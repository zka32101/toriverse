import 'package:flutter/material.dart';
import '../../../../../config/theme.dart';

/// Collision Resolution Animation Widget
///
/// Displays animated collision resolution (同マス被り) when multiple players
/// attempt to place stones on the same square.
/// Animation shows:
/// - Conflicting players
/// - Random selection result
/// - Winner gets the square
/// - Losers receive rescue cards
class CollisionResolutionAnimationWidget extends StatefulWidget {
  final List<String> conflictingPlayerNames;
  final List<int> playerIndices;
  final String winnerName;
  final int winnerIndex;
  final int boardRow;
  final int boardCol;
  final Duration displayDuration;
  final VoidCallback onAnimationComplete;

  const CollisionResolutionAnimationWidget({
    required this.conflictingPlayerNames,
    required this.playerIndices,
    required this.winnerName,
    required this.winnerIndex,
    required this.boardRow,
    required this.boardCol,
    this.displayDuration = const Duration(seconds: 4),
    required this.onAnimationComplete,
    Key? key,
  }) : super(key: key);

  @override
  State<CollisionResolutionAnimationWidget> createState() =>
      _CollisionResolutionAnimationWidgetState();
}

class _CollisionResolutionAnimationWidgetState
    extends State<CollisionResolutionAnimationWidget>
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
    final loserNames = widget.conflictingPlayerNames
        .where((name) => name != widget.winnerName)
        .toList();

    return FadeTransition(
      opacity: _fadeOutAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade200.withOpacity(0.1),
              Colors.purple.shade100.withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: Colors.purple.shade300,
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
            // Collision details
            Container(
              decoration: BoxDecoration(
                color: Colors.purple.shade100.withOpacity(0.1),
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
                    '同マス被り!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.purple.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: ToriverseTheme.spacing12),
                  // Winner section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade100.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green.shade300,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(ToriverseTheme.spacing12),
                    child: Column(
                      children: [
                        Text(
                          '当選者',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: ToriverseTheme.spacing8),
                        _buildPlayerChip(
                          widget.winnerName,
                          widget.winnerIndex,
                          isWinner: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: ToriverseTheme.spacing12),
                  // Losers section
                  if (loserNames.isNotEmpty) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: ToriverseTheme.accentRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: ToriverseTheme.accentRed.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(ToriverseTheme.spacing12),
                      child: Column(
                        children: [
                          Text(
                            '救済カード獲得',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: ToriverseTheme.accentRed,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: ToriverseTheme.spacing8),
                          ...loserNames.map((name) {
                            final index = widget.conflictingPlayerNames.indexOf(name);
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: _buildPlayerChip(
                                name,
                                widget.playerIndices[index],
                                isWinner: false,
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: ToriverseTheme.spacing12),
                  Text(
                    '座標 (${widget.boardRow}, ${widget.boardCol})',
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

  Widget _buildPlayerChip(String playerName, int playerIndex,
      {required bool isWinner}) {
    final stoneColor = ToriverseTheme.getStoneColor(playerIndex);

    return Container(
      decoration: BoxDecoration(
        color: isWinner
            ? Colors.green.shade100.withOpacity(0.3)
            : ToriverseTheme.accentRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner ? Colors.green.shade300 : ToriverseTheme.accentRed,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: ToriverseTheme.spacing12,
        vertical: ToriverseTheme.spacing8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
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
            playerName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (isWinner) ...[
            const SizedBox(width: ToriverseTheme.spacing8),
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 16,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLottieAnimation() {
    // TODO: Replace with actual Lottie animation file
    // Path should be: assets/animations/collision_resolution.json
    // import 'package:lottie/lottie.dart';
    // return Lottie.asset('assets/animations/collision_resolution.json', ...);
    // For now, show a placeholder with icon animation
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _fadeOutController, curve: Curves.elasticOut),
      ),
      child: Icon(
        Icons.blur_on,
        size: 80,
        color: Colors.purple.shade300,
      ),
    );
  }
}
