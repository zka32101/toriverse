/// Leaderboard screen displaying global and friend rankings
///
/// Shows top players, allows filtering by time period, and displays
/// contextual rankings around the current player.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../leaderboard/application/providers/leaderboard_provider.dart';
import '../../../leaderboard/domain/models/leaderboard_models.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  int _selectedIndex = 0; // 0: Global, 1: Friends

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tab selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    'Global',
                    isSelected: _selectedIndex == 0,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTabButton(
                    'Friends',
                    isSelected: _selectedIndex == 1,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                ),
              ],
            ),
          ),
          // Leaderboard content
          Expanded(
            child: _selectedIndex == 0
                ? _buildGlobalLeaderboard(context, ref)
                : _buildFriendsLeaderboard(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    String label, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildGlobalLeaderboard(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(globalLeaderboardProvider(100));

    return leaderboardAsync.when(
      data: (leaderboard) {
        if (leaderboard.entries.isEmpty) {
          return const Center(
            child: Text('No players on leaderboard'),
          );
        }

        return ListView.builder(
          itemCount: leaderboard.entries.length,
          itemBuilder: (context, index) {
            final entry = leaderboard.entries[index];
            return _buildLeaderboardEntry(entry, index + 1);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildFriendsLeaderboard(BuildContext context, WidgetRef ref) {
    // TODO: Integrate with friend system to fetch friend UIDs
    // For now, show placeholder
    return const Center(
      child: Text('Friends leaderboard coming soon'),
    );
  }

  Widget _buildLeaderboardEntry(
    PlayerLeaderboardEntry entry,
    int displayRank,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Rank badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getRankColor(displayRank),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$displayRank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Player info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${entry.rankPoints} pts • ${entry.totalWins}W-${entry.totalLosses}L',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // Win rate
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(entry.winRate * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    'win rate',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey;
    if (rank == 3) return Colors.orange;
    if (rank <= 10) return Colors.blue;
    return Colors.grey;
  }
}
