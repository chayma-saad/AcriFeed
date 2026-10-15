import 'package:flutter/material.dart';

class ConditionOverlay extends StatelessWidget {
  final String condition;
  final double confidence;

  const ConditionOverlay({
    super.key,
    required this.condition,
    required this.confidence,
  });

  Color _getConditionColor() {
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

  IconData _getConditionIcon() {
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

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _getConditionColor().withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getConditionIcon(),
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Condition: ${condition.toUpperCase()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Confidence: ${(confidence * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

