import 'package:toriverse/features/match/application/providers/ai_takeover_state.dart';
import 'package:toriverse/features/match/application/providers/streak_state.dart';

/// Determines streak progression and reset logic
class StreakCalculator {
  /// Check if match completion should increment streak
  ///
  /// Returns true if:
  /// - Match is fully finished (not abandoned)
  /// - Player didn't manually quit
  /// - Player didn't timeout without AI takeover
  ///
  /// Note: AI takeover does NOT reset streak!
  static bool shouldIncrementStreak({
    required bool matchFinished,
    required bool manuallyQuit,
    required bool timedOutWithoutAITakeover,
    required AITakeoverState aiTakeover,
  }) {
    // Match must be finished
    if (!matchFinished) return false;

    // Player must not have quit manually
    if (manuallyQuit) return false;

    // Player must not have timed out without AI takeover
    if (timedOutWithoutAITakeover) return false;

    // If we get here, streak should increment
    return true;
  }

  /// Check if streak should be reset and return the reason
  ///
  /// Returns null if streak should NOT be reset
  /// Returns reason string if streak should be reset:
  /// - 'manual_quit': Player manually abandoned
  /// - 'connection_timeout': Timeout without AI takeover
  /// - 'system_error': Unexpected error
  ///
  /// Note: AI takeover does NOT cause reset!
  static String? getStreakResetReason({
    required bool matchFinished,
    required bool manuallyQuit,
    required bool connectionLost,
    required bool aiTakeoverActive,
    required String? matchErrorReason,
  }) {
    // If AI takeover is active, never reset
    // (Other players still played with AI, game continued)
    if (aiTakeoverActive) {
      return null; // Preserve streak!
    }

    // Manual quit = reset
    if (manuallyQuit) {
      return 'manual_quit';
    }

    // Connection timeout without AI takeover = reset
    if (connectionLost && !aiTakeoverActive) {
      return 'connection_timeout';
    }

    // System error
    if (matchErrorReason != null) {
      return 'system_error';
    }

    // No reset needed
    return null;
  }

  /// Milestone boundaries for badges and rewards
  static const milestoneBoundaries = [3, 5, 10, 25, 50, 100];

  /// Check if a streak value is at a milestone
  static bool isMilestone(int streak) {
    return milestoneBoundaries.contains(streak);
  }

  /// Get next milestone after current streak
  static int getNextMilestone(int currentStreak) {
    for (final boundary in milestoneBoundaries) {
      if (boundary > currentStreak) return boundary;
    }
    // If beyond all defined milestones, return next 25
    return ((currentStreak ~/ 25) + 1) * 25;
  }

  /// Get milestone level (for scaling rewards)
  /// 0 = no milestone
  /// 1 = first milestone (3)
  /// 2 = second milestone (5)
  /// etc.
  static int getMilestoneLevel(int streak) {
    for (int i = 0; i < milestoneBoundaries.length; i++) {
      if (milestoneBoundaries[i] == streak) {
        return i + 1;
      }
    }
    return 0;
  }

  /// Check if reaching this streak is a "major" milestone
  /// Major milestones: 10, 25, 50, 100
  static bool isMajorMilestone(int streak) {
    return [10, 25, 50, 100].contains(streak);
  }

  /// Calculate streak "burn rate" (how often player completes streaks)
  /// Useful for engagement metrics
  static double calculateStreakEngagement(
    int currentStreak,
    int bestStreak,
    DateTime? lastCompletedAt,
  ) {
    if (lastCompletedAt == null) return 0.0;

    // How many days since last completion?
    final daysSinceCompletion = DateTime.now()
        .difference(lastCompletedAt)
        .inDays
        .clamp(0, 30);

    // Active streaks are better than inactive ones
    if (currentStreak > 0 && daysSinceCompletion == 0) {
      return 1.0; // Completed today, high engagement
    } else if (currentStreak > 0 && daysSinceCompletion <= 3) {
      return 0.7; // Recent activity
    } else if (bestStreak >= 25) {
      return 0.5; // Has achieved major milestone in past
    } else {
      return 0.2; // Inactive or low engagement
    }
  }
}

/// Determines cosmetic rewards for streaks and milestones
class CosmeticRewardCalculator {
  /// Get a cosmetic reward for reaching a streak
  ///
  /// Returns null if no reward this streak
  /// Probabilistic: approximately 1 cosmetic per 5 streaks
  /// Higher rarity at higher streaks
  static bool shouldGrantStreakReward(int streakValue) {
    // Grant reward every 5 streaks
    // 5, 10, 15, 20, 25, ...
    return streakValue > 0 && streakValue % 5 == 0;
  }

  /// Check if reaching this streak grants a reward
  /// Used before calling shouldGrantStreakReward
  static int? getStreakRewardStreak(int streakValue) {
    if (streakValue > 0 && streakValue % 5 == 0) {
      return streakValue;
    }
    return null;
  }

  /// Get rarity for streak-based reward
  /// Higher streaks = better rarity
  static String getStreakRewardRarity(int streakValue) {
    if (streakValue >= 50) {
      return 'legendary'; // 50+ streak
    } else if (streakValue >= 25) {
      return 'rare'; // 25-49 streak
    } else if (streakValue >= 10) {
      return 'uncommon'; // 10-24 streak
    } else {
      return 'common'; // 5-9 streak
    }
  }

  /// Check if milestone should grant a guaranteed reward
  static bool shouldGrantMilestoneReward(int milestone) {
    // All milestones grant rewards
    return StreakCalculator.isMilestone(milestone);
  }

  /// Get rarity for milestone reward
  /// Milestones always get better rewards than streaks
  static String getMilestoneRewardRarity(int milestone) {
    if (milestone >= 100) {
      return 'legendary';
    } else if (milestone >= 50) {
      return 'legendary';
    } else if (milestone >= 25) {
      return 'rare';
    } else if (milestone >= 10) {
      return 'rare';
    } else if (milestone >= 5) {
      return 'uncommon';
    } else {
      return 'uncommon'; // 3-streak gets uncommon
    }
  }

  /// Get cosmetic type for reward (cosmetics alternate between types)
  /// Ensures variety in rewards
  static String getRewardCosmeticType(int streakValue) {
    // Alternate between 'board' and 'stone' rewards
    // Odd streaks = board, even streaks = stone
    return streakValue % 2 == 1 ? 'board' : 'stone';
  }

  /// Calculate probability of getting bonus cosmetic on top of regular reward
  /// Higher streaks = higher bonus chance
  static double getBonusCosmeticProbability(int streakValue) {
    if (streakValue >= 50) return 0.5; // 50% chance
    if (streakValue >= 25) return 0.3; // 30% chance
    if (streakValue >= 10) return 0.15; // 15% chance
    return 0.05; // 5% chance
  }
}
