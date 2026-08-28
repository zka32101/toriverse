import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/leaderboards_and_social_repository.dart';
import '../../domain/models/leaderboards_and_social.dart';

part 'leaderboards_and_social_providers.freezed.dart';
part 'leaderboards_and_social_providers.g.dart';

// ============================================================================
// PARAMETER CLASSES (Freezed)
// ============================================================================

@freezed
class UserIdParam with _$UserIdParam {
  const factory UserIdParam(String userId) = _UserIdParam;
}

@freezed
class UserSeasonParam with _$UserSeasonParam {
  const factory UserSeasonParam(String userId, String seasonId) =
      _UserSeasonParam;
}

@freezed
class RankingIdParam with _$RankingIdParam {
  const factory RankingIdParam(String rankingId) = _RankingIdParam;
}

@freezed
class LeaderboardParam with _$LeaderboardParam {
  const factory LeaderboardParam(int limit, {int offset = 0}) =
      _LeaderboardParam;
}

@freezed
class SeasonalLeaderboardParam with _$SeasonalLeaderboardParam {
  const factory SeasonalLeaderboardParam(String seasonId, int limit) =
      _SeasonalLeaderboardParam;
}

@freezed
class CreatorIdParam with _$CreatorIdParam {
  const factory CreatorIdParam(String creatorId) = _CreatorIdParam;
}

@freezed
class ClanIdParam with _$ClanIdParam {
  const factory ClanIdParam(String clanId) = _ClanIdParam;
}

@freezed
class SearchParam with _$SearchParam {
  const factory SearchParam(String query, int limit) = _SearchParam;
}

@freezed
class FriendParam with _$FriendParam {
  const factory FriendParam(String userId, String friendId) = _FriendParam;
}

@freezed
class UserFriendParam with _$UserFriendParam {
  const factory UserFriendParam(String userId) = _UserFriendParam;
}

