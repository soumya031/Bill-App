import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'backend/bill_database.dart';

class CustomerRecord {
  CustomerRecord(this.name, this.contact, this.balance);
  String name;
  String contact;
  double balance;
}

class ProductRecord {
  ProductRecord(this.name, this.sku, this.category, this.stock, this.price);
  String name;
  String sku;
  String category;
  int stock;
  double price;
}

class InvoiceRecord {
  InvoiceRecord(
      this.number, this.customer, this.date, this.amount, this.status);
  String number;
  String customer;
  String date;
  double amount;
  String status;
}

class TransactionRecord {
  TransactionRecord(
      this.description, this.account, this.date, this.amount, this.type);
  String description;
  String account;
  String date;
  double amount;
  String type;
}

class BillStore extends ChangeNotifier {
  final BillDatabase _database = BillDatabase();
  bool isLoading = false;
  bool isReady = false;
  final customers = <CustomerRecord>[
    CustomerRecord('Meera Enterprises', 'meera@example.com', 42800),
    CustomerRecord('Northstar Foods', 'accounts@northstar.in', 18450),
    CustomerRecord('Aarav Retail', 'aarav@example.com', 0),
    CustomerRecord('Bloom Studio', 'hello@bloom.studio', 27600),
  ];
  final products = <ProductRecord>[
    ProductRecord('Premium A4 Paper', 'PAP-001', 'Office', 248, 320),
    ProductRecord('Thermal Receipt Roll', 'ROL-014', 'Supplies', 42, 85),
    ProductRecord('Desk Organizer', 'ORG-220', 'Office', 18, 640),
    ProductRecord('Packing Tape', 'TAP-102', 'Packaging', 7, 120),
  ];
  final invoices = <InvoiceRecord>[
    InvoiceRecord(
        'INV-1042', 'Meera Enterprises', '25 Aug 2026', 42800, 'Paid'),
    InvoiceRecord(
        'INV-1041', 'Northstar Foods', '24 Aug 2026', 18450, 'Pending'),
    InvoiceRecord('INV-1040', 'Aarav Retail', '22 Aug 2026', 9200, 'Paid'),
    InvoiceRecord('INV-1039', 'Bloom Studio', '20 Aug 2026', 27600, 'Overdue'),
  ];
  final transactions = <TransactionRecord>[
    TransactionRecord('Payment from Meera Enterprises', 'HDFC current',
        '25 Aug 2026', 42800, 'Income'),
    TransactionRecord('Office supplies purchase', 'HDFC current', '24 Aug 2026',
        -6240, 'Expense'),
    TransactionRecord(
        'Cash sale', 'Cash on hand', '24 Aug 2026', 9200, 'Income'),
    TransactionRecord(
        'Courier charges', 'Cash on hand', '23 Aug 2026', -1850, 'Expense'),
  ];

