import 'package:flutter/material.dart';

enum AlertSeverity { info, warning, critical }

class SmartAlert {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;

  const SmartAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
  });

  Color get color {
    switch (severity) {
      case AlertSeverity.critical:
        return Colors.red;
      case AlertSeverity.warning:
        return Colors.orange;
      case AlertSeverity.info:
        return Colors.blue;
    }
  }

  IconData get icon {
    switch (severity) {
      case AlertSeverity.critical:
        return Icons.emergency;
      case AlertSeverity.warning:
        return Icons.warning_amber_outlined;
      case AlertSeverity.info:
        return Icons.notifications_active_outlined;
    }
  }

  bool get isCritical => severity == AlertSeverity.critical;

  SmartAlert copyWith({
    String? id,
    String? title,
    String? message,
    AlertSeverity? severity,
    DateTime? timestamp,
  }) {
    return SmartAlert(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

