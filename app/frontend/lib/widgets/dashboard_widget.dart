import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import 'condition_overlay.dart';
import 'recommended_actions_panel.dart';
import 'quick_stats_widget.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _latestPrediction;
  Map<String, dynamic>? _environmentalData;
  bool _isLoading = true;
  bool _isRefreshing = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Auto-refresh every 30 seconds
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _refreshData();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final prediction = await _apiService.getLatestPrediction();
      final envData = await _apiService.getLatestEnvironmentalData();
      
      setState(() {
        _latestPrediction = prediction;
        _environmentalData = envData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    try {
      final prediction = await _apiService.getLatestPrediction();
      final envData = await _apiService.getLatestEnvironmentalData();
      
      setState(() {
        _latestPrediction = prediction;
        _environmentalData = envData;
        _isRefreshing = false;
      });
    } catch (e) {
      setState(() => _isRefreshing = false);
    }
  }

  Future<void> _createNewPrediction() async {
    try {
      // Simulate frame data and environmental readings
      final prediction = await _apiService.createPrediction({
        'frameData': 'simulated_frame_data',
        'temperature': _environmentalData?['temperature'] ?? 25.0,
        'humidity': _environmentalData?['humidity'] ?? 60.0,
        'lightLevel': _environmentalData?['lightLevel'] ?? 75.0,
        'activityIndex': _environmentalData?['activityIndex'] ?? 0.65,
        'feedLevel': _environmentalData?['feedLevel'] ?? 80.0,
      });

      setState(() {
        _latestPrediction = prediction;
        if (prediction['environmentalData'] != null) {
          _environmentalData = prediction['environmentalData'];
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New prediction created')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating prediction: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // AI-Vision Feed Section
            Card(
              elevation: 4,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Simulated video feed
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videocam,
                            size: 64,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Live AI-Vision Feed',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Simulated Feed',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Condition Overlay
                    if (_latestPrediction != null)
                      ConditionOverlay(
                        condition: _latestPrediction!['conditionType'] ?? 'normal',
                        confidence: _latestPrediction!['confidence']?.toDouble() ?? 0.0,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Recommended Actions Panel
            if (_latestPrediction != null)
              RecommendedActionsPanel(
                condition: _latestPrediction!['conditionType'] ?? 'normal',
                recommendedAction: _latestPrediction!['recommendedAction'] ?? 'No action',
                explanation: _latestPrediction!['explanation'] ?? '',
              ),
            const SizedBox(height: 16),

            // Quick Stats
            QuickStatsWidget(
              environmentalData: _environmentalData,
              activityIndex: _environmentalData?['activityIndex']?.toDouble() ?? 0.0,
            ),
            const SizedBox(height: 16),

            // Action Button
            ElevatedButton.icon(
              onPressed: _createNewPrediction,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture & Analyze'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

