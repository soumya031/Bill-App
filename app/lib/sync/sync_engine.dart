import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../core/models.dart';
import '../data/repositories.dart';

class MockApi {
  static bool simulateFailure = false;
  static int processed = 0;

  static Future<void> push(SyncRecord record) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (simulateFailure) {
      throw Exception('Server unreachable (simulated)');
    }
    processed++;
    debugPrint('mock-sync ${record.idempotencyKey}');
  }

  static Future<Map<String, Object?>> backup(List<Map<String, Object?>> tables) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return {'stored': true, 'tables': tables.length};
  }

  static String encodePayload(Map<String, Object?> map) => jsonEncode(map);
}

class SyncEngine extends ChangeNotifier {
  SyncEngine._();
  static final SyncEngine instance = SyncEngine._();

  bool syncing = false;
  DateTime? lastSyncedAt;
  int? pendingCount;

  Future<void> refreshPending() async {
    pendingCount = await Repository.instance.pendingSyncCount();
    notifyListeners();
  }

  Future<void> syncNow() async {
    if (syncing) return;
    syncing = true;
    notifyListeners();
    try {
      final queue = await Repository.instance.syncQueue();
      for (final record in queue) {
        try {
          await MockApi.push(record);
          await Repository.instance.markSyncSuccess(record.id!);
        } catch (e) {
          await Repository.instance.markSyncFailed(record.id!, e.toString());
          break;
        }
      }
      lastSyncedAt = DateTime.now();
    } finally {
      syncing = false;
      await refreshPending();
    }
  }
}