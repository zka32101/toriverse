import 'package:riverpod/riverpod.dart';
import 'firestore_match_provider.dart';
import '../services/firebase_error_handler.dart';

/// Represents the progress state of a match
class MatchProgressState {
  final String matchId;
  final int totalRounds;
  final int completedRounds;
  final bool isFinished;
  final List<String> winners;
  final List<int> finalScores;
  final DateTime? finishedAt;

  MatchProgressState({
    required this.matchId,
    required this.totalRounds,
    required this.completedRounds,
    this.isFinished = false,
    this.winners = const [],
    this.finalScores = const [],
    this.finishedAt,
  });

  double get progressPercentage =>
      totalRounds > 0 ? (completedRounds / totalRounds) * 100 : 0;

  int get remainingRounds => totalRounds - completedRounds;

  MatchProgressState copyWith({
    String? matchId,
    int? totalRounds,
    int? completedRounds,
    bool? isFinished,
    List<String>? winners,
    List<int>? finalScores,
    DateTime? finishedAt,
  }) {
    return MatchProgressState(
      matchId: matchId ?? this.matchId,
      totalRounds: totalRounds ?? this.totalRounds,
      completedRounds: completedRounds ?? this.completedRounds,
      isFinished: isFinished ?? this.isFinished,
      winners: winners ?? this.winners,
      finalScores: finalScores ?? this.finalScores,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }
}

/// Notifier for tracking match progress
class MatchProgressNotifier extends StateNotifier<MatchProgressState> {
  MatchProgressNotifier({
    required String matchId,
    required int totalRounds,
  }) : super(
    MatchProgressState(
      matchId: matchId,
      totalRounds: totalRounds,
      completedRounds: 0,
    ),
  );

  /// Record that a round has been completed
  void recordRoundCompletion() {
    state = state.copyWith(
      completedRounds: state.completedRounds + 1,
    );
  }

  /// Mark match as finished with results
  void finishMatch({
    required List<String> winners,
    required List<int> finalScores,
  }) {
    state = state.copyWith(
      isFinished: true,
      winners: winners,
      finalScores: finalScores,
      finishedAt: DateTime.now(),
    );
  }

  /// Reset progress (for testing)
  void reset() {
    state = state.copyWith(
      completedRounds: 0,
      isFinished: false,
      winners: const [],
      finalScores: const [],
      finishedAt: null,
    );
  }
}

/// Provider for match progress per match
final matchProgressProvider = StateNotifierProvider.family<
    MatchProgressNotifier,
    MatchProgressState,
    ({String matchId, int totalRounds})>(
  (ref, args) => MatchProgressNotifier(
    matchId: args.matchId,
    totalRounds: args.totalRounds,
  ),
);

/// Stream provider for sync-from-firestore (optional secondary sync)
final matchProgressFromFirestoreProvider =
    StreamProvider.family<MatchProgressState?, String>((ref, matchId) {
  final firestoreRepo = ref.watch(firestoreRepositoryProvider);
  // This would be implemented to stream match progress from Firestore
  // For now, returns null as the primary source is the local StateNotifier
  return const Stream.empty();
});
