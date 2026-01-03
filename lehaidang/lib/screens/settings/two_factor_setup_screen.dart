import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/api/two_factor_auth_api_service.dart';
import '../../services/auth_service.dart';

/// 2FA Setup Screen
/// Màn hình để user setup Two-Factor Authentication với Google Authenticator
class TwoFactorSetupScreen extends StatefulWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  State<TwoFactorSetupScreen> createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends State<TwoFactorSetupScreen> {
  final TwoFactorAuthApiService _tfaApiService = TwoFactorAuthApiService();
  final TextEditingController _tokenController = TextEditingController();

  bool _isLoading = true;
  bool _isVerifying = false;
  String? _errorMessage;

  // 2FA Setup data
  String? _secret;
  String? _qrCodeUrl;
  List<String>? _backupCodes;

  @override
  void initState() {
    super.initState();
    _loadSetupData();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _loadSetupData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.id;

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final result = await _tfaApiService.setup2FA(userId);

      if (result['success'] == true) {
        setState(() {
          _secret = result['secret'];
          _qrCodeUrl = result['qrCodeUrl'];
          _backupCodes = result['backupCodes'];
          _isLoading = false;
        });
      } else {
        throw Exception('Setup failed');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi setup 2FA: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _enableTwoFactor() async {
    if (_tokenController.text.trim().length != 6) {
      setState(() {
        _errorMessage = 'Vui lòng nhập mã 6 số từ Google Authenticator';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.id;

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final success = await _tfaApiService.enable2FA(
        userId,
        _tokenController.text.trim(),
      );

      if (mounted) {
        if (success) {
          // Update user model
          final updatedUser = authService.currentUser!.copyWith(
            twoFactorEnabled: true,
            twoFactorSecret: _secret,
          );
          await authService.updateUser(updatedUser);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ 2FA đã được kích hoạt thành công!'),
              backgroundColor: Colors.green,
            ),
          );

          // Return to previous screen
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          setState(() {
            _errorMessage = 'Mã xác thực không đúng. Vui lòng thử lại.';
            _isVerifying = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi khi enable 2FA: $e';
          _isVerifying = false;
        });
      }
    }
  }

  void _showBackupCodesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Backup Codes'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LƯU CÁC MÃ NÀY VÀO NƠI AN TOÀN!\n\nMỗi mã chỉ dùng 1 lần khi bạn mất điện thoại.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _backupCodes!
                      .map(
                        (code) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            code,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _backupCodes!.join('\n')));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã copy backup codes')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy tất cả'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup 2FA'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.security,
                        size: 40,
                        color: Colors.deepPurple.shade700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    const Text(
                      'Bảo mật 2 lớp (2FA)',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bảo vệ tài khoản với Google Authenticator',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Step 1: Install App
                    _buildStep(
                      number: '1',
                      title: 'Cài đặt Google Authenticator',
                      description:
                          'Tải app từ App Store hoặc Google Play Store',
                    ),
                    const SizedBox(height: 16),
                    // Step 2: Scan QR Code
                    _buildStep(
                      number: '2',
                      title: 'Quét QR Code',
                      description: 'Mở app và quét mã QR bên dưới',
                    ),
                    const SizedBox(height: 16),
                    // QR Code Image
                    if (_qrCodeUrl != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Image.memory(
                              Uri.parse(_qrCodeUrl!).data!.contentAsBytes(),
                              width: 200,
                              height: 200,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Secret: $_secret',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontFamily: 'monospace',
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: _secret ?? ''),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã copy secret key'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy, size: 16),
                              label: const Text('Copy secret key'),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    // Step 3: Verify Token
                    _buildStep(
                      number: '3',
                      title: 'Nhập mã xác thực',
                      description: 'Nhập mã 6 số từ Google Authenticator',
                    ),
                    const SizedBox(height: 16),
                    // Token Input
                    TextField(
                      controller: _tokenController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                      decoration: InputDecoration(
                        hintText: '000000',
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
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                    // Enable Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isVerifying ? null : _enableTwoFactor,
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
                                'Kích hoạt 2FA',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // View Backup Codes
                    if (_backupCodes != null && _backupCodes!.isNotEmpty)
                      OutlinedButton.icon(
                        onPressed: _showBackupCodesDialog,
                        icon: const Icon(Icons.vpn_key),
                        label: const Text('Xem Backup Codes'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
