import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/monetization/application/providers/monetization_providers.dart';
import 'package:toriverse/features/monetization/domain/models/monetization.dart';

/// Widget for managing creator payouts
class PayoutManagementWidget extends ConsumerWidget {
  final String creatorId;

  const PayoutManagementWidget({
    Key? key,
    required this.creatorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payoutSchedule = ref.watch(
      payoutScheduleProvider(CreatorIdParam(creatorId)),
    );
    final paymentMethods = ref.watch(
      creatorPaymentMethodsProvider(CreatorIdParam(creatorId)),
    );
    final payouts = ref.watch(
      watchCreatorPayoutsProvider(CreatorIdParam(creatorId)),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payout Management',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          // Payout schedule
          Text(
            'Payout Schedule',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          payoutSchedule.when(
            data: (schedule) {
              if (schedule == null) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Create payout schedule
                    },
                    child: const Text('Set Up Payout Schedule'),
                  ),
                );
              }

              return _PayoutScheduleCard(schedule: schedule);
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Error: $error'),
          ),
          const SizedBox(height: 24),
          // Payment methods
          Text(
            'Payment Methods',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          paymentMethods.when(
            data: (methods) {
              if (methods.isEmpty) {
                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Add payment method
                    },
                    child: const Text('Add Payment Method'),
                  ),
                );
              }

              return Column(
                children: [
                  ...methods.map((method) => _PaymentMethodCard(method: method)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Add another method
                      },
                      child: const Text('Add Another Method'),
                    ),
                  ),
                ],
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Error: $error'),
          ),
          const SizedBox(height: 24),
          // Payout history
          Text(
            'Payout History',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          payouts.when(
            data: (payoutList) {
              if (payoutList.isEmpty) {
                return const Center(
                  child: Text('No payouts yet'),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: payoutList.length,
                itemBuilder: (context, index) {
                  final payout = payoutList[index];
                  return _PayoutCard(payout: payout);
                },
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Error: $error'),
          ),
        ],
      ),
    );
  }
}

class _PayoutScheduleCard extends StatelessWidget {
  final PayoutSchedule schedule;

  const _PayoutScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final frequencyDisplay = {
      'weekly': 'Every week',
      'biweekly': 'Every 2 weeks',
      'monthly': 'Every month',
    }[schedule.frequency] ?? schedule.frequency;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Frequency',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                frequencyDisplay,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minimum Threshold',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '¥${schedule.minimumPayoutThreshold.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Auto-Payout',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Chip(
                label: Text(
                  schedule.autoPayoutEnabled ? 'Enabled' : 'Disabled',
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: schedule.autoPayoutEnabled
                    ? Colors.green.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next Payout',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                schedule.nextPayoutDate.toString().split(' ')[0],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Edit schedule
              },
              child: const Text('Edit Schedule'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;

  const _PaymentMethodCard({required this.method});

  String _getPaymentTypeIcon(String type) {
    switch (type) {
      case 'bank_transfer':
        return '🏦';
      case 'paypal':
        return '📱';
      case 'stripe':
        return '💳';
      default:
        return '💰';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: method.isDefault
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Theme.of(context).primaryColor.withOpacity(0.05),
        border: Border.all(
          color: method.isDefault
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColor.withOpacity(0.2),
          width: method.isDefault ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    _getPaymentTypeIcon(method.type),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.accountHolder,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        method.type.replaceAll('_', ' ').toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (method.isDefault)
                    Chip(
                      label: const Text('Default'),
                      labelStyle: const TextStyle(fontSize: 11),
                    ),
                  if (!method.isVerified)
                    Chip(
                      label: const Text('Unverified'),
                      labelStyle: const TextStyle(fontSize: 11),
                      backgroundColor: Colors.orange.withOpacity(0.2),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  // Edit
                },
                child: const Text('Edit'),
              ),
              TextButton(
                onPressed: () {
                  // Delete
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayoutCard extends StatelessWidget {
  final CreatorPayout payout;

  const _PayoutCard({required this.payout});

  Color _getStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¥${payout.amountJpy.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                payout.requestedAt.toString().split(' ')[0],
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
              color: _getStatusColor(context, payout.status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              payout.status.toUpperCase(),
              style: TextStyle(
                color: _getStatusColor(context, payout.status),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
