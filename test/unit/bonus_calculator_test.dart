import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/match/domain/services/bonus_calculator.dart';

void main() {
  group('BonusCalculator - 弱者ボーナス発動判定', () {
    test('条件を全て満たすと発動できる', () {
      final canActivate = BonusCalculator.shouldActivateBonus(
        roundsRemaining: 5,      // 残り11手以下
        stoneCounts: [10, 30, 25], // プレイヤー0が最下位
        previousActivations: 0,   // 未発動
        playerIndex: 0,           // プレイヤー0
      );
      expect(canActivate, true);
    });

    test('残り12手以上だと発動できない', () {
      final canActivate = BonusCalculator.shouldActivateBonus(
        roundsRemaining: 12, // 11を超える
        stoneCounts: [10, 30, 25],
        previousActivations: 0,
        playerIndex: 0,
      );
      expect(canActivate, false);
    });

    test('残り11手ちょうどは発動できる', () {
      final canActivate = BonusCalculator.shouldActivateBonus(
        roundsRemaining: 11,
        stoneCounts: [10, 30, 25],
        previousActivations: 0,
        playerIndex: 0,
      );
      expect(canActivate, true);
    });

    test('劣勢でないと発動できない', () {
      final canActivate = BonusCalculator.shouldActivateBonus(
        roundsRemaining: 5,
        stoneCounts: [25, 26, 24], // プレイヤー0が優勢
        previousActivations: 0,
        playerIndex: 0,
      );
      expect(canActivate, false);
    });

    test('2回発動済みだと発動できない', () {
      final canActivate = BonusCalculator.shouldActivateBonus(
        roundsRemaining: 5,
        stoneCounts: [10, 30, 25],
        previousActivations: 2, // 上限に達した
        playerIndex: 0,
      );
      expect(canActivate, false);
    });

    test('1回発動済みでも発動できる', () {
      final canActivate = BonusCalculator.shouldActivateBonus(
        roundsRemaining: 3,
        stoneCounts: [8, 32, 28],
        previousActivations: 1,
        playerIndex: 0,
      );
      expect(canActivate, true);
    });

    test('複数プレイヤー間の大差でも発動', () {
      final canActivate = BonusCalculator.shouldActivateBonus(
        roundsRemaining: 8,
        stoneCounts: [5, 35, 28], // プレイヤー0が大きく負けている
        previousActivations: 0,
        playerIndex: 0,
      );
      expect(canActivate, true);
    });
  });

  group('BonusCalculator - ボーナス効果適用', () {
    test('ボーナス効果マップが正しい形式', () {
      final bonus = BonusCalculator.applyBonus(
        playerIndex: 0,
        currentScore: 10,
      );

      expect(bonus['type'], 'extra_move');
      expect(bonus['value'], 1);
      expect(bonus['playerId'], 0);
      expect(bonus.containsKey('description'), true);
    });

    test('複数プレイヤーでも効果は独立', () {
      final bonus0 = BonusCalculator.applyBonus(playerIndex: 0, currentScore: 10);
      final bonus1 = BonusCalculator.applyBonus(playerIndex: 1, currentScore: 20);

      expect(bonus0['playerId'], 0);
      expect(bonus1['playerId'], 1);
      expect(bonus0['playerId'] != bonus1['playerId'], true);
    });
  });

  group('RescueCardCalculator - 救済カード発動判定', () {
    test('2ラウンド連続被弾で付与', () {
      final shouldGrant = RescueCardCalculator.shouldGrantRescueCard(
        consecutiveAttackCount: 2,
        cardAlreadyActive: false,
      );
      expect(shouldGrant, true);
    });

    test('1ラウンド被弾では付与されない', () {
      final shouldGrant = RescueCardCalculator.shouldGrantRescueCard(
        consecutiveAttackCount: 1,
        cardAlreadyActive: false,
      );
      expect(shouldGrant, false);
    });

    test('カード既に有効なら付与されない', () {
      final shouldGrant = RescueCardCalculator.shouldGrantRescueCard(
        consecutiveAttackCount: 2,
        cardAlreadyActive: true,
      );
      expect(shouldGrant, false);
    });

    test('3ラウンド以上被弾でも付与', () {
      final shouldGrant = RescueCardCalculator.shouldGrantRescueCard(
        consecutiveAttackCount: 3,
        cardAlreadyActive: false,
      );
      expect(shouldGrant, true);
    });
  });

  group('RescueCardCalculator - 効果適用', () {
    test('救済カード効果マップが正しい形式', () {
      final card = RescueCardCalculator.applyRescueCard(playerIndex: 1);

      expect(card['type'], 'double_move');
      expect(card['value'], 2);
      expect(card['duration'], 'next_round');
      expect(card['playerId'], 1);
      expect(card.containsKey('description'), true);
    });
  });

  group('CollisionResolver - 同マス被り抽選', () {
    test('複数プレイヤーから1人を選出', () {
      final result = CollisionResolver.resolveCollision(
        playerIds: ['player_0', 'player_1', 'player_2'],
        boardRow: 3,
        boardCol: 4,
      );

      expect(result.containsKey('winner'), true);
      expect(result['winner'] != null, true);
      expect(['player_0', 'player_1', 'player_2'].contains(result['winner']), true);
    });

    test('外れたプレイヤーに救済カードが付与', () {
      final result = CollisionResolver.resolveCollision(
        playerIds: ['player_0', 'player_1', 'player_2'],
        boardRow: 3,
        boardCol: 4,
      );

      expect(result['losers'].length, 2);
      expect(result['losers'].length + 1, 3); // 勝者1 + 敗者2
      expect(result['rescueCardGranted'], true);
    });

    test('2人のみの抽選', () {
      final result = CollisionResolver.resolveCollision(
        playerIds: ['player_0', 'player_1'],
        boardRow: 0,
        boardCol: 0,
      );

      expect(result['losers'].length, 1);
      expect(result['winner'] != result['losers'][0], true);
    });

    test('異なる位置での抽選結果が記録される', () {
      final result1 = CollisionResolver.resolveCollision(
        playerIds: ['player_0', 'player_1', 'player_2'],
        boardRow: 3,
        boardCol: 4,
      );

      final result2 = CollisionResolver.resolveCollision(
        playerIds: ['player_0', 'player_1', 'player_2'],
        boardRow: 5,
        boardCol: 6,
      );

      expect(result1['position'], [3, 4]);
      expect(result2['position'], [5, 6]);
    });
  });

  group('ProcessOrderRandomizer - 処理順抽選', () {
    test('3人の処理順をランダムに決定', () {
      final order = ProcessOrderRandomizer.randomizeOrder(
        ['player_0', 'player_1', 'player_2'],
      );

      expect(order.length, 3);
      expect(order.contains('player_0'), true);
      expect(order.contains('player_1'), true);
      expect(order.contains('player_2'), true);
    });

    test('複数回実行で異なる順序が出現', () {
      final orders = <List<String>>[];
      for (int i = 0; i < 10; i++) {
        orders.add(ProcessOrderRandomizer.randomizeOrder(
          ['player_0', 'player_1', 'player_2'],
        ));
      }

      // 全て同じ順序でないことを確認（確率的テスト）
      final uniqueOrders = orders.toSet().length;
      expect(uniqueOrders > 1, true);
    });

    test('アニメーションシーケンス生成', () {
      final sequence = ProcessOrderRandomizer.generateAnimationSequence(
        processOrder: ['player_0', 'player_1', 'player_2'],
        moveResults: {
          'player_0': {'flips': [[3, 3], [3, 4]]},
          'player_1': {'flips': [[4, 4]]},
          'player_2': {'flips': []},
        },
      );

      expect(sequence.isNotEmpty, true);
      expect(sequence[0]['type'], 'lottery');
    });

    test('toReplayEvents で ReplayEvent のリストに変換できる', () {
      final sequence = ProcessOrderRandomizer.generateAnimationSequence(
        processOrder: ['player_0', 'player_1'],
        moveResults: {
          'player_0': {'flips': [[3, 3]]},
          'player_1': {'flips': []},
        },
      );

      final events = ProcessOrderRandomizer.toReplayEvents(sequence);

      expect(events.length, sequence.length);
      expect(events.first.type, 'lottery');
      expect(events.first.delayMs, 500);
      expect(events.first.data['description'], 'くじ引き中...');
    });
  });
}
