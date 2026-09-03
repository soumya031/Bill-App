# Stitch Bill — QA report

**Build under test:** `Bill-App/app` (Flutter 3.47.2 / Dart 3.13.2)
**Device:** Android emulator, Pixel 7 (API 36, 1080×2400)
**Date:** 2026-09-02
**Artefacts:** [`demo.mp4`](demo.mp4) — 4m25s recording of the full flow on the fixed build

---

## 1. Automated checks

| Check | Result |
|---|---|
| `flutter analyze` | clean — no issues |
| `flutter test` | **37 / 37 pass** |

Test files:

- `test/core/money_test.dart` — paise formatting, Indian digit grouping
- `test/core/billing_engine_test.dart` — line/quote maths, discounts, tax-inclusive prices, rounding, CGST/SGST vs IGST, `intraStateOverride`, mixed-rate tax
- `test/core/…`, `test/widget_test.dart`, `test/app_gate_test.dart` — money widget, session gate, PIN hashing
- **`test/data/repository_db_test.dart` (new)** — runs the real `Repository` against an in-memory copy of the real schema. This is the check that catches SQL/schema drift: a column that does not exist, an ambiguous column in a JOIN, a ledger sign flipped the wrong way, invoice-number collisions.

---

## 2. Manual test matrix

| Area | Cases exercised | Result |
|---|---|---|
| Onboarding | phone → mock OTP → business setup, GST toggle, sample data | pass |
| Dashboard | today's summary, financial position, low-stock banner, pull-to-refresh, quick actions | pass |
| New sale | customer picker (walk-in / existing / add new), add item, edit line (qty, price, disc %, GST), remove line, invoice discount (% and ₹), intra/inter-state toggle, partial payment, notes, date picker | pass |
| Invoice detail | line breakdown, subtotal → tax → round-off → total, paid/balance, status chip | pass |
| PDF | print preview render, share sheet (`INV-0001.pdf`), amount in words | pass |
| Payment in | party pick, live amount label, allocation across outstanding invoices, advance remainder, invoice status → Paid / Partially paid | pass |
| Payment out | supplier pick, ledger direction | pass |
| Purchase | supplier / direct vendor, add + edit line, GST, notes, stock increase, cost-average update, payables | pass |
| Expense | category, mode, date, description, vendor; zero-amount rejected | pass |
| Stock | search, All / Low / Out filters, product tile, stock history, adjust stock | pass |
| Parties | customer + supplier lists with live balances, search, detail, statement / invoices tabs, edit | pass |
| Reports | Today / Week / Month / Year, six stat tiles, expense breakdown, best sellers | pass |
| More | business profile edit + save, audit log, data sync → Sync now → Synced, backup & export, invoice settings | pass |
| App lock | set 4-digit PIN, lock from app bar, wrong PIN rejected, correct PIN unlocks, cold-start lock | pass |
| Ledger integrity | receivables / payables / cash / bank / stock value cross-checked against invoices, payments and expenses | pass |

Cross-checks were done against the on-device SQLite file, not just the UI.

---

## 3. Bugs found and fixed

### 3.1 App would not run at all

| # | Bug | Fix |
|---|---|---|
| 1 | `SyncEngine` was never provided, but `AppShell` and `MoreTab` both call `context.watch<SyncEngine>()` → `ProviderNotFoundException` the moment onboarding finished. The app never opened. | `MultiProvider` in `main.dart` |
| 2 | `createPurchase` inserted a `notes` column that does not exist on `expenses` → **every** purchase save failed | notes fold into the description |
| 3 | "Add item" on a new sale called `lines.indexOf(newLine)`, got `-1`, and dropped the line — nothing could be billed | append when absent |
| 4 | Quick-action sheet emitted `'Purchase'`; the switch matched `'New Purchase'` → button did nothing | case renamed |
| 5 | **Reports never loaded.** `bestProducts` selects `SUM(taxable)` across a JOIN where both `invoice_items` and `invoices` have a `taxable` column → `ambiguous column name`, thrown out of `_load()`, leaving a permanent spinner | columns qualified; `_load` now surfaces an error instead of spinning forever |
| 6 | **The first three sales after onboarding always failed.** Sample data wrote `INV-0001…0003` but left `businesses.invoice_sequence` at 0, so the first real sale reused `INV-0001` and hit the UNIQUE index on `(business_id, number)` | seed draws numbers from `nextInvoiceNumber` |

### 3.2 Money correctness

