import 'package:flutter/foundation.dart';
import '../../../data/models/round_result_model.dart';
import '../providers/animation_orchestrator_provider.dart';

/// Builds animation sequences from game events
///
/// Converts game logic results (bonuses, rescue cards, collisions)
/// into a queue of animation events for the AnimationOrchestratorNotifier
class AnimationSequenceBuilder {
  /// Build animation sequence for weak bonus activation
  static QueuedAnimation buildWeakBonusAnimation({
    required String playerId,
    required String playerName,
    required int playerIndex,
    int durationMs = 3000,
    VoidCallback? onComplete,
  }) {
    return QueuedAnimation(
      id: 'weak_bonus_$playerId',
      type: AnimationEventType.weakBonus,
      data: {
        'playerId': playerId,
        'playerName': playerName,
        'playerIndex': playerIndex,
      },
      durationMs: durationMs,
      onComplete: onComplete,
    );
  }

  /// Build animation sequence for rescue card award
  static QueuedAnimation buildRescueCardAnimation({
    required String playerId,
    required String playerName,
    required int playerIndex,
    String reason = 'consecutive_attacks',
    int durationMs = 4000,
    VoidCallback? onComplete,
  }) {
    return QueuedAnimation(
      id: 'rescue_card_$playerId',
      type: AnimationEventType.rescueCard,
      data: {
        'playerId': playerId,
        'playerName': playerName,
        'playerIndex': playerIndex,
        'reason': reason,
      },
      durationMs: durationMs,
      onComplete: onComplete,
    );
  }

  /// Build animation sequence for collision resolution
  static QueuedAnimation buildCollisionAnimation({
    required List<String> conflictingPlayerIds,
    required List<String> conflictingPlayerNames,
    required List<int> playerIndices,
    required String winnerId,
    required String winnerName,
    required int winnerIndex,
    required int boardRow,
    required int boardCol,
    int durationMs = 4000,
    VoidCallback? onComplete,
  }) {
    return QueuedAnimation(
      id: 'collision_${boardRow}_${boardCol}',
      type: AnimationEventType.collision,
      data: {
        'conflictingPlayerIds': conflictingPlayerIds,
        'conflictingPlayerNames': conflictingPlayerNames,
        'playerIndices': playerIndices,
        'winnerId': winnerId,
        'winnerName': winnerName,
        'winnerIndex': winnerIndex,
        'boardRow': boardRow,
        'boardCol': boardCol,
      },
      durationMs: durationMs,
      onComplete: onComplete,
    );
  }

  /// Build animation sequence for lottery/process order reveal
  static QueuedAnimation buildLotteryAnimation({
    required List<String> playerNames,
    required List<int> playerIndices,
    required List<String> processOrder,
    int durationMs = 6000,
    VoidCallback? onComplete,
  }) {
    return QueuedAnimation(
      id: 'lottery_${DateTime.now().millisecondsSinceEpoch}',
      type: AnimationEventType.lottery,
      data: {
        'playerNames': playerNames,
        'playerIndices': playerIndices,
        'processOrder': processOrder,
      },
      durationMs: durationMs,
      onComplete: onComplete,
    );
  }

  /// Build animation sequence for stone flip
  static QueuedAnimation buildFlipAnimation({
    required String playerId,
    required String playerName,
    required int playerIndex,
    required List<List<int>> flippedPositions,
    int durationMs = 800,
    VoidCallback? onComplete,
  }) {
    return QueuedAnimation(
      id: 'flip_$playerId',
      type: AnimationEventType.flip,
      data: {
        'playerId': playerId,
        'playerName': playerName,
        'playerIndex': playerIndex,
        'flippedPositions': flippedPositions,
      },
      durationMs: durationMs,
      onComplete: onComplete,
    );
  }

  /// Build complete animation sequence for a round result
  ///
  /// Orchestrates all animations that should play for a given round:
  /// 1. Lottery (process order reveal)
  /// 2. Collision resolutions (if any)
  /// 3. Weak bonus activations (if any)
  /// 4. Rescue card awards (if any)
  /// 5. Flips for each player (in process order)
  static List<QueuedAnimation> buildRoundSequence({
    required RoundResultModel result,
    required List<String> playerNames,
    required List<int> playerIndices,
    Map<String, String> playerIdToName = const {},
    VoidCallback? onSequenceComplete,
  }) {
    final animations = <QueuedAnimation>[];

    // 1. Lottery animation (if process order is randomized)
    if (result.processOrder.isNotEmpty && result.processOrder.length == 3) {
      animations.add(
        buildLotteryAnimation(
          playerNames: playerNames,
          playerIndices: playerIndices,
          processOrder: result.processOrder,
          durationMs: 6000,
        ),
      );
    }

    // 2. Collision resolutions (if any)
    for (final collision in result.collisionResolved) {
      if (collision.losers.isNotEmpty) {
        animations.add(
          buildCollisionAnimation(
            conflictingPlayerIds: [collision.winnerPlayerId, ...collision.losers],
            conflictingPlayerNames: [
              playerIdToName[collision.winnerPlayerId] ?? collision.winnerPlayerId,
              ...collision.losers
                  .map((id) => playerIdToName[id] ?? id)
                  .toList(),
            ],
            playerIndices: playerIndices,
            winnerId: collision.winnerPlayerId,
            winnerName: playerIdToName[collision.winnerPlayerId] ??
                collision.winnerPlayerId,
            winnerIndex: playerIndices.indexWhere(
              (idx) => idx.toString() == collision.winnerPlayerId,
            ),
            boardRow: collision.position[0],
            boardCol: collision.position[1],
            durationMs: 4000,
          ),
        );
      }
    }

    // 3-4. Weak bonus and rescue card animations would be added here
    // (requires additional data from game state about which bonuses were triggered)

    // 5. Flip animations for each player
    // (requires move result data to show stone flips)

    return animations;
  }
}
