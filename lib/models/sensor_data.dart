import 'dart:convert';
class SensorData {
  final double temperature;
  final double humidity;
  final double foodLevel;
  final double waterLevel;
  final int colonyActivity;
  final DateTime timestamp;

  // Add the missing ML prediction fields
  final double? predictedHumidity;
  final double? feedingRecommendation;
  final double? anomalyScore;
  final String? condition;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.foodLevel,
    required this.waterLevel,
    required this.colonyActivity,
    required this.timestamp,
    this.predictedHumidity,
    this.feedingRecommendation,
    this.anomalyScore,
    this.condition,
  });

  // Convert to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'foodLevel': foodLevel,
      'waterLevel': waterLevel,
      'colonyActivity': colonyActivity,
      'timestamp': timestamp.toIso8601String(), // Convert DateTime to string
      'predictedHumidity': predictedHumidity,
      'feedingRecommendation': feedingRecommendation,
      'anomalyScore': anomalyScore,
      'condition': condition,
    };
  }

  // Convert to JSON for API calls
  String toJson() => jsonEncode(toMap());

  factory SensorData.fromMap(Map<String, dynamic> map) {
    return SensorData(
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (map['humidity'] as num?)?.toDouble() ?? 0.0,
      foodLevel: (map['foodLevel'] as num?)?.toDouble() ?? 0.0,
      waterLevel: (map['waterLevel'] as num?)?.toDouble() ?? 0.0,
      colonyActivity: (map['colonyActivity'] as int?) ?? 0,
      timestamp: map['timestamp'] is DateTime
          ? map['timestamp'] as DateTime
          : DateTime.parse(map['timestamp'].toString()),
      predictedHumidity: (map['predictedHumidity'] as num?)?.toDouble(),
      feedingRecommendation: (map['feedingRecommendation'] as num?)?.toDouble(),
      anomalyScore: (map['anomalyScore'] as num?)?.toDouble(),
      condition: map['condition'] as String?,
    );
  }

  // Create mock data for testing
  factory SensorData.mock() {
    return SensorData(
      temperature: 28.5,
      humidity: 65.0,
      foodLevel: 45.0,
      waterLevel: 70.0,
      colonyActivity: 75,
      timestamp: DateTime.now(),
      predictedHumidity: 62.0,
      feedingRecommendation: 50.0,
      anomalyScore: 0.1,
      condition: 'normal',
    );
  }

  // Create from ML prediction results
  factory SensorData.withPredictions({
    required SensorData original,
    required double predictedHumidity,
    required double feedingRecommendation,
    required double anomalyScore,
    required String condition,
  }) {
    return SensorData(
      temperature: original.temperature,
      humidity: original.humidity,
      foodLevel: original.foodLevel,
      waterLevel: original.waterLevel,
      colonyActivity: original.colonyActivity,
      timestamp: original.timestamp,
      predictedHumidity: predictedHumidity,
      feedingRecommendation: feedingRecommendation,
      anomalyScore: anomalyScore,
      condition: condition,
    );
  }
}