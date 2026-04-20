import 'package:dio/dio.dart';

import 'api_client.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final dio = ApiClient.instance.unauthenticated();

    final response = await dio.post(
      '/auth/signup',
      data: {'name': name, 'email': email, 'password': password},
    );

    return _handleAuthPayload(response.data);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final dio = ApiClient.instance.unauthenticated();

    final response = await dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    return _handleAuthPayload(response.data);
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final dio = await ApiClient.instance.authenticated();
      final response = await dio.get('/users/me');
      if (response.data is! Map) return null;
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException {
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateCurrentUser({
    required String name,
    required String email,
  }) async {
    try {
      final dio = await ApiClient.instance.authenticated();
      final response = await dio.put(
        '/users/me',
        data: {'name': name, 'email': email},
      );

      if (response.data is! Map) return null;
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException {
      return null;
    }
  }

  Future<void> logout() => ApiClient.instance.clearAuthToken();

  Future<Map<String, dynamic>> _handleAuthPayload(dynamic payload) async {
    if (payload is! Map) {
      throw const FormatException('Invalid auth response');
    }

    final map = Map<String, dynamic>.from(payload as Map);
    final token = map['token'];
    final user = map['user'];

    if (token is! String || user is! Map) {
      throw const FormatException('Invalid auth response fields');
    }

    await ApiClient.instance.saveAuthToken(token);
    return Map<String, dynamic>.from(user as Map);
  }
}
