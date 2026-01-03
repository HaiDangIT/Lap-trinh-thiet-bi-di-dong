import 'package:flutter/material.dart';

class Event {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
  final bool hasReminder;
  final int reminderMinutesBefore;
  final bool isHidden; // For admin to hide events
  final DateTime createdAt;
  final String? location;
  final List<String> participants;

  Event({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    this.color = Colors.blue,
    this.hasReminder = false,
    this.reminderMinutesBefore = 15,
    this.isHidden = false,
    DateTime? createdAt,
    this.location,
    this.participants = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert Event to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'color': color.toARGB32(),
      'hasReminder': hasReminder,
      'reminderMinutesBefore': reminderMinutesBefore,
      'isHidden': isHidden,
      'createdAt': createdAt.toIso8601String(),
      'location': location,
      'participants': participants,
    };
  }

  // Create Event from Map
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      color: Color(map['color'] ?? Colors.blue.toARGB32()),
      hasReminder: map['hasReminder'] ?? false,
      reminderMinutesBefore: map['reminderMinutesBefore'] ?? 15,
      isHidden: map['isHidden'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      location: map['location'],
      participants: List<String>.from(map['participants'] ?? []),
    );
  }

  Event copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    Color? color,
    bool? hasReminder,
    int? reminderMinutesBefore,
    bool? isHidden,
    DateTime? createdAt,
    String? location,
    List<String>? participants,
  }) {
    return Event(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      isHidden: isHidden ?? this.isHidden,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      participants: participants ?? this.participants,
    );
  }

  bool isOnDate(DateTime date) {
    final eventDate = DateTime(startTime.year, startTime.month, startTime.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return eventDate == checkDate;
  }
}
