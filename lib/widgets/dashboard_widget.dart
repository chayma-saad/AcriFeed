import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../models/realtime_snapshot.dart';
import '../models/smart_alert.dart';
import '../services/api_service.dart';
import '../services/realtime_monitoring_service.dart';
import '../services/notification_service.dart';
import '../services/alerts_service.dart';
import 'condition_overlay.dart';
import 'feeding_control_card.dart';
import 'live_sensor_panel.dart';
import 'recommended_actions_panel.dart';
import 'package:video_player/video_player.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  final ApiService _apiService = ApiService();
  final AlertsService _alertsService = AlertsService();
  RealtimeMonitoringService? _monitoringService;
  StreamSubscription<RealtimeSnapshot>? _snapshotSubscription;
  RealtimeSnapshot? _snapshot;
  Map<String, dynamic>? _latestPrediction;
  Map<String, dynamic>? _environmentalData;
  bool _isLoading = true;
  String? _lastSnackAlertId;
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;

  @override
  void initState() {
    super.initState();
    _monitoringService = RealtimeMonitoringService(apiService: _apiService);
    _snapshotSubscription = _monitoringService!.stream.listen(_handleSnapshot);
    _monitoringService!.start();
    _initializeVideoPlayer();
    _loadData();
  }

  @override
  void dispose() {
    _snapshotSubscription?.cancel();
    _videoController?.dispose();
    _monitoringService?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      // Try different video formats for better browser compatibility
      List<String> videoPaths = [
        'data/Locust_Feeding.mp4',
      ];

      for (String assetPath in videoPaths) {
        try {
          // First try asset loading
          _videoController = VideoPlayerController.asset(assetPath);
          await _videoController!.initialize();

          await _videoController!.setLooping(true);
          await _videoController!.play();
          await _videoController!.setVolume(0.0); // Mute the video for dashboard

          if (mounted) {
            setState(() {
              _videoInitialized = true;
            });
          }
          return; // Successfully loaded a video
        } catch (e) {
          debugPrint('Asset loading failed for $assetPath: $e');

          // If asset loading fails, try copying to temp file and loading from there
          try {
            final tempFile = await _copyAssetToTempFile(assetPath);
            if (tempFile != null) {
              _videoController = VideoPlayerController.file(tempFile);
              await _videoController!.initialize();

              await _videoController!.setLooping(true);
              await _videoController!.play();
              await _videoController!.setVolume(0.0); // Mute the video for dashboard

              if (mounted) {
                setState(() {
                  _videoInitialized = true;
                });
              }
              return; // Successfully loaded a video
            }
          } catch (fileError) {
            debugPrint('File loading also failed for $assetPath: $fileError');
          }

          _videoController?.dispose();
          _videoController = null;
        }
      }

      // If all videos failed, show fallback
      debugPrint('All video loading attempts failed, showing fallback UI');
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  Future<File?> _copyAssetToTempFile(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${assetPath.split('/').last}');
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());
      return tempFile;
    } catch (e) {
      debugPrint('Failed to copy asset to temp file: $e');
      return null;
    }
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
    try {
      await _monitoringService?.refreshNow();
      final prediction = await _apiService.getLatestPrediction();
      final envData = await _apiService.getLatestEnvironmentalData();

      if (!mounted) return;
      setState(() {
        _latestPrediction = prediction;
        _environmentalData = envData;
      });
    } catch (e) {
    }
  }

  void _handleSnapshot(RealtimeSnapshot snapshot) {
    if (!mounted) return;
    setState(() {
      _snapshot = snapshot;
      _latestPrediction = snapshot.prediction ?? _latestPrediction;
      _environmentalData = snapshot.toEnvironmentalMap();
      _isLoading = false;
    });

    // Add new alerts to global service
    _alertsService.addAlerts(snapshot.alerts);

    // Show notifications for new alerts
    for (final alert in snapshot.alerts) {
      if (!_alertsService.hasBeenNotified(alert.id)) {
        // New alert - show notification
        _alertsService.markAsNotified(alert.id);
        NotificationService().showAlert(alert);
      }
    }

    // Show snackbar for critical alerts
    SmartAlert? criticalAlert;
    if (snapshot.alerts.isNotEmpty) {
      criticalAlert = snapshot.alerts.firstWhere(
        (alert) => alert.isCritical,
        orElse: () => snapshot.alerts.first,
      );
    }

    if (criticalAlert != null && criticalAlert.id != _lastSnackAlertId) {
      _lastSnackAlertId = criticalAlert.id;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: criticalAlert.color.withAlpha(230),
          content: Text('${criticalAlert.title}: ${criticalAlert.message}'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () {
              // Scroll to alerts panel or show details
            },
          ),
        ),
      );
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
      await _monitoringService?.refreshNow();
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
            // AI-Vision Feed Section (moved to top)
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
                    // Live video feed
                    if (_videoInitialized && _videoController != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: VideoPlayer(_videoController!),
                      )
                    else
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Icon(
                                  Icons.videocam_off,
                                  size: 32,
                                  color: Colors.red.shade300,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Live AI-Vision Feed',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Video format not supported\nin this browser',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.blue.shade300.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 14,
                                      color: Colors.blue.shade300,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Try Chrome for full video support',
                                      style: TextStyle(
                                        color: Colors.blue.shade300,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
            // Live Sensor Feed (moved below AI vision feed)
            if (_snapshot != null)
              LiveSensorPanel(
                snapshot: _snapshot!,
                onRefresh: _refreshData,
              ),
            if (_snapshot != null) const SizedBox(height: 16),


            // Recommended Actions Panel
            if (_latestPrediction != null)
              RecommendedActionsPanel(
                condition: _latestPrediction!['conditionType'] ?? 'normal',
                recommendedAction: _latestPrediction!['recommendedAction'] ?? 'No action',
                explanation: _latestPrediction!['explanation'] ?? '',
              ),
            const SizedBox(height: 16),

            FeedingControlCard(
              onScheduleUpdated: (_) => _monitoringService?.refreshNow(),
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

