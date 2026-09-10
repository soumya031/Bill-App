# PricePilot Bill Backend

This is the backend starter for the Android-first billing app.

## Stack

- Fastify + TypeScript
- JWT auth
- JSON schemas via Zod
- In-memory store for bootstrapping, ready for PostgreSQL/Prisma later

## Run locally

```bash
npm install
npm run dev
```

## Primary API surface

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

## Production next steps

1. Replace in-memory persistence with PostgreSQL + Prisma.
2. Add tenant scoping by businessId.
3. Add invoice totals, ledger posting, and stock movement service rules.
4. Add rate limits, hashing, and audit logging.
5. Add background sync workers and retry policies.
