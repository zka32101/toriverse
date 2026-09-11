import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/match/domain/services/streak_calculator.dart';
import 'package:toriverse/features/match/application/providers/cosmetic_state.dart';

void main() {
  group('StreakCalculator', () {
    group('shouldIncrementStreak', () {
      test('returns true for completed match', () {
        expect(
          StreakCalculator.shouldIncrementStreak(
            matchStatus: 'finished',
            quitReason: null,
            timeoutReason: null,
          ),
          isTrue,
        );
      });

      test('returns false for manual quit', () {
        expect(
          StreakCalculator.shouldIncrementStreak(
            matchStatus: 'finished',
            quitReason: 'manual',
            timeoutReason: null,
          ),
          isFalse,
        );
      });

      test('returns false for connection timeout without AI takeover', () {
        expect(
          StreakCalculator.shouldIncrementStreak(
            matchStatus: 'finished',
            quitReason: null,
            timeoutReason: 'connection_lost',
          ),
          isFalse,
        );
      });

      test('returns true for connection timeout with AI takeover', () {
        expect(
          StreakCalculator.shouldIncrementStreak(
            matchStatus: 'finished',
            quitReason: null,
            timeoutReason: 'connection_lost_with_ai',
          ),
          isTrue,
        );
      });

      test('returns false for non-finished match', () {
        expect(
          StreakCalculator.shouldIncrementStreak(
            matchStatus: 'playing',
            quitReason: null,
            timeoutReason: null,
          ),
          isFalse,
        );
      });
    });

    group('getStreakResetReason', () {
      test('returns null for valid completion', () {
        expect(
          StreakCalculator.getStreakResetReason(
            matchStatus: 'finished',
            quitReason: null,
            timeoutReason: null,
          ),
          isNull,
        );
      });

      test('returns manual_quit for user quit', () {
        expect(
          StreakCalculator.getStreakResetReason(
            matchStatus: 'finished',
            quitReason: 'manual',
            timeoutReason: null,
          ),
          equals('manual_quit'),
        );
      });

      test('returns connection_timeout for timeout without AI', () {
        expect(
          StreakCalculator.getStreakResetReason(
            matchStatus: 'finished',
            quitReason: null,
            timeoutReason: 'connection_lost',
          ),
          equals('connection_timeout'),
        );
      });

      test('returns system_error for other conditions', () {
        expect(
          StreakCalculator.getStreakResetReason(
            matchStatus: 'error',
            quitReason: null,
            timeoutReason: null,
          ),
          equals('system_error'),
        );
      });
    });

    group('isMilestone', () {
      test('identifies milestone 3', () {
        expect(StreakCalculator.isMilestone(3), isTrue);
      });

      test('identifies milestone 5', () {
        expect(StreakCalculator.isMilestone(5), isTrue);
      });

      test('identifies milestone 10', () {
        expect(StreakCalculator.isMilestone(10), isTrue);
      });

      test('identifies milestone 25', () {
        expect(StreakCalculator.isMilestone(25), isTrue);
      });

      test('identifies milestone 50', () {
        expect(StreakCalculator.isMilestone(50), isTrue);
      });

      test('identifies milestone 100', () {
        expect(StreakCalculator.isMilestone(100), isTrue);
      });

      test('returns false for non-milestone', () {
        expect(StreakCalculator.isMilestone(4), isFalse);
        expect(StreakCalculator.isMilestone(7), isFalse);
        expect(StreakCalculator.isMilestone(51), isFalse);
      });
    });

    group('getNextMilestone', () {
      test('returns 3 for streak < 3', () {
        expect(StreakCalculator.getNextMilestone(0), equals(3));
        expect(StreakCalculator.getNextMilestone(1), equals(3));
        expect(StreakCalculator.getNextMilestone(2), equals(3));
      });

      test('returns 5 for streak 3-4', () {
        expect(StreakCalculator.getNextMilestone(3), equals(5));
        expect(StreakCalculator.getNextMilestone(4), equals(5));
      });

      test('returns 10 for streak 5-9', () {
        expect(StreakCalculator.getNextMilestone(5), equals(10));
        expect(StreakCalculator.getNextMilestone(9), equals(10));
      });

      test('returns 25 for streak 10-24', () {
        expect(StreakCalculator.getNextMilestone(10), equals(25));
        expect(StreakCalculator.getNextMilestone(24), equals(25));
      });

      test('returns 50 for streak 25-49', () {
        expect(StreakCalculator.getNextMilestone(25), equals(50));
        expect(StreakCalculator.getNextMilestone(49), equals(50));
      });

      test('returns 100 for streak 50-99', () {
        expect(StreakCalculator.getNextMilestone(50), equals(100));
        expect(StreakCalculator.getNextMilestone(99), equals(100));
      });

      test('returns null for streak >= 100', () {
        expect(StreakCalculator.getNextMilestone(100), isNull);
        expect(StreakCalculator.getNextMilestone(200), isNull);
      });
    });

    group('getMilestoneLevel', () {
      test('returns 0 for streak < 3', () {
        expect(StreakCalculator.getMilestoneLevel(0), equals(0));
        expect(StreakCalculator.getMilestoneLevel(2), equals(0));
      });

      test('returns correct level for each milestone', () {
        expect(StreakCalculator.getMilestoneLevel(3), equals(1));
        expect(StreakCalculator.getMilestoneLevel(5), equals(2));
        expect(StreakCalculator.getMilestoneLevel(10), equals(3));
        expect(StreakCalculator.getMilestoneLevel(25), equals(4));
        expect(StreakCalculator.getMilestoneLevel(50), equals(5));
        expect(StreakCalculator.getMilestoneLevel(100), equals(6));
      });

      test('maintains level between milestones', () {
        expect(StreakCalculator.getMilestoneLevel(3), equals(1));
        expect(StreakCalculator.getMilestoneLevel(4), equals(1));
        expect(StreakCalculator.getMilestoneLevel(15), equals(3));
        expect(StreakCalculator.getMilestoneLevel(48), equals(4));
      });

      test('caps level at 6 for very high streaks', () {
        expect(StreakCalculator.getMilestoneLevel(500), equals(6));
      });
    });

    group('isMajorMilestone', () {
      test('identifies major milestones (10, 25, 50, 100)', () {
        expect(StreakCalculator.isMajorMilestone(10), isTrue);
        expect(StreakCalculator.isMajorMilestone(25), isTrue);
        expect(StreakCalculator.isMajorMilestone(50), isTrue);
        expect(StreakCalculator.isMajorMilestone(100), isTrue);
      });

      test('returns false for minor milestones (3, 5)', () {
        expect(StreakCalculator.isMajorMilestone(3), isFalse);
        expect(StreakCalculator.isMajorMilestone(5), isFalse);
      });

      test('returns false for non-milestones', () {
        expect(StreakCalculator.isMajorMilestone(7), isFalse);
        expect(StreakCalculator.isMajorMilestone(15), isFalse);
      });
    });
  });

  group('CosmeticRewardCalculator', () {
    group('shouldGrantStreakReward', () {
      test('returns false for streaks < 5', () {
        expect(CosmeticRewardCalculator.shouldGrantStreakReward(1), isFalse);
        expect(CosmeticRewardCalculator.shouldGrantStreakReward(4), isFalse);
      });

      test('returns true approximately every 5 streaks', () {
        // At streak 5, 10, 15, 20, etc.
        expect(CosmeticRewardCalculator.shouldGrantStreakReward(5), isTrue);
        expect(CosmeticRewardCalculator.shouldGrantStreakReward(10), isTrue);
        expect(CosmeticRewardCalculator.shouldGrantStreakReward(15), isTrue);
      });

      test('returns false for non-reward streaks', () {
        // Between reward streaks
        expect(CosmeticRewardCalculator.shouldGrantStreakReward(6), isFalse);
        expect(CosmeticRewardCalculator.shouldGrantStreakReward(12), isFalse);
      });
    });

    group('getStreakRewardRarity', () {
      test('returns common for streaks 5-9', () {
        expect(
          CosmeticRewardCalculator.getStreakRewardRarity(5),
          equals('common'),
        );
        expect(
          CosmeticRewardCalculator.getStreakRewardRarity(9),
          equals('common'),
        );
      });

      test('returns uncommon for streaks 10-24', () {
        expect(
          CosmeticRewardCalculator.getStreakRewardRarity(10),
          equals('uncommon'),
        );
        expect(
          CosmeticRewardCalculator.getStreakRewardRarity(24),
          equals('uncommon'),
        );
      });

      test('returns rare for streaks 25-49', () {
        expect(
          CosmeticRewardCalculator.getStreakRewardRarity(25),
          equals('rare'),
        );
        expect(
          CosmeticRewardCalculator.getStreakRewardRarity(49),
          equals('rare'),
        );
      });

      test('returns legendary for streaks 50+', () {
        expect(
          CosmeticRewardCalculator.getStreakRewardRarity(50),
          equals('legendary'),
        );
        expect(
          CosmeticRewardCalculator.getStreakRewardRarity(100),
          equals('legendary'),
        );
      });
    });

    group('shouldGrantMilestoneReward', () {
      test('returns true for all milestones', () {
        expect(CosmeticRewardCalculator.shouldGrantMilestoneReward(3), isTrue);
        expect(CosmeticRewardCalculator.shouldGrantMilestoneReward(5), isTrue);
        expect(CosmeticRewardCalculator.shouldGrantMilestoneReward(10), isTrue);
        expect(CosmeticRewardCalculator.shouldGrantMilestoneReward(25), isTrue);
        expect(CosmeticRewardCalculator.shouldGrantMilestoneReward(50), isTrue);
        expect(CosmeticRewardCalculator.shouldGrantMilestoneReward(100), isTrue);
      });

      test('returns false for non-milestones', () {
        expect(CosmeticRewardCalculator.shouldGrantMilestoneReward(1), isFalse);
        expect(CosmeticRewardCalculator.shouldGrantMilestoneReward(7), isFalse);
        expect(CosmeticRewardCalculator.shouldGrantMilestoneReward(15), isFalse);
      });
    });

    group('getMilestoneRewardRarity', () {
      test('returns better rarity for milestones vs streak rewards', () {
        // Milestone rewards are 1-2 rarity levels higher than streak at same count
        expect(
          CosmeticRewardCalculator.getMilestoneRewardRarity(5),
          equals('uncommon'),
        );
        expect(
          CosmeticRewardCalculator.getMilestoneRewardRarity(10),
          equals('rare'),
        );
        expect(
          CosmeticRewardCalculator.getMilestoneRewardRarity(25),
          equals('legendary'),
        );
      });

      test('handles major vs minor milestone tiers', () {
        // Minor milestones (3, 5) get lower rarity
        expect(
          CosmeticRewardCalculator.getMilestoneRewardRarity(3),
          equals('common'),
        );
        expect(
          CosmeticRewardCalculator.getMilestoneRewardRarity(5),
          equals('uncommon'),
        );
      });
    });

    group('getRewardCosmeticType', () {
      test('alternates between board and stone', () {
        final type1 = CosmeticRewardCalculator.getRewardCosmeticType(1);
        final type2 = CosmeticRewardCalculator.getRewardCosmeticType(2);
        final type3 = CosmeticRewardCalculator.getRewardCosmeticType(3);

        expect([type1, type2, type3], contains('board'));
        expect([type1, type2, type3], contains('stone'));
      });

      test('returns only board or stone', () {
        for (int i = 0; i < 20; i++) {
          final type = CosmeticRewardCalculator.getRewardCosmeticType(i);
          expect(['board', 'stone'], contains(type));
        }
      });
    });

    group('getBonusCosmeticProbability', () {
      test('returns 5% for streaks 5-9', () {
        expect(
          CosmeticRewardCalculator.getBonusCosmeticProbability(5),
          equals(0.05),
        );
        expect(
          CosmeticRewardCalculator.getBonusCosmeticProbability(9),
          equals(0.05),
        );
      });

      test('returns 20% for streaks 10-24', () {
        expect(
          CosmeticRewardCalculator.getBonusCosmeticProbability(10),
          equals(0.20),
        );
        expect(
          CosmeticRewardCalculator.getBonusCosmeticProbability(24),
          equals(0.20),
        );
      });

      test('returns 35% for streaks 25-49', () {
        expect(
          CosmeticRewardCalculator.getBonusCosmeticProbability(25),
          equals(0.35),
        );
        expect(
          CosmeticRewardCalculator.getBonusCosmeticProbability(49),
          equals(0.35),
        );
      });

      test('returns 50% for streaks 50+', () {
        expect(
          CosmeticRewardCalculator.getBonusCosmeticProbability(50),
          equals(0.50),
        );
        expect(
          CosmeticRewardCalculator.getBonusCosmeticProbability(100),
          equals(0.50),
        );
      });

      test('returns 0% for streaks < 5', () {
        expect(
          CosmeticRewardCalculator.getBonusCosmeticProbability(1),
          equals(0.0),
        );
        expect(
          CosmeticRewardCalculator.getBonusCosmeticProbability(4),
          equals(0.0),
        );
      });
    });
  });
}
