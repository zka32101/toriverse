import 'package:flutter/material.dart';
import '../../domain/models/analytics_and_moderation.dart';

/// Presentational widget for displaying a user's earned achievement badges.
class AchievementBadgesWidget extends StatelessWidget {
  final List<AchievementBadge> badges;

  const AchievementBadgesWidget({
    Key? key,
    required this.badges,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return const Center(child: Text('No badges earned yet'));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) => _BadgeTile(badge: badges[index]),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final AchievementBadge badge;

  const _BadgeTile({Key? key, required this.badge}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: badge.description,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: _rarityColor(badge.rarityTier).withOpacity(0.15),
            child: Icon(Icons.emoji_events, color: _rarityColor(badge.rarityTier)),
          ),
          const SizedBox(height: 6),
          Text(
            badge.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _rarityColor(String? tier) {
    switch (tier) {
      case 'legendary':
        return Colors.orange;
      case 'epic':
        return Colors.purple;
      case 'rare':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
