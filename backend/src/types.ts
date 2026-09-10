export type Role = 'owner' | 'manager' | 'staff';

export interface User {
  id: string;
  name: string;
  email: string;
  passwordHash: string;
  role: Role;
  createdAt: string;
}

export interface Business {
  id: string;
  name: string;
  ownerName?: string;
  gstin?: string;
  city?: string;
  state?: string;
  currency: string;
  createdAt: string;
}

export interface Customer {
  id: string;
  businessId: string;
  name: string;
  phone?: string;
  email?: string;
  gstin?: string;
  billingAddress?: string;
  city?: string;
  openingBalance: number;
  createdAt: string;
}

export interface Product {
  id: string;
  businessId: string;
  name: string;
  sku?: string;
  category?: string;
  hsn?: string;
  unit: string;
  gstRate: number;
  purchasePrice: number;
  salePrice: number;
  stock: number;
  createdAt: string;
}

export interface InvoiceItem {
  id: string;
  productId?: string;
  name: string;
  hsn?: string;
  quantity: number;
  price: number;
  gstRate: number;
  discount: number;
  taxable: number;
  tax: number;
}

export interface Invoice {
  id: string;
  businessId: string;
  number: string;
  customerId?: string;
  customerName: string;
  date: string;
  dueDate?: string;
  subtotal: number;
  discount: number;
  tax: number;
  total: number;
  status: 'Draft' | 'Finalized' | 'Paid';
  items: InvoiceItem[];
  createdAt: string;
}

export interface SyncQueueItem {
  id: string;
  businessId: string;
  entity: string;
  entityId: string;
  op: 'upsert' | 'delete';
  payload: string;
  createdAt: string;
  processedAt?: string;
}
