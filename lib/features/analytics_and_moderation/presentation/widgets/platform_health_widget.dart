import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/analytics_and_moderation_providers.dart';

/// Admin-only widget displaying platform-wide health metrics.
class PlatformHealthWidget extends ConsumerWidget {
  const PlatformHealthWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(watchPlatformHealthProvider);

    return healthAsync.when(
      data: (health) => _buildHealth(context, health),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading platform health: $error'),
      ),
    );
  }

  Widget _buildHealth(BuildContext context, Map<String, dynamic> health) {
    final errorRate = (health['errorRate'] as num?)?.toDouble() ?? 0.0;
    final apiLatencyP50 = (health['apiLatencyP50'] as num?)?.toDouble() ?? 0.0;
    final apiLatencyP99 = (health['apiLatencyP99'] as num?)?.toDouble() ?? 0.0;
    final cacheHitRate = (health['cacheHitRate'] as num?)?.toDouble() ?? 0.0;
    final isHealthy = errorRate < 0.01;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isHealthy ? Icons.check_circle : Icons.warning,
                color: isHealthy ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                isHealthy ? 'All Systems Operational' : 'Degraded Performance',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _HealthRow(label: 'Error Rate', value: '${(errorRate * 100).toStringAsFixed(2)}%'),
          _HealthRow(label: 'API Latency (p50)', value: '${apiLatencyP50.toStringAsFixed(0)}ms'),
          _HealthRow(label: 'API Latency (p99)', value: '${apiLatencyP99.toStringAsFixed(0)}ms'),
          _HealthRow(
            label: 'Cache Hit Rate',
            value: '${(cacheHitRate * 100).toStringAsFixed(1)}%',
          ),
        ],
      ),
    );
  }
}

class _HealthRow extends StatelessWidget {
  final String label;
  final String value;

  const _HealthRow({Key? key, required this.label, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
