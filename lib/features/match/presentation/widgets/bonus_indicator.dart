import 'package:flutter/material.dart';
import '../../../../config/theme.dart';

/// Bonus indicator widget - shows when weak bonus or rescue card is triggered
class BonusIndicator extends StatefulWidget {
  final String bonusType; // 'weak_bonus' or 'rescue_card'
  final String playerName;
  final Duration displayDuration;
  final VoidCallback onDismiss;

  const BonusIndicator({
    required this.bonusType,
    required this.playerName,
    this.displayDuration = const Duration(seconds: 3),
    required this.onDismiss,
    Key? key,
  }) : super(key: key);

  @override
  State<BonusIndicator> createState() => _BonusIndicatorState();
}

class _BonusIndicatorState extends State<BonusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAutoClose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  void _startAutoClose() {
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _animationController.reverse().then((_) {
          if (mounted) {
            widget.onDismiss();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildBonusCard(),
      ),
    );
  }

  Widget _buildBonusCard() {
    if (widget.bonusType == 'weak_bonus') {
      return Card(
        color: Colors.yellow.shade700,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ToriverseTheme.spacing24,
            vertical: ToriverseTheme.spacing16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: ToriverseTheme.spacing12),
              const Text(
                '弱者ボーナス発動!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: ToriverseTheme.spacing8),
              Text(
                '${widget.playerName}が逆転を狙える!',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (widget.bonusType == 'rescue_card') {
      return Card(
        color: ToriverseTheme.accentRed,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ToriverseTheme.spacing24,
            vertical: ToriverseTheme.spacing16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.card_giftcard,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: ToriverseTheme.spacing12),
              const Text(
                '救済カード獲得!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: ToriverseTheme.spacing8),
              Text(
                '${widget.playerName}が2手連続実行権を獲得!',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
