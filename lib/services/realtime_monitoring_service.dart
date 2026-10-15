import 'dart:async';
import 'dart:math';

import '../models/realtime_snapshot.dart';
import '../models/smart_alert.dart';
import 'api_service.dart';
import 'sensor_data_store.dart';

class RealtimeMonitoringService {
  final ApiService _apiService;
  final Duration pollInterval;
  final StreamController<RealtimeSnapshot> _controller = StreamController.broadcast();
  final Random _random = Random();

  Timer? _timer;
  Map<String, dynamic>? _lastEnvironmentalData;
  Map<String, dynamic>? _lastPrediction;
  final SensorDataStore _sensorStore = SensorDataStore();
  StreamSubscription? _sensorSubscription;
  int _lastErrorLogTime = 0;
  
  // Track previous values to detect threshold crossings
  double? _lastTemp;
  double? _lastHumidity;
  double? _lastFood;
  double? _lastWater;
  double? _lastActivity;
  String? _lastCondition;
  
  // Track active alerts to prevent duplicates
  final Set<String> _activeAlertIds = {};

  RealtimeMonitoringService({
    ApiService? apiService,
    this.pollInterval = const Duration(seconds: 12),
  }) : _apiService = apiService ?? ApiService();

  Stream<RealtimeSnapshot> get stream => _controller.stream;

  void start() {
    if (_timer != null) return;
    
    // Listen to simulated sensor data
    _sensorSubscription = _sensorStore.stream.listen((sensorData) {
      final envMap = _sensorStore.toEnvironmentalMap();
      if (envMap != null) {
        _lastEnvironmentalData = envMap;
        _emitSnapshot(envMap, _lastPrediction);
      }
    });
    
    _fetchAndEmit();
    _timer = Timer.periodic(pollInterval, (_) => _fetchAndEmit());
  }

