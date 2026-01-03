import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Configuration
/// Chứa tất cả các cấu hình liên quan đến API endpoints (24 endpoints)
class ApiConfig {
  // Base URL từ .env file
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';

  // =============================================================================
  // 🏥 HEALTH & SYSTEM ENDPOINTS (3)
  // =============================================================================
  static const String rootEndpoint = '/';
  static const String apiInfoEndpoint = '/api';
  static const String healthEndpoint = '/api/health';

  // =============================================================================
  // 👤 USER MANAGEMENT ENDPOINTS (7)
  // =============================================================================
  static const String usersEndpoint = '/api/users';
  static const String registerEndpoint = '/api/users/register';
  static const String loginEndpoint = '/api/users/login';
  static const String userProfileEndpoint = '/api/users/me';
  // GET /api/users - Danh sách users (usersEndpoint)
  // GET /api/users/:id - Chi tiết user (usersEndpoint/:id)
  // PUT /api/users/:id - Cập nhật user (usersEndpoint/:id)
  // DELETE /api/users/:id - Xóa user (usersEndpoint/:id)

  // =============================================================================
  // 🔐 TWO-FACTOR AUTHENTICATION ENDPOINTS (5)
  // =============================================================================
  static const String twoFactorSetupEndpoint = '/api/2fa/setup';
  static const String twoFactorEnableEndpoint = '/api/2fa/enable';
  static const String twoFactorVerifyEndpoint = '/api/2fa/verify';
  static const String twoFactorStatusEndpoint = '/api/2fa/status';
  static const String twoFactorDisableEndpoint = '/api/2fa/disable';

  // =============================================================================
  // 📅 CALENDAR MANAGEMENT ENDPOINTS (6)
  // =============================================================================
  static const String calendarsEndpoint = '/api/calendars';
  // POST /api/calendars - Tạo calendar (calendarsEndpoint)
  // GET /api/calendars - Danh sách calendars (calendarsEndpoint)
  // GET /api/calendars/:id - Chi tiết calendar (calendarsEndpoint/:id)
  // PUT /api/calendars/:id - Cập nhật calendar (calendarsEndpoint/:id)
  // DELETE /api/calendars/:id - Xóa calendar (calendarsEndpoint/:id)
  // POST /api/calendars/:id/primary - Đặt làm calendar chính

  // =============================================================================
  // 📆 EVENT MANAGEMENT ENDPOINTS (8)
  // =============================================================================
  static const String eventsEndpoint = '/api/events';
  static const String eventRangeEndpoint = '/api/events/range';
  static const String eventSearchEndpoint = '/api/events/search';
  static const String eventUpcomingEndpoint = '/api/events/upcoming';
  // POST /api/events - Tạo event (eventsEndpoint)
  // GET /api/events/:id - Chi tiết event (eventsEndpoint/:id)
  // PUT /api/events/:id - Cập nhật event (eventsEndpoint/:id)
  // DELETE /api/events/:id - Xóa event (eventsEndpoint/:id)
  // POST /api/events/:id/exceptions - Tạo exception cho recurring event

  // =============================================================================
  // API TIMEOUTS
  // =============================================================================
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // =============================================================================
  // HEADERS
  // =============================================================================
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String userId) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $userId',
  };

  // =============================================================================
  // ENVIRONMENT & DEFAULT CREDENTIALS
  // =============================================================================
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';

  // ADMIN (16 permissions)
  static String get adminEmail =>
      dotenv.env['ADMIN_EMAIL'] ?? 'admin@example.com';
  static String get adminPassword => dotenv.env['ADMIN_PASSWORD'] ?? 'admin123';

  // MANAGER (9 permissions)
  static String get managerEmail =>
      dotenv.env['MANAGER_EMAIL'] ?? 'manager@example.com';
  static String get managerPassword =>
      dotenv.env['MANAGER_PASSWORD'] ?? 'manager123';

  // USER (5 permissions)
  static String get userEmail => dotenv.env['USER_EMAIL'] ?? 'user@example.com';
  static String get userPassword => dotenv.env['USER_PASSWORD'] ?? 'user123';
}