  bool get _supportsSqlite =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> initialize() async {
    if (!_supportsSqlite || isLoading || isReady) return;
    isLoading = true;
    notifyListeners();
    try {
      final savedCustomers = await _database.read('customers');
      final savedProducts = await _database.read('products');
      final savedInvoices = await _database.read('invoices');
      final savedTransactions = await _database.read('transactions');
      if (savedCustomers.isNotEmpty) {
        customers
          ..clear()
          ..addAll(savedCustomers.map((row) => CustomerRecord(
              row['name']! as String,
              row['contact']! as String,
              (row['balance']! as num).toDouble())));
      }
      if (savedProducts.isNotEmpty) {
        products
          ..clear()
          ..addAll(savedProducts.map((row) => ProductRecord(
              row['name']! as String,
              row['sku']! as String,
              row['category']! as String,
              row['stock']! as int,
              (row['price']! as num).toDouble())));
      }
      if (savedInvoices.isNotEmpty) {
        invoices
          ..clear()
          ..addAll(savedInvoices.map((row) => InvoiceRecord(
              row['number']! as String,
              row['customer']! as String,
              row['date']! as String,
              (row['amount']! as num).toDouble(),
              row['status']! as String)));
      }
      if (savedTransactions.isNotEmpty) {
        transactions
          ..clear()
          ..addAll(savedTransactions.map((row) => TransactionRecord(
              row['description']! as String,
              row['account']! as String,
              row['date']! as String,
              (row['amount']! as num).toDouble(),
              row['type']! as String)));
      }
      if (savedCustomers.isEmpty &&
          savedProducts.isEmpty &&
          savedInvoices.isEmpty &&
          savedTransactions.isEmpty) {
        await _seedDatabase();
      }
      isReady = true;
    } catch (_) {
      // The in-memory records remain usable if the local database is unavailable.
      isReady = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _seedDatabase() async {
    for (final item in customers) {
      await _database.insert('customers', {
        'name': item.name,
        'contact': item.contact,
        'balance': item.balance
      });
    }
    for (final item in products) {
      await _database.insert('products', {
        'name': item.name,
        'sku': item.sku,
        'category': item.category,
        'stock': item.stock,
        'price': item.price
      });
    }
    for (final item in invoices) {
      await _database.insert('invoices', {
        'number': item.number,
        'customer': item.customer,
        'date': item.date,
        'amount': item.amount,
        'status': item.status
      });
    }
    for (final item in transactions) {
      await _database.insert('transactions', {
        'description': item.description,
        'account': item.account,
        'date': item.date,
        'amount': item.amount,
        'type': item.type
      });
    }
  }

  void addCustomer(CustomerRecord customer) {
    customers.insert(0, customer);
    if (_supportsSqlite) {
      _database.insert('customers', {
        'name': customer.name,
        'contact': customer.contact,
        'balance': customer.balance
      });
    }
    notifyListeners();
  }

  void addProduct(ProductRecord product) {
    products.insert(0, product);
    if (_supportsSqlite) {
      _database.insert('products', {
        'name': product.name,
        'sku': product.sku,
        'category': product.category,
        'stock': product.stock,
        'price': product.price
      });
    }
    notifyListeners();
  }

  void addInvoice(InvoiceRecord invoice) {
    invoices.insert(0, invoice);
    if (_supportsSqlite) {
      _database.insert('invoices', {
        'number': invoice.number,
        'customer': invoice.customer,
        'date': invoice.date,
        'amount': invoice.amount,
        'status': invoice.status
      });
    }
    notifyListeners();
  }

  void addTransaction(TransactionRecord transaction) {
    transactions.insert(0, transaction);
    if (_supportsSqlite) {
      _database.insert('transactions', {
        'description': transaction.description,
        'account': transaction.account,
        'date': transaction.date,
        'amount': transaction.amount,
        'type': transaction.type
      });
    }
    notifyListeners();
  }
}

final billStore = BillStore();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  billStore.initialize();
  runApp(const BillApp());
}

class BillApp extends StatelessWidget {
  const BillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PricePilot Bill',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8FAFC),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: AnimatedBuilder(
        animation: billStore,
        builder: (context, child) => child!,
        child: const WorkspaceShell(),
      ),
    );
  }
}

class WorkspaceShell extends StatefulWidget {
  const WorkspaceShell({super.key});

  @override
  State<WorkspaceShell> createState() => _WorkspaceShellState();
}

class _WorkspaceShellState extends State<WorkspaceShell> {
  int selectedIndex = 0;
  bool isSearchOpen = false;

