import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/shop/application/providers/battle_pass_providers.dart';

/// Card showing individual tier with rewards
class BattlePassTierCard extends ConsumerWidget {
  final int tier;
  final int currentTier;
  final bool hasPremiumPass;
  final bool isClaimedReward;
  final VoidCallback onClaimReward;

  const BattlePassTierCard({
    required this.tier,
    required this.currentTier,
    required this.hasPremiumPass,
    required this.isClaimedReward,
    required this.onClaimReward,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final battlePassService = ref.watch(battlePassServiceProvider);
    final tierInfo = battlePassService.getTierReward(tier);

    if (tierInfo == null) return const SizedBox.shrink();

    final isCompleted = currentTier >= tier;
    final isUpcoming = currentTier < tier;
    final canClaim = isCompleted && !isClaimedReward;

    return Container(
      decoration: BoxDecoration(
        color: isUpcoming
            ? Colors.grey.shade100
            : isClaimedReward
                ? Colors.green.shade50
                : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUpcoming
              ? Colors.grey.shade300
              : isClaimedReward
                  ? Colors.green.shade200
                  : Colors.blue.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Tier number and status
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUpcoming
                    ? Colors.grey.shade300
                    : isClaimedReward
                        ? Colors.green.shade400
                        : Colors.blue.shade400,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tier.toString(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (isClaimedReward)
                      Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Reward info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tierInfo.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Free reward
                      if (tierInfo.freeReward != null)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '無料',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
                                        fontSize: 10,
                                      ),
                                ),
                                Text(
                                  tierInfo.freeReward!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      if (tierInfo.freeReward != null &&
                          tierInfo.premiumReward != null)
                        const SizedBox(width: 8),

                      // Premium reward
                      if (tierInfo.premiumReward != null)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 10,
                                      color: Colors.amber.shade700,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'プレミアム',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Colors.amber.shade700,
                                            fontSize: 10,
                                          ),
                                    ),
                                  ],
                                ),
                                Text(
                                  tierInfo.premiumReward!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber.shade900,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Action button
            if (isUpcoming)
              Icon(
                Icons.lock,
                color: Colors.grey.shade400,
              )
            else if (isClaimedReward)
              Icon(
                Icons.check_circle,
                color: Colors.green.shade400,
                size: 28,
              )
            else if (canClaim)
              SizedBox(
                width: 80,
                child: ElevatedButton(
                  onPressed: onClaimReward,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade400,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(
                    '受け取る',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              )
            else
              const SizedBox(width: 80),
          ],
        ),
      ),
    );
  }
}
