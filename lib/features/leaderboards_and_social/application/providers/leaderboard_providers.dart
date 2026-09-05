import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/leaderboards_and_social_repository.dart';
import '../../domain/models/leaderboards_and_social.dart';
import 'repository_provider.dart';

part 'leaderboard_providers.freezed.dart';
part 'leaderboard_providers.g.dart';

// ============================================================================
// PARAMETER CLASSES (Freezed)
// ============================================================================

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
class UserIdParam with _$UserIdParam {
  const factory UserIdParam(String userId) = _UserIdParam;
}

// ============================================================================
// STREAM PROVIDERS (Real-time)
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

// ============================================================================
// FUTURE PROVIDERS (Async)
// ============================================================================

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
Future<List<UserProfile>> topPlayers(
  TopPlayersRef ref,
  LeaderboardParam param,
) async {
  final repository = ref.watch(leaderboardsAndSocialRepositoryProvider);
  return repository.getTopPlayers(param.limit);
}
