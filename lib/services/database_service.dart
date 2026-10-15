import 'dart:convert';
import 'package:mysql1/mysql1.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/database_config.dart';
import '../models/sensor_data.dart';
import '../models/feeding_schedule.dart';

class DatabaseService {
  MySqlConnection? _connection;
  bool _isConnected = false;

  Future<void> connect() async {
    // Skip MySQL connection on web platform (mysql1 doesn't support web)
    if (kIsWeb) {
      debugPrint('Running on web - MySQL connection not available (use API instead)');
      _isConnected = false;
      _connection = null;
      return;
    }

    try {
      if (_isConnected && _connection != null) {
        // Test if connection is still alive
        try {
          await _connection!.query('SELECT 1');
          return; // Connection is still good
        } catch (e) {
          debugPrint('Existing connection is dead, reconnecting...');
          _isConnected = false;
          _connection = null;
        }
      }

      final settings = ConnectionSettings(
        host: DatabaseConfig.host,
        port: DatabaseConfig.port,
        user: DatabaseConfig.username,
        password: DatabaseConfig.password.isEmpty ? null : DatabaseConfig.password,
        db: DatabaseConfig.databaseName,
        timeout: Duration(seconds: 30), // Increased timeout
        maxPacketSize: 16 * 1024 * 1024, // 16MB
      );

      debugPrint('Attempting to connect to MySQL...');
      debugPrint('Host: ${DatabaseConfig.host}:${DatabaseConfig.port}');
      debugPrint('Database: ${DatabaseConfig.databaseName}');

      _connection = await MySqlConnection.connect(settings);
      _isConnected = true;
      debugPrint('✅ Connected to MySQL database successfully');

      // Initialize database tables
      await _initializeTables();
    } catch (e) {
      debugPrint('❌ MySQL connection failed: $e');
      _isConnected = false;
      _connection = null;
      // Don't rethrow - allow app to continue (will use API instead)
    }
  }

  Future<void> _ensureConnection() async {
    // Skip on web
    if (kIsWeb) return;
    
    if (!_isConnected || _connection == null) {
      await connect();
    } else {
      // Verify connection is still alive
      try {
        await _connection!.query('SELECT 1');
      } catch (e) {
        debugPrint('Connection test failed, reconnecting...');
        _isConnected = false;
        _connection = null;
        await connect();
      }
    }
  }

