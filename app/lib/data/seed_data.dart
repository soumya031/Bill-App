import '../core/billing_engine.dart';
import '../core/dates.dart';
import '../core/models.dart';
import '../core/money.dart';
import 'repositories.dart';

Future<void> seedDemoData(Repository repo, int businessId) async {
  final productMaps = [
    ('Premium A4 Paper', 'PAP-001', 'Office', '4802', 18, 200, 320, 420, 480, 40, 120),
    ('Thermal Receipt Roll', 'ROL-014', 'Supplies', '4821', 12, 55, 85, 100, 120, 20, 42),
    ('Desk Organizer', 'ORG-220', 'Office', '3926', 18, 380, 640, 720, 840, 25, 18),
    ('Packing Tape', 'TAP-102', 'Packaging', '3919', 28, 60, 120, 140, 160, 30, 7),
    ('Wireless Mouse', 'ELC-031', 'Electronics', '8471', 18, 450, 899, 999, 1299, 10, 15),
    ('Bluetooth Speaker', 'ELC-044', 'Electronics', '8518', 18, 750, 1499, 1699, 1999, 8, 9),
  ];
  final productIds = <int>[];
  for (final p in productMaps) {
    final product = Product(
      name: p.$1,
      sku: p.$2,
      category: p.$3,
      hsn: p.$4,
      gstRate: p.$5,
      purchasePrice: p.$6 * 100,
      salePrice: p.$7 * 100,
      wholesalePrice: p.$8 * 100,
      mrp: p.$9 * 100,
      stock: p.$10,
      costAverage: p.$6 * 100,
      lowStockThreshold: p.$11 > 30 ? 30 : p.$11,
    );
    final id = await repo.upsertProduct(product, businessIdOverride: businessId);
    productIds.add(id);
  }

  final customerSeeds = [
    ('Meera Enterprises', '9845012345', 'meera@example.com', 'Bengaluru', '', 0, 50000, 30),
    ('Northstar Foods', '9821122334', 'accounts@northstar.in', 'Bengaluru', '29ABCDE1234F1Z5', 0, 0, 15),
    ('Aarav Retail', '9611456789', 'aarav@example.com', 'Hubli', '', 12000, 0, 15),
    ('Bloom Studio', '9740001122', 'hello@bloom.studio', 'Shimoga', '', 0, 25000, 30),
  ];
  final customerIds = <int>[];
  for (final c in customerSeeds) {
    final customer = Customer(
      name: c.$1,
      phone: c.$2,
      email: c.$3,
      state: c.$4,
      gstin: c.$5,
      openingBalance: c.$6 * 100,
      creditLimit: c.$7 * 100,
      paymentTermsDays: c.$8,
    );
    customerIds.add(await repo.upsertCustomer(customer, businessIdOverride: businessId));
  }

  final suppliers = [
    ('Paper House', '9880011223', 'paperhouse@example.com', 'Bengaluru', '29AABCP1122K1Z1', 0, 30),
    ('PackRight Supplies', '9899022110', 'sales@packright.in', 'Bengaluru', '29AACCP7788Q1Z8', 24000, 15),
  ];
  for (final s in suppliers) {
    await repo.upsertSupplier(Supplier(
      name: s.$1,
      phone: s.$2,
      email: s.$3,
      state: s.$4,
      gstin: s.$5,
      openingBalance: s.$6 * 100,
      creditPeriodDays: s.$7,
    ), businessIdOverride: businessId);
  }

  final today = DateTime.now();
  Future<String> backDate(int days) =>
      Future.value(isoDate(today.subtract(Duration(days: days))));

  final sampleInvoices = <(int, int, num, int, double)>[
    (productIds[0], 3, 340, 18, 0),
    (productIds[1], 10, 90, 12, 0),
  ];
  await _seedInvoice(repo, businessId, customerIds[0], 'INV-0001',
      await backDate(6), sampleInvoices, paymentMode: 'UPI', amountPaid: 0, notes: 'Partial payment');

  await _seedInvoice(repo, businessId, customerIds[1], 'INV-0002',
      await backDate(3), <(int, int, num, int, double)>[
        (productIds[2], 2, 680, 18, 0),
        (productIds[4], 1, 949, 18, 0),
      ],
      paymentMode: 'Cash', amountPaid: 0);

  await _seedInvoice(repo, businessId, customerIds[2], 'INV-0003',
      await backDate(1), <(int, int, num, int, double)>[
        (productIds[5], 1, 1599, 18, 0),
        (productIds[1], 5, 90, 12, 0),
      ],
      paymentMode: 'Card', amountPaid: 0);

  await repo.recordPayment(
    businessId: businessId,
    partyType: 'customer',
    amount: Money.fromRupees(1000).paise,
    date: await backDate(2),
    mode: 'UPI',
    invoiceIds: [1],
  );

  await repo.recordExpense(
    businessId: businessId,
    category: 'Rent',
    amount: Money.fromRupees(25000).paise,
    mode: 'Bank transfer',
    date: await backDate(5),
    description: 'Monthly store rent',
  );
}

Future<void> _seedInvoice(
  Repository repo,
  int businessId,
  int customerId,
  String number,
  String date,
  List<(int, int, num, int, double)> items, {
  required String paymentMode,
  required int amountPaid,
  String? notes,
}) async {
  final inputs = items
      .map((i) => LineCalcInput(
            quantity: i.$2.toDouble(),
            price: (i.$3 * 100).round(),
            gstRate: i.$4,
            discountPercent: i.$5,
          ))
      .toList();
  final quote = BillingEngine.calculateQuote(
    lines: inputs,
    invoiceDiscount: const InvoiceDiscountInput.none(),
    businessState: 'Karnataka',
    customerState: 'Karnataka',
  );
  final lines = <InvoiceLine>[];
  for (var i = 0; i < items.length; i++) {
    final productId = items[i].$1;
    final result = quote.lines[i];
    lines.add(InvoiceLine(
      productId: productId,
      name: _productName(productId),
      hsn: ' ',
      gstRate: items[i].$4,
      quantity: items[i].$2.toDouble(),
      price: (items[i].$3 * 100).round(),
      discount: result.discount.paise,
      discountPercent: items[i].$5,
      taxable: result.taxable.paise,
      tax: result.tax.paise,
    ));
  }
  await repo.finalizeSale(
    businessId: businessId,
    number: number,
    customerId: customerId,
    customerName: 'Customer',
    date: date,
    gstType: 'gst',
    quote: quote,
    lines: lines,
    paymentMode: paymentMode,
    notes: notes,
    amountPaid: amountPaid,
  );
}

String _productName(int id) => switch (id) {
      1 => 'Premium A4 Paper',
      2 => 'Thermal Receipt Roll',
      3 => 'Desk Organizer',
      4 => 'Packing Tape',
      5 => 'Wireless Mouse',
      6 => 'Bluetooth Speaker',
      _ => 'Item',
    };