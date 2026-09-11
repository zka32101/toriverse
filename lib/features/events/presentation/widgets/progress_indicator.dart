import 'package:flutter/material.dart';

/// Custom progress indicator widget for events
class ProgressIndicator extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  final Color? backgroundColor;
  final Color? progressColor;

  const ProgressIndicator({
    Key? key,
    required this.label,
    required this.current,
    required this.max,
    this.backgroundColor,
    this.progressColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    final bgColor = backgroundColor ?? Colors.grey.shade200;
    final progColor = progressColor ?? Colors.blue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              '$current / $max',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: bgColor,
            valueColor: AlwaysStoppedAnimation<Color>(progColor),
          ),
        ),
      ],
    );
  }
}
