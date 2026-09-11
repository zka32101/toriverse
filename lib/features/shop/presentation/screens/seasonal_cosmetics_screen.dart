import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/shop/application/providers/seasonal_providers.dart';
import 'package:toriverse/features/shop/domain/services/seasonal_cosmetics_service.dart';
import 'package:toriverse/shared/services/analytics_service.dart';
import '../widgets/seasonal_header.dart';
import '../widgets/seasonal_cosmetic_card.dart';
import '../widgets/archived_cosmetics_section.dart';

/// Seasonal cosmetics screen
class SeasonalCosmeticsScreen extends ConsumerStatefulWidget {
  const SeasonalCosmeticsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SeasonalCosmeticsScreen> createState() =>
      _SeasonalCosmeticsScreenState();
}

class _SeasonalCosmeticsScreenState extends ConsumerState<SeasonalCosmeticsScreen> {
  @override
  void initState() {
    super.initState();
    _logScreenOpened();
  }

  Future<void> _logScreenOpened() async {
    final analyticsService = AnalyticsService();
    await analyticsService.logEvent(
      name: 'seasonal_cosmetics_screen_opened',
      parameters: {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSeasonAsync = ref.watch(currentSeasonProvider);
    final nextSeasonAsync = ref.watch(nextSeasonProvider);
    final currentSeasonalCosmeticsAsync =
        ref.watch(currentSeasonalCosmeticsProvider);
    final archivedCosmeticsAsync = ref.watch(archivedCosmeticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('シーズナルコスメティックス'),
        elevation: 0,
      ),
      body: currentSeasonAsync.when(
        data: (currentSeason) {
          if (currentSeason == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'シーズンデータが利用できません',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Season header
                SeasonalHeader(season: currentSeason),

                const SizedBox(height: 24),

                // Current season cosmetics
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '今シーズンの特集',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 12),
                      currentSeasonalCosmeticsAsync.when(
                        data: (cosmetics) {
                          if (cosmetics.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                child: Text(
                                  'コスメティックスがありません',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              ...cosmetics
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                    final index = entry.key;
                                    final cosmetic = entry.value;
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: index < cosmetics.length - 1
                                            ? 12
                                            : 0,
                                      ),
                                      child: SeasonalCosmeticCard(
                                        cosmetic: cosmetic,
                                        season: currentSeason,
                                      ),
                                    );
                                  })
                                  .toList(),
                            ],
                          );
                        },
                        loading: () => const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, stack) => Center(
                          child: Text('エラー: ${error.toString()}'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Next season preview
                if (nextSeasonAsync.hasValue && nextSeasonAsync.value != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '次シーズン予告',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.indigo.shade200,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nextSeasonAsync.value!.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo.shade700,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '開始: ${nextSeasonAsync.value!.startDate}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.indigo.shade600,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${nextSeasonAsync.value!.featuredCosmetics.length} 個の新コスメティックス予定',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Colors.indigo.shade600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                // Archived cosmetics
                archivedCosmeticsAsync.when(
                  data: (archived) {
                    if (archived.isNotEmpty) {
                      return ArchivedCosmeticsSection(
                        archivedCosmetics: archived,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
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
}
