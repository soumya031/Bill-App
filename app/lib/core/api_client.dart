import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({String baseUrl = 'http://10.0.2.2:4000'}) : _baseUrl = baseUrl;

  final String _baseUrl;
  String? _token;

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;

  Map<String, String> _headers({Map<String, String>? extra}) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  Future<http.Response> post(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    return http.post(uri,
        headers: _headers(extra: headers), body: jsonEncode(body));
  }

  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    return http.get(uri, headers: _headers(extra: headers));
  }
}
