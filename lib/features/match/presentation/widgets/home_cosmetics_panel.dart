import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/cosmetic_state.dart';
import '../../application/providers/streak_state.dart';
import 'streak_display_widget.dart';

/// Home screen panel showing cosmetic collection and streak progress
///
/// Displays:
/// - Current streak with progress to next milestone
/// - Recently acquired cosmetics preview
/// - Quick access to collection browser
/// - Visual indication of cosmetic rarity
class HomeCosmeticsPanel extends ConsumerWidget {
  /// Callback to open full cosmetic collection
  final VoidCallback? onOpenCollection;

  /// Callback to view detailed streak stats
  final VoidCallback? onViewStreak;

  const HomeCosmeticsPanel({
    super.key,
    this.onOpenCollection,
    this.onViewStreak,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cosmeticState = ref.watch(cosmeticProvider);
    final currentStreak = ref.watch(currentStreakProvider);
    final nextMilestone = ref.watch(nextMilestoneProvider);

    // Get recently acquired cosmetics (last 3)
    final recentCosmetics = cosmeticState.ownedCosmetics
        .sorted((a, b) => b.acquiredAt.compareTo(a.acquiredAt))
        .take(3)
        .toList();

    return Column(
      children: [
        // Streak Widget
        GestureDetector(
          onTap: onViewStreak,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: StreakDisplayWidget(
              isCompact: false,
              showBestStreak: true,
              onTapCollection: onOpenCollection,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Cosmetics Preview Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Collection',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  GestureDetector(
                    onTap: onOpenCollection,
                    child: Text(
                      'View All →',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (recentCosmetics.isEmpty)
                _buildEmptyCollectionPrompt(context)
              else
                _buildCosmeticPreview(context, ref, recentCosmetics),
            ],
          ),
        ),
      ],
    );
  }

  /// Build preview of recent cosmetics
  Widget _buildCosmeticPreview(
    BuildContext context,
    WidgetRef ref,
    List<OwnedCosmetic> recentCosmetics,
  ) {
    final cosmeticState = ref.watch(cosmeticProvider);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: List.generate(
          recentCosmetics.length,
          (index) {
            final owned = recentCosmetics[index];
            final cosmetic = cosmeticState.getCosmeticById(owned.itemId);

            if (cosmetic == null) return const SizedBox.shrink();

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < recentCosmetics.length - 1 ? 8 : 0,
              ),
              child: Row(
                children: [
                  // Cosmetic icon placeholder
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        cosmetic.type == 'board' ? '🎮' : '⚫',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Cosmetic name and rarity
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cosmetic.name,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getSourceLabel(owned.source),
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Rarity badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _getRarityColor(cosmetic.rarity),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      cosmetic.rarity.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),

                  // Active indicator
                  if (owned.isActive)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '✓',
                            style: TextStyle(
                              color: Colors.green.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build empty state when no cosmetics owned
  Widget _buildEmptyCollectionPrompt(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.shade50,
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            '✨ Complete your first match to earn cosmetics!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Get human-readable source label
  String _getSourceLabel(String source) {
    switch (source) {
      case 'starter_kit':
        return 'Starter Kit';
      case 'match_reward':
        return 'Match Reward';
      case 'milestone_reward':
        return 'Milestone Reward';
      case 'shop_purchase':
        return 'Shop Purchase';
      case 'seasonal_event':
        return 'Seasonal Event';
      default:
        return 'Acquired';
    }
  }

  /// Get color for rarity badge
  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return Colors.amber;
      case 'rare':
        return Colors.purple;
      case 'uncommon':
        return Colors.blue;
      case 'common':
      default:
        return Colors.grey;
    }
  }
}
