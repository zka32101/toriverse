import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/shop/domain/services/battle_pass_service.dart';

void main() {
  group('BattlePassService', () {
    final service = BattlePassService();

    test('getTierFromXP calculates correct tier', () {
      // Tier 1: 0-999 XP
      var result = service.getTierFromXP(500);
      expect(result.tier, equals(1));

      // Tier 2: 1000-1999 XP
      result = service.getTierFromXP(1500);
      expect(result.tier, equals(2));

      // Tier 5: 4000-4999 XP
      result = service.getTierFromXP(4500);
      expect(result.tier, equals(5));
    });

    test('getTierFromXP caps at max tier', () {
      final result = service.getTierFromXP(999999);
      expect(result.tier, equals(BattlePassService.maxTier));
    });

    test('getTierFromXP calculates XP to next tier correctly', () {
      // 500 XP → 500 XP to tier 2
      var result = service.getTierFromXP(500);
      expect(result.xpToNextTier, equals(500));

      // 1000 XP → 0 XP to tier 3 (exactly tier boundary)
      result = service.getTierFromXP(1000);
      expect(result.xpToNextTier, equals(1000));

      // 1500 XP → 500 XP to tier 3
      result = service.getTierFromXP(1500);
      expect(result.xpToNextTier, equals(500));
    });

    test('calculateMatchXP returns base XP without bonus', () {
      final xp = service.calculateMatchXP(
        result: 'loss',
        matchDurationSeconds: 180, // < 5 min
        isPremium: false,
      );
      expect(xp, equals(50)); // Base XP only
    });

    test('calculateMatchXP adds win bonus', () {
      final xp = service.calculateMatchXP(
        result: 'win',
        matchDurationSeconds: 180,
        isPremium: false,
      );
      expect(xp, equals(75)); // Base 50 + win 25
    });

    test('calculateMatchXP adds duration bonus', () {
      final xp = service.calculateMatchXP(
        result: 'loss',
        matchDurationSeconds: 301, // > 5 min
        isPremium: false,
      );
      expect(xp, equals(60)); // Base 50 + duration 10
    });

    test('calculateMatchXP combines all bonuses', () {
      final xp = service.calculateMatchXP(
        result: 'win',
        matchDurationSeconds: 301, // > 5 min
        isPremium: false,
      );
      expect(xp, equals(85)); // 50 + 25 + 10
    });

    test('calculateMatchXP applies premium multiplier', () {
      final normalXp = service.calculateMatchXP(
        result: 'win',
        matchDurationSeconds: 301,
        isPremium: false,
      );
      final premiumXp = service.calculateMatchXP(
        result: 'win',
        matchDurationSeconds: 301,
        isPremium: true,
      );
      expect(premiumXp, equals((normalXp * 1.5).toInt()));
    });

    test('getTierReward returns reward at tier', () {
      final tier5 = service.getTierReward(5)!;
      expect(tier5.tier, equals(5));
      expect(tier5.freeReward, equals('stone_white_classic'));
      expect(tier5.premiumReward, equals('board_sakura'));
    });

    test('getTierReward returns null for invalid tier', () {
      expect(service.getTierReward(0), isNull); // Too low
      expect(service.getTierReward(51), isNull); // Too high
    });

    test('hasMilestoneReward checks tier config', () {
      expect(service.hasMilestoneReward(5), isTrue); // Tier 5 has reward
      expect(service.hasMilestoneReward(10), isTrue); // Tier 10 has reward
      expect(service.hasMilestoneReward(7), isFalse); // Tier 7 has no reward
    });

    test('getProgressPercentage calculates correctly', () {
      expect(service.getProgressPercentage(1, 500), equals(50));
      expect(service.getProgressPercentage(5, 0), equals(100));
      expect(service.getProgressPercentage(50, 0), equals(100)); // Max tier
    });

    test('getSeasonEndDate returns 30 days after start', () {
      final start = DateTime(2026, 9, 1);
      final end = service.getSeasonEndDate(start);
      expect(end.difference(start).inDays, equals(30));
    });

    test('isBattlePassActive checks if season is active', () {
      final start = DateTime.now().subtract(const Duration(days: 10));
      final passed = DateTime.now().add(const Duration(days: 20));

      expect(service.isBattlePassActive(start), isTrue);
      expect(service.isBattlePassActive(passed), isFalse);
    });

    test('getDaysRemainingInSeason calculates correctly', () {
      final start = DateTime.now().subtract(const Duration(days: 25));
      final days = service.getDaysRemainingInSeason(start);
      expect(days, isIn([4, 5])); // ~5 days remaining
    });

    test('UserBattlePassProgress serialization roundtrip', () {
      final original = UserBattlePassProgress(
        userId: 'user123',
        season: 1,
        totalXP: 5000,
        currentTier: 5,
        hasPremiumPass: true,
        claimedRewards: {1, 5},
        seasonStartDate: DateTime(2026, 9, 1),
      );

      final map = original.toMap();
      final restored = UserBattlePassProgress.fromMap(map);

      expect(restored.userId, equals(original.userId));
      expect(restored.totalXP, equals(original.totalXP));
      expect(restored.currentTier, equals(original.currentTier));
      expect(restored.hasPremiumPass, equals(original.hasPremiumPass));
      expect(restored.claimedRewards, equals(original.claimedRewards));
    });

    test('UserBattlePassProgress.canClaimReward checks conditions', () {
      final progress = UserBattlePassProgress(
        userId: 'user123',
        season: 1,
        totalXP: 5000,
        currentTier: 5,
        hasPremiumPass: false,
        claimedRewards: {1},
        seasonStartDate: DateTime(2026, 9, 1),
      );

      expect(progress.canClaimReward(5), isTrue); // Current tier, not claimed
      expect(progress.canClaimReward(1), isFalse); // Already claimed
      expect(progress.canClaimReward(10), isFalse); // Not reached yet
    });

    test('UserBattlePassProgress.claimReward creates new instance', () {
      final original = UserBattlePassProgress(
        userId: 'user123',
        season: 1,
        totalXP: 5000,
        currentTier: 5,
        hasPremiumPass: false,
        claimedRewards: {1},
        seasonStartDate: DateTime(2026, 9, 1),
      );

      final updated = original.claimReward(5);

      expect(original.claimedRewards, equals({1})); // Original unchanged
      expect(updated.claimedRewards, equals({1, 5})); // Updated includes 5
      expect(updated.userId, equals(original.userId)); // Other fields same
    });
  });
}
