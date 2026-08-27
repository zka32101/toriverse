import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ユーザー状態の定義
class UserState {
  final String uid;
  final String? displayName;
  final int rankPoints;
  final int completedMatchStreak;
  final int freeMatchUsedToday;
  final SubscriptionStatus subscriptionStatus;
  final DateTime createdAt;
  final DateTime? lastPlayedAt;

  UserState({
    required this.uid,
    this.displayName,
    required this.rankPoints,
    required this.completedMatchStreak,
    required this.freeMatchUsedToday,
    required this.subscriptionStatus,
    required this.createdAt,
    this.lastPlayedAt,
  });

  /// コピーコンストラクタ
  UserState copyWith({
    String? uid,
    String? displayName,
    int? rankPoints,
    int? completedMatchStreak,
    int? freeMatchUsedToday,
    SubscriptionStatus? subscriptionStatus,
    DateTime? createdAt,
    DateTime? lastPlayedAt,
  }) {
    return UserState(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      rankPoints: rankPoints ?? this.rankPoints,
      completedMatchStreak: completedMatchStreak ?? this.completedMatchStreak,
      freeMatchUsedToday: freeMatchUsedToday ?? this.freeMatchUsedToday,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      createdAt: createdAt ?? this.createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  /// 本日の無料マッチがあるか
  bool get hasFreeMatchToday => freeMatchUsedToday < 1;

  /// サブスクリプション中か
  bool get isSubscribed => subscriptionStatus == SubscriptionStatus.active;
}

/// サブスクリプション状態
enum SubscriptionStatus {
  trial,      // トライアル
  active,     // 購読中
  cancelled,  // キャンセル済み
}

/// User Notifier
class UserStateNotifier extends StateNotifier<UserState?> {
  UserStateNotifier() : super(null);

  /// ユーザーを初期化（新規登録）
  void initializeUser(String uid, {String? displayName}) {
    state = UserState(
      uid: uid,
      displayName: displayName ?? 'Player_$uid',
      rankPoints: 0,
      completedMatchStreak: 0,
      freeMatchUsedToday: 0,
      subscriptionStatus: SubscriptionStatus.trial,
      createdAt: DateTime.now(),
      lastPlayedAt: null,
    );
  }

  /// ランクポイントを加算
  void addRankPoints(int points) {
    final currentUser = state;
    if (currentUser == null) return;

    state = currentUser.copyWith(
      rankPoints: currentUser.rankPoints + points,
    );
  }

  /// 完走ストリークをインクリメント
  void incrementStreak() {
    final currentUser = state;
    if (currentUser == null) return;

    state = currentUser.copyWith(
      completedMatchStreak: currentUser.completedMatchStreak + 1,
      lastPlayedAt: DateTime.now(),
    );
  }

  /// 完走ストリークをリセット
  void resetStreak() {
    final currentUser = state;
    if (currentUser == null) return;

    state = currentUser.copyWith(
      completedMatchStreak: 0,
    );
  }

  /// 本日の無料マッチを使用
  void useFreeMatch() {
    final currentUser = state;
    if (currentUser == null) return;

    state = currentUser.copyWith(
      freeMatchUsedToday: currentUser.freeMatchUsedToday + 1,
    );
  }

  /// 本日の無料マッチをリセット（日替わり）
  void resetDailyFreeMatch() {
    final currentUser = state;
    if (currentUser == null) return;

    state = currentUser.copyWith(
      freeMatchUsedToday: 0,
    );
  }

  /// サブスクリプションを有効化
  void activateSubscription() {
    final currentUser = state;
    if (currentUser == null) return;

    state = currentUser.copyWith(
      subscriptionStatus: SubscriptionStatus.active,
    );
  }

  /// サブスクリプションをキャンセル
  void cancelSubscription() {
    final currentUser = state;
    if (currentUser == null) return;

    state = currentUser.copyWith(
      subscriptionStatus: SubscriptionStatus.cancelled,
    );
  }

  /// ユーザーをログアウト
  void logout() {
    state = null;
  }
}

/// User Provider
final userStateProvider =
    StateNotifierProvider<UserStateNotifier, UserState?>((ref) {
  return UserStateNotifier();
});

/// ユーザーUID Provider
final userUidProvider = Provider<String?>((ref) {
  return ref.watch(userStateProvider)?.uid;
});

/// ユーザー名 Provider
final userDisplayNameProvider = Provider<String?>((ref) {
  return ref.watch(userStateProvider)?.displayName;
});

/// ランクポイント Provider
final rankPointsProvider = Provider<int>((ref) {
  return ref.watch(userStateProvider)?.rankPoints ?? 0;
});

/// 完走ストリーク Provider
final streakProvider = Provider<int>((ref) {
  return ref.watch(userStateProvider)?.completedMatchStreak ?? 0;
});

/// 本日の無料マッチ有無 Provider
final hasFreeMatchProvider = Provider<bool>((ref) {
  return ref.watch(userStateProvider)?.hasFreeMatchToday ?? false;
});

/// サブスクリプション状態 Provider
final isSubscribedProvider = Provider<bool>((ref) {
  return ref.watch(userStateProvider)?.isSubscribed ?? false;
});

/// ログイン状態 Provider
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(userStateProvider) != null;
});
