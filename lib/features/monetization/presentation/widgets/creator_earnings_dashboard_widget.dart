import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/monetization/application/providers/monetization_providers.dart';

/// Widget for displaying creator earnings dashboard
class CreatorEarningsDashboardWidget extends ConsumerWidget {
  final String creatorId;

  const CreatorEarningsDashboardWidget({
    Key? key,
    required this.creatorId,
  }) : super(key: key);

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '¥${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '¥${(value / 1000).toStringAsFixed(1)}K';
    }
    return '¥${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earningsHistory = ref.watch(
      creatorEarningsHistoryProvider(CreatorIdParam(creatorId)),
    );

    return earningsHistory.when(
      data: (earnings) {
        if (earnings.isEmpty) {
          return const Center(
            child: Text('No earnings data available yet'),
          );
        }

        final latestEarnings = earnings.first;
        final trend = earnings.length > 1
            ? ((earnings[0].totalEarnings - earnings[1].totalEarnings) /
                    earnings[1].totalEarnings *
                    100)
            : 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Creator Dashboard',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              // Total earnings card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Earnings',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatCurrency(latestEarnings.totalEarnings),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Net: ${_formatCurrency(latestEarnings.netEarnings)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: trend >= 0 ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${trend >= 0 ? '+' : ''}${trend.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Revenue breakdown
              Text(
                'Revenue Breakdown',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _buildRevenueBreakdownCard(
                context,
                'Subscriptions',
                latestEarnings.subscriptionRevenue,
                latestEarnings.totalEarnings,
                Icons.people,
              ),
              const SizedBox(height: 8),
              _buildRevenueBreakdownCard(
                context,
                'Gifts',
                latestEarnings.giftRevenue,
                latestEarnings.totalEarnings,
                Icons.card_giftcard,
              ),
              const SizedBox(height: 8),
              _buildRevenueBreakdownCard(
                context,
                'Clips',
                latestEarnings.clipRevenue,
                latestEarnings.totalEarnings,
                Icons.video_library,
              ),
              const SizedBox(height: 24),
              // Deductions
              Text(
                'Deductions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDeductionCard(
                      context,
                      'Platform Fee',
                      latestEarnings.platformFeeDeducted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDeductionCard(
                      context,
                      'Tax',
                      latestEarnings.taxDeducted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Metrics
              Text(
                'Metrics',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildMetricCard(
                    context,
                    'Active Subscribers',
                    latestEarnings.activeSubscribers.toString(),
                  ),
                  _buildMetricCard(
                    context,
                    'Gifts Purchased',
                    latestEarnings.totalGiftsPurchased.toString(),
                  ),
                  _buildMetricCard(
                    context,
                    'Monetized Clips',
                    latestEarnings.totalClipsMonetized.toString(),
                  ),
                  _buildMetricCard(
                    context,
                    'Revenue/Sub',
                    latestEarnings.activeSubscribers > 0
                        ? _formatCurrency(
                            latestEarnings.subscriptionRevenue /
                                latestEarnings.activeSubscribers,
                          )
                        : '¥0',
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading earnings: $error'),
      ),
    );
  }

  Widget _buildRevenueBreakdownCard(
    BuildContext context,
    String label,
    double amount,
    double total,
    IconData icon,
  ) {
    final percentage = total > 0 ? (amount / total * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeductionCard(
    BuildContext context,
    String label,
    double amount,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(amount),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
