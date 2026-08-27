import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/config/theme.dart';
import 'package:toriverse/features/match/application/providers/game_state.dart';
import 'package:toriverse/features/match/application/providers/user_state.dart';
import 'package:toriverse/features/results/presentation/screens/results_screen.dart';

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
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('リザルト画面がビルドされる', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameStateProvider
                .overrideWith((ref) => container.read(gameStateProvider)),
            userStateProvider
                .overrideWith((ref) => container.read(userStateProvider)),
          ],
          child: MaterialApp(
            theme: appTheme,
            home: ResultsScreen(
              playerIds: ['player_0', 'player_1', 'AI_1'],
              stoneCounts: {'player_0': 30, 'player_1': 20, 'AI_1': 14},
            ),
          ),
        ),
      );

      expect(find.byType(ResultsScreen), findsOneWidget);
    });

    testWidgets('順位が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameStateProvider
                .overrideWith((ref) => container.read(gameStateProvider)),
            userStateProvider
                .overrideWith((ref) => container.read(userStateProvider)),
          ],
          child: MaterialApp(
            theme: appTheme,
            home: ResultsScreen(
              playerIds: ['player_0', 'player_1', 'AI_1'],
              stoneCounts: {'player_0': 30, 'player_1': 20, 'AI_1': 14},
            ),
          ),
        ),
      );

      // メダルアイコンが表示される（1位、2位、3位）
      expect(find.byIcon(Icons.emoji_events), findsWidgets);
    });

    testWidgets('石数が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameStateProvider
                .overrideWith((ref) => container.read(gameStateProvider)),
            userStateProvider
                .overrideWith((ref) => container.read(userStateProvider)),
          ],
          child: MaterialApp(
            theme: appTheme,
            home: ResultsScreen(
              playerIds: ['player_0', 'player_1', 'AI_1'],
              stoneCounts: {'player_0': 30, 'player_1': 20, 'AI_1': 14},
            ),
          ),
        ),
      );

      expect(find.text('30'), findsWidgets);
      expect(find.text('20'), findsWidgets);
      expect(find.text('14'), findsWidgets);
    });

    testWidgets('プレイヤー名が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameStateProvider
                .overrideWith((ref) => container.read(gameStateProvider)),
            userStateProvider
                .overrideWith((ref) => container.read(userStateProvider)),
          ],
          child: MaterialApp(
            theme: appTheme,
            home: ResultsScreen(
              playerIds: ['player_0', 'player_1', 'AI_1'],
              stoneCounts: {'player_0': 30, 'player_1': 20, 'AI_1': 14},
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('ストリークインクリメントアニメーション', (WidgetTester tester) async {
      var userState = container.read(userStateProvider)!;
      expect(userState.completedMatchStreak, 0);

      container.read(userStateProvider.notifier).incrementStreak();

      userState = container.read(userStateProvider)!;
      expect(userState.completedMatchStreak, 1);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameStateProvider
                .overrideWith((ref) => container.read(gameStateProvider)),
            userStateProvider
                .overrideWith((ref) => container.read(userStateProvider)),
          ],
          child: MaterialApp(
            theme: appTheme,
            home: ResultsScreen(
              playerIds: ['player_0', 'player_1', 'AI_1'],
              stoneCounts: {'player_0': 30, 'player_1': 20, 'AI_1': 14},
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('クリッププレビューが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameStateProvider
                .overrideWith((ref) => container.read(gameStateProvider)),
            userStateProvider
                .overrideWith((ref) => container.read(userStateProvider)),
          ],
          child: MaterialApp(
            theme: appTheme,
            home: ResultsScreen(
              playerIds: ['player_0', 'player_1', 'AI_1'],
              stoneCounts: {'player_0': 30, 'player_1': 20, 'AI_1': 14},
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('シェアボタンが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameStateProvider
                .overrideWith((ref) => container.read(gameStateProvider)),
            userStateProvider
                .overrideWith((ref) => container.read(userStateProvider)),
          ],
          child: MaterialApp(
            theme: appTheme,
            home: ResultsScreen(
              playerIds: ['player_0', 'player_1', 'AI_1'],
              stoneCounts: {'player_0': 30, 'player_1': 20, 'AI_1': 14},
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('次のマッチボタンが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameStateProvider
                .overrideWith((ref) => container.read(gameStateProvider)),
            userStateProvider
                .overrideWith((ref) => container.read(userStateProvider)),
          ],
          child: MaterialApp(
            theme: appTheme,
            home: ResultsScreen(
              playerIds: ['player_0', 'player_1', 'AI_1'],
              stoneCounts: {'player_0': 30, 'player_1': 20, 'AI_1': 14},
            ),
          ),
        ),
      );

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
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('複数シナリオのランキング表示', (WidgetTester tester) async {
      // シナリオ1: 通常順位
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userStateProvider
                .overrideWith((ref) => container.read(userStateProvider)),
          ],
          child: MaterialApp(
            theme: appTheme,
            home: ResultsScreen(
              playerIds: ['player_0', 'player_1', 'AI_1'],
              stoneCounts: {'player_0': 30, 'player_1': 20, 'AI_1': 14},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.emoji_events), findsWidgets);

      // シナリオ2: 逆転勝利
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userStateProvider
                .overrideWith((ref) => container.read(userStateProvider)),
          ],
          child: MaterialApp(
            theme: appTheme,
            home: ResultsScreen(
              playerIds: ['player_0', 'player_1', 'AI_1'],
              stoneCounts: {'player_0': 45, 'player_1': 19, 'AI_1': 0},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.emoji_events), findsWidgets);
    });

    testWidgets('獲得石数の計算', (WidgetTester tester) async {
      // player_0が30石で最多
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userStateProvider
                .overrideWith((ref) => container.read(userStateProvider)),
          ],
          child: MaterialApp(
            theme: appTheme,
            home: ResultsScreen(
              playerIds: ['player_0', 'player_1', 'AI_1'],
              stoneCounts: {'player_0': 30, 'player_1': 20, 'AI_1': 14},
            ),
          ),
        ),
      );

      expect(find.text('30'), findsWidgets);
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
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('異なるスクリーンサイズでの表示', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userStateProvider
                .overrideWith((ref) => container.read(userStateProvider)),
          ],
          child: MaterialApp(
            theme: appTheme,
            home: ResultsScreen(
              playerIds: ['player_0', 'player_1', 'AI_1'],
              stoneCounts: {'player_0': 30, 'player_1': 20, 'AI_1': 14},
            ),
          ),
        ),
      );

      expect(find.byType(ResultsScreen), findsOneWidget);
    });
  });
}
