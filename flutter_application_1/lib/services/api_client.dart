import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Exception thrown by API client
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException({required this.message, this.statusCode, this.originalError});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static const String _authTokenKey = 'authToken';
  static const String _apiBaseUrlFromEnv = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  String _defaultBaseUrl() {
    if (kIsWeb) return 'http://localhost:4000';

    if (Platform.isAndroid) {
      // Android emulator loopback to host machine.
      return 'http://10.0.2.2:4000';
    }

    if (Platform.isIOS) {
      // iOS simulator loopback to host machine.
      return 'http://127.0.0.1:4000';
    }

    return 'http://localhost:4000';
  }

  String get baseUrl {
    if (_apiBaseUrlFromEnv.isNotEmpty) return _apiBaseUrlFromEnv;
    return _defaultBaseUrl();
  }

  bool _isInitialized = false;
  late final Dio _dio;

  void _initialize() {
    if (_isInitialized) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add error interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );

    _isInitialized = true;
  }

  Dio unauthenticated() {
    _initialize();
    return _dio;
  }

  Future<Dio> authenticated() async {
    _initialize();
    final token = await readAuthToken();
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
    return _dio;
  }

  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  Future<String?> readAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  Future<bool> hasAuthToken() async {
    final token = await readAuthToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    if (_isInitialized) {
      _dio.options.headers.remove('Authorization');
    }
  }

  /// Parse API error response
  static ApiException handleError(dynamic error) {
    if (error is DioException) {
      int? statusCode = error.response?.statusCode;
      String message = error.message ?? 'Unknown error';

      try {
        if (error.response?.data is Map) {
          final data = error.response!.data as Map;
          message = data['message'] ?? message;
        }
      } catch (_) {}

      return ApiException(
        message: message,
        statusCode: statusCode,
        originalError: error,
      );
    }

    return ApiException(message: error.toString(), originalError: error);
  }
}
