import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/sensor_data.dart';

/// FREE ML Service - Uses your Flask backend
class MLService {
  // Configuration - Platform-aware URL
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000'; // Web browser
    }
    // Android emulator needs special IP
    return 'http://10.0.2.2:5000'; // Android emulator
    // For iOS simulator or desktop, use: 'http://localhost:5000'
  }

  final Duration timeout = Duration(seconds: 30);

  /// Generic prediction method
  Future<Map<String, dynamic>> _predict(
      String endpoint,
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('ML API error: $e');
      rethrow;
    }
  }

  /// 1. Predict Locust Condition (Your existing model)
  Future<ConditionResult> predictCondition(SensorData data) async {
    final result = await _predict('predict/condition', {
      'temperature': data.temperature,
      'humidity': data.humidity,
      'food_level': data.foodLevel,
      'water_level': data.waterLevel,
      'colony_activity': data.colonyActivity,
      'timestamp': data.timestamp.toIso8601String(),
    });
    return ConditionResult.fromJson(result);
  }

  /// 2. Predict Future Humidity
  Future<HumidityResult> predictHumidity(SensorData data, List<SensorData> history) async {
    final result = await _predict('predict/humidity', {
      'current_data': data.toMap(),
      'history': history.take(10).map((d) => d.toMap()).toList(), // Last 10 readings
    });
    return HumidityResult.fromJson(result);
  }

  /// 3. Get Feeding Recommendations
  Future<FeedingResult> getFeedingRecommendation(SensorData data, String condition) async {
    final result = await _predict('predict/feeding', {
      'sensor_data': data.toMap(),
      'current_condition': condition,
      'time_of_day': DateTime.now().hour,
    });
    return FeedingResult.fromJson(result);
  }

  /// 4. Detect Anomalies
  Future<AnomalyResult> detectAnomaly(SensorData data, String condition) async {
    final result = await _predict('predict/anomaly', {
      'sensor_data': data.toMap(),
      'current_condition': condition,
      'historical_context': {}, // Add if you have historical patterns
    });
    return AnomalyResult.fromJson(result);
  }

  /// Check if backend is available
  Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Backend connection failed: $e');
      return false;
    }
  }
}

// Result Models (Keep yours, just adding toMap methods)
class ConditionResult {
  final String condition; // 'normal', 'hungry', 'stressed'
  final double confidence;
  final List<String> factors;
  final String recommendation;

  ConditionResult({
    required this.condition,
    required this.confidence,
    required this.factors,
    required this.recommendation,
  });

  factory ConditionResult.fromJson(Map<String, dynamic> json) {
    return ConditionResult(
      condition: json['condition'] ?? 'normal',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      factors: List<String>.from(json['factors'] ?? []),
      recommendation: json['recommendation'] ?? 'No specific recommendations',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'condition': condition,
      'confidence': confidence,
      'factors': factors,
      'recommendation': recommendation,
    };
  }
}

class HumidityResult {
  final double predictedHumidity;
  final double confidence;
  final String trend; // 'increasing', 'decreasing', 'stable'
  final bool adjustmentNeeded;

  HumidityResult({
    required this.predictedHumidity,
    required this.confidence,
    required this.trend,
    required this.adjustmentNeeded,
  });

  factory HumidityResult.fromJson(Map<String, dynamic> json) {
    return HumidityResult(
      predictedHumidity: (json['predicted_humidity'] ?? 0.0).toDouble(),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      trend: json['trend'] ?? 'stable',
      adjustmentNeeded: json['adjustment_needed'] ?? false,
    );
  }
}

class FeedingResult {
  final double amount; // in grams
  final double urgency; // 0.0 to 1.0
  final String schedule; // 'immediate', 'next_hour', 'scheduled'
  final List<String> recommendations;

  FeedingResult({
    required this.amount,
    required this.urgency,
    required this.schedule,
    required this.recommendations,
  });

  factory FeedingResult.fromJson(Map<String, dynamic> json) {
    return FeedingResult(
      amount: (json['amount'] ?? 50.0).toDouble(),
      urgency: (json['urgency'] ?? 0.5).toDouble(),
      schedule: json['schedule'] ?? 'scheduled',
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}

class AnomalyResult {
  final bool isAnomaly;
  final double anomalyScore;
  final String severity; // 'low', 'medium', 'high', 'critical'
  final List<String> detectedIssues;
  final String recommendedAction;

  AnomalyResult({
    required this.isAnomaly,
    required this.anomalyScore,
    required this.severity,
    required this.detectedIssues,
    required this.recommendedAction,
  });

  factory AnomalyResult.fromJson(Map<String, dynamic> json) {
    return AnomalyResult(
      isAnomaly: json['is_anomaly'] ?? false,
      anomalyScore: (json['anomaly_score'] ?? 0.0).toDouble(),
      severity: json['severity'] ?? 'low',
      detectedIssues: List<String>.from(json['detected_issues'] ?? []),
      recommendedAction: json['recommended_action'] ?? 'No action needed',
    );
  }
}