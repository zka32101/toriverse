import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/riverpod.dart';
import '../../data/models/user_public_profile_model.dart';
import '../../domain/services/social_discovery_service.dart';
import 'friend_providers.dart';

// Service provider
final socialDiscoveryServiceProvider = Provider<SocialDiscoveryService>((ref) {
  final firestore = FirebaseFirestore.instance;
  return SocialDiscoveryService(firestore);
});

// User search results by query
final userSearchProvider = FutureProvider.family<List<UserPublicProfile>, String>(
  (ref, query) async {
    if (query.isEmpty) {
      return [];
    }

    final service = ref.watch(socialDiscoveryServiceProvider);
    return service.searchUsers(query, limit: 20);
  },
);

// Public profile for a user
final publicProfileProvider =
    FutureProvider.family<UserPublicProfile?, String>((ref, uid) async {
  final service = ref.watch(socialDiscoveryServiceProvider);
  return service.getUserPublicProfile(uid);
});

// Watch public profile as a stream
final watchPublicProfileProvider =
    StreamProvider.family<UserPublicProfile?, String>(
  (ref, uid) {
    final service = ref.watch(socialDiscoveryServiceProvider);
    return service.watchUserPublicProfile(uid);
  },
);

// Recent players
final recentPlayersProvider =
    FutureProvider<List<UserPublicProfile>>((ref) async {
  final uid = ref.watch(currentUserUidProvider);
  if (uid == null) {
    return [];
  }

  final service = ref.watch(socialDiscoveryServiceProvider);
  return service.getRecentPlayers(uid, limit: 10);
});

// Leaderboard by rank points
final leaderboardByRankProvider =
    FutureProvider<List<UserPublicProfile>>((ref) async {
  final service = ref.watch(socialDiscoveryServiceProvider);
  return service.getLeaderboard(sortBy: 'rankPoints', limit: 100);
});

// Leaderboard by followers
final leaderboardByFollowersProvider =
    FutureProvider<List<UserPublicProfile>>((ref) async {
  final service = ref.watch(socialDiscoveryServiceProvider);
  return service.getLeaderboard(sortBy: 'followers', limit: 100);
});

// Leaderboard by social rank
final leaderboardBySocialRankProvider =
    FutureProvider<List<UserPublicProfile>>((ref) async {
  final service = ref.watch(socialDiscoveryServiceProvider);
  return service.getLeaderboard(sortBy: 'socialRank', limit: 100);
});

// Check if following a user
final isFollowingProvider = FutureProvider.family<bool, String>(
  (ref, followingUid) async {
    final uid = ref.watch(currentUserUidProvider);
    if (uid == null) {
      return false;
    }

    final service = ref.watch(socialDiscoveryServiceProvider);
    return service.isFollowing(followerUid: uid, followingUid: followingUid);
  },
);

// Follower count
final followerCountProvider =
    FutureProvider.family<int, String>((ref, uid) async {
  final service = ref.watch(socialDiscoveryServiceProvider);
  return service.getFollowerCount(uid);
});

// Following count
final followingCountProvider =
    FutureProvider.family<int, String>((ref, uid) async {
  final service = ref.watch(socialDiscoveryServiceProvider);
  return service.getFollowingCount(uid);
});

// Following list stream
final followingListProvider = StreamProvider<List<UserPublicProfile>>((ref) {
  final uid = ref.watch(currentUserUidProvider);
  if (uid == null) {
    return Stream.value([]);
  }

  final service = ref.watch(socialDiscoveryServiceProvider);
  return service.getFollowingStream(uid);
});

// Social discovery notifier
class SocialDiscoveryNotifier extends StateNotifier<AsyncValue<void>> {
  final SocialDiscoveryService _service;
  final Ref _ref;

  SocialDiscoveryNotifier(this._service, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> followUser({
    required String followerUid,
    required String followingUid,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.followUser(
        followerUid: followerUid,
        followingUid: followingUid,
      );
      _ref.invalidate(isFollowingProvider(followingUid));
      _ref.invalidate(followerCountProvider(followingUid));
      _ref.invalidate(followingCountProvider(followerUid));
      _ref.invalidate(followingListProvider);
      _ref.invalidate(watchPublicProfileProvider(followingUid));
    });
  }

  Future<void> unfollowUser({
    required String followerUid,
    required String followingUid,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.unfollowUser(
        followerUid: followerUid,
        followingUid: followingUid,
      );
      _ref.invalidate(isFollowingProvider(followingUid));
      _ref.invalidate(followerCountProvider(followingUid));
      _ref.invalidate(followingCountProvider(followerUid));
      _ref.invalidate(followingListProvider);
      _ref.invalidate(watchPublicProfileProvider(followingUid));
    });
  }
}

final socialDiscoveryNotifierProvider =
    StateNotifierProvider<SocialDiscoveryNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(socialDiscoveryServiceProvider);
  return SocialDiscoveryNotifier(service, ref);
});
