import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/two_factor_auth_service.dart';

/// OTP Verification Screen
/// Màn hình xác thực OTP cho bảo mật 2 lớp
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
  final TwoFactorAuthService _tfaService = TwoFactorAuthService();

  bool _isLoading = false;
  bool _isVerifying = false;
  String? _errorMessage;
  int _remainingSeconds = 0;
  Timer? _timer;
  String? _sentOtp; // For demo purposes

  @override
  void initState() {
    super.initState();
    _sendOTP();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Send OTP
      _sentOtp = await _tfaService.sendOTP(widget.userId);

      // Start countdown timer
      _remainingSeconds = TwoFactorAuthService.otpValidityMinutes * 60;
      _startTimer();

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mã OTP đã được gửi đến ${widget.email}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Show OTP for demo
        _showOTPDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Lỗi khi gửi OTP. Vui lòng thử lại.';
        });
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOTP() async {
    // Get OTP from controllers
    final otp = _controllers.map((c) => c.text).join();

    if (otp.length != 6) {
      setState(() {
        _errorMessage = 'Vui lòng nhập đủ 6 số';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final isValid = await _tfaService.verifyOTP(widget.userId, otp);

      if (mounted) {
        if (isValid) {
          // Success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Xác thực thành công!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Wait for snackbar then callback
          await Future.delayed(const Duration(milliseconds: 500));
          widget.onVerified();
        } else {
          setState(() {
            _errorMessage = 'Mã OTP không đúng hoặc đã hết hạn';
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

  Future<void> _resendOTP() async {
    // Clear all fields
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();

    await _sendOTP();
  }

  void _showOTPDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Mã OTP (Demo)'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Trong môi trường thực tế, mã này sẽ được gửi qua email/SMS.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _sentOtp ?? '',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Copy to clipboard
              Clipboard.setData(ClipboardData(text: _sentOtp ?? ''));
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Đã copy mã OTP')));
            },
            child: const Text('Copy'),
          ),
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
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác Thực OTP'),
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
                'Nhập mã OTP 6 số đã được gửi đến\n${widget.email}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              // OTP Input Fields
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
                      keyboardType: TextInputType.number,
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
                            _verifyOTP();
                          }
                        } else if (value.isEmpty && index > 0) {
                          // Move to previous field
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              // Timer
              if (_remainingSeconds > 0)
                Text(
                  'Mã hết hạn sau: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              const SizedBox(height: 16),
              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOTP,
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
              // Resend Button
              TextButton(
                onPressed: _isLoading || _remainingSeconds > 240
                    ? null
                    : _resendOTP,
                child: Text(
                  _isLoading
                      ? 'Đang gửi...'
                      : _remainingSeconds > 240
                      ? 'Gửi lại sau ${_remainingSeconds - 240}s'
                      : 'Gửi lại mã OTP',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
