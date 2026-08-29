import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../core/money.dart';
import '../../core/models.dart';
import '../../theme/stitch_theme.dart';
import '../../utils/widgets.dart';

class LedgerEntryTile extends StatelessWidget {
  const LedgerEntryTile({super.key, required this.entry, this.mode = 'generic'});
  final LedgerEntry entry;
  final String mode;

  @override
  Widget build(BuildContext context) {
    final isCustomer = mode == 'due';
    final debit = entry.debit;
    final credit = entry.credit;
    final outgoing = isCustomer ? debit > credit : credit > debit;
    final delta = (debit - credit).abs();
    final title = (entry.note != null && entry.note!.isNotEmpty)
        ? entry.note!
        : entry.account;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: outgoing ? const Color(0xFFFFECE9) : const Color(0xFFE8F5EF),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              outgoing ? Icons.north_east_rounded : Icons.south_west_rounded,
              size: 16,
              color: outgoing ? StitchColors.error : StitchColors.success,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(displayDate(entry.date),
                  style: const TextStyle(fontSize: 11, color: StitchColors.textSecondary)),
            ]),
          ),
          Text(
            delta == 0 ? '—' : formatPaise(delta),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: delta == 0 ? StitchColors.textSecondary : outgoing ? StitchColors.error : StitchColors.success,
            ),
          ),
        ]),
      ),
    );
  }
}