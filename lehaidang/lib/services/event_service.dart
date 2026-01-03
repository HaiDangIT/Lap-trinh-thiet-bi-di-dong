import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';
import 'notification_service.dart';

class EventService extends ChangeNotifier {
  List<Event> _allEvents = [];
  final NotificationService _notificationService = NotificationService();

  List<Event> get allEvents => List.from(_allEvents);

  EventService() {
    _loadEvents();
  }

  // Load events from SharedPreferences
  Future<void> _loadEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString('events');

      if (eventsJson != null) {
        final List<dynamic> eventsList = json.decode(eventsJson);
        _allEvents = eventsList.map((e) => Event.fromMap(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading events: $e');
    }
  }

  // Save events to SharedPreferences
  Future<void> _saveEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = json.encode(_allEvents.map((e) => e.toMap()).toList());
      await prefs.setString('events', eventsJson);
    } catch (e) {
      debugPrint('Error saving events: $e');
    }
  }

  // Get events for a specific user (excluding hidden events for non-admins)
  List<Event> getUserEvents(String userId, {bool isAdmin = false}) {
    if (isAdmin) {
      return _allEvents.where((e) => e.userId == userId).toList();
    }
    return _allEvents.where((e) => e.userId == userId && !e.isHidden).toList();
  }

  // Get all events (admin only)
  List<Event> getAllEvents({bool includeHidden = true}) {
    if (!includeHidden) {
      return _allEvents.where((e) => !e.isHidden).toList();
    }
    return List.from(_allEvents);
  }

  // Get events for a specific date
  List<Event> getEventsForDate(
    DateTime date,
    String userId, {
    bool isAdmin = false,
  }) {
    final userEvents = getUserEvents(userId, isAdmin: isAdmin);
    return userEvents.where((e) => e.isOnDate(date)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // Add event
  Future<bool> addEvent(Event event) async {
    try {
      _allEvents.add(event);
      await _saveEvents();

      // Lên lịch thông báo nếu có reminder
      if (event.hasReminder) {
        await _notificationService.scheduleEventNotification(event);
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding event: $e');
      return false;
    }
  }

  // Update event
  Future<bool> updateEvent(Event event) async {
    try {
      final index = _allEvents.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _allEvents[index] = event;
        await _saveEvents();

        // Hủy thông báo cũ và tạo mới
        await _notificationService.cancelEventNotification(event.id);
        if (event.hasReminder) {
          await _notificationService.scheduleEventNotification(event);
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating event: $e');
      return false;
    }
  }

  // Delete event
  Future<bool> deleteEvent(String eventId) async {
    try {
      // Hủy thông báo trước khi xóa
      await _notificationService.cancelEventNotification(eventId);

      _allEvents.removeWhere((e) => e.id == eventId);
      await _saveEvents();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting event: $e');
      return false;
    }
  }

  // Toggle event visibility (admin only)
  Future<bool> toggleEventVisibility(String eventId) async {
    try {
      final index = _allEvents.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        _allEvents[index] = _allEvents[index].copyWith(
          isHidden: !_allEvents[index].isHidden,
        );
        await _saveEvents();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling event visibility: $e');
      return false;
    }
  }

  // Search events
  List<Event> searchEvents(
    String query,
    String userId, {
    bool isAdmin = false,
  }) {
    final userEvents = getUserEvents(userId, isAdmin: isAdmin);
    final lowerQuery = query.toLowerCase();

    return userEvents.where((e) {
      return e.title.toLowerCase().contains(lowerQuery) ||
          e.description.toLowerCase().contains(lowerQuery) ||
          (e.location?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  // Get upcoming events (next 7 days)
  List<Event> getUpcomingEvents(String userId, {bool isAdmin = false}) {
    final now = DateTime.now();
    final weekLater = now.add(const Duration(days: 7));
    final userEvents = getUserEvents(userId, isAdmin: isAdmin);

    return userEvents.where((e) {
      return e.startTime.isAfter(now) && e.startTime.isBefore(weekLater);
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // Get today's events count (for statistics)
  int getTodayEventsCount() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _allEvents.where((e) {
      return e.startTime.isAfter(today) && e.startTime.isBefore(tomorrow);
    }).length;
  }

  // Get this week's events count (for statistics)
  int getThisWeekEventsCount() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    return _allEvents.where((e) {
      return e.startTime.isAfter(weekStart) && e.startTime.isBefore(weekEnd);
    }).length;
  }
}
