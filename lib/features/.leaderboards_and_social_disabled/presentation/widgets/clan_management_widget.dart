import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/leaderboards_and_social_providers.dart';
import '../../domain/models/leaderboards_and_social.dart';

class ClanManagementWidget extends ConsumerWidget {
  final String clanId;

  const ClanManagementWidget({
    Key? key,
    required this.clanId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clanAsync = ref.watch(clanProvider(ClanIdParam(clanId)));
    final membersAsync = ref.watch(watchClanMembersProvider(ClanIdParam(clanId)));

    return clanAsync.when(
      data: (clan) => membersAsync.when(
        data: (members) => _buildClanView(context, clan, members),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading members: $error'),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading clan: $error'),
      ),
    );
  }

  Widget _buildClanView(
    BuildContext context,
    Clan clan,
    List<ClanMembership> members,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Clan header
          Container(
            color: _parseColorFromString(clan.tagColor),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    clan.clanName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  clan.clanName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Clan stats
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2,
                  children: [
                    _StatCard(
                      label: 'Members',
                      value: '${clan.memberCount}',
                    ),
                    _StatCard(
                      label: 'Matches',
                      value: '${clan.totalMatches}',
                    ),
                    _StatCard(
                      label: 'Wins',
                      value: '${clan.totalWins}',
                    ),
                    _StatCard(
                      label: 'Rating',
                      value: '${clan.clanRating.toStringAsFixed(0)}',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Description
                Text(
                  'About',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  clan.description,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                // Members list
                Text(
                  'Members',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return _MemberTile(membership: member);
                  },
                ),
              ],
            ),
          ),
        ],
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

class _MemberTile extends StatelessWidget {
  final ClanMembership membership;

  const _MemberTile({
    Key? key,
    required this.membership,
  }) : super(key: key);

  String _getRoleLabel(ClanMemberRole role) {
    switch (role) {
      case ClanMemberRole.founder:
        return 'Founder';
      case ClanMemberRole.officer:
        return 'Officer';
      case ClanMemberRole.member:
        return 'Member';
    }
  }

  Color _getRoleColor(ClanMemberRole role) {
    switch (role) {
      case ClanMemberRole.founder:
        return Colors.purple;
      case ClanMemberRole.officer:
        return Colors.blue;
      case ClanMemberRole.member:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: Text(membership.userId[0].toUpperCase()),
        ),
        title: Text('User ${membership.userId.substring(0, 8)}'),
        subtitle: Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _getRoleColor(membership.role).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _getRoleLabel(membership.role),
            style: TextStyle(
              fontSize: 11,
              color: _getRoleColor(membership.role),
            ),
          ),
        ),
        trailing: Text(
          '${membership.contributionScore} pts',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        onTap: () {
          // Navigate to member profile or open options
        },
      ),
    );
  }
}

Color _parseColorFromString(String colorString) {
  // Simple color parsing - in production, use a more robust method
  final colorMap = {
    'red': Colors.red,
    'blue': Colors.blue,
    'green': Colors.green,
    'yellow': Colors.yellow,
    'purple': Colors.purple,
    'orange': Colors.orange,
  };
  return colorMap[colorString.toLowerCase()] ?? Colors.grey;
}
