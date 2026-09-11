import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/social_discovery_providers.dart';

/// Button widget for following/unfollowing users
class FollowButton extends ConsumerWidget {
  final String targetUid;
  final VoidCallback? onFollowChanged;

  const FollowButton({
    Key? key,
    required this.targetUid,
    this.onFollowChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFollowingAsync = ref.watch(isFollowingProvider(targetUid));
    final followerCountAsync = ref.watch(followerCountProvider(targetUid));

    return isFollowingAsync.when(
      data: (isFollowing) => followerCountAsync.when(
        data: (followerCount) => OutlinedButton.icon(
          onPressed: () {
            if (isFollowing) {
              ref
                  .read(socialDiscoveryNotifierProvider.notifier)
                  .unfollowUser(
                    followerUid: '', // Would be current user UID
                    followingUid: targetUid,
                  );
            } else {
              ref
                  .read(socialDiscoveryNotifierProvider.notifier)
                  .followUser(
                    followerUid: '', // Would be current user UID
                    followingUid: targetUid,
                  );
            }
            onFollowChanged?.call();
          },
          icon: Icon(
            isFollowing ? Icons.favorite : Icons.favorite_border,
          ),
          label: Text(
            isFollowing ? 'Following ($followerCount)' : 'Follow ($followerCount)',
          ),
        ),
        loading: () => const OutlinedButton.icon(
          onPressed: null,
          icon: SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          label: Text('Follow'),
        ),
        error: (err, stack) => const OutlinedButton.icon(
          onPressed: null,
          icon: Icon(Icons.favorite_border),
          label: Text('Follow'),
        ),
      ),
      loading: () => const OutlinedButton.icon(
        onPressed: null,
        icon: SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        label: Text('Follow'),
      ),
      error: (err, stack) => const OutlinedButton.icon(
        onPressed: null,
        icon: Icon(Icons.favorite_border),
        label: Text('Follow'),
      ),
    );
  }
}
