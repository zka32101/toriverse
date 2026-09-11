import 'package:flutter/material.dart';
import '../../../../../config/theme.dart';

/// Weak Bonus Animation Widget
///
/// Displays animated weak bonus (弱者ボーナス) effect when triggered.
/// Animation shows:
/// - Participant player info
/// - Bonus activation effect
/// - Extra move indicator (+1手)
class WeakBonusAnimationWidget extends StatefulWidget {
  final String playerName;
  final int playerIndex;
  final Duration displayDuration;
  final VoidCallback onAnimationComplete;

  const WeakBonusAnimationWidget({
    required this.playerName,
    required this.playerIndex,
    this.displayDuration = const Duration(seconds: 3),
    required this.onAnimationComplete,
    Key? key,
  }) : super(key: key);

  @override
  State<WeakBonusAnimationWidget> createState() =>
      _WeakBonusAnimationWidgetState();
}

class _WeakBonusAnimationWidgetState extends State<WeakBonusAnimationWidget>
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
    return FadeTransition(
      opacity: _fadeOutAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.yellow.shade400.withOpacity(0.1),
              Colors.yellow.shade200.withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: Colors.yellow.shade300,
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
            // Player info and bonus details
            Container(
              decoration: BoxDecoration(
                color: Colors.yellow.shade700.withOpacity(0.1),
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
                    '弱者ボーナス発動!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.yellow.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: ToriverseTheme.spacing8),
                  Text(
                    widget.playerName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.yellow.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: ToriverseTheme.spacing12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade100.withOpacity(0.5),
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
                          Icons.add_circle,
                          color: Colors.yellow,
                          size: 20,
                        ),
                        const SizedBox(width: ToriverseTheme.spacing8),
                        Text(
                          '追加で1手配置できます',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.yellow.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
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

  Widget _buildLottieAnimation() {
    // TODO: Replace with actual Lottie animation file
    // Path should be: assets/animations/weak_bonus.json
    // import 'package:lottie/lottie.dart';
    // return Lottie.asset('assets/animations/weak_bonus.json', ...);
    // For now, show a placeholder with icon animation
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _fadeOutController, curve: Curves.elasticOut),
      ),
      child: Icon(
        Icons.stars,
        size: 80,
        color: Colors.yellow.shade300,
      ),
    );
  }
}
