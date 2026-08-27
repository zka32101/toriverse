import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod/riverpod.dart';

import '../../domain/models/spectator_session.dart';
import '../../data/repositories/spectator_repository.dart';

// Firebase instance providers
final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);
final authProvider = Provider((ref) => FirebaseAuth.instance);

// Repository provider
final spectatorRepositoryProvider = Provider((ref) {
  final firestore = ref.watch(firestoreProvider);
  final auth = ref.watch(authProvider);
  return SpectatorRepository(firestore, auth);
});

/// Stream of current user's spectator sessions (active matches they're watching)
final currentUserSpectatorSessionsProvider =
    StreamProvider.family<List<SpectatorSession>, String>((ref, userId) async* {
  final repository = ref.watch(spectatorRepositoryProvider);
  await for (final sessions in repository.watchUserSpectatorSessions(userId)) {
    yield sessions;
  }
});

/// Stream of all spectators watching a specific match
final matchSpectatorsProvider =
    StreamProvider.family<List<SpectatorSession>, String>((ref, matchId) async* {
  final repository = ref.watch(spectatorRepositoryProvider);
  await for (final spectators in repository.watchMatchSpectators(matchId)) {
    yield spectators;
  }
});

/// Real-time spectator count for a match
final matchSpectatorCountProvider =
    StreamProvider.family<int, String>((ref, matchId) async* {
  final spectators = ref.watch(matchSpectatorsProvider(matchId));
  yield spectators.maybeWhen(
    data: (list) => list.length,
    orElse: () => 0,
  );
});

/// Join spectator session for a match
final joinSpectatorSessionProvider = FutureProvider.family<void, String>(
  (ref, matchId) async {
    final repository = ref.watch(spectatorRepositoryProvider);
    final auth = ref.watch(authProvider);

    final user = auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await repository.joinSpectatorSession(
      matchId: matchId,
      userId: user.uid,
      displayName: user.displayName ?? 'Guest',
    );
  },
);

/// Leave spectator session
final leaveSpectatorSessionProvider = FutureProvider.family<void, String>(
  (ref, matchId) async {
    final repository = ref.watch(spectatorRepositoryProvider);
    final auth = ref.watch(authProvider);

    final user = auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await repository.leaveSpectatorSession(
      matchId: matchId,
      userId: user.uid,
    );
  },
);

/// Track spectator analytics event
final recordSpectatorEventProvider =
    FutureProvider.family<void, SpectatorAnalyticsEvent>(
  (ref, event) async {
    final repository = ref.watch(spectatorRepositoryProvider);
    await repository.recordSpectatorEvent(event);
  },
);

/// Analytics event for spectator actions
class SpectatorAnalyticsEvent {
  final String matchId;
  final String userId;
  final String eventType; // 'spectator_joined', 'spectator_left', 'spectator_shared_url'
  final Map<String, dynamic> parameters;

  SpectatorAnalyticsEvent({
    required this.matchId,
    required this.userId,
    required this.eventType,
    required this.parameters,
  });
}
