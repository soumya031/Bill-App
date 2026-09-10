# PricePilot Bill – Project Technical Report

## 1. Executive Summary

PricePilot Bill is an Android-first business billing and accounting application designed for local commerce, inventory management, payment tracking, GST-aware invoicing, and financial reporting. The application is positioned as a lightweight digital ledger system for small and medium businesses, with a strong emphasis on offline usability, financial correctness, and business workflow continuity.

The system has been structured in a way that supports both local-first operation and future backend-driven synchronization. The current architecture combines a Flutter mobile client with a local SQLite repository for business logic and an API-ready backend foundation for remote services, authentication, and sync operations.

This report is prepared in alignment with the standard formal structure used in the Bill app.docx reference and focuses on product scope, backend architecture, mobile integration, security, data flow, and implementation readiness.

---

## 2. Project Overview

### 2.1 Business Objective
The core objective of the application is to digitize and simplify business operations such as:

- Sales invoicing and payment collection
- Supplier and purchase tracking
- Inventory and stock movement management
- Expense and cash flow monitoring
- GST-aware financial reporting
- Ledger-based financial visibility
- Business profile and onboarding management

### 2.2 Target Users
- Retail and wholesale business owners
- Small shop operators
- Traders and distributors
- Field sales and accounting staff
- Business operators who need a mobile-first accounting suite

### 2.3 Product Positioning
The product is intended to be:

- Android-first
- Offline-capable for daily operations
- Optimized for Indian business workflows
- Lightweight enough for local business use
- Ready for backend sync and multi-device expansion

---

## 3. Functional Scope

### 3.1 Core Modules
The current application includes the following modules:

1. Business onboarding and setup
2. Customer management
3. Supplier management
4. Product and inventory management
5. Sales invoice creation and tracking
6. Purchase management
7. Payment in and payment out workflows
8. Expense tracking
9. Dashboard and financial overview
10. Reports and analytics
11. Audit log and sync controls
12. App lock and session management

### 3.2 Business Workflow Coverage
The application supports a complete operational cycle:

- Create business profile
- Add products and stock
- Add customers and suppliers
- Create purchase records
- Create sales invoices
- Receive and track payments
- Monitor outstanding balances
- Review reports and cash flow
- Export or print invoices and reports

---

## 4. Technical Architecture

### 4.1 Client Layer
The mobile application is built using Flutter and Dart, with Material 3-based UI and Provider-based state management.

The client architecture includes:

- Mobile app shell and navigation layer
- Session management and onboarding gate
- Business, customer, supplier, and product repositories
- Local database and ledger logic
- Invoice creation and PDF export
- Sync engine placeholder for backend coordination

### 4.2 Data Layer
The app uses SQLite for local persistence via sqflite, which is appropriate for Android-first offline business workflows. The repository layer handles:

- Business records
- Inventory entries
- Purchase and sales invoice records
- Payment audit trail
- Ledger entries
- Sync queue for pending remote operations

### 4.3 Backend Layer
The active backend foundation is built with Node.js, TypeScript, and Fastify. It provides:

- JWT-based authentication and bearer-token protection
- Business, customer, product, and invoice REST APIs
- Request validation with Zod
- Password hashing with bcryptjs
- Invoice totals and business logic services
- Sync queue ingestion for offline-first records
- A lightweight architecture ready for future PostgreSQL/Prisma adoption

This backend is intentionally compact and service-oriented rather than monolithic, matching the current project phase and mobile-first workflow.

---

## 5. Data Model Design

### 5.1 Core Entities
The domain model covers the following main entities:

- Business
- User
- Customer
- Supplier
- Product
- Invoice
- InvoiceItem
- Payment
- Expense
- LedgerEntry
- SyncQueueItem
- AuditLog

### 5.2 Key Attributes

Business entity includes:
- Business name
- GST information
- State and city
- Invoice prefix
- Currency
- Tax registration flag

Customer and supplier entities include:
- Name
- Contact details
- GSTIN
- Opening balance
- Credit terms and notes

