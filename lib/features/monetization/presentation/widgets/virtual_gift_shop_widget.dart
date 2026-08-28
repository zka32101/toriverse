import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/monetization/application/providers/monetization_providers.dart';
import 'package:toriverse/features/monetization/domain/models/monetization.dart';

/// Widget for displaying virtual gifts shop
class VirtualGiftShopWidget extends ConsumerWidget {
  final String creatorId;

  const VirtualGiftShopWidget({
    Key? key,
    required this.creatorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gifts = ref.watch(watchAvailableVirtualGiftsProvider);

    return gifts.when(
      data: (giftList) {
        if (giftList.isEmpty) {
          return const Center(
            child: Text('No gifts available'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: giftList.length,
          itemBuilder: (context, index) {
            final gift = giftList[index];
            return _GiftCard(gift: gift, creatorId: creatorId);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading gifts: $error'),
      ),
    );
  }
}

class _GiftCard extends StatelessWidget {
  final VirtualGift gift;
  final String creatorId;

  const _GiftCard({
    required this.gift,
    required this.creatorId,
  });

  String _getRarityColor(String rarity) {
    switch (rarity) {
      case 'legendary':
        return '#FFD700'; // Gold
      case 'rare':
        return '#C0C0C0'; // Silver
      case 'common':
      default:
        return '#CD7F32'; // Bronze
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gift image
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.card_giftcard,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gift name and rarity
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        gift.name,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        gift.rarity[0].toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Price
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '¥${gift.priceJpy}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Sent count
                Text(
                  '${gift.totalGiftsSent} sent',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for displaying received gifts for a creator
class CreatorReceivedGiftsWidget extends ConsumerWidget {
  final String creatorId;

  const CreatorReceivedGiftsWidget({
    Key? key,
    required this.creatorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gifts = ref.watch(
      watchCreatorReceivedGiftsProvider(CreatorIdParam(creatorId)),
    );

    return gifts.when(
      data: (giftList) {
        if (giftList.isEmpty) {
          return const Center(
            child: Text('No gifts received yet'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: giftList.length,
          itemBuilder: (context, index) {
            final gift = giftList[index];
            return _ReceivedGiftTile(gift: gift);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading gifts: $error'),
      ),
    );
  }
}

class _ReceivedGiftTile extends StatelessWidget {
  final GiftTransaction gift;

  const _ReceivedGiftTile({required this.gift});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.card_giftcard,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gift received',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'from ${gift.senderId}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                if (gift.personalMessage != null && gift.personalMessage!.isNotEmpty)
                  Text(
                    '"${gift.personalMessage}"',
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '¥${gift.creatorRevenueJpy}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                'x${gift.quantity}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
