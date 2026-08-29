import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models.dart';
import '../../core/money.dart';
import '../../core/session.dart';
import '../../data/repositories.dart';
import '../../finance/stock_moves_screen.dart';
import '../../theme/stitch_theme.dart';
import '../../utils/widgets.dart';
import 'product_form.dart';

class ProductListTab extends StatefulWidget {
  const ProductListTab({super.key});
  @override
  State<ProductListTab> createState() => _ProductListTabState();
}

class _ProductListTabState extends State<ProductListTab> {
  List<Product>? items;
  final search = TextEditingController();
  String query = '';
  String? typeFilter;

  Future<void> _load() async {
    final businessId = context.read<Session>().businessId;
    if (businessId == null) return;
    final products = await Repository.instance.products(businessId);
    if (!mounted) return;
    setState(() => items = products);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _add() {
    final businessId = context.read<Session>().businessId!;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ProductFormSheet(onSaved: _load, onSavedProduct: (_) {}, businessId: businessId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final all = items ?? const <Product>[];
    final filtered = all.where((p) {
      final q = query.trim().toLowerCase();
      final matchQuery = q.isEmpty || p.name.toLowerCase().contains(q) || (p.sku ?? '').toLowerCase().contains(q) || (p.barcode ?? '').toLowerCase().contains(q);
      final matchType = switch (typeFilter) {
        'out' => p.outOfStock,
        'low' => p.low,
        _ => true,
      };
      return matchQuery && matchType;
    }).toList();
    final inStock = all.where((p) => !p.outOfStock).length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: search,
              onChanged: (v) => setState(() => query = v),
              decoration: const InputDecoration(hintText: 'Search by name, SKU or barcode', prefixIcon: Icon(Icons.search_rounded, size: 20)),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 48,
            height: 48,
            child: FilledButton(onPressed: _add, style: FilledButton.styleFrom(padding: EdgeInsets.zero), child: const Icon(Icons.add_rounded)),
          ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        child: Wrap(spacing: 8, children: [
          FilterChip(label: const Text('All'), selected: typeFilter == null, onSelected: (_) => setState(() => typeFilter = null)),
          FilterChip(
              label: const Text('Low stock'),
              selected: typeFilter == 'low',
              onSelected: (_) => setState(() => typeFilter = typeFilter == 'low' ? null : 'low')),
          FilterChip(
              label: const Text('Out of stock'),
              selected: typeFilter == 'out',
              onSelected: (_) => setState(() => typeFilter = typeFilter == 'out' ? null : 'out')),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Text('${all.length} product(s), $inStock in stock',
            style: const TextStyle(fontSize: 12, color: StitchColors.textSecondary)),
      ),
      Expanded(
        child: items == null
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : filtered.isEmpty
                ? ListView(children: const [
                    AppEmptyState(icon: Icons.inventory_2_outlined, title: 'No products found')
                  ])
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 128,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => _ProductTile(
                      product: filtered[i],
                      onTap: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => StockMovesScreen(productId: filtered[i].id!)))
                          .then((_) => _load()),
                    ),
                  ),
      ),
    ]);
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.onTap});
  final Product product;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final out = product.outOfStock;
    final low = product.low;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
            if (out)
              const Icon(Icons.error_rounded, size: 16, color: StitchColors.error)
            else if (low)
              const Icon(Icons.warning_amber_rounded, size: 16, color: StitchColors.warning),
          ]),
          const SizedBox(height: 4),
          Text(product.sku ?? product.barcode ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: StitchColors.textSecondary)),
          const Spacer(),
          Row(children: [
            Expanded(
              child: Text('Stock ${_qty(product.stock)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: out ? StitchColors.error : low ? StitchColors.warning : StitchColors.success,
                  )),
            ),
            Text(formatPaise(product.salePrice), style: moneyStyle(fontSize: 12, color: StitchColors.textPrimary)),
          ]),
        ]),
      ),
    );
  }

  static String _qty(num stock) => stock == stock.roundToDouble() ? stock.round().toString() : stock.toStringAsFixed(2);
}