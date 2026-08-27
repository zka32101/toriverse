import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/clipping/application/providers/clip_providers.dart';

/// Widget for displaying trending clips
class TrendingClipsWidget extends ConsumerWidget {
  const TrendingClipsWidget({Key? key}) : super(key: key);

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
    final trendingAsync = ref.watch(watchTrendingClipsProvider);

    return trendingAsync.when(
      data: (clips) {
        if (clips.isEmpty) {
          return const Center(child: Text('No trending clips yet'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: clips.length,
          itemBuilder: (context, index) {
            final clip = clips[index];
            final rank = int.tryParse(clip.rank) ?? (index + 1);

            return _buildTrendingClipCard(
              context,
              rank,
              clip,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading trending clips: $error'),
      ),
    );
  }

  Widget _buildTrendingClipCard(
    BuildContext context,
    int rank,
    dynamic clip,
  ) {
    final views24h = clip.viewsLast24h ?? 0;
    final shares24h = clip.sharesLast24h ?? 0;
    final totalViews = clip.totalViews ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rank and title row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rank badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getRankColor(rank),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Title and info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clip.title ?? 'Untitled Clip',
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (clip.isFeatured ?? false)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Featured',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Metrics row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMetricColumn(
                  context,
                  Icons.visibility,
                  _formatNumber(views24h),
                  'Views (24h)',
                ),
                _buildMetricColumn(
                  context,
                  Icons.share,
                  _formatNumber(shares24h),
                  'Shares (24h)',
                ),
                _buildMetricColumn(
                  context,
                  Icons.trending_up,
                  '${(clip.trendingVelocity ?? 0.0).toStringAsFixed(2)}x',
                  'Velocity',
                ),
                _buildMetricColumn(
                  context,
                  Icons.all_inclusive,
                  _formatNumber(totalViews),
                  'Total Views',
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Trending started date
            if (clip.trendingStartedAt != null)
              Text(
                'Trending since: ${_formatDate(clip.trendingStartedAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) {
      return Colors.amber;
    } else if (rank == 2) {
      return Colors.grey.shade400;
    } else if (rank == 3) {
      return Colors.orange.shade700;
    }
    return Colors.blue;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