  Future<void> _initializeTables() async {
    try {
      // Create sensor_data table
      await _connection!.query('''
        CREATE TABLE IF NOT EXISTS sensor_data (
          id INT AUTO_INCREMENT PRIMARY KEY,
          temperature DECIMAL(5,2),
          humidity DECIMAL(5,2),
          food_level DECIMAL(5,2),
          water_level DECIMAL(5,2),
          colony_activity INT,
          predicted_humidity DECIMAL(5,2),
          feeding_recommendation DECIMAL(5,2),
          anomaly_score DECIMAL(3,2),
          condition_status VARCHAR(20),
          timestamp DATETIME,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // Create feeding_schedules table
      await _connection!.query('''
        CREATE TABLE IF NOT EXISTS feeding_schedules (
          id VARCHAR(50) PRIMARY KEY,
          name VARCHAR(100),
          hour INT,
          minute INT,
          food_amount DECIMAL(5,2),
          is_active BOOLEAN,
          days JSON,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
      ''');

      // Create ml_predictions table
      await _connection!.query('''
        CREATE TABLE IF NOT EXISTS ml_predictions (
          id INT AUTO_INCREMENT PRIMARY KEY,
          condition_prediction VARCHAR(20),
          humidity_prediction DECIMAL(5,2),
          feeding_amount DECIMAL(5,2),
          anomaly_score DECIMAL(3,2),
          confidence DECIMAL(3,2),
          timestamp DATETIME,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      print('✅ MySQL tables initialized successfully');
    } catch (e) {
      print('❌ Table initialization failed: $e');
    }
  }

  // Sensor Data Methods
  Future<void> saveSensorData(SensorData data) async {
    await _ensureConnection();

    try {
      await _connection!.query(
        'INSERT INTO sensor_data (temperature, humidity, food_level, water_level, colony_activity, predicted_humidity, feeding_recommendation, anomaly_score, condition_status, timestamp) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          data.temperature,
          data.humidity,
          data.foodLevel,
          data.waterLevel,
          data.colonyActivity,
          data.predictedHumidity,
          data.feedingRecommendation,
          data.anomalyScore,
          data.condition,
          data.timestamp,
        ],
      );
      print('✅ Sensor data saved to MySQL successfully');
    } catch (e) {
      print('❌ Error saving sensor data to MySQL: $e');
      rethrow;
    }
  }

  Future<List<SensorData>> getRecentSensorData({int limit = 50}) async {
    await _ensureConnection();

    try {
      final results = await _connection!.query(
        'SELECT * FROM sensor_data ORDER BY timestamp DESC LIMIT ?',
        [limit],
      );

      return results.map((row) => SensorData(
        temperature: (row['temperature'] as double?) ?? 0.0,
        humidity: (row['humidity'] as double?) ?? 0.0,
        foodLevel: (row['food_level'] as double?) ?? 0.0,
        waterLevel: (row['water_level'] as double?) ?? 0.0,
        colonyActivity: (row['colony_activity'] as int?) ?? 0,
        timestamp: row['timestamp'] != null ? (row['timestamp'] as DateTime) : DateTime.now(),
        predictedHumidity: (row['predicted_humidity'] as double?),
        feedingRecommendation: (row['feeding_recommendation'] as double?),
        anomalyScore: (row['anomaly_score'] as double?),
        condition: row['condition_status'] as String?,
      )).toList();
    } catch (e) {
      print('❌ Error fetching sensor data from MySQL: $e');
      return [];
    }
  }

  // Feeding Schedule Methods
  Future<void> saveFeedingSchedule(FeedingSchedule schedule) async {
    if (kIsWeb || !_isConnected) {
      debugPrint('Web platform or no DB connection: Feeding schedule saved to local storage only');
      return;
    }
    
    await _ensureConnection();
    if (_connection == null) return;

    try {
      final daysJson = jsonEncode(schedule.days);

      await _connection!.query(
        'INSERT INTO feeding_schedules (id, name, hour, minute, food_amount, is_active, days) VALUES (?, ?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE name=?, hour=?, minute=?, food_amount=?, is_active=?, days=?',
        [
          schedule.id,
          schedule.name,
          schedule.time.hour,
          schedule.time.minute,
          schedule.foodAmount,
          schedule.isActive,
          daysJson,
          schedule.name,
          schedule.time.hour,
          schedule.time.minute,
          schedule.foodAmount,
          schedule.isActive,
          daysJson,
        ],
      );
      debugPrint('✅ Feeding schedule saved to MySQL successfully');
    } catch (e) {
      debugPrint('❌ Error saving feeding schedule to MySQL: $e');
      if (!kIsWeb) rethrow;
    }
  }

  Future<List<FeedingSchedule>> getFeedingSchedules() async {
    if (kIsWeb || !_isConnected) {
      debugPrint('Web platform or no DB connection: Returning empty feeding schedules');
      return [];
    }
    
    await _ensureConnection();
    if (_connection == null) return [];

    try {
      final results = await _connection!.query(
        'SELECT * FROM feeding_schedules',
      );

      return results.map((row) {
        List<int> days = [];
        try {
          final daysJson = row['days'] as String?;
          if (daysJson != null && daysJson.isNotEmpty) {
            final parsed = jsonDecode(daysJson) as List<dynamic>;
            days = parsed.map((e) => (e as num).toInt()).toList();
          }
        } catch (e) {
          debugPrint('Error parsing days JSON: $e');
        }

        return FeedingSchedule(
          id: row['id'] as String? ?? '',
          name: row['name'] as String? ?? 'Unnamed Schedule',
          time: TimeOfDay(
            hour: (row['hour'] as int?) ?? 0,
            minute: (row['minute'] as int?) ?? 0,
          ),
          foodAmount: (row['food_amount'] as double?) ?? 0.0,
          isActive: (row['is_active'] as bool?) ?? false,
          days: days,
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Error fetching feeding schedules from MySQL: $e');
      return [];
    }
  }

  Future<void> deleteFeedingSchedule(String id) async {
    if (kIsWeb || !_isConnected) {
      debugPrint('Web platform or no DB connection: Delete feeding schedule skipped');
      return;
    }
    
    await _ensureConnection();
    if (_connection == null) return;

    try {
      await _connection!.query(
        'DELETE FROM feeding_schedules WHERE id = ?',
        [id],
      );
      debugPrint('✅ Feeding schedule deleted from MySQL successfully');
    } catch (e) {
      debugPrint('❌ Error deleting feeding schedule from MySQL: $e');
      if (!kIsWeb) rethrow;
    }
  }

  // ML Predictions Methods
  Future<void> saveMLPrediction(Map<String, dynamic> prediction) async {
    await _ensureConnection();

    try {
      await _connection!.query(
        'INSERT INTO ml_predictions (condition_prediction, humidity_prediction, feeding_amount, anomaly_score, confidence, timestamp) VALUES (?, ?, ?, ?, ?, ?)',
        [
          prediction['condition'],
          prediction['predictedHumidity'],
          prediction['feedingRecommendation'],
          prediction['anomalyScore'],
          prediction['confidence'] ?? 0.8,
          DateTime.now(),
        ],
      );
      print('✅ ML prediction saved to MySQL successfully');
    } catch (e) {
      print('❌ Error saving ML prediction to MySQL: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getLatestMLPrediction() async {
    await _ensureConnection();

    try {
      final results = await _connection!.query(
        'SELECT * FROM ml_predictions ORDER BY timestamp DESC LIMIT 1',
      );

      if (results.isEmpty) return null;

      final row = results.first;
      return {
        'condition': row['condition_prediction'] as String?,
        'predictedHumidity': (row['humidity_prediction'] as double?),
        'feedingRecommendation': (row['feeding_amount'] as double?),
        'anomalyScore': (row['anomaly_score'] as double?),
        'confidence': (row['confidence'] as double?),
        'timestamp': row['timestamp'] as DateTime?,
      };
    } catch (e) {
      print('❌ Error fetching ML prediction from MySQL: $e');
      return null;
    }
  }

  // Utility Methods
  Future<int> getSensorDataCount() async {
    await _ensureConnection();

    try {
      final results = await _connection!.query(
        'SELECT COUNT(*) as count FROM sensor_data',
      );
      return (results.first['count'] as int?) ?? 0;
    } catch (e) {
      print('❌ Error getting sensor data count from MySQL: $e');
      return 0;
    }
  }

  Future<void> clearOldSensorData({int daysToKeep = 30}) async {
    await _ensureConnection();

    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      final result = await _connection!.query(
        'DELETE FROM sensor_data WHERE timestamp < ?',
        [cutoffDate],
      );

      print('✅ Cleared ${result.affectedRows} old sensor data records from MySQL');
    } catch (e) {
      print('❌ Error clearing old sensor data from MySQL: $e');
    }
  }

  Future<void> disconnect() async {
    if (_isConnected && _connection != null) {
      try {
        await _connection!.close();
      } catch (e) {
        print('Error closing connection: $e');
      }
      _connection = null;
      _isConnected = false;
      print('✅ MySQL database disconnected');
    }
  }

  bool get isConnected => _isConnected;
}