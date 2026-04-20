import 'package:dio/dio.dart';

import 'api_client.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  /// Sign up a new user
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final dio = ApiClient.instance.unauthenticated();
      final response = await dio.post(
        '/auth/signup',
        data: {'name': name, 'email': email, 'password': password},
      );
      return _handleAuthPayload(response.data);
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Login with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final dio = ApiClient.instance.unauthenticated();
      final response = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return _handleAuthPayload(response.data);
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Get current authenticated user
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final dio = await ApiClient.instance.authenticated();
      final response = await dio.get('/users/me');
      if (response.data is! Map) {
        throw FormatException('Invalid user response');
      }
      return Map<String, dynamic>.from(response.data as Map);
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Update current user profile
  Future<Map<String, dynamic>> updateCurrentUser({
    required String name,
    required String email,
  }) async {
    try {
      final dio = await ApiClient.instance.authenticated();
      final response = await dio.put(
        '/users/me',
        data: {'name': name, 'email': email},
      );

      if (response.data is! Map) {
        throw FormatException('Invalid update response');
      }
      return Map<String, dynamic>.from(response.data as Map);
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return ApiClient.instance.hasAuthToken();
  }

  /// Logout - clear auth token
  Future<void> logout() async {
    await ApiClient.instance.clearAuthToken();
  }

  /// Get stored auth token
  Future<String?> getAuthToken() async {
    return ApiClient.instance.readAuthToken();
  }

  /// Parse and handle auth API response
  Future<Map<String, dynamic>> _handleAuthPayload(dynamic payload) async {
    if (payload is! Map) {
      throw FormatException('Invalid auth response');
    }

    final map = Map<String, dynamic>.from(payload as Map);
    final token = map['token'];
    final user = map['user'];

    if (token is! String || user is! Map) {
      throw FormatException('Invalid auth response fields');
    }

    await ApiClient.instance.saveAuthToken(token);
    return Map<String, dynamic>.from(user as Map);
  }
}
