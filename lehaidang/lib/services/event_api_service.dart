import '../../config/app_config.dart';
import '../models/event_model.dart';
import 'api/base_api_service.dart';

/// Event API Service
/// Service để xử lý các API liên quan đến events theo API_ENDPOINTS.md
class EventApiService extends BaseApiService {
  /// Get Events in Date Range
  /// GET /api/events/range?startTime=...&endTime=...&calendarId=...
  Future<List<Event>> getEventsInRange(
    String userId, {
    required DateTime startTime,
    required DateTime endTime,
    String? calendarId,
  }) async {
    try {
      final response = await get(
        ApiConfig.eventRangeEndpoint,
        queryParameters: {
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          if (calendarId != null) 'calendarId': calendarId,
        },
        headers: ApiConfig.authHeaders(userId),
      );
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Event.fromMap(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get Upcoming Events
  /// GET /api/events/upcoming
  Future<List<Event>> getUpcomingEvents(String userId) async {
    try {
      final response = await get(
        ApiConfig.eventUpcomingEndpoint,
        headers: ApiConfig.authHeaders(userId),
      );
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Event.fromMap(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Search Events
  /// GET /api/events/search?q=...
  Future<List<Event>> searchEvents({
    required String userId,
    required String query,
  }) async {
    try {
      final response = await get(
        ApiConfig.eventSearchEndpoint,
        queryParameters: {'q': query},
        headers: ApiConfig.authHeaders(userId),
      );
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Event.fromMap(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get Event by ID
  /// GET /api/events/:id
  Future<Event> getEventById(String userId, String eventId) async {
    try {
      final response = await get(
        '${ApiConfig.eventsEndpoint}/$eventId',
        headers: ApiConfig.authHeaders(userId),
      );
      return Event.fromMap(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Create Event
  /// POST /api/events
  Future<Event> createEvent(
    String userId,
    Map<String, dynamic> eventData,
  ) async {
    try {
      final response = await post(
        ApiConfig.eventsEndpoint,
        body: eventData,
        headers: ApiConfig.authHeaders(userId),
      );
      return Event.fromMap(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Update Event
  /// PUT /api/events/:id
  Future<Event> updateEvent(
    String userId,
    String eventId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await put(
        '${ApiConfig.eventsEndpoint}/$eventId',
        body: updates,
        headers: ApiConfig.authHeaders(userId),
      );
      return Event.fromMap(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete Event
  /// DELETE /api/events/:id
  Future<void> deleteEvent(String userId, String eventId) async {
    try {
      await delete(
        '${ApiConfig.eventsEndpoint}/$eventId',
        headers: ApiConfig.authHeaders(userId),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Create Event Exception (for recurring events)
  /// POST /api/events/:id/exceptions
  Future<Map<String, dynamic>> createEventException(
    String userId,
    String eventId,
    Map<String, dynamic> exceptionData,
  ) async {
    try {
      final response = await post(
        '${ApiConfig.eventsEndpoint}/$eventId/exceptions',
        body: exceptionData,
        headers: ApiConfig.authHeaders(userId),
      );
      return response['data'];
    } catch (e) {
      rethrow;
    }
  }
}
