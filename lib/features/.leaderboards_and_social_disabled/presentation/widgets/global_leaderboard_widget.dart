import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/leaderboards_and_social_providers.dart';
import '../../domain/models/leaderboards_and_social.dart';

class GlobalLeaderboardWidget extends ConsumerWidget {
  final int limit;
  final bool showSeason;

  const GlobalLeaderboardWidget({
    Key? key,
    this.limit = 100,
    this.showSeason = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(
      watchGlobalLeaderboardProvider(LeaderboardParam(limit)),
    );

    return leaderboardAsync.when(
      data: (rankings) => _buildLeaderboardList(context, rankings),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading leaderboard: $error'),
      ),
    );
  }

  Widget _buildLeaderboardList(
    BuildContext context,
    List<GlobalRanking> rankings,
  ) {
    if (rankings.isEmpty) {
      return const Center(child: Text('No rankings available'));
    }

    return ListView.builder(
      itemCount: rankings.length,
      itemBuilder: (context, index) {
        final ranking = rankings[index];
        return _LeaderboardTile(ranking: ranking, position: index + 1);
      },
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final GlobalRanking ranking;
  final int position;

  const _LeaderboardTile({
    Key? key,
    required this.ranking,
    required this.position,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = {
      RankTier.bronze: Colors.orange,
      RankTier.silver: Colors.grey[400],
      RankTier.gold: Colors.amber,
      RankTier.platinum: Colors.cyan,
      RankTier.diamond: Colors.purple,
      RankTier.legendary: Colors.red,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors[ranking.tier] ?? Colors.grey,
              ),
              child: Center(
                child: Text(
                  '#$position',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Player info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Player ${ranking.userId.substring(0, 8)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${ranking.wins}W - ${ranking.losses}L (${(ranking.winRate * 100).toStringAsFixed(1)}%)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Rating and streak
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${ranking.rating.toStringAsFixed(0)} RP',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ranking.streakCurrent > 0
                        ? Colors.green[100]
                        : Colors.red[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${ranking.streakCurrent}🔥',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
