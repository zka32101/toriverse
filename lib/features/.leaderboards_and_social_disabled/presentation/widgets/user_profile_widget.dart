import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/leaderboards_and_social_providers.dart';
import '../../domain/models/leaderboards_and_social.dart';

class UserProfileWidget extends ConsumerWidget {
  final String userId;

  const UserProfileWidget({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider(UserIdParam(userId)));

    return profileAsync.when(
      data: (profile) => _buildProfileCard(context, profile),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading profile: $error'),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, UserProfile profile) {
    return SingleChildScrollView(
      child: Card(
        margin: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar and name
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[300],
                child: Text(
                  profile.displayName.isNotEmpty
                      ? profile.displayName[0]
                      : '?',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                profile.displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (profile.isVerified)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Verified ✓',
                    style: TextStyle(fontSize: 11, color: Colors.blue),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                profile.bio,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              // Stats grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2,
                children: [
                  _StatCard(label: 'Matches', value: '${profile.totalMatches}'),
                  _StatCard(label: 'Wins', value: '${profile.totalWins}'),
                  _StatCard(
                    label: 'Win Rate',
                    value: profile.totalMatches > 0
                        ? '${((profile.totalWins / profile.totalMatches) * 100).toStringAsFixed(1)}%'
                        : '0%',
                  ),
                  _StatCard(label: 'Clips', value: '${profile.totalClipsCreated}'),
                ],
              ),
              const SizedBox(height: 16),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add Friend'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Follow'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.block),
                      label: const Text('Block'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.volume_off),
                      label: const Text('Mute'),
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
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
