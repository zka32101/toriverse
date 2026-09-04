import 'package:toriverse/shared/models/cosmetic_item.dart';

/// Battle pass service for seasonal progression
///
/// Manages seasonal ranks, rewards, and tier progression.
/// Supports both free and premium tracks with cosmetic rewards.
class BattlePassService {
  /// Current season (rotates monthly)
  static const int currentSeason = 1;

  /// Maximum tier in battle pass
  static const int maxTier = 50;

  /// XP required per tier
  static const int xpPerTier = 1000;

  /// Battle pass configuration by tier
  ///
  /// Defines free and premium rewards at each tier.
  static const Map<int, BattlePassTier> tierConfig = {
    1: BattlePassTier(
      tier: 1,
      name: 'Novice I',
      freeReward: null,
      premiumReward: 'stone_black_classic',
    ),
    5: BattlePassTier(
      tier: 5,
      name: 'Novice V',
      freeReward: 'stone_white_classic',
      premiumReward: 'board_sakura',
    ),
    10: BattlePassTier(
      tier: 10,
      name: 'Intermediate I',
      freeReward: 'stone_red_classic',
      premiumReward: 'board_neon',
    ),
    25: BattlePassTier(
      tier: 25,
      name: 'Master I',
      freeReward: 'board_classic',
      premiumReward: 'board_crystal',
    ),
    50: BattlePassTier(
      tier: 50,
      name: 'Apex',
      freeReward: null,
      premiumReward: 'limited_apex_board', // Exclusive seasonal cosmetic
    ),
  };

  /// Get current tier based on XP
  ///
  /// Calculates tier from total XP.
  /// Returns tier (1-50) and XP progress to next tier.
  ({int tier, int xpToNextTier, int totalXpEarned}) getTierFromXP(
    int totalXP,
  ) {
    final tier = (totalXP ~/ xpPerTier) + 1;
    final clampedTier = tier > maxTier ? maxTier : tier;

    final currentTierStartXP = (clampedTier - 1) * xpPerTier;
    final nextTierStartXP = clampedTier * xpPerTier;
    final xpToNextTier = nextTierStartXP - totalXP;

    return (
      tier: clampedTier,
      xpToNextTier: xpToNextTier.clamp(0, xpPerTier),
      totalXpEarned: totalXP,
    );
  }

  /// Calculate XP gained from match
  ///
  /// Rewards vary by match result and duration.
  int calculateMatchXP({
    required String result, // 'win', 'loss', 'draw'
    required int matchDurationSeconds,
    bool isPremium = false,
  }) {
    int baseXP = 50;

    // Bonus for win
    if (result == 'win') {
      baseXP += 25;
    }

    // Bonus for longer matches (strategic play)
    if (matchDurationSeconds > 300) {
      baseXP += 10;
    }

    // Premium track multiplier (1.5x)
    if (isPremium) {
      baseXP = (baseXP * 1.5).toInt();
    }

    return baseXP;
  }

  /// Get reward at specific tier
  ///
  /// Returns free and premium rewards.
  BattlePassTier? getTierReward(int tier) {
    if (tier < 1 || tier > maxTier) return null;

    // Return closest tier with defined rewards
    for (int t = tier; t >= 1; t--) {
      if (tierConfig.containsKey(t)) {
        return tierConfig[t];
      }
    }

    return null;
  }

  /// Check if tier has milestone reward
  bool hasMilestoneReward(int tier) {
    return tierConfig.containsKey(tier);
  }

  /// Get XP progress visualization (0-100)
  int getProgressPercentage(int currentTier, int xpToNextTier) {
    if (currentTier >= maxTier) return 100;
    return 100 - ((xpToNextTier / xpPerTier) * 100).toInt();
  }

  /// Get season end date
  ///
  /// Seasons are 30 days long.
  DateTime getSeasonEndDate(DateTime seasonStartDate) {
    return seasonStartDate.add(const Duration(days: 30));
  }

  /// Check if battle pass is active
  bool isBattlePassActive(DateTime seasonStartDate) {
    final now = DateTime.now();
    final endDate = getSeasonEndDate(seasonStartDate);
    return now.isBefore(endDate);
  }

  /// Calculate days remaining in season
  int getDaysRemainingInSeason(DateTime seasonStartDate) {
    final endDate = getSeasonEndDate(seasonStartDate);
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }
}

/// Battle pass tier definition
class BattlePassTier {
  /// Tier number (1-50)
  final int tier;

  /// Display name for tier
  final String name;

  /// Free reward cosmetic ID (null if no reward)
  final String? freeReward;

  /// Premium reward cosmetic ID (null if no reward)
  final String? premiumReward;

  const BattlePassTier({
    required this.tier,
    required this.name,
    required this.freeReward,
    required this.premiumReward,
  });

  /// Convert to JSON
  Map<String, dynamic> toMap() => {
        'tier': tier,
        'name': name,
        'free_reward': freeReward,
        'premium_reward': premiumReward,
      };

  /// Create from JSON
  factory BattlePassTier.fromMap(Map<String, dynamic> map) {
    return BattlePassTier(
      tier: map['tier'] as int,
      name: map['name'] as String,
      freeReward: map['free_reward'] as String?,
      premiumReward: map['premium_reward'] as String?,
    );
  }
}

/// User's battle pass progress
class UserBattlePassProgress {
  /// User ID
  final String userId;

  /// Current season
  final int season;

  /// Total XP earned in season
  final int totalXP;

  /// Current tier (calculated from XP)
  final int currentTier;

  /// Whether user owns premium pass
  final bool hasPremiumPass;

  /// Rewards already claimed
  final Set<int> claimedRewards;

  /// Date season started
  final DateTime seasonStartDate;

  UserBattlePassProgress({
    required this.userId,
    required this.season,
    required this.totalXP,
    required this.currentTier,
    required this.hasPremiumPass,
    required this.claimedRewards,
    required this.seasonStartDate,
  });

  /// Convert to JSON
  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'season': season,
        'total_xp': totalXP,
        'current_tier': currentTier,
        'has_premium_pass': hasPremiumPass,
        'claimed_rewards': claimedRewards.toList(),
        'season_start_date': seasonStartDate.toIso8601String(),
      };

  /// Create from JSON
  factory UserBattlePassProgress.fromMap(Map<String, dynamic> map) {
    return UserBattlePassProgress(
      userId: map['user_id'] as String,
      season: map['season'] as int,
      totalXP: map['total_xp'] as int? ?? 0,
      currentTier: map['current_tier'] as int? ?? 1,
      hasPremiumPass: map['has_premium_pass'] as bool? ?? false,
      claimedRewards: Set<int>.from(
        (map['claimed_rewards'] as List?)?.cast<int>() ?? [],
      ),
      seasonStartDate: DateTime.parse(
        map['season_start_date'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Check if user can claim reward at tier
  bool canClaimReward(int tier) {
    return currentTier >= tier && !claimedRewards.contains(tier);
  }

  /// Mark reward as claimed
  UserBattlePassProgress claimReward(int tier) {
    return UserBattlePassProgress(
      userId: userId,
      season: season,
      totalXP: totalXP,
      currentTier: currentTier,
      hasPremiumPass: hasPremiumPass,
      claimedRewards: {...claimedRewards, tier},
      seasonStartDate: seasonStartDate,
    );
  }
}
