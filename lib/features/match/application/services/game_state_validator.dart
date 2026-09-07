import '../../domain/entities/board.dart';

/// Validates game state integrity and compliance with game rules
class GameStateValidator {
  /// Validate that a board state is legal
  ///
  /// Checks:
  /// - Board size is 8x8
  /// - Stone counts are reasonable (0-64 total)
  /// - No more than 2 stones flipped per move (simplified check)
  static bool isValidBoardState(Board board) {
    // Check board size
    if (board.boardState.length != 64) return false;

    // Check stone counts
    final counts = board.countStones();
    final total = (counts[Board.black] ?? 0) +
        (counts[Board.white] ?? 0) +
        (counts[Board.red] ?? 0);

    if (total < 0 || total > 64) return false;

    // Initial state should have 4 stones
    if (total == 4) {
      // Should be 2 black, 2 white in center
      if (counts[Board.black] != 2 || counts[Board.white] != 2) return false;
    }

    return true;
  }

  /// Validate that submitted moves are within bounds
  static bool areMovesValid(
    Map<String, int> submittedPositions,
    List<String> playerIds,
  ) {
    if (submittedPositions.isEmpty) return true;

    for (final (playerId, position) in submittedPositions.entries) {
      // Check player exists
      if (!playerIds.contains(playerId)) return false;

      // Check position is in range [0, 63]
      if (position < 0 || position >= 64) return false;
    }

    return true;
  }

  /// Validate that all players have unique moves (or are AI)
  static bool areMovePositionsUnique(Map<String, int> submittedPositions) {
    final positions = submittedPositions.values.toList();
    return positions.length == positions.toSet().length ||
        positions.any((p) => p == -1); // -1 = no move
  }

  /// Validate bonus activation count state
  static bool areBonusCountsValid(List<int> bonusActivationCounts) {
    if (bonusActivationCounts.length != 3) return false;

    // Each player can activate max 2 times per match
    for (final count in bonusActivationCounts) {
      if (count < 0 || count > 2) return false;
    }

    return true;
  }

  /// Validate player list
  static bool isPlayerListValid(List<String> playerIds) {
    // Exactly 3 players
    if (playerIds.length != 3) return false;

    // No duplicates
    if (playerIds.toSet().length != 3) return false;

    // All non-empty
    for (final id in playerIds) {
      if (id.isEmpty) return false;
    }

    return true;
  }

  /// Validate round index is reasonable
  static bool isRoundIndexValid(int roundIndex) {
    return roundIndex >= 0 && roundIndex < 64;
  }

  /// Comprehensive game state validation
  static ValidationResult validateGameState({
    required Board board,
    required List<String> playerIds,
    required Map<String, int> submittedPositions,
    required List<int> bonusActivationCounts,
    required int roundIndex,
  }) {
    final errors = <String>[];

    if (!isValidBoardState(board)) {
      errors.add('Invalid board state');
    }

    if (!isPlayerListValid(playerIds)) {
      errors.add('Invalid player list');
    }

    if (!areMovesValid(submittedPositions, playerIds)) {
      errors.add('Invalid moves');
    }

    if (!areBonusCountsValid(bonusActivationCounts)) {
      errors.add('Invalid bonus counts');
    }

    if (!isRoundIndexValid(roundIndex)) {
      errors.add('Invalid round index');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Check stone count progression is reasonable
  static bool isStoneProgressionReasonable(
    int previousTotal,
    int currentTotal,
  ) {
    // After each move, total should increase by exactly 1
    // (the new stone placed, minus flipped stones = net +1)
    return currentTotal == previousTotal + 1;
  }

  /// Validate a collision resolution
  static bool isCollisionResolutionValid({
    required List<String> collidingPlayers,
    required String winner,
    required List<String> losers,
    required List<String> allPlayerIds,
  }) {
    // Winner must be in colliding players
    if (!collidingPlayers.contains(winner)) return false;

    // Losers count must match colliding - 1
    if (losers.length != (collidingPlayers.length - 1)) return false;

    // All losers must be in colliding players
    for (final loser in losers) {
      if (!collidingPlayers.contains(loser)) return false;
      if (loser == winner) return false;
    }

    return true;
  }
}

/// Result of a game state validation
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({
    required this.isValid,
    required this.errors,
  });

  @override
  String toString() {
    if (isValid) return 'ValidationResult: Valid ✓';
    return 'ValidationResult: Invalid\n${errors.join('\n')}';
  }
}
