import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/smart_alert.dart';

class AlertsService extends ChangeNotifier {
  static final AlertsService _instance = AlertsService._internal();
  factory AlertsService() => _instance;
  AlertsService._internal();

  final List<SmartAlert> _alerts = [];
  final Set<String> _notifiedIds = {};
  final StreamController<List<SmartAlert>> _alertsController = StreamController<List<SmartAlert>>.broadcast();

  List<SmartAlert> get alerts => List.unmodifiable(_alerts);
  Stream<List<SmartAlert>> get alertsStream => _alertsController.stream;

  void addAlert(SmartAlert alert) {
    // Check if similar alert already exists (same title and message within 2 minutes)
    final existingIndex = _alerts.indexWhere((existing) =>
      existing.title == alert.title &&
      existing.message == alert.message &&
      alert.timestamp.difference(existing.timestamp).abs() < const Duration(minutes: 2)
    );

    if (existingIndex >= 0) {
      // Update timestamp of existing alert
      _alerts[existingIndex] = alert;
    } else {
      // Add new alert
      _alerts.insert(0, alert);

      // Keep only latest 20 alerts
      if (_alerts.length > 20) {
        _alerts.removeRange(20, _alerts.length);
      }
    }

    _alertsController.add(List.from(_alerts));
    notifyListeners();
  }

  void addAlerts(List<SmartAlert> newAlerts) {
    for (final alert in newAlerts) {
      addAlert(alert);
    }
  }

  void clearAlerts() {
    _alerts.clear();
    _notifiedIds.clear();
    _alertsController.add([]);
    notifyListeners();
  }

  void removeAlert(String alertId) {
    _alerts.removeWhere((alert) => alert.id == alertId);
    _alertsController.add(List.from(_alerts));
    notifyListeners();
  }

  bool hasBeenNotified(String alertId) {
    return _notifiedIds.contains(alertId);
  }

  void markAsNotified(String alertId) {
    _notifiedIds.add(alertId);
  }

  List<SmartAlert> getUnreadAlerts() {
    return _alerts.where((alert) => !_notifiedIds.contains(alert.id)).toList();
  }

  void markAlertAsRead(String alertId) {
    _notifiedIds.add(alertId);
    notifyListeners();
  }

  void dispose() {
    _alertsController.close();
    super.dispose();
  }
}



