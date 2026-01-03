import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Two-Factor Authentication Service
/// Quản lý OTP và bảo mật 2 lớp cho tài khoản
class TwoFactorAuthService {
  static const String _otpKey = 'otp_codes';
  static const String _otpTimestampKey = 'otp_timestamps';
  static const int otpLength = 6;
  static const int otpValidityMinutes = 5;

  /// Generate OTP code (6 digits)
  String generateOTP() {
    final random = Random.secure();
    final code = List.generate(otpLength, (_) => random.nextInt(10)).join();
    return code;
  }

  /// Send OTP (trong môi trường thực tế sẽ gửi qua email/SMS)
  /// Hiện tại lưu vào SharedPreferences để demo
  Future<String> sendOTP(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final otp = generateOTP();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Lưu OTP và timestamp
    final otpMap = prefs.getString(_otpKey) ?? '{}';
    final timestampMap = prefs.getString(_otpTimestampKey) ?? '{}';

    // Parse maps
    final Map<String, dynamic> otps = _parseJson(otpMap);
    final Map<String, dynamic> timestamps = _parseJson(timestampMap);

    // Store new OTP
    otps[userId] = otp;
    timestamps[userId] = timestamp;

    // Save back
    await prefs.setString(_otpKey, _encodeJson(otps));
    await prefs.setString(_otpTimestampKey, _encodeJson(timestamps));

    // Trong thực tế: gửi OTP qua email/SMS
    if (kDebugMode) {
      print('📧 OTP sent to user $userId: $otp');
    }

    return otp;
  }

  /// Verify OTP
  Future<bool> verifyOTP(String userId, String otp) async {
    final prefs = await SharedPreferences.getInstance();

    final otpMap = prefs.getString(_otpKey) ?? '{}';
    final timestampMap = prefs.getString(_otpTimestampKey) ?? '{}';

    final Map<String, dynamic> otps = _parseJson(otpMap);
    final Map<String, dynamic> timestamps = _parseJson(timestampMap);

    // Check if OTP exists
    final storedOtp = otps[userId];
    final timestamp = timestamps[userId];

    if (storedOtp == null || timestamp == null) {
      return false;
    }

    // Check if OTP expired
    final otpTime = DateTime.fromMillisecondsSinceEpoch(timestamp as int);
    final now = DateTime.now();
    final difference = now.difference(otpTime).inMinutes;

    if (difference > otpValidityMinutes) {
      // OTP expired
      await clearOTP(userId);
      return false;
    }

    // Verify OTP
    final isValid = storedOtp == otp;

    if (isValid) {
      // Clear OTP after successful verification
      await clearOTP(userId);
    }

    return isValid;
  }

  /// Clear OTP for user
  Future<void> clearOTP(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    final otpMap = prefs.getString(_otpKey) ?? '{}';
    final timestampMap = prefs.getString(_otpTimestampKey) ?? '{}';

    final Map<String, dynamic> otps = _parseJson(otpMap);
    final Map<String, dynamic> timestamps = _parseJson(timestampMap);

    otps.remove(userId);
    timestamps.remove(userId);

    await prefs.setString(_otpKey, _encodeJson(otps));
    await prefs.setString(_otpTimestampKey, _encodeJson(timestamps));
  }

  /// Get remaining OTP validity time in seconds
  Future<int> getRemainingTime(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final timestampMap = prefs.getString(_otpTimestampKey) ?? '{}';
    final Map<String, dynamic> timestamps = _parseJson(timestampMap);

    final timestamp = timestamps[userId];
    if (timestamp == null) return 0;

    final otpTime = DateTime.fromMillisecondsSinceEpoch(timestamp as int);
    final now = DateTime.now();
    final elapsed = now.difference(otpTime).inSeconds;
    final remaining = (otpValidityMinutes * 60) - elapsed;

    return remaining > 0 ? remaining : 0;
  }

  /// Helper: Parse JSON string to Map
  Map<String, dynamic> _parseJson(String jsonStr) {
    try {
      if (jsonStr.isEmpty || jsonStr == '{}') return {};
      // Simple parsing for demo (in production use dart:convert)
      final map = <String, dynamic>{};
      final cleaned = jsonStr.substring(1, jsonStr.length - 1);
      if (cleaned.isEmpty) return map;

      final pairs = cleaned.split(',');
      for (final pair in pairs) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          final key = parts[0].trim().replaceAll('"', '');
          final value = parts[1].trim().replaceAll('"', '');
          // Try parse as int
          final intValue = int.tryParse(value);
          map[key] = intValue ?? value;
        }
      }
      return map;
    } catch (e) {
      return {};
    }
  }

  /// Helper: Encode Map to JSON string
  String _encodeJson(Map<String, dynamic> map) {
    if (map.isEmpty) return '{}';
    final pairs = map.entries.map((e) {
      final value = e.value is String ? '"${e.value}"' : e.value;
      return '"${e.key}":$value';
    });
    return '{${pairs.join(',')}}';
  }

  /// Resend OTP
  Future<String> resendOTP(String userId) async {
    await clearOTP(userId);
    return await sendOTP(userId);
  }

  /// Check if user has pending OTP
  Future<bool> hasPendingOTP(String userId) async {
    final remaining = await getRemainingTime(userId);
    return remaining > 0;
  }
}
