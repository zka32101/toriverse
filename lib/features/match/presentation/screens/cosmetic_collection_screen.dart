import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/cosmetic_state.dart';
import '../../application/providers/streak_state.dart';

/// Full-screen cosmetic collection browser and management
///
/// Features:
/// - View owned cosmetics with active/inactive status
/// - Browse available cosmetics for purchase
/// - Filter by type (board, stone)
/// - Activate cosmetics
/// - Preview cosmetic details
/// - Show cosmetics earned from streaks
class CosmeticCollectionScreen extends ConsumerStatefulWidget {
  const CosmeticCollectionScreen({super.key});

  @override
  ConsumerState<CosmeticCollectionScreen> createState() =>
      _CosmeticCollectionScreenState();
}

class _CosmeticCollectionScreenState
    extends ConsumerState<CosmeticCollectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cosmetics Collection'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Owned'),
            Tab(text: 'Shop'),
            Tab(text: 'Boards'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOwnedTab(),
          _buildShopTab(),
          _buildBoardsTab(),
        ],
      ),
    );
  }

  /// Owned cosmetics tab
  Widget _buildOwnedTab() {
    return Consumer(
      builder: (context, ref, _) {
        final ownedCosmetics = ref.watch(ownedCosmeticsProvider);
        final cosmeticState = ref.watch(cosmeticProvider);

        if (ownedCosmetics.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '✨',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'No cosmetics yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete matches to earn cosmetics',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: ownedCosmetics.length,
          itemBuilder: (context, index) {
            final owned = ownedCosmetics[index];
            final cosmetic = cosmeticState.getCosmeticById(owned.itemId);

            if (cosmetic == null) return const SizedBox.shrink();

            return _buildCosmeticCard(
              context,
              ref,
              cosmetic,
              owned,
              cosmeticState,
            );
          },
        );
      },
    );
  }

  /// Shop/available cosmetics tab
  Widget _buildShopTab() {
    return Consumer(
      builder: (context, ref, _) {
        final available = ref.watch(availableCosmeticsProvider);

        if (available.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎁', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  'Nothing new right now',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Check back later for seasonal items',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: available.length,
          itemBuilder: (context, index) {
            final cosmetic = available[index];
            return _buildPurchasableCard(context, cosmetic);
          },
        );
      },
    );
  }

  /// Boards-only tab
  Widget _buildBoardsTab() {
    return Consumer(
      builder: (context, ref, _) {
        final boards = ref.watch(ownedCosmeticsByTypeProvider('board'));

        if (boards.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎮', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  'No board cosmetics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: boards.length,
          itemBuilder: (context, index) {
            final board = boards[index];
            return _buildBoardPreviewCard(context, ref, board);
          },
        );
      },
    );
  }

  /// Build cosmetic card for owned items
  Widget _buildCosmeticCard(
    BuildContext context,
    WidgetRef ref,
    CosmeticItem cosmetic,
    OwnedCosmetic owned,
    CosmeticState cosmeticState,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Placeholder for preview image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  cosmetic.type == 'board' ? '🎮' : '⚫',
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cosmetic.name,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildRarityBadge(context, cosmetic.rarity),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'From: ${owned.source}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (owned.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '✓ Active',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.green.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(cosmeticProvider.notifier)
                            .activateCosmetic(cosmetic.id);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),
                      child: const Text('Activate'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build card for purchasable cosmetics
  Widget _buildPurchasableCard(
    BuildContext context,
    CosmeticItem cosmetic,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  cosmetic.type == 'board' ? '🎮' : '⚫',
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cosmetic.name,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildRarityBadge(context, cosmetic.rarity),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (cosmetic.description != null)
                    Text(
                      cosmetic.description!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  if (cosmetic.price != null)
                    Text(
                      '¥${cosmetic.price}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement purchase flow
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Purchase ${cosmetic.name}'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Buy'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build board preview card for grid view
  Widget _buildBoardPreviewCard(
    BuildContext context,
    WidgetRef ref,
    CosmeticItem board,
  ) {
    final cosmeticState = ref.watch(cosmeticProvider);
    final isActive = cosmeticState.isActive(board.id);

    return GestureDetector(
      onTap: () {
        if (!isActive) {
          ref.read(cosmeticProvider.notifier).activateCosmetic(board.id);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(color: Colors.green, width: 3)
              : Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🎮',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              board.name,
              style: Theme.of(context).textTheme.labelLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            _buildRarityBadge(context, board.rarity),
            if (isActive) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Active',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.green.shade900,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build rarity badge
  Widget _buildRarityBadge(BuildContext context, String rarity) {
    Color bgColor;
    Color textColor;

    switch (rarity.toLowerCase()) {
      case 'legendary':
        bgColor = Colors.amber;
        textColor = Colors.white;
      case 'rare':
        bgColor = Colors.purple;
        textColor = Colors.white;
      case 'uncommon':
        bgColor = Colors.blue;
        textColor = Colors.white;
      case 'common':
      default:
        bgColor = Colors.grey;
        textColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        rarity.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
