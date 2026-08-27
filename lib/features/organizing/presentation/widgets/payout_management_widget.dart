import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/organizing/application/providers/organizer_providers.dart';
import 'package:toriverse/features/organizing/domain/models/organizer.dart';

/// Payout management interface for tournament organizers
///
/// Displays prize payout requests, payment status, and processing options.
class PayoutManagementWidget extends ConsumerWidget {
  final String organizerId;

  const PayoutManagementWidget({
    required this.organizerId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payoutsAsync = ref.watch(
      payoutRequestsProvider(_GetPayoutsParams(organizerId)),
    );

    return payoutsAsync.when(
      data: (payouts) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPayoutSummary(payouts),
            const SizedBox(height: 24),
            _buildPayoutsList(context, ref, payouts),
          ],
        ),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, stack) => Center(
        child: Text('Error loading payouts: $err'),
      ),
    );
  }

  Widget _buildPayoutSummary(List<PayoutRequest> payouts) {
    final totalAmount = payouts
        .where((p) => p.status != 'failed')
        .fold<int>(0, (sum, p) => sum + p.totalAmount);

    final pending = payouts.where((p) => p.status == 'pending').length;
    final processing = payouts.where((p) => p.status == 'processing').length;
    final completed = payouts.where((p) => p.status == 'completed').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payout Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total to Payout',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¥${_formatCurrency(totalAmount)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.trending_up,
                size: 32,
                color: Colors.blue[600],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatusCard(
                label: 'Pending',
                count: pending,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatusCard(
                label: 'Processing',
                count: processing,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatusCard(
                label: 'Completed',
                count: completed,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPayoutsList(
    BuildContext context,
    WidgetRef ref,
    List<PayoutRequest> payouts,
  ) {
    if (payouts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long,
                size: 48,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 12),
              Text(
                'No payout requests yet',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payout Requests',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: payouts.length,
          itemBuilder: (context, index) {
            final payout = payouts[index];
            return _PayoutCard(
              payout: payout,
              organizerId: organizerId,
              onStatusChange: (status) =>
                  _updatePayoutStatus(context, ref, payout, status),
            );
          },
        ),
      ],
    );
  }

  void _updatePayoutStatus(
    BuildContext context,
    WidgetRef ref,
    PayoutRequest payout,
    String status,
  ) async {
    try {
      await ref.read(updatePayoutStatusProvider((
        payout.id,
        status,
        null,
      )).future);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payout status updated to $status'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating payout: $e')),
        );
      }
    }
  }

  String _formatCurrency(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return amount.toString();
  }
}

/// Status card showing payout request counts
class _StatusCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusCard({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual payout request card
class _PayoutCard extends StatelessWidget {
  final PayoutRequest payout;
  final String organizerId;
  final Function(String) onStatusChange;

  const _PayoutCard({
    required this.payout,
    required this.organizerId,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(payout.status);
    final statusLabel = _getStatusLabel(payout.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      'Tournament ${payout.tournamentId.substring(0, 8)}...',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Requested: ${_formatDate(payout.requestedAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Payout',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '¥${_formatCurrency(payout.totalAmount)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Recipients',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${payout.payouts.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildPayoutTable(),
            const SizedBox(height: 12),
            if (payout.status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showCancelDialog(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onStatusChange('processing'),
                      child: const Text('Process Payment'),
                    ),
                  ),
                ],
              )
            else if (payout.status == 'processing')
              ElevatedButton(
                onPressed: () => onStatusChange('completed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                ),
                child: const Text('Mark Complete'),
              )
            else if (payout.status == 'completed')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[300]!),
                ),
                child: Center(
                  child: Text(
                    'Paid out on ${_formatDate(payout.processedAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayoutTable() {
    final topPayouts = payout.payouts.entries
        .toList()
        .sublist(0, (payout.payouts.length < 3 ? payout.payouts.length : 3));

    return Column(
      children: topPayouts
          .asMap()
          .entries
          .map((entry) {
            final rank = entry.key + 1;
            final userId = entry.value.key;
            final amount = entry.value.value;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _getRankBadge(rank),
                      const SizedBox(width: 8),
                      Text(
                        userId.substring(0, 8),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Text(
                    '¥${_formatCurrency(amount)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          })
          .toList(),
    );
  }

  Widget _getRankBadge(int rank) {
    final badges = ['🥇', '🥈', '🥉'];
    if (rank <= 3) {
      return Text(badges[rank - 1], style: const TextStyle(fontSize: 14));
    }
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Payout'),
        content: const Text('Are you sure you want to cancel this payout request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              onStatusChange('cancelled');
              Navigator.pop(context);
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      default:
        return status;
    }
  }

  String _formatCurrency(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return amount.toString();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.month}/${date.day}/${date.year}';
  }
}
