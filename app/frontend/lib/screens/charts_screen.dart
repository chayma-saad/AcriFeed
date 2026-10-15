import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _environmentalData = [];
  List<dynamic> _predictions = [];
  bool _isLoading = true;
  String _timeFilter = 'day'; // hour, day, week

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      DateTime? startDate;

      switch (_timeFilter) {
        case 'hour':
          startDate = now.subtract(const Duration(hours: 1));
          break;
        case 'day':
          startDate = now.subtract(const Duration(days: 1));
          break;
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
      }

      final envData = await _apiService.getEnvironmentalData(
        startDate: startDate,
        endDate: now,
      );
      final predictions = await _apiService.getPredictions(
        startDate: startDate,
        endDate: now,
      );

      setState(() {
        _environmentalData = envData;
        _predictions = predictions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading charts: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _FilterButton(
                        label: 'Last Hour',
                        isSelected: _timeFilter == 'hour',
                        onTap: () {
                          setState(() => _timeFilter = 'hour');
                          _loadData();
                        },
                      ),
                      _FilterButton(
                        label: 'Last Day',
                        isSelected: _timeFilter == 'day',
                        onTap: () {
                          setState(() => _timeFilter = 'day');
                          _loadData();
                        },
                      ),
                      _FilterButton(
                        label: 'Last Week',
                        isSelected: _timeFilter == 'week',
                        onTap: () {
                          setState(() => _timeFilter = 'week');
                          _loadData();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildTemperatureChart(),
                        const SizedBox(height: 24),
                        _buildHumidityChart(),
                        const SizedBox(height: 24),
                        _buildActivityChart(),
                        const SizedBox(height: 24),
                        _buildConditionChart(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTemperatureChart() {
    if (_environmentalData.isEmpty) {
      return const _EmptyChart(title: 'Temperature Trend');
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Temperature Trend',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        _environmentalData.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          _environmentalData[index]['temperature']?.toDouble() ?? 0,
                        ),
                      ),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHumidityChart() {
    if (_environmentalData.isEmpty) {
      return const _EmptyChart(title: 'Humidity Trend');
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Humidity Trend',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        _environmentalData.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          _environmentalData[index]['humidity']?.toDouble() ?? 0,
                        ),
                      ),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart() {
    if (_environmentalData.isEmpty) {
      return const _EmptyChart(title: 'Activity Index');
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Index',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  barGroups: List.generate(
                    _environmentalData.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: (_environmentalData[index]['activityIndex']?.toDouble() ?? 0) * 100,
                          color: Colors.green,
                          width: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionChart() {
    if (_predictions.isEmpty) {
      return const _EmptyChart(title: 'Predicted Condition Over Time');
    }

    final conditionCounts = <String, int>{};
    for (var pred in _predictions) {
      final condition = pred['conditionType'] ?? 'unknown';
      conditionCounts[condition] = (conditionCounts[condition] ?? 0) + 1;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Predicted Condition Over Time',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: conditionCounts.entries.map((entry) {
                    Color color;
                    switch (entry.key) {
                      case 'stressed':
                        color = Colors.red;
                        break;
                      case 'hungry':
                        color = Colors.orange;
                        break;
                      case 'normal':
                        color = Colors.green;
                        break;
                      default:
                        color = Colors.grey;
                    }
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${entry.key}\n${entry.value}',
                      color: color,
                      radius: 80,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  final String title;

  const _EmptyChart({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              height: 200,
              child: Center(
                child: Text('No data available'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

