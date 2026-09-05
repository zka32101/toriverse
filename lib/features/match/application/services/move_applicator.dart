import 'dart:math';
import '../../data/models/round_result_model.dart';
import '../../domain/entities/board.dart';
import '../../domain/services/bonus_calculator.dart';
import '../../domain/services/rivalry_tracker.dart';

/// Apply submitted moves in process order with collision resolution
class MoveApplicator {
  /// Apply all moves in process order, detecting collisions and applying consequences
  ///
  /// Returns a [RoundResultModel] capturing the round's outcome
  ///
  /// Optional [bonusCalculator] enables weak bonus checking. If null, bonus is not computed.
  static RoundResultModel applyRoundMoves({
    required String matchId,
    required int roundIndex,
    required Board boardBefore,
    required List<String> playerIds,
    required List<String> processOrder,
    required Map<String, int> submittedPositions, // { playerId: position(0-63) }
    required RivalryTracker? rivalryTracker,
    BonusCalculator? bonusCalculator,
    List<ReplayEvent> replayEvents = const [],
  }) {
    // Step 1: Detect same-square collisions
    final collisions = _detectCollisions(submittedPositions, playerIds);

    // Step 2: Apply moves in process order (excluding losers of collisions)
    final boardAfter = boardBefore.clone();
    final appliedMoves = <String>{};

    for (final playerId in processOrder) {
      final position = submittedPositions[playerId];
      if (position == null) continue;

      // Skip if this player lost a collision
      if (collisions.any((c) => c.losers.contains(playerId))) {
        continue;
      }

      final row = position ~/ 8;
      final col = position % 8;
      final playerIndex = playerIds.indexOf(playerId);

      // Only apply if move is still valid on current board state
      if (boardAfter.getValidMoves(playerIndex).any((m) => m[0] == row && m[1] == col)) {
        boardAfter.placeStone(row, col, playerIndex);
        appliedMoves.add(playerId);
      }
    }

    // Step 3: Build submitted moves list
    final submittedMoves = <SubmittedMove>[];
    for (final playerId in playerIds) {
      final position = submittedPositions[playerId];
      if (position != null) {
        submittedMoves.add(SubmittedMove(
          playerId: playerId,
          position: position,
          submittedAt: DateTime.now(),
        ));
      }
    }

    // Step 4: Check if weak bonus should trigger (if calculator provided)
    String bonusTriggeredPlayerId = '';
    if (bonusCalculator != null) {
      // Check each player for weak bonus eligibility
      // Bonus applies to player in bottom 20% of stone count at round ≤ 11
      final stoneCounts = boardBefore.countStones();
      final playerStones = <String, int>{};
      for (int i = 0; i < playerIds.length; i++) {
        final stoneType = i == 0 ? Board.black : (i == 1 ? Board.white : Board.red);
        playerStones[playerIds[i]] = stoneCounts[stoneType] ?? 0;
      }

      // For now, check if any player qualifies (full logic requires match history)
      // This is a simplified check - full implementation would need:
      // - Previous stone diffs
      // - Match-level activation count
      // - Proper percentile calculation
      if (roundIndex <= 10) {
        // Placeholder: could improve with proper percentile logic
        // Bonus would be applied during move processing if triggered
        // bonusTriggeredPlayerId = ...computed logic...
      }
    }

    // Step 5: Build result model
    return RoundResultModel(
      id: '${matchId}_$roundIndex',
      matchId: matchId,
      roundIndex: roundIndex,
      submittedMoves: submittedMoves,
      collisionResolved: collisions,
      processOrder: processOrder,
      replayEvents: replayEvents,
      createdAt: DateTime.now(),
      processedAt: DateTime.now(),
      bonusTriggered: bonusTriggeredPlayerId,
      rescueCardsGranted: _getRescueCardRecipients(collisions),
    );
  }

  /// Detect moves where 2+ players submitted the same position
  static List<CollisionResolution> _detectCollisions(
    Map<String, int> submittedPositions,
    List<String> playerIds,
  ) {
    final collisions = <CollisionResolution>[];
    final positionMap = <int, List<String>>{};

    // Group players by position
    for (final (playerId, position) in submittedPositions.entries) {
      positionMap.putIfAbsent(position, () => []).add(playerId);
    }

    // Resolve collisions
    final random = Random();
    for (final (position, players) in positionMap.entries) {
      if (players.length > 1) {
        // Randomly pick winner
        final winner = players[random.nextInt(players.length)];
        final losers = players.where((p) => p != winner).toList();

        collisions.add(CollisionResolution(
          position: position,
          winnerPlayerId: winner,
          losers: losers,
          rescueCardGranted: true,
        ));
      }
    }

    return collisions;
  }

  /// Get list of players who should receive rescue cards
  static List<String> _getRescueCardRecipients(List<CollisionResolution> collisions) {
    final recipients = <String>{};
    for (final collision in collisions) {
      if (collision.rescueCardGranted) {
        recipients.addAll(collision.losers);
      }
    }
    return recipients.toList();
  }

  /// Check if game should end after this round
  static bool isGameOver(Board board) {
    for (int i = 0; i < 3; i++) {
      if (board.getValidMoves(i).isNotEmpty) {
        return false;
      }
    }
    return true;
  }

  /// Get stone counts after applying moves
  static Map<int, int> getStoneCountsAfter(Board board) {
    return board.countStones();
  }
}