| # | Bug | Fix |
|---|---|---|
| 7 | The billing engine multiplied `price × qty × 100`, treating price as rupees, while the DB, forms and seed data all store **paise** — every invoice was **100× too large** (₹2,20,800 instead of ₹2,208) | engine works in paise; the three tests that encoded the rupee assumption were restated |
| 8 | GST was applied via a blended **integer** rate, so mixed-rate invoices drifted (₹2,208 vs the correct ₹2,212) | sums exact per-line tax, scaled by the invoice discount |
| 9 | The checkout intra/inter-state toggle changed only the saved label, not the CGST/SGST-vs-IGST split | `intraStateOverride` + recompute at save |
| 10 | Dashboard cash/bank summed `credit − debit`, but cash-in is a debit — balances had inverted signs | `debit − credit` |
| 11 | "Profit" compared GST-inclusive sales against costs | uses taxable |
| 12 | `createPurchase` divided by `stock + qty` unguarded → `NaN.round()` crash | guarded |

### 3.3 Lockouts and dead UI

| # | Bug | Fix |
|---|---|---|
| 13 | `load()` cleared the lock flag on every start, so the app-lock PIN never re-locked | stays locked when a PIN exists |
| 14 | `completeOnboarding` / `updatePin` stored the **raw** PIN while `verifyPin` compares hashes — a guaranteed lockout | both hash |
| 15 | A PIN could be set to 5–6 digits, but the lock screen auto-submits at exactly 4 — permanent lockout | capped at 4, digits only |
| 16 | Setting or changing the PIN immediately locked the session the user was working in | `setPin`/`updatePin` clear the lock |
| 17 | `products()` / `suppliers()` accepted `includeInactive` and ignored it — stock history hung on an inactive product | flag honoured |

### 3.4 Feedback and refresh

| # | Bug | Fix |
|---|---|---|
| 18 | Validation errors and save failures raised from a bottom sheet or dialog were **invisible** — the SnackBar is painted behind the modal, so "Save" appeared to do nothing | `showAppMessage` renders in the root overlay |
| 19 | Quick-action saves committed correctly but the visible tab kept showing stale numbers until a manual pull-to-refresh | tabs reload after a write; sync badge refreshes |
| 20 | `CheckboxListTile` inside `AppCard` threw a framework assertion on every build and swallowed its ink splash | transparent `Material` inside the card |
| 21 | `SegmentedButton` labels clipped ("Customers" → "Customer\ns", "Month" → "Mont\nh") — the selected-check icon stole the label's width | `showSelectedIcon: false` on all five |
| 22 | `AsyncButton` labels overflowed their button by 10px | label ellipsizes |
| 23 | Negative cash / bank balances were painted green | red when negative |
| 24 | Stray leading comma in the low-stock banner when only "out of stock" applied | joined properly |
| 25 | The payment amount field never triggered a rebuild, so the button label and advance hint stayed stale while typing | listener + dispose |
| 26 | The header "add item" button was disabled exactly when the cart was empty | always enabled |
| 27 | The business-profile card looked tappable but only the small chevron was | whole card is an `InkWell` |

### 3.5 Data layer hygiene

| # | Bug | Fix |
|---|---|---|
| 28 | `upsertProduct` passed `null` in `whereArgs` — unsupported by sqflite (warns it will throw in a future version), and `sku = NULL` never matches, so the duplicate check silently did nothing | only compares identifiers that were filled in |
| 29 | Seeded invoices were all billed to the literal name "Customer" | real customer names |
| 30 | `lib/backend/bill_database.dart` — a second, unused SQLite layer competing with the real one | deleted |

---

## 4. Known issues — not fixed

Deliberately left alone; none of these block use.

- **Stock history ordering in demo data.** History is oldest-first, but seeded "opening" moves are stamped with today's date while seeded sales are backdated, so the running "after" column reads out of order until real activity accumulates.
- **Invoice numbers can gap.** `nextInvoiceNumber` commits its increment before the invoice insert, so a failed save burns a number. Harmless, but sequential-numbering audits would notice.
- **The PIN is not a security boundary.** It is a djb2 hash in `SharedPreferences` — fine as a convenience lock, not as protection for the data at rest. `SECURITY.md` should say so.
- **`_amountInWords` breaks above ₹100 crore** (index out of range on the crore group).
- **`AppAmountField` accepts multiple decimal points** — "1.2.3" fails to parse and is treated as 0.
- **Several form sheets do not dispose their `TextEditingController`s** — a small leak, not user-visible.
- **Seeded customer "state" values are city names** ("Bengaluru", "Hubli"), so seeded sales default to IGST against a Karnataka business. Real data entered through the UI behaves correctly.
- **Android's "16 KB page size" dialog** on first launch is a platform notice about Flutter's own prebuilt `.so` files, not an app defect.

---

## 5. Reproducing the demo

```bash
cd Bill-App/app
flutter test                       # 37 tests
flutter emulators --launch Pixel_7
flutter run -d emulator-5554
```

The recording in `demo.mp4` walks, in order: onboarding → dashboard → a new GST sale
(customer, item, 10% invoice discount, intra-state split, part payment) → the invoice and
its PDF → payment allocation settling an invoice → a purchase updating stock → stock
filters and a stock adjustment → parties and a customer statement → reports for the month
and year → audit log → data sync → setting a PIN, locking and unlocking.
