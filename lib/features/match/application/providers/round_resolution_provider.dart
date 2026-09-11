import 'package:riverpod/riverpod.dart';
import '../services/remote_config_service.dart';
import '../services/round_processor.dart';
import '../../data/models/round_result_model.dart';
import '../../domain/entities/board.dart';
import '../services/move_applicator.dart';

/// Provider for the RoundProcessor service (singleton)
final roundProcessorProvider = Provider<RoundProcessor>((ref) {
  final configService = RemoteConfigService();
  return RoundProcessor(configService: configService);
});

/// Bonus activation state per match
/// Tracks which players have activated bonuses and how many times
class BonusActivationState {
  final Map<String, int> activationCounts; // playerId -> count (0-2)
  final List<int> lastActivatedRounds; // playerId -> round index

  BonusActivationState({
    required this.activationCounts,
    required this.lastActivatedRounds,
  });

  /// Get activation count for a player
  int getCount(String playerId) => activationCounts[playerId] ?? 0;

  /// Increment activation count
  BonusActivationState incrementActivation(String playerId) {
    final newCounts = Map<String, int>.from(activationCounts);
    newCounts[playerId] = (newCounts[playerId] ?? 0) + 1;
    return BonusActivationState(
      activationCounts: newCounts,
      lastActivatedRounds: lastActivatedRounds,
    );
  }
}

/// Notifier for bonus activation state
class BonusActivationNotifier extends StateNotifier<BonusActivationState> {
  BonusActivationNotifier({required List<String> playerIds})
      : super(
          BonusActivationState(
            activationCounts: {for (final id in playerIds) id: 0},
            lastActivatedRounds: [],
          ),
        );

  /// Record bonus activation for a player
  void recordActivation(String playerId, int roundIndex) {
    state = state.incrementActivation(playerId);
  }

  /// Get activation count for player
  int getActivationCount(String playerId) => state.getCount(playerId);

  /// Check if player can still activate bonus
  bool canActivateBonus(String playerId) {
    return getActivationCount(playerId) < 2; // Max 2 per match
  }
}

/// Provider for bonus activation state per match
final bonusActivationProvider = StateNotifierProvider.family<
    BonusActivationNotifier,
    BonusActivationState,
    String>((ref, matchId) {
  // This will be initialized when match starts
  // For now, default to 3 empty players
  return BonusActivationNotifier(playerIds: ['player1', 'player2', 'player3']);
});

/// Result of round resolution
class RoundResolution {
  final RoundResultModel result;
  final Board boardAfter;
  final bool isGameOver;
  final List<String> winners; // Empty if game not over

  RoundResolution({
    required this.result,
    required this.boardAfter,
    required this.isGameOver,
    required this.winners,
  });
}

/// Service for resolving a complete round
class RoundResolutionService {
  final RoundProcessor processor;
  final RemoteConfigService configService;

  RoundResolutionService({
    required this.processor,
    required this.configService,
  });

  /// Resolve a round with all submitted moves
  Future<RoundResolution> resolveRound({
    required String matchId,
    required int roundIndex,
    required Board boardBefore,
    required List<String> playerIds,
    required Map<String, int> submittedPositions,
    required List<int> bonusActivationCounts,
  }) async {
    // Process the round using RoundProcessor
    final result = processor.processRound(
      matchId: matchId,
      roundIndex: roundIndex,
      boardBefore: boardBefore,
      playerIds: playerIds,
      submittedPositions: submittedPositions,
      previousBonusActivations: bonusActivationCounts,
    );

    // Check if game is over
    final isGameOver = processor.isGameOver(result.boardAfter);
    final winners = isGameOver
        ? processor.determineWinners(result.boardAfter, playerIds)
        : <String>[];

    return RoundResolution(
      result: result,
      boardAfter: result.boardAfter,
      isGameOver: isGameOver,
      winners: winners,
    );
  }
}

/// Provider for round resolution service
final roundResolutionServiceProvider = Provider<RoundResolutionService>((ref) {
  final processor = ref.watch(roundProcessorProvider);
  final configService = RemoteConfigService();
  return RoundResolutionService(
    processor: processor,
    configService: configService,
  );
});