  static const destinations = [
    (Icons.grid_view_rounded, 'Overview'),
    (Icons.receipt_long_rounded, 'Invoices'),
    (Icons.inventory_2_outlined, 'Inventory'),
    (Icons.people_alt_outlined, 'Customers'),
    (Icons.account_balance_wallet_outlined, 'Cash & bank'),
    (Icons.local_shipping_outlined, 'Purchases'),
    (Icons.payments_outlined, 'Income & expenses'),
    (Icons.bar_chart_rounded, 'Reports'),
    (Icons.settings_outlined, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        automaticallyImplyLeading: false,
        titleSpacing: wide ? 28 : 16,
        title: Row(
          children: [
            if (!wide) ...[
              IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu_rounded),
              ),
              const SizedBox(width: 4),
            ],
            const BrandMark(),
            if (wide) const SizedBox(width: 46),
            if (wide)
              Text('Tuesday, 25 August 2026',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          ],
        ),
        actions: [
          if (isSearchOpen)
            SizedBox(
              width: 210,
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                    hintText: 'Search workspace', border: InputBorder.none),
                onSubmitted: (_) => setState(() => isSearchOpen = false),
              ),
            ),
          IconButton(
            tooltip: 'Search',
            onPressed: () => setState(() => isSearchOpen = !isSearchOpen),
            icon:
                Icon(isSearchOpen ? Icons.close_rounded : Icons.search_rounded),
          ),
          IconButton(
              tooltip: 'Notifications',
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded)),
          const SizedBox(width: 8),
          const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFDCEAFE),
              child: Text('AK',
                  style: TextStyle(
                      color: Color(0xFF1D4ED8),
                      fontSize: 12,
                      fontWeight: FontWeight.w700))),
          const SizedBox(width: 24),
        ],
      ),
      drawer: wide
          ? null
          : NavigationDrawer(
              selectedIndex: selectedIndex,
              onDestinationSelected: _select,
              children: [
                  const Padding(
                      padding: EdgeInsets.fromLTRB(28, 18, 16, 8),
                      child: BrandMark()),
                  ...destinations.map((item) => NavigationDrawerDestination(
                      icon: Icon(item.$1), label: Text(item.$2)))
                ]),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (wide)
            _SideNavigation(selectedIndex: selectedIndex, onSelect: _select),
          Expanded(child: _pageForIndex()),
        ],
      ),
    );
  }

  void _select(int value) {
    setState(() => selectedIndex = value);
    if (MediaQuery.sizeOf(context).width < 980) Navigator.pop(context);
  }

  Widget _pageForIndex() {
    if (selectedIndex == 0) return const DashboardPage();
    switch (selectedIndex) {
      case 1:
        return const InvoicesPage();
      case 2:
        return const InventoryPage();
      case 3:
        return const CustomersPage();
      case 4:
        return const CashBankPage();
      case 5:
        return const PurchasesPage();
      case 6:
        return const ExpenseIncomePage();
      case 7:
        return const ReportsPage();
      default:
        return const SettingsPage();
    }
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.receipt_long_rounded,
                color: Colors.white, size: 19)),
        const SizedBox(width: 10),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PricePilot Bill',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  letterSpacing: -0.2)),
          Text('Modern Retail Store',
              style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.w500))
        ])
      ]);
}

class _SideNavigation extends StatelessWidget {
  const _SideNavigation({required this.selectedIndex, required this.onSelect});
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  @override
  Widget build(BuildContext context) => Container(
      width: 238,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(right: BorderSide(color: Color(0xFFE2E8F0)))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Padding(
            padding: EdgeInsets.fromLTRB(14, 4, 14, 24),
            child: Text('WORKSPACE',
                style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF94A3B8)))),
        ...WorkspaceShellState_destinations(
            onSelect: onSelect, selectedIndex: selectedIndex),
        const Spacer(),
        Material(
            color: Colors.transparent,
            child: ListTile(
                leading: const Icon(Icons.settings_outlined, size: 20),
                title: const Text('Settings',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                onTap: () {})),
        Material(
            color: Colors.transparent,
            child: ListTile(
                leading: const Icon(Icons.help_outline_rounded, size: 20),
                title: const Text('Help centre',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                onTap: () {}))
      ]));
}

