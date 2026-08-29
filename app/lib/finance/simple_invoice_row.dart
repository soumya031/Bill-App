import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../core/models.dart';
import '../../theme/stitch_theme.dart';
import '../../utils/widgets.dart';

class SimpleInvoiceRow extends StatelessWidget {
  const SimpleInvoiceRow({super.key, required this.invoice, required this.onTap});
  final Invoice invoice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
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
                Text(displayDate(invoice.date),
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