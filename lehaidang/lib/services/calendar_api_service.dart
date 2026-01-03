import '../../config/app_config.dart';
import 'api/base_api_service.dart';

/// Calendar API Service
/// Service để xử lý các API liên quan đến calendars theo API_ENDPOINTS.md
class CalendarApiService extends BaseApiService {
  /// Create Calendar
  /// POST /api/calendars
  Future<Map<String, dynamic>> createCalendar(
    String userId,
    Map<String, dynamic> calendarData,
  ) async {
    try {
      final response = await post(
        ApiConfig.calendarsEndpoint,
        body: calendarData,
        headers: ApiConfig.authHeaders(userId),
      );
      return response['data'];
    } catch (e) {
      rethrow;
    }
  }

  /// Get All Calendars
  /// GET /api/calendars
  Future<List<Map<String, dynamic>>> getAllCalendars(String userId) async {
    try {
      final response = await get(
        ApiConfig.calendarsEndpoint,
        headers: ApiConfig.authHeaders(userId),
      );
      return List<Map<String, dynamic>>.from(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Get Calendar by ID
  /// GET /api/calendars/:id
  Future<Map<String, dynamic>> getCalendarById(
    String userId,
    String calendarId,
  ) async {
    try {
      final response = await get(
        '${ApiConfig.calendarsEndpoint}/$calendarId',
        headers: ApiConfig.authHeaders(userId),
      );
      return response['data'];
    } catch (e) {
      rethrow;
    }
  }

  /// Update Calendar
  /// PUT /api/calendars/:id
  Future<Map<String, dynamic>> updateCalendar(
    String userId,
    String calendarId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await put(
        '${ApiConfig.calendarsEndpoint}/$calendarId',
        body: updates,
        headers: ApiConfig.authHeaders(userId),
      );
      return response['data'];
    } catch (e) {
      rethrow;
    }
  }

  /// Delete Calendar
  /// DELETE /api/calendars/:id
  Future<void> deleteCalendar(String userId, String calendarId) async {
    try {
      await delete(
        '${ApiConfig.calendarsEndpoint}/$calendarId',
        headers: ApiConfig.authHeaders(userId),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Set Calendar as Primary
  /// POST /api/calendars/:id/primary
  Future<Map<String, dynamic>> setPrimaryCalendar(
    String userId,
    String calendarId,
  ) async {
    try {
      final response = await post(
        '${ApiConfig.calendarsEndpoint}/$calendarId/primary',
        headers: ApiConfig.authHeaders(userId),
      );
      return response['data'];
    } catch (e) {
      rethrow;
    }
  }
}