Product entity includes:
- SKU and category
- Purchase and sale price
- GST rate
- Quantity and stock threshold
- Inventory status

Invoice entity includes:
- Invoice number
- Customer reference
- Totals, discount, tax, and final amount
- Payment state and issue date

---

## 6. Backend Architecture Details

### 6.1 Service Structure
The backend follows a compact, production-oriented service layout:

- Authentication service
- Ledger and invoice totals service
- Sync queue service
- Store abstraction for in-memory bootstrap data
- Route layer for HTTP APIs

### 6.2 API Design
The backend exposes REST endpoints for:

- Auth registration
- Auth login
- Business listing and creation
- Customer retrieval and creation
- Product retrieval and creation
- Invoice retrieval and creation
- Sync push operations
- Health check endpoint

### 6.3 Security Model
The current implementation follows a practical and lean security model:

- Password hashing with bcrypt
- JWT token generation for authenticated requests
- Authorization checks on protected endpoints
- Business-scoped access boundaries
- Session persistence in the mobile app

### 6.4 Future-Ready Persistence
A Prisma schema has been created to support migration to a relational database in production, especially PostgreSQL. This gives the project a clean path to:

- Multi-user support
- Tenant-safe business data isolation
- Stronger transaction handling
- Better reporting and audit compliance

---

## 7. Android Application Integration

### 7.1 Current Mobile Stack
The app is built with:

- Flutter
- Dart
- Provider state management
- SQLite repository pattern
- Material 3 UI
- Local business logic engine

### 7.2 Backend Client Layer
The Android app now includes a minimal API client layer to integrate with the backend, including:

- HTTP client wrapper
- Auth service
- Business service
- Inventory service
- Sync service

This layer is intentionally lightweight to minimize project complexity and maintain better maintainability.

### 7.3 Operational Model
The app supports a hybrid mode:

- Local-first execution for offline business work
- Backend-ready auth and sync hooks
- Graceful fallback when the backend is unavailable

This hybrid approach is ideal for real-world business continuity on Android devices.

---

## 8. Security and Risk Considerations

### 8.1 Security Checks
The implementation includes:

- Password hashing
- JWT verification
- Protected API routes
- Session token persistence
- Local PIN lock in the app

### 8.2 Key Risks
The following are important future risks to address:

- Move from in-memory backend storage to database-backed persistence
- Add row-level access control for multi-business tenancy
- Introduce rate limiting and request validation hardening
- Add robust audit trail and event replay controls
- Add deployment environment separation for dev, QA, and prod

### 8.3 Data Integrity
The application already demonstrates strong focus on ledger integrity, invoice consistency, and financial calculation correctness. The backend and local models are designed around preserving account balance, stock movement, and invoice totals with clear transaction boundaries.

---

## 9. Deployment and Production Readiness

### 9.1 Current Status
The project is at a strong MVP-to-early-production stage. It has:

- Android-first application shell
- Local business data persistence
- Functional billing and inventory modules
- Initial backend service layer
- Auth and sync capability foundation
- API-ready architecture for future scaling

### 9.2 Recommended Next Steps
1. Replace in-memory backend data store with PostgreSQL and Prisma
2. Add real tenant and business authorization rules
3. Add production logging and monitoring
4. Add API testing and integration test coverage
5. Add deployment environment configuration
6. Add Docker and CI/CD flow for backend deployment
7. Connect full app modules to backend APIs progressively

---

## 10. Conclusion

PricePilot Bill is a practical, business-oriented billing application with a clean mobile-first design and a backend-ready architecture that can evolve from a local SQLite application into a robust cloud service. The project has already established its domain model, data integrity practices, and backend service foundation in a compact and maintainable way.

The implementation approach emphasizes:

- business practicality
- Android usability
- financial correctness
- minimal complexity
- scalable future backend integration

This makes the project well-suited for further growth into a production-grade billing and accounting platform.

---

## 11. Approved Status

Status: Completed foundation and technical backend setup for Android-first business billing application.

Prepared for: Product and engineering review.

Prepared by: Senior Backend & Architecture Review.
