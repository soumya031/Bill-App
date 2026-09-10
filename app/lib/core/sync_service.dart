import 'dart:convert';

import 'api_client.dart';

class SyncService {
  const SyncService(this._client);

  final ApiClient _client;

  Future<bool> pushSync(
      {required String businessId,
      required String entity,
      required String entityId,
      required String op,
      required Map<String, dynamic> payload}) async {
    final response = await _client.post('/api/v1/sync/push', {
      'businessId': businessId,
      'entity': entity,
      'entityId': entityId,
      'op': op,
      'payload': jsonEncode(payload),
    });

    return response.statusCode == 202 || response.statusCode == 200;
  }
}
