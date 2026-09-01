import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/dates.dart';
import '../../core/models.dart';
import '../../core/money.dart';
import '../../core/session.dart';
import '../../data/repositories.dart';
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
        nav.push(
            MaterialPageRoute(builder: (_) => const InvoiceBuilderScreen()));
      case 'Payment In':
        nav.push(MaterialPageRoute(
            builder: (_) => const PaymentFormScreen(partyType: 'customer')));
      case 'Payment Out':
        nav.push(MaterialPageRoute(
            builder: (_) => const PaymentFormScreen(partyType: 'supplier')));
      case 'Purchase':
        nav.push(
            MaterialPageRoute(builder: (_) => const PurchaseBuilderScreen()));
      default:
        showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (_) => switch (action) {
                  'Customer' => CustomerFormSheet(
                      onSaved: () async {}, businessId: businessId),
                  'Supplier' => SupplierFormSheet(
                      onSaved: () async {}, businessId: businessId),
                  'Product' => ProductFormSheet(
                      onSaved: () async {},
                      businessId: businessId,
                      onSavedProduct: (_) {}),
                  'Expense' => ExpenseFormSheet(
                      onSaved: () async {}, businessId: businessId),
                  _ => const SizedBox.shrink(),
                });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = totals;
    final recentInvoices = recent ?? const <Invoice>[];
    final todayShort = _shortDate(DateTime.now());
    final profitToday = (t == null)
        ? null
        : t['salesToday']! - t['cogsToday']! - t['expensesToday']!;
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
              mainAxisSpacing: 12,
              childAspectRatio: 1.8,
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
                  color: StitchColors.success,
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
                        if (out > 0) ', $out out of stock',
                      ].join(),
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

  Widget _positionRow(String label, String value, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600))),
            Text(value,
                style: moneyStyle(
                    fontSize: 14, weight: FontWeight.w700, color: color)),
          ]),
        ),
      );

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
