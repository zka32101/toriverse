import 'package:flutter/material.dart';
import 'package:toriverse/config/theme.dart';
import '../../domain/services/rivalry_tracker.dart';

/// Rivalry/Alliance indicator widget (GAME_DESIGN_UI_REFORM.md §2.2)
///
/// Displays "2v1" coalition dynamics by showing who is attacking whom.
/// When a player is being double-targeted by the other two, shows a visual warning.
/// This makes implicit alliances explicit and raises the psychological tension.
class RivalryIndicatorWidget extends StatelessWidget {
  /// Rivalry scores aggregated from recent rounds
  /// { attacker_index: { target_index: stone_count } }
  final Map<int, Map<int, int>> rivalryScores;

  /// Player IDs/colors (in order: black, white, red)
  final List<String> playerIds;

  /// Current player's index (for highlighting perspective)
  final int currentPlayerIndex;

  /// Whether to show verbose attack counts (default: compact mode)
  final bool showCounts;

  const RivalryIndicatorWidget({
    Key? key,
    required this.rivalryScores,
    required this.playerIds,
    required this.currentPlayerIndex,
    this.showCounts = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if current player is being double-targeted (alliance against them)
    final allPlayers = [0, 1, 2];
    final isDoubleTargeted = RivalryTracker.isDoubleTargeted(
      rivalryScores,
      currentPlayerIndex,
      allPlayers,
      minAttacksEach: 1,
    );

    // Get top aggressors against current player
    final topAggressors = RivalryTracker.getTopAggressorsAgainst(
      rivalryScores,
      currentPlayerIndex,
    );

    return _buildIndicator(
      context: context,
      isDoubleTargeted: isDoubleTargeted,
      topAggressors: topAggressors,
    );
  }

  Widget _buildIndicator({
    required BuildContext context,
    required bool isDoubleTargeted,
    required List<int> topAggressors,
  }) {
    if (topAggressors.isEmpty) {
      // No attacks yet - neutral state
      return SizedBox(
        height: 56,
        child: Center(
          child: Text(
            '試合開始',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDoubleTargeted ? Colors.red.shade50 : Colors.blue.shade50,
        border: Border.all(
          color: isDoubleTargeted ? Colors.red.shade300 : Colors.blue.shade300,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with warning icon if double-targeted
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isDoubleTargeted)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Colors.red.shade600,
                  ),
                ),
              Text(
                isDoubleTargeted ? '連合の標的' : '攻撃を受けている',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDoubleTargeted ? Colors.red.shade700 : Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Attack sources visualization
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: topAggressors.map((aggressorIdx) {
              final aggressorColor = _getPlayerColor(aggressorIdx);
              final attackCount = rivalryScores[aggressorIdx]?[currentPlayerIndex] ?? 0;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: aggressorColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      playerIds[aggressorIdx],
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (showCounts) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 10,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$attackCount',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getPlayerColor(int playerIndex) {
    switch (playerIndex) {
      case 0:
        return Colors.grey.shade900; // Black
      case 1:
        return Colors.grey.shade300; // White (lighter for contrast)
      case 2:
        return Colors.red.shade600; // Red
      default:
        return Colors.grey;
    }
  }
}

/// Compact rivalry indicator for display during play (minimal footprint)
class CompactRivalryIndicator extends StatelessWidget {
  /// Rivalry scores aggregated from recent rounds
  final Map<int, Map<int, int>> rivalryScores;

  /// Player index being targeted
  final int targetPlayerIndex;

  /// All player indices
  final List<int> allPlayers;

  const CompactRivalryIndicator({
    Key? key,
    required this.rivalryScores,
    required this.targetPlayerIndex,
    this.allPlayers = const [0, 1, 2],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDoubleTargeted = RivalryTracker.isDoubleTargeted(
      rivalryScores,
      targetPlayerIndex,
      allPlayers,
      minAttacksEach: 1,
    );

    if (!isDoubleTargeted) {
      return const SizedBox.shrink();
    }

    // Show warning indicator only when double-targeted
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.warning_rounded,
          size: 14,
          color: Colors.white,
        ),
      ),
    );
  }
}
