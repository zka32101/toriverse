import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/match/domain/entities/board.dart';
import 'package:toriverse/features/match/domain/services/rivalry_tracker.dart';

void main() {
  group('RivalryTracker - computeAttackBreakdown', () {
    test('黒が白1枚を挟んだ場合の内訳を計算する', () {
      final grid = List.generate(8, (_) => List.filled(8, Board.empty));
      grid[3][1] = Board.black;
      grid[3][2] = Board.white;
      final before = Board.fromGrid(grid);

      final after = before.clone();
      after.placeStone(3, 3, Board.black);

      final breakdown = RivalryTracker.computeAttackBreakdown(
        boardBefore: before,
        boardAfter: after,
        mover: Board.black,
      );

      expect(breakdown[Board.white], 1);
      expect(breakdown[Board.red], isNull);
    });

    test('赤が白と黒を同時に挟んだ場合、両方が内訳に含まれる', () {
      final grid = List.generate(8, (_) => List.filled(8, Board.empty));
      // 横方向: 赤 - 白 - (置く場所)
      grid[3][1] = Board.red;
      grid[3][2] = Board.white;
      // 縦方向: 赤 - 黒 - (置く場所と同じマスに縦から到達)
      grid[1][3] = Board.red;
      grid[2][3] = Board.black;
      final before = Board.fromGrid(grid);

      final after = before.clone();
      after.placeStone(3, 3, Board.red);

      final breakdown = RivalryTracker.computeAttackBreakdown(
        boardBefore: before,
        boardAfter: after,
        mover: Board.red,
      );

      expect(breakdown[Board.white], 1);
      expect(breakdown[Board.black], 1);
    });

    test('反転が発生しなければ空の内訳を返す', () {
      final board = Board.initial();
      final breakdown = RivalryTracker.computeAttackBreakdown(
        boardBefore: board,
        boardAfter: board.clone(),
        mover: Board.black,
      );

      expect(breakdown, isEmpty);
    });
  });

  group('RivalryTracker - aggregateRivalryScores', () {
    test('複数ラウンドの攻撃内訳を累積集計する', () {
      final rounds = [
        {
          Board.black: {Board.red: 2},
        },
        {
          Board.black: {Board.red: 1},
          Board.white: {Board.red: 3},
        },
      ];

      final scores = RivalryTracker.aggregateRivalryScores(rounds);

      expect(scores[Board.black]?[Board.red], 3);
      expect(scores[Board.white]?[Board.red], 3);
    });

    test('windowRounds を超える古いラウンドは切り捨てられる', () {
      final rounds = [
        {
          Board.black: {Board.red: 100}, // 古すぎるので無視される
        },
        {
          Board.black: {Board.red: 1},
        },
        {
          Board.black: {Board.red: 1},
        },
      ];

      final scores = RivalryTracker.aggregateRivalryScores(
        rounds,
        windowRounds: 2,
      );

      expect(scores[Board.black]?[Board.red], 2);
    });

    test('空リストに対しては空マップを返す', () {
      final scores = RivalryTracker.aggregateRivalryScores([]);
      expect(scores, isEmpty);
    });
  });

  group('RivalryTracker - getTopAggressorsAgainst', () {
    test('最多攻撃者を1人特定する', () {
      final scores = {
        Board.black: {Board.red: 3},
        Board.white: {Board.red: 1},
      };

      final top = RivalryTracker.getTopAggressorsAgainst(scores, Board.red);
      expect(top, [Board.black]);
    });

    test('同点の場合は複数の攻撃者を返す', () {
      final scores = {
        Board.black: {Board.red: 2},
        Board.white: {Board.red: 2},
      };

      final top = RivalryTracker.getTopAggressorsAgainst(scores, Board.red);
      expect(top, containsAll([Board.black, Board.white]));
      expect(top.length, 2);
    });

    test('攻撃実績がなければ空リストを返す', () {
      final top = RivalryTracker.getTopAggressorsAgainst({}, Board.red);
      expect(top, isEmpty);
    });
  });

  group('RivalryTracker - isDoubleTargeted', () {
    test('2人から攻撃されていれば二強連合と判定する', () {
      final scores = {
        Board.black: {Board.red: 1},
        Board.white: {Board.red: 1},
      };

      final result = RivalryTracker.isDoubleTargeted(
        scores,
        Board.red,
        [Board.black, Board.white, Board.red],
      );

      expect(result, true);
    });

    test('1人からの攻撃のみでは二強連合と判定しない', () {
      final scores = {
        Board.black: {Board.red: 5},
      };

      final result = RivalryTracker.isDoubleTargeted(
        scores,
        Board.red,
        [Board.black, Board.white, Board.red],
      );

      expect(result, false);
    });

    test('minAttacksEach 閾値未満の攻撃はカウントしない', () {
      final scores = {
        Board.black: {Board.red: 1},
        Board.white: {Board.red: 1},
      };

      final result = RivalryTracker.isDoubleTargeted(
        scores,
        Board.red,
        [Board.black, Board.white, Board.red],
        minAttacksEach: 2,
      );

      expect(result, false);
    });
  });
}
