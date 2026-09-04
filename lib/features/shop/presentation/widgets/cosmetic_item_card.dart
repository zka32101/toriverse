import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/shop/application/providers/cosmetics_providers.dart';
import 'package:toriverse/shared/models/cosmetic_item.dart';
import 'package:toriverse/shared/services/analytics_service.dart';

/// Card widget displaying a single cosmetic item
class CosmeticItemCard extends ConsumerStatefulWidget {
  final CosmeticItem cosmetic;

  const CosmeticItemCard({
    required this.cosmetic,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<CosmeticItemCard> createState() => _CosmeticItemCardState();
}

class _CosmeticItemCardState extends ConsumerState<CosmeticItemCard> {
  bool _isPurchasing = false;

  @override
  Widget build(BuildContext context) {
    final userOwnsCosmeticAsync =
        ref.watch(userOwnsCosmeticProvider(widget.cosmetic.id));
    final userPreference =
        ref.watch(userCosmeticsPreferenceProvider);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          _showDetailDialog(context);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview image/color
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _getCosmeticPreviewColor(widget.cosmetic),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getCosmeticIcon(widget.cosmetic.type),
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Item info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name
                  Text(
                    widget.cosmetic.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),

                  // Rarity badge
                  if (widget.cosmetic.rarity != CosmeticRarity.common)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getRarityColor(widget.cosmetic.rarity),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getRarityLabel(widget.cosmetic.rarity),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 20),

                  const SizedBox(height: 8),

                  // Price or owned indicator
                  userOwnsCosmeticAsync.when(
                    data: (owned) {
                      if (owned) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '所有中',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            userPreference.whenData(
                              (pref) {
                                final isActive = pref.activeCosmeticIds
                                    .contains(widget.cosmetic.id);
                                return SizedBox(
                                  width: double.infinity,
                                  height: 28,
                                  child: _isPurchasing
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : OutlinedButton(
                                          onPressed: isActive
                                              ? null
                                              : () => _setActive(),
                                          style: OutlinedButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                          child: Text(
                                            isActive
                                                ? '使用中'
                                                : 'セットする',
                                            style: const TextStyle(
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                );
                              },
                            ).unwrap(),
                          ],
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¥${widget.cosmetic.priceJpy}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: double.infinity,
                              height: 28,
                              child: _isPurchasing
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: () => _purchaseCosmetic(),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        visualDensity:
                                            VisualDensity.compact,
                                      ),
                                      child: const Text(
                                        '購入',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ),
                            ),
                          ],
                        );
                      }
                    },
                    loading: () => const SizedBox(
                      height: 20,
                      width: 20,
                      child:
                          CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (_, __) => const Text(
                      'エラー',
                      style: TextStyle(fontSize: 11, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context) {
    // Log preview event
    final userOwnsCosmeticAsync =
        ref.read(userOwnsCosmeticProvider(widget.cosmetic.id));
    userOwnsCosmeticAsync.whenData((owned) {
      _logCosmeticPreview(owned);
    });

    showDialog(
      context: context,
      builder: (context) => _CosmeticDetailDialog(
        cosmetic: widget.cosmetic,
      ),
    );
  }

  void _logCosmeticPreview(bool isOwned) {
    final analyticsService = AnalyticsService();
    analyticsService.logCosmeticItemPreviewed(
      cosmeticId: widget.cosmetic.id,
      cosmeticType: widget.cosmetic.typeString,
      rarity: widget.cosmetic.rarity.toString().split('.').last,
      priceYen: widget.cosmetic.priceJpy,
      isOwned: isOwned,
    );
  }

  void _purchaseCosmetic() async {
    setState(() => _isPurchasing = true);
    try {
      await ref
          .read(cosmeticsShopNotifierProvider.notifier)
          .purchaseCosmetic(widget.cosmetic.id);

      if (!mounted) return;

      // Log successful purchase
      _logCosmeticPurchaseSuccess();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('購入しました！')),
      );
    } catch (e) {
      if (!mounted) return;

      // Log purchase failure
      _logCosmeticPurchaseFailed(e.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('購入に失敗しました: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  void _logCosmeticPurchaseSuccess() {
    final analyticsService = AnalyticsService();
    analyticsService.logCosmeticPurchased(
      cosmeticId: widget.cosmetic.id,
      cosmeticType: widget.cosmetic.typeString,
      rarity: widget.cosmetic.rarity.toString().split('.').last,
      priceYen: widget.cosmetic.priceJpy,
      paymentMethod: 'in_app',
    );
  }

  void _logCosmeticPurchaseFailed(String error) {
    final analyticsService = AnalyticsService();
    String failureReason = 'unknown';
    if (error.contains('insufficient')) {
      failureReason = 'insufficient_balance';
    } else if (error.contains('payment')) {
      failureReason = 'payment_failed';
    } else if (error.contains('network')) {
      failureReason = 'network_error';
    }
    analyticsService.logCosmeticPurchaseFailed(
      cosmeticId: widget.cosmetic.id,
      cosmeticType: widget.cosmetic.typeString,
      failureReason: failureReason,
    );
  }

  void _setActive() async {
    try {
      await ref
          .read(cosmeticsShopNotifierProvider.notifier)
          .setActiveCosmectic(widget.cosmetic.id);

      if (!mounted) return;

      // Log cosmetic applied to match
      _logCosmeticApplied();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('セットしました！')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('セットに失敗しました: $e')),
      );
    }
  }

  void _logCosmeticApplied() {
    final analyticsService = AnalyticsService();
    analyticsService.logCosmeticAppliedToMatch(
      cosmeticId: widget.cosmetic.id,
      cosmeticType: widget.cosmetic.typeString,
      rarity: widget.cosmetic.rarity.toString().split('.').last,
    );
  }

  Color _getCosmeticPreviewColor(CosmeticItem cosmetic) {
    // Generate a preview color based on cosmetic type and ID
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

class _CosmeticDetailDialog extends ConsumerWidget {
  final CosmeticItem cosmetic;

  const _CosmeticDetailDialog({
    required this.cosmetic,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text(cosmetic.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Preview container
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.dashboard,
                  size: 64,
                  color: Colors.teal.shade400,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              cosmetic.description ?? 'No description available',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),

            // Rarity
            Row(
              children: [
                Text(
                  'レアリティ: ',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  _getRarityLabel(cosmetic.rarity),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Price
            Row(
              children: [
                Text(
                  '価格: ',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '¥${cosmetic.priceJpy}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('閉じる'),
        ),
      ],
    );
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
