import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/shop/application/providers/seasonal_providers.dart';
import 'package:toriverse/features/shop/domain/services/seasonal_cosmetics_service.dart';

/// Header showing current season information
class SeasonalHeader extends ConsumerWidget {
  final Season season;

  const SeasonalHeader({
    required this.season,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysUntilEnd = ref.watch(daysUntilSeasonEndProvider);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getSeasonColor(season.theme).shade600,
            _getSeasonColor(season.theme).shade400,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Season name and theme
            Row(
              children: [
                Icon(
                  _getSeasonIcon(season.theme),
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        season.name,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${season.startDate} - ${season.endDate}',
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Countdown
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    daysUntilEnd > 0
                        ? '残り $daysUntilEnd 日'
                        : 'シーズン終了',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Featured count
            Text(
              '${season.featuredCosmetics.length} 個の限定コスメティックス',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  MaterialColor _getSeasonColor(SeasonalTheme theme) {
    switch (theme) {
      case SeasonalTheme.autumn:
        return Colors.orange;
      case SeasonalTheme.winter:
        return Colors.cyan;
      case SeasonalTheme.spring:
        return Colors.pink;
      case SeasonalTheme.summer:
        return Colors.amber;
      case SeasonalTheme.festival:
        return Colors.red;
      case SeasonalTheme.anniversary:
        return Colors.purple;
      case SeasonalTheme.holiday:
        return Colors.green;
      case SeasonalTheme.special:
        return Colors.indigo;
    }
  }

  IconData _getSeasonIcon(SeasonalTheme theme) {
    switch (theme) {
      case SeasonalTheme.autumn:
        return Icons.eco;
      case SeasonalTheme.winter:
        return Icons.wb_sunny;
      case SeasonalTheme.spring:
        return Icons.favorite;
      case SeasonalTheme.summer:
        return Icons.brightness_7;
      case SeasonalTheme.festival:
        return Icons.celebration;
      case SeasonalTheme.anniversary:
        return Icons.cake;
      case SeasonalTheme.holiday:
        return Icons.card_giftcard;
      case SeasonalTheme.special:
        return Icons.star;
    }
  }
}
