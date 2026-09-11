import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/shop/application/providers/seasonal_providers.dart';
import 'package:toriverse/features/shop/domain/services/seasonal_cosmetics_service.dart';
import 'package:toriverse/shared/models/cosmetic_item.dart';

/// Card showing a seasonal cosmetic with availability badge
class SeasonalCosmeticCard extends ConsumerWidget {
  final CosmeticItem cosmetic;
  final Season season;

  const SeasonalCosmeticCard({
    required this.cosmetic,
    required this.season,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonalService = ref.watch(seasonalCosmeticsServiceProvider);
    final daysLeft = seasonalService.getDaysUntilSeasonEnd(season);
    final isAvailable = seasonalService.isCosmeticAvailable(cosmetic.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isAvailable ? Colors.amber.shade200 : Colors.grey.shade300,
          width: isAvailable ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Preview
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _getCosmeticColor(cosmetic),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  _getCosmeticIcon(cosmetic.type),
                  size: 56,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cosmetic.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),

                  // Rarity badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getRarityColor(cosmetic.rarity),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getRarityLabel(cosmetic.rarity),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Price
                  Text(
                    '¥${cosmetic.priceJpy}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                  ),

                  const SizedBox(height: 8),

                  // Availability badge
                  if (isAvailable)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: daysLeft <= 7
                            ? Colors.red.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: daysLeft <= 7
                              ? Colors.red.shade300
                              : Colors.green.shade300,
                        ),
                      ),
                      child: Text(
                        daysLeft <= 7
                            ? '残り $daysLeft 日で入手不可'
                            : '今すぐ入手可能',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color: daysLeft <= 7
                                  ? Colors.red.shade700
                                  : Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        '入手不可',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Action
            if (isAvailable)
              SizedBox(
                width: 80,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade400,
                  ),
                  child: Text(
                    '購入',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              )
            else
              SizedBox(
                width: 80,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  child: Text(
                    '表示',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getCosmeticColor(CosmeticItem cosmetic) {
    switch (cosmetic.type) {
      case CosmeticType.board:
        return Colors.teal.shade400;
      case CosmeticType.stoneBlack:
        return Colors.grey.shade800;
      case CosmeticType.stoneWhite:
        return Colors.grey.shade200;
      case CosmeticType.stoneRed:
        return Colors.red.shade400;
    }
  }

  IconData _getCosmeticIcon(CosmeticType type) {
    switch (type) {
      case CosmeticType.board:
        return Icons.dashboard;
      case CosmeticType.stoneBlack:
      case CosmeticType.stoneWhite:
      case CosmeticType.stoneRed:
        return Icons.circle;
    }
  }

  Color _getRarityColor(CosmeticRarity rarity) {
    switch (rarity) {
      case CosmeticRarity.common:
        return Colors.grey;
      case CosmeticRarity.rare:
        return Colors.blue;
      case CosmeticRarity.limited:
        return Colors.amber;
    }
  }

  String _getRarityLabel(CosmeticRarity rarity) {
    switch (rarity) {
      case CosmeticRarity.common:
        return 'コモン';
      case CosmeticRarity.rare:
        return 'レア';
      case CosmeticRarity.limited:
        return '限定';
    }
  }
}
