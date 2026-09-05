import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/leaderboards_and_social.dart';
import 'repository_provider.dart';

part 'search_and_lfg_providers.freezed.dart';
part 'search_and_lfg_providers.g.dart';

// ============================================================================
// PARAMETER CLASSES (Freezed)
// ============================================================================

@freezed
class SearchParam with _$SearchParam {
  const factory SearchParam(String query, int limit) = _SearchParam;
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
// STREAM PROVIDERS (Real-time)
// ============================================================================

@riverpod
Stream<List<LFGPost>> watchLFGPosts(
  WatchLFGPostsRef ref,
  LFGParam param,
) async* {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  yield* repository.watchLFGPosts(param.skillLevel);
}

// ============================================================================
// FUTURE PROVIDERS (Async)
// ============================================================================

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
Future<List<UserProfile>> verifiedUsers(
  VerifiedUsersRef ref,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  return repository.getVerifiedUsers();
}