List<Widget> WorkspaceShellState_destinations(
    {required ValueChanged<int> onSelect, required int selectedIndex}) {
  const items = [
    (Icons.grid_view_rounded, 'Overview'),
    (Icons.receipt_long_rounded, 'Invoices'),
    (Icons.inventory_2_outlined, 'Inventory'),
    (Icons.people_alt_outlined, 'Customers'),
    (Icons.account_balance_wallet_outlined, 'Cash & bank'),
    (Icons.local_shipping_outlined, 'Purchases'),
    (Icons.payments_outlined, 'Income & expenses'),
    (Icons.bar_chart_rounded, 'Reports'),
    (Icons.settings_outlined, 'Settings')
  ];
  return items.indexed
      .map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                selected: selectedIndex == entry.$1,
                selectedTileColor: const Color(0xFFEFF6FF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9)),
                leading: Icon(entry.$2.$1,
                    size: 20,
                    color: selectedIndex == entry.$1
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF64748B)),
                title: Text(entry.$2.$2,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: selectedIndex == entry.$1
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selectedIndex == entry.$1
                            ? const Color(0xFF1D4ED8)
                            : const Color(0xFF475569))),
                onTap: () => onSelect(entry.$1),
              ),
            ),
          ))
      .toList();
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 720;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(narrow ? 18 : 38, 26, narrow ? 18 : 38, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good morning, Anika',
                        style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.7)),
                    SizedBox(height: 6),
                    Text('Here is what is happening with your business today.',
                        style:
                            TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                  ],
                ),
              ),
              if (!narrow)
                FilledButton.icon(
                  onPressed: () => showDialog<void>(
                      context: context, builder: (_) => const InvoiceDialog()),
                  icon: const Icon(Icons.add_rounded, size: 19),
                  label: const Text('Create invoice'),
                ),
            ],
          ),
          if (narrow)
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => showDialog<void>(
                      context: context, builder: (_) => const InvoiceDialog()),
                  icon: const Icon(Icons.add_rounded, size: 19),
                  label: const Text('Create invoice'),
                ),
              ),
            ),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 650 ? 2 : 4;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.8,
                children: const [
                  MetricCard(
                      label: 'Total sales',
                      value: '₹8,42,560',
                      change: '+12.8%',
                      icon: Icons.trending_up_rounded,
                      color: Color(0xFF0F766E)),
                  MetricCard(
                      label: 'Outstanding',
                      value: '₹1,26,430',
                      change: '18 invoices',
                      icon: Icons.schedule_rounded,
                      color: Color(0xFFD97706)),
                  MetricCard(
                      label: 'Expenses',
                      value: '₹3,18,240',
                      change: '-4.2%',
                      icon: Icons.arrow_downward_rounded,
                      color: Color(0xFFDC2626)),
                  MetricCard(
                      label: 'Net profit',
                      value: '₹5,24,320',
                      change: '+16.4%',
                      icon: Icons.savings_outlined,
                      color: Color(0xFF2563EB)),
                ],
              );
            },
          ),
          const SizedBox(height: 26),
          if (narrow) ...[
            const SalesChart(),
            const SizedBox(height: 18),
            const RecentInvoices(),
          ] else
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: SalesChart()),
                SizedBox(width: 18),
                Expanded(flex: 5, child: RecentInvoices()),
              ],
            ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard(
      {super.key,
      required this.label,
      required this.value,
      required this.change,
      required this.icon,
      required this.color});
  final String label, value, change;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(children: [
              Flexible(
                  child: Text(label,
                      style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w600))),
              const SizedBox(width: 6),
              Icon(icon, color: color, size: 19)
            ]),
            const SizedBox(height: 7),
            FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.4))),
            const SizedBox(height: 4),
            Text(change,
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.w700))
          ]));
}

class SalesChart extends StatelessWidget {
  const SalesChart({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 310,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sales overview',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('Revenue performance this month',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: 'Last 30 days',
                underline: const SizedBox(),
                items: ['Last 30 days', 'Last 90 days']
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (_) {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
              child: CustomPaint(
                  painter: SalesPainter(), child: const SizedBox.expand())),
        ],
      ),
    );
  }
}

class SalesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFFEFF3F8)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = i * size.height / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final points = [
      0.03,
      .18,
      .14,
      .32,
      .29,
      .54,
      .48,
      .63,
      .52,
      .72,
      .68,
      .94
    ];
    final line = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final point = Offset(
          i * size.width / (points.length - 1), size.height * (1 - points[i]));
      if (i == 0)
        path.moveTo(point.dx, point.dy);
      else
        path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, line);
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
        fillPath,
        Paint()
          ..shader = const LinearGradient(
                  colors: [Color(0x332563EB), Color(0x002563EB)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)
              .createShader(Offset.zero & size));
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(
          Offset(i * size.width / (points.length - 1),
              size.height * (1 - points[i])),
          4,
          Paint()..color = Colors.white);
      canvas.drawCircle(
          Offset(i * size.width / (points.length - 1),
              size.height * (1 - points[i])),
          2.5,
          Paint()..color = const Color(0xFF2563EB));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RecentInvoices extends StatelessWidget {
  const RecentInvoices({super.key});
  @override
  Widget build(BuildContext context) => Container(
      height: 310,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Row(children: [
          const Expanded(
              child: Text('Recent invoices',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
          TextButton(onPressed: () {}, child: const Text('View all'))
        ]),
        const SizedBox(height: 4),
        Expanded(
            child: ListView(
                children: [
          ('INV-1042', 'Meera Enterprises', '₹42,800', 'Paid'),
          ('INV-1041', 'Northstar Foods', '₹18,450', 'Pending'),
          ('INV-1040', 'Aarav Retail', '₹9,200', 'Paid'),
          ('INV-1039', 'Bloom Studio', '₹27,600', 'Overdue')
        ]
                    .map((invoice) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(children: [
                          Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.receipt_outlined,
                                  size: 17, color: Color(0xFF64748B))),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(invoice.$1,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(invoice.$2,
                                    style: const TextStyle(
                                        fontSize: 11, color: Color(0xFF94A3B8)))
                              ])),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(invoice.$3,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                StatusPill(status: invoice.$4)
                              ])
                        ])))
                    .toList()))
      ]));
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final color = status == 'Paid'
        ? const Color(0xFF15803D)
        : status == 'Overdue'
            ? const Color(0xFFDC2626)
            : const Color(0xFFD97706);
    return Text(status,
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700));
  }
}

class InvoicesPage extends StatelessWidget {
  const InvoicesPage({super.key});

  @override
  Widget build(BuildContext context) => ModulePage(
        title: 'Invoices',
        subtitle: 'Create, send, and track every customer invoice.',
        actionLabel: 'New invoice',
        actionIcon: Icons.add_rounded,
        onAction: () => showDialog<void>(
            context: context, builder: (_) => const InvoiceDialog()),
        child: DataPanel(
          headers: const ['Invoice', 'Customer', 'Date', 'Amount', 'Status'],
          rows: billStore.invoices
              .map((row) => [
                    row.number,
                    row.customer,
                    row.date,
                    _money(row.amount),
                    row.status
                  ])
              .toList(),
        ),
      );
}

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});
  @override
  Widget build(BuildContext context) => ModulePage(
        title: 'Inventory',
        subtitle: 'Keep stock levels and product pricing under control.',
        actionLabel: 'Add product',
        actionIcon: Icons.add_rounded,
        onAction: () => showDialog<void>(
            context: context, builder: (_) => const ProductDialog()),
        child: DataPanel(
            lastColumnIsStatus: false,
            headers: const ['Product', 'SKU', 'Category', 'Stock', 'Price'],
            rows: billStore.products
                .map((product) => [
                      product.name,
                      product.sku,
                      product.category,
                      '${product.stock} units',
                      _money(product.price)
                    ])
                .toList()),
      );
}

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});
  @override
  Widget build(BuildContext context) => ModulePage(
        title: 'Customers',
        subtitle: 'One clear view of your customer relationships and balances.',
        actionLabel: 'Add customer',
        actionIcon: Icons.person_add_alt_1_rounded,
        onAction: () => showDialog<void>(
            context: context, builder: (_) => const CustomerDialog()),
        child: DataPanel(
            headers: const [
              'Customer',
              'Contact',
              'Invoices',
              'Balance',
              'Status'
            ],
            rows: billStore.customers
                .map((customer) => [
                      customer.name,
                      customer.contact,
                      '0',
                      _money(customer.balance),
                      customer.balance > 0 ? 'Active' : 'Clear'
                    ])
                .toList()),
      );
}

