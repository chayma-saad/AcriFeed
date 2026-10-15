import 'package:flutter/material.dart';

class RecommendedActionsPanel extends StatelessWidget {
  final String condition;
  final String recommendedAction;
  final String explanation;

  const RecommendedActionsPanel({
    super.key,
    required this.condition,
    required this.recommendedAction,
    required this.explanation,
  });

  Color _getActionColor() {
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

  IconData _getActionIcon() {
    switch (condition.toLowerCase()) {
      case 'stressed':
        return Icons.water_drop;
      case 'hungry':
        return Icons.restaurant;
      case 'normal':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: _getActionColor().withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getActionIcon(),
                  color: _getActionColor(),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Recommended Action',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getActionColor(),
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getActionColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getActionColor().withOpacity(0.3)),
              ),
              child: Text(
                recommendedAction,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _getActionColor(),
                ),
              ),
            ),
            if (explanation.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                explanation,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

