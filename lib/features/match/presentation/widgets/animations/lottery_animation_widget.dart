import 'package:flutter/material.dart';
import '../../../../../config/theme.dart';

/// Lottery/Process Order Animation Widget
///
/// Displays animated lottery drawing (くじ引き) for process order randomization.
/// Animation shows:
/// - Lottery drawing animation
/// - Process order reveal (1st, 2nd, 3rd)
/// - Player names and colors
/// - Suspenseful animation sequence
class LotteryAnimationWidget extends StatefulWidget {
  final List<String> playerNames;
  final List<int> playerIndices;
  final List<String> processOrder; // Result of randomization
  final Duration displayDuration;
  final VoidCallback onAnimationComplete;

  const LotteryAnimationWidget({
    required this.playerNames,
    required this.playerIndices,
    required this.processOrder,
    this.displayDuration = const Duration(seconds: 6),
    required this.onAnimationComplete,
    Key? key,
  }) : super(key: key);

  @override
  State<LotteryAnimationWidget> createState() => _LotteryAnimationWidgetState();
}

class _LotteryAnimationWidgetState extends State<LotteryAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _fadeOutController;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _scheduleCompletion();
  }

  void _setupAnimations() {
    // Main animation controller for the lottery sequence
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 4500),
      vsync: this,
    );

    // Fade out controller for final exit
    _fadeOutController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeOut),
    );

    _mainController.forward();
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
    _mainController.dispose();
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
              Colors.amber.shade200.withOpacity(0.1),
              Colors.amber.shade100.withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: Colors.amber.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lottie animation placeholder (lottery drawing)
            SizedBox(
              height: 180,
              child: Center(
                child: _buildLottieAnimation(),
              ),
            ),
            // Process order results
            Container(
              decoration: BoxDecoration(
                color: Colors.amber.shade100.withOpacity(0.1),
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
                    'くじ引き結果',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.amber.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: ToriverseTheme.spacing16),
                  // Process order display
                  ..._buildProcessOrderCards(),
                  const SizedBox(height: ToriverseTheme.spacing8),
                  Text(
                    'この順番で反転します',
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

  List<Widget> _buildProcessOrderCards() {
    final cards = <Widget>[];

    for (int i = 0; i < widget.processOrder.length; i++) {
      final playerId = widget.processOrder[i];
      final playerName = widget.playerNames[i];
      final playerIndexInList = widget.playerIndices[i];
      final stoneColor = ToriverseTheme.getStoneColor(playerIndexInList);

      cards.add(
        AnimatedBuilder(
          animation: _mainController,
          builder: (context, child) {
            // Calculate when this card should appear
            final cardStartTime = (i * 1000.0) / _mainController.duration!.inMilliseconds;
            final cardProgress = (_mainController.value - cardStartTime).clamp(0.0, 1.0);

            return ScaleTransition(
              scale: AlwaysStoppedAnimation(
                Tween<double>(begin: 0.8, end: 1.0).transform(
                  Curves.elasticOut.transform(cardProgress),
                ),
              ),
              child: Opacity(
                opacity: cardProgress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        stoneColor.withOpacity(0.1),
                        stoneColor.withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(
                      color: stoneColor.withOpacity(0.5),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: ToriverseTheme.spacing16,
                    vertical: ToriverseTheme.spacing12,
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 4.0,
                  ),
                  child: Row(
                    children: [
                      // Order badge
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: stoneColor,
                          border: stoneColor == ToriverseTheme.stoneWhite
                              ? Border.all(color: Colors.grey.shade400, width: 1)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: ToriverseTheme.spacing12),
                      // Player info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              playerName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              '${i + 1}番目に反転',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );

      if (i < widget.processOrder.length - 1) {
        cards.add(const SizedBox(height: 8));
      }
    }

    return cards;
  }

  Widget _buildLottieAnimation() {
    // TODO: Replace with actual Lottie animation file
    // Path should be: assets/animations/lottery.json
    // import 'package:lottie/lottie.dart';
    // return Lottie.asset('assets/animations/lottery.json', ...);
    // For now, show a placeholder with rotating icon animation
    return RotationTransition(
      turns: _mainController,
      child: Icon(
        Icons.casino,
        size: 100,
        color: Colors.amber.shade300,
      ),
    );
  }
}
