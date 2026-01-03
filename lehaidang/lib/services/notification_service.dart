import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../models/event_model.dart';

/// Service quản lý thông báo cục bộ
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Khởi tạo service thông báo
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Khởi tạo timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    // Cấu hình Android
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // Cấu hình iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    debugPrint('✅ Notification Service initialized');
  }

  /// Xử lý khi người dùng nhấn vào thông báo
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Có thể điều hướng đến chi tiết sự kiện ở đây
  }

  /// Yêu cầu quyền thông báo
  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        // Android 13+ cần yêu cầu quyền thông báo
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }

    return true;
  }

  /// Lên lịch thông báo cho sự kiện
  Future<void> scheduleEventNotification(Event event) async {
    if (!event.hasReminder) return;

    await initialize();

    // Tính toán thời gian thông báo
    final notificationTime = event.startTime.subtract(
      Duration(minutes: event.reminderMinutesBefore),
    );

    // Kiểm tra nếu thời gian thông báo đã qua
    if (notificationTime.isBefore(DateTime.now())) {
      debugPrint('⚠️ Notification time has passed for event: ${event.title}');
      return;
    }

    final tzNotificationTime = tz.TZDateTime.from(notificationTime, tz.local);

    // Chi tiết thông báo cho Android
    final androidDetails = AndroidNotificationDetails(
      'event_reminders',
      'Nhắc nhở sự kiện',
      channelDescription: 'Thông báo nhắc nhở về các sự kiện sắp diễn ra',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      enableLights: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      color: event.color,
      styleInformation: BigTextStyleInformation(
        event.description.isNotEmpty
            ? event.description
            : 'Sự kiện sẽ bắt đầu trong ${event.reminderMinutesBefore} phút',
        contentTitle: event.title,
        summaryText: event.location ?? 'Quản lý lịch',
      ),
    );

    // Chi tiết thông báo cho iOS
    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      subtitle: event.location,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.zonedSchedule(
        event.id.hashCode, // ID duy nhất cho mỗi sự kiện
        event.title,
        event.description.isNotEmpty
            ? event.description
            : 'Sự kiện sẽ bắt đầu trong ${event.reminderMinutesBefore} phút',
        tzNotificationTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: event.id,
      );

      debugPrint(
        '✅ Scheduled notification for: ${event.title} at $tzNotificationTime',
      );
    } catch (e) {
      debugPrint('❌ Error scheduling notification: $e');
    }
  }

  /// Hủy thông báo của một sự kiện
  Future<void> cancelEventNotification(String eventId) async {
    await _notifications.cancel(eventId.hashCode);
    debugPrint('🔕 Cancelled notification for event: $eventId');
  }

  /// Hủy tất cả thông báo
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('🔕 Cancelled all notifications');
  }

  /// Hiển thị thông báo ngay lập tức (test)
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'instant_notifications',
      'Thông báo tức thì',
      channelDescription: 'Thông báo hiển thị ngay lập tức',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Lấy danh sách thông báo đang chờ
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Kiểm tra quyền thông báo
  Future<bool> checkPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.status;
      return status.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final status = await Permission.notification.status;
      return status.isGranted;
    }
    return true;
  }
}