class CashBankPage extends StatelessWidget {
  const CashBankPage({super.key});
  @override
  Widget build(BuildContext context) => ModulePage(
        title: 'Cash & bank',
        subtitle: 'Track money in, money out, and your current position.',
        actionLabel: 'Record transaction',
        actionIcon: Icons.add_rounded,
        onAction: () => showDialog<void>(
            context: context, builder: (_) => const TransactionDialog()),
        child: DataPanel(
            headers: const ['Description', 'Account', 'Date', 'Amount', 'Type'],
            rows: billStore.transactions
                .map((transaction) => [
                      transaction.description,
                      transaction.account,
                      transaction.date,
                      '${transaction.amount >= 0 ? '+' : '-'}${_money(transaction.amount.abs())}',
                      transaction.type
                    ])
                .toList()),
      );
}

class PurchasesPage extends StatelessWidget {
  const PurchasesPage({super.key});
  @override
  Widget build(BuildContext context) => ModulePage(
        title: 'Purchases & suppliers',
        subtitle: 'Track supplier bills and stock purchased for the business.',
        actionLabel: 'Record purchase',
        actionIcon: Icons.add_rounded,
        onAction: () => showDialog<void>(
            context: context,
            builder: (_) => const TransactionDialog(expense: true)),
        child: DataPanel(headers: const [
          'Supplier',
          'Account',
          'Date',
          'Amount',
          'Type'
        ], rows: const [
          [
            'Paper House',
            'HDFC current',
            '22 Aug 2026',
            '-₹12,400',
            'Purchase'
          ],
          [
            'PackRight Supplies',
            'HDFC current',
            '19 Aug 2026',
            '-₹8,650',
            'Purchase'
          ],
        ]),
      );
}

class ExpenseIncomePage extends StatelessWidget {
  const ExpenseIncomePage({super.key});
  @override
  Widget build(BuildContext context) => ModulePage(
        title: 'Income & expenses',
        subtitle:
            'Record operating activity and keep your profit view current.',
        actionLabel: 'Add entry',
        actionIcon: Icons.add_rounded,
        onAction: () => showDialog<void>(
            context: context, builder: (_) => const TransactionDialog()),
        child: DataPanel(
            headers: const ['Description', 'Account', 'Date', 'Amount', 'Type'],
            rows: billStore.transactions
                .map((item) => [
                      item.description,
                      item.account,
                      item.date,
                      '${item.amount >= 0 ? '+' : '-'}${_money(item.amount.abs())}',
                      item.type
                    ])
                .toList()),
      );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) => ModulePage(
        title: 'Settings & sync',
        subtitle:
            'Configure your store profile, tax defaults, and data safety.',
        child: Column(children: [
          _SettingTile(
              icon: Icons.storefront_outlined,
              title: 'Store profile',
              detail: 'Modern Retail Store',
              onTap: () =>
                  _showMessage(context, 'Store profile is ready to edit.')),
          _SettingTile(
              icon: Icons.percent_rounded,
              title: 'GST and invoice defaults',
              detail: 'Tax registration, invoice numbering, and payment terms',
              onTap: () => _showMessage(context, 'Invoice defaults opened.')),
          _SettingTile(
              icon: Icons.sync_rounded,
              title: 'Data sync',
              detail: 'Local workspace is up to date',
              onTap: () =>
                  _showMessage(context, 'Sync completed successfully.')),
          _SettingTile(
              icon: Icons.help_outline_rounded,
              title: 'Help centre',
              detail: 'Guides and support for your billing workspace',
              onTap: () => _showMessage(context, 'Help centre opened.')),
        ]),
      );
}

class _SettingTile extends StatelessWidget {
  const _SettingTile(
      {required this.icon,
      required this.title,
      required this.detail,
      required this.onTap});
  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
            leading: Icon(icon, color: const Color(0xFF2563EB)),
            title: Text(title),
            subtitle: Text(detail),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: onTap),
      );
}

String _money(double value) => '₹${value.toStringAsFixed(0)}';

