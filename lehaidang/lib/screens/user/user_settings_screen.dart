import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api/two_factor_auth_api_service.dart';
import '../settings/two_factor_setup_screen.dart';
import 'notification_settings_screen.dart';

/// User Settings Screen
/// Màn hình cài đặt tài khoản với option bật/tắt 2FA
class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  final TwoFactorAuthApiService _tfaApiService = TwoFactorAuthApiService();
  bool _isLoading = true;
  bool _twoFactorEnabled = false;
  int _backupCodesCount = 0;

  @override
  void initState() {
    super.initState();
    _load2FAStatus();
  }

  Future<void> _load2FAStatus() async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.id;

      if (userId != null) {
        final status = await _tfaApiService.get2FAStatus(userId);
        if (mounted) {
          setState(() {
            _twoFactorEnabled = status['isEnabled'] ?? false;
            _backupCodesCount = status['backupCodesCount'] ?? 0;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSetup2FA() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const TwoFactorSetupScreen()),
    );

    if (result == true) {
      _load2FAStatus();
    }
  }

  Future<void> _handleDisable2FA() async {
    // Show confirmation dialog with token input
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _Disable2FADialog(
        onDisable: (token) async {
          final authService = Provider.of<AuthService>(context, listen: false);
          final userId = authService.currentUser?.id;
          if (userId != null) {
            final success = await _tfaApiService.disable2FA(userId, token);
            if (success && mounted) {
              // Update user model
              final updatedUser = authService.currentUser!.copyWith(
                twoFactorEnabled: false,
              );
              await authService.updateUser(updatedUser);
              return true;
            }
          }
          return false;
        },
      ),
    );

    if (confirmed == true) {
      _load2FAStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài Đặt Tài Khoản'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // User Info Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Text(
                          user?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                          style: TextStyle(
                            fontSize: 40,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.fullName ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user?.role.displayName ?? 'User',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Security Section
                _buildSectionHeader('Bảo mật'),
                _build2FATile(),
                const Divider(),
                // Account Section
                _buildSectionHeader('Tài khoản'),
                _buildSettingTile(
                  icon: Icons.person,
                  title: 'Thông tin cá nhân',
                  subtitle: 'Cập nhật tên, email',
                  onTap: () {
                    // TODO: Navigate to profile edit
                  },
                ),
                _buildSettingTile(
                  icon: Icons.lock,
                  title: 'Đổi mật khẩu',
                  subtitle: 'Thay đổi mật khẩu đăng nhập',
                  onTap: () {
                    // TODO: Navigate to change password
                  },
                ),
                const Divider(),
                // App Settings
                _buildSectionHeader('Ứng dụng'),
                _buildSettingTile(
                  icon: Icons.notifications,
                  title: 'Thông báo',
                  subtitle: 'Quản lý thông báo nhắc nhở',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationSettingsScreen(),
                      ),
                    );
                  },
                ),
                _buildSettingTile(
                  icon: Icons.palette,
                  title: 'Giao diện',
                  subtitle: 'Chủ đề và màu sắc',
                  onTap: () {
                    // TODO: Navigate to theme settings
                  },
                ),
                const Divider(),
                // About
                _buildSectionHeader('Về ứng dụng'),
                _buildSettingTile(
                  icon: Icons.info,
                  title: 'Phiên bản',
                  subtitle: '1.0.0',
                  onTap: null,
                ),
                const SizedBox(height: 24),
                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Đăng xuất'),
                          content: const Text('Bạn có chắc muốn đăng xuất?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Hủy'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Đăng xuất'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await authService.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/');
                        }
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Đăng xuất'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _build2FATile() {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _twoFactorEnabled
              ? Colors.green.shade50
              : Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.security,
          color: _twoFactorEnabled ? Colors.green : Colors.orange,
        ),
      ),
      title: const Text(
        'Xác thực hai bước (2FA)',
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        _twoFactorEnabled
            ? 'Đã bật • $_backupCodesCount backup codes còn lại'
            : 'Tăng cường bảo mật tài khoản',
      ),
      trailing: Switch(
        value: _twoFactorEnabled,
        onChanged: (value) {
          if (value) {
            _handleSetup2FA();
          } else {
            _handleDisable2FA();
          }
        },
        activeTrackColor: Colors.green,
      ),
      onTap: () {
        if (_twoFactorEnabled) {
          _handleDisable2FA();
        } else {
          _handleSetup2FA();
        }
      },
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }
}

/// Dialog để disable 2FA
class _Disable2FADialog extends StatefulWidget {
  final Future<bool> Function(String token) onDisable;

  const _Disable2FADialog({required this.onDisable});

  @override
  State<_Disable2FADialog> createState() => _Disable2FADialogState();
}

class _Disable2FADialogState extends State<_Disable2FADialog> {
  final _tokenController = TextEditingController();
  bool _isDisabling = false;
  String? _errorMessage;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _handleDisable() async {
    if (_tokenController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập mã xác thực');
      return;
    }

    setState(() {
      _isDisabling = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.onDisable(_tokenController.text.trim());
      if (mounted) {
        if (success) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Đã tắt xác thực hai bước'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            _errorMessage = 'Mã xác thực không đúng';
            _isDisabling = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi: $e';
          _isDisabling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 8),
          Text('Tắt 2FA'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Để tắt xác thực hai bước, vui lòng nhập mã từ Google Authenticator hoặc backup code:',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tokenController,
            decoration: InputDecoration(
              labelText: 'Mã xác thực',
              hintText: '123456 hoặc backup code',
              border: const OutlineInputBorder(),
              errorText: _errorMessage,
            ),
            keyboardType: TextInputType.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isDisabling ? null : () => Navigator.pop(context, false),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isDisabling ? null : _handleDisable,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isDisabling
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Tắt 2FA'),
        ),
      ],
    );
  }
}
