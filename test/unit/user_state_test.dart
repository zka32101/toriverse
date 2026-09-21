import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/match/application/providers/user_state.dart';

void main() {
  group('UserStateNotifier - ユーザー管理', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('初期状態は null', () {
      final state = container.read(userStateProvider);
      expect(state, null);
    });

    test('ユーザーを初期化', () {
      container.read(userStateProvider.notifier).initializeUser(
        'user_123',
        displayName: 'TestPlayer',
      );

      final state = container.read(userStateProvider);
      expect(state, isNotNull);
      expect(state!.uid, 'user_123');
      expect(state.displayName, 'TestPlayer');
      expect(state.rankPoints, 0);
      expect(state.completedMatchStreak, 0);
    });

    test('デフォルト表示名が生成される', () {
      container.read(userStateProvider.notifier).initializeUser('user_456');

      final state = container.read(userStateProvider);
      expect(state!.displayName, 'Player_user_456');
    });

    test('ランクポイントを加算', () {
      container
          .read(userStateProvider.notifier)
          .initializeUser('user_123');

      container.read(userStateProvider.notifier).addRankPoints(50);
      final state1 = container.read(userStateProvider);
      expect(state1!.rankPoints, 50);

      container.read(userStateProvider.notifier).addRankPoints(30);
      final state2 = container.read(userStateProvider);
      expect(state2!.rankPoints, 80);
    });

    test('完走ストリークをインクリメント', () {
      container
          .read(userStateProvider.notifier)
          .initializeUser('user_123');

      container.read(userStateProvider.notifier).incrementStreak();
      final state1 = container.read(userStateProvider);
      expect(state1!.completedMatchStreak, 1);
      expect(state1.lastPlayedAt, isNotNull);

      container.read(userStateProvider.notifier).incrementStreak();
      final state2 = container.read(userStateProvider);
      expect(state2!.completedMatchStreak, 2);
    });

    test('完走ストリークをリセット', () {
      container
          .read(userStateProvider.notifier)
          .initializeUser('user_123');

      container.read(userStateProvider.notifier).incrementStreak();
      container.read(userStateProvider.notifier).incrementStreak();
      final state1 = container.read(userStateProvider);
      expect(state1!.completedMatchStreak, 2);

      container.read(userStateProvider.notifier).resetStreak();
      final state2 = container.read(userStateProvider);
      expect(state2!.completedMatchStreak, 0);
    });

    test('本日の無料マッチを使用', () {
      container
          .read(userStateProvider.notifier)
          .initializeUser('user_123');

      final state1 = container.read(userStateProvider);
      expect(state1!.freeMatchUsedToday, 0);
      expect(state1.hasFreeMatchToday, true);

      container.read(userStateProvider.notifier).useFreeMatch();
      final state2 = container.read(userStateProvider);
      expect(state2!.freeMatchUsedToday, 1);
      expect(state2.hasFreeMatchToday, false);
    });

    test('本日の無料マッチをリセット', () {
      container
          .read(userStateProvider.notifier)
          .initializeUser('user_123');

      container.read(userStateProvider.notifier).useFreeMatch();
      final state1 = container.read(userStateProvider);
      expect(state1!.hasFreeMatchToday, false);

      container.read(userStateProvider.notifier).resetDailyFreeMatch();
      final state2 = container.read(userStateProvider);
      expect(state2!.freeMatchUsedToday, 0);
      expect(state2.hasFreeMatchToday, true);
    });

    test('サブスクリプションを有効化', () {
      container
          .read(userStateProvider.notifier)
          .initializeUser('user_123');

      final state1 = container.read(userStateProvider);
      expect(state1!.subscriptionStatus, SubscriptionStatus.trial);
      expect(state1.isSubscribed, false);

      container.read(userStateProvider.notifier).activateSubscription();
      final state2 = container.read(userStateProvider);
      expect(state2!.subscriptionStatus, SubscriptionStatus.active);
      expect(state2.isSubscribed, true);
    });

    test('サブスクリプションをキャンセル', () {
      container
          .read(userStateProvider.notifier)
          .initializeUser('user_123');

      container.read(userStateProvider.notifier).activateSubscription();
      final state1 = container.read(userStateProvider);
      expect(state1!.isSubscribed, true);

      container.read(userStateProvider.notifier).cancelSubscription();
      final state2 = container.read(userStateProvider);
      expect(state2!.subscriptionStatus, SubscriptionStatus.cancelled);
      expect(state2.isSubscribed, false);
    });

    test('ユーザーをログアウト', () {
      container
          .read(userStateProvider.notifier)
          .initializeUser('user_123');

      var state = container.read(userStateProvider);
      expect(state, isNotNull);

      container.read(userStateProvider.notifier).logout();
      state = container.read(userStateProvider);
      expect(state, null);
    });
  });

  group('UserStateNotifier - Provider 依存', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      container.read(userStateProvider.notifier).initializeUser(
        'user_123',
        displayName: 'TestPlayer',
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('userUidProvider がUID を返す', () {
      final uid = container.read(userUidProvider);
      expect(uid, 'user_123');
    });

    test('userDisplayNameProvider が表示名を返す', () {
      final name = container.read(userDisplayNameProvider);
      expect(name, 'TestPlayer');
    });

    test('rankPointsProvider がランクポイントを返す', () {
      container.read(userStateProvider.notifier).addRankPoints(100);
      final points = container.read(rankPointsProvider);
      expect(points, 100);
    });

    test('streakProvider がストリークを返す', () {
      container.read(userStateProvider.notifier).incrementStreak();
      container.read(userStateProvider.notifier).incrementStreak();
      final streak = container.read(streakProvider);
      expect(streak, 2);
    });

    test('hasFreeMatchProvider が無料マッチ有無を返す', () {
      var hasMatch = container.read(hasFreeMatchProvider);
      expect(hasMatch, true);

      container.read(userStateProvider.notifier).useFreeMatch();
      hasMatch = container.read(hasFreeMatchProvider);
      expect(hasMatch, false);
    });

    test('isSubscribedProvider がサブスクリプション状態を返す', () {
      var isSubscribed = container.read(isSubscribedProvider);
      expect(isSubscribed, false);

      container.read(userStateProvider.notifier).activateSubscription();
      isSubscribed = container.read(isSubscribedProvider);
      expect(isSubscribed, true);
    });

    test('isLoggedInProvider がログイン状態を返す', () {
      var isLoggedIn = container.read(isLoggedInProvider);
      expect(isLoggedIn, true);

      container.read(userStateProvider.notifier).logout();
      isLoggedIn = container.read(isLoggedInProvider);
      expect(isLoggedIn, false);
    });
  });
}