class CustomerDialog extends StatefulWidget {
  const CustomerDialog({super.key});
  @override
  State<CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends State<CustomerDialog> {
  final name = TextEditingController();
  final contact = TextEditingController();
  @override
  void dispose() {
    name.dispose();
    contact.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
          title: const Text('Add customer'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Name')),
            TextField(
                controller: contact,
                decoration: const InputDecoration(labelText: 'Email or phone'))
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () {
                  if (name.text.trim().isEmpty) return;
                  billStore.addCustomer(
                      CustomerRecord(name.text.trim(), contact.text.trim(), 0));
                  Navigator.pop(context);
                },
                child: const Text('Add customer'))
          ]);
}

class ProductDialog extends StatefulWidget {
  const ProductDialog({super.key});
  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  final name = TextEditingController();
  final sku = TextEditingController();
  final category = TextEditingController();
  final stock = TextEditingController();
  final price = TextEditingController();
  @override
  void dispose() {
    for (final controller in [name, sku, category, stock, price]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
          title: const Text('Add product'),
          content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Product name')),
            TextField(
                controller: sku,
                decoration: const InputDecoration(labelText: 'SKU')),
            TextField(
                controller: category,
                decoration: const InputDecoration(labelText: 'Category')),
            TextField(
                controller: stock,
                decoration: const InputDecoration(labelText: 'Opening stock'),
                keyboardType: TextInputType.number),
            TextField(
                controller: price,
                decoration:
                    const InputDecoration(labelText: 'Price', prefixText: '₹ '),
                keyboardType: TextInputType.number)
          ])),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () {
                  final quantity = int.tryParse(stock.text);
                  final amount = double.tryParse(price.text);
                  if (name.text.trim().isEmpty ||
                      quantity == null ||
                      amount == null) return;
                  billStore.addProduct(ProductRecord(name.text.trim(),
                      sku.text.trim(), category.text.trim(), quantity, amount));
                  Navigator.pop(context);
                },
                child: const Text('Add product'))
          ]);
}

class TransactionDialog extends StatefulWidget {
  const TransactionDialog({super.key, this.expense = false});
  final bool expense;
  @override
  State<TransactionDialog> createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<TransactionDialog> {
  final description = TextEditingController();
  final amount = TextEditingController();
  final account = TextEditingController(text: 'HDFC current');
  late bool isExpense = widget.expense;
  @override
  void dispose() {
    description.dispose();
    amount.dispose();
    account.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
          title:
              Text(widget.expense ? 'Record purchase' : 'Record transaction'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
                controller: description,
                decoration: const InputDecoration(labelText: 'Description')),
            TextField(
                controller: account,
                decoration: const InputDecoration(labelText: 'Account')),
            TextField(
                controller: amount,
                decoration: const InputDecoration(
                    labelText: 'Amount', prefixText: '₹ '),
                keyboardType: TextInputType.number),
            SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Expense'),
                value: isExpense,
                onChanged: (value) => setState(() => isExpense = value))
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () {
                  final value = double.tryParse(amount.text);
                  if (description.text.trim().isEmpty || value == null) return;
                  final signed = isExpense ? -value : value;
                  billStore.addTransaction(TransactionRecord(
                      description.text.trim(),
                      account.text.trim(),
                      '27 Aug 2026',
                      signed,
                      isExpense ? 'Expense' : 'Income'));
                  Navigator.pop(context);
                },
                child: const Text('Save entry'))
          ]);
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});
  @override
  Widget build(BuildContext context) => ModulePage(
        title: 'Reports',
        subtitle: 'Understand performance with reports made for decisions.',
        child: LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth < 700 ? 1 : 2;
          return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: columns == 1 ? 3.4 : 1.8,
              children: const [
                ReportCard(
                    icon: Icons.receipt_long_rounded,
                    title: 'Sales report',
                    detail: 'Revenue by customer and period'),
                ReportCard(
                    icon: Icons.account_balance_rounded,
                    title: 'GST summary',
                    detail: 'Tax collected and payable'),
                ReportCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Stock report',
                    detail: 'Low stock and valuation'),
                ReportCard(
                    icon: Icons.payments_outlined,
                    title: 'Profit & loss',
                    detail: 'Income, expenses, and margin'),
              ]);
        }),
      );
}

