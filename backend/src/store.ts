import { Business, Customer, Invoice, Product, SyncQueueItem, User } from './types.js';

export class InMemoryStore {
  users: User[] = [];
  businesses: Business[] = [];
  customers: Customer[] = [];
  products: Product[] = [];
  invoices: Invoice[] = [];
  syncQueue: SyncQueueItem[] = [];

  seed(): void {
    const now = new Date().toISOString();

    this.users.push({
      id: 'user_1',
      name: 'Demo Owner',
      email: 'owner@pricepilot.com',
      passwordHash: '$2a$10$2nknM7sKjH2XQ2Lqvs8M9uNGz3rWq5xVg4sJmB4ZZx4fPj3i5QWc2',
      role: 'owner',
      createdAt: now,
    });

    this.businesses.push({
      id: 'biz_1',
      name: 'Sharma Electronics',
      ownerName: 'Raj Sharma',
      gstin: '29ABCDE1234F1Z5',
      city: 'Shimoga',
      state: 'Karnataka',
      currency: 'INR',
      createdAt: now,
    });
  }

  private nextId(prefix: string): string {
    const rand = Math.random().toString(36).slice(2, 10);
    return `${prefix}_${rand}`;
  }

  findUserByEmail(email: string): User | undefined {
    return this.users.find((u) => u.email.toLowerCase() === email.toLowerCase());
  }

  createUser(user: Omit<User, 'id' | 'createdAt'>): User {
    const entity: User = {
      ...user,
      id: this.nextId('user'),
      createdAt: new Date().toISOString(),
    };
    this.users.push(entity);
    return entity;
  }

  listBusinessesByUser(userId: string): Business[] {
    return this.businesses.filter((b) => b.id === 'biz_1' || userId.length > 0);
  }

  createBusiness(input: Omit<Business, 'id' | 'createdAt'>): Business {
    const entity: Business = {
      ...input,
      id: this.nextId('biz'),
      createdAt: new Date().toISOString(),
    };
    this.businesses.push(entity);
    return entity;
  }

  listCustomers(businessId: string): Customer[] {
    return this.customers.filter((c) => c.businessId === businessId);
  }

  createCustomer(input: Omit<Customer, 'id' | 'createdAt'>): Customer {
    const entity: Customer = {
      ...input,
      id: this.nextId('cust'),
      createdAt: new Date().toISOString(),
    };
    this.customers.push(entity);
    return entity;
  }

  listProducts(businessId: string): Product[] {
    return this.products.filter((p) => p.businessId === businessId);
  }

  createProduct(input: Omit<Product, 'id' | 'createdAt'>): Product {
    const entity: Product = {
      ...input,
      id: this.nextId('prod'),
      createdAt: new Date().toISOString(),
    };
    this.products.push(entity);
    return entity;
  }

  listInvoices(businessId: string): Invoice[] {
    return this.invoices.filter((i) => i.businessId === businessId);
  }

  createInvoice(input: Omit<Invoice, 'id' | 'createdAt'>): Invoice {
    const entity: Invoice = {
      ...input,
      id: this.nextId('inv'),
      createdAt: new Date().toISOString(),
    };
    this.invoices.push(entity);
    return entity;
  }

  enqueueSync(item: Omit<SyncQueueItem, 'id' | 'createdAt'>): SyncQueueItem {
    const entity: SyncQueueItem = {
      ...item,
      id: this.nextId('sync'),
      createdAt: new Date().toISOString(),
    };
    this.syncQueue.push(entity);
    return entity;
  }
}

export const store = new InMemoryStore();
store.seed();
