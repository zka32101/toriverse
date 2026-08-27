import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/clipping/application/providers/clip_providers.dart';

/// Widget for displaying clip engagement metrics
class ClipMetricsWidget extends ConsumerWidget {
  final String clipId;

  const ClipMetricsWidget({
    Key? key,
    required this.clipId,
  }) : super(key: key);

  String _formatNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(
      clipMetricsProvider(ClipIdParam(clipId)),
    );

    return metricsAsync.when(
      data: (metrics) {
        if (metrics == null) {
          return const Center(child: Text('No metrics available'));
        }

        final platformMetrics = [
          ('YouTube', metrics.youtubeViews),
          ('Instagram', metrics.instagramViews),
          ('TikTok', metrics.tiktokViews),
          ('Twitter', metrics.twitterViews),
          ('Twitch', metrics.twitchViews),
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clip Metrics',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              // Main metrics cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildMetricCard(
                    context,
                    'Views',
                    _formatNumber(metrics.totalViews),
                    Icons.visibility,
                  ),
                  _buildMetricCard(
                    context,
                    'Likes',
                    _formatNumber(metrics.totalLikes),
                    Icons.thumb_up,
                  ),
                  _buildMetricCard(
                    context,
                    'Shares',
                    _formatNumber(metrics.totalShares),
                    Icons.share,
                  ),
                  _buildMetricCard(
                    context,
                    'Comments',
                    _formatNumber(metrics.totalComments),
                    Icons.comment,
                  ),
                  _buildMetricCard(
                    context,
                    'Clicks',
                    _formatNumber(metrics.totalClicks),
                    Icons.touch_app,
                  ),
                  _buildMetricCard(
                    context,
                    'Engagement Rate',
                    '${(metrics.avgEngagementRate * 100).toStringAsFixed(1)}%',
                    Icons.trending_up,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Platform breakdown
              Text(
                'Views by Platform',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ...platformMetrics.map((item) {
                final percentage = metrics.totalViews > 0
                    ? (item.$2 / metrics.totalViews * 100)
                    : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.$1),
                          Text(
                            '${_formatNumber(item.$2)} (${percentage.toStringAsFixed(1)}%)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 32),
              // Viral score
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Viral Score',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Popularity ranking',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${metrics.viralScore}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Last updated
              Text(
                'Last updated: ${metrics.updatedAt?.toString() ?? 'Never'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading metrics: $error'),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