class ModulePage extends StatelessWidget {
  const ModulePage(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.child,
      this.actionLabel,
      this.actionIcon,
      this.onAction});
  final String title, subtitle;
  final Widget child;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 650;
    return SingleChildScrollView(
        padding:
            EdgeInsets.fromLTRB(narrow ? 18 : 38, 30, narrow ? 18 : 38, 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 14))
                ])),
            if (!narrow && actionLabel != null)
              FilledButton.icon(
                  onPressed: onAction,
                  icon: Icon(actionIcon),
                  label: Text(actionLabel!),
                  style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14)))
          ]),
          if (narrow && actionLabel != null)
            Padding(
                padding: const EdgeInsets.only(top: 18),
                child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                        onPressed: onAction,
                        icon: Icon(actionIcon),
                        label: Text(actionLabel!),
                        style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14))))),
          const SizedBox(height: 26),
          child,
        ]));
  }
}

class DataPanel extends StatelessWidget {
  const DataPanel(
      {super.key,
      required this.headers,
      required this.rows,
      this.lastColumnIsStatus = true});
  final List<String> headers;
  final List<List<String>> rows;
  final bool lastColumnIsStatus;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 34,
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
          columns: headers
              .map((header) => DataColumn(
                  label: Text(header,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B)))))
              .toList(),
          rows: rows
              .map((row) => DataRow(
                  cells: row.indexed
                      .map((entry) => DataCell(
                          lastColumnIsStatus && entry.$1 == row.length - 1
                              ? StatusPill(status: entry.$2)
                              : Text(entry.$2,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600))))
                      .toList()))
              .toList(),
        ),
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  const ReportCard(
      {super.key,
      required this.icon,
      required this.title,
      required this.detail});
  final IconData icon;
  final String title, detail;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: () => _showMessage(context, '$title opened.'),
      borderRadius: BorderRadius.circular(10),
      child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(9)),
                child: Icon(icon, color: const Color(0xFF2563EB))),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 5),
                  Text(detail,
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 12))
                ])),
            const Icon(Icons.arrow_forward_rounded, color: Color(0xFF94A3B8))
          ])));
}

class InvoiceDialog extends StatefulWidget {
  const InvoiceDialog({super.key});
  @override
  State<InvoiceDialog> createState() => _InvoiceDialogState();
}

class _InvoiceDialogState extends State<InvoiceDialog> {
  final amount = TextEditingController();
  final notes = TextEditingController();
  String? customer;
  String status = 'Draft';

  @override
  void dispose() {
    amount.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Create invoice'),
        content: SizedBox(
          width: 420,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(
              initialValue: customer,
              decoration: const InputDecoration(labelText: 'Customer'),
              items: billStore.customers
                  .map((item) => DropdownMenuItem(
                      value: item.name, child: Text(item.name)))
                  .toList(),
              onChanged: (value) => setState(() => customer = value),
            ),
            const SizedBox(height: 14),
            TextField(
                controller: amount,
                decoration: const InputDecoration(
                    labelText: 'Amount', prefixText: '₹ '),
                keyboardType: TextInputType.number),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: status,
              decoration: const InputDecoration(labelText: 'Payment status'),
              items: ['Draft', 'Pending', 'Paid']
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) => setState(() => status = value ?? 'Draft'),
            ),
            const SizedBox(height: 14),
            TextField(
                controller: notes,
                decoration: const InputDecoration(
                    labelText: 'Notes', hintText: 'Optional payment note')),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () {
                final value = double.tryParse(amount.text);
                if (customer == null || value == null || value <= 0) return;
                final nextNumber = 'INV-${1043 + billStore.invoices.length}';
                billStore.addInvoice(InvoiceRecord(
                    nextNumber, customer!, '27 Aug 2026', value, status));
                Navigator.pop(context);
              },
              child: const Text('Save invoice')),
        ],
      );
}

void _showMessage(BuildContext context, String message) =>
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
