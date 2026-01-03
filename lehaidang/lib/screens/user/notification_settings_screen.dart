import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

/// Màn hình cài đặt thông báo
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _notificationsEnabled = false;
  List<dynamic> _pendingNotifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    setState(() => _isLoading = true);

    final hasPermission = await _notificationService.checkPermissions();
    final pending = await _notificationService.getPendingNotifications();

    setState(() {
      _notificationsEnabled = hasPermission;
      _pendingNotifications = pending;
      _isLoading = false;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      final granted = await _notificationService.requestPermissions();
      setState(() => _notificationsEnabled = granted);

      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Vui lòng cấp quyền thông báo trong cài đặt hệ thống',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      setState(() => _notificationsEnabled = false);
    }
  }

  Future<void> _testNotification() async {
    await _notificationService.showInstantNotification(
      title: 'Thông báo thử nghiệm',
      body: 'Đây là thông báo thử nghiệm từ ứng dụng Quản lý lịch!',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi thông báo thử nghiệm'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _clearAllNotifications() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text(
          'Bạn có chắc muốn hủy tất cả thông báo đã lên lịch?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _notificationService.cancelAllNotifications();
      await _loadNotificationSettings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy tất cả thông báo'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt thông báo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Permission Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _notificationsEnabled
                                  ? Icons.notifications_active
                                  : Icons.notifications_off,
                              color: _notificationsEnabled
                                  ? Colors.green
                                  : Colors.grey,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Trạng thái thông báo',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _notificationsEnabled
                                        ? 'Đã bật thông báo'
                                        : 'Chưa bật thông báo',
                                    style: TextStyle(
                                      color: _notificationsEnabled
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _notificationsEnabled,
                              onChanged: _toggleNotifications,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Bật thông báo để nhận nhắc nhở về các sự kiện sắp diễn ra.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Pending Notifications Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.schedule, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Thông báo đã lên lịch',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_pendingNotifications.length}',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_pendingNotifications.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.event_busy,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Không có thông báo nào đang chờ',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Column(
                            children: _pendingNotifications
                                .take(5)
                                .map(
                                  (notification) => ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    leading: const CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      radius: 16,
                                      child: Icon(
                                        Icons.event,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      notification.title?.toString() ??
                                          'Không có tiêu đề',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    subtitle: Text(
                                      notification.body?.toString() ?? '',
                                      style: const TextStyle(fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        if (_pendingNotifications.length > 5)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '... và ${_pendingNotifications.length - 5} thông báo khác',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Actions
                ElevatedButton.icon(
                  onPressed: _testNotification,
                  icon: const Icon(Icons.notifications_active),
                  label: const Text('Gửi thông báo thử nghiệm'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),

                const SizedBox(height: 12),

                if (_pendingNotifications.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: _clearAllNotifications,
                    icon: const Icon(Icons.clear_all, color: Colors.red),
                    label: const Text(
                      'Hủy tất cả thông báo đã lên lịch',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),

                const SizedBox(height: 24),

                // Info Card
                Card(
                  color: Colors.blue.shade50,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Thông tin',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Thông báo sẽ được gửi trước khi sự kiện diễn ra theo thời gian bạn đã cài đặt.\n\n'
                          '• Đảm bảo rằng ứng dụng có quyền gửi thông báo trong cài đặt hệ thống.\n\n'
                          '• Thông báo vẫn hoạt động ngay cả khi ứng dụng đã đóng.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
