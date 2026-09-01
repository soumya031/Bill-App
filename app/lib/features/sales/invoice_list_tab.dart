import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models.dart';
import '../../core/money.dart';
import '../../core/session.dart';
import '../../data/repositories.dart';
import '../../finance/simple_invoice_row.dart';
import '../../theme/stitch_theme.dart';
import '../../utils/widgets.dart';
import '../../utils/export_service.dart';
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

  Future<void> _exportData(String format, List<Invoice> invoices) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Preparing export...'),
            duration: Duration(seconds: 1)),
      );

      final session = context.read<Session>();
      final business =
          await Repository.instance.getBusiness(session.businessId!);
      final fileName = 'Sales_Report_${DateTime.now().millisecondsSinceEpoch}';

      switch (format) {
        case 'excel':
          await ExportService.exportToExcel(
            invoices,
            businessName: business?.name,
            fileName: fileName,
          );
        case 'json':
          await ExportService.exportToJson(
            invoices,
            businessName: business?.name,
            fileName: fileName,
          );
        case 'csv':
          await ExportService.exportToCsv(
            invoices,
            businessName: business?.name,
            fileName: fileName,
          );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = items ?? const <Invoice>[];
    final filtered = all.where((i) {
      final matchStatus = statusFilter == null || i.status == statusFilter;
      final q = query.trim().toLowerCase();
      final matchQuery = q.isEmpty ||
          i.number.toLowerCase().contains(q) ||
          (i.customerName ?? '').toLowerCase().contains(q);
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
              decoration: const InputDecoration(
                  hintText: 'Search invoice or customer',
                  prefixIcon: Icon(Icons.search_rounded, size: 20)),
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
                DropdownMenuItem(
                    value: 'Partially paid', child: Text('Partially paid')),
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${filtered.length} invoice(s)  •  ${formatPaise(total)}',
                style: const TextStyle(
                    fontSize: 12, color: StitchColors.textSecondary)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: filtered.isEmpty
                        ? null
                        : () => _exportData('excel', filtered),
                    icon: const Icon(Icons.file_download_rounded, size: 18),
                    label: const Text('Excel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StitchColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: filtered.isEmpty
                        ? null
                        : () => _exportData('json', filtered),
                    icon: const Icon(Icons.data_object_rounded, size: 18),
                    label: const Text('JSON'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StitchColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: filtered.isEmpty
                        ? null
                        : () => _exportData('csv', filtered),
                    icon: const Icon(Icons.table_chart_rounded, size: 18),
                    label: const Text('CSV'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StitchColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      Expanded(
        child: items == null
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : filtered.isEmpty
                ? ListView(children: const [
                    AppEmptyState(
                        icon: Icons.receipt_long_rounded,
                        title: 'No invoices found')
                  ])
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SimpleInvoiceRow(
                        invoice: filtered[i],
                        onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (_) => InvoiceDetailScreen(
                                    invoiceId: filtered[i].id!)))
                            .then((_) => _load()),
                      ),
                    ),
                  ),
      ),
    ]);
  }
}
