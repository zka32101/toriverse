import 'package:flutter/material.dart';
import '../../data/models/leaderboard_model.dart';

/// Leaderboard entry widget displaying player ranking information
class LeaderboardEntryWidget extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;

  const LeaderboardEntryWidget({
    Key? key,
    required this.entry,
    required this.rank,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color getRankColor() {
      if (rank == 1) return Colors.amber;
      if (rank == 2) return Colors.grey[400]!;
      if (rank == 3) return Colors.brown.shade400;
      return Colors.transparent;
    }

    Widget getRankIcon() {
      if (rank == 1) {
        return const Icon(Icons.emoji_events, color: Colors.amber, size: 28);
      } else if (rank == 2) {
        return const Icon(Icons.emoji_events, color: Colors.grey, size: 28);
      } else if (rank == 3) {
        return const Icon(Icons.emoji_events, color: Colors.brown, size: 28);
      } else {
        return Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          // Rank icon
          getRankIcon(),
          const SizedBox(width: 16),

          // Player info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.completedChallenges} challenges',
                      style:
                          Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.card_giftcard,
                      size: 14,
                      color: Colors.purple.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.unlockedCosmetics} cosmetics',
                      style:
                          Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.score}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'points',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
