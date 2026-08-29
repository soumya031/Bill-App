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
        nav.push(MaterialPageRoute(builder: (_) => const InvoiceBuilderScreen()));
      case 'Payment In':
        nav.push(MaterialPageRoute(builder: (_) => const PaymentFormScreen(partyType: 'customer')));
      case 'Payment Out':
        nav.push(MaterialPageRoute(builder: (_) => const PaymentFormScreen(partyType: 'supplier')));
      case 'Purchase':
        nav.push(MaterialPageRoute(builder: (_) => const PurchaseBuilderScreen()));
      default:
        showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (_) => switch (action) {
                  'Customer' => CustomerFormSheet(onSaved: () async {}, businessId: businessId),
                  'Supplier' => SupplierFormSheet(onSaved: () async {}, businessId: businessId),
                  'Product' => ProductFormSheet(onSaved: () async {}, businessId: businessId, onSavedProduct: (_) {}),
                  'Expense' => ExpenseFormSheet(onSaved: () async {}, businessId: businessId),
                  _ => const SizedBox.shrink(),
                });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = totals;
    final recentInvoices = recent ?? const <Invoice>[];
    final todayShort = _shortDate(DateTime.now());
    final profitToday = (t == null) ? null : t['salesToday']! - t['cogsToday']! - t['expensesToday']!;
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
              decoration: BoxDecoration(color: StitchColors.primaryContainer, borderRadius: BorderRadius.circular(13)),
              child: const Icon(Icons.store_rounded, color: StitchColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(business?.name ?? 'My Business',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Text([
                  if (business?.gstin != null && business!.gstin!.isNotEmpty) 'GSTIN ${business!.gstin}',
                  todayShort,
                ].join('  •  '),
                    style: const TextStyle(fontSize: 12, color: StitchColors.textSecondary)),
              ]),
            ),
          ]),
          const SizedBox(height: 20),
          const Text('Today\'s Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (t == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.7,
              children: [
                StatCard(label: 'Sales', value: _amt(t['salesToday']!), icon: Icons.trending_up_rounded, color: StitchColors.success),
                StatCard(label: 'Purchases', value: _amt(t['purchasesToday']!), icon: Icons.local_shipping_rounded, color: StitchColors.error),
                StatCard(label: 'Expenses', value: _amt(t['expensesToday']!), icon: Icons.currency_rupee_rounded, color: StitchColors.error),
                StatCard(
                    label: 'Profit',
                    value: _amt(profitToday!),
                    icon: profitToday >= 0 ? Icons.savings_outlined : Icons.trending_down_rounded,
                    color: profitToday >= 0 ? StitchColors.success : StitchColors.error),
              ],
            ),
          const SizedBox(height: 20),
          const Text('Financial position', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (t != null) ...[
            _positionRow('Receivables', _amt(t['receivables']!), StitchColors.warning),
            _positionRow('Payables', _amt(t['payables']!), StitchColors.error),
            _positionRow('Cash balance', _amt(t['cash']!), StitchColors.success),
            _positionRow('Bank balance', _amt(t['bank']!), StitchColors.success),
            _positionRow('Stock value', _amt(t['stockValue']!), StitchColors.primary),
          ],
          if (low > 0 || out > 0) ...[
            const SizedBox(height: 20),
            InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductListTab())),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: StitchColors.warningSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE4B8)),
                ),
                child: Row(children: [
                  const Icon(Icons.warning_amber_rounded, color: StitchColors.warning, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      [
                        if (low > 0) '$low item(s) low on stock',
                        if (out > 0) ', $out out of stock',
                      ].join(),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFB45309)),
                    ),
                  ),
                ]),
              ),
            ),
          ],
          const SizedBox(height: 20),
          AppSectionHeader('Recent invoices', actionText: 'All',
              onAction: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InvoiceListTab()))),
          const SizedBox(height: 10),
          if (recentInvoices.isEmpty)
            const AppEmptyState(icon: Icons.receipt_long_rounded, title: 'No invoices yet')
          else
            ...recentInvoices.map((invoice) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _InvoiceRow(invoice: invoice),
                )),
          const SizedBox(height: 14),
          const Text('Quick actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 16,
            children: [
              QuickAction(icon: Icons.add_shopping_cart_rounded, label: 'New Sale', onTap: () => _quick('New Sale')),
              QuickAction(icon: Icons.local_shipping_rounded, label: 'Purchase', onTap: () => _quick('Purchase'), color: StitchColors.success),
              QuickAction(icon: Icons.call_received_rounded, label: 'Payment In', onTap: () => _quick('Payment In'), color: StitchColors.success),
              QuickAction(icon: Icons.call_made_rounded, label: 'Payment Out', onTap: () => _quick('Payment Out'), color: StitchColors.error),
              QuickAction(icon: Icons.currency_rupee_rounded, label: 'Expense', onTap: () => _quick('Expense'), color: StitchColors.error),
              QuickAction(icon: Icons.person_add_alt_1_rounded, label: 'Customer', onTap: () => _quick('Customer')),
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
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            Text(value, style: moneyStyle(fontSize: 14, weight: FontWeight.w700, color: color)),
          ]),
        ),
      );

  static String _amt(int paise) => formatPaise(paise);
  static String _shortDate(DateTime d) =>
      '${d.day} ${const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1]} ${d.year}';
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({required this.invoice});
  final Invoice invoice;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => InvoiceDetailScreen(invoiceId: invoice.id!))),
        borderRadius: BorderRadius.circular(12),
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: StitchColors.surfaceVariant, borderRadius: BorderRadius.circular(9)),
              child: const Icon(Icons.receipt_outlined, size: 17, color: StitchColors.primary),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(invoice.number, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('${invoice.customerName ?? 'Walk-in'} • ${displayDate(invoice.date)}',
                    style: const TextStyle(fontSize: 11.5, color: StitchColors.textSecondary)),
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