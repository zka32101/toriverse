import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/analytics_and_moderation_providers.dart';

class EngagementMetricsWidget extends ConsumerWidget {
  final String userId;

  const EngagementMetricsWidget({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoreAsync = ref.watch(userEngagementScoreProvider(userId));
    final sessionAsync = ref.watch(sessionAnalyticsProvider(userId));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Engagement',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          scoreAsync.when(
            data: (score) => Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Text('$score / 100'),
              ],
            ),
            loading: () => const LinearProgressIndicator(),
            error: (error, stack) => Text('Error: $error'),
          ),
          const SizedBox(height: 16),
          sessionAsync.when(
            data: (session) => Row(
              children: [
                _StatChip(
                  icon: Icons.timer,
                  label: '${session['sessionDuration'] ?? 0}s avg',
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.repeat,
                  label: '${session['sessionCount'] ?? 0} sessions',
                ),
              ],
            ),
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Error: $error'),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({Key? key, required this.icon, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
