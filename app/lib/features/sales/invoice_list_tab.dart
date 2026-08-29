import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models.dart';
import '../../core/money.dart';
import '../../core/session.dart';
import '../../data/repositories.dart';
import '../../finance/simple_invoice_row.dart';
import '../../theme/stitch_theme.dart';
import '../../utils/widgets.dart';
import 'invoice_detail_screen.dart';

class InvoiceListTab extends StatefulWidget {
  const InvoiceListTab({super.key});
  @override
  State<InvoiceListTab> createState() => _InvoiceListTabState();
}

class _InvoiceListTabState extends State<InvoiceListTab> {
  List<Invoice>? items;
  String? statusFilter;
  String query = '';
  final search = TextEditingController();

  Future<void> _load() async {
    final businessId = context.read<Session>().businessId;
    if (businessId == null) return;
    final all = await Repository.instance.invoices(businessId);
    if (!mounted) return;
    setState(() => items = all);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final all = items ?? const <Invoice>[];
    final filtered = all.where((i) {
      final matchStatus = statusFilter == null || i.status == statusFilter;
      final q = query.trim().toLowerCase();
      final matchQuery = q.isEmpty || i.number.toLowerCase().contains(q) || (i.customerName ?? '').toLowerCase().contains(q);
      return matchStatus && matchQuery;
    }).toList();
    final total = filtered.fold<int>(0, (sum, i) => sum + i.total);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: search,
              onChanged: (v) => setState(() => query = v),
              decoration: const InputDecoration(hintText: 'Search invoice or customer', prefixIcon: Icon(Icons.search_rounded, size: 20)),
            ),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: DropdownButton<String?>(
              value: statusFilter,
              underline: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(12),
              hint: const Text('All'),
              items: const [
                DropdownMenuItem(value: null, child: Text('All')),
                DropdownMenuItem(value: 'Draft', child: Text('Draft')),
                DropdownMenuItem(value: 'Finalized', child: Text('Finalized')),
                DropdownMenuItem(value: 'Partially paid', child: Text('Partially paid')),
                DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                DropdownMenuItem(value: 'Unpaid', child: Text('Unpaid')),
                DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
              ],
              onChanged: (v) => setState(() => statusFilter = v),
            ),
          ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Text('${filtered.length} invoice(s)  •  ${formatPaise(total)}',
            style: const TextStyle(fontSize: 12, color: StitchColors.textSecondary)),
      ),
      Expanded(
        child: items == null
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : filtered.isEmpty
                ? ListView(children: const [
                    AppEmptyState(icon: Icons.receipt_long_rounded, title: 'No invoices found')
                  ])
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SimpleInvoiceRow(
                        invoice: filtered[i],
                        onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => InvoiceDetailScreen(invoiceId: filtered[i].id!)))
                            .then((_) => _load()),
                      ),
                    ),
                  ),
      ),
    ]);
  }
}