import 'dart:convert';

import 'api_client.dart';

class AuthResponse {
  const AuthResponse(
      {required this.token,
      required this.userId,
      required this.name,
      required this.email,
      required this.role});

  final String token;
  final String userId;
  final String name;
  final String email;
  final String role;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      userId: json['user']['id'] as String,
      name: json['user']['name'] as String,
      email: json['user']['email'] as String,
      role: json['user']['role'] as String,
    );
  }
}

class AuthService {
  const AuthService(this._client);

  final ApiClient _client;

  Future<AuthResponse> register(
      {required String name,
      required String email,
      required String password}) async {
    final response = await _client.post('/api/v1/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });

    if (response.statusCode >= 400) {
      throw Exception(
          jsonDecode(response.body)['error'] ?? 'Registration failed');
    }

    return AuthResponse.fromJson(jsonDecode(response.body));
  }

  Future<AuthResponse> login(
      {required String email, required String password}) async {
    final response = await _client.post('/api/v1/auth/login', {
      'email': email,
      'password': password,
    });

    if (response.statusCode >= 400) {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Login failed');
    }

    return AuthResponse.fromJson(jsonDecode(response.body));
  }
}
