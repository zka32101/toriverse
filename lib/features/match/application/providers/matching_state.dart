import 'package:flutter_riverpod/flutter_riverpod.dart';

/// マッチング状態の定義
class MatchingState {
  final MatchingStatus status;
  final int playersWaiting; // 待機中のプレイヤー数（0-3）
  final List<String> playerIds; // 参加プレイヤーのID
  final DateTime createdAt;
  final String? matchId; // Firestore match ID
  final String? error;

  MatchingState({
    required this.status,
    required this.playersWaiting,
    required this.playerIds,
    required this.createdAt,
    this.matchId,
    this.error,
  });

  /// コピーコンストラクタ
  MatchingState copyWith({
    MatchingStatus? status,
    int? playersWaiting,
    List<String>? playerIds,
    DateTime? createdAt,
    String? matchId,
    String? error,
  }) {
    return MatchingState(
      status: status ?? this.status,
      playersWaiting: playersWaiting ?? this.playersWaiting,
      playerIds: playerIds ?? this.playerIds,
      createdAt: createdAt ?? this.createdAt,
      matchId: matchId ?? this.matchId,
      error: error ?? this.error,
    );
  }

  /// マッチングが成立したか
  bool get isMatched => playerIds.length == 3;

  /// タイムアウト（30秒）
  bool get isTimedOut {
    return DateTime.now().difference(createdAt).inSeconds > 30;
  }
}

/// マッチング状態
enum MatchingStatus {
  idle,       // 待機中
  searching,  // マッチング検索中
  matched,    // マッチング成立
  timeout,    // タイムアウト
  error,      // エラー
}

/// Matching Notifier
class MatchingStateNotifier extends StateNotifier<MatchingState> {
  MatchingStateNotifier()
      : super(
          MatchingState(
            status: MatchingStatus.idle,
            playersWaiting: 0,
            playerIds: [],
            createdAt: DateTime.now(),
          ),
        );

  /// マッチング検索を開始
  Future<void> startMatching(String userId) async {
    state = state.copyWith(
      status: MatchingStatus.searching,
      playersWaiting: 1,
      playerIds: [userId],
      createdAt: DateTime.now(),
      error: null,
    );

    // Firestore に "waiting" ドキュメントを作成
    // (ここでは仮実装)
    try {
      // 5秒ごとにチェック（最大30秒）
      for (int i = 0; i < 6; i++) {
        await Future.delayed(const Duration(seconds: 5));

        // タイムアウトチェック
        if (state.isTimedOut) {
          state = state.copyWith(status: MatchingStatus.timeout);
          return;
        }

        // マッチング成立確認（Firestore リスナー）
        if (state.isMatched) {
          state = state.copyWith(status: MatchingStatus.matched);
          return;
        }
      }

      // ここまで来たら AI を補完
      await completeWithAI();
    } catch (e) {
      state = state.copyWith(
        status: MatchingStatus.error,
        error: e.toString(),
      );
    }
  }

  /// AI で補完
  Future<void> completeWithAI() async {
    final currentPlayers = state.playerIds;

    // 不足分を AI で埋める
    final aiPlayers = List.generate(
      3 - currentPlayers.length,
      (index) => 'AI_${index + 1}',
    );

    final allPlayers = [...currentPlayers, ...aiPlayers];

    state = state.copyWith(
      status: MatchingStatus.matched,
      playerIds: allPlayers,
      playersWaiting: 3,
    );
  }

  /// マッチングをキャンセル
  void cancelMatching() {
    state = MatchingState(
      status: MatchingStatus.idle,
      playersWaiting: 0,
      playerIds: [],
      createdAt: DateTime.now(),
    );
  }

  /// マッチング状態をリセット
  void reset() {
    state = MatchingState(
      status: MatchingStatus.idle,
      playersWaiting: 0,
      playerIds: [],
      createdAt: DateTime.now(),
    );
  }
}

/// Matching Provider
final matchingStateProvider =
    StateNotifierProvider<MatchingStateNotifier, MatchingState>((ref) {
  return MatchingStateNotifier();
});

/// マッチング成立か Provider
final isMatchedProvider = Provider<bool>((ref) {
  return ref.watch(matchingStateProvider).isMatched;
});

/// マッチング中かProvider
final isSearchingProvider = Provider<bool>((ref) {
  return ref.watch(matchingStateProvider).status == MatchingStatus.searching;
});

/// プレイヤーリスト Provider
final matchedPlayersProvider = Provider<List<String>>((ref) {
  return ref.watch(matchingStateProvider).playerIds;
});
