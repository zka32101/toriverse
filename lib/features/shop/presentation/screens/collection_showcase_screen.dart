import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toriverse/features/shop/application/providers/showcase_providers.dart';
import 'package:toriverse/shared/services/analytics_service.dart';
import '../widgets/collection_summary_card.dart';
import '../widgets/collection_grid.dart';
import '../widgets/achievement_badges.dart';

/// Collection showcase screen
class CollectionShowcaseScreen extends ConsumerStatefulWidget {
  const CollectionShowcaseScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CollectionShowcaseScreen> createState() =>
      _CollectionShowcaseScreenState();
}

class _CollectionShowcaseScreenState
    extends ConsumerState<CollectionShowcaseScreen> {
  @override
  void initState() {
    super.initState();
    _logScreenOpened();
  }

  Future<void> _logScreenOpened() async {
    final analyticsService = AnalyticsService();
    await analyticsService.logEvent(
      name: 'collection_showcase_opened',
      parameters: {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final showcaseAsync = ref.watch(showcaseDisplayProvider);
    final completionAsync = ref.watch(completionPercentageProvider);
    final achievementsAsync = ref.watch(collectionAchievementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('マイコレクション'),
        elevation: 0,
        actions: [
          // Share button
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: showcaseAsync.when(
              data: (_) => IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareCollection(),
                tooltip: 'シェア',
              ),
              loading: () => const SizedBox(width: 48),
              error: (_, __) => const SizedBox(width: 48),
            ),
          ),
        ],
      ),
      body: showcaseAsync.when(
        data: (showcase) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary card
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: completionAsync.when(
                    data: (completion) =>
                        CollectionSummaryCard(
                          totalOwned: showcase.totalOwned,
                          totalAvailable: showcase.totalAvailable,
                          completionPercentage: completion,
                        ),
                    loading: () =>
                        const SizedBox(height: 120, child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),

                const SizedBox(height: 24),

                // Achievements section
                if (achievementsAsync.hasValue)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'アチーブメント',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        AchievementBadges(
                          achievements: achievementsAsync.value ?? [],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                // Collections by rarity
                if (showcase.limitedEditions.isNotEmpty)
                  _RaritySection(
                    title: '限定版 (${showcase.limitedEditions.length})',
                    cosmetics: showcase.limitedEditions,
                    color: Colors.amber,
                  ),

                if (showcase.rareCosmetics.isNotEmpty)
                  _RaritySection(
                    title: 'レア (${showcase.rareCosmetics.length})',
                    cosmetics: showcase.rareCosmetics,
                    color: Colors.blue,
                  ),

                if (showcase.commonCosmetics.isNotEmpty)
                  _RaritySection(
                    title: 'コモン (${showcase.commonCosmetics.length})',
                    cosmetics: showcase.commonCosmetics,
                    color: Colors.grey,
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
            child: Text('エラー: ${error.toString()}'),
          ),
        ),
      ),
    );
  }

  Future<void> _shareCollection() async {
    try {
      final showcase = ref.read(showcaseDisplayProvider).value;
      final completion = ref.read(completionPercentageProvider).value;

      if (showcase == null || completion == null) return;

      final shareText = '🎨 マイコスメティックコレクション\n\n'
          '総数: ${showcase.totalOwned}個\n'
          '限定: ${showcase.limitedEditions.length}\n'
          'レア: ${showcase.rareCosmetics.length}\n'
          'コモン: ${showcase.commonCosmetics.length}\n\n'
          '進捗: ${completion.toStringAsFixed(1)}%\n\n'
          '#トリバース #cosmetics';

      await Share.share(shareText, subject: 'マイコレクション');

      ref.read(showcaseNotifierProvider.notifier).logCollectionShared(
            platform: 'share',
            cosmeticCount: showcase.totalOwned,
          );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('シェア失敗: $e')),
      );
    }
  }
}

class _RaritySection extends StatelessWidget {
  final String title;
  final List<CosmeticItem> cosmetics;
  final Color color;

  const _RaritySection({
    required this.title,
    required this.cosmetics,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CollectionGrid(cosmetics: cosmetics),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

import 'package:toriverse/shared/models/cosmetic_item.dart';
