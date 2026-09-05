import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/index.dart';
import '../../data/models/event_model.dart';

/// Challenge card widget displaying challenge information
class ChallengeCard extends ConsumerWidget {
  final Challenge challenge;

  const ChallengeCard({
    Key? key,
    required this.challenge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = ref.watch(
      challengeProgressProvider('${challenge.eventId}|${challenge.id}'),
    );

    final daysUntilEnd =
        challenge.endDate.difference(DateTime.now()).inDays;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and type
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: challenge.isDaily
                              ? Colors.blue.shade100
                              : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          challenge.isDaily ? 'Daily' : 'Weekly',
                          style: TextStyle(
                            fontSize: 12,
                            color: challenge.isDaily
                                ? Colors.blue.shade700
                                : Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                isCompleted.when(
                  data: (progress) {
                    return Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: progress == 100
                            ? Colors.green.shade100
                            : Colors.grey.shade200,
                      ),
                      child: Center(
                        child: progress == 100
                            ? Icon(
                                Icons.check_circle,
                                color: Colors.green.shade700,
                              )
                            : Text(
                                '$progress%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                      ),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => const SizedBox.shrink(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            if (challenge.description != null)
              Text(
                challenge.description!,
                style: Theme.of(context).textTheme.bodySmall,
              ),

            const SizedBox(height: 12),

            // Target and reward info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${challenge.target}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reward',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${challenge.reward.rankPoints} pts',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expires in',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '$daysUntilEnd days',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Reward preview
            if (challenge.reward.cosmeticId.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.card_giftcard,
                      color: Colors.purple.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Unlock cosmetic on completion',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.purple.shade700,
                          fontWeight: FontWeight.w600,
                        ),
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
}
