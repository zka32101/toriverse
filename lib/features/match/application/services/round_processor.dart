import '../../application/services/move_applicator.dart';
import '../../application/services/remote_config_service.dart';
import '../../data/models/round_result_model.dart';
import '../../domain/entities/board.dart';
import '../../domain/services/bonus_calculator.dart'; // For ProcessOrderRandomizer
import '../../domain/services/rivalry_tracker.dart';

/// Processes a complete round: validates moves, applies them, resolves outcomes
class RoundProcessor {
  final RemoteConfigService configService;

  RoundProcessor({RemoteConfigService? configService})
      : configService = configService ?? RemoteConfigService();

  /// Process a complete round with all submitted moves
  ///
  /// Returns a RoundResultModel with all game events and outcomes
  RoundResultModel processRound({
    required String matchId,
    required int roundIndex,
    required Board boardBefore,
    required List<String> playerIds,
    required Map<String, int> submittedPositions, // playerId -> position(0-63)
    required List<int> previousBonusActivations, // activation count per player
    RivalryTracker? rivalryTracker,
  }) {
    // Step 1: Generate random process order for move resolution
    final processOrder = _generateProcessOrder(playerIds);

    // Step 2: Apply all moves in process order
    final result = MoveApplicator.applyRoundMoves(
      matchId: matchId,
      roundIndex: roundIndex,
      boardBefore: boardBefore,
      playerIds: playerIds,
      processOrder: processOrder,
      submittedPositions: submittedPositions,
      rivalryTracker: rivalryTracker,
      previousBonusActivations: previousBonusActivations,
      configService: configService,
    );

    return result;
  }

  /// Check if the game should end after this round
  bool isGameOver(Board board) {
    return MoveApplicator.isGameOver(board);
  }

  /// Calculate final scores from board state
  Map<String, int> calculateScores(Board board, List<String> playerIds) {
    final counts = board.countStones();
    return {
      playerIds[0]: counts[Board.black] ?? 0,
      playerIds[1]: counts[Board.white] ?? 0,
      playerIds[2]: counts[Board.red] ?? 0,
    };
  }

  /// Determine match winner(s) based on final board state
  List<String> determineWinners(Board board, List<String> playerIds) {
    final scores = calculateScores(board, playerIds);
    final maxScore = scores.values.reduce((a, b) => a > b ? a : b);

    // All players with max score are winners (tie is possible)
    return scores.entries
        .where((e) => e.value == maxScore)
        .map((e) => e.key)
        .toList();
  }

  /// Generate a random process order for move resolution
  List<String> _generateProcessOrder(List<String> playerIds) {
    // Use ProcessOrderRandomizer for fairness
    return ProcessOrderRandomizer.randomizeOrder(playerIds);
  }

  /// Process a sequence of moves (for testing or replays)
  static Future<Board> applyMoveSequence(
    Board board,
    List<Map<String, dynamic>> moves, // { playerIndex, row, col }
  ) async {
    final result = board.clone();
    for (final move in moves) {
      final playerIndex = move['playerIndex'] as int;
      final row = move['row'] as int;
      final col = move['col'] as int;

      // Only apply if legal
      if (result.getValidMoves(playerIndex).any((m) => m[0] == row && m[1] == col)) {
        result.placeStone(row, col, playerIndex);
      }
    }
    return result;
  }
}
