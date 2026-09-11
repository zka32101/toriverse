import 'package:flutter/material.dart';
import 'package:toriverse/config/theme.dart';

/// Indicator widget showing AI takeover status
///
/// Displays which players have been replaced by AI due to disconnection.
/// Shows the AI takeover reason and activation time for debugging.
class AITakeoverIndicatorWidget extends StatelessWidget {
  /// Map of playerId -> reason ('inactivity', 'timeout', 'manual')
  final Map<String, String> aiControlledPlayers;

  /// Player IDs in order (for color mapping)
  final List<String> playerIds;

  /// Called when user clicks to see detailed info
  final VoidCallback? onTap;

  const AITakeoverIndicatorWidget({
    Key? key,
    required this.aiControlledPlayers,
    required this.playerIds,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (aiControlledPlayers.isEmpty) {
      // No AI takeover active
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          border: Border.all(
            color: Colors.orange.shade300,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with warning icon
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.smart_toy_rounded,
                  size: 16,
                  color: Colors.orange.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  'AI引き継ぎ中',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // AI-controlled players
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: aiControlledPlayers.entries.map((entry) {
                final playerId = entry.key;
                final reason = entry.value;
                final playerIndex = playerIds.indexOf(playerId);
                final playerColor = _getPlayerColor(playerIndex);

                return Tooltip(
                  message: 'AI took over ($reason)',
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: playerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          playerId,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.smart_toy,
                          size: 10,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
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

/// Compact AI takeover indicator (minimal footprint, icon-only)
class CompactAITakeoverIndicator extends StatelessWidget {
  /// Number of players with AI takeover active
  final int aiTakeoverCount;

  const CompactAITakeoverIndicator({
    Key? key,
    required this.aiTakeoverCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (aiTakeoverCount == 0) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: '$aiTakeoverCount player(s) using AI takeover',
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.orange.shade600,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            aiTakeoverCount.toString(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
