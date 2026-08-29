import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/dates.dart';
import '../../core/money.dart';
import '../../core/models.dart';
import '../../core/session.dart';
import '../../data/repositories.dart';
import '../../theme/stitch_theme.dart';
import '../../utils/widgets.dart';

class StockMovesScreen extends StatefulWidget {
  const StockMovesScreen({super.key, required this.productId});
  final int productId;
  @override
  State<StockMovesScreen> createState() => _StockMovesScreenState();
}

class _StockMovesScreenState extends State<StockMovesScreen> {
  Product? product;
  List<StockMove>? moves;

  Future<void> _load() async {
    final businessId = context.read<Session>().businessId;
    if (businessId == null) return;
    final repo = Repository.instance;
    final products = await repo.products(businessId, includeInactive: true);
    Product? found;
    for (final x in products) {
      if (x.id == widget.productId) found = x;
    }
    final m = await repo.stockMoves(businessId, widget.productId);
    if (!mounted) return;
    setState(() {
      product = found;
      moves = m;
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _adjust() async {
    final controller = TextEditingController();
    final mode = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Adjust stock', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(product?.name ?? '', style: const TextStyle(fontSize: 13, color: StitchColors.textSecondary)),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'New stock quantity'))),
              ]),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, 'cancelled'),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, controller.text),
                    child: const Text('Update stock'),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
    if (mode == null || mode == 'cancelled') return;
    final newQty = double.tryParse(mode.trim());
    if (newQty == null) return;
    final p = product;
    if (p == null) return;
    try {
      await Repository.instance.adjustStock(p, newQty - p.stock, 'adjustment');
      await _load();
      if (mounted) showAppMessage(context, 'Stock updated');
    } catch (e) {
      if (mounted) showAppMessage(context, 'Could not update: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = product;
    final m = moves;
    return Scaffold(
      appBar: AppBar(
        title: Text(p?.name ?? 'Product'),
        actions: [
          TextButton.icon(onPressed: _adjust, icon: const Icon(Icons.tune_rounded, size: 18), label: const Text('Adjust')),
        ],
      ),
      body: p == null
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 40), children: [
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    InitialsAvatar(p.name, size: 42),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(p.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        Text([p.sku, p.category].whereType<String>().where((e) => e.isNotEmpty).join('  •  '),
                            style: const TextStyle(fontSize: 12, color: StitchColors.textSecondary)),
                      ]),
                    ),
                  ]),
                  const Divider(height: 20),
                  Row(children: [
                    Expanded(child: _stat('In stock', _qty(p.stock), p.outOfStock ? StitchColors.error : p.low ? StitchColors.warning : StitchColors.success)),
                    Expanded(child: _stat('Sale price', formatPaise(p.salePrice), StitchColors.textPrimary)),
                    Expanded(child: _stat('Purchase price', formatPaise(p.purchasePrice), StitchColors.textPrimary)),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: _stat('MRP', formatPaise(p.mrp), StitchColors.textSecondary)),
                    Expanded(child: _stat('GST', '${p.gstRate}%', StitchColors.textSecondary)),
                    Expanded(child: _stat('Unit', p.unit, StitchColors.textSecondary)),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),
              const Text('Stock history', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              if (m == null)
                const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
              else if (m.isEmpty)
                const AppEmptyState(icon: Icons.receipt_long_rounded, title: 'No stock movements yet')
              else
                ...m.map((move) => _MoveTile(move: move)),
            ]),
    );
  }

  Widget _stat(String label, String value, Color color) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: StitchColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ]);

  static String _qty(num stock) => stock == stock.roundToDouble() ? stock.round().toString() : stock.toStringAsFixed(2);
}

class _MoveTile extends StatelessWidget {
  const _MoveTile({required this.move});
  final StockMove move;
  @override
  Widget build(BuildContext context) {
    final inQty = move.changeQty >= 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: inQty ? const Color(0xFFE8F5EF) : const Color(0xFFFFECE9),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(inQty ? Icons.add_rounded : Icons.remove_rounded, size: 17, color: inQty ? StitchColors.success : StitchColors.error),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(move.moveType, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(displayDate(move.date), style: const TextStyle(fontSize: 11, color: StitchColors.textSecondary)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${inQty ? '+' : ''}${_qty(move.changeQty)}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: inQty ? StitchColors.success : StitchColors.error)),
            const SizedBox(height: 2),
            Text('after: ${_qty(move.qtyAfter)}', style: const TextStyle(fontSize: 10.5, color: StitchColors.textSecondary)),
          ]),
        ]),
      ),
    );
  }

  static String _qty(num stock) => stock == stock.roundToDouble() ? stock.round().toString() : stock.toStringAsFixed(2);
}