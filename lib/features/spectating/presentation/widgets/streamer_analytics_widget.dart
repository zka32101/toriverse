import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/spectating/application/providers/influencer_program_providers.dart';

/// Streamer analytics dashboard widget
///
/// Displays comprehensive analytics for stream performance and earnings.
class StreamerAnalyticsWidget extends ConsumerWidget {
  final String userId;
  final DateTime periodStart;
  final DateTime periodEnd;

  const StreamerAnalyticsWidget({
    required this.userId,
    required this.periodStart,
    required this.periodEnd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(streamerAnalyticsProvider(
      _GetAnalyticsParams(
        userId: userId,
        periodStart: periodStart,
        periodEnd: periodEnd,
      ),
    ));

    return analytics.when(
      data: (data) => SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildKPIGrid(data),
            const SizedBox(height: 24),
            _buildRevenueCard(data),
            const SizedBox(height: 20),
            _buildViewershipCard(data),
            const SizedBox(height: 20),
            _buildClipsCard(data),
            const SizedBox(height: 20),
            _buildEngagementCard(data),
          ],
        ),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, stack) => Center(
        child: Text('Error: $err'),
      ),
    );
  }

  Widget _buildKPIGrid(dynamic data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildKPICard(
          title: 'Total Streams',
          value: data.totalStreams.toString(),
          icon: Icons.stream,
          color: Colors.blue,
        ),
        _buildKPICard(
          title: 'Stream Minutes',
          value: data.totalStreamMinutes.toString(),
          icon: Icons.timer,
          color: Colors.purple,
        ),
        _buildKPICard(
          title: 'Avg Viewers',
          value: data.avgViewerCount.toString(),
          icon: Icons.people,
          color: Colors.green,
        ),
        _buildKPICard(
          title: 'Peak Viewers',
          value: data.peakViewerCount.toString(),
          icon: Icons.trending_up,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard(dynamic data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildRevenueRow(
              'Stream Revenue',
              '¥${data.streamingRevenue.toStringAsFixed(0)}',
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildRevenueRow(
              'Clip Revenue',
              '¥${data.clipRevenue.toStringAsFixed(0)}',
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildRevenueRow(
              'Affiliate Commission',
              '¥${data.affiliateCommission.toStringAsFixed(0)}',
              Colors.purple,
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Revenue',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '¥${data.totalRevenue.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueRow(
    String label,
    String amount,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
        Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildViewershipCard(dynamic data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Viewership Stats',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              'Total Viewer-Minutes',
              data.totalViewerMinutes.toString(),
              'minutes watched across all streams',
            ),
            const SizedBox(height: 12),
            _buildStatItem(
              'Unique Viewers',
              data.totalUniqueViewers.toString(),
              'individual viewers this period',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClipsCard(dynamic data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Highlight Clips Performance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              'Clips Generated',
              data.totalClips.toString(),
              'auto-generated highlights',
            ),
            const SizedBox(height: 12),
            _buildStatItem(
              'Clip Views',
              data.totalClipViews.toString(),
              'total views across all clips',
            ),
            const SizedBox(height: 12),
            _buildStatItem(
              'Clip Shares',
              data.totalClipShares.toString(),
              'times shared to social media',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementCard(dynamic data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Engagement Metrics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildProgressStat(
              'Chat Engagement',
              data.engagementRate,
              'messages per viewer',
            ),
            const SizedBox(height: 12),
            _buildProgressStat(
              'Clip Engagement',
              data.clipEngagementRate,
              'views to shares ratio',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Engagement rates show how active your community is relative to viewership.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    String subtitle,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStat(
    String label,
    double value,
    String unit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              '${(value * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green[400]!),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          unit,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