  Future<void> refreshNow() async {
    await _fetchAndEmit(force: true);
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> dispose() async {
    stop();
    _sensorSubscription?.cancel();
    await _controller.close();
  }

  Future<void> _fetchAndEmit({bool force = false}) async {
    // Check for simulated data first
    final simulatedEnv = _sensorStore.toEnvironmentalMap();
    if (simulatedEnv != null) {
      _lastEnvironmentalData = simulatedEnv;
      try {
        final prediction = await _apiService.getLatestPrediction();
        _lastPrediction = prediction;
        _emitSnapshot(simulatedEnv, prediction);
        return;
      } catch (e) {
        // Use fallback prediction if API fails
        _emitSnapshot(simulatedEnv, _lastPrediction ?? _generateFallbackPrediction());
        return;
      }
    }

    // Otherwise try API
    try {
      final environmentalData = await _apiService.getLatestEnvironmentalData();
      final prediction = await _apiService.getLatestPrediction();
      _lastEnvironmentalData = environmentalData;
      _lastPrediction = prediction;
      _emitSnapshot(environmentalData, prediction);
    } catch (e) {
      if (!force && _lastEnvironmentalData != null) {
        _emitSnapshot(_lastEnvironmentalData!, _lastPrediction, error: e.toString());
        return;
      }
      final fallbackEnv = _generateFallbackEnvironment();
      final fallbackPrediction = _lastPrediction ?? _generateFallbackPrediction();
      _lastEnvironmentalData = fallbackEnv;
      _lastPrediction = fallbackPrediction;
      _emitSnapshot(fallbackEnv, fallbackPrediction, error: e.toString());
    }
  }

  void _emitSnapshot(
    Map<String, dynamic> environmentalData,
    Map<String, dynamic>? prediction, {
    String? error,
  }) {
    final alerts = _buildAlerts(environmentalData, prediction);

    final snapshot = RealtimeSnapshot.fromApi(
      environmentalData: environmentalData,
      prediction: prediction,
      generatedAt: DateTime.now(),
      alerts: alerts,
      error: error,
    );
    _controller.add(snapshot);

    // Save environmental data to database periodically (every 5 minutes)
    _saveEnvironmentalDataIfNeeded(environmentalData, prediction);
  }

  DateTime? _lastDataSaveTime;
  Future<void> _saveEnvironmentalDataIfNeeded(
    Map<String, dynamic> environmentalData,
    Map<String, dynamic>? prediction
  ) async {
    final now = DateTime.now();
    // Save data every 5 minutes to avoid overwhelming the database
    if (_lastDataSaveTime == null || now.difference(_lastDataSaveTime!) > const Duration(minutes: 5)) {
      try {
        // Save basic environmental data
        await _apiService.saveEnvironmentalData({
          'temperature': environmentalData['temperature'],
          'humidity': environmentalData['humidity'],
          'lightLevel': environmentalData['lightLevel'] ?? 75.0,
          'activityIndex': environmentalData['activityIndex'] ?? 0.5,
          'feedLevel': environmentalData['feedLevel'] ?? 50.0,
        });

        // Save detailed sensor data including condition
        await _apiService.saveSensorData({
          'temperature': environmentalData['temperature'],
          'humidity': environmentalData['humidity'],
          'foodLevel': environmentalData['feedLevel'] ?? 50.0,
          'waterLevel': environmentalData['waterLevel'] ?? 60.0,
          'colonyActivity': ((environmentalData['activityIndex'] ?? 0.5) * 100).round(),
          'conditionStatus': prediction?['conditionType'] ?? prediction?['condition'] ?? 'normal',
          'timestamp': now.toIso8601String(),
        });

        _lastDataSaveTime = now;
        print('✅ Live sensor data and condition saved to database');
      } catch (e) {
        // Only log database errors occasionally to avoid spam
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        if (currentTime - _lastErrorLogTime > 30000) { // Log every 30 seconds max
          print('❌ Failed to save live sensor data: $e');
          _lastErrorLogTime = currentTime;
        }
        // Don't update _lastDataSaveTime on failure, so we retry next time
      }
    }
  }

  Map<String, dynamic> _generateFallbackEnvironment() {
    double jitter(double base, double variance, {double min = 0, double max = 100}) {
      final value = base + (_random.nextDouble() * variance * 2) - variance;
      return value.clamp(min, max);
    }

    return {
      'temperature': jitter(28, 2, min: 20, max: 38),
      'humidity': jitter(62, 8, min: 30, max: 90),
      'feedLevel': jitter(65, 15).clamp(0, 100),
      'waterLevel': jitter(72, 12).clamp(0, 100),
      'activityIndex': (_random.nextDouble() * 0.4) + 0.4,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _generateFallbackPrediction() {
    return {
      'conditionType': 'normal',
      'confidence': 0.82,
      'recommendedAction': 'Continue monitoring – colony is stable.',
      'explanation': 'All vitals within expected bands.',
    };
  }

  List<SmartAlert> _buildAlerts(
    Map<String, dynamic> environmentalData,
    Map<String, dynamic>? prediction,
  ) {
    final alerts = <SmartAlert>[];
    double parse(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    final temp = parse(environmentalData['temperature']);
    final humidity = parse(environmentalData['humidity']);
    final food = parse(environmentalData['feedLevel']);
    final water = parse(environmentalData['waterLevel']);
    // Activity index is 0.0-1.0, convert to percentage for display
    final activityRaw = parse(environmentalData['activityIndex']);
    final activity = activityRaw > 1.0 ? activityRaw : activityRaw * 100; // Handle both formats
    final condition = (prediction?['conditionType'] ?? prediction?['condition'] ?? 'normal')
        .toString()
        .toLowerCase();

    // Food Level Alerts - Only alert when crossing thresholds or if already below threshold
    if (food <= 25) {
      final wasAboveThreshold = _lastFood == null || _lastFood! > 25;
      final isCritical = food <= 10;
      final wasCritical = _lastFood != null && _lastFood! <= 10;
      
      // Alert if: crossing threshold OR already below threshold but severity changed OR first time
      if (wasAboveThreshold || (isCritical != wasCritical) || _lastFood == null) {
        final alertId = 'food_${isCritical ? 'critical' : 'warning'}';
        if (!_activeAlertIds.contains(alertId)) {
          alerts.add(
            SmartAlert(
              id: alertId,
              title: isCritical ? 'Food Critically Low' : 'Food Level Warning',
              message: 'Dispenser at ${food.toStringAsFixed(0)}%. Refill needed soon.',
              severity: isCritical ? AlertSeverity.critical : AlertSeverity.warning,
              timestamp: DateTime.now(),
            ),
          );
          _activeAlertIds.add(alertId);
        }
      }
    } else if (_lastFood != null && _lastFood! <= 25) {
      // Food level recovered - remove alert
      _activeAlertIds.removeWhere((id) => id.startsWith('food_'));
    }

    // Water Level Alerts
    if (water <= 30) {
      final wasAboveThreshold = _lastWater == null || _lastWater! > 30;
      final isCritical = water <= 15;
      final wasCritical = _lastWater != null && _lastWater! <= 15;
      
      if (wasAboveThreshold || (isCritical != wasCritical) || _lastWater == null) {
        final alertId = 'water_${isCritical ? 'critical' : 'warning'}';
        if (!_activeAlertIds.contains(alertId)) {
          alerts.add(
            SmartAlert(
              id: alertId,
              title: isCritical ? 'Hydration Emergency' : 'Hydration Warning',
              message: 'Water reservoir at ${water.toStringAsFixed(0)}%. Refill needed.',
              severity: isCritical ? AlertSeverity.critical : AlertSeverity.warning,
              timestamp: DateTime.now(),
            ),
          );
          _activeAlertIds.add(alertId);
        }
      }
    } else if (_lastWater != null && _lastWater! <= 30) {
      _activeAlertIds.removeWhere((id) => id.startsWith('water_'));
    }

    // Activity Alerts - Only when activity is abnormally high
    if (activity >= 85) {
      final wasBelowThreshold = _lastActivity == null || _lastActivity! < 85;
      
      if (wasBelowThreshold || _lastActivity == null) {
        final alertId = 'activity_high';
        if (!_activeAlertIds.contains(alertId)) {
          alerts.add(
            SmartAlert(
              id: alertId,
              title: 'Abnormal Activity Spike',
              message: 'Activity index at ${activity.toStringAsFixed(0)}%. Colony may be stressed.',
              severity: AlertSeverity.warning,
              timestamp: DateTime.now(),
            ),
          );
          _activeAlertIds.add(alertId);
        }
      }
    } else if (_lastActivity != null && _lastActivity! >= 85) {
      _activeAlertIds.remove('activity_high');
    }

    // Temperature Alerts - Only when out of safe range
    if (temp >= 35 || temp <= 20) {
      final wasInRange = _lastTemp == null || (_lastTemp! >= 20 && _lastTemp! <= 35);
      final isTooHot = temp >= 35;
      final isTooCold = temp <= 20;
      
      if (wasInRange || _lastTemp == null) {
        final alertId = isTooHot ? 'temp_hot' : 'temp_cold';
        if (!_activeAlertIds.contains(alertId)) {
          alerts.add(
            SmartAlert(
              id: alertId,
              title: isTooHot ? 'Temperature Too High' : 'Temperature Too Low',
              message: 'Current temperature ${temp.toStringAsFixed(1)}°C. Optimal range: 20-35°C.',
              severity: AlertSeverity.warning,
              timestamp: DateTime.now(),
            ),
          );
          _activeAlertIds.add(alertId);
        }
      }
    } else if (_lastTemp != null && (_lastTemp! >= 35 || _lastTemp! <= 20)) {
      _activeAlertIds.removeWhere((id) => id.startsWith('temp_'));
    }

    // Humidity Alerts
    if (humidity <= 35) {
      final wasAboveThreshold = _lastHumidity == null || _lastHumidity! > 35;
      
      if (wasAboveThreshold || _lastHumidity == null) {
        final alertId = 'humidity_low';
        if (!_activeAlertIds.contains(alertId)) {
          alerts.add(
            SmartAlert(
              id: alertId,
              title: 'Humidity Too Low',
              message: 'Current humidity ${humidity.toStringAsFixed(0)}%. Optimal: 40-70%.',
              severity: AlertSeverity.warning,
              timestamp: DateTime.now(),
            ),
          );
          _activeAlertIds.add(alertId);
        }
      }
    } else if (_lastHumidity != null && _lastHumidity! <= 35) {
      _activeAlertIds.remove('humidity_low');
    }

    // Condition Alerts - Only when condition changes
    if (condition != 'normal') {
      final conditionChanged = _lastCondition != condition;
      
      if (conditionChanged || _lastCondition == null) {
        final alertId = 'condition_$condition';
        if (!_activeAlertIds.contains(alertId)) {
          alerts.add(
            SmartAlert(
              id: alertId,
              title: 'AI Detected: ${condition.toUpperCase()} Condition',
              message: prediction?['recommendedAction'] ??
                  'Follow latest recommended action to stabilize the colony.',
              severity: condition == 'stressed' ? AlertSeverity.critical : AlertSeverity.warning,
              timestamp: DateTime.now(),
            ),
          );
          _activeAlertIds.add(alertId);
        }
      }
    } else if (_lastCondition != null && _lastCondition != 'normal') {
      _activeAlertIds.removeWhere((id) => id.startsWith('condition_'));
    }

    // Update last values
    _lastTemp = temp;
    _lastHumidity = humidity;
    _lastFood = food;
    _lastWater = water;
    _lastActivity = activity;
    _lastCondition = condition;

    return alerts;
  }
}

