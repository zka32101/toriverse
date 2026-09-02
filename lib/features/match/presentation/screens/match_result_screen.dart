import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/streak_state.dart';
import '../../application/providers/cosmetic_state.dart';
import '../../domain/services/streak_calculator.dart';
import '../../domain/services/streak_calculator.dart' as calculator_module;
import '../widgets/streak_display_widget.dart';
import '../widgets/milestone_reached_dialog.dart';
import '../screens/cosmetic_collection_screen.dart';
import '../../../shared/services/analytics_service.dart';

/// Match result screen showing game outcome, streak progress, and cosmetic rewards
///
/// Integrates:
/// - Match result display (winner, scores)
/// - Streak tracking and milestone celebration
/// - Cosmetic reward preview
/// - Navigation to cosmetic collection
class MatchResultScreen extends ConsumerStatefulWidget {
  /// Match ID for data lookup
  final String matchId;

  /// Game results (winner, final stone counts, etc.)
  final Map<String, dynamic> matchResult;

  /// Callback to play again or return to home
  final VoidCallback? onPlayAgain;
  final VoidCallback? onReturnHome;

  const MatchResultScreen({
    super.key,
    required this.matchId,
    required this.matchResult,
    this.onPlayAgain,
    this.onReturnHome,
  });

  @override
  ConsumerState<MatchResultScreen> createState() => _MatchResultScreenState();
}

class _MatchResultScreenState extends ConsumerState<MatchResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _celebrationController;
  bool _milestoneShown = false;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Check for milestone achievement after animation delay
    Future.delayed(const Duration(milliseconds: 800), _checkMilestoneReached);
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  /// Check if player reached a milestone and show celebration
  Future<void> _checkMilestoneReached() async {
    if (!mounted || _milestoneShown) return;

    final streak = ref.read(currentStreakProvider);
    final isAtMilestone = ref.read(isAtMilestoneProvider);

    if (isAtMilestone && StreakCalculator.isMilestone(streak)) {
      _milestoneShown = true;

      // Get cosmetic reward if applicable
      CosmeticItem? reward;
      if (calculator_module.CosmeticRewardCalculator
          .shouldGrantMilestoneReward(streak)) {
        // In production, this would fetch from a reward table
        // For now, we show a placeholder
        reward = const CosmeticItem(
          id: 'milestone_reward_$streak',
          type: 'board',
          name: 'Milestone $streak Board',
          rarity: 'rare',
        );
      }

      // Fire analytics event for milestone achievement
      final analytics = AnalyticsService();
      await analytics.logMilestoneReached(
        milestone: streak,
        cosmeticRewardId: reward?.id,
        cosmeticRarity: reward?.rarity ?? 'none',
      );

      if (mounted) {
        await showMilestoneReachedDialog(
          context,
          milestone: streak,
          cosmeticReward: reward,
          onViewCollection: _openCosmeticCollection,
        );
      }
    }
  }

  /// Navigate to cosmetic collection screen
  void _openCosmeticCollection() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CosmeticCollectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final streak = ref.watch(currentStreakProvider);
    final bestStreak = ref.watch(bestStreakProvider);
    final nextMilestone = ref.watch(nextMilestoneProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Result'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Streak Display at Top
            Padding(
              padding: const EdgeInsets.all(16),
              child: StreakDisplayWidget(
                isCompact: false,
                showBestStreak: true,
                onTapCollection: _openCosmeticCollection,
              ),
            ),

            const Divider(height: 24),

            // Match Result Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Match Result',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Result Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Winner Display
                          if (widget.matchResult['winner'] != null) ...[
                            Text(
                              '🏆 Winner',
                              style:
                                  Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.matchResult['winner'] ?? 'Unknown',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                          ],

                          // Final Scores
                          Text(
                            'Final Stones',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(height: 12),
                          _buildStoneCountRow(
                            context,
                            'Black',
                            widget.matchResult['blackStones'] ?? 0,
                          ),
                          const SizedBox(height: 8),
                          _buildStoneCountRow(
                            context,
                            'White',
                            widget.matchResult['whiteStones'] ?? 0,
                          ),
                          const SizedBox(height: 8),
                          _buildStoneCountRow(
                            context,
                            'Red',
                            widget.matchResult['redStones'] ?? 0,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Streak Stats
                  Card(
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Current Streak',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium,
                              ),
                              Text(
                                '🔥 $streak',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Best Streak',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium,
                              ),
                              Text(
                                '⭐ $bestStreak',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          if (nextMilestone != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Next Milestone',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium,
                                ),
                                Text(
                                  '$nextMilestone',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: widget.onPlayAgain ?? _playAgain,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Play Again'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: widget.onReturnHome ?? _returnHome,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Return Home'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Build a row displaying stone count for a color
  Widget _buildStoneCountRow(
    BuildContext context,
    String color,
    int count,
  ) {
    final emoji = color.toLowerCase() == 'black'
        ? '⚫'
        : color.toLowerCase() == 'white'
            ? '⚪'
            : '🔴';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$emoji $color',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          '$count',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  /// Default play again action
  void _playAgain() {
    Navigator.of(context).pop();
  }

  /// Default return home action
  void _returnHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
