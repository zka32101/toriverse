import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/shop/domain/services/cosmetics_crafting_service.dart';
import 'package:toriverse/features/shop/application/providers/crafting_providers.dart';
import 'package:toriverse/shared/services/analytics_service.dart';

/// Card widget displaying a crafting recipe
class CraftingRecipeCard extends ConsumerStatefulWidget {
  final CraftingRecipe recipe;

  const CraftingRecipeCard({
    required this.recipe,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<CraftingRecipeCard> createState() => _CraftingRecipeCardState();
}

class _CraftingRecipeCardState extends ConsumerState<CraftingRecipeCard> {
  bool _isCrafting = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe result section
            Row(
              children: [
                // Result icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.dashboard,
                      size: 48,
                      color: Colors.teal.shade400,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Result info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.recipe.resultName,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'レア',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.recipe.craftingTimeMinutes} 分でクラフト完了',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Materials section
            Text(
              '必要な材料',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                ...widget.recipe.requiredMaterials
                    .asMap()
                    .entries
                    .map((entry) {
                      final index = entry.key;
                      final material = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index <
                                  widget.recipe.requiredMaterials.length - 1
                              ? 8
                              : 0,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.check_circle_outline,
                                  size: 20,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    material,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium,
                                  ),
                                  Text(
                                    'x1',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Colors.grey.shade500,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    })
                    .toList(),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Craft button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: _isCrafting
                  ? Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.teal.shade400,
                          ),
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () => _startCrafting(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade400,
                      ),
                      child: Text(
                        'クラフト開始',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startCrafting() async {
    setState(() => _isCrafting = true);

    try {
      final success = await ref
          .read(craftingNotifierProvider.notifier)
          .startCrafting(widget.recipe.resultId);

      if (!mounted) return;

      if (success) {
        _logCraftStarted();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('クラフトを開始しました！'),
            duration: Duration(seconds: 2),
          ),
        );

        // Refresh data
        ref.refresh(userCraftingProgressProvider);
      } else {
        _logCraftStartFailed('unknown');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('クラフト開始に失敗しました'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      _logCraftStartFailed(e.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラー: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCrafting = false);
      }
    }
  }

  void _logCraftStarted() {
    final analyticsService = AnalyticsService();
    analyticsService.logEvent(
      name: 'craft_started',
      parameters: {
        'cosmetic_id': widget.recipe.resultId,
        'recipe_id': widget.recipe.resultId,
        'crafting_time_minutes': widget.recipe.craftingTimeMinutes,
      },
    );
  }

  void _logCraftStartFailed(String reason) {
    final analyticsService = AnalyticsService();
    analyticsService.logEvent(
      name: 'craft_start_failed',
      parameters: {
        'cosmetic_id': widget.recipe.resultId,
        'reason': reason,
      },
    );
  }
}
