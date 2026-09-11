import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/replay_providers.dart';
import '../../data/models/replay_model.dart';

/// Card widget for displaying a replay in grid view
class ReplayCard extends ConsumerWidget {
  final Replay replay;
  final VoidCallback onTap;

  const ReplayCard({
    Key? key,
    required this.replay,
    required this.onTap,
  }) : super(key: key);

  void _showShareMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Replay',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copy Link'),
              onTap: () {
                // Copy replay link to clipboard
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard')),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_2),
              title: const Text('QR Code'),
              onTap: () {
                // Show QR code
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share via...'),
              onTap: () {
                ref
                    .read(replayNotifierProvider.notifier)
                    .incrementShareCount(replay.id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showShareMenu(context, ref),
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey[300],
                child: replay.thumbnail != null
                    ? Image.network(
                        replay.thumbnail!,
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Icon(
                          Icons.video_library,
                          size: 48,
                          color: Colors.grey[600],
                        ),
                      ),
              ),
            ),

            // Title and metadata
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    replay.title ?? 'Untitled',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    replay.creatorUid,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 4),

                  // Stats row
                  Row(
                    children: [
                      Icon(Icons.visibility, size: 12, color: Colors.grey),
                      const SizedBox(width: 2),
                      Text(
                        '${replay.viewCount}',
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.favorite, size: 12, color: Colors.red),
                      const SizedBox(width: 2),
                      Text(
                        '${replay.favoriteCount}',
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                      ),
                    ],
                  ),

                  // Tags
                  if (replay.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Wrap(
                        spacing: 4,
                        children: replay.tags
                            .take(2)
                            .map(
                              (tag) => Text(
                                tag,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.blue,
                                      fontSize: 10,
                                    ),
                              ),
                            )
                            .toList(),
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
}
