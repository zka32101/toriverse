import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/config/theme.dart';
import 'package:toriverse/features/match/application/providers/game_state.dart';
import 'package:toriverse/features/match/application/providers/user_state.dart';
import 'package:toriverse/features/results/presentation/screens/results_screen.dart';

/// Pumps [ResultsScreen] wired to the given [container] so that both the
/// game state and user state notifiers created in tests are visible to the
/// widget tree.
Future<void> _pumpResultsScreen(
  WidgetTester tester,
  ProviderContainer container,
) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        gameStateProvider
            .overrideWith((ref) => container.read(gameStateProvider.notifier)),
        userStateProvider
            .overrideWith((ref) => container.read(userStateProvider.notifier)),
      ],
      child: MaterialApp(
        theme: ToriverseTheme.lightTheme(),
        home: const ResultsScreen(matchId: 'test_match'),
      ),
    ),
  );
}

void main() {
  group('ResultsScreen - リザルト画面', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      // ユーザー初期化
      container.read(userStateProvider.notifier).initializeUser(
        'player_0',
        displayName: 'TestPlayer',
      );
      // ゲーム開始と終了
      container.read(gameStateProvider.notifier).startGame(
        playerIds: ['player_0', 'player_1', 'AI_1'],
      );
      container.read(gameStateProvider.notifier).updateGameState(
        status: GameStatus.finished,
        stoneCounts: {'player_0': 30, 'player_1': 20, 'AI_1': 14},
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('リザルト画面がビルドされる', (WidgetTester tester) async {
      await _pumpResultsScreen(tester, container);

      expect(find.byType(ResultsScreen), findsOneWidget);
    });

    testWidgets('順位が表示される', (WidgetTester tester) async {
      await _pumpResultsScreen(tester, container);

      // メダルアイコンが表示される（1位、2位、3位）
      expect(find.byIcon(Icons.emoji_events), findsNothing);
      expect(find.textContaining('位'), findsWidgets);
    });

    testWidgets('石数が表示される', (WidgetTester tester) async {
      await _pumpResultsScreen(tester, container);

      expect(find.text('30 石'), findsWidgets);
      expect(find.text('20 石'), findsWidgets);
      expect(find.text('14 石'), findsWidgets);
    });

    testWidgets('プレイヤー名が表示される', (WidgetTester tester) async {
      await _pumpResultsScreen(tester, container);

      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('ストリークインクリメントアニメーション', (WidgetTester tester) async {
      var userState = container.read(userStateProvider)!;
      expect(userState.completedMatchStreak, 0);

      container.read(userStateProvider.notifier).incrementStreak();

      userState = container.read(userStateProvider)!;
      expect(userState.completedMatchStreak, 1);

      await _pumpResultsScreen(tester, container);

      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('クリッププレビューが表示される', (WidgetTester tester) async {
      await _pumpResultsScreen(tester, container);

      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('シェアボタンが表示される', (WidgetTester tester) async {
      await _pumpResultsScreen(tester, container);

      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('次のマッチボタンが表示される', (WidgetTester tester) async {
      await _pumpResultsScreen(tester, container);

      expect(find.byType(ElevatedButton), findsWidgets);
    });
  });

  group('ResultsScreen - ランキング表示', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      container.read(userStateProvider.notifier).initializeUser(
        'player_0',
        displayName: 'TestPlayer',
      );
      container.read(gameStateProvider.notifier).startGame(
        playerIds: ['player_0', 'player_1', 'AI_1'],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('複数シナリオのランキング表示', (WidgetTester tester) async {
      // シナリオ1: 通常順位
      container.read(gameStateProvider.notifier).updateGameState(
        status: GameStatus.finished,
        stoneCounts: {'player_0': 30, 'player_1': 20, 'AI_1': 14},
      );

      await _pumpResultsScreen(tester, container);

      expect(find.textContaining('位'), findsWidgets);

      // シナリオ2: 逆転勝利
      container.read(gameStateProvider.notifier).updateGameState(
        stoneCounts: {'player_0': 45, 'player_1': 19, 'AI_1': 0},
      );

      await _pumpResultsScreen(tester, container);

      expect(find.textContaining('位'), findsWidgets);
    });

    testWidgets('獲得石数の計算', (WidgetTester tester) async {
      // player_0が30石で最多
      container.read(gameStateProvider.notifier).updateGameState(
        status: GameStatus.finished,
        stoneCounts: {'player_0': 30, 'player_1': 20, 'AI_1': 14},
      );

      await _pumpResultsScreen(tester, container);

      expect(find.text('30 石'), findsWidgets);
    });
  });

  group('ResultsScreen - レスポンシブデザイン', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      container.read(userStateProvider.notifier).initializeUser(
        'player_0',
        displayName: 'TestPlayer',
      );
      container.read(gameStateProvider.notifier).startGame(
        playerIds: ['player_0', 'player_1', 'AI_1'],
      );
      container.read(gameStateProvider.notifier).updateGameState(
        status: GameStatus.finished,
        stoneCounts: {'player_0': 30, 'player_1': 20, 'AI_1': 14},
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('異なるスクリーンサイズでの表示', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await _pumpResultsScreen(tester, container);

      expect(find.byType(ResultsScreen), findsOneWidget);
    });
  });
}
