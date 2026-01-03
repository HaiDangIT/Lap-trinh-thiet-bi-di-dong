import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// API Client for making HTTP requests to backend
/// Follows the API structure from API_TESTING_GUIDE.md
class ApiClient {
  final String baseUrl;
  String? _authToken;

  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? ApiConfig.baseUrl;

  /// Set authentication token
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Get authentication headers
  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  /// Handle API response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: body['message'] ?? 'Unknown error',
      );
    }
  }

  /// GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl$endpoint');

      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(
          queryParameters: queryParams.map(
            (key, value) => MapEntry(key, value.toString()),
          ),
        );
      }

      debugPrint('GET: $uri');

      final response = await http.get(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('GET Error: $e');
      rethrow;
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('POST: $uri');
      debugPrint('Body: ${json.encode(body)}');

      final response = await http.post(
        uri,
        headers: _headers,
        body: body != null ? json.encode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint('POST Error: $e');
      rethrow;
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('PUT: $uri');

      final response = await http.put(
        uri,
        headers: _headers,
        body: body != null ? json.encode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint('PUT Error: $e');
      rethrow;
    }
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('DELETE: $uri');

      final response = await http.delete(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('DELETE Error: $e');
      rethrow;
    }
  }

  // =============================================================================
  // 👤 USER ENDPOINTS
  // =============================================================================

  /// Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    String timezone = 'Asia/Ho_Chi_Minh',
  }) async {
    return await post(
      ApiConfig.registerEndpoint,
      body: {
        'email': email,
        'password': password,
        'fullName': fullName,
        'timezone': timezone,
      },
    );
  }

  /// Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return await post(
      ApiConfig.loginEndpoint,
      body: {'email': email, 'password': password},
    );
  }

  /// Verify 2FA after login
  Future<Map<String, dynamic>> verify2FA({
    required String userId,
    required String token,
  }) async {
    return await post(
      '/api/users/verify-2fa',
      body: {'userId': userId, 'token': token},
    );
  }

  /// Get current user profile
  Future<Map<String, dynamic>> getCurrentUser() async {
    return await get(ApiConfig.userProfileEndpoint);
  }

  /// Get list of users (Admin/Manager only)
  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int pageSize = 20,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'pageSize': pageSize};

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    return await get(ApiConfig.usersEndpoint, queryParams: queryParams);
  }

  /// Search users
  Future<Map<String, dynamic>> searchUsers({
    required String query,
    int limit = 10,
  }) async {
    return await get(
      '/api/users/search',
      queryParams: <String, dynamic>{'q': query, 'limit': limit},
    );
  }

  /// Get user by ID
  Future<Map<String, dynamic>> getUserById(String userId) async {
    return await get('${ApiConfig.usersEndpoint}/$userId');
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    return await get('${ApiConfig.usersEndpoint}/$userId/stats');
  }

  /// Update user
  Future<Map<String, dynamic>> updateUser({
    required String userId,
    String? fullName,
    String? timezone,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['fullName'] = fullName;
    if (timezone != null) body['timezone'] = timezone;

    return await put('${ApiConfig.usersEndpoint}/$userId', body: body);
  }

  /// Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await post(
      '/api/users/change-password',
      body: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }

  /// Delete user (Admin only)
  Future<Map<String, dynamic>> deleteUser(String userId) async {
    return await delete('${ApiConfig.usersEndpoint}/$userId');
  }

  /// Bulk delete users (Admin only)
  Future<Map<String, dynamic>> bulkDeleteUsers(List<String> userIds) async {
    return await post('/api/users/bulk-delete', body: {'userIds': userIds});
  }

  // =============================================================================
  // 🔐 2FA ENDPOINTS
  // =============================================================================

  /// Setup 2FA - Get QR code
  Future<Map<String, dynamic>> setup2FA() async {
    return await post(ApiConfig.twoFactorSetupEndpoint);
  }

  /// Enable 2FA
  Future<Map<String, dynamic>> enable2FA({required String token}) async {
    return await post(
      ApiConfig.twoFactorEnableEndpoint,
      body: {'token': token},
    );
  }

  /// Check 2FA status
  Future<Map<String, dynamic>> get2FAStatus() async {
    return await get(ApiConfig.twoFactorStatusEndpoint);
  }

  /// Regenerate backup codes
  Future<Map<String, dynamic>> regenerateBackupCodes({
    required String token,
  }) async {
    return await post(
      '/api/2fa/regenerate-backup-codes',
      body: {'token': token},
    );
  }

  /// Disable 2FA
  Future<Map<String, dynamic>> disable2FA({required String token}) async {
    return await post(
      ApiConfig.twoFactorDisableEndpoint,
      body: {'token': token},
    );
  }

  /// Verify 2FA (Internal)
  Future<Map<String, dynamic>> verify2FAToken({
    required String userId,
    required String token,
  }) async {
    return await post(
      ApiConfig.twoFactorVerifyEndpoint,
      body: {'userId': userId, 'token': token},
    );
  }
}

/// API Exception
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
