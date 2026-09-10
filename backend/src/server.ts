import Fastify from 'fastify';
import { z } from 'zod';
import { config } from './config.js';
import { verifyAccessToken } from './lib/jwt.js';
import { registerUser, loginUser } from './services/auth.js';
import { calculateInvoiceTotals } from './services/ledger.js';
import { enqueueSync } from './services/sync.js';
import { store } from './store.js';

const app = Fastify({ logger: config.nodeEnv !== 'production' });

const authRegisterSchema = z.object({
  name: z.string().min(2),
  email: z.string().email(),
  password: z.string().min(6),
});

const authLoginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
});

const businessSchema = z.object({
  name: z.string().min(2),
  ownerName: z.string().optional(),
  gstin: z.string().optional(),
  city: z.string().optional(),
  state: z.string().optional(),
  currency: z.string().default('INR'),
});

const customerSchema = z.object({
  businessId: z.string(),
  name: z.string().min(2),
  phone: z.string().optional(),
  email: z.string().optional(),
  gstin: z.string().optional(),
  billingAddress: z.string().optional(),
  city: z.string().optional(),
  openingBalance: z.number().default(0),
});

const productSchema = z.object({
  businessId: z.string(),
  name: z.string().min(2),
  sku: z.string().optional(),
  category: z.string().optional(),
  hsn: z.string().optional(),
  unit: z.string().default('pc'),
  gstRate: z.number().default(0),
  purchasePrice: z.number().default(0),
  salePrice: z.number().default(0),
  stock: z.number().default(0),
});

const invoiceItemSchema = z.object({
  productId: z.string().optional(),
  name: z.string(),
  hsn: z.string().optional(),
  quantity: z.number().default(1),
  price: z.number().default(0),
  gstRate: z.number().default(0),
  discount: z.number().default(0),
});

const invoiceSchema = z.object({
  businessId: z.string(),
  number: z.string().min(1),
  customerId: z.string().optional(),
  customerName: z.string().min(1),
  date: z.string(),
  dueDate: z.string().optional(),
  items: z.array(invoiceItemSchema),
});

app.get('/health', async () => ({ ok: true, service: 'pricepilot-bill-backend' }));

app.post('/api/v1/auth/register', async (request, reply) => {
  const parsed = authRegisterSchema.safeParse(request.body);
  if (!parsed.success) {
    return reply.code(400).send({ error: 'Invalid registration payload' });
  }

  try {
    const result = await registerUser(parsed.data);
    return reply.code(201).send(result);
  } catch (error) {
    if (error instanceof Error && error.message === 'USER_EXISTS') {
      return reply.code(409).send({ error: 'User already exists' });
    }
    return reply.code(500).send({ error: 'Registration failed' });
  }
});

app.post('/api/v1/auth/login', async (request, reply) => {
  const parsed = authLoginSchema.safeParse(request.body);
  if (!parsed.success) {
    return reply.code(400).send({ error: 'Invalid login payload' });
  }

  try {
    return await loginUser(parsed.data);
  } catch (error) {
    if (error instanceof Error && error.message === 'INVALID_CREDENTIALS') {
      return reply.code(401).send({ error: 'Invalid credentials' });
    }
    return reply.code(500).send({ error: 'Login failed' });
  }
});

app.addHook('preHandler', async (request, reply) => {
  const authHeader = request.headers.authorization;
  if (request.url.startsWith('/api/v1/auth/')) return;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return reply.code(401).send({ error: 'Missing bearer token' });
  }
  try {
    const token = authHeader.replace('Bearer ', '');
    const payload = verifyAccessToken(token);
    request.headers.user = payload as never;
  } catch {
    return reply.code(401).send({ error: 'Invalid token' });
  }
});

app.get('/api/v1/businesses', async () => store.businesses);

app.post('/api/v1/businesses', async (request, reply) => {
  const parsed = businessSchema.safeParse(request.body);
  if (!parsed.success) {
    return reply.code(400).send({ error: 'Invalid business payload' });
  }

  const business = store.createBusiness(parsed.data);
  return reply.code(201).send(business);
});

app.get('/api/v1/customers', async (request) => {
  const businessId = String(request.headers['x-business-id'] ?? 'biz_1');
  return store.listCustomers(businessId);
});

app.post('/api/v1/customers', async (request, reply) => {
  const parsed = customerSchema.safeParse(request.body);
  if (!parsed.success) {
    return reply.code(400).send({ error: 'Invalid customer payload' });
  }

  const customer = store.createCustomer(parsed.data);
  return reply.code(201).send(customer);
});

app.get('/api/v1/products', async (request) => {
  const businessId = String(request.headers['x-business-id'] ?? 'biz_1');
  return store.listProducts(businessId);
});

app.post('/api/v1/products', async (request, reply) => {
  const parsed = productSchema.safeParse(request.body);
  if (!parsed.success) {
    return reply.code(400).send({ error: 'Invalid product payload' });
  }

  const product = store.createProduct(parsed.data);
  return reply.code(201).send(product);
});

app.get('/api/v1/invoices', async (request) => {
  const businessId = String(request.headers['x-business-id'] ?? 'biz_1');
  return store.listInvoices(businessId);
});

app.post('/api/v1/invoices', async (request, reply) => {
  const parsed = invoiceSchema.safeParse(request.body);
  if (!parsed.success) {
    return reply.code(400).send({ error: 'Invalid invoice payload' });
  }

  const items = parsed.data.items.map((item, index) => {
    const lineTotal = item.quantity * item.price;
    const taxable = Math.max(lineTotal - item.discount, 0);
    const tax = (taxable * item.gstRate) / 100;
    return {
      id: `invitem_${index + 1}`,
      productId: item.productId,
      name: item.name,
      hsn: item.hsn,
      quantity: item.quantity,
      price: item.price,
      gstRate: item.gstRate,
      discount: item.discount,
      taxable,
      tax,
    };
  });

  const totals = calculateInvoiceTotals(parsed.data.items);

  const invoice = store.createInvoice({
    ...parsed.data,
    items,
    subtotal: totals.subtotal,
    discount: totals.discount,
    tax: totals.tax,
    total: totals.total,
    status: 'Finalized',
  });

  return reply.code(201).send(invoice);
});

app.post('/api/v1/sync/push', async (request, reply) => {
  const queueItem = z.object({
    businessId: z.string(),
    entity: z.string(),
    entityId: z.string(),
    op: z.enum(['upsert', 'delete']),
    payload: z.string(),
  }).safeParse(request.body);

  if (!queueItem.success) {
    return reply.code(400).send({ error: 'Invalid sync payload' });
  }

  const record = enqueueSync({
    businessId: queueItem.data.businessId,
    entity: queueItem.data.entity,
    entityId: queueItem.data.entityId,
    op: queueItem.data.op,
    payload: queueItem.data.payload,
  });

  return reply.code(202).send({ accepted: true, record });
});

const start = async () => {
  try {
    await app.listen({ port: config.port, host: '0.0.0.0' });
    app.log.info(`Server listening at http://localhost:${config.port}`);
  } catch (error) {
    app.log.error(error);
    process.exit(1);
  }
};

start();
