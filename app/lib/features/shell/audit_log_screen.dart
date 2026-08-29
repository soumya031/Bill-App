import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models.dart';
import '../../core/session.dart';
import '../../data/repositories.dart';
import '../../theme/stitch_theme.dart';
import '../../utils/widgets.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});
  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  List<AuditEntry>? entries;

  Future<void> _load() async {
    final businessId = context.read<Session>().businessId;
    if (businessId == null) return;
    final list = await Repository.instance.auditLog(businessId);
    if (!mounted) return;
    setState(() => entries = list);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Audit log')),
        body: entries == null
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : entries!.isEmpty
                ? const AppEmptyState(icon: Icons.history_rounded, title: 'No activity recorded yet')
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries!.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final e = entries![i];
                      final color = switch (e.action) {
                        'create' => StitchColors.success,
                        'delete' => StitchColors.error,
                        'update' => StitchColors.warning,
                        _ => StitchColors.primary,
                      };
                      return AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                            child: Icon(
                              switch (e.action) {
                                'create' => Icons.add_rounded,
                                'delete' => Icons.delete_outline_rounded,
                                'update' => Icons.edit_outlined,
                                _ => Icons.info_outline_rounded,
                              },
                              size: 18,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('${e.action.toUpperCase()} ${e.entity}${e.entityId != null ? ' #${e.entityId}' : ''}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(
                                '${e.timestamp}${e.actor.isNotEmpty ? '  •  ${e.actor}' : ''}',
                                style: const TextStyle(fontSize: 11, color: StitchColors.textSecondary),
                              ),
                            ]),
                          ),
                        ]),
                      );
                    },
                  ),
      );
}