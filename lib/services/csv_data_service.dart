import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import '../models/sensor_data.dart';
import 'dart:math';

/// Service to load and simulate sensor data from CSV files
class CsvDataService {
  List<Map<String, dynamic>> _swarmsData = [];
  List<Map<String, dynamic>> _locustWatchData = [];
  int _currentIndex = 0;
  final Random _random = Random();

  /// Load CSV data from assets
  Future<void> loadCsvData() async {
    try {
      // Load Swarms.csv
      final swarmsContent = await rootBundle.loadString('data/Swarms.csv');
      final swarmsList = const CsvToListConverter().convert(swarmsContent);
      if (swarmsList.length > 1) {
        final headers = swarmsList[0] as List<dynamic>;
        _swarmsData = swarmsList.skip(1).map((row) {
          final map = <String, dynamic>{};
          for (int i = 0; i < headers.length && i < row.length; i++) {
            map[headers[i].toString()] = row[i];
          }
          return map;
        }).toList();
      }

      // Load Locust_watch.csv
      final watchContent = await rootBundle.loadString('data/Locust_watch.csv');
      final watchList = const CsvToListConverter().convert(watchContent);
      if (watchList.length > 1) {
        final headers = watchList[0] as List<dynamic>;
        _locustWatchData = watchList.skip(1).map((row) {
          final map = <String, dynamic>{};
          for (int i = 0; i < headers.length && i < row.length; i++) {
            map[headers[i].toString()] = row[i];
          }
          return map;
        }).toList();
      }
    } catch (e) {
      print('Error loading CSV data: $e');
    }
  }

  /// Generate sensor data based on CSV patterns
  SensorData generateSensorDataFromCsv() {
    if (_swarmsData.isEmpty && _locustWatchData.isEmpty) {
      return _generateFallbackData();
    }

    // Cycle through CSV data
    _currentIndex = (_currentIndex + 1) % (_swarmsData.length + _locustWatchData.length);
    
    final dataSource = _currentIndex < _swarmsData.length
        ? _swarmsData[_currentIndex]
        : _locustWatchData[_currentIndex - _swarmsData.length];

    // Extract or generate sensor values based on CSV data
    final baseTemp = _extractOrGenerate(dataSource, 'temperature', 25.0, 30.0);
    final baseHumidity = _extractOrGenerate(dataSource, 'humidity', 50.0, 70.0);
    
    // Activity based on swarm presence or density
    final activity = _calculateActivity(dataSource);
    
    // Food and water levels - simulate based on date patterns
    final foodLevel = _calculateFoodLevel(dataSource);
    final waterLevel = _calculateWaterLevel(dataSource);

    return SensorData(
      temperature: baseTemp + (_random.nextDouble() * 4 - 2), // ±2°C variation
      humidity: baseHumidity + (_random.nextDouble() * 10 - 5), // ±5% variation
      foodLevel: foodLevel,
      waterLevel: waterLevel,
      colonyActivity: activity,
      timestamp: DateTime.now(),
      condition: _determineCondition(baseTemp, baseHumidity, foodLevel, waterLevel, activity),
    );
  }

  double _extractOrGenerate(Map<String, dynamic> data, String key, double min, double max) {
    final value = data[key];
    if (value != null && value is num) {
      return value.toDouble().clamp(min, max);
    }
    return min + _random.nextDouble() * (max - min);
  }

  int _calculateActivity(Map<String, dynamic> data) {
    // Use swarm density or presence indicators
    final density = data['SHPMINDSQM'] ?? data['GHPMINDSQM'] ?? 0;
    if (density is num) {
      return (density.toDouble() * 10).clamp(0, 100).toInt();
    }
    
    // Check if locusts are present
    final present = data['LOCPRESENT'];
    if (present == 1 || present == '1') {
      return 60 + _random.nextInt(30);
    }
    
    return 30 + _random.nextInt(40);
  }

  double _calculateFoodLevel(Map<String, dynamic> data) {
    // Simulate food level based on breeding status and date
    final breeding = data['BREEDING'];
    if (breeding == 1 || breeding == '1') {
      return 40.0 + _random.nextDouble() * 30; // Lower when breeding
    }
    return 60.0 + _random.nextDouble() * 30;
  }

  double _calculateWaterLevel(Map<String, dynamic> data) {
    // Simulate water level
    final partMonth = data['PARTMONTH']?.toString().toLowerCase() ?? '';
    if (partMonth.contains('late')) {
      return 50.0 + _random.nextDouble() * 30; // Lower in late month
    }
    return 70.0 + _random.nextDouble() * 25;
  }

  String? _determineCondition(double temp, double humidity, double food, double water, int activity) {
    if (food < 25 || water < 30) return 'hungry';
    if (temp > 35 || temp < 20 || humidity < 35) return 'stressed';
    if (activity > 80) return 'stressed';
    return 'normal';
  }

  SensorData _generateFallbackData() {
    return SensorData(
      temperature: 28.0 + (_random.nextDouble() * 4 - 2),
      humidity: 60.0 + (_random.nextDouble() * 10 - 5),
      foodLevel: 65.0 + (_random.nextDouble() * 20),
      waterLevel: 72.0 + (_random.nextDouble() * 15),
      colonyActivity: 50 + _random.nextInt(30),
      timestamp: DateTime.now(),
      condition: 'normal',
    );
  }

  /// Get historical data for charts
  List<SensorData> getHistoricalData({int count = 50}) {
    final List<SensorData> history = [];
    for (int i = 0; i < count; i++) {
      final data = generateSensorDataFromCsv();
      history.add(data);
    }
    return history;
  }
}

