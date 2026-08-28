import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/analytics_and_moderation_providers.dart';
import '../../domain/models/analytics_and_moderation.dart';

class CreatorAnalyticsDashboardWidget extends ConsumerWidget {
  final String creatorId;

  const CreatorAnalyticsDashboardWidget({
    Key? key,
    required this.creatorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(watchCreatorAnalyticsDashboardProvider(creatorId));

    return dashboardAsync.when(
      data: (dashboard) => _buildDashboard(context, dashboard),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading analytics dashboard: $error'),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, CreatorAnalyticsDashboard dashboard) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics Dashboard',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Metric tiles
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _MetricTile(
                label: 'Total Views',
                value: dashboard.totalViews.toString(),
                icon: Icons.visibility,
              ),
              _MetricTile(
                label: 'Total Earnings',
                value: '\$${dashboard.totalEarnings.toStringAsFixed(2)}',
                icon: Icons.attach_money,
              ),
              _MetricTile(
                label: 'Follower Growth',
                value: '+${dashboard.followerGrowth}',
                icon: Icons.trending_up,
              ),
              _MetricTile(
                label: 'Engagement Rate',
                value: '${(dashboard.engagementRate * 100).toStringAsFixed(1)}%',
                icon: Icons.favorite,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Top Content',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (dashboard.topContent.isEmpty)
            const Text('No content performance data available yet')
          else
            ...dashboard.topContent.map(
              (content) => ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: Text(content['title']?.toString() ?? 'Untitled'),
                trailing: Text('${content['views'] ?? 0} views'),
              ),
            ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Trigger export flow
            },
            icon: const Icon(Icons.download),
            label: const Text('Export Report'),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricTile({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
