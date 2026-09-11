import 'package:flutter/material.dart';
import '../../data/models/event_model.dart';

/// Reward preview widget displaying challenge rewards
class RewardPreview extends StatelessWidget {
  final ChallengeReward reward;
  final String? cosmeticImageUrl;

  const RewardPreview({
    Key? key,
    required this.reward,
    this.cosmeticImageUrl,
  }) : super(key: key);

  Color getTierColor() {
    switch (reward.tier.toLowerCase()) {
      case 'gold':
        return Colors.amber.shade400;
      case 'silver':
        return Colors.grey.shade400;
      case 'bronze':
        return Colors.brown.shade400;
      default:
        return Colors.grey.shade300;
    }
  }

  IconData getTierIcon() {
    switch (reward.tier.toLowerCase()) {
      case 'gold':
        return Icons.emoji_events;
      case 'silver':
        return Icons.emoji_medal;
      case 'bronze':
        return Icons.emoji_objects;
      default:
        return Icons.card_giftcard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: getTierColor(), width: 2),
        borderRadius: BorderRadius.circular(12),
        color: getTierColor().withOpacity(0.05),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tier badge
            Row(
              children: [
                Icon(
                  getTierIcon(),
                  color: getTierColor(),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  reward.tier.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: getTierColor(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Cosmetic preview
            if (cosmeticImageUrl != null)
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.network(
                  cosmeticImageUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.card_giftcard,
                        color: Colors.grey.shade400,
                        size: 40,
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: getTierColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.card_giftcard,
                    color: getTierColor(),
                    size: 40,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Reward details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Points',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${reward.rankPoints}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: getTierColor(),
                          ),
                    ),
                  ],
                ),
                Expanded(
                  child: Text(
                    reward.description ?? 'Unlock exclusive cosmetic',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.end,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
