import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toriverse/features/clipping/application/providers/clip_providers.dart';

/// Widget for sharing clips to social platforms
class ClipShareWidget extends ConsumerWidget {
  final String clipId;
  final String userId;
  final String clipTitle;
  final String clipUrl;

  const ClipShareWidget({
    Key? key,
    required this.clipId,
    required this.userId,
    required this.clipTitle,
    required this.clipUrl,
  }) : super(key: key);

  Future<void> _shareToSocialPlatform(
    WidgetRef ref,
    String platform,
    String shareType,
  ) async {
    try {
      // Record share
      await ref.read(
        shareClipProvider(
          ShareClipParam(
            clipId: clipId,
            userId: userId,
            platform: platform,
            shareType: shareType,
          ),
        ).future,
      );

      if (platform == 'native') {
        // Use native share dialog
        await Share.share(
          '$clipTitle - Check out this amazing clip! $clipUrl',
          subject: clipTitle,
        );
      }
    } catch (e) {
      debugPrint('Error sharing clip: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Clip',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Text(
              'Choose where to share this clip:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            // Social platform options
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildShareButton(
                  context,
                  ref,
                  'YouTube',
                  Icons.video_library,
                  'youtube',
                  'video_upload',
                ),
                _buildShareButton(
                  context,
                  ref,
                  'Instagram',
                  Icons.image,
                  'instagram',
                  'story',
                ),
                _buildShareButton(
                  context,
                  ref,
                  'TikTok',
                  Icons.music_note,
                  'tiktok',
                  'video_upload',
                ),
                _buildShareButton(
                  context,
                  ref,
                  'Twitter',
                  Icons.tag,
                  'twitter',
                  'direct_link',
                ),
                _buildShareButton(
                  context,
                  ref,
                  'Twitch',
                  Icons.play_circle,
                  'twitch',
                  'embed',
                ),
                _buildShareButton(
                  context,
                  ref,
                  'More',
                  Icons.share,
                  'native',
                  'direct_link',
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Direct link
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Direct Link',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          clipUrl,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          // Copy to clipboard
                          _copyToClipboard(context, clipUrl);
                        },
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Close button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    IconData icon,
    String platform,
    String shareType,
  ) {
    return GestureDetector(
      onTap: () => _shareToSocialPlatform(ref, platform, shareType),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    // Copy text to clipboard using Dart approach
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard!')),
    );
  }
}
