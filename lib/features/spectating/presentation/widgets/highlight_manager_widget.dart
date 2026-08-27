import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/spectating/application/providers/streaming_providers.dart';
import 'package:toriverse/features/spectating/domain/models/streaming_session.dart';

/// Highlight manager widget for viewing and managing auto-generated clips
///
/// Displays list of highlight clips generated during stream, allows approval,
/// deletion, and sharing of clips.
class HighlightManagerWidget extends ConsumerStatefulWidget {
  final String sessionId;

  const HighlightManagerWidget({
    required this.sessionId,
  });

  @override
  ConsumerState<HighlightManagerWidget> createState() =>
      _HighlightManagerWidgetState();
}

class _HighlightManagerWidgetState extends ConsumerState<HighlightManagerWidget> {
  @override
  Widget build(BuildContext context) {
    final highlightClips = ref.watch(highlightClipsProvider(widget.sessionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Highlight Clips'),
        elevation: 0,
      ),
      body: highlightClips.when(
        data: (clips) => clips.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(12.0),
                itemCount: clips.length,
                itemBuilder: (context, index) {
                  final clip = clips[index];
                  return _buildClipCard(context, clip);
                },
              ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Text('Error: $err'),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Highlights Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Highlight clips will be generated automatically\nwhen epic moments happen during your stream',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClipCard(BuildContext context, HighlightClip clip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => _showClipDetails(context, clip),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with type and approval status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail placeholder
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.video_library,
                        size: 40,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Clip info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          clip.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(clip.type),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${clip.type.emoji} ${clip.type.label}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Duration and views
                        Text(
                          '${_formatDuration(clip.startTime, clip.endTime)} • ${clip.viewCount} views',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),

                        // Approval status
                        if (!clip.isApproved) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Pending Approval',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.orange[900],
                              ),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Approved',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.green[900],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Action menu
                  PopupMenuButton<String>(
                    onSelected: (value) =>
                        _handleClipAction(context, clip, value),
                    itemBuilder: (BuildContext context) => [
                      if (!clip.isApproved)
                        const PopupMenuItem<String>(
                          value: 'approve',
                          child: Text('Approve'),
                        ),
                      const PopupMenuItem<String>(
                        value: 'share',
                        child: Text('Share'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),

              // Description
              if (clip.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  clip.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showClipDetails(BuildContext context, HighlightClip clip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(clip.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Type: ${clip.type.label}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                'Duration: ${_formatDuration(clip.startTime, clip.endTime)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                'Views: ${clip.viewCount}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                'Shares: ${clip.shareCount}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Text(
                clip.description,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleClipAction(context, clip, 'share');
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _handleClipAction(
    BuildContext context,
    HighlightClip clip,
    String action,
  ) {
    switch (action) {
      case 'approve':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clip approved and published')),
        );
        break;
      case 'share':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Share options will open')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context, clip);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, HighlightClip clip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Clip?'),
        content: Text('Are you sure you want to delete "${clip.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Clip deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(HighlightType type) {
    switch (type) {
      case HighlightType.milestone:
        return Colors.blue;
      case HighlightType.epic:
        return Colors.red;
      case HighlightType.turnover:
        return Colors.purple;
      case HighlightType.funny:
        return Colors.orange;
      case HighlightType.close_call:
        return Colors.yellow;
      case HighlightType.championship:
        return Colors.gold;
    }
  }

  String _formatDuration(Duration start, Duration end) {
    final duration = end.inSeconds - start.inSeconds;
    return '${duration}s';
  }
}

// Helper to display gold color
const gold = Color(0xFFFFD700);

extension ColorX on Color {
  static const gold = Color(0xFFFFD700);
}
