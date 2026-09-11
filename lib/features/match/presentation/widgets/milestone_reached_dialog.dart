import 'package:flutter/material.dart';
import '../../application/providers/cosmetic_state.dart';

/// Celebration dialog shown when player reaches a milestone streak
///
/// Features:
/// - Animated confetti effect
/// - Milestone count display with trophy emoji
/// - Preview of granted cosmetic reward
/// - CTA to view full collection
class MilestoneReachedDialog extends StatefulWidget {
  /// Milestone number (3, 5, 10, 25, 50, 100)
  final int milestone;

  /// Cosmetic reward being granted
  final CosmeticItem? cosmeticReward;

  /// Callback when user dismisses dialog
  final VoidCallback? onDismiss;

  /// Callback to open cosmetic collection
  final VoidCallback? onViewCollection;

  const MilestoneReachedDialog({
    super.key,
    required this.milestone,
    this.cosmeticReward,
    this.onDismiss,
    this.onViewCollection,
  });

  @override
  State<MilestoneReachedDialog> createState() => _MilestoneReachedDialogState();
}

class _MilestoneReachedDialogState extends State<MilestoneReachedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
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
        opacity: _opacityAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.shade900,
                  Colors.amber.shade700,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.shade300, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.5),
                  blurRadius: 16,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Confetti emoji celebration
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      7,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildConfettiEmoji(i),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Trophy and milestone text
                Text(
                  '🏆',
                  style: const TextStyle(fontSize: 48),
                ),

                const SizedBox(height: 8),

                Text(
                  'Milestone Reached!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 4),

                Text(
                  '${widget.milestone} Matches',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 16),

                // Cosmetic reward preview
                if (widget.cosmeticReward != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Reward Unlocked',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.cosmeticReward!.name,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getRarityColor(
                              widget.cosmeticReward!.rarity,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.cosmeticReward!.rarity.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onDismiss?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Continue'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onViewCollection?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.amber.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('View Collection'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get color based on cosmetic rarity
  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return Colors.amber;
      case 'rare':
        return Colors.purple;
      case 'uncommon':
        return Colors.blue;
      case 'common':
      default:
        return Colors.grey;
    }
  }

  /// Build animated confetti emoji
  Widget _buildConfettiEmoji(int index) {
    final emojis = ['🎉', '✨', '🌟', '💫', '🎊', '🏆', '👑'];
    return Text(
      emojis[index % emojis.length],
      style: const TextStyle(fontSize: 24),
    );
  }
}

/// Show milestone reached celebration
Future<void> showMilestoneReachedDialog(
  BuildContext context, {
  required int milestone,
  CosmeticItem? cosmeticReward,
  VoidCallback? onDismiss,
  VoidCallback? onViewCollection,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => MilestoneReachedDialog(
      milestone: milestone,
      cosmeticReward: cosmeticReward,
      onDismiss: onDismiss,
      onViewCollection: onViewCollection,
    ),
  );
}
