import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/round_result_model.dart';
import '../../data/repositories/round_result_repository.dart';
import '../../data/repositories/match_repository.dart';
import '../../domain/services/bonus_calculator.dart';
import 'game_state.dart';

// Collision resolver for same-position submissions
class _CollisionResolver {
  static Map<String, dynamic> resolveCollision({
    required List<String> playerIds,
    required int boardRow,
    required int boardCol,
  }) {
    final random = DateTime.now().microsecond % playerIds.length;
    final winner = playerIds[random];
    final losers = playerIds.where((id) => id != winner).toList();

    return {
      'winner': winner,
      'losers': losers,
      'position': boardRow * 8 + boardCol,
      'rescueCardGranted': true,
      'description':
          '同マス被り! $winner が着手、${losers.length}人に救済カードが付与されました',
    };
  }
}

/// Move submission state during a round
class MoveSubmissionState {
  final Map<String, int?> playerMoves; // playerId -> position (0-63) or null
  final Set<String> submittedPlayers;
  final DateTime? roundStartTime;
  final bool revealTriggered;
  final List<String>? processOrder;

  MoveSubmissionState({
    required this.playerMoves,
    required this.submittedPlayers,
    this.roundStartTime,
    this.revealTriggered = false,
    this.processOrder,
  });

  MoveSubmissionState copyWith({
    Map<String, int?>? playerMoves,
    Set<String>? submittedPlayers,
    DateTime? roundStartTime,
    bool? revealTriggered,
    List<String>? processOrder,
  }) {
    return MoveSubmissionState(
      playerMoves: playerMoves ?? this.playerMoves,
      submittedPlayers: submittedPlayers ?? this.submittedPlayers,
      roundStartTime: roundStartTime ?? this.roundStartTime,
      revealTriggered: revealTriggered ?? this.revealTriggered,
      processOrder: processOrder ?? this.processOrder,
    );
  }

  /// Check if all players have submitted their moves
  bool get allPlayersSubmitted => submittedPlayers.length == 3;

  /// Get all submitted moves as SubmittedMove objects
  List<SubmittedMove> getSubmittedMoves(DateTime now) {
    return playerMoves.entries
        .where((e) => e.value != null)
        .map((e) => SubmittedMove(
              playerId: e.key,
              position: e.value!,
              submittedAt: now,
            ))
        .toList();
  }
}

/// Notifier for move submission state
class MoveSubmissionNotifier extends StateNotifier<MoveSubmissionState> {
  final RoundResultRepository _roundResultRepository;
  final MatchRepository _matchRepository;

  MoveSubmissionNotifier({
    required RoundResultRepository roundResultRepository,
    required MatchRepository matchRepository,
  })  : _roundResultRepository = roundResultRepository,
        _matchRepository = matchRepository,
        super(MoveSubmissionState(
          playerMoves: {},
          submittedPlayers: {},
          roundStartTime: DateTime.now(),
        ));

  /// Initialize for a new round with player IDs
  void initializeRound(List<String> playerIds) {
    state = MoveSubmissionState(
      playerMoves: {for (final playerId in playerIds) playerId: null},
      submittedPlayers: {},
      roundStartTime: DateTime.now(),
    );
  }

  /// Submit a move for a player
  void submitMove(String playerId, int position) {
    final newMoves = Map<String, int?>.from(state.playerMoves);
    newMoves[playerId] = position;

    final newSubmitted = Set<String>.from(state.submittedPlayers);
    newSubmitted.add(playerId);

    state = state.copyWith(
      playerMoves: newMoves,
      submittedPlayers: newSubmitted,
    );
  }

  /// Check for collisions (same position submitted by multiple players)
  Map<int, List<String>> checkCollisions() {
    final positionMap = <int, List<String>>{};

    for (final entry in state.playerMoves.entries) {
      if (entry.value != null) {
        final position = entry.value!;
        positionMap.putIfAbsent(position, () => []);
        positionMap[position]!.add(entry.key);
      }
    }

    // Filter to only positions with collisions (multiple submissions)
    return {
      for (final entry in positionMap.entries)
        if (entry.value.length > 1) entry.key: entry.value
    };
  }

  /// Trigger simultaneous reveal
  Future<void> triggerSimultaneousReveal(String matchId, int roundIndex) async {
    // Randomize process order
    final playerIds = state.playerMoves.keys.toList();
    playerIds.shuffle();

    state = state.copyWith(
      revealTriggered: true,
      processOrder: playerIds,
    );

    // Save round result to Firestore
    final submittedMoves = state.getSubmittedMoves(DateTime.now());
    final collisions = checkCollisions();
    final collisionResolutions = <CollisionResolution>[];

    // Resolve collisions (random winner + rescue cards for losers)
    for (final entry in collisions.entries) {
      final position = entry.key;
      final collidingPlayers = entry.value;

      final resolution = _CollisionResolver.resolveCollision(
        playerIds: collidingPlayers,
        boardRow: position ~/ 8,
        boardCol: position % 8,
      );

      collisionResolutions.add(CollisionResolution(
        position: position,
        winnerPlayerId: resolution['winner'] as String,
        losers: List<String>.from(resolution['losers'] as List),
        rescueCardGranted: true,
      ));
    }

    // Create round result document
    final roundResult = RoundResultModel(
      id: '${matchId}_$roundIndex',
      matchId: matchId,
      roundIndex: roundIndex,
      submittedMoves: submittedMoves,
      collisionResolved: collisionResolutions,
      processOrder: playerIds,
      createdAt: DateTime.now(),
    );

    await _roundResultRepository.createRoundResult(roundResult);
  }

  /// Reset state for next round
  void resetForNextRound() {
    final playerIds = state.playerMoves.keys.toList();
    state = MoveSubmissionState(
      playerMoves: {for (final playerId in playerIds) playerId: null},
      submittedPlayers: {},
      roundStartTime: DateTime.now(),
    );
  }
}

/// Provider factory for move submission (one per match)
final moveSubmissionProvider = StateNotifierProvider.family<
    MoveSubmissionNotifier,
    MoveSubmissionState,
    String>((ref, matchId) {
  final roundResultRepository = RoundResultRepository();
  final matchRepository = MatchRepository();

  return MoveSubmissionNotifier(
    roundResultRepository: roundResultRepository,
    matchRepository: matchRepository,
  );
});

/// Computed provider: check if time has expired (30 second window)
final moveSubmissionTimeExpiredProvider = StreamProvider.family<bool, String>(
  (ref, matchId) async* {
    final state = ref.watch(moveSubmissionProvider(matchId));

    if (state.roundStartTime == null) {
      yield false;
      return;
    }

    const submissionWindowSeconds = 30;

    while (!state.revealTriggered) {
      final elapsed =
          DateTime.now().difference(state.roundStartTime!).inSeconds;
      yield elapsed >= submissionWindowSeconds;
      await Future.delayed(const Duration(milliseconds: 500));
    }
  },
);

/// Computed provider: should reveal moves (all submitted OR time expired)
final shouldRevealMovesProvider = Provider.family<bool, String>(
  (ref, matchId) {
    final submission = ref.watch(moveSubmissionProvider(matchId));
    final timeExpired = ref.watch(moveSubmissionTimeExpiredProvider(matchId));

    return switch (timeExpired) {
      AsyncValue.data(:final value) =>
        submission.allPlayersSubmitted || value,
      _ => false,
    };
  },
);
