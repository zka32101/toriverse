import 'package:flutter/material.dart';

/// Displays player information in spectator view
///
/// Shows:
/// - Player name
/// - Stone count/score
/// - Status indicator (playing, passed, etc.)
class SpectatorInfoCard extends StatelessWidget {
  final int playerIndex;
  // TODO: Replace with actual Match type when imported
  final dynamic match;

  const SpectatorInfoCard({
    Key? key,
    required this.playerIndex,
    required this.match,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Get actual player data from match
    final playerName = 'Player ${playerIndex + 1}';
    final stoneCount = 10 + (playerIndex * 5); // Placeholder
    final isActive = playerIndex == 0; // Placeholder

    return Column(
      children: [
        // Player name
        Text(
          playerName,
          style: Theme.of(context).textTheme.titleSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Stone count with progress indicator
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.surfaceVariant,
            border: Border.all(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '$stoneCount',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Status badge
        if (isActive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green),
            ),
            child: Text(
              '🎮 Playing',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.green,
                  ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            child: Text(
              'Waiting',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
      ],
    );
  }
}
