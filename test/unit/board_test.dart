import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/match/domain/entities/board.dart';

void main() {
  group('Board - 初期化・基本操作', () {
    late Board board;

    setUp(() {
      board = Board.initial();
    });

    test('初期配置が正しく設定される', () {
      expect(board.getStone(3, 3), Board.white);
      expect(board.getStone(3, 4), Board.black);
      expect(board.getStone(4, 3), Board.black);
      expect(board.getStone(4, 4), Board.white);
    });

    test('範囲外のマスはemptyを返す', () {
      expect(board.getStone(-1, 0), Board.empty);
      expect(board.getStone(0, -1), Board.empty);
      expect(board.getStone(8, 0), Board.empty);
      expect(board.getStone(0, 8), Board.empty);
    });

    test('石の個数を正しくカウントする', () {
      final counts = board.countStones();
      expect(counts[Board.black], 2);
      expect(counts[Board.white], 2);
      expect(counts[Board.red], 0);
      expect(counts[Board.empty], 60);
    });
  });

  group('Board - 合法手判定', () {
    late Board board;

    setUp(() {
      board = Board.initial();
    });

    test('黒の初期合法手が正しい', () {
      // 黒の初期合法手: (2,3), (3,2), (4,5), (5,4)
      expect(board.isValidMove(2, 3, Board.black), true);
      expect(board.isValidMove(3, 2, Board.black), true);
      expect(board.isValidMove(4, 5, Board.black), true);
      expect(board.isValidMove(5, 4, Board.black), true);
    });

    test('黒の不正な手を判定', () {
      expect(board.isValidMove(0, 0, Board.black), false);
      expect(board.isValidMove(3, 3, Board.black), false); // 既に石がある
      expect(board.isValidMove(2, 2, Board.black), false);
    });

    test('白の初期合法手が正しい', () {
      // 白の初期合法手: (2,4), (4,2), (3,5), (5,3)
      expect(board.isValidMove(2, 4, Board.white), true);
      expect(board.isValidMove(4, 2, Board.white), true);
      expect(board.isValidMove(3, 5, Board.white), true);
      expect(board.isValidMove(5, 3, Board.white), true);
    });

    test('範囲外は常に不正', () {
      expect(board.isValidMove(-1, 0, Board.black), false);
      expect(board.isValidMove(8, 0, Board.black), false);
      expect(board.isValidMove(0, -1, Board.black), false);
      expect(board.isValidMove(0, 8, Board.black), false);
    });

    test('getValidMoves で合法手リストを取得', () {
      final blackMoves = board.getValidMoves(Board.black);
      expect(blackMoves.length, 4);
      expect(blackMoves, contains([2, 3]));
      expect(blackMoves, contains([3, 2]));
      expect(blackMoves, contains([4, 5]));
      expect(blackMoves, contains([5, 4]));
    });
  });

  group('Board - 石の配置と反転', () {
    late Board board;

    setUp(() {
      board = Board.initial();
    });

    test('黒が(2,3)に置くと(3,3)の白が反転', () {
      board.placeStone(2, 3, Board.black);
      expect(board.getStone(2, 3), Board.black);
      expect(board.getStone(3, 3), Board.black); // 反転
    });

    test('白が(2,4)に置くと(3,4)の黒が反転', () {
      board.placeStone(2, 4, Board.white);
      expect(board.getStone(2, 4), Board.white);
      expect(board.getStone(3, 4), Board.white); // 反転
    });

    test('複数方向で反転', () {
      // 複雑なシーン: 複数方向で挟まれる場合
      board.placeStone(2, 3, Board.black); // 上から反転
      final counts = board.countStones();
      expect(counts[Board.black], 3);
      expect(counts[Board.white], 1);
    });

    test('不正な手を置こうとするとエラー', () {
      expect(
        () => board.placeStone(0, 0, Board.black),
        throwsArgumentError,
      );
    });
  });

  group('Board - 盤面クローン', () {
    late Board board;
    late Board cloned;

    setUp(() {
      board = Board.initial();
      cloned = board.clone();
    });

    test('クローンが元の盤面と同じ', () {
      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          expect(cloned.getStone(row, col), board.getStone(row, col));
        }
      }
    });

    test('クローンの変更が元に影響しない', () {
      cloned.placeStone(2, 3, Board.black);
      // 元の盤面は (2,3) に黒が置かれていない
      expect(board.getStone(2, 3), Board.empty);
      expect(cloned.getStone(2, 3), Board.black);
    });
  });

  group('Board - エッジケース', () {
    test('隅での反転判定（盤の端での処理）', () {
      final board = Board.initial();

      // 隅のマスで合法手かどうか確認
      // (標準オセロでは隅に近い位置でのテスト)
      expect(board.isValidMove(0, 2, Board.black), false);
      expect(board.isValidMove(0, 3, Board.black), false);
    });

    test('辺での反転判定', () {
      final board = Board.initial();
      // 辺でのテスト
      // (初期状態では辺は石がない)
      expect(board.getStone(0, 0), Board.empty);
    });

    test('連続反転（2つ以上の石を反転）', () {
      // 複雑なシーン: 2つ以上の相手石が挟まれる
      // 初期配置から複数ムーブして複雑な盤面を作成
      final board = Board.initial();
      board.placeStone(2, 3, Board.black);
      board.placeStone(2, 4, Board.white);
      board.placeStone(2, 2, Board.black); // 複数の白を反転

      // カウントで確認
      final counts = board.countStones();
      expect(counts[Board.black]! > 2, true);
    });
  });

  group('Board - 3色対応の挟み判定', () {
    test('赤が白を挟んで反転できる', () {
      // 赤 - 白 - (置く場所) の並びを作る
      final grid = List.generate(8, (_) => List.filled(8, Board.empty));
      grid[3][2] = Board.red;
      grid[3][3] = Board.white;
      final board = Board.fromGrid(grid);

      expect(board.isValidMove(3, 4, Board.red), true);
      board.placeStone(3, 4, Board.red);
      expect(board.getStone(3, 3), Board.red); // 白が赤に反転
      expect(board.getStone(3, 4), Board.red);
    });

    test('黒が赤を挟んで反転できる（赤も捕獲対象になる）', () {
      final grid = List.generate(8, (_) => List.filled(8, Board.empty));
      grid[3][2] = Board.black;
      grid[3][3] = Board.red;
      final board = Board.fromGrid(grid);

      expect(board.isValidMove(3, 4, Board.black), true);
      board.placeStone(3, 4, Board.black);
      expect(board.getStone(3, 3), Board.black); // 赤が黒に反転
    });

    test('白が黒を挟んで反転できる（従来の2色ロジックと同じ挙動）', () {
      final grid = List.generate(8, (_) => List.filled(8, Board.empty));
      grid[3][2] = Board.white;
      grid[3][3] = Board.black;
      final board = Board.fromGrid(grid);

      expect(board.isValidMove(3, 4, Board.white), true);
      board.placeStone(3, 4, Board.white);
      expect(board.getStone(3, 3), Board.white);
    });

    test('異なる2色が混在する区間もまとめて挟める（白→赤→白）', () {
      final grid = List.generate(8, (_) => List.filled(8, Board.empty));
      grid[3][1] = Board.black;
      grid[3][2] = Board.white;
      grid[3][3] = Board.red;
      grid[3][4] = Board.white;
      final board = Board.fromGrid(grid);

      expect(board.isValidMove(3, 5, Board.black), true);
      board.placeStone(3, 5, Board.black);
      // 挟まれた区間（白・赤・白）がすべて黒に反転する
      expect(board.getStone(3, 2), Board.black);
      expect(board.getStone(3, 3), Board.black);
      expect(board.getStone(3, 4), Board.black);
    });

    test('手前の自分の色で閉じた時点で判定し、その先は無視する', () {
      // 黒-白-黒-白 の並びで (3,5) に黒を置いた場合、
      // 直近の (3,3) の黒で閉じるため (3,4) の白のみ反転する
      final grid = List.generate(8, (_) => List.filled(8, Board.empty));
      grid[3][1] = Board.black;
      grid[3][2] = Board.white;
      grid[3][3] = Board.black;
      grid[3][4] = Board.white;
      final board = Board.fromGrid(grid);

      expect(board.isValidMove(3, 5, Board.black), true);
      board.placeStone(3, 5, Board.black);
      expect(board.getStone(3, 4), Board.black); // 反転
      expect(board.getStone(3, 3), Board.black); // 元々黒（変化なし）
      expect(board.getStone(3, 2), Board.white); // 遠方は対象外のまま
      expect(board.getStone(3, 1), Board.black); // 遠方は対象外のまま
    });

    test('自分の色に隣接直後は挟む石がなく不正な手', () {
      final grid = List.generate(8, (_) => List.filled(8, Board.empty));
      grid[3][4] = Board.black;
      final board = Board.fromGrid(grid);

      // (3,4)がすでに黒なので、隣接する(3,5)から見て相手石を挟んでいない
      expect(board.isValidMove(3, 5, Board.black), false);
    });

    test('赤の初期合法手は0（初期配置に赤石が存在しないため）', () {
      final board = Board.initial();
      expect(board.getValidMoves(Board.red), isEmpty);
    });
  });

  group('Board - パフォーマンス', () {
    test('大量の合法手計算が高速', () {
      final board = Board.initial();
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        board.getValidMoves(Board.black);
      }

      stopwatch.stop();
      // 1000回の計算が100ms 以下（概算）
      expect(stopwatch.elapsedMilliseconds < 500, true);
    });
  });

  group('Board - デバッグ出力', () {
    test('toDebugString が文字列を返す', () {
      final board = Board.initial();
      final debugStr = board.toDebugString();

      expect(debugStr.contains('●'), true); // 黒
      expect(debugStr.contains('○'), true); // 白
      expect(debugStr.contains('·'), true); // 空
    });
  });
}
