import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';

/// Two-Factor Authentication API Service
/// Tích hợp với backend API để quản lý 2FA (TOTP với Google Authenticator)
class TwoFactorAuthApiService {
  /// POST /api/2fa/setup - Setup 2FA (Bước 1)
  /// Trả về QR code URL và backup codes
  Future<Map<String, dynamic>> setup2FA(String userId) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.twoFactorSetupEndpoint}',
      );
      final response = await http.post(
        url,
        headers: ApiConfig.authHeaders(userId),
      );

      if (kDebugMode) {
        print('📡 2FA Setup - Status: ${response.statusCode}');
        print('📡 Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'secret': data['data']['secret'],
            'qrCodeUrl': data['data']['qrCodeUrl'],
            'backupCodes': List<String>.from(data['data']['backupCodes']),
          };
        }
      }

      throw Exception('Setup 2FA failed: ${response.body}');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in setup2FA: $e');
      }
      rethrow;
    }
  }

  /// POST /api/2fa/enable - Enable 2FA (Bước 2)
  /// Verify token từ Google Authenticator để enable 2FA
  Future<bool> enable2FA(String userId, String token) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.twoFactorEnableEndpoint}',
      );
      final response = await http.post(
        url,
        headers: ApiConfig.authHeaders(userId),
        body: json.encode({'token': token}),
      );

      if (kDebugMode) {
        print('📡 2FA Enable - Status: ${response.statusCode}');
        print('📡 Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in enable2FA: $e');
      }
      return false;
    }
  }

  /// POST /api/2fa/verify - Verify 2FA (Dùng khi login)
  /// Verify token hoặc backup code
  Future<Map<String, dynamic>> verify2FA(String userId, String token) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.twoFactorVerifyEndpoint}',
      );
      final response = await http.post(
        url,
        headers: ApiConfig.defaultHeaders,
        body: json.encode({'userId': userId, 'token': token}),
      );

      if (kDebugMode) {
        print('📡 2FA Verify - Status: ${response.statusCode}');
        print('📡 Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'verified': data['data']['verified'],
            'usedBackupCode': data['data']['usedBackupCode'] ?? false,
          };
        }
      }

      return {
        'success': false,
        'verified': false,
        'message': 'Invalid token or expired',
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in verify2FA: $e');
      }
      return {
        'success': false,
        'verified': false,
        'message': 'Error verifying 2FA: $e',
      };
    }
  }

  /// GET /api/2fa/status - Kiểm tra trạng thái 2FA
  Future<Map<String, dynamic>> get2FAStatus(String userId) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.twoFactorStatusEndpoint}',
      );
      final response = await http.get(
        url,
        headers: ApiConfig.authHeaders(userId),
      );

      if (kDebugMode) {
        print('📡 2FA Status - Status: ${response.statusCode}');
        print('📡 Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'isEnabled': data['data']['isEnabled'],
            'hasBackupCodes': data['data']['hasBackupCodes'],
            'backupCodesCount': data['data']['backupCodesCount'],
          };
        }
      }

      return {'success': false, 'isEnabled': false};
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in get2FAStatus: $e');
      }
      return {'success': false, 'isEnabled': false};
    }
  }

  /// POST /api/2fa/disable - Tắt 2FA
  /// Cần token hoặc backup code để xác nhận
  Future<bool> disable2FA(String userId, String token) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.twoFactorDisableEndpoint}',
      );
      final response = await http.post(
        url,
        headers: ApiConfig.authHeaders(userId),
        body: json.encode({'token': token}),
      );

      if (kDebugMode) {
        print('📡 2FA Disable - Status: ${response.statusCode}');
        print('📡 Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in disable2FA: $e');
      }
      return false;
    }
  }
}
