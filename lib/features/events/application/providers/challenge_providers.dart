import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/event_model.dart';
import '../../domain/services/challenge_service.dart';
import 'event_providers.dart';

// Challenge Service
final challengeServiceProvider = Provider<ChallengeService>((ref) {
  final firestore = ref.watch(firebaseProvider);
  return ChallengeService(firestore);
});

// Get daily challenges for an event
final dailyChallengesProvider =
    FutureProvider.family<List<Challenge>, String>((ref, eventId) {
  final service = ref.watch(challengeServiceProvider);
  return service.getDailyChallenges(eventId: eventId);
});

// Get weekly challenges for an event
final weeklyChallengesProvider =
    FutureProvider.family<List<Challenge>, String>((ref, eventId) {
  final service = ref.watch(challengeServiceProvider);
  return service.getWeeklyChallenges(eventId: eventId);
});

// Get all challenges for an event as stream
final challengesStreamProvider =
    StreamProvider.family<List<Challenge>, String>((ref, eventId) {
  final service = ref.watch(challengeServiceProvider);
  return service.watchChallenges(eventId);
});

// Get single challenge details
final challengeDetailsProvider = FutureProvider.family<Challenge?, String>(
  (ref, params) {
    final service = ref.watch(challengeServiceProvider);
    final parts = params.split('|');
    final eventId = parts[0];
    final challengeId = parts[1];

    return service.getChallengeDetails(
      eventId: eventId,
      challengeId: challengeId,
    );
  },
);

// Get user's progress on a specific challenge
final challengeProgressProvider =
    FutureProvider.family<int, String>((ref, params) {
  final service = ref.watch(challengeServiceProvider);
  final userId = ref.watch(userIdProvider);
  final parts = params.split('|');
  final eventId = parts[0];
  final challengeId = parts[1];

  if (userId.isEmpty) {
    return Future.value(0);
  }

  return service.getChallengeProgress(
    uid: userId,
    eventId: eventId,
    challengeId: challengeId,
  );
});

// Get challenge completion count for user in event
final challengeCompletionCountProvider =
    FutureProvider.family<int, String>((ref, eventId) {
  final service = ref.watch(challengeServiceProvider);
  final userId = ref.watch(userIdProvider);

  if (userId.isEmpty) {
    return Future.value(0);
  }

  return service.getChallengeCompletionCount(
    uid: userId,
    eventId: eventId,
  );
});

// Get all completed challenges for user in event
final completedChallengesProvider =
    FutureProvider.family<List<String>, String>((ref, eventId) {
  final service = ref.watch(challengeServiceProvider);
  final userId = ref.watch(userIdProvider);

  if (userId.isEmpty) {
    return Future.value([]);
  }

  return service.getCompletedChallenges(
    uid: userId,
    eventId: eventId,
  );
});

// Get reward points for a challenge
final challengeRewardPointsProvider = FutureProvider.family<int, String>(
  (ref, params) {
    final service = ref.watch(challengeServiceProvider);
    final parts = params.split('|');
    final eventId = parts[0];
    final challengeId = parts[1];

    return service.getChallengeRewardPoints(
      eventId: eventId,
      challengeId: challengeId,
    );
  },
);

// Challenge mutation provider
final challengeNotifierProvider =
    StateNotifierProvider<ChallengeNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(challengeServiceProvider);
  final userId = ref.watch(userIdProvider);
  return ChallengeNotifier(service, userId, ref);
});

class ChallengeNotifier extends StateNotifier<AsyncValue<void>> {
  final ChallengeService _service;
  final String _userId;
  final Ref _ref;

  ChallengeNotifier(this._service, this._userId, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> completeChallenge(String eventId, String challengeId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.completeChallenge(
        uid: _userId,
        eventId: eventId,
        challengeId: challengeId,
      );

      // Invalidate related caches
      _ref.invalidate(
        challengeProgressProvider('$eventId|$challengeId'),
      );
      _ref.invalidate(challengeCompletionCountProvider(eventId));
      _ref.invalidate(completedChallengesProvider(eventId));
      _ref.invalidate(eventProgressStreamProvider(eventId));
      _ref.invalidate(eventProgressFutureProvider(eventId));
    });
  }

  Future<void> validateChallenge(String eventId, String challengeId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final isValid = await _service.validateChallengeCompletion(
        uid: _userId,
        eventId: eventId,
        challengeId: challengeId,
      );

      if (isValid) {
        await completeChallenge(eventId, challengeId);
      }
    });
  }

  Future<void> resetDailyChallenges(String eventId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.resetDailyChallenges(
        uid: _userId,
        eventId: eventId,
      );

      // Invalidate related caches
      _ref.invalidate(dailyChallengesProvider(eventId));
      _ref.invalidate(challengesStreamProvider(eventId));
      _ref.invalidate(challengeCompletionCountProvider(eventId));
      _ref.invalidate(completedChallengesProvider(eventId));
    });
  }
}
