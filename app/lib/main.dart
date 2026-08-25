import 'package:flutter/material.dart';

void main() {
  runApp(const BillApp());
}

class BillApp extends StatelessWidget {
  const BillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bill-app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        fontFamily: 'Arial',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8FAFC),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const WorkspaceShell(),
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
    (Icons.bar_chart_rounded, 'Reports'),
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
            if (wide) Text('Tuesday, 25 August 2026', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          ],
        ),
        actions: [
          if (isSearchOpen)
            SizedBox(
              width: 210,
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Search workspace', border: InputBorder.none),
                onSubmitted: (_) => setState(() => isSearchOpen = false),
              ),
            ),
          IconButton(
            tooltip: 'Search',
            onPressed: () => setState(() => isSearchOpen = !isSearchOpen),
            icon: Icon(isSearchOpen ? Icons.close_rounded : Icons.search_rounded),
          ),
          IconButton(tooltip: 'Notifications', onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
          const SizedBox(width: 8),
          const CircleAvatar(radius: 18, backgroundColor: Color(0xFFDCEAFE), child: Text('AK', style: TextStyle(color: Color(0xFF1D4ED8), fontSize: 12, fontWeight: FontWeight.w700))),
          const SizedBox(width: 24),
        ],
      ),
      drawer: wide ? null : NavigationDrawer(selectedIndex: selectedIndex, onDestinationSelected: _select, children: [const Padding(padding: EdgeInsets.fromLTRB(28, 18, 16, 8), child: BrandMark()), ...destinations.map((item) => NavigationDrawerDestination(icon: Icon(item.$1), label: Text(item.$2)))]),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (wide) _SideNavigation(selectedIndex: selectedIndex, onSelect: _select),
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
      default:
        return const ReportsPage();
    }
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(9)), child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 19)), const SizedBox(width: 10), const Text('bill-app', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19, letterSpacing: -0.4))]);
}

class _SideNavigation extends StatelessWidget {
  const _SideNavigation({required this.selectedIndex, required this.onSelect});
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  @override
  Widget build(BuildContext context) => Container(width: 238, padding: const EdgeInsets.fromLTRB(14, 12, 14, 20), decoration: const BoxDecoration(color: Colors.white, border: Border(right: BorderSide(color: Color(0xFFE2E8F0)))), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Padding(padding: EdgeInsets.fromLTRB(14, 4, 14, 24), child: Text('WORKSPACE', style: TextStyle(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))), ...WorkspaceShellState_destinations(onSelect: onSelect, selectedIndex: selectedIndex), const Spacer(), ListTile(leading: const Icon(Icons.settings_outlined, size: 20), title: const Text('Settings', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), onTap: () {}), ListTile(leading: const Icon(Icons.help_outline_rounded, size: 20), title: const Text('Help centre', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), onTap: () {})]));
}

