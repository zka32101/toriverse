import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/leaderboards_and_social_providers.dart';
import '../../domain/models/leaderboards_and_social.dart';

class FriendsSocialWidget extends ConsumerWidget {
  final String userId;

  const FriendsSocialWidget({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(userFriendsProvider(UserIdParam(userId)));
    final followersAsync = ref.watch(userFollowersProvider(UserIdParam(userId)));

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Friends'),
              Tab(text: 'Followers'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Friends tab
                friendsAsync.when(
                  data: (friends) => _buildFriendsList(context, friends),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text('Error loading friends: $error'),
                  ),
                ),
                // Followers tab
                followersAsync.when(
                  data: (followers) => _buildFollowersList(context, followers),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text('Error loading followers: $error'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsList(BuildContext context, List<Friend> friends) {
    if (friends.isEmpty) {
      return const Center(
        child: Text('No friends yet. Add some friends!'),
      );
    }

    return ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return _FriendTile(friend: friend);
      },
    );
  }

  Widget _buildFollowersList(BuildContext context, List<Follower> followers) {
    if (followers.isEmpty) {
      return const Center(
        child: Text('No followers yet'),
      );
    }

    return ListView.builder(
      itemCount: followers.length,
      itemBuilder: (context, index) {
        final follower = followers[index];
        return _FollowerTile(follower: follower);
      },
    );
  }
}

class _FriendTile extends ConsumerWidget {
  final Friend friend;

  const _FriendTile({
    Key? key,
    required this.friend,
  }) : super(key: key);

  Color _getStatusColor(FriendStatus status) {
    switch (status) {
      case FriendStatus.accepted:
        return Colors.green;
      case FriendStatus.pending:
        return Colors.orange;
      case FriendStatus.rejected:
        return Colors.red;
    }
  }

  String _getStatusText(FriendStatus status) {
    switch (status) {
      case FriendStatus.accepted:
        return 'Online';
      case FriendStatus.pending:
        return 'Pending';
      case FriendStatus.rejected:
        return 'Blocked';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: Text(friend.friendId[0].toUpperCase()),
        ),
        title: Text('Friend ${friend.friendId.substring(0, 8)}'),
        subtitle: Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _getStatusColor(friend.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _getStatusText(friend.status),
            style: TextStyle(
              fontSize: 11,
              color: _getStatusColor(friend.status),
            ),
          ),
        ),
        trailing: friend.isFavorite
            ? const Icon(Icons.star, color: Colors.amber)
            : null,
        onTap: () {
          // Navigate to friend profile or open DM
        },
      ),
    );
  }
}

class _FollowerTile extends StatelessWidget {
  final Follower follower;

  const _FollowerTile({
    Key? key,
    required this.follower,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: Text(follower.followerId[0].toUpperCase()),
        ),
        title: Text('User ${follower.followerId.substring(0, 8)}'),
        subtitle: Text(
          'Followed ${follower.followedAt.difference(DateTime.now()).inDays} days ago',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: follower.isNotificationEnabled
            ? const Icon(Icons.notifications_active, color: Colors.blue)
            : const Icon(Icons.notifications_off),
        onTap: () {
          // Navigate to follower profile
        },
      ),
    );
  }
}
