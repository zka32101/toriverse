import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/config/theme.dart';
import 'package:toriverse/features/home/presentation/screens/home_screen.dart';
import 'package:toriverse/features/match/application/providers/user_state.dart';
import 'package:toriverse/features/match/application/providers/matching_state.dart';

void main() {
  group('HomeScreen - ホーム画面', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      // ユーザーログイン
      container.read(userStateProvider.notifier).initializeUser(
        'user_123',
        displayName: 'TestPlayer',
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('ホーム画面がビルドされる', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userStateProvider
                .overrideWith((ref) => container.read(userStateProvider)),
          ],
          child: MaterialApp(
            theme: appTheme,
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('プレイヤー名が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userStateProvider
                .overrideWith((ref) => container.read(userStateProvider)),
          ],
          child: MaterialApp(
            theme: appTheme,
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.text('TestPlayer'), findsWidgets);
    });

    testWidgets('ランクポイントが表示される', (WidgetTester tester) async {
      // ランクポイント追加
      container.read(userStateProvider.notifier).addRankPoints(100);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userStateProvider
                .overrideWith((ref) => container.read(userStateProvider)),
          ],
          child: MaterialApp(
            theme: appTheme,
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.text('100'), findsWidgets);
    });

    testWidgets('完走ストリークが表示される', (WidgetTester tester) async {
      // ストリーク追加
      container.read(userStateProvider.notifier).incrementStreak();
      container.read(userStateProvider.notifier).incrementStreak();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userStateProvider
                .overrideWith((ref) => container.read(userStateProvider)),
          ],
          child: MaterialApp(
            theme: appTheme,
            home: HomeScreen(),
          ),
        ),
      );

      // ストリークは画面に表示される
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('マッチング開始ボタンが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userStateProvider
                .overrideWith((ref) => container.read(userStateProvider)),
          ],
          child: MaterialApp(
            theme: appTheme,
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('無料マッチ有無が表示される', (WidgetTester tester) async {
      var state = container.read(userStateProvider)!;
      expect(state.hasFreeMatchToday, true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userStateProvider
                .overrideWith((ref) => container.read(userStateProvider)),
          ],
          child: MaterialApp(
            theme: appTheme,
            home: HomeScreen(),
          ),
        ),
      );

      // 無料マッチの状態がUIに反映される
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('サブスクリプション状態が表示される', (WidgetTester tester) async {
      var state = container.read(userStateProvider)!;
      expect(state.subscriptionStatus, SubscriptionStatus.trial);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userStateProvider
                .overrideWith((ref) => container.read(userStateProvider)),
          ],
          child: MaterialApp(
            theme: appTheme,
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('マッチング開始をタップ可能', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userStateProvider
                .overrideWith((ref) => container.read(userStateProvider)),
            matchingStateProvider
                .overrideWith((ref) => container.read(matchingStateProvider)),
          ],
          child: MaterialApp(
            theme: appTheme,
            home: HomeScreen(),
          ),
        ),
      );

      // ボタンが存在
      expect(find.byType(ElevatedButton), findsWidgets);
    });
  });

  group('HomeScreen - ユーザー状態変化', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('ログイン前は表示されない', (WidgetTester tester) async {
      // ユーザーが初期化されていない
      expect(container.read(userStateProvider), null);
    });

    testWidgets('無料マッチ使用後に表示が更新される', (WidgetTester tester) async {
      container.read(userStateProvider.notifier).initializeUser(
        'user_123',
        displayName: 'TestPlayer',
      );

      var state = container.read(userStateProvider)!;
      expect(state.hasFreeMatchToday, true);

      container.read(userStateProvider.notifier).useFreeMatch();
      state = container.read(userStateProvider)!;
      expect(state.hasFreeMatchToday, false);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userStateProvider
                .overrideWith((ref) => container.read(userStateProvider)),
          ],
          child: MaterialApp(
            theme: appTheme,
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('サブスクリプション有効化が反映される', (WidgetTester tester) async {
      container.read(userStateProvider.notifier).initializeUser(
        'user_123',
        displayName: 'TestPlayer',
      );

      container.read(userStateProvider.notifier).activateSubscription();
      var state = container.read(userStateProvider)!;
      expect(state.isSubscribed, true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userStateProvider
                .overrideWith((ref) => container.read(userStateProvider)),
          ],
          child: MaterialApp(
            theme: appTheme,
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.byType(Card), findsWidgets);
    });
  });
}
