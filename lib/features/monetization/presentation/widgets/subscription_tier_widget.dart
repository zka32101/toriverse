import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/monetization/application/providers/monetization_providers.dart';
import 'package:toriverse/features/monetization/domain/models/monetization.dart';

/// Widget for displaying and managing subscription tiers
class SubscriptionTierWidget extends ConsumerWidget {
  final String creatorId;

  const SubscriptionTierWidget({
    Key? key,
    required this.creatorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiers = ref.watch(
      watchCreatorSubscriptionTiersProvider(CreatorIdParam(creatorId)),
    );

    return tiers.when(
      data: (tierList) {
        if (tierList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No subscription tiers yet'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Show create tier dialog
                  },
                  child: const Text('Create First Tier'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tierList.length,
          itemBuilder: (context, index) {
            final tier = tierList[index];
            return _SubscriptionTierCard(
              tier: tier,
              creatorId: creatorId,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading tiers: $error'),
      ),
    );
  }
}

class _SubscriptionTierCard extends ConsumerWidget {
  final SubscriptionTier tier;
  final String creatorId;

  const _SubscriptionTierCard({
    required this.tier,
    required this.creatorId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tier.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    tier.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '¥${tier.monthlyPriceJpy}/month',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  label: 'Subscribers',
                  value: tier.currentSubscribers.toString(),
                ),
                _StatItem(
                  label: 'Limit',
                  value: tier.maxSubscriberLimit > 0
                      ? tier.maxSubscriberLimit.toString()
                      : '∞',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Benefits',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _BenefitsList(tier: tier),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Edit tier
              },
              child: const Text('Edit Tier'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _BenefitsList extends StatelessWidget {
  final SubscriptionTier tier;

  const _BenefitsList({required this.tier});

  @override
  Widget build(BuildContext context) {
    final benefits = <String>[];

    if (tier.includeExclusiveClips) benefits.add('Exclusive Clips');
    if (tier.includePriorityChat) benefits.add('Priority Chat');
    if (tier.includeCustomEmoji) benefits.add('Custom Emoji');
    if (tier.includeCreatorBadge) benefits.add('Creator Badge');
    if (tier.includeEarlyAccess) benefits.add('Early Access');

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: benefits
          .map((benefit) => Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 16),
                const SizedBox(width: 4),
                Text(
                  benefit,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ))
          .toList(),
    );
  }
}
