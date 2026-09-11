import 'package:riverpod/riverpod.dart';
import '../../domain/entities/board.dart';
import '../../domain/services/ai_player.dart';

/// AI difficulty level
enum AIDifficulty {
  easy,    // Depth 1 - mostly random
  normal,  // Depth 3 - balanced
  hard,    // Depth 4 - strong
  expert,  // Depth 5 - very strong
}

/// Get depth value for difficulty
int getDepthForDifficulty(AIDifficulty difficulty) {
  return AIPlayer.getDepthByDifficulty(difficulty.name);
}

/// AI difficulty provider (can be set per match or globally)
final aiDifficultyProvider = StateProvider<AIDifficulty>((ref) {
  return AIDifficulty.normal; // Default difficulty
});

/// AI move selector service
class AIMoveSelector {
  final AIDifficulty difficulty;

  AIMoveSelector({this.difficulty = AIDifficulty.normal});

  /// Select best move for AI player
  List<int>? selectMove(Board board, int playerIndex) {
    final depth = getDepthForDifficulty(difficulty);
    return AIPlayer.selectMove(board, playerIndex, depth: depth);
  }

  /// Get integer position for move
  int? suggestMove(Board board, int playerIndex) {
    final depth = getDepthForDifficulty(difficulty);
    return AIPlayer.suggestMove(board, playerIndex, depth: depth);
  }
}

/// Provider for AI move selector with current difficulty
final aiMoveSelectorProvider = Provider<AIMoveSelector>((ref) {
  final difficulty = ref.watch(aiDifficultyProvider);
  return AIMoveSelector(difficulty: difficulty);
});

/// Get AI move for a player
Future<List<int>?> getAIMove(
  Board board,
  int playerIndex,
  AIDifficulty difficulty,
) async {
  // Can be made async if AI computation becomes heavy
  final selector = AIMoveSelector(difficulty: difficulty);
  return selector.selectMove(board, playerIndex);
}
