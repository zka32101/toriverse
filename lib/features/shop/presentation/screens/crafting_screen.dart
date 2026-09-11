import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/shop/application/providers/crafting_providers.dart';
import 'package:toriverse/shared/services/analytics_service.dart';
import '../widgets/crafting_recipe_card.dart';
import '../widgets/crafting_progress_widget.dart';

/// Main cosmetics crafting screen
class CraftingScreen extends ConsumerStatefulWidget {
  const CraftingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CraftingScreen> createState() => _CraftingScreenState();
}

class _CraftingScreenState extends ConsumerState<CraftingScreen> {
  @override
  void initState() {
    super.initState();
    _logScreenOpened();
  }

  Future<void> _logScreenOpened() async {
    final analyticsService = AnalyticsService();
    await analyticsService.logEvent(
      name: 'crafting_screen_opened',
      parameters: {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final craftingProgressAsync = ref.watch(userCraftingProgressProvider);
    final availableRecipesAsync = ref.watch(availableCraftingRecipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('クラフト'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active crafting progress section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '現在のクラフト',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    craftingProgressAsync.when(
                      data: (progress) {
                        if (progress == null) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.workspaces_outline,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'アクティブなクラフトはありません',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                ),
                              ],
                            ),
                          );
                        }

                        return CraftingProgressWidget(progress: progress);
                      },
                      loading: () => const SizedBox(
                        height: 120,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, stack) => Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'エラー: ${error.toString()}',
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Available recipes section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '利用可能なレシピ',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    availableRecipesAsync.when(
                      data: (recipes) {
                        if (recipes.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 24,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.amber.shade200,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 40,
                                  color: Colors.amber.shade600,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'クラフト可能なレシピはありません',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: Colors.amber.shade800,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '材料となるコスメティックを集めてください',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.amber.shade700,
                                      ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: [
                            ...recipes
                                .asMap()
                                .entries
                                .map((entry) {
                                  final index = entry.key;
                                  final recipe = entry.value;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: index < recipes.length - 1
                                          ? 12
                                          : 0,
                                    ),
                                    child: CraftingRecipeCard(
                                      recipe: recipe,
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
                      error: (error, stack) => Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'エラー: ${error.toString()}',
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Info section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ℹ️ クラフトについて',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '3つのコモンコスメティックを消費して、1つのレアコスメティックを作成できます。クラフト中は通常通りゲームをプレイできます。',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue.shade800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'クラフト完了時に通知を受け取ります。',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
