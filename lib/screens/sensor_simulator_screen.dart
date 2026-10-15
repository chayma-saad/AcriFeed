import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../services/realtime_monitoring_service.dart';
import '../services/api_service.dart';
import '../services/sensor_data_store.dart';
import '../models/sensor_data.dart';

class SensorSimulatorScreen extends StatefulWidget {
  const SensorSimulatorScreen({super.key});

  @override
  State<SensorSimulatorScreen> createState() => _SensorSimulatorScreenState();
}

class _SensorSimulatorScreenState extends State<SensorSimulatorScreen> {
  double _temperature = 28.0;
  double _humidity = 60.0;
  double _feedLevel = 65.0;
  double _waterLevel = 72.0;
  double _activity = 50.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Simulator'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.science, size: 48, color: Colors.deepPurple),
                    const SizedBox(height: 8),
                    Text(
                      'Developer Mode: Sensor Simulator',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Adjust sensor values to test alerts and monitoring',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Temperature Slider
            _buildSensorCard(
              icon: Icons.thermostat,
              title: 'Temperature',
              value: _temperature,
              unit: '°C',
              min: 0,
              max: 50,
              color: Colors.red,
              onChanged: (value) => setState(() => _temperature = value),
            ),

            const SizedBox(height: 16),

            // Humidity Slider
            _buildSensorCard(
              icon: Icons.water_drop,
              title: 'Humidity',
              value: _humidity,
              unit: '%',
              min: 0,
              max: 100,
              color: Colors.blue,
              onChanged: (value) => setState(() => _humidity = value),
            ),

            const SizedBox(height: 16),

            // Feed Level Slider
            _buildSensorCard(
              icon: Icons.restaurant,
              title: 'Feed Level',
              value: _feedLevel,
              unit: '%',
              min: 0,
              max: 100,
              color: Colors.orange,
              onChanged: (value) => setState(() => _feedLevel = value),
            ),

            const SizedBox(height: 16),

            // Water Level Slider
            _buildSensorCard(
              icon: Icons.opacity,
              title: 'Water Level',
              value: _waterLevel,
              unit: '%',
              min: 0,
              max: 100,
              color: Colors.lightBlue,
              onChanged: (value) => setState(() => _waterLevel = value),
            ),

            const SizedBox(height: 16),

            // Activity Slider
            _buildSensorCard(
              icon: Icons.trending_up,
              title: 'Colony Activity',
              value: _activity,
              unit: '%',
              min: 0,
              max: 100,
              color: Colors.green,
              onChanged: (value) => setState(() => _activity = value),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sendSimulatedData,
                    icon: const Icon(Icons.send),
                    label: const Text('Send Current Values'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _generateRandomData,
                    icon: const Icon(Icons.shuffle),
                    label: const Text('Random Data'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Quick Presets
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Presets',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _PresetButton(
                          label: 'Normal',
                          onTap: () => _setPreset(28.0, 60.0, 70.0, 75.0, 50.0),
                          color: Colors.green,
                        ),
                        _PresetButton(
                          label: 'Hot & Dry',
                          onTap: () => _setPreset(38.0, 35.0, 60.0, 70.0, 60.0),
                          color: Colors.red,
                        ),
                        _PresetButton(
                          label: 'Low Food',
                          onTap: () => _setPreset(28.0, 60.0, 15.0, 70.0, 40.0),
                          color: Colors.orange,
                        ),
                        _PresetButton(
                          label: 'Low Water',
                          onTap: () => _setPreset(28.0, 60.0, 70.0, 20.0, 45.0),
                          color: Colors.blue,
                        ),
                        _PresetButton(
                          label: 'High Activity',
                          onTap: () => _setPreset(30.0, 65.0, 70.0, 75.0, 85.0),
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Current Values Summary
            Card(
              elevation: 2,
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Simulated Values',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _ValueRow('Temperature', '${_temperature.toStringAsFixed(1)}°C', Colors.red),
                    _ValueRow('Humidity', '${_humidity.toStringAsFixed(1)}%', Colors.blue),
                    _ValueRow('Feed Level', '${_feedLevel.toStringAsFixed(1)}%', Colors.orange),
                    _ValueRow('Water Level', '${_waterLevel.toStringAsFixed(1)}%', Colors.lightBlue),
                    _ValueRow('Activity', '${_activity.toStringAsFixed(1)}%', Colors.green),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard({
    required IconData icon,
    required String title,
    required double value,
    required String unit,
    required double min,
    required double max,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${value.toStringAsFixed(1)}$unit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).toInt(),
              activeColor: color,
              onChanged: onChanged,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${min.toInt()}$unit',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                Text(
                  '${max.toInt()}$unit',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _setPreset(double temp, double humidity, double feed, double water, double activity) {
    setState(() {
      _temperature = temp;
      _humidity = humidity;
      _feedLevel = feed;
      _waterLevel = water;
      _activity = activity;
    });
    _sendSimulatedData();
  }

  void _generateRandomData() {
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    setState(() {
      _temperature = 20.0 + (random % 30);
      _humidity = 30.0 + (random % 50);
      _feedLevel = (random % 100).toDouble();
      _waterLevel = (random % 100).toDouble();
      _activity = (random % 100).toDouble();
    });
    _sendSimulatedData();
  }

  Future<void> _sendSimulatedData() async {
    try {
      final sensorData = SensorData(
        temperature: _temperature,
        humidity: _humidity,
        foodLevel: _feedLevel,
        waterLevel: _waterLevel,
        colonyActivity: _activity.toInt(),
        timestamp: DateTime.now(),
      );

      // Store in sensor data store (for real-time monitoring)
      SensorDataStore().setSimulatedData(sensorData);

      // Also send to API for persistence
      try {
        final apiService = ApiService();
        await apiService.createPrediction({
          'frameData': 'simulated',
          'temperature': _temperature,
          'humidity': _humidity,
          'lightLevel': 75.0,
          'activityIndex': _activity / 100,
          'feedLevel': _feedLevel,
        });
      } catch (e) {
        // API might be offline, but simulator still works
        debugPrint('API error (simulator still works): $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Simulated sensor data sent! Dashboard will update in real-time.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _PresetButton({
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(100)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ValueRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