List<Widget> WorkspaceShellState_destinations({required ValueChanged<int> onSelect, required int selectedIndex}) {
  const items = [(Icons.grid_view_rounded, 'Overview'), (Icons.receipt_long_rounded, 'Invoices'), (Icons.inventory_2_outlined, 'Inventory'), (Icons.people_alt_outlined, 'Customers'), (Icons.account_balance_wallet_outlined, 'Cash & bank'), (Icons.bar_chart_rounded, 'Reports')];
  return items.indexed.map((entry) => Padding(padding: const EdgeInsets.only(bottom: 4), child: ListTile(selected: selectedIndex == entry.$1, selectedTileColor: const Color(0xFFEFF6FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)), leading: Icon(entry.$2.$1, size: 20, color: selectedIndex == entry.$1 ? const Color(0xFF2563EB) : const Color(0xFF64748B)), title: Text(entry.$2.$2, style: TextStyle(fontSize: 13, fontWeight: selectedIndex == entry.$1 ? FontWeight.w700 : FontWeight.w500, color: selectedIndex == entry.$1 ? const Color(0xFF1D4ED8) : const Color(0xFF475569))), onTap: () => onSelect(entry.$1)))).toList();
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 720;
    return SingleChildScrollView(padding: EdgeInsets.fromLTRB(narrow ? 18 : 38, 26, narrow ? 18 : 38, 40), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Good morning, Anika', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.7)), SizedBox(height: 6), Text('Here is what is happening with your business today.', style: TextStyle(color: Color(0xFF64748B), fontSize: 14))]), if (!narrow) FilledButton.icon(onPressed: () => showDialog<void>(context: context, builder: (_) => const InvoiceDialog()), icon: const Icon(Icons.add_rounded, size: 19), label: const Text('Create invoice'), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))]),
      if (narrow) Padding(padding: const EdgeInsets.only(top: 18), child: SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => showDialog<void>(context: context, builder: (_) => const InvoiceDialog()), icon: const Icon(Icons.add_rounded, size: 19), label: const Text('Create invoice'), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
      const SizedBox(height: 28),
      LayoutBuilder(builder: (context, constraints) { final columns = constraints.maxWidth < 650 ? 2 : 4; return GridView.count(crossAxisCount: columns, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: narrow ? 1.45 : 1.75, children: const [MetricCard(label: 'Total sales', value: '₹8,42,560', change: '+12.8%', icon: Icons.trending_up_rounded, color: Color(0xFF0F766E)), MetricCard(label: 'Outstanding', value: '₹1,26,430', change: '18 invoices', icon: Icons.schedule_rounded, color: Color(0xFFD97706)), MetricCard(label: 'Expenses', value: '₹3,18,240', change: '-4.2%', icon: Icons.arrow_downward_rounded, color: Color(0xFFDC2626)), MetricCard(label: 'Net profit', value: '₹5,24,320', change: '+16.4%', icon: Icons.savings_outlined, color: Color(0xFF2563EB))]; }),
      const SizedBox(height: 26),
      if (narrow) ...[const SalesChart(), const SizedBox(height: 18), const RecentInvoices()] else Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Expanded(flex: 6, child: SalesChart()), const SizedBox(width: 18), const Expanded(flex: 5, child: RecentInvoices())]),
    ]));
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.label, required this.value, required this.change, required this.icon, required this.color});
  final String label, value, change; final IconData icon; final Color color;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Flexible(child: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600))), Icon(icon, color: color, size: 19)]), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.4)), Text(change, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700))]));
}

class SalesChart extends StatelessWidget {
  const SalesChart({super.key});
  @override
  Widget build(BuildContext context) => Container(height: 310, padding: const EdgeInsets.fromLTRB(22, 20, 22, 16), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(10)), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Sales overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)), SizedBox(height: 4), Text('Revenue performance this month', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))]), DropdownButton<String>(value: 'Last 30 days', underline: const SizedBox(), style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w600), items: ['Last 30 days', 'Last 90 days'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (_) {})]), const SizedBox(height: 16), Expanded(child: CustomPaint(painter: SalesPainter(), child: const SizedBox.expand()))]));
}

class SalesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) { final grid = Paint()..color = const Color(0xFFEFF3F8)..strokeWidth = 1; for (var i = 0; i < 4; i++) { final y = i * size.height / 3; canvas.drawLine(0, y, size.width, y, grid); } final points = [0.03, .18, .14, .32, .29, .54, .48, .63, .52, .72, .68, .94]; final line = Paint()..color = const Color(0xFF2563EB)..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round; final path = Path(); for (var i = 0; i < points.length; i++) { final point = Offset(i * size.width / (points.length - 1), size.height * (1 - points[i])); if (i == 0) path.moveTo(point.dx, point.dy); else path.lineTo(point.dx, point.dy); } canvas.drawPath(path, line); final fillPath = Path.from(path)..lineTo(size.width, size.height)..lineTo(0, size.height)..close(); canvas.drawPath(fillPath, Paint()..shader = const LinearGradient(colors: [Color(0x332563EB), Color(0x002563EB)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(Offset.zero & size)); for (var i = 0; i < points.length; i++) { canvas.drawCircle(Offset(i * size.width / (points.length - 1), size.height * (1 - points[i])), 4, Paint()..color = Colors.white); canvas.drawCircle(Offset(i * size.width / (points.length - 1), size.height * (1 - points[i])), 2.5, Paint()..color = const Color(0xFF2563EB)); } }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RecentInvoices extends StatelessWidget {
  const RecentInvoices({super.key});
  @override
  Widget build(BuildContext context) => Container(height: 310, padding: const EdgeInsets.fromLTRB(20, 20, 20, 10), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(10)), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Recent invoices', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)), TextButton(onPressed: () {}, child: const Text('View all'))]), const SizedBox(height: 4), ...[('INV-1042', 'Meera Enterprises', '₹42,800', 'Paid'), ('INV-1041', 'Northstar Foods', '₹18,450', 'Pending'), ('INV-1040', 'Aarav Retail', '₹9,200', 'Paid'), ('INV-1039', 'Bloom Studio', '₹27,600', 'Overdue')].map((invoice) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Container(width: 34, height: 34, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.receipt_outlined, size: 17, color: Color(0xFF64748B))), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(invoice.$1, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)), const SizedBox(height: 2), Text(invoice.$2, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)))])), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(invoice.$3, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)), const SizedBox(height: 2), StatusPill(status: invoice.$4)])])))]));
}

class StatusPill extends StatelessWidget { const StatusPill({super.key, required this.status}); final String status; @override Widget build(BuildContext context) { final color = status == 'Paid' ? const Color(0xFF15803D) : status == 'Overdue' ? const Color(0xFFDC2626) : const Color(0xFFD97706); return Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)); } }

class InvoicesPage extends StatelessWidget {
  const InvoicesPage({super.key});

  static const rows = [
    ('INV-1042', 'Meera Enterprises', '25 Aug 2026', '₹42,800', 'Paid'),
    ('INV-1041', 'Northstar Foods', '24 Aug 2026', '₹18,450', 'Pending'),
    ('INV-1040', 'Aarav Retail', '22 Aug 2026', '₹9,200', 'Paid'),
    ('INV-1039', 'Bloom Studio', '20 Aug 2026', '₹27,600', 'Overdue'),
    ('INV-1038', 'Kaveri Homeware', '18 Aug 2026', '₹12,900', 'Paid'),
  ];

  @override
  Widget build(BuildContext context) => ModulePage(
        title: 'Invoices',
        subtitle: 'Create, send, and track every customer invoice.',
        actionLabel: 'New invoice',
        actionIcon: Icons.add_rounded,
        onAction: () => showDialog<void>(context: context, builder: (_) => const InvoiceDialog()),
        child: DataPanel(
          headers: const ['Invoice', 'Customer', 'Date', 'Amount', 'Status'],
          rows: rows.map((row) => [row.$1, row.$2, row.$3, row.$4, row.$5]).toList(),
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
        onAction: () => _showMessage(context, 'Product form is ready for your next item.'),
        child: const DataPanel(lastColumnIsStatus: false, headers: ['Product', 'SKU', 'Category', 'Stock', 'Price'], rows: [
          ['Premium A4 Paper', 'PAP-001', 'Office', '248 units', '₹320'],
          ['Thermal Receipt Roll', 'ROL-014', 'Supplies', '42 units', '₹85'],
          ['Desk Organizer', 'ORG-220', 'Office', '18 units', '₹640'],
          ['Packing Tape', 'TAP-102', 'Packaging', '7 units', '₹120'],
        ]),
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
        onAction: () => _showMessage(context, 'Customer form is ready for a new contact.'),
        child: const DataPanel(headers: ['Customer', 'Contact', 'Invoices', 'Balance', 'Status'], rows: [
          ['Meera Enterprises', 'meera@example.com', '12', '₹42,800', 'Active'],
          ['Northstar Foods', 'accounts@northstar.in', '8', '₹18,450', 'Active'],
          ['Aarav Retail', 'aarav@example.com', '5', '₹0', 'Active'],
          ['Bloom Studio', 'hello@bloom.studio', '3', '₹27,600', 'Follow up'],
        ]),
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
        onAction: () => _showMessage(context, 'Transaction form is ready to use.'),
        child: const DataPanel(headers: ['Description', 'Account', 'Date', 'Amount', 'Type'], rows: [
          ['Payment from Meera Enterprises', 'HDFC current', '25 Aug 2026', '+₹42,800', 'Income'],
          ['Office supplies purchase', 'HDFC current', '24 Aug 2026', '-₹6,240', 'Expense'],
          ['Cash sale', 'Cash on hand', '24 Aug 2026', '+₹9,200', 'Income'],
          ['Courier charges', 'Cash on hand', '23 Aug 2026', '-₹1,850', 'Expense'],
        ]),
      );
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});
  @override
  Widget build(BuildContext context) => ModulePage(
        title: 'Reports',
        subtitle: 'Understand performance with reports made for decisions.',
        child: LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth < 700 ? 1 : 2;
          return GridView.count(crossAxisCount: columns, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: columns == 1 ? 3.4 : 1.8, children: const [
            ReportCard(icon: Icons.receipt_long_rounded, title: 'Sales report', detail: 'Revenue by customer and period'),
            ReportCard(icon: Icons.account_balance_rounded, title: 'GST summary', detail: 'Tax collected and payable'),
            ReportCard(icon: Icons.inventory_2_outlined, title: 'Stock report', detail: 'Low stock and valuation'),
            ReportCard(icon: Icons.payments_outlined, title: 'Profit & loss', detail: 'Income, expenses, and margin'),
          ]);
        }),
      );
}

