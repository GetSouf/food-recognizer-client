import 'package:flutter/material.dart';

class ProgressBarWidget extends StatelessWidget {
  final String label;
  final double currentValue;
  final double? goalValue;
  final Color color;

  const ProgressBarWidget({
    super.key,
    required this.label,
    required this.currentValue,
    this.goalValue,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = goalValue != null && goalValue! > 0
        ? (currentValue / goalValue! * 100).clamp(0, 100)
        : null;
    final progress = goalValue != null ? (currentValue / goalValue!).clamp(0, 1).toDouble() : 0.5;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (percentage != null)
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
                ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            color: color,
            borderRadius: BorderRadius.circular(8),
            minHeight: 12,
          ),
          const SizedBox(height: 4),
          Text(
            '${currentValue.toStringAsFixed(1)} / ${goalValue?.toStringAsFixed(1) ?? 'N/A'} ${label.contains('Калории') ? 'ккал' : 'г'}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}