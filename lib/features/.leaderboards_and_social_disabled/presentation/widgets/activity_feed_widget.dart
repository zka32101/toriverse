import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/leaderboards_and_social_providers.dart';
import '../../domain/models/leaderboards_and_social.dart';

class ActivityFeedWidget extends ConsumerWidget {
  final String userId;
  final int limit;

  const ActivityFeedWidget({
    Key? key,
    required this.userId,
    this.limit = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(
      watchUserActivityFeedProvider(ActivityFeedParam(userId, limit)),
    );

    return feedAsync.when(
      data: (activities) => _buildActivityFeed(context, activities),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading activity feed: $error'),
      ),
    );
  }

  Widget _buildActivityFeed(
    BuildContext context,
    List<ActivityFeed> activities,
  ) {
    if (activities.isEmpty) {
      return const Center(
        child: Text('No activities yet'),
      );
    }

    return ListView.builder(
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _ActivityTile(activity: activity);
      },
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityFeed activity;

  const _ActivityTile({
    Key? key,
    required this.activity,
  }) : super(key: key);

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.matchWon:
        return Icons.sports_score;
      case ActivityType.tierUp:
        return Icons.trending_up;
      case ActivityType.tierDown:
        return Icons.trending_down;
      case ActivityType.clipViral:
        return Icons.videocam;
      case ActivityType.friendAdded:
        return Icons.person_add;
      case ActivityType.clanJoined:
        return Icons.groups;
      case ActivityType.clanPromoted:
        return Icons.star;
      case ActivityType.achievementUnlocked:
        return Icons.military_tech;
      case ActivityType.streakMilestone:
        return Icons.local_fire_department;
    }
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.matchWon:
        return Colors.green;
      case ActivityType.tierUp:
        return Colors.blue;
      case ActivityType.tierDown:
        return Colors.red;
      case ActivityType.clipViral:
        return Colors.purple;
      case ActivityType.friendAdded:
        return Colors.orange;
      case ActivityType.clanJoined:
        return Colors.amber;
      case ActivityType.clanPromoted:
        return Colors.cyan;
      case ActivityType.achievementUnlocked:
        return Colors.indigo;
      case ActivityType.streakMilestone:
        return Colors.red[400] ?? Colors.red;
    }
  }

  String _getActivityLabel(ActivityType type) {
    switch (type) {
      case ActivityType.matchWon:
        return 'Match Won!';
      case ActivityType.tierUp:
        return 'Ranked Up';
      case ActivityType.tierDown:
        return 'Ranked Down';
      case ActivityType.clipViral:
        return 'Clip Went Viral';
      case ActivityType.friendAdded:
        return 'Friend Added';
      case ActivityType.clanJoined:
        return 'Joined Clan';
      case ActivityType.clanPromoted:
        return 'Promoted in Clan';
      case ActivityType.achievementUnlocked:
        return 'Achievement Unlocked';
      case ActivityType.streakMilestone:
        return 'Streak Milestone';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${diff.inDays ~/ 7}w ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getActivityColor(activity.activityType).withOpacity(0.1),
              ),
              child: Center(
                child: Icon(
                  _getActivityIcon(activity.activityType),
                  color: _getActivityColor(activity.activityType),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getActivityLabel(activity.activityType),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (activity.metadata != null && activity.metadata!.isNotEmpty)
                    Text(
                      _buildActivityDescription(activity),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  if (activity.metadata == null || activity.metadata!.isEmpty)
                    Text(
                      'No details',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            Text(
              _formatTime(activity.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildActivityDescription(ActivityFeed activity) {
    final metadata = activity.metadata ?? {};

    if (activity.activityType == ActivityType.matchWon &&
        metadata.containsKey('opponent')) {
      return 'vs ${metadata['opponent']}';
    } else if (activity.activityType == ActivityType.clipViral &&
        metadata.containsKey('views')) {
      return '${metadata['views']} views';
    } else if (metadata.isNotEmpty) {
      return metadata.values.first.toString();
    }

    return '';
  }
}
