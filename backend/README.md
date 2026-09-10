# PricePilot Bill Backend

Node.js + Fastify service for the PricePilot Bill mobile-first billing platform.

## Tech stack

- Node.js 20+
- Fastify v5
- TypeScript
- JWT-based authentication
- Zod request validation
- bcryptjs password hashing
- In-memory persistence for bootstrapping and local testing

## Local development

```bash
npm install
npm run dev
```

## Production build

```bash
npm run build
npm start
```

## Verification

```bash
npm test
```

## API surface

- `GET /health`
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `GET /api/v1/businesses`
- `POST /api/v1/businesses`
- `GET /api/v1/customers`
- `POST /api/v1/customers`
- `GET /api/v1/products`
- `POST /api/v1/products`
- `GET /api/v1/invoices`
- `POST /api/v1/invoices`
- `POST /api/v1/sync/push`

## Notes

- The backend is intentionally lightweight and uses an in-memory store for the current stage of the project.
- Auth routes are public; all business and ledger endpoints require a bearer token.
- The API is designed to be extended toward PostgreSQL, Prisma, tenant-aware data access, and background sync workers in the next phase.
