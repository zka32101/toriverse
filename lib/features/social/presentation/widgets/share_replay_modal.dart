import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modal widget for sharing replay videos
class ShareReplayModal extends StatelessWidget {
  final String replayId;
  final String replayTitle;
  final String? shareLink;
  final VoidCallback? onShareLink;
  final VoidCallback? onGenerateQR;

  const ShareReplayModal({
    Key? key,
    required this.replayId,
    required this.replayTitle,
    this.shareLink,
    this.onShareLink,
    this.onGenerateQR,
  }) : super(key: key);

  void _copyToClipboard(BuildContext context) {
    if (shareLink != null) {
      Clipboard.setData(ClipboardData(text: shareLink!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultLink = 'toriverse.app/replay/$replayId';
    final link = shareLink ?? defaultLink;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share "$replayTitle"',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          // Share link section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share Link',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                SelectableText(
                  link,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _copyToClipboard(context),
                  icon: const Icon(Icons.content_copy),
                  label: const Text('Copy Link'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // QR code option
          OutlinedButton.icon(
            onPressed: onGenerateQR ?? () {},
            icon: const Icon(Icons.qr_code_2),
            label: const Text('Generate QR Code'),
          ),

          const SizedBox(height: 12),

          // Direct share options
          Text(
            'Share via',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _ShareOptionButton(
                icon: Icons.message,
                label: 'SMS',
                onTap: () {
                  // Share via SMS
                },
              ),
              _ShareOptionButton(
                icon: Icons.mail,
                label: 'Email',
                onTap: () {
                  // Share via email
                },
              ),
              _ShareOptionButton(
                icon: Icons.share,
                label: 'More',
                onTap: () {
                  // Show native share sheet
                },
              ),
              _ShareOptionButton(
                icon: Icons.close,
                label: 'Close',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShareOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShareOptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
