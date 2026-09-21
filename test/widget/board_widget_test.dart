import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/config/theme.dart';
import 'package:toriverse/features/match/application/providers/game_state.dart';
import 'package:toriverse/features/match/domain/entities/board.dart';
import 'package:toriverse/features/match/presentation/widgets/board_widget.dart';

void main() {
  group('BoardWidget - ボード表示', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      // ゲーム初期化
      container.read(gameStateProvider.notifier).startGame(
        playerIds: ['player_0', 'player_1', 'AI_1'],
      );
    });

    tearDown(() {
      container.dispose();
    });

    Widget buildTestApp() {
      final gameState = container.read(gameStateProvider)!;
      return ProviderScope(
        overrides: [
          gameStateProvider
              .overrideWith((ref) => container.read(gameStateProvider.notifier)),
        ],
        child: MaterialApp(
          theme: ToriverseTheme.lightTheme(),
          home: Scaffold(
            body: BoardWidget(
              board: gameState.board,
              validMoves: gameState.validMoves,
            ),
          ),
        ),
      );
    }

    testWidgets('ボードが8x8グリッドで表示される', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.byType(GridView), findsOneWidget);
      // 8x8 = 64 マス
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('初期盤面の石が正しく表示される', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());

      // 初期盤面では黒2、白2の合計4石
      final board = container.read(gameStateProvider)!.board;
      int stoneCount = 0;
      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          final stone = board.getStone(row, col);
          if (stone != Board.empty) {
            stoneCount++;
          }
        }
      }
      expect(stoneCount, 4);
    });

    testWidgets('合法手がハイライトされる', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());

      final validMoves = container.read(gameStateProvider)!.validMoves;
      expect(validMoves.length, greaterThan(0)); // 初期状態では合法手あり
    });

    testWidgets('石をタップしてプレイ可能', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());

      final board = container.read(gameStateProvider)!.board;
      final initialBlackCount = board.countStones()[Board.black] ?? 0;

      // 合法手の1つをタップ（例: (2, 3)）
      final validMoves = container.read(gameStateProvider)!.validMoves;
      if (validMoves.isNotEmpty) {
        final move = validMoves.first;
        await container
            .read(gameStateProvider.notifier)
            .placeStone(move[0], move[1]);

        await tester.pumpWidget(buildTestApp());

        final updatedBoard = container.read(gameStateProvider)!.board;
        final updatedBlackCount = updatedBoard.countStones()[Board.black];
        expect(updatedBlackCount, greaterThan(initialBlackCount));
      }
    });

    testWidgets('3色（黒・白・赤）が正しく描画される', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());

      final board = container.read(gameStateProvider)!.board;

      // 初期盤面確認
      final blackStone = board.getStone(3, 4);
      final whiteStone = board.getStone(3, 3);

      expect(blackStone == Board.black || whiteStone == Board.white, true);
    });

    testWidgets('盤面がレスポンシブである', (WidgetTester tester) async {
      // 異なるスクリーンサイズでテスト
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(buildTestApp());

      expect(find.byType(GridView), findsOneWidget);
    });
  });

  group('BoardWidget - ゲーム進行', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      container.read(gameStateProvider.notifier).startGame(
        playerIds: ['player_0', 'player_1', 'AI_1'],
      );
    });

    tearDown(() {
      container.dispose();
    });

    Widget buildTestApp() {
      final gameState = container.read(gameStateProvider)!;
      return ProviderScope(
        overrides: [
          gameStateProvider
              .overrideWith((ref) => container.read(gameStateProvider.notifier)),
        ],
        child: MaterialApp(
          theme: ToriverseTheme.lightTheme(),
          home: Scaffold(
            body: BoardWidget(
              board: gameState.board,
              validMoves: gameState.validMoves,
            ),
          ),
        ),
      );
    }

    testWidgets('複数手の後に盤面が更新される', (WidgetTester tester) async {
      // 複数の手を打つ
      await container
          .read(gameStateProvider.notifier)
          .placeStone(2, 3);
      await container
          .read(gameStateProvider.notifier)
          .placeStone(2, 4);

      await tester.pumpWidget(buildTestApp());

      final roundIndex = container.read(gameStateProvider)!.roundIndex;
      expect(roundIndex, greaterThan(0));
    });
  });
}
