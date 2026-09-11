/// Riverpod providers for leaderboard state management and real-time updates
///
/// Provides cached access to leaderboard data, player rankings, and streaming
/// listeners for real-time leaderboard updates.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../leaderboard/domain/models/leaderboard_models.dart';
import '../../../leaderboard/application/services/leaderboard_service.dart';

/// Singleton instance of LeaderboardService
final leaderboardServiceProvider = Provider((ref) {
  return LeaderboardService();
});

/// Global leaderboard provider (top 100 players)
///
/// Fetches the current global leaderboard with proper ranking.
/// Rebuilds when manually invalidated or on periodic refresh.
final globalLeaderboardProvider =
    FutureProvider.family<Leaderboard, int>((ref, limit) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getGlobalLeaderboard(limit: limit);
});

/// Player's current rank provider
///
/// Fetches the player's position in the global leaderboard.
/// Returns null if player is not ranked.
final playerRankProvider =
    FutureProvider.family<int?, String>((ref, uid) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getPlayerRank(uid);
});

/// Player's leaderboard entry provider
///
/// Fetches complete leaderboard data for a specific player including
/// rank, points, win rate, and streak information.
final playerLeaderboardEntryProvider =
    FutureProvider.family<PlayerLeaderboardEntry?, String>((ref, uid) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getPlayerEntry(uid);
});

/// Players near a specific rank provider
///
/// Fetches the leaderboard around a player's rank for contextual viewing.
/// Useful for showing "you are here" with surrounding players.
final playersNearRankProvider = FutureProvider.family<
    List<PlayerLeaderboardEntry>,
    ({String uid, int radius})>((ref, params) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getPlayersNearRank(
    params.uid,
    radius: params.radius,
  );
});

/// Username search provider
///
/// Searches leaderboard entries by username prefix.
/// Useful for finding specific players.
final searchPlayersByUsernameProvider =
    FutureProvider.family<List<PlayerLeaderboardEntry>, String>((ref, query) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.searchByUsername(query, limit: 20);
});

/// Stream global leaderboard changes
///
/// Real-time listener for leaderboard updates. Use this to show live
/// rank changes as other players complete matches.
final streamGlobalLeaderboardProvider =
    StreamProvider.family<Leaderboard, int>((ref, limit) {
  final service = ref.watch(leaderboardServiceProvider);
  return service.streamGlobalLeaderboard(limit: limit);
});

/// Stream player's leaderboard entry
///
/// Real-time listener for a specific player's entry. Updates when:
/// - Player's rank points change
/// - Player's rank position changes
/// - Player completes a match
final streamPlayerEntryProvider =
    StreamProvider.family<PlayerLeaderboardEntry?, String>((ref, uid) {
  final service = ref.watch(leaderboardServiceProvider);
  return service.streamPlayerEntry(uid);
});

/// Top friends leaderboard provider
///
/// Fetches rankings for a player's friend list.
/// Useful for displaying friend-only competitive rankings.
final topFriendsLeaderboardProvider = FutureProvider.family<
    List<PlayerLeaderboardEntry>,
    ({String uid, List<String> friendUids, int limit})>((ref, params) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getTopFriends(
    params.uid,
    params.friendUids,
    limit: params.limit,
  );
});

/// Player rank points updater notifier
///
/// Used to update rank points and trigger rebuilds of dependent providers.
/// Automatically invalidates related caches.
final playerRankUpdateNotifierProvider =
    StateNotifierProvider.family<PlayerRankUpdateNotifier, void, String>(
        (ref, uid) {
  final service = ref.watch(leaderboardServiceProvider);
  return PlayerRankUpdateNotifier(uid, service, ref);
});

/// Leaderboard refresh trigger
///
/// Use this to manually trigger a refresh of all leaderboard data.
/// Useful after a match completes or when user taps "refresh".
final leaderboardRefreshProvider = Provider((ref) {
  return () {
    ref.invalidate(globalLeaderboardProvider);
    ref.invalidate(playerRankProvider);
    ref.invalidate(playerLeaderboardEntryProvider);
  };
});

/// State notifier for handling rank updates
class PlayerRankUpdateNotifier extends StateNotifier<void> {
  final String uid;
  final LeaderboardService _leaderboardService;
  final Ref _ref;

  PlayerRankUpdateNotifier(this.uid, this._leaderboardService, this._ref)
      : super(null);

  /// Update player's rank points
  ///
  /// Updates the player's rank and invalidates all dependent caches.
  /// Called after a match completes to award/deduct points.
  Future<void> updateRankPoints({
    required int pointsChange,
    required String reason,
  }) async {
    try {
      await _leaderboardService.updatePlayerRankPoints(
        uid: uid,
        pointsChange: pointsChange,
        reason: reason,
      );

      // Invalidate related caches to trigger rebuilds
      _ref.invalidate(playerLeaderboardEntryProvider);
      _ref.invalidate(playerRankProvider);
      _ref.invalidate(globalLeaderboardProvider);
      _ref.invalidate(playersNearRankProvider);
    } catch (e) {
      rethrow;
    }
  }

  /// Initialize player in leaderboard
  ///
  /// Called after first match to create leaderboard entry.
  Future<void> initializeLeaderboardEntry({
    required String username,
  }) async {
    try {
      await _leaderboardService.initializePlayerLeaderboard(
        uid: uid,
        username: username,
      );

      // Invalidate related caches
      _ref.invalidate(playerLeaderboardEntryProvider);
      _ref.invalidate(playerRankProvider);
      _ref.invalidate(globalLeaderboardProvider);
    } catch (e) {
      rethrow;
    }
  }
}
