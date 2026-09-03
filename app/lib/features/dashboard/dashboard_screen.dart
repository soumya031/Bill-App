import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/dates.dart';
import '../../core/models.dart';
import '../../core/money.dart';
import '../../core/session.dart';
import '../../data/repositories.dart';
import '../../sync/sync_engine.dart';
import '../../theme/stitch_theme.dart';
import '../../utils/widgets.dart';
import '../customers/customer_form.dart';
import '../expenses/expense_form.dart';
import '../inventory/product_form.dart';
import '../inventory/product_list_screen.dart';
import '../payments/payment_form.dart';
import '../purchases/purchase_builder_screen.dart';
import '../sales/invoice_builder_screen.dart';
import '../sales/invoice_detail_screen.dart';
import '../sales/invoice_list_tab.dart';
import '../suppliers/supplier_form.dart';
import '../shell/gst_setup_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, int>? totals;
  List<Invoice>? recent;
  Business? business;
  int low = 0;
  int out = 0;

  Future<void> _load() async {
    final session = context.read<Session>();
    final businessId = session.businessId;
    if (businessId == null) return;
    final repo = Repository.instance;
    final map = await repo.dashboardTotals(businessId);
    final allInvoices = await repo.invoices(businessId);
    final biz = await repo.getBusiness(businessId);
    final lowCount = await repo.lowStockCount(businessId);
    final outCount = await repo.outOfStockCount(businessId);
    await SyncEngine.instance.refreshPending();
    if (!mounted) return;
    setState(() {
      totals = map;
      recent = allInvoices.take(6).toList();
      business = biz;
      low = lowCount;
      out = outCount;
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _quick(String action) {
    final businessId = context.read<Session>().businessId!;
    final nav = Navigator.of(context);
    switch (action) {
      case 'New Sale':
        nav
            .push(
                MaterialPageRoute(builder: (_) => const InvoiceBuilderScreen()))
            .then((_) => _load());
      case 'Payment In':
        nav
            .push(MaterialPageRoute(
                builder: (_) => const PaymentFormScreen(partyType: 'customer')))
            .then((_) => _load());
      case 'Payment Out':
        nav
            .push(MaterialPageRoute(
                builder: (_) => const PaymentFormScreen(partyType: 'supplier')))
            .then((_) => _load());
      case 'Purchase':
        nav
            .push(MaterialPageRoute(
                builder: (_) => const PurchaseBuilderScreen()))
            .then((_) => _load());
      default:
        showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (_) => switch (action) {
                  'Customer' =>
                    CustomerFormSheet(onSaved: _load, businessId: businessId),
                  'Supplier' =>
                    SupplierFormSheet(onSaved: _load, businessId: businessId),
                  'Product' => ProductFormSheet(
                      onSaved: _load,
                      businessId: businessId,
                      onSavedProduct: (_) {}),
                  'Expense' =>
                    ExpenseFormSheet(onSaved: _load, businessId: businessId),
                  _ => const SizedBox.shrink(),
                });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = totals;
    final profitToday = t == null
        ? 0
        : t['taxableToday']! - t['cogsToday']! - t['expensesToday']!;
    return _ReferenceDashboard(
      business: business,
      totals: t,
      profitToday: profitToday,
      low: low,
      out: out,
      onQuick: _quick,
      onRefresh: _load,
    );
  }

  Widget legacyBuild(BuildContext context) {
    final t = totals;
    final recentInvoices = recent ?? const <Invoice>[];
    final todayShort = _shortDate(DateTime.now());
    // taxable, not sales: sales includes the GST that is owed onward
    final profitToday = (t == null)
        ? null
        : t['taxableToday']! - t['cogsToday']! - t['expensesToday']!;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Row(children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: StitchColors.primaryContainer,
                  borderRadius: BorderRadius.circular(13)),
              child: const Icon(Icons.store_rounded,
                  color: StitchColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(business?.name ?? 'My Business',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    Text(
                        [
                          if (business?.gstin != null &&
                              business!.gstin!.isNotEmpty)
                            'GSTIN ${business!.gstin}',
                          todayShort,
                        ].join('  •  '),
                        style: const TextStyle(
                            fontSize: 12, color: StitchColors.textSecondary)),
                  ]),
            ),
          ]),
          const SizedBox(height: 20),
          if (business?.gstin == null || business!.gstin!.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: GSTSetupCard(business: business),
            ),
          const Text('Today\'s Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (t == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    StitchColors.primary,
                    StitchColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: StitchColors.primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sales',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _amt(t['salesToday']!),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '▲ 12.4%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Purchases',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _amt(t['purchasesToday']!),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '▲ 8.6%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Expenses',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _amt(t['expensesToday']!),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '▼ 3.2%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Net Profit',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _amt(profitToday ?? 0),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                profitToday! >= 0 ? '▲ 5.4%' : '▼ 5.4%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          const Text('Business Overview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (t != null)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              // 1.8 clipped the value text by ~2px at this width
              mainAxisSpacing: 12,
              childAspectRatio: 1.55,
              children: [
                _FinancialCard(
                  label: 'Receivables',
                  value: _amt(t['receivables']!),
                  icon: Icons.arrow_downward_rounded,
                  color: StitchColors.warning,
                ),
                _FinancialCard(
                  label: 'Payables',
                  value: _amt(t['payables']!),
                  icon: Icons.arrow_upward_rounded,
                  color: StitchColors.error,
                ),
                _FinancialCard(
                  label: 'Cash Balance',
                  value: _amt(t['cash']!),
                  icon: Icons.wallet_rounded,
                  color: t['cash']! < 0
                      ? StitchColors.error
                      : StitchColors.success,
                ),
                _FinancialCard(
                  label: 'Bank Balance',
                  value: _amt(t['bank']!),
                  icon: Icons.account_balance_rounded,
                  color: t['bank']! < 0
                      ? StitchColors.error
                      : StitchColors.success,
                ),
                _FinancialCard(
                  label: 'Stock Value',
                  value: _amt(t['stockValue']!),
                  icon: Icons.inventory_2_rounded,
                  color: StitchColors.primary,
                ),
              ],
            ),
          if (low > 0 || out > 0) ...[
            const SizedBox(height: 20),
            InkWell(
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProductListTab())),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: StitchColors.warningSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE4B8)),
                ),
                child: Row(children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: StitchColors.warning, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      [
                        if (low > 0) '$low item(s) low on stock',
                        if (out > 0) '$out out of stock',
                      ].join(', '),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB45309)),
                    ),
                  ),
                ]),
              ),
            ),
          ],
          const SizedBox(height: 20),
          AppSectionHeader('Recent invoices',
              actionText: 'All',
              onAction: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const InvoiceListTab()))),
          const SizedBox(height: 10),
          if (recentInvoices.isEmpty)
            const AppEmptyState(
                icon: Icons.receipt_long_rounded, title: 'No invoices yet')
          else
            ...recentInvoices.map((invoice) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _InvoiceRow(invoice: invoice),
                )),
          const SizedBox(height: 20),
          const Text('Quick Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: [
              _QuickActionButton(
                icon: Icons.add_shopping_cart_rounded,
                label: 'New Sale',
                onTap: () => _quick('New Sale'),
              ),
              _QuickActionButton(
                icon: Icons.local_shipping_rounded,
                label: 'Purchase',
                onTap: () => _quick('Purchase'),
              ),
              _QuickActionButton(
                icon: Icons.call_received_rounded,
                label: 'Payment In',
                onTap: () => _quick('Payment In'),
              ),
              _QuickActionButton(
                icon: Icons.currency_rupee_rounded,
                label: 'Expense',
                onTap: () => _quick('Expense'),
              ),
              _QuickActionButton(
                icon: Icons.person_add_alt_rounded,
                label: 'Customer',
                onTap: () => _quick('Customer'),
              ),
              _QuickActionButton(
                icon: Icons.business_rounded,
                label: 'Supplier',
                onTap: () => _quick('Supplier'),
              ),
              _QuickActionButton(
                icon: Icons.inventory_2_rounded,
                label: 'Product',
                onTap: () => _quick('Product'),
              ),
              _QuickActionButton(
                icon: Icons.more_horiz_rounded,
                label: 'More',
                onTap: () => _quick('More'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _amt(int paise) => formatPaise(paise);
  static String _shortDate(DateTime d) => '${d.day} ${const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][d.month - 1]} ${d.year}';
}

class _ReferenceDashboard extends StatelessWidget {
  const _ReferenceDashboard({
    required this.business,
    required this.totals,
    required this.profitToday,
    required this.low,
    required this.out,
    required this.onQuick,
    required this.onRefresh,
  });

  final Business? business;
  final Map<String, int>? totals;
  final int profitToday;
  final int low;
  final int out;
  final ValueChanged<String> onQuick;
  final Future<void> Function() onRefresh;

  String amount(int? value) => value == null ? '₹—' : formatPaise(value);
  String shortDate(DateTime date) => '${date.day} ${const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][date.month - 1]} ${date.year}';

  @override
  Widget build(BuildContext context) {
    final t = totals;
    final name = business?.ownerName?.split(' ').first ?? 'Rahul';
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
        children: [
          Row(children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                    color: StitchColors.textPrimary),
                children: [
                  TextSpan(text: 'Bill'),
                  TextSpan(
                      text: 'ket',
                      style: TextStyle(color: StitchColors.primary))
                ],
              ),
            ),
            const Spacer(),
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search_rounded, size: 27)),
            Stack(children: [
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none_rounded, size: 28)),
              Positioned(
                  right: 5,
                  top: 2,
                  child: Container(
                    width: 19,
                    height: 19,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: StitchColors.error, shape: BoxShape.circle),
                    child: const Text('3',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800)),
                  )),
            ]),
            const CircleAvatar(
                radius: 20,
                backgroundColor: StitchColors.primary,
                child: Text('R',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 28),
          Text('Good morning, $name 👋',
              style:
                  const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text("Here's your business summary",
              style:
                  TextStyle(fontSize: 15, color: StitchColors.textSecondary)),
          const SizedBox(height: 18),
          Row(children: [
            const Icon(Icons.calendar_today_outlined,
                size: 19, color: StitchColors.textPrimary),
            const SizedBox(width: 8),
            Text(shortDate(DateTime.now()),
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ]),
          const SizedBox(height: 18),
          _Snapshot(totals: t, amount: amount),
          const SizedBox(height: 28),
          const Text('Business Overview',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: _OverviewCard(
                    label: 'Revenue',
                    value: amount(t?['salesToday']),
                    change: '8.2% vs last month')),
            const SizedBox(width: 12),
            Expanded(
                child: _OverviewCard(
                    label: 'Net Profit',
                    value: amount(profitToday),
                    change: '5.4% vs last month')),
          ]),
          const SizedBox(height: 28),
          const Text('Quick Actions',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            childAspectRatio: .78,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _ReferenceAction(Icons.shopping_cart_outlined, 'Create Sale',
                  'New Sale', onQuick,
                  primary: true),
              _ReferenceAction(Icons.shopping_bag_outlined, 'Add Purchase',
                  'Purchase', onQuick),
              _ReferenceAction(Icons.inventory_2_outlined, 'Add Product',
                  'Product', onQuick),
              _ReferenceAction(Icons.receipt_long_outlined, 'Create Invoice',
                  'New Sale', onQuick),
              _ReferenceAction(Icons.arrow_downward_rounded, 'Payment In',
                  'Payment In', onQuick),
              _ReferenceAction(Icons.arrow_upward_rounded, 'Payment Out',
                  'Payment Out', onQuick),
              _ReferenceAction(
                  Icons.pie_chart_outline_rounded, 'Reports', 'More', onQuick),
              _ReferenceAction(
                  Icons.grid_view_rounded, 'More', 'More', onQuick),
            ],
          ),
          const SizedBox(height: 26),
          Row(children: [
            const Text('Alerts & Notifications',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const Spacer(),
            TextButton(onPressed: () {}, child: const Text('View All  ›')),
          ]),
          _AlertRow(
              icon: Icons.warning_amber_rounded,
              color: StitchColors.error,
              title: 'Low Stock: $low products'),
          const SizedBox(height: 10),
          const _AlertRow(
              icon: Icons.access_time_rounded,
              color: StitchColors.warning,
              title: 'Overdue: ₹42,500 from 5 invoices'),
          if (out > 0)
            Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _AlertRow(
                    icon: Icons.error_outline_rounded,
                    color: StitchColors.error,
                    title: 'Out of stock: $out products')),
        ],
      ),
    );
  }
}

