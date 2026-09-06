import 'package:flutter/material.dart';

/// Premium pass upsell card
class PremiumPassUpsell extends StatelessWidget {
  final VoidCallback onPurchase;

  const PremiumPassUpsell({
    required this.onPurchase,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.shade600,
            Colors.orange.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 32,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'プレミアムパスで加速',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '¥300 / 月',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Benefits
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BenefitRow(
                  icon: Icons.lightning_bolt,
                  text: 'XP獲得量が 1.5 倍に',
                ),
                const SizedBox(height: 8),
                _BenefitRow(
                  icon: Icons.card_giftcard,
                  text: '全ティアで限定報酬を獲得',
                ),
                const SizedBox(height: 8),
                _BenefitRow(
                  icon: Icons.check_circle,
                  text: 'ティア 50 で限定ボード獲得',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Purchase button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  'プレミアムパスを購入',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.amber.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Terms
            Text(
              'キャンセルはいつでも可能です。日割り返金対応。',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.white,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      ],
    );
  }
}
