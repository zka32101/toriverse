import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/shop/application/providers/battle_pass_providers.dart';
import 'package:toriverse/features/shop/domain/services/battle_pass_service.dart';
import 'package:toriverse/shared/services/analytics_service.dart';
import '../widgets/battle_pass_overview_card.dart';
import '../widgets/battle_pass_tier_card.dart';
import '../widgets/premium_pass_upsell.dart';

/// Main battle pass screen
class BattlePassScreen extends ConsumerStatefulWidget {
  const BattlePassScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BattlePassScreen> createState() => _BattlePassScreenState();
}

class _BattlePassScreenState extends ConsumerState<BattlePassScreen> {
  @override
  void initState() {
    super.initState();
    _logScreenOpened();
  }

  Future<void> _logScreenOpened() async {
    final analyticsService = AnalyticsService();
    await analyticsService.logEvent(
      name: 'battle_pass_screen_opened',
      parameters: {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(userBattlePassProgressProvider);
    final hasPremiumAsync = ref.watch(hasPremiumPassProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('バトルパス'),
        elevation: 0,
      ),
      body: progressAsync.when(
        data: (progress) {
          if (progress == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview card
                BattlePassOverviewCard(progress: progress),

                const SizedBox(height: 24),

                // Premium upsell (if not already premium)
                if (!progress.hasPremiumPass)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: PremiumPassUpsell(
                      onPurchase: () => _purchasePremiumPass(),
                    ),
                  ),

                if (!progress.hasPremiumPass) const SizedBox(height: 24),

                // Tier progression section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ティア進捗',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 12),

                      // All tiers
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: BattlePassService.maxTier,
                        itemBuilder: (context, index) {
                          final tier = index + 1;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: BattlePassTierCard(
                              tier: tier,
                              currentTier: progress.currentTier,
                              hasPremiumPass: progress.hasPremiumPass,
                              isClaimedReward:
                                  progress.claimedRewards.contains(tier),
                              onClaimReward: () => _claimReward(tier),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'エラー: ${error.toString()}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _purchasePremiumPass() async {
    final success = await ref
        .read(battlePassNotifierProvider.notifier)
        .purchasePremiumPass();

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('プレミアムパスを購入しました！'),
            duration: Duration(seconds: 2),
          ),
        );
        ref.refresh(userBattlePassProgressProvider);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('購入に失敗しました'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _claimReward(int tier) async {
    final success = await ref
        .read(battlePassNotifierProvider.notifier)
        .claimTierReward(tier);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('報酬を受け取りました！'),
            duration: Duration(seconds: 2),
          ),
        );
        ref.refresh(userBattlePassProgressProvider);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('報酬の受け取りに失敗しました'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