/// App Configuration
/// Cấu hình chung cho toàn bộ ứng dụng
class AppConfig {
  // App Information
  static const String appName = 'Quản Lý Lịch';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Local Storage Keys
  static const String userTokenKey = 'user_token';
  static const String currentUserIdKey = 'currentUserId';
  static const String usersKey = 'users';
  static const String eventsKey = 'events';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Date & Time Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

  // Validation Rules
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 2;
  static const int maxUsernameLength = 50;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;

  // Calendar Settings
  static const int upcomingEventsDays = 7;
  static const int reminderMinutesMin = 5;
  static const int reminderMinutesMax = 60;
  static const int reminderMinutesDefault = 15;

  // Cache Settings
  static const Duration cacheExpiration = Duration(hours: 24);
  static const Duration tokenRefreshInterval = Duration(hours: 1);

  // Image & File Settings
  static const int maxImageSizeMB = 5;
  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
  ];

  // Debug Mode
  static const bool isDebugMode = true;
  static const bool enableLogging = true;

  // =============================================================================
  // USER ROLES & PERMISSIONS
  // =============================================================================

  // ADMIN (16 permissions)
  static const List<String> adminPermissions = [
    'user:read',
    'user:write',
    'user:delete',
    'calendar:read',
    'calendar:write',
    'calendar:delete',
    'event:read',
    'event:write',
    'event:delete',
    'recurring-event:read',
    'recurring-event:write',
    'recurring-event:delete',
    'system:admin',
    'system:manage-users',
    'system:view-logs',
    'system:config',
  ];

  // MANAGER (9 permissions)
  static const List<String> managerPermissions = [
    'user:read',
    'calendar:read',
    'calendar:write',
    'event:read',
    'event:write',
    'event:delete',
    'recurring-event:read',
    'recurring-event:write',
    'system:manage-users',
  ];

  // USER (5 permissions)
  static const List<String> userPermissions = [
    'calendar:read',
    'event:read',
    'event:write',
    'recurring-event:read',
    'recurring-event:write',
  ];
}

/// Error Messages
class ErrorMessages {
  static const String networkError =
      'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';
  static const String serverError = 'Lỗi server. Vui lòng thử lại sau.';
  static const String unauthorized =
      'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
  static const String forbidden = 'Bạn không có quyền thực hiện hành động này.';
  static const String notFound = 'Không tìm thấy dữ liệu.';
  static const String badRequest = 'Yêu cầu không hợp lệ.';
  static const String invalidCredentials = 'Email hoặc mật khẩu không đúng.';
  static const String emailAlreadyExists = 'Email đã tồn tại trong hệ thống.';
  static const String invalidEmail = 'Email không hợp lệ.';
  static const String passwordTooShort =
      'Mật khẩu phải có ít nhất ${AppConfig.minPasswordLength} ký tự.';
  static const String fieldRequired = 'Trường này là bắt buộc.';
  static const String invalidDateRange =
      'Thời gian kết thúc phải sau thời gian bắt đầu.';
  static const String deleteConfirmation = 'Bạn có chắc muốn xóa?';
  static const String unknown = 'Đã xảy ra lỗi không xác định.';
}

/// Success Messages
class SuccessMessages {
  static const String loginSuccess = 'Đăng nhập thành công!';
  static const String registerSuccess = 'Đăng ký thành công!';
  static const String logoutSuccess = 'Đăng xuất thành công!';
  static const String createEventSuccess = 'Tạo sự kiện thành công!';
  static const String updateEventSuccess = 'Cập nhật sự kiện thành công!';
  static const String deleteEventSuccess = 'Xóa sự kiện thành công!';
  static const String createCalendarSuccess = 'Tạo calendar thành công!';
  static const String updateCalendarSuccess = 'Cập nhật calendar thành công!';
  static const String deleteCalendarSuccess = 'Xóa calendar thành công!';
  static const String createUserSuccess = 'Tạo người dùng thành công!';
  static const String updateUserSuccess = 'Cập nhật người dùng thành công!';
  static const String deleteUserSuccess = 'Xóa người dùng thành công!';
  static const String saveSuccess = 'Lưu thành công!';
}
