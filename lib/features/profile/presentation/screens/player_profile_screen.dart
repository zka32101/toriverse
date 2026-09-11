/// Player profile screen displaying player stats and achievements
///
/// Shows player's rank, stats, achievements, and allows editing own profile.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/domain/models/player_profile_models.dart';

class PlayerProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  final bool isOwnProfile;

  const PlayerProfileScreen({
    Key? key,
    required this.uid,
    this.isOwnProfile = false,
  }) : super(key: key);

  @override
  ConsumerState<PlayerProfileScreen> createState() =>
      _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends ConsumerState<PlayerProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Profile'),
        actions: widget.isOwnProfile
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Navigate to edit profile screen
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              _buildProfileHeader(),
              const SizedBox(height: 24),
              // Stats section
              _buildStatsSection(),
              const SizedBox(height: 24),
              // Achievements section
              _buildAchievementsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: const Center(
              child: Icon(Icons.person, size: 40),
            ),
          ),
          const SizedBox(height: 16),
          // Username
          const Text(
            'Player Username',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Rank and points
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Rank #1 • 1500 points',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // Stats grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildStatCard('Total Matches', '50', Icons.sports_esports),
            _buildStatCard('Wins', '35', Icons.emoji_events),
            _buildStatCard('Win Rate', '70%', Icons.trending_up),
            _buildStatCard('Best Streak', '12', Icons.local_fire_department),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Achievements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // Achievements list
        for (int i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Text(
                      '🏆',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'First Victory',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Win your first match',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      '✓',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
