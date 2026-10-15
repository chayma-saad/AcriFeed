import 'package:flutter/foundation.dart';
import 'smart_alert.dart';

class RealtimeSnapshot {
  final double temperature;
  final double humidity;
  final double foodLevel;
  final double waterLevel;
  final double activityIndex;
  final Map<String, dynamic>? prediction;
  final DateTime timestamp;
  final List<SmartAlert> alerts;
  final String? error;

  const RealtimeSnapshot({
    required this.temperature,
    required this.humidity,
    required this.foodLevel,
    required this.waterLevel,
    required this.activityIndex,
    required this.timestamp,
    required this.alerts,
    this.prediction,
    this.error,
  });

  factory RealtimeSnapshot.fromApi({
    required Map<String, dynamic> environmentalData,
    Map<String, dynamic>? prediction,
    required DateTime generatedAt,
    required List<SmartAlert> alerts,
    String? error,
  }) {
    double toDoubleSafe(dynamic value, double fallback) {
      if (value == null) return fallback;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? fallback;
    }

    return RealtimeSnapshot(
      temperature: toDoubleSafe(environmentalData['temperature'], 0),
      humidity: toDoubleSafe(environmentalData['humidity'], 0),
      foodLevel: toDoubleSafe(environmentalData['feedLevel'], 0),
      waterLevel: toDoubleSafe(environmentalData['waterLevel'], 0),
      activityIndex: toDoubleSafe(environmentalData['activityIndex'], 0).clamp(0.0, 1.0),
      prediction: prediction,
      timestamp: generatedAt,
      alerts: alerts,
      error: error,
    );
  }

  Map<String, dynamic> toEnvironmentalMap() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'feedLevel': foodLevel,
      'waterLevel': waterLevel,
      'activityIndex': activityIndex,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get hasCriticalAlert => alerts.any((alert) => alert.isCritical);

  RealtimeSnapshot copyWith({
    double? temperature,
    double? humidity,
    double? foodLevel,
    double? waterLevel,
    double? activityIndex,
    Map<String, dynamic>? prediction,
    DateTime? timestamp,
    List<SmartAlert>? alerts,
    String? error,
  }) {
    return RealtimeSnapshot(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      foodLevel: foodLevel ?? this.foodLevel,
      waterLevel: waterLevel ?? this.waterLevel,
      activityIndex: activityIndex ?? this.activityIndex,
      prediction: prediction ?? this.prediction,
      timestamp: timestamp ?? this.timestamp,
      alerts: alerts ?? List<SmartAlert>.from(this.alerts),
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'RealtimeSnapshot(temp: $temperature, humidity: $humidity, food: $foodLevel, water: $waterLevel, activity: $activityIndex, alerts: ${alerts.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RealtimeSnapshot &&
        other.temperature == temperature &&
        other.humidity == humidity &&
        other.foodLevel == foodLevel &&
        other.waterLevel == waterLevel &&
        other.activityIndex == activityIndex &&
        mapEquals(other.prediction, prediction) &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(
      temperature,
      humidity,
      foodLevel,
      waterLevel,
      activityIndex,
      prediction,
      timestamp,
    );
  }
}

