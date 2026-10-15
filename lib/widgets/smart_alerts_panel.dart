import 'package:flutter/material.dart';

import '../models/smart_alert.dart';

class SmartAlertsPanel extends StatelessWidget {
  final List<SmartAlert> alerts;
  final void Function(SmartAlert alert)? onAlertTap;
  final VoidCallback? onClear;

  const SmartAlertsPanel({
    super.key,
    required this.alerts,
    this.onAlertTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final latestAlerts = alerts.take(4).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.deepOrange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Smart Alerts',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (alerts.isNotEmpty && onClear != null)
                  TextButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Clear all'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (latestAlerts.isEmpty)
              _EmptyState(theme: theme)
            else
              Column(
                children: latestAlerts.map((alert) {
                  return _AlertTile(
                    alert: alert,
                    onTap: onAlertTap,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final SmartAlert alert;
  final void Function(SmartAlert alert)? onTap;

  const _AlertTile({required this.alert, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap == null ? null : () => onTap!(alert),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: alert.color.withAlpha(77)),
          color: alert.color.withAlpha(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(alert.icon, color: alert.color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: alert.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(alert.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}

class _EmptyState extends StatelessWidget {
  final ThemeData theme;

  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withAlpha(51)),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green),
          const SizedBox(height: 8),
          Text(
            'All systems normal',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'We will surface alerts here if anything drifts out of range.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.green.shade600),
          ),
        ],
      ),
    );
  }
}

