import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/replay_providers.dart';
import '../../application/providers/friend_providers.dart';

/// Screen for playing and sharing replay videos
class ReplayPlayerScreen extends ConsumerStatefulWidget {
  final String replayId;

  const ReplayPlayerScreen({
    Key? key,
    required this.replayId,
  }) : super(key: key);

  @override
  ConsumerState<ReplayPlayerScreen> createState() =>
      _ReplayPlayerScreenState();
}

class _ReplayPlayerScreenState extends ConsumerState<ReplayPlayerScreen> {
  bool _isPlaying = true;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Record that this replay was viewed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(replayNotifierProvider.notifier).recordReplayView(
        replayId: widget.replayId,
        viewerUid: ref.read(currentUserUidProvider) ?? '',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final replayAsync = ref.watch(watchReplayProvider(widget.replayId));
    final isFavoritedAsync = ref.watch(isFavoritedProvider(widget.replayId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Replay'),
      ),
      body: replayAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error loading replay: $err'),
        ),
        data: (replay) {
          if (replay == null) {
            return const Center(child: Text('Replay not found'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video player placeholder
                Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.black,
                  child: Center(
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),

                // Player controls placeholder
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: _totalDuration.inMilliseconds > 0
                            ? _currentPosition.inMilliseconds /
                                _totalDuration.inMilliseconds
                            : 0,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_currentPosition),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            _formatDuration(Duration(seconds: replay.duration ?? 0)),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Replay metadata
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        replay.title ?? 'Untitled Replay',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            child: Text(
                              replay.creatorUid.substring(0, 2).toUpperCase(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  replay.creatorUid,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
                                ),
                                Text(
                                  _formatDate(replay.createdAt),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn(
                            context,
                            icon: Icons.visibility,
                            value: '${replay.viewCount}',
                            label: 'Views',
                          ),
                          _buildStatColumn(
                            context,
                            icon: Icons.favorite,
                            value: '${replay.favoriteCount}',
                            label: 'Likes',
                          ),
                          _buildStatColumn(
                            context,
                            icon: Icons.share,
                            value: '${replay.shareCount}',
                            label: 'Shares',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Action buttons
                      if (replay.description != null)
                        Text(
                          replay.description!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          isFavoritedAsync.when(
                            data: (isFavorited) => ElevatedButton.icon(
                              onPressed: () {
                                ref
                                    .read(
                                      replayNotifierProvider.notifier,
                                    )
                                    .toggleFavoriteReplay(
                                      replayId: widget.replayId,
                                      userUid: ref.read(
                                            currentUserUidProvider,
                                          ) ??
                                          '',
                                    );
                              },
                              icon: Icon(
                                isFavorited
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              label: const Text('Like'),
                            ),
                            loading: () => const ElevatedButton.icon(
                              onPressed: null,
                              icon: SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              label: Text('Like'),
                            ),
                            error: (err, stack) => ElevatedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.favorite_border),
                              label: const Text('Like'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              ref
                                  .read(replayNotifierProvider.notifier)
                                  .incrementShareCount(widget.replayId);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Replay shared!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
