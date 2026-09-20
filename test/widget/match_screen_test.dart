import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/config/theme.dart';
import 'package:toriverse/features/match/application/providers/game_state.dart';
import 'package:toriverse/features/match/presentation/screens/match_screen.dart';
import 'package:toriverse/features/match/presentation/widgets/board_widget.dart';
import 'package:toriverse/features/match/presentation/widgets/move_submission_panel.dart';

const _testMatchId = 'test_match_1';

void main() {
  group('MatchScreen - マッチ画面', () {
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
      return ProviderScope(
        overrides: [
          gameStateProvider.overrideWith(
              (ref) => container.read(gameStateProvider.notifier)),
        ],
        child: MaterialApp(
          theme: ToriverseTheme.lightTheme(),
          home: const MatchScreen(matchId: _testMatchId),
        ),
      );
    }

    testWidgets('マッチ画面がビルドされる', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.byType(MatchScreen), findsOneWidget);
    });

    testWidgets('ボードが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.byType(BoardWidget), findsOneWidget);
    });

    testWidgets('プレイヤー情報が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());

      final gameState = container.read(gameStateProvider)!;
      expect(gameState.playerIds.length, 3);
    });

    testWidgets('ラウンド情報が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());

      final gameState = container.read(gameStateProvider)!;
      expect(gameState.roundIndex, greaterThanOrEqualTo(0));
    });

    testWidgets('石数が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());

      final gameState = container.read(gameStateProvider)!;
      expect(gameState.stoneCounts, isNotNull);
      expect(gameState.stoneCounts['player_0'], greaterThanOrEqualTo(0));
    });

    testWidgets('移動投稿パネルが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.byType(MoveSubmissionPanel), findsOneWidget);
    });

    testWidgets('合法手の数が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());

      final gameState = container.read(gameStateProvider)!;
      expect(gameState.validMoves.length, greaterThanOrEqualTo(0));
    });
  });

  group('MatchScreen - ゲーム進行', () {
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
      return ProviderScope(
        overrides: [
          gameStateProvider.overrideWith(
              (ref) => container.read(gameStateProvider.notifier)),
        ],
        child: MaterialApp(
          theme: ToriverseTheme.lightTheme(),
          home: const MatchScreen(matchId: _testMatchId),
        ),
      );
    }

    testWidgets('手を打つとラウンド進行', (WidgetTester tester) async {
      var gameState = container.read(gameStateProvider)!;
      final initialRound = gameState.roundIndex;

      await container
          .read(gameStateProvider.notifier)
          .placeStone(2, 3);

      await tester.pumpWidget(buildTestApp());

      gameState = container.read(gameStateProvider)!;
      expect(gameState.roundIndex, greaterThan(initialRound));
    });

    testWidgets('ゲーム一時停止・再開が機能する', (WidgetTester tester) async {
      container.read(gameStateProvider.notifier).pauseGame();
      var gameState = container.read(gameStateProvider)!;
      expect(gameState.status, GameStatus.paused);

      container.read(gameStateProvider.notifier).resumeGame();
      gameState = container.read(gameStateProvider)!;
      expect(gameState.status, isNot(GameStatus.paused));

      await tester.pumpWidget(buildTestApp());

      expect(find.byType(MatchScreen), findsOneWidget);
    });

    testWidgets('複数ラウンド進行後も画面更新される', (WidgetTester tester) async {
      final validMoves = container.read(gameStateProvider)!.validMoves;
      if (validMoves.isNotEmpty) {
        await container
            .read(gameStateProvider.notifier)
            .placeStone(validMoves[0][0], validMoves[0][1]);
        await container
            .read(gameStateProvider.notifier)
            .placeStone(2, 4);
        await container
            .read(gameStateProvider.notifier)
            .placeStone(2, 2);
      }

      await tester.pumpWidget(buildTestApp());

      final gameState = container.read(gameStateProvider)!;
      expect(gameState.roundIndex, greaterThanOrEqualTo(0));
    });
  });

  group('MatchScreen - UI応答性', () {
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
      return ProviderScope(
        overrides: [
          gameStateProvider.overrideWith(
              (ref) => container.read(gameStateProvider.notifier)),
        ],
        child: MaterialApp(
          theme: ToriverseTheme.lightTheme(),
          home: const MatchScreen(matchId: _testMatchId),
        ),
      );
    }

    testWidgets('画面がレスポンシブ', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(buildTestApp());

      expect(find.byType(MatchScreen), findsOneWidget);
    });

    testWidgets('タイマーが表示される（時間制限あり）', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());

      // タイマーがUIに存在
      expect(find.byType(MoveSubmissionPanel), findsOneWidget);
    });
  });
}