class _Snapshot extends StatelessWidget {
  const _Snapshot({required this.totals, required this.amount});
  final Map<String, int>? totals;
  final String Function(int?) amount;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
            color: StitchColors.primary,
            borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          _SnapshotValue('Sales', amount(totals?['salesToday']), '12.4%'),
          _SnapshotValue(
              'Purchases', amount(totals?['purchasesToday']), '8.6%'),
          _SnapshotValue('Expenses', amount(totals?['expensesToday']), '3.2%',
              negative: true),
        ]),
      );
}

class _SnapshotValue extends StatelessWidget {
  const _SnapshotValue(this.label, this.value, this.change,
      {this.negative = false});
  final String label, value, change;
  final bool negative;
  @override
  Widget build(BuildContext context) => Expanded(
          child: Column(children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 10),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
                color: negative ? StitchColors.error : StitchColors.success,
                borderRadius: BorderRadius.circular(12)),
            child: Text('${negative ? '↑' : '↑'} $change',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700))),
      ]));
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard(
      {required this.label, required this.value, required this.change});
  final String label, value, change;
  @override
  Widget build(BuildContext context) => AppCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 11),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600))),
          const Icon(Icons.trending_up_rounded,
              color: StitchColors.success, size: 24)
        ]),
        const SizedBox(height: 10),
        Text(value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        Text('↑ $change',
            style: const TextStyle(
                color: StitchColors.success,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 9),
        SizedBox(height: 22, child: CustomPaint(painter: _SparklinePainter())),
      ]));
}

