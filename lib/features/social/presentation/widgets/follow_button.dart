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
        loading: () => OutlinedButton.icon(
          onPressed: null,
          icon: const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          label: const Text('Follow'),
        ),
        error: (err, stack) => OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.favorite_border),
          label: const Text('Follow'),
        ),
      ),
      loading: () => OutlinedButton.icon(
        onPressed: null,
        icon: const SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        label: const Text('Follow'),
      ),
      error: (err, stack) => OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.favorite_border),
        label: const Text('Follow'),
      ),
    );
  }
}
