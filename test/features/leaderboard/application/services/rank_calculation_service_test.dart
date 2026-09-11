/// Unit tests for RankCalculationService
///
/// Tests rank point calculation, skill level estimation, and validation.

import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/leaderboard/application/services/rank_calculation_service.dart';
import 'package:toriverse/features/leaderboard/domain/models/leaderboard_models.dart';

void main() {
  late RankCalculationService rankCalculationService;
  late RankPointsConfig config;

  setUp(() {
    config = const RankPointsConfig(
      winPoints1st: 30,
      winPoints2nd: 10,
      winPoints3rd: -5,
      winPointsFriendChallenge: 20,
      lossPointsFriendChallenge: -10,
      aiMatchPoints: 0,
      casualMatchPoints: 0,
      streakBonusPerWin: 5,
    );
    rankCalculationService = RankCalculationService(config: config);
  });

  group('RankCalculationService', () {
    group('calculateMatchPoints', () {
      test('awards correct points for ranked match with 3 players', () {
        // Arrange
        final placements = ['uid1', 'uid2', 'uid3'];

        // Act
        final points = rankCalculationService.calculateMatchPoints(
          placements: placements,
          matchType: 'ranked',
        );

        // Assert
        expect(points['uid1'], equals(30)); // 1st place
        expect(points['uid2'], equals(10)); // 2nd place
        expect(points['uid3'], equals(-5)); // 3rd place
      });

      test('awards zero points for casual matches', () {
        // Arrange
        final placements = ['uid1', 'uid2', 'uid3'];

        // Act
        final points = rankCalculationService.calculateMatchPoints(
          placements: placements,
          matchType: 'casual',
        );

        // Assert
        expect(points['uid1'], equals(0));
        expect(points['uid2'], equals(0));
        expect(points['uid3'], equals(0));
      });

      test('awards points for friendChallenge match type', () {
        // Arrange
        final placements = ['uid1', 'uid2', 'uid3'];

        // Act
        final points = rankCalculationService.calculateMatchPoints(
          placements: placements,
          matchType: 'friendChallenge',
        );

        // Assert
        expect(points['uid1'], equals(30)); // 1st place
        expect(points['uid2'], equals(10)); // 2nd place
        expect(points['uid3'], equals(-5)); // 3rd place
      });

      test('returns empty map for invalid player count', () {
        // Arrange
        final placements = ['uid1', 'uid2']; // Only 2 players

        // Act
        final points = rankCalculationService.calculateMatchPoints(
          placements: placements,
          matchType: 'ranked',
        );

        // Assert
        expect(points, isEmpty);
      });

      test('returns empty map for 4 players', () {
        // Arrange
        final placements = ['uid1', 'uid2', 'uid3', 'uid4'];

        // Act
        final points = rankCalculationService.calculateMatchPoints(
          placements: placements,
          matchType: 'ranked',
        );

        // Assert
        expect(points, isEmpty);
      });
    });

    group('calculateFriendChallengePoints', () {
      test('calculates correct friend challenge points', () {
        // Act
        final points = rankCalculationService.calculateFriendChallengePoints(
          winnerUid: 'uid1',
          loserUid: 'uid2',
        );

        // Assert
        expect(points['uid1'], equals(20)); // Winner
        expect(points['uid2'], equals(-10)); // Loser
      });

      test('returns 2 entries for friend challenge', () {
        // Act
        final points = rankCalculationService.calculateFriendChallengePoints(
          winnerUid: 'uid1',
          loserUid: 'uid2',
        );

        // Assert
        expect(points, hasLength(2));
      });
    });

    group('calculateWinRate', () {
      test('calculates correct win rate', () {
        // Act
        final winRate = RankCalculationService.calculateWinRate(
          wins: 8,
          totalMatches: 10,
        );

        // Assert
        expect(winRate, closeTo(0.8, 0.001));
      });

      test('returns 0.0 for zero total matches', () {
        // Act
        final winRate = RankCalculationService.calculateWinRate(
          wins: 0,
          totalMatches: 0,
        );

        // Assert
        expect(winRate, equals(0.0));
      });

      test('returns 1.0 for perfect record', () {
        // Act
        final winRate = RankCalculationService.calculateWinRate(
          wins: 10,
          totalMatches: 10,
        );

        // Assert
        expect(winRate, equals(1.0));
      });

      test('returns 0.0 for no wins', () {
        // Act
        final winRate = RankCalculationService.calculateWinRate(
          wins: 0,
          totalMatches: 10,
        );

        // Assert
        expect(winRate, equals(0.0));
      });
    });

    group('matchAffectsRanking', () {
      test('returns true for ranked matches', () {
        // Act
        final affects = rankCalculationService.matchAffectsRanking('ranked');

        // Assert
        expect(affects, isTrue);
      });

      test('returns true for friendChallenge matches', () {
        // Act
        final affects =
            rankCalculationService.matchAffectsRanking('friendChallenge');

        // Assert
        expect(affects, isTrue);
      });

      test('returns false for casual matches', () {
        // Act
        final affects = rankCalculationService.matchAffectsRanking('casual');

        // Assert
        expect(affects, isFalse);
      });

      test('returns false for unknown match types', () {
        // Act
        final affects = rankCalculationService.matchAffectsRanking('unknown');

        // Assert
        expect(affects, isFalse);
      });
    });

    group('getPointsForPlacement', () {
      test('returns 30 points for 1st place', () {
        // Act
        final points = rankCalculationService.getPointsForPlacement(1);

        // Assert
        expect(points, equals(30));
      });

      test('returns 10 points for 2nd place', () {
        // Act
        final points = rankCalculationService.getPointsForPlacement(2);

        // Assert
        expect(points, equals(10));
      });

      test('returns -5 points for 3rd place', () {
        // Act
        final points = rankCalculationService.getPointsForPlacement(3);

        // Assert
        expect(points, equals(-5));
      });

      test('returns 0 points for invalid placement', () {
        // Act
        final points = rankCalculationService.getPointsForPlacement(4);

        // Assert
        expect(points, equals(0));
      });

      test('returns 0 points for negative placement', () {
        // Act
        final points = rankCalculationService.getPointsForPlacement(-1);

        // Assert
        expect(points, equals(0));
      });
    });

    group('estimateSkillLevel', () {
      test('returns Beginner for < 100 points', () {
        // Act
        final level = RankCalculationService.estimateSkillLevel(50);

        // Assert
        expect(level, equals(PlayerSkillLevel.beginner));
      });

      test('returns Intermediate for 100-499 points', () {
        // Act
        final level = RankCalculationService.estimateSkillLevel(300);

        // Assert
        expect(level, equals(PlayerSkillLevel.intermediate));
      });

      test('returns Advanced for 500-1499 points', () {
        // Act
        final level = RankCalculationService.estimateSkillLevel(1000);

        // Assert
        expect(level, equals(PlayerSkillLevel.advanced));
      });

      test('returns Expert for 1500-2999 points', () {
        // Act
        final level = RankCalculationService.estimateSkillLevel(2000);

        // Assert
        expect(level, equals(PlayerSkillLevel.expert));
      });

      test('returns Master for >= 3000 points', () {
        // Act
        final level = RankCalculationService.estimateSkillLevel(5000);

        // Assert
        expect(level, equals(PlayerSkillLevel.master));
      });

      test('boundary: exactly 100 is Intermediate', () {
        // Act
        final level = RankCalculationService.estimateSkillLevel(100);

        // Assert
        expect(level, equals(PlayerSkillLevel.intermediate));
      });

      test('boundary: exactly 500 is Advanced', () {
        // Act
        final level = RankCalculationService.estimateSkillLevel(500);

        // Assert
        expect(level, equals(PlayerSkillLevel.advanced));
      });
    });

    group('validateMatchPoints', () {
      test('validates correct match points', () {
        // Arrange
        final placements = ['uid1', 'uid2', 'uid3'];
        final points = {
          'uid1': 30,
          'uid2': 10,
          'uid3': -5,
        };

        // Act
        final isValid = rankCalculationService.validateMatchPoints(
          placements,
          points,
        );

        // Assert
        expect(isValid, isTrue);
      });

      test('rejects points map with wrong length', () {
        // Arrange
        final placements = ['uid1', 'uid2', 'uid3'];
        final points = {
          'uid1': 30,
          'uid2': 10,
        };

        // Act
        final isValid = rankCalculationService.validateMatchPoints(
          placements,
          points,
        );

        // Assert
        expect(isValid, isFalse);
      });

      test('rejects placements with wrong length', () {
        // Arrange
        final placements = ['uid1', 'uid2'];
        final points = {
          'uid1': 30,
          'uid2': 10,
          'uid3': -5,
        };

        // Act
        final isValid = rankCalculationService.validateMatchPoints(
          placements,
          points,
        );

        // Assert
        expect(isValid, isFalse);
      });

      test('rejects when UIDs do not match', () {
        // Arrange
        final placements = ['uid1', 'uid2', 'uid3'];
        final points = {
          'uid1': 30,
          'uid2': 10,
          'uid999': -5, // Wrong UID
        };

        // Act
        final isValid = rankCalculationService.validateMatchPoints(
          placements,
          points,
        );

        // Assert
        expect(isValid, isFalse);
      });
    });

    group('SkillLevelExtension', () {
      test('displayName for beginner', () {
        // Assert
        expect(PlayerSkillLevel.beginner.displayName, equals('Beginner'));
      });

      test('displayName for master', () {
        // Assert
        expect(PlayerSkillLevel.master.displayName, equals('Master'));
      });

      test('minPoints for beginner', () {
        // Assert
        expect(PlayerSkillLevel.beginner.minPoints, equals(0));
      });

      test('minPoints for master', () {
        // Assert
        expect(PlayerSkillLevel.master.minPoints, equals(3000));
      });

      test('maxPoints for beginner', () {
        // Assert
        expect(PlayerSkillLevel.beginner.maxPoints, equals(99));
      });

      test('maxPoints for master', () {
        // Assert
        expect(PlayerSkillLevel.master.maxPoints, equals(999999));
      });
    });
  });
}
