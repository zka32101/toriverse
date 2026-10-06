import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/match/domain/services/bonus_calculator.dart';

void main() {
  group('BonusCalculator', () {
    group('Weak Bonus Activation', () {
      test('shouldActivateBonus returns false when not in late game', () {
        final result = BonusCalculator.shouldActivateBonus(
          roundsRemaining: 20, // Not in final 11 rounds
          stoneCounts: [10, 15, 5],
          previousActivations: 0,
          playerIndex: 2, // Lowest score
          configService: null,
        );

        expect(result, isFalse);
      });

      test('shouldActivateBonus returns false when not in bottom 20%', () {
        final result = BonusCalculator.shouldActivateBonus(
          roundsRemaining: 10, // In final rounds
          stoneCounts: [20, 18, 17], // All relatively close
          previousActivations: 0,
          playerIndex: 2, // Middle/high score
          configService: null,
        );

        expect(result, isFalse);
      });

      test('shouldActivateBonus returns false when max activations reached', () {
        final result = BonusCalculator.shouldActivateBonus(
          roundsRemaining: 10,
          stoneCounts: [30, 15, 5],
          previousActivations: 2, // Already used 2 times
          playerIndex: 2, // Lowest score
          configService: null,
        );

        expect(result, isFalse);
      });

      test('shouldActivateBonus returns true when all conditions met', () {
        final result = BonusCalculator.shouldActivateBonus(
          roundsRemaining: 10, // Final rounds
          stoneCounts: [30, 20, 5], // Significantly trailing
          previousActivations: 0, // Not used yet
          playerIndex: 2, // Lowest score
          configService: null,
        );

        expect(result, isTrue);
      });

      test('shouldActivateBonus activates on 1st and 2nd time only', () {
        // First activation
        expect(
          BonusCalculator.shouldActivateBonus(
            roundsRemaining: 10,
            stoneCounts: [30, 20, 5],
            previousActivations: 0,
            playerIndex: 2,
          ),
          isTrue,
        );

        // Second activation
        expect(
          BonusCalculator.shouldActivateBonus(
            roundsRemaining: 8,
            stoneCounts: [35, 18, 10],
            previousActivations: 1,
            playerIndex: 2,
          ),
          isTrue,
        );

        // Third activation blocked
        expect(
          BonusCalculator.shouldActivateBonus(
            roundsRemaining: 6,
            stoneCounts: [40, 16, 15],
            previousActivations: 2,
            playerIndex: 2,
          ),
          isFalse,
        );
      });
    });

    group('Bottom Percentile Check', () {
      test('Player in last place qualifies', () {
        final result = BonusCalculator.shouldActivateBonus(
          roundsRemaining: 10,
          stoneCounts: [25, 20, 5], // Player 2 in last
          previousActivations: 0,
          playerIndex: 2,
        );

        expect(result, isTrue);
      });

      test('High-scoring player does not qualify', () {
        final result = BonusCalculator.shouldActivateBonus(
          roundsRemaining: 10,
          stoneCounts: [25, 20, 5],
          previousActivations: 0,
          playerIndex: 0, // Leading player
        );

        expect(result, isFalse);
      });

      test('Mid-range player in close game does not qualify', () {
        final result = BonusCalculator.shouldActivateBonus(
          roundsRemaining: 10,
          stoneCounts: [21, 20, 19], // Close scores
          previousActivations: 0,
          playerIndex: 2,
        );

        expect(result, isFalse);
      });
    });

    group('Bonus Effect', () {
      test('applyBonus returns extra move', () {
        final bonus = BonusCalculator.applyBonus(
          playerIndex: 0,
          currentScore: 10,
        );

        expect(bonus['type'], equals('extra_move'));
        expect(bonus['value'], equals(1));
        expect(bonus['playerId'], equals(0));
      });

      test('applyBonus provides description', () {
        final bonus = BonusCalculator.applyBonus(
          playerIndex: 1,
          currentScore: 15,
        );

        expect(bonus['description'], isNotEmpty);
        expect(bonus['description'], contains('弱者ボーナス'));
      });
    });
  });

  group('RescueCardCalculator', () {
    group('Rescue Card Grant', () {
      test('shouldGrantRescueCard returns true after 2 consecutive attacks', () {
        final result = RescueCardCalculator.shouldGrantRescueCard(
          consecutiveAttackCount: 2,
          cardAlreadyActive: false,
          configService: null,
        );

        expect(result, isTrue);
      });

      test('shouldGrantRescueCard returns false when already active', () {
        final result = RescueCardCalculator.shouldGrantRescueCard(
          consecutiveAttackCount: 2,
          cardAlreadyActive: true, // Already have the card
          configService: null,
        );

        expect(result, isFalse);
      });

      test('shouldGrantRescueCard returns false for single attack', () {
        final result = RescueCardCalculator.shouldGrantRescueCard(
          consecutiveAttackCount: 1,
          cardAlreadyActive: false,
          configService: null,
        );

        expect(result, isFalse);
      });

      test('shouldGrantRescueCard triggers at threshold', () {
        final result = RescueCardCalculator.shouldGrantRescueCard(
          consecutiveAttackCount: 2,
          cardAlreadyActive: false,
        );

        expect(result, isTrue);
      });

      test('shouldGrantRescueCard triggers above threshold', () {
        final result = RescueCardCalculator.shouldGrantRescueCard(
          consecutiveAttackCount: 3,
          cardAlreadyActive: false,
        );

        expect(result, isTrue);
      });
    });

    group('Rescue Card Effect', () {
      test('applyRescueCard returns double move', () {
        final card = RescueCardCalculator.applyRescueCard(
          playerIndex: 0,
        );

        expect(card['type'], equals('double_move'));
        expect(card['value'], equals(2));
        expect(card['playerId'], equals(0));
      });

      test('applyRescueCard specifies duration', () {
        final card = RescueCardCalculator.applyRescueCard(
          playerIndex: 1,
        );

        expect(card['duration'], equals('next_round'));
      });

      test('applyRescueCard provides description', () {
        final card = RescueCardCalculator.applyRescueCard(
          playerIndex: 2,
        );

        expect(card['description'], isNotEmpty);
        expect(card['description'], contains('救済カード'));
      });
    });
  });

  group('CollisionResolver', () {
    test('resolveCollision returns winner from collision list', () {
      final result = CollisionResolver.resolveCollision(
        playerIds: ['player1', 'player2', 'player3'],
        boardRow: 3,
        boardCol: 4,
      );

      expect(result['winner'], isIn(['player1', 'player2', 'player3']));
      expect(result['losers'], isNotEmpty);
      expect(result['losers'].length, equals(2));
    });

    test('resolveCollision winner not in losers', () {
      final result = CollisionResolver.resolveCollision(
        playerIds: ['player1', 'player2'],
        boardRow: 5,
        boardCol: 6,
      );

      final winner = result['winner'] as String;
      final losers = result['losers'] as List<String>;

      expect(losers, isNotEmpty);
      expect(losers, isNot(contains(winner)));
    });

    test('resolveCollision grants rescue card', () {
      final result = CollisionResolver.resolveCollision(
        playerIds: ['player1', 'player2', 'player3'],
        boardRow: 0,
        boardCol: 0,
      );

      expect(result['rescueCardGranted'], isTrue);
    });

    test('resolveCollision stores position', () {
      final result = CollisionResolver.resolveCollision(
        playerIds: ['player1', 'player2'],
        boardRow: 3,
        boardCol: 5,
      );

      expect(result['position'], equals([3, 5]));
    });

    test('resolveCollision provides description', () {
      final result = CollisionResolver.resolveCollision(
        playerIds: ['player1', 'player2'],
        boardRow: 2,
        boardCol: 3,
      );

      expect(result['description'], isNotEmpty);
      expect(result['description'], contains('同マス被り'));
    });

    // CLAUDE.md §16「同マス被り時のランダム抽選（偏りチェック）」:
    // 均等分布であることを統計的に確認する。既存のテストは1回のみの実行で
    // winner が playerIds のいずれかであることしか確認しておらず、
    // 偏り（例: 常に同じプレイヤーが勝つ）を検出できなかった。
    test('resolveCollision: 3人抽選は十分な回数で均等分布に近い', () {
      const trials = 9000;
      const players = ['player1', 'player2', 'player3'];
      final winCounts = {for (final p in players) p: 0};

      for (int i = 0; i < trials; i++) {
        final result = CollisionResolver.resolveCollision(
          playerIds: players,
          boardRow: 0,
          boardCol: 0,
        );
        winCounts[result['winner'] as String] =
            winCounts[result['winner'] as String]! + 1;
      }

      // 期待値は trials/3 = 3000。真に均等な乱数なら標準偏差は約36.5
      // (sqrt(trials * 1/3 * 2/3))。±16%（約±480、13標準偏差相当）の
      // 許容幅を取っても、「常に同じプレイヤーが選ばれる」等の明確な
      // 偏りバグは確実に検出できる一方、統計的揺らぎでは誤検知しない。
      final expected = trials / players.length;
      final tolerance = expected * 0.16;
      for (final player in players) {
        expect(
          winCounts[player],
          inInclusiveRange(
            (expected - tolerance).round(),
            (expected + tolerance).round(),
          ),
          reason: '$player の当選回数が均等分布から大きく偏っている: '
              '${winCounts[player]} (期待値: $expected)',
        );
      }
    });

    test('resolveCollision: 2人抽選も均等分布に近い', () {
      const trials = 6000;
      const players = ['player1', 'player2'];
      final winCounts = {for (final p in players) p: 0};

      for (int i = 0; i < trials; i++) {
        final result = CollisionResolver.resolveCollision(
          playerIds: players,
          boardRow: 0,
          boardCol: 0,
        );
        winCounts[result['winner'] as String] =
            winCounts[result['winner'] as String]! + 1;
      }

      final expected = trials / players.length; // 3000
      final tolerance = expected * 0.1; // ±300, ~13 standard deviations
      for (final player in players) {
        expect(
          winCounts[player],
          inInclusiveRange(
            (expected - tolerance).round(),
            (expected + tolerance).round(),
          ),
          reason: '$player の当選回数が均等分布から大きく偏っている: '
              '${winCounts[player]} (期待値: $expected)',
        );
      }
    });
  });

  group('ProcessOrderRandomizer', () {
    test('randomizeOrder returns all players', () {
      final players = ['player1', 'player2', 'player3'];
      final order = ProcessOrderRandomizer.randomizeOrder(players);

      expect(order.length, equals(3));
      expect(order, containsAll(players));
    });

    test('randomizeOrder is a permutation', () {
      final players = ['player1', 'player2', 'player3'];
      final order = ProcessOrderRandomizer.randomizeOrder(players);

      // All original players present
      for (final player in players) {
        expect(order, contains(player));
      }

      // No duplicates
      expect(order.length, equals(order.toSet().length));
    });

    test('randomizeOrder can produce different results', () {
      final players = ['player1', 'player2', 'player3'];
      final orders = <String>{};

      // Generate multiple random orders
      for (int i = 0; i < 10; i++) {
        final order = ProcessOrderRandomizer.randomizeOrder(players);
        orders.add(order.join(','));
      }

      // Should have multiple distinct orders (very unlikely to be all same)
      expect(orders.length, greaterThan(1));
    });

    test('generateAnimationSequence includes lottery', () {
      final sequence = ProcessOrderRandomizer.generateAnimationSequence(
        processOrder: ['player1', 'player2', 'player3'],
        moveResults: {
          'player1': {'row': 3, 'col': 4},
          'player2': {'row': 4, 'col': 5},
          'player3': {'row': 5, 'col': 6},
        },
      );

      final lotteryEvent = sequence.firstWhere(
        (e) => e['type'] == 'lottery',
        orElse: () => {},
      );

      expect(lotteryEvent, isNotEmpty);
    });

    test('generateAnimationSequence includes announce turns', () {
      final sequence = ProcessOrderRandomizer.generateAnimationSequence(
        processOrder: ['player1', 'player2', 'player3'],
        moveResults: {},
      );

      final announceEvents = sequence.where((e) => e['type'] == 'announce_turn');
      expect(announceEvents.length, equals(3));
    });

    test('generateAnimationSequence includes flip animations', () {
      final sequence = ProcessOrderRandomizer.generateAnimationSequence(
        processOrder: ['player1', 'player2'],
        moveResults: {
          'player1': {'row': 3, 'col': 4},
          'player2': {'row': 4, 'col': 5},
        },
      );

      final flipEvents = sequence.where((e) => e['type'] == 'flip_animation');
      expect(flipEvents.length, equals(2));
    });
  });
}
