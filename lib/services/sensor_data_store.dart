import 'dart:async';
import '../models/sensor_data.dart';

/// Service to store and retrieve simulated sensor data
class SensorDataStore {
  static final SensorDataStore _instance = SensorDataStore._internal();
  factory SensorDataStore() => _instance;
  SensorDataStore._internal();

  SensorData? _lastSimulatedData;
  final StreamController<SensorData> _controller = StreamController<SensorData>.broadcast();

  Stream<SensorData> get stream => _controller.stream;

  /// Store simulated sensor data
  void setSimulatedData(SensorData data) {
    _lastSimulatedData = data;
    _controller.add(data);
  }

  /// Get last simulated data
  SensorData? getLastSimulatedData() => _lastSimulatedData;

  /// Convert to environmental data map format
  Map<String, dynamic>? toEnvironmentalMap() {
    if (_lastSimulatedData == null) return null;
    
    return {
      'temperature': _lastSimulatedData!.temperature,
      'humidity': _lastSimulatedData!.humidity,
      'feedLevel': _lastSimulatedData!.foodLevel,
      'waterLevel': _lastSimulatedData!.waterLevel,
      'activityIndex': _lastSimulatedData!.colonyActivity / 100.0,
      'timestamp': _lastSimulatedData!.timestamp.toIso8601String(),
    };
  }

  void dispose() {
    _controller.close();
  }
}

