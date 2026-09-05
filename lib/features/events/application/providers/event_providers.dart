import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/event_model.dart';
import '../../domain/services/event_service.dart';

// Firebase instance
final firebaseProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Event Service
final eventServiceProvider = Provider<EventService>((ref) {
  final firestore = ref.watch(firebaseProvider);
  return EventService(firestore);
});

// Get all active events as stream
final activeEventsStreamProvider = StreamProvider<List<Event>>((ref) {
  final service = ref.watch(eventServiceProvider);
  return service.getActiveEventsStream();
});

// Get upcoming events (Future)
final upcomingEventsProvider = FutureProvider<List<Event>>((ref) {
  final service = ref.watch(eventServiceProvider);
  return service.getUpcomingEvents(limit: 5);
});

// Get single event details by ID (Stream)
final eventDetailsStreamProvider =
    StreamProvider.family<Event?, String>((ref, eventId) {
  final service = ref.watch(eventServiceProvider);
  return service.watchEventDetails(eventId);
});

// Get single event details by ID (Future)
final eventDetailsFutureProvider = FutureProvider.family<Event?, String>(
  (ref, eventId) {
    final service = ref.watch(eventServiceProvider);
    return service.getEventDetails(eventId);
  },
);

// Get event challenges as stream
final eventChallengesStreamProvider =
    StreamProvider.family<List<Challenge>, String>((ref, eventId) {
  final service = ref.watch(eventServiceProvider);
  return service.getChallengesStream(eventId);
});

// Get event challenges (Future)
final eventChallengesFutureProvider = FutureProvider.family<List<Challenge>, String>(
  (ref, eventId) {
    final service = ref.watch(eventServiceProvider);
    return service.getEventChallenges(eventId);
  },
);

// Get user's event progress as stream
final eventProgressStreamProvider =
    StreamProvider.family<EventProgress?, String>((ref, eventId) {
  final service = ref.watch(eventServiceProvider);
  final userId = ref.watch(userIdProvider);

  if (userId.isEmpty) {
    return Stream.value(null);
  }

  return service.watchEventProgress(uid: userId, eventId: eventId);
});

// Get user's event progress (Future)
final eventProgressFutureProvider =
    FutureProvider.family<EventProgress?, String>((ref, eventId) {
  final service = ref.watch(eventServiceProvider);
  final userId = ref.watch(userIdProvider);

  if (userId.isEmpty) {
    return Future.value(null);
  }

  return service.getEventProgress(uid: userId, eventId: eventId);
});

// Get user's active events
final userActiveEventsProvider = FutureProvider<List<EventProgress>>((ref) {
  final service = ref.watch(eventServiceProvider);
  final userId = ref.watch(userIdProvider);

  if (userId.isEmpty) {
    return Future.value([]);
  }

  return service.getUserActiveEvents(userId);
});

// Get event leaderboard as stream
final eventLeaderboardStreamProvider =
    StreamProvider.family<List<LeaderboardEntry>, String>((ref, eventId) {
  final service = ref.watch(eventServiceProvider);
  return service.watchEventLeaderboard(eventId, limit: 100);
});

// Get event leaderboard (Future)
final eventLeaderboardFutureProvider =
    FutureProvider.family<List<LeaderboardEntry>, String>((ref, eventId) {
  final service = ref.watch(eventServiceProvider);
  return service.getEventLeaderboard(eventId, limit: 100);
});

// Get user's rank in event
final userEventRankProvider =
    FutureProvider.family<int?, String>((ref, eventId) {
  final service = ref.watch(eventServiceProvider);
  final userId = ref.watch(userIdProvider);

  if (userId.isEmpty) {
    return Future.value(null);
  }

  return service.getUserRank(uid: userId, eventId: eventId);
});

// Check if user has joined event
final hasJoinedEventProvider =
    FutureProvider.family<bool, String>((ref, eventId) {
  final service = ref.watch(eventServiceProvider);
  final userId = ref.watch(userIdProvider);

  if (userId.isEmpty) {
    return Future.value(false);
  }

  return service.hasJoinedEvent(uid: userId, eventId: eventId);
});

// User ID provider (should be replaced with actual auth provider)
final userIdProvider = Provider<String>((ref) {
  // TODO: Replace with actual authentication provider
  return '';
});

// Event mutation provider
final eventNotifierProvider =
    StateNotifierProvider<EventNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(eventServiceProvider);
  final userId = ref.watch(userIdProvider);
  return EventNotifier(service, userId, ref);
});

@freezed
class EventMutation with _$EventMutation {
  const factory EventMutation.joinEvent({
    required String eventId,
  }) = _JoinEventMutation;

  const factory EventMutation.addScore({
    required String eventId,
    required int points,
  }) = _AddScoreMutation;

  const factory EventMutation.completeChallenge({
    required String eventId,
    required String challengeId,
  }) = _CompletechallengeMutation;

  const factory EventMutation.unlockCosmetic({
    required String eventId,
    required String cosmeticId,
  }) = _UnlockCosmeticMutation;

  const factory EventMutation.updateLeaderboardEntry({
    required String eventId,
    required String displayName,
    required int score,
    required int completedChallenges,
    required int unlockedCosmetics,
  }) = _UpdateLeaderboardEntryMutation;
}

class EventNotifier extends StateNotifier<AsyncValue<void>> {
  final EventService _service;
  final String _userId;
  final Ref _ref;

  EventNotifier(this._service, this._userId, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> joinEvent(String eventId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.joinEvent(uid: _userId, eventId: eventId);
      _ref.invalidate(hasJoinedEventProvider(eventId));
      _ref.invalidate(eventProgressStreamProvider(eventId));
      _ref.invalidate(eventProgressFutureProvider(eventId));
      _ref.invalidate(userActiveEventsProvider);
    });
  }

  Future<void> addEventScore(String eventId, int points) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.addEventScore(
        uid: _userId,
        eventId: eventId,
        points: points,
      );
      _ref.invalidate(eventProgressStreamProvider(eventId));
      _ref.invalidate(eventProgressFutureProvider(eventId));
    });
  }

  Future<void> completeChallenge(String eventId, String challengeId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.completeChallenge(
        uid: _userId,
        eventId: eventId,
        challengeId: challengeId,
      );
      _ref.invalidate(eventProgressStreamProvider(eventId));
      _ref.invalidate(eventProgressFutureProvider(eventId));
    });
  }

  Future<void> unlockCosmetic(String eventId, String cosmeticId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.unlockCosmetic(
        uid: _userId,
        eventId: eventId,
        cosmeticId: cosmeticId,
      );
      _ref.invalidate(eventProgressStreamProvider(eventId));
      _ref.invalidate(eventProgressFutureProvider(eventId));
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
      _ref.invalidate(eventLeaderboardStreamProvider(eventId));
      _ref.invalidate(eventLeaderboardFutureProvider(eventId));
      _ref.invalidate(userEventRankProvider(eventId));
    });
  }
}
