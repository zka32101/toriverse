import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../../config/theme.dart';

/// Rescue Card Animation Widget
///
/// Displays animated rescue card (救済カード) effect when triggered.
/// Animation shows:
/// - Card reveal effect
/// - Player who receives the card
/// - Bonus ability indicator (2手連続実行権)
class RescueCardAnimationWidget extends StatefulWidget {
  final String playerName;
  final int playerIndex;
  final String reason; // 'consecutive_attacks', 'collision', etc.
  final Duration displayDuration;
  final VoidCallback onAnimationComplete;

  const RescueCardAnimationWidget({
    required this.playerName,
    required this.playerIndex,
    this.reason = 'consecutive_attacks',
    this.displayDuration = const Duration(seconds: 4),
    required this.onAnimationComplete,
    Key? key,
  }) : super(key: key);

  @override
  State<RescueCardAnimationWidget> createState() =>
      _RescueCardAnimationWidgetState();
}

class _RescueCardAnimationWidgetState extends State<RescueCardAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeOutController;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _scheduleCompletion();
  }

  void _setupAnimations() {
    _fadeOutController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeOut),
    );
  }

  void _scheduleCompletion() {
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _fadeOutController.forward().then((_) {
          if (mounted) {
            widget.onAnimationComplete();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stoneColor = ToriverseTheme.getStoneColor(widget.playerIndex);

    return FadeTransition(
      opacity: _fadeOutAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ToriverseTheme.accentRed.withOpacity(0.1),
              ToriverseTheme.accentRed.withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: ToriverseTheme.accentRed,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lottie animation placeholder
            SizedBox(
              height: 160,
              child: Center(
                child: _buildLottieAnimation(),
              ),
            ),
            // Rescue card details
            Container(
              decoration: BoxDecoration(
                color: ToriverseTheme.accentRed.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: ToriverseTheme.spacing16,
                vertical: ToriverseTheme.spacing12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '救済カード獲得!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: ToriverseTheme.accentRed,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: ToriverseTheme.spacing8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: stoneColor,
                          border: stoneColor == ToriverseTheme.stoneWhite
                              ? Border.all(color: Colors.grey.shade400, width: 1)
                              : null,
                        ),
                      ),
                      const SizedBox(width: ToriverseTheme.spacing8),
                      Text(
                        widget.playerName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: ToriverseTheme.accentRed,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ToriverseTheme.spacing12),
                  Container(
                    decoration: BoxDecoration(
                      color: ToriverseTheme.accentRed.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: ToriverseTheme.spacing12,
                      vertical: ToriverseTheme.spacing8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.double_arrow,
                          color: ToriverseTheme.accentRed,
                          size: 20,
                        ),
                        const SizedBox(width: ToriverseTheme.spacing8),
                        Text(
                          '次のラウンドで2手配置できます',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: ToriverseTheme.accentRed,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: ToriverseTheme.spacing8),
                  Text(
                    _getReasonText(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
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

  String _getReasonText() {
    switch (widget.reason) {
      case 'consecutive_attacks':
        return '同一相手から連続攻撃を受けました';
      case 'collision':
        return '同マス被りで外れました';
      default:
        return '救済カードが付与されました';
    }
  }

  Widget _buildLottieAnimation() {
    // TODO: Replace with actual Lottie animation file
    // Path should be: assets/animations/rescue_card.json
    // For now, show a placeholder with icon animation
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _fadeOutController, curve: Curves.elasticOut),
      ),
      child: const Icon(
        Icons.card_giftcard,
        size: 80,
        color: ToriverseTheme.accentRed,
      ),
    );
  }
}
