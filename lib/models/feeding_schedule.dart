import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Add this import for listEquals

class FeedingSchedule {
  final String id;
  final String name;
  final TimeOfDay time;
  final double foodAmount;
  final bool isActive;
  final List<int> days;

  FeedingSchedule({
    required this.id,
    required this.name,
    required this.time,
    required this.foodAmount,
    required this.isActive,
    required this.days,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'hour': time.hour,
      'minute': time.minute,
      'foodAmount': foodAmount,
      'isActive': isActive,
      'days': days,
    };
  }

  factory FeedingSchedule.fromMap(Map<String, dynamic> map) {
    return FeedingSchedule(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      time: TimeOfDay(
        hour: map['hour']?.toInt() ?? 0,
        minute: map['minute']?.toInt() ?? 0,
      ),
      foodAmount: map['foodAmount']?.toDouble() ?? 0.0,
      isActive: map['isActive'] ?? false,
      days: _convertDaysToListInt(map['days']),
    );
  }

  // Helper method to convert days to List<int>
  static List<int> _convertDaysToListInt(dynamic daysData) {
    if (daysData == null) return [];

    if (daysData is List<int>) {
      return daysData;
    } else if (daysData is List<String>) {
      // Convert List<String> to List<int>
      return daysData.map((day) => int.tryParse(day) ?? -1).where((day) => day != -1).toList();
    } else if (daysData is List<dynamic>) {
      // Convert List<dynamic> to List<int>
      return daysData.map((day) {
        if (day is int) return day;
        if (day is String) return int.tryParse(day) ?? -1;
        if (day is num) return day.toInt();
        return -1;
      }).where((day) => day != -1).toList();
    }

    return [];
  }

  // Create mock data for testing
  factory FeedingSchedule.mock() {
    return FeedingSchedule(
      id: 'mock_1',
      name: 'Morning Feeding',
      time: const TimeOfDay(hour: 8, minute: 0),
      foodAmount: 50.0,
      isActive: true,
      days: [1, 3, 5], // Monday, Wednesday, Friday
    );
  }

  // Helper method to get time as DateTime (today with the schedule time)
  DateTime getTimeAsDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  // Check if schedule is active for today
  bool isActiveToday() {
    if (!isActive) return false;
    final today = DateTime.now().weekday;
    // DateTime.weekday returns 1-7 (Monday=1, Sunday=7)
    return days.contains(today);
  }

  // Get formatted time string
  String getFormattedTime() {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Alternative formatted time method without context
  String getFormattedTime12Hour() {
    final period = time.hour < 12 ? 'AM' : 'PM';
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  // Get days as readable string
  String getDaysString() {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayStrings = days.map((day) {
      if (day >= 1 && day <= 7) {
        return dayNames[day - 1];
      }
      return 'Invalid';
    }).where((day) => day != 'Invalid').toList();

    return dayStrings.join(', ');
  }

  @override
  String toString() {
    return 'FeedingSchedule(id: $id, name: $name, time: ${time.hour}:${time.minute.toString().padLeft(2, '0')}, foodAmount: $foodAmount, isActive: $isActive, days: $days)';
  }

  // Copy with method for immutability
  FeedingSchedule copyWith({
    String? id,
    String? name,
    TimeOfDay? time,
    double? foodAmount,
    bool? isActive,
    List<int>? days,
  }) {
    return FeedingSchedule(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      foodAmount: foodAmount ?? this.foodAmount,
      isActive: isActive ?? this.isActive,
      days: days ?? this.days,
    );
  }

  // Equality check
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeedingSchedule &&
        other.id == id &&
        other.name == name &&
        other.time.hour == time.hour &&
        other.time.minute == time.minute &&
        other.foodAmount == foodAmount &&
        other.isActive == isActive &&
        listEquals(other.days, days); // Now listEquals is available
  }

  @override
  int get hashCode {
    return Object.hash(id, name, time.hour, time.minute, foodAmount, isActive, Object.hashAll(days));
  }
}