class ModulePage extends StatelessWidget {
  const ModulePage({super.key, required this.title, required this.subtitle, required this.child, this.actionLabel, this.actionIcon, this.onAction});
  final String title, subtitle;
  final Widget child;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 650;
    return SingleChildScrollView(padding: EdgeInsets.fromLTRB(narrow ? 18 : 38, 30, narrow ? 18 : 38, 40), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))), const SizedBox(height: 6), Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14))])), if (!narrow && actionLabel != null) FilledButton.icon(onPressed: onAction, icon: Icon(actionIcon), label: Text(actionLabel!), style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14))) ]),
      if (narrow && actionLabel != null) Padding(padding: const EdgeInsets.only(top: 18), child: SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: onAction, icon: Icon(actionIcon), label: Text(actionLabel!), style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 14))))),
      const SizedBox(height: 26), child,
    ]));
  }
}

class DataPanel extends StatelessWidget {
  const DataPanel({super.key, required this.headers, required this.rows, this.lastColumnIsStatus = true});
  final List<String> headers;
  final List<List<String>> rows;
  final bool lastColumnIsStatus;
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(10)), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(columnSpacing: 34, headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)), columns: headers.map((header) => DataColumn(label: Text(header, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))).toList(), rows: rows.map((row) => DataRow(cells: row.indexed.map((entry) => DataCell(lastColumnIsStatus && entry.$1 == row.length - 1 ? StatusPill(status: entry.$2) : Text(entry.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))).toList())).toList())));
}

class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.icon, required this.title, required this.detail});
  final IconData icon;
  final String title, detail;
  @override
  Widget build(BuildContext context) => InkWell(onTap: () => _showMessage(context, '$title opened.'), borderRadius: BorderRadius.circular(10), child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(10)), child: Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(9)), child: Icon(icon, color: const Color(0xFF2563EB))), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)), const SizedBox(height: 5), Text(detail, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12))])), const Icon(Icons.arrow_forward_rounded, color: Color(0xFF94A3B8))])));
}

class InvoiceDialog extends StatelessWidget {
  const InvoiceDialog({super.key});
  @override
  Widget build(BuildContext context) => AlertDialog(title: const Text('Create invoice'), content: const SizedBox(width: 420, child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(decoration: InputDecoration(labelText: 'Customer', hintText: 'Search customer')), SizedBox(height: 14), TextField(decoration: InputDecoration(labelText: 'Amount', prefixText: '₹ '), keyboardType: TextInputType.number), SizedBox(height: 14), TextField(decoration: InputDecoration(labelText: 'Notes', hintText: 'Optional payment note'))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () { Navigator.pop(context); _showMessage(context, 'Invoice draft created.'); }, child: const Text('Create draft'))]);
}

void _showMessage(BuildContext context, String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
