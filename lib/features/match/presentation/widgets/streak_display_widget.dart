import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/streak_state.dart';

/// Compact widget displaying current match completion streak
///
/// Shows:
/// - Current streak count with fire emoji
/// - Best streak record
/// - Progress bar to next milestone
/// - Milestone celebration indicator
///
/// Designed for in-game display (top corner) and home screen (dashboard)
class StreakDisplayWidget extends ConsumerWidget {
  /// Compact vs expanded layout mode
  final bool isCompact;

  /// Show best streak or just current
  final bool showBestStreak;

  /// Callback when user taps to view collection
  final VoidCallback? onTapCollection;

  const StreakDisplayWidget({
    super.key,
    this.isCompact = false,
    this.showBestStreak = true,
    this.onTapCollection,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStreak = ref.watch(currentStreakProvider);
    final bestStreak = ref.watch(bestStreakProvider);
    final nextMilestone = ref.watch(nextMilestoneProvider);
    final isAtMilestone = ref.watch(isAtMilestoneProvider);

    if (isCompact) {
      return _buildCompactLayout(
        context,
        currentStreak: currentStreak,
        bestStreak: bestStreak,
        isAtMilestone: isAtMilestone,
      );
    }

    return _buildExpandedLayout(
      context,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      nextMilestone: nextMilestone,
      isAtMilestone: isAtMilestone,
    );
  }

  /// Compact layout: Single-line display for in-game UI
  Widget _buildCompactLayout(
    BuildContext context, {
    required int currentStreak,
    required int bestStreak,
    required bool isAtMilestone,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
        border: isAtMilestone
            ? Border.all(color: Colors.amber, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🔥',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 4),
          Text(
            '$currentStreak',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showBestStreak) ...[
            const SizedBox(width: 8),
            Text(
              '/ Max: $bestStreak',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Expanded layout: Dashboard display with milestone progress
  Widget _buildExpandedLayout(
    BuildContext context, {
    required int currentStreak,
    required int bestStreak,
    required int? nextMilestone,
    required bool isAtMilestone,
  }) {
    final progress = nextMilestone != null
        ? (currentStreak / nextMilestone).clamp(0.0, 1.0)
        : 1.0;

    return GestureDetector(
      onTap: onTapCollection,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade900,
              Colors.grey.shade800,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: isAtMilestone
              ? Border.all(color: Colors.amber, width: 2)
              : Border.all(color: Colors.grey.shade700, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with current streak
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '🔥',
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Streak',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          '$currentStreak',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isAtMilestone)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Milestone!',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Best streak
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Best Streak',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  '$bestStreak',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Milestone progress
            if (nextMilestone != null) ...[
              Text(
                'Next Milestone: $nextMilestone',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade700,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isAtMilestone ? Colors.amber : Colors.green.shade400,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Tap hint
            Center(
              child: Text(
                'Tap to view cosmetics',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
