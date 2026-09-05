import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/leaderboards_and_social.dart';
import 'repository_provider.dart';

part 'social_providers.freezed.dart';
part 'social_providers.g.dart';

// ============================================================================
// PARAMETER CLASSES (Freezed)
// ============================================================================

@freezed
class UserIdParam with _$UserIdParam {
  const factory UserIdParam(String userId) = _UserIdParam;
}

@freezed
class MessageParam with _$MessageParam {
  const factory MessageParam(String userId, int limit) = _MessageParam;
}

@freezed
class ActivityFeedParam with _$ActivityFeedParam {
  const factory ActivityFeedParam(String userId, int limit) =
      _ActivityFeedParam;
}

@freezed
class FollowerParam with _$FollowerParam {
  const factory FollowerParam(String userId, String followerId) =
      _FollowerParam;
}

@freezed
class FriendParam with _$FriendParam {
  const factory FriendParam(String userId, String friendId) = _FriendParam;
}

@freezed
class ClanIdParam with _$ClanIdParam {
  const factory ClanIdParam(String clanId) = _ClanIdParam;
}

// ============================================================================
// STREAM PROVIDERS (Real-time)
// ============================================================================

@riverpod
Stream<UserProfile> watchUserProfile(
  WatchUserProfileRef ref,
  UserIdParam param,
) async* {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  yield* repository.watchUserProfile(param.userId);
}

@riverpod
Stream<List<UserMessage>> watchUserMessages(
  WatchUserMessagesRef ref,
  UserIdParam param,
) async* {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  yield* repository.watchUserMessages(param.userId);
}

@riverpod
Stream<Clan> watchClan(
  WatchClanRef ref,
  ClanIdParam param,
) async* {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  yield* repository.watchClan(param.clanId);
}

@riverpod
Stream<List<ClanMembership>> watchClanMembers(
  WatchClanMembersRef ref,
  ClanIdParam param,
) async* {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  yield* repository.watchClanMembers(param.clanId);
}

@riverpod
Stream<List<ActivityFeed>> watchUserActivityFeed(
  WatchUserActivityFeedRef ref,
  ActivityFeedParam param,
) async* {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  yield* repository.watchUserActivityFeed(param.userId);
}

@riverpod
Stream<List<Follower>> watchUserFollowers(
  WatchUserFollowersRef ref,
  UserIdParam param,
) async* {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  yield* repository.watchUserFollowers(param.userId);
}

@riverpod
Stream<List<Friend>> watchUserFriends(
  WatchUserFriendsRef ref,
  UserIdParam param,
) async* {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  yield* repository.watchUserFriends(param.userId);
}

// ============================================================================
// FUTURE PROVIDERS (Async)
// ============================================================================

@riverpod
Future<UserProfile> userProfile(
  UserProfileRef ref,
  UserIdParam param,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  return repository.getUserProfile(param.userId);
}

@riverpod
Future<UserProfile> userStats(
  UserStatsRef ref,
  UserIdParam param,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  return repository.getUserStats(param.userId);
}

@riverpod
Future<List<Friend>> userFriends(
  UserFriendsRef ref,
  UserIdParam param,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  return repository.getUserFriends(param.userId);
}

@riverpod
Future<List<Follower>> userFollowers(
  UserFollowersRef ref,
  UserIdParam param,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  return repository.getUserFollowers(param.userId);
}

@riverpod
Future<List<Follower>> userFollowing(
  UserFollowingRef ref,
  UserIdParam param,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  return repository.getFollowingList(param.userId);
}

@riverpod
Future<List<UserMessage>> userMessages(
  UserMessagesRef ref,
  MessageParam param,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  return repository.getUserMessages(param.userId, param.limit);
}

@riverpod
Future<Clan> clan(
  ClanRef ref,
  ClanIdParam param,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  return repository.getClan(param.clanId);
}

@riverpod
Future<List<ClanMembership>> clanMembers(
  ClanMembersRef ref,
  ClanIdParam param,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  return repository.getClanMembers(param.clanId);
}

@riverpod
Future<List<ActivityFeed>> userActivityFeed(
  UserActivityFeedRef ref,
  ActivityFeedParam param,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  return repository.getUserActivityFeed(param.userId, param.limit);
}

// ============================================================================
// MUTATION PROVIDERS (Transactions)
// ============================================================================

@riverpod
Future<Friend> sendFriendRequest(
  SendFriendRequestRef ref,
  FriendParam param,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  final result = await repository.sendFriendRequest(param.userId, param.friendId);
  ref.invalidate(userFriendsProvider(UserIdParam(param.userId)));
  ref.invalidate(userFriendsProvider(UserIdParam(param.friendId)));
  return result;
}

@riverpod
Future<Friend> acceptFriendRequest(
  AcceptFriendRequestRef ref,
  FriendParam param,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  final result = await repository.acceptFriendRequest(param.userId, param.friendId);
  ref.invalidate(userFriendsProvider(UserIdParam(param.userId)));
  ref.invalidate(userFriendsProvider(UserIdParam(param.friendId)));
  return result;
}

@riverpod
Future<Follower> followUser(
  FollowUserRef ref,
  FollowerParam param,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  final result = await repository.followUser(param.userId, param.followerId);
  ref.invalidate(userFollowersProvider(UserIdParam(param.userId)));
  ref.invalidate(userFollowingProvider(UserIdParam(param.followerId)));
  return result;
}

@riverpod
Future<Clan> createClan(
  CreateClanRef ref,
  Clan clan,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  final result = await repository.createClan(clan, clan.founderUserId);
  ref.invalidate(clanProvider(ClanIdParam(clan.clanId)));
  return result;
}

@riverpod
Future<ActivityFeed> recordActivity(
  RecordActivityRef ref,
  ActivityFeed activity,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  final result = await repository.recordActivity(activity);
  ref.invalidate(userActivityFeedProvider(
    ActivityFeedParam(activity.userId, 50),
  ));
  return result;
}
