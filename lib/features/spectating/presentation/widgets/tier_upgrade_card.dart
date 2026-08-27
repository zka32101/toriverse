import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/spectating/application/providers/influencer_program_providers.dart';
import 'package:toriverse/features/spectating/domain/models/influencer_program.dart';

/// Tier upgrade eligibility card with progress tracking
///
/// Displays current tier, next tier requirements, and eligibility status.
/// Shows progress toward next tier upgrade with visual indicators.
class TierUpgradeCard extends ConsumerWidget {
  final String userId;
  final StreamerTier currentTier;
  final VoidCallback? onUpgradePressed;

  const TierUpgradeCard({
    required this.userId,
    required this.currentTier,
    this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine next tier
    final nextTier = _getNextTier(currentTier);
    if (nextTier == null) {
      return _buildMaxTierCard();
    }

    final eligibility = ref.watch(tierUpgradeEligibilityProvider(
      _CheckTierEligibilityParams(
        userId: userId,
        nextTier: nextTier,
      ),
    ));

    return eligibility.when(
      data: (data) => _buildUpgradeCard(context, data, nextTier),
      loading: () => _buildLoadingState(),
      error: (err, stack) => _buildErrorState(err),
    );
  }

  Widget _buildMaxTierCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  currentTier.icon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Maximum Tier Reached',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'You are at the highest tier: ${currentTier.label}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Revenue Share: ${(currentTier.revenueShare * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[900],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeCard(
    BuildContext context,
    TierUpgradeEligibility eligibility,
    StreamerTier nextTier,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with current and next tier
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Tier',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          currentTier.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          currentTier.label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Next Tier',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          nextTier.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          nextTier.label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Requirements list
            const Text(
              'Requirements',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...eligibility.missingRequirements.asMap().entries.map((e) {
              final check = e.value;
              return _buildRequirementItem(check);
            }),

            // Status badge
            const SizedBox(height: 16),
            if (eligibility.isEligible)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '✓ You are eligible for ${nextTier.label} tier!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[900],
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${eligibility.daysUntilEligible} days until eligible',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[900],
                  ),
                ),
              ),

            // Revenue share info
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${nextTier.label}: ${(nextTier.revenueShare * 100).toStringAsFixed(0)}% revenue share',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Action button
            if (eligibility.isEligible) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onUpgradePressed,
                  icon: const Icon(Icons.upgrade),
                  label: Text('Upgrade to ${nextTier.label}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(TierRequirementCheck check) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: check.isMet ? Colors.green[100] : Colors.orange[100],
              border: Border.all(
                color: check.isMet ? Colors.green : Colors.orange,
              ),
            ),
            child: Center(
              child: Icon(
                check.isMet ? Icons.check : Icons.close,
                size: 12,
                color: check.isMet ? Colors.green : Colors.orange,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  check.requirement,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${check.current} / ${check.required}${check.remaining > 0 ? ' (${check.remaining} more needed)' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (!check.isMet)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: check.current / check.required,
                minHeight: 4,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[400]!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            const Text('Checking eligibility...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Error',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Error: $error',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  StreamerTier? _getNextTier(StreamerTier current) {
    switch (current) {
      case StreamerTier.unverified:
        return StreamerTier.affiliate;
      case StreamerTier.affiliate:
        return StreamerTier.partner;
      case StreamerTier.partner:
        return StreamerTier.premium;
      case StreamerTier.premium:
        return null;
    }
  }
}
