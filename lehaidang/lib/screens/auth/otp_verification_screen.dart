import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api/two_factor_auth_api_service.dart';

/// OTP Verification Screen
/// Màn hình xác thực 2FA token khi login (sử dụng backend API)
class OTPVerificationScreen extends StatefulWidget {
  final String userId;
  final String email;
  final VoidCallback onVerified;

  const OTPVerificationScreen({
    super.key,
    required this.userId,
    required this.email,
    required this.onVerified,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final TwoFactorAuthApiService _tfaApiService = TwoFactorAuthApiService();

  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyToken() async {
    // Get token from controllers
    final token = _controllers.map((c) => c.text).join();

    if (token.length != 6) {
      setState(() {
        _errorMessage = 'Vui lòng nhập đủ 6 số hoặc backup code';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final result = await _tfaApiService.verify2FA(widget.userId, token);

      if (mounted) {
        if (result['verified'] == true) {
          // Success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['usedBackupCode'] == true
                    ? '✅ Xác thực bằng backup code thành công!'
                    : '✅ Xác thực thành công!',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Wait for snackbar then callback
          await Future.delayed(const Duration(milliseconds: 500));
          widget.onVerified();
        } else {
          setState(() {
            _errorMessage =
                result['message'] ?? 'Mã xác thực không đúng hoặc đã hết hạn';
            _isVerifying = false;
            // Clear all fields
            for (var controller in _controllers) {
              controller.clear();
            }
            _focusNodes[0].requestFocus();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi xác thực. Vui lòng thử lại.';
          _isVerifying = false;
        });
      }
    }
  }

  void _showBackupCodeInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Backup Code'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nếu bạn mất điện thoại, có thể dùng backup code để đăng nhập.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            Text(
              '• Mỗi backup code chỉ dùng 1 lần\n'
              '• Nhập backup code vào ô token\n'
              '• Backup code có 8 ký tự',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác Thực 2FA'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 50,
                  color: Colors.deepPurple.shade700,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              const Text(
                'Bảo mật 2 lớp',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                'Nhập mã 6 số từ Google Authenticator\n${widget.email}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              // Token Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50,
                    height: 60,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.text,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.deepPurple,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          // Move to next field
                          if (index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else {
                            // Last field - auto verify
                            _focusNodes[index].unfocus();
                            _verifyToken();
                          }
                        } else if (value.isEmpty && index > 0) {
                          // Move to previous field
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyToken,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Xác Thực',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // Backup Code Info
              TextButton.icon(
                onPressed: _showBackupCodeInfo,
                icon: const Icon(Icons.vpn_key, size: 18),
                label: const Text('Dùng Backup Code'),
              ),
              const SizedBox(height: 8),
              Text(
                'Mã xác thực tự động làm mới mỗi 30 giây',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
