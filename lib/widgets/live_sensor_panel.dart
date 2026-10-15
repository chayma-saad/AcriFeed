import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/realtime_snapshot.dart';
import '../services/language_service.dart';

class LiveSensorPanel extends StatefulWidget {
  final RealtimeSnapshot snapshot;
  final VoidCallback? onRefresh;
  final bool isStreaming;

  const LiveSensorPanel({
    super.key,
    required this.snapshot,
    this.onRefresh,
    this.isStreaming = true,
  });

  @override
  State<LiveSensorPanel> createState() => _LiveSensorPanelState();
}

class _LiveSensorPanelState extends State<LiveSensorPanel> {
  String _getLocalizedString(String key) {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    final locale = languageService.locale.languageCode;

    // Define localized strings for live sensor panel
    const Map<String, Map<String, String>> localizedStrings = {
      'en': {
        'liveSensorFeed': 'Live Sensor Feed',
        'live': 'LIVE',
        'paused': 'PAUSED',
        'pullLatestReading': 'Pull latest reading',
        'temperature': 'Temperature',
        'humidity': 'Humidity',
        'foodLevel': 'Food Level',
        'waterLevel': 'Water Level',
        'activityIndex': 'Activity Index',
        'lastUpdated': 'Last updated',
      },
      'fr': {
        'liveSensorFeed': 'Flux de Capteurs en Direct',
        'live': 'EN DIRECT',
        'paused': 'EN PAUSE',
        'pullLatestReading': 'Tirer la dernière lecture',
        'temperature': 'Température',
        'humidity': 'Humidité',
        'foodLevel': 'Niveau de Nourriture',
        'waterLevel': 'Niveau d\'Eau',
        'activityIndex': 'Indice d\'Activité',
        'lastUpdated': 'Dernière mise à jour',
      },
      'ar': {
        'liveSensorFeed': 'تغذية المستشعرات الحية',
        'live': 'مباشر',
        'paused': 'متوقف',
        'pullLatestReading': 'سحب آخر قراءة',
        'temperature': 'درجة الحرارة',
        'humidity': 'الرطوبة',
        'foodLevel': 'مستوى الطعام',
        'waterLevel': 'مستوى الماء',
        'activityIndex': 'مؤشر النشاط',
        'lastUpdated': 'آخر تحديث',
      },
    };

    return localizedStrings[locale]?[key] ?? localizedStrings['en']?[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sensors, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getLocalizedString('liveSensorFeed'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Chip(
                  backgroundColor: widget.isStreaming ? Colors.green.withAlpha(38) : Colors.grey.shade200,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: widget.isStreaming ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(widget.isStreaming ? _getLocalizedString('live') : _getLocalizedString('paused')),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: _getLocalizedString('pullLatestReading'),
                  onPressed: widget.onRefresh,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _LiveMetricTile(
              label: _getLocalizedString('temperature'),
              value: '${widget.snapshot.temperature.toStringAsFixed(1)}°C',
              progress: widget.snapshot.temperature / 40,
              color: Colors.redAccent,
              icon: Icons.thermostat,
            ),
            _LiveMetricTile(
              label: _getLocalizedString('humidity'),
              value: '${widget.snapshot.humidity.toStringAsFixed(0)}%',
              progress: widget.snapshot.humidity / 100,
              color: Colors.blueAccent,
              icon: Icons.water_drop,
            ),
            _LiveMetricTile(
              label: _getLocalizedString('foodLevel'),
              value: '${widget.snapshot.foodLevel.toStringAsFixed(0)}%',
              progress: widget.snapshot.foodLevel / 100,
              color: Colors.orangeAccent,
              icon: Icons.restaurant,
              warningThreshold: 0.3,
            ),
            _LiveMetricTile(
              label: _getLocalizedString('waterLevel'),
              value: '${widget.snapshot.waterLevel.toStringAsFixed(0)}%',
              progress: widget.snapshot.waterLevel / 100,
              color: Colors.lightBlueAccent,
              icon: Icons.local_drink,
              warningThreshold: 0.4,
            ),
            _LiveMetricTile(
              label: _getLocalizedString('activityIndex'),
              value: '${(widget.snapshot.activityIndex * 100).toStringAsFixed(0)}%',
              progress: widget.snapshot.activityIndex,
              color: widget.snapshot.activityIndex > 0.75 ? Colors.amber : Colors.green,
              icon: Icons.trending_up,
            ),
            const SizedBox(height: 8),
            Text(
              '${_getLocalizedString('lastUpdated')} ${TimeOfDay.fromDateTime(widget.snapshot.timestamp).format(context)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  final double warningThreshold;
  final Color color;
  final IconData icon;

  const _LiveMetricTile({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
    required this.icon,
    this.warningThreshold = 0.2,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress.clamp(0.0, 1.0);
    final isWarning = normalizedProgress <= warningThreshold &&
        (label.toLowerCase().contains('level') || label.toLowerCase().contains('humidity'));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isWarning ? Colors.redAccent : color,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: normalizedProgress,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(isWarning ? Colors.redAccent : color),
          ),
        ],
      ),
    );
  }
}

