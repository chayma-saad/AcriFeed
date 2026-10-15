import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final history = await _apiService.getHistory();
      setState(() {
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading history: $e')),
        );
      }
    }
  }

  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'stressed':
        return Colors.red;
      case 'hungry':
        return Colors.orange;
      case 'normal':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getConditionIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'stressed':
        return Icons.warning;
      case 'hungry':
        return Icons.restaurant;
      case 'normal':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  Future<void> _exportToCSV() async {
    // Simple CSV export (in production, use a proper CSV library)
    final buffer = StringBuffer();
    buffer.writeln('Timestamp,Condition,Action Taken,Notes,Temperature,Humidity,Activity Index,Feed Level');
    
    for (var entry in _history) {
      final timestamp = DateTime.parse(entry['timestamp']);
      final envData = entry['environmentalData'];
      buffer.writeln([
        DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp),
        entry['condition'] ?? '',
        entry['actionTaken'] ?? '',
        '"${entry['notes']?.replaceAll('"', '""') ?? ''}"',
        envData?['temperature']?.toString() ?? '',
        envData?['humidity']?.toString() ?? '',
        envData?['activityIndex']?.toString() ?? '',
        envData?['feedLevel']?.toString() ?? '',
      ].join(','));
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV data ready (${_history.length} entries)'),
          action: SnackBarAction(
            label: 'Copy',
            onPressed: () {
              // In production, copy to clipboard or save to file
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header with export button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Historical Log',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: _exportToCSV,
                        tooltip: 'Export to CSV',
                      ),
                    ],
                  ),
                ),
                // History table
                Expanded(
                  child: _history.isEmpty
                      ? const Center(
                          child: Text('No history available'),
                        )
                      : ListView.builder(
                          itemCount: _history.length,
                          itemBuilder: (context, index) {
                            final entry = _history[index];
                            final condition = entry['condition'] ?? 'unknown';
                            final timestamp = DateTime.parse(entry['timestamp']);
                            final envData = entry['environmentalData'];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getConditionColor(condition).withOpacity(0.2),
                                  child: Icon(
                                    _getConditionIcon(condition),
                                    color: _getConditionColor(condition),
                                  ),
                                ),
                                title: Text(
                                  condition.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getConditionColor(condition),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp),
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Action: ${entry['actionTaken'] ?? 'No action'}',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    if (entry['notes'] != null && entry['notes'].toString().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          entry['notes'],
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    if (envData != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Wrap(
                                          spacing: 8,
                                          children: [
                                            if (envData['temperature'] != null)
                                              Chip(
                                                label: Text(
                                                  '${envData['temperature']?.toStringAsFixed(1)}°C',
                                                  style: const TextStyle(fontSize: 10),
                                                ),
                                                padding: EdgeInsets.zero,
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                            if (envData['humidity'] != null)
                                              Chip(
                                                label: Text(
                                                  '${envData['humidity']?.toStringAsFixed(1)}%',
                                                  style: const TextStyle(fontSize: 10),
                                                ),
                                                padding: EdgeInsets.zero,
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

