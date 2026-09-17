import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}

class ApiClient {
  final SecureStorageService _storage;
  final http.Client _client;

  ApiClient({SecureStorageService? storage, http.Client? client})
      : _storage = storage ?? SecureStorageService(),
        _client = client ?? http.Client();

  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<bool> testConnection([String? host]) async {
    try {
      final rawHost = (host != null && host.trim().isNotEmpty) ? host.trim() : AppConfig.activeHost;
      var clean = rawHost;
      final bool isSecure = rawHost.startsWith('https://') ||
          rawHost.contains('.trycloudflare.com') ||
          rawHost.contains('.ngrok-free.app');
      if (clean.startsWith('https://')) {
        clean = clean.substring(8);
      } else if (clean.startsWith('http://')) {
        clean = clean.substring(7);
      }
      if (clean.endsWith('/')) {
        clean = clean.substring(0, clean.length - 1);
      }
      final scheme = isSecure ? 'https' : 'http';
      final uri = Uri.parse('$scheme://$clean/health');
      final response = await _client.get(uri).timeout(const Duration(seconds: 6));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<dynamic> get(String endpoint, {bool requiresAuth = true}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);

    try {
      final response = await _client.get(uri, headers: headers).timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } on TimeoutException {
      throw ApiException(message: 'Connection timed out. Please check your network.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error: $e');
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body, bool requiresAuth = true}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);

    try {
      final response = await _client
          .post(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } on TimeoutException {
      throw ApiException(message: 'Connection timed out. Please check your network.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error: $e');
    }
  }

  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? body, bool requiresAuth = true}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);

    try {
      final response = await _client
          .patch(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } on TimeoutException {
      throw ApiException(message: 'Connection timed out. Please check your network.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return response.body;
      }
    }

    String errorMessage = 'Request failed with status: ${response.statusCode}';
    dynamic errorData;
    try {
      errorData = jsonDecode(response.body);
      if (errorData is Map && errorData.containsKey('detail')) {
        errorMessage = errorData['detail'].toString();
      }
    } catch (_) {}

    throw ApiException(
      message: errorMessage,
      statusCode: response.statusCode,
      data: errorData,
    );
  }
}
