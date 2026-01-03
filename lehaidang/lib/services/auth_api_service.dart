import '../../config/app_config.dart';
import 'api/base_api_service.dart';

/// Auth API Service
/// Service để xử lý các API liên quan đến authentication
class AuthApiService extends BaseApiService {
  /// Login
  /// POST /api/users/login
  /// ACTUAL Response format: {success: true, data: {id, email, fullName, timezone}}
  /// Note: Backend returns user data directly in 'data', not nested in 'data.user'
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await post(
        ApiConfig.loginEndpoint,
        body: {'email': email, 'password': password},
      );

      print('🔍 Login Response: $response');

      if (response == null) {
        throw Exception('Response is null');
      }

      final data = response['data'];
      print('🔍 Response data: $data');

      if (data == null) {
        throw Exception('Response data is null. Full response: $response');
      }

      if (data is! Map) {
        throw Exception(
          'Response data is not a Map: ${data.runtimeType}. Data: $data',
        );
      }

      // Backend returns user data DIRECTLY in 'data' field, not nested
      final userData = Map<String, dynamic>.from(data);
      print('✅ Login successful! User: ${userData['email']}');

      // Return user data with requires2FA flag set to false
      // (If backend implements 2FA, it will need to return this flag)
      return {'requires2FA': false, ...userData};
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  /// Register
  /// POST /api/users/register
  /// ACTUAL Response format: {success: true, message: "...", data: {id, email, fullName, ...}}
  /// Note: Backend returns user data directly in 'data', not nested in 'data.user'
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    String? timezone,
  }) async {
    try {
      final response = await post(
        ApiConfig.registerEndpoint,
        body: {
          'email': email,
          'password': password,
          'fullName': fullName,
          if (timezone != null) 'timezone': timezone,
        },
      );

      if (response == null) {
        throw Exception('Response is null');
      }

      final data = response['data'];
      if (data == null) {
        throw Exception('Response data is null');
      }

      if (data is! Map) {
        throw Exception('Response data is not a Map: ${data.runtimeType}');
      }

      // Backend returns user data DIRECTLY in 'data' field
      return Map<String, dynamic>.from(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get Current User Profile
  /// GET /api/users/me
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await get(
        ApiConfig.userProfileEndpoint,
        headers: ApiConfig.authHeaders(userId),
      );
      // Response: {success: true, data: {id, email, fullName, timezone}}
      if (response == null || response['data'] == null) {
        throw Exception('Invalid response from getUserProfile');
      }
      final data = response['data'];
      if (data is! Map) {
        throw Exception('User data is not a Map: ${data.runtimeType}');
      }
      return data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Get All Users (Admin/Manager only)
  /// GET /api/users
  Future<List<Map<String, dynamic>>> getAllUsers(String userId) async {
    try {
      final response = await get(
        ApiConfig.usersEndpoint,
        headers: ApiConfig.authHeaders(userId),
      );
      // Response: {success: true, data: [...]}
      if (response == null || response['data'] == null) {
        throw Exception('Invalid response from getAllUsers');
      }
      final data = response['data'];
      if (data is! List) {
        throw Exception('Users data is not a List: ${data.runtimeType}');
      }
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get User by ID
  /// GET /api/users/:id
  Future<Map<String, dynamic>> getUserById(
    String userId,
    String targetUserId,
  ) async {
    try {
      final response = await get(
        '${ApiConfig.usersEndpoint}/$targetUserId',
        headers: ApiConfig.authHeaders(userId),
      );
      if (response == null || response['data'] == null) {
        throw Exception('Invalid response from getUserById');
      }
      final data = response['data'];
      if (data is! Map) {
        throw Exception('User data is not a Map: ${data.runtimeType}');
      }
      return data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Update User
  /// PUT /api/users/:id
  Future<Map<String, dynamic>> updateUser(
    String userId,
    String targetUserId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await put(
        '${ApiConfig.usersEndpoint}/$targetUserId',
        body: updates,
        headers: ApiConfig.authHeaders(userId),
      );
      if (response == null || response['data'] == null) {
        throw Exception('Invalid response from updateUser');
      }
      final data = response['data'];
      if (data is! Map) {
        throw Exception('User data is not a Map: ${data.runtimeType}');
      }
      return data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete User (Admin only)
  /// DELETE /api/users/:id
  Future<void> deleteUser(String userId, String targetUserId) async {
    try {
      await delete(
        '${ApiConfig.usersEndpoint}/$targetUserId',
        headers: ApiConfig.authHeaders(userId),
      );
    } catch (e) {
      rethrow;
    }
  }
}
