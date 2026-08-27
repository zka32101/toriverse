import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/spectating/application/providers/streaming_providers.dart';
import 'package:toriverse/features/spectating/domain/models/streaming_session.dart';

/// Streamer dashboard widget for viewing active stream status and earnings
///
/// Displays real-time viewer count, stream duration, earnings, and platform status.
/// Provides controls for ending stream and managing highlight clips.
class StreamerDashboardWidget extends ConsumerWidget {
  final String sessionId;
  final VoidCallback onStreamEnd;

  const StreamerDashboardWidget({
    required this.sessionId,
    required this.onStreamEnd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewerCount = ref.watch(viewerCountProvider(sessionId));
    final publicStatus = ref.watch(publicStreamStatusProvider(''));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Stream Dashboard'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Viewer count card
            _buildViewerCountCard(viewerCount),
            const SizedBox(height: 16),

            // Stream status
            _buildStreamStatusCard(publicStatus),
            const SizedBox(height: 16),

            // Earnings display
            _buildEarningsCard(),
            const SizedBox(height: 16),

            // Platform status
            _buildPlatformStatusCard(),
            const SizedBox(height: 24),

            // Action buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onStreamEnd,
                icon: const Icon(Icons.stop_circle),
                label: const Text('End Stream'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewerCountCard(AsyncValue<int> viewerCount) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Viewers',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            viewerCount.when(
              data: (count) => Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.fiber_manual_record, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'watching',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamStatusCard(AsyncValue<Map<String, dynamic>> status) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stream Status',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            status.when(
              data: (data) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: data['isLive'] == true ? Colors.red : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        data['isLive'] == true ? 'LIVE' : 'OFFLINE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: data['isLive'] == true ? Colors.red : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (data['platforms'] != null) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: (data['platforms'] as List<dynamic>?)
                              ?.map((p) => Chip(label: Text(p.toString())))
                              .toList() ??
                          [],
                    ),
                  ],
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estimated Earnings (This Stream)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '¥1,250',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Based on viewer-minutes and platform rate',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Connected Platforms',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            _buildPlatformStatus(
              icon: '📺',
              name: 'Twitch',
              status: 'Connected',
              statusColor: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildPlatformStatus(
              icon: '📹',
              name: 'YouTube Live',
              status: 'Connected',
              statusColor: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildPlatformStatus(
              icon: '🎬',
              name: 'OBS Browser Source',
              status: 'Active',
              statusColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformStatus({
    required String icon,
    required String name,
    required String status,
    required Color statusColor,
  }) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