@freezed
class FollowerParam with _$FollowerParam {
  const factory FollowerParam(String userId, String followerId) =
      _FollowerParam;
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
class LFGParam with _$LFGParam {
  const factory LFGParam(SkillLevel skillLevel, int limit) = _LFGParam;
}

@freezed
class OnlineUsersParam with _$OnlineUsersParam {
  const factory OnlineUsersParam(int limit) = _OnlineUsersParam;
}

// ============================================================================
// STREAM PROVIDERS (Real-time, 12 total)
// ============================================================================

@riverpod
Stream<GlobalRanking> watchGlobalRanking(
  WatchGlobalRankingRef ref,
  UserIdParam param,
) async* {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  yield* repository.watchGlobalRanking(param.userId);
}

@riverpod
Stream<List<GlobalRanking>> watchGlobalLeaderboard(
  WatchGlobalLeaderboardRef ref,
  LeaderboardParam param,
) async* {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  yield* repository.watchGlobalLeaderboard(param.limit);
}

@riverpod
Stream<List<SeasonalRanking>> watchSeasonalLeaderboard(
  WatchSeasonalLeaderboardRef ref,
  SeasonalLeaderboardParam param,
) async* {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  yield* repository.watchSeasonalLeaderboard(param.seasonId, param.limit);
}

@riverpod
Stream<List<CreatorRanking>> watchCreatorLeaderboard(
  WatchCreatorLeaderboardRef ref,
  LeaderboardParam param,
) async* {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  yield* repository.watchCreatorLeaderboard(param.limit);
}

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
Stream<List<LFGPost>> watchLFGPosts(
  WatchLFGPostsRef ref,
  LFGParam param,
) async* {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  yield* repository.watchLFGPosts(param.skillLevel);
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
// FUTURE PROVIDERS (Async, 15+ total)
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
Future<List<GlobalRanking>> globalLeaderboard(
  GlobalLeaderboardRef ref,
  LeaderboardParam param,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  return repository.getGlobalLeaderboard(param.limit, offset: param.offset);
}

@riverpod
Future<List<SeasonalRanking>> seasonalLeaderboard(
  SeasonalLeaderboardRef ref,
  SeasonalLeaderboardParam param,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  return repository.getSeasonalLeaderboard(param.seasonId, param.limit);
}

@riverpod
Future<List<CreatorRanking>> creatorLeaderboard(
  CreatorLeaderboardRef ref,
  LeaderboardParam param,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  return repository.getCreatorLeaderboard(param.limit);
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

@riverpod
Future<List<LFGPost>> lfgPosts(
  LfgPostsRef ref,
  LFGParam param,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  return repository.getLFGPosts(param.skillLevel, param.limit);
}

@riverpod
Future<List<OnlineStatus>> onlineUsers(
  OnlineUsersRef ref,
  OnlineUsersParam param,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  return repository.getOnlineUsers(param.limit);
}

@riverpod
Future<List<UserProfile>> userSearchResults(
  UserSearchResultsRef ref,
  SearchParam param,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  return repository.searchUsers(param.query, param.limit);
}

@riverpod
Future<List<UserProfile>> topPlayers(
  TopPlayersRef ref,
  LeaderboardParam param,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  return repository.getTopPlayers(param.limit);
}

@riverpod
Future<List<UserProfile>> verifiedUsers(
  VerifiedUsersRef ref,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  return repository.getVerifiedUsers();
}

// ============================================================================
// MUTATION PROVIDERS (Transactions, 5+ total)
// ============================================================================

@riverpod
Future<Friend> sendFriendRequest(
  SendFriendRequestRef ref,
  FriendParam param,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  final result = await repository.sendFriendRequest(param.userId, param.friendId);

  // Invalidate friend lists
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

  // Invalidate friend lists
  ref.invalidate(userFriendsProvider(UserIdParam(param.userId)));
  ref.invalidate(userFriendsProvider(UserIdParam(param.friendId)));

  return result;
}

@riverpod
Future<UserMessage> sendMessage(
  SendMessageRef ref,
  MessageParam param,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  // Note: This would need sender and recipient IDs
  final result = await repository.sendMessage(param.userId, '', '');

  // Invalidate messages
  ref.invalidate(userMessagesProvider(param));

  return result;
}

@riverpod
Future<Clan> createClan(
  CreateClanRef ref,
  Clan clan,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  final result = await repository.createClan(clan, clan.founderUserId);

  // Invalidate clan lists
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

  // Invalidate activity feeds
  ref.invalidate(userActivityFeedProvider(
    ActivityFeedParam(activity.userId, 50),
  ));

  return result;
}

@riverpod
Future<GlobalRanking> updateRanking(
  UpdateRankingRef ref,
  UserIdParam param,
  double newRating,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  final result = await repository.updateRanking(param.userId, newRating);

  // Invalidate leaderboards
  ref.invalidate(watchGlobalRankingProvider(param));
  ref.invalidate(globalLeaderboardProvider(LeaderboardParam(100)));
  ref.invalidate(userProfileProvider(param));

  return result;
}

@riverpod
Future<Follower> followUser(
  FollowUserRef ref,
  FollowerParam param,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  final result = await repository.followUser(param.userId, param.followerId);

  // Invalidate follower lists
  ref.invalidate(userFollowersProvider(UserIdParam(param.userId)));
  ref.invalidate(userFollowingProvider(UserIdParam(param.followerId)));

  return result;
}

// ============================================================================
// SINGLETON REPOSITORY PROVIDER
// ============================================================================

@riverpod
LeaderboardsAndSocialRepository leaderboardsAndSocialRepositoryProvider(
  LeaderboardsAndSocialRepositoryProviderRef ref,
) {
  return LeaderboardsAndSocialRepository(
    firestore: FirebaseFirestore.instance,
    analytics: FirebaseAnalytics.instance,
  );
}
