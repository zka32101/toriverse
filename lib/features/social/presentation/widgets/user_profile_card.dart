import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/social_discovery_providers.dart';
import '../../data/models/user_public_profile_model.dart';

/// Card widget displaying a user's public profile
class UserPublicProfileCard extends ConsumerWidget {
  final UserPublicProfile profile;
  final VoidCallback? onAddFriendTap;
  final VoidCallback? onMessageTap;
  final VoidCallback? onViewReplaysTap;

  const UserPublicProfileCard({
    Key? key,
    required this.profile,
    this.onAddFriendTap,
    this.onMessageTap,
    this.onViewReplaysTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFollowingAsync =
        ref.watch(isFollowingProvider(profile.uid));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar and name
            CircleAvatar(
              radius: 40,
              child: Text(
                profile.displayName.substring(0, 2).toUpperCase(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              profile.displayName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              '#${profile.uid}',
              style: Theme.of(context).textTheme.bodySmall,
            ),

            // Stats row
            if (profile.bio != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  profile.bio!,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

            // Rank and stats
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatColumn(
                    label: 'Rank',
                    value: '${profile.rankPoints}',
                  ),
                  _StatColumn(
                    label: 'Win Rate',
                    value: '${(profile.winRate * 100).toStringAsFixed(1)}%',
                  ),
                  _StatColumn(
                    label: 'Matches',
                    value: '${profile.totalMatches}',
                  ),
                  _StatColumn(
                    label: 'Followers',
                    value: '${profile.followers}',
                  ),
                ],
              ),
            ),

            // Favorite cosmetics preview
            if (profile.favoriteCosmetics.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Favorite Items',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: profile.favoriteCosmetics
                          .take(3)
                          .map(
                            (cosmetic) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Chip(
                                label: Text(cosmetic),
                                avatar: const Icon(Icons.star),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),

            // Action buttons
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (onAddFriendTap != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onAddFriendTap,
                            icon: const Icon(Icons.person_add),
                            label: const Text('Add Friend'),
                          ),
                        ),
                      if (onMessageTap != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onMessageTap,
                            icon: const Icon(Icons.message),
                            label: const Text('Message'),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (onViewReplaysTap != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onViewReplaysTap,
                        icon: const Icon(Icons.video_library),
                        label: const Text('View Replays'),
                      ),
                    ),
                ],
              ),
            ),

            // Follow button
            const SizedBox(height: 8),
            isFollowingAsync.when(
              data: (isFollowing) => SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (isFollowing) {
                      ref
                          .read(
                            socialDiscoveryNotifierProvider.notifier,
                          )
                          .unfollowUser(
                            followerUid: '', // Would be current user UID
                            followingUid: profile.uid,
                          );
                    } else {
                      ref
                          .read(
                            socialDiscoveryNotifierProvider.notifier,
                          )
                          .followUser(
                            followerUid: '', // Would be current user UID
                            followingUid: profile.uid,
                          );
                    }
                  },
                  icon: Icon(
                    isFollowing ? Icons.favorite : Icons.favorite_border,
                  ),
                  label: Text(
                    isFollowing ? 'Following' : 'Follow',
                  ),
                ),
              ),
              loading: () => const SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  label: Text('Follow'),
                ),
              ),
              error: (err, stack) => const SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.favorite_border),
                  label: Text('Follow'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }
}