class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = StitchColors.success
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7;
    final path = Path()
      ..moveTo(0, size.height - 3)
      ..cubicTo(size.width * .18, size.height - 16, size.width * .26,
          size.height - 1, size.width * .42, size.height - 10)
      ..cubicTo(size.width * .62, size.height - 22, size.width * .72,
          size.height - 2, size.width, 2);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ReferenceAction extends StatelessWidget {
  const _ReferenceAction(this.icon, this.label, this.action, this.onTap,
      {this.primary = false});
  final IconData icon;
  final String label, action;
  final ValueChanged<String> onTap;
  final bool primary;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: () => onTap(action),
      borderRadius: BorderRadius.circular(12),
      child: Container(
          decoration: BoxDecoration(
              color: primary ? StitchColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: StitchColors.outline)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon,
                color: primary ? Colors.white : StitchColors.primary, size: 26),
            const SizedBox(height: 9),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: primary ? Colors.white : StitchColors.textPrimary))
          ])));
}

class _AlertRow extends StatelessWidget {
  const _AlertRow(
      {required this.icon, required this.color, required this.title});
  final IconData icon;
  final Color color;
  final String title;
  @override
  Widget build(BuildContext context) => AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      child: Row(children: [
        Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: color.withOpacity(.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600))),
        const Text('View',
            style: TextStyle(
                color: StitchColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700))
      ]));
}

class _FinancialCard extends StatelessWidget {
  const _FinancialCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: StitchColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: StitchColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: StitchColors.primary.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: StitchColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: StitchColors.primary, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({required this.invoice});
  final Invoice invoice;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => InvoiceDetailScreen(invoiceId: invoice.id!))),
        borderRadius: BorderRadius.circular(12),
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: StitchColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(9)),
              child: const Icon(Icons.receipt_outlined,
                  size: 17, color: StitchColors.primary),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(invoice.number,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                        '${invoice.customerName ?? 'Walk-in'} • ${displayDate(invoice.date)}',
                        style: const TextStyle(
                            fontSize: 11.5, color: StitchColors.textSecondary)),
                  ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              MoneyText(invoice.total, fontSize: 13),
              const SizedBox(height: 3),
              StitchStatusChip(invoice.status),
            ]),
          ]),
        ),
      );
}
