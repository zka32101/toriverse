import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/spectating/application/providers/influencer_program_providers.dart';
import 'package:toriverse/features/spectating/domain/models/influencer_program.dart';

/// Referral program manager widget
///
/// Displays referral code, tracks referrals, and shows earnings from referrals.
class ReferralManagerWidget extends ConsumerStatefulWidget {
  final String userId;
  final String displayName;

  const ReferralManagerWidget({
    required this.userId,
    required this.displayName,
  });

  @override
  ConsumerState<ReferralManagerWidget> createState() =>
      _ReferralManagerWidgetState();
}

class _ReferralManagerWidgetState extends ConsumerState<ReferralManagerWidget> {
  late String referralCode;
  bool codeGenerated = false;

  @override
  void initState() {
    super.initState();
    referralCode = '';
  }

  void _generateReferralCode() async {
    final asyncValue = ref.read(createReferralCodeProvider(widget.userId));
    await asyncValue.then((code) {
      setState(() {
        referralCode = code;
        codeGenerated = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final referrals = ref.watch(streamerReferralsProvider(widget.userId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Referral code section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Referral Code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!codeGenerated)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _generateReferralCode,
                        icon: const Icon(Icons.add),
                        label: const Text('Generate Referral Code'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    )
                  else
                    _buildReferralCodeDisplay(context),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Referral stats
          _buildStatsRow(),
          const SizedBox(height: 20),

          // Referrals list
          const Text(
            'Your Referrals',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          referrals.when(
            data: (records) => records.isEmpty
                ? _buildEmptyReferralsState()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      return _buildReferralCard(records[index]);
                    },
                  ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (err, stack) => Center(
              child: Text('Error: $err'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCodeDisplay(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            referralCode,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: referralCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code copied to clipboard')),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy Code'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _shareReferralCode(context);
                },
                icon: const Icon(Icons.share),
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Share your code to earn ¥500 bonus + 5% ongoing commission',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Referrals',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '7',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Commission This Month',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '¥3,500',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferralCard(ReferralRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status indicator
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: record.status == ReferralStatus.active
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Referral Code: ${record.referralCode}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        record.status.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: record.status == ReferralStatus.active
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Referred: ${record.referredAt.toString().split(' ')[0]}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    if (record.activatedAt != null)
                      Text(
                        'Activated: ${record.activatedAt.toString().split(' ')[0]}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
                if (record.status == ReferralStatus.active)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+¥${record.totalCommissionEarned ?? 0}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
              ],
            ),
            if (record.commissionRate > 0) ...[
              const SizedBox(height: 8),
              Text(
                '${(record.commissionRate * 100).toStringAsFixed(1)}% ongoing commission',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyReferralsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No Referrals Yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share your referral code to earn commissions',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareReferralCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Referral Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(referralCode),
            const SizedBox(height: 12),
            const Text(
              'Share this code to earn ¥500 bonus + 5% commission per referral',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: referralCode));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Code copied to clipboard')),
              );
            },
            child: const Text('Copy & Share'),
          ),
        ],
      ),
    );
  }
}
