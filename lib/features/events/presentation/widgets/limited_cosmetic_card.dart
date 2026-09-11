import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/index.dart';
import '../../data/models/cosmetic_model.dart';

/// Limited cosmetic card widget displaying cosmetic items
class LimitedCosmeticCard extends ConsumerWidget {
  final LimitedCosmetic cosmetic;

  const LimitedCosmeticCard({
    Key? key,
    required this.cosmetic,
  }) : super(key: key);

  Color getRarityColor() {
    switch (cosmetic.rarity.toLowerCase()) {
      case 'legendary':
        return Colors.amber.shade400;
      case 'epic':
        return Colors.purple.shade400;
      case 'rare':
        return Colors.blue.shade400;
      case 'uncommon':
        return Colors.green.shade400;
      case 'common':
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnlockedAsync = ref.watch(
      hasUnlockedCosmeticProvider('${cosmetic.id}|${ref.watch(userIdProvider)}'),
    );

    return Card(
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => _CosmeticDetailsSheet(cosmetic: cosmetic),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image placeholder
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: getRarityColor().withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: cosmetic.imageUrl != null
                    ? Image.network(
                        cosmetic.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Icon(
                          cosmetic.type == 'stone'
                              ? Icons.radio_button_checked
                              : Icons.square,
                          color: getRarityColor(),
                          size: 32,
                        ),
                      ),
              ),
            ),

            // Info section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    cosmetic.name,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Rarity badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: getRarityColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      cosmetic.rarity.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: getRarityColor(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Unlock status
                  isUnlockedAsync.when(
                    data: (isUnlocked) {
                      if (isUnlocked) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 12,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Unlocked',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Locked',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      );
                    },
                    loading: () => const SizedBox(height: 16),
                    error: (error, stack) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CosmeticDetailsSheet extends StatelessWidget {
  final LimitedCosmetic cosmetic;

  const _CosmeticDetailsSheet({required this.cosmetic});

  Color getRarityColor() {
    switch (cosmetic.rarity.toLowerCase()) {
      case 'legendary':
        return Colors.amber.shade400;
      case 'epic':
        return Colors.purple.shade400;
      case 'rare':
        return Colors.blue.shade400;
      case 'uncommon':
        return Colors.green.shade400;
      case 'common':
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Image
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: getRarityColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: cosmetic.imageUrl != null
                      ? Image.network(
                          cosmetic.imageUrl!,
                          fit: BoxFit.contain,
                        )
                      : Center(
                          child: Icon(
                            cosmetic.type == 'stone'
                                ? Icons.radio_button_checked
                                : Icons.square,
                            color: getRarityColor(),
                            size: 64,
                          ),
                        ),
                ),
                const SizedBox(height: 24),

                // Name and rarity
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cosmetic.name,
                      style:
                          Theme.of(context).textTheme.headlineSmall,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: getRarityColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cosmetic.rarity.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: getRarityColor(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Description
                if (cosmetic.description != null)
                  Text(
                    cosmetic.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                const SizedBox(height: 16),

                // Type and event exclusive info
                Wrap(
                  spacing: 12,
                  children: [
                    Chip(
                      label: Text(
                        cosmetic.type.toUpperCase(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    if (cosmetic.eventExclusive)
                      Chip(
                        label: const Text(
                          'EVENT EXCLUSIVE',
                          style: TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.red.shade100,
                        labelStyle: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
