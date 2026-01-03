import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../settings/two_factor_setup_screen.dart';
import '../user/notification_settings_screen.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt Admin'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.deepPurple.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 50,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.fullName ?? 'Admin',
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
                  child: const Text(
                    'ADMIN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Settings Sections
          const SizedBox(height: 16),

          // Account Settings
          _SettingsSection(
            title: 'Tài khoản',
            items: [
              _SettingsItem(
                icon: Icons.person,
                title: 'Thông tin cá nhân',
                subtitle: 'Xem và chỉnh sửa thông tin',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng đang phát triển')),
                  );
                },
              ),
              _SettingsItem(
                icon: Icons.security,
                title: 'Xác thực hai bước (2FA)',
                subtitle: user?.twoFactorEnabled == true
                    ? 'Đã bật'
                    : 'Chưa bật',
                trailing: user?.twoFactorEnabled == true
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TwoFactorSetupScreen(),
                    ),
                  );
                },
              ),
              _SettingsItem(
                icon: Icons.lock,
                title: 'Đổi mật khẩu',
                subtitle: 'Cập nhật mật khẩu của bạn',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng đang phát triển')),
                  );
                },
              ),
            ],
          ),

          // System Settings
          _SettingsSection(
            title: 'Hệ thống',
            items: [
              _SettingsItem(
                icon: Icons.notifications,
                title: 'Cài đặt thông báo',
                subtitle: 'Quản lý thông báo',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationSettingsScreen(),
                    ),
                  );
                },
              ),
              _SettingsItem(
                icon: Icons.language,
                title: 'Ngôn ngữ',
                subtitle: 'Tiếng Việt',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng đang phát triển')),
                  );
                },
              ),
              _SettingsItem(
                icon: Icons.palette,
                title: 'Giao diện',
                subtitle: 'Sáng',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng đang phát triển')),
                  );
                },
              ),
            ],
          ),

          // About
          _SettingsSection(
            title: 'Thông tin',
            items: [
              _SettingsItem(
                icon: Icons.info,
                title: 'Về ứng dụng',
                subtitle: 'Phiên bản 1.0.0',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Calendar App',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(
                      Icons.calendar_today,
                      size: 50,
                      color: Colors.deepPurple,
                    ),
                    children: [
                      const Text('Ứng dụng quản lý lịch cho Admin và User'),
                    ],
                  );
                },
              ),
              _SettingsItem(
                icon: Icons.help,
                title: 'Trợ giúp',
                subtitle: 'Hướng dẫn sử dụng',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng đang phát triển')),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
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
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: items
                .map(
                  (item) => Column(
                    children: [
                      item,
                      if (item != items.last)
                        const Divider(height: 1, indent: 56),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
