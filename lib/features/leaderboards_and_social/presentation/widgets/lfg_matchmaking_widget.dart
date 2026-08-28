import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/leaderboards_and_social_providers.dart';
import '../../domain/models/leaderboards_and_social.dart';

class LFGMatchmakingWidget extends ConsumerWidget {
  final SkillLevel skillLevel;

  const LFGMatchmakingWidget({
    Key? key,
    this.skillLevel = SkillLevel.intermediate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lfgAsync = ref.watch(watchLFGPostsProvider(LFGParam(skillLevel, 50)));

    return lfgAsync.when(
      data: (posts) => _buildLFGView(context, posts),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading LFG posts: $error'),
      ),
    );
  }

  Widget _buildLFGView(BuildContext context, List<LFGPost> posts) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header with create button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Looking for Group',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Open create LFG post dialog
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create'),
                ),
              ],
            ),
          ),
          // LFG posts list
          if (posts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text('No LFG posts available'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return _LFGPostCard(post: post);
              },
            ),
        ],
      ),
    );
  }
}

class _LFGPostCard extends StatelessWidget {
  final LFGPost post;

  const _LFGPostCard({
    Key? key,
    required this.post,
  }) : super(key: key);

  String _getSkillLevelLabel(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return 'Beginner';
      case SkillLevel.intermediate:
        return 'Intermediate';
      case SkillLevel.advanced:
        return 'Advanced';
    }
  }

  Color _getSkillLevelColor(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return Colors.green;
      case SkillLevel.intermediate:
        return Colors.blue;
      case SkillLevel.advanced:
        return Colors.red;
    }
  }

  String _getTimePosted(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final spotsRemaining = post.maxParticipants - post.applicantIds.length;
    final isFull = post.fillStatus == LFGFillStatus.closed;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: title and skill level
            Row(
              children: [
                Expanded(
                  child: Text(
                    post.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSkillLevelColor(post.skillLevel).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getSkillLevelLabel(post.skillLevel),
                    style: TextStyle(
                      fontSize: 11,
                      color: _getSkillLevelColor(post.skillLevel),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              post.description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Match type and platforms
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    post.matchType,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: post.preferredPlatforms
                          .map((platform) => Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              platform,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.blue,
                              ),
                            ),
                          ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Footer: spots and posted time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spots: ${spotsRemaining.clamp(0, post.maxParticipants)}/${post.maxParticipants}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: spotsRemaining > 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      _getTimePosted(post.createdAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: isFull ? null : () {
                    // Join LFG post
                  },
                  icon: const Icon(Icons.person_add, size: 18),
                  label: Text(isFull ? 'Full' : 'Join'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFull ? Colors.grey : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
