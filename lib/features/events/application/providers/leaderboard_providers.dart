import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/leaderboard_model.dart';
import '../../domain/services/event_leaderboard_service.dart';
import 'event_providers.dart';

// Event Leaderboard Service
final eventLeaderboardServiceProvider =
    Provider<EventLeaderboardService>((ref) {
  final firestore = ref.watch(firebaseProvider);
  return EventLeaderboardService(firestore);
});

// Watch leaderboard as stream
final leaderboardStreamProvider = StreamProvider.family<List<LeaderboardEntry>, String>(
  (ref, params) {
    final service = ref.watch(eventLeaderboardServiceProvider);
    final parts = params.split('|');
    final eventId = parts[0];
    final limit = parts.length > 1 ? int.tryParse(parts[1]) ?? 100 : 100;

    return service.watchLeaderboard(eventId, limit: limit);
  },
);

// Get leaderboard as future
final leaderboardFutureProvider =
    FutureProvider.family<List<LeaderboardEntry>, String>((ref, params) {
  final service = ref.watch(eventLeaderboardServiceProvider);
  final parts = params.split('|');
  final eventId = parts[0];
  final limit = parts.length > 1 ? int.tryParse(parts[1]) ?? 100 : 100;

  return service.getLeaderboard(eventId, limit: limit);
});

// Get user's rank entry in event
final userRankEntryProvider = FutureProvider.family<LeaderboardEntry?, String>(
  (ref, eventId) {
    final service = ref.watch(eventLeaderboardServiceProvider);
    final userId = ref.watch(userIdProvider);

    if (userId.isEmpty) {
      return Future.value(null);
    }

    return service.getUserRankEntry(
      eventId: eventId,
      uid: userId,
    );
  },
);

// Get top N players
final topPlayersProvider =
    FutureProvider.family<List<LeaderboardEntry>, String>((ref, params) {
  final service = ref.watch(eventLeaderboardServiceProvider);
  final parts = params.split('|');
  final eventId = parts[0];
  final limit = parts.length > 1 ? int.tryParse(parts[1]) ?? 10 : 10;

  return service.getTopPlayers(eventId, limit: limit);
});

// Get players around user's rank
final playersAroundRankProvider =
    FutureProvider.family<List<LeaderboardEntry>, String>((ref, params) {
  final service = ref.watch(eventLeaderboardServiceProvider);
  final userId = ref.watch(userIdProvider);
  final parts = params.split('|');
  final eventId = parts[0];
  final range = parts.length > 1 ? int.tryParse(parts[1]) ?? 5 : 5;

  if (userId.isEmpty) {
    return Future.value([]);
  }

  return service.getPlayersAroundRank(
    eventId: eventId,
    uid: userId,
    range: range,
  );
});

// Get total participants
final totalParticipantsProvider =
    FutureProvider.family<int, String>((ref, eventId) {
  final service = ref.watch(eventLeaderboardServiceProvider);
  return service.getTotalParticipants(eventId);
});

// Leaderboard mutation provider
final leaderboardNotifierProvider = StateNotifierProvider<
    LeaderboardNotifier,
    AsyncValue<void>>((ref) {
  final service = ref.watch(eventLeaderboardServiceProvider);
  final userId = ref.watch(userIdProvider);
  return LeaderboardNotifier(service, userId, ref);
});

class LeaderboardNotifier extends StateNotifier<AsyncValue<void>> {
  final EventLeaderboardService _service;
  final String _userId;
  final Ref _ref;

  LeaderboardNotifier(this._service, this._userId, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> addPoints({
    required String eventId,
    required int points,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.addPoints(
        eventId: eventId,
        uid: _userId,
        points: points,
      );

      // Invalidate related caches
      _ref.invalidate(userRankEntryProvider(eventId));
      _ref.invalidate(playersAroundRankProvider('$eventId|5'));
      _ref.invalidate(leaderboardStreamProvider('$eventId|100'));
      _ref.invalidate(leaderboardFutureProvider('$eventId|100'));
    });
  }

  Future<void> incrementChallengeCount(String eventId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.incrementChallengeCount(
        eventId: eventId,
        uid: _userId,
      );

      // Invalidate related caches
      _ref.invalidate(userRankEntryProvider(eventId));
      _ref.invalidate(playersAroundRankProvider('$eventId|5'));
    });
  }

  Future<void> incrementCosmeticCount(String eventId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.incrementCosmeticCount(
        eventId: eventId,
        uid: _userId,
      );

      // Invalidate related caches
      _ref.invalidate(userRankEntryProvider(eventId));
      _ref.invalidate(playersAroundRankProvider('$eventId|5'));
    });
  }

  Future<void> updateLeaderboardEntry({
    required String eventId,
    required String displayName,
    required int score,
    required int completedChallenges,
    required int unlockedCosmetics,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.updateLeaderboardEntry(
        eventId: eventId,
        uid: _userId,
        displayName: displayName,
        score: score,
        completedChallenges: completedChallenges,
        unlockedCosmetics: unlockedCosmetics,
      );

      // Invalidate related caches
      _ref.invalidate(userRankEntryProvider(eventId));
      _ref.invalidate(playersAroundRankProvider('$eventId|5'));
      _ref.invalidate(leaderboardStreamProvider('$eventId|100'));
      _ref.invalidate(leaderboardFutureProvider('$eventId|100'));
      _ref.invalidate(topPlayersProvider('$eventId|10'));
    });
  }
}
