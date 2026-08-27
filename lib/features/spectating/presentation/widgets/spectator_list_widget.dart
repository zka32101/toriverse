import 'package:flutter/material.dart';

import '../../domain/models/spectator_session.dart';

/// Displays list of users currently spectating the match
class SpectatorListWidget extends StatelessWidget {
  final List<SpectatorSession> spectators;

  const SpectatorListWidget({
    Key? key,
    required this.spectators,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (spectators.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.visibility_off,
              size: 48,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No other spectators',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: spectators.length,
      itemBuilder: (context, index) {
        final spectator = spectators[index];
        return SpectatorListTile(spectator: spectator);
      },
    );
  }
}

/// Single spectator list item
class SpectatorListTile extends StatelessWidget {
  final SpectatorSession spectator;

  const SpectatorListTile({
    Key? key,
    required this.spectator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          spectator.displayName.isNotEmpty
              ? spectator.displayName[0].toUpperCase()
              : '?',
        ),
      ),
      title: Text(spectator.displayName),
      subtitle: Text(
        _getRoleLabel(spectator.role),
        style: Theme.of(context).textTheme.labelSmall,
      ),
      trailing: _buildRoleBadge(context, spectator.role),
    );
  }

  String _getRoleLabel(SpectatorRole role) {
    switch (role) {
      case SpectatorRole.viewer:
        return 'Viewer';
      case SpectatorRole.commentator:
        return 'Commentator';
      case SpectatorRole.streamer:
        return 'Streamer';
    }
  }

  Widget _buildRoleBadge(BuildContext context, SpectatorRole role) {
    final color = _getRoleColor(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        _getRoleEmoji(role),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }

  Color _getRoleColor(SpectatorRole role) {
    switch (role) {
      case SpectatorRole.viewer:
        return Colors.blue;
      case SpectatorRole.commentator:
        return Colors.orange;
      case SpectatorRole.streamer:
        return Colors.purple;
    }
  }

  String _getRoleEmoji(SpectatorRole role) {
    switch (role) {
      case SpectatorRole.viewer:
        return '👁️';
      case SpectatorRole.commentator:
        return '🎤';
      case SpectatorRole.streamer:
        return '📺';
    }
  }
}
