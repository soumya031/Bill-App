export class InMemoryStore {
    users = [];
    businesses = [];
    customers = [];
    products = [];
    invoices = [];
    syncQueue = [];
    seed() {
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
    nextId(prefix) {
        const rand = Math.random().toString(36).slice(2, 10);
        return `${prefix}_${rand}`;
    }
    findUserByEmail(email) {
        return this.users.find((u) => u.email.toLowerCase() === email.toLowerCase());
    }
    createUser(user) {
        const entity = {
            ...user,
            id: this.nextId('user'),
            createdAt: new Date().toISOString(),
        };
        this.users.push(entity);
        return entity;
    }
    listBusinessesByUser(userId) {
        return this.businesses.filter((b) => b.id === 'biz_1' || userId.length > 0);
    }
    createBusiness(input) {
        const entity = {
            ...input,
            id: this.nextId('biz'),
            createdAt: new Date().toISOString(),
        };
        this.businesses.push(entity);
        return entity;
    }
    listCustomers(businessId) {
        return this.customers.filter((c) => c.businessId === businessId);
    }
    createCustomer(input) {
        const entity = {
            ...input,
            id: this.nextId('cust'),
            createdAt: new Date().toISOString(),
        };
        this.customers.push(entity);
        return entity;
    }
    listProducts(businessId) {
        return this.products.filter((p) => p.businessId === businessId);
    }
    createProduct(input) {
        const entity = {
            ...input,
            id: this.nextId('prod'),
            createdAt: new Date().toISOString(),
        };
        this.products.push(entity);
        return entity;
    }
    listInvoices(businessId) {
        return this.invoices.filter((i) => i.businessId === businessId);
    }
    createInvoice(input) {
        const entity = {
            ...input,
            id: this.nextId('inv'),
            createdAt: new Date().toISOString(),
        };
        this.invoices.push(entity);
        return entity;
    }
    enqueueSync(item) {
        const entity = {
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
