import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/round_result_model.dart';
import '../../domain/services/bonus_calculator.dart';

/// ラウンド中の手の提出状態を管理
class RoundSubmissionState {
  final int roundIndex;
  final Map<String, int?> submittedPositions; // playerId -> position (null = not submitted)
  final DateTime roundStartedAt;
  final Duration roundTimeout;

  const RoundSubmissionState({
    required this.roundIndex,
    required this.submittedPositions,
    required this.roundStartedAt,
    this.roundTimeout = const Duration(seconds: 30),
  });

  /// タイムアウトまでの残り時間（ミリ秒）
  int get msRemaining {
    final elapsed = DateTime.now().difference(roundStartedAt).inMilliseconds;
    return (roundTimeout.inMilliseconds - elapsed).clamp(0, roundTimeout.inMilliseconds);
  }

  /// すべてのプレイヤーが提出済みか
  bool isAllSubmitted(List<String> playerIds) {
    return playerIds.every((id) => submittedPositions.containsKey(id) && submittedPositions[id] != null);
  }

  /// タイムアウトしたか
  bool isTimedOut() {
    return msRemaining <= 0;
  }

  /// 手を提出
  RoundSubmissionState submitMove(String playerId, int position) {
    final updated = Map<String, int?>.from(submittedPositions);
    updated[playerId] = position;
    return RoundSubmissionState(
      roundIndex: roundIndex,
      submittedPositions: updated,
      roundStartedAt: roundStartedAt,
      roundTimeout: roundTimeout,
    );
  }

  /// ラウンドをリセット（次ラウンド用）
  static RoundSubmissionState create({
    required int roundIndex,
    required List<String> playerIds,
  }) {
    return RoundSubmissionState(
      roundIndex: roundIndex,
      submittedPositions: {for (final id in playerIds) id: null},
      roundStartedAt: DateTime.now(),
    );
  }
}

/// ラウンド提出状態を管理するNotifier
class RoundSubmissionNotifier extends StateNotifier<RoundSubmissionState?> {
  RoundSubmissionNotifier() : super(null);

  /// 新規ラウンドを開始
  void startRound({
    required int roundIndex,
    required List<String> playerIds,
  }) {
    state = RoundSubmissionState.create(
      roundIndex: roundIndex,
      playerIds: playerIds,
    );
  }

  /// 手を提出
  void submitMove(String playerId, int position) {
    final current = state;
    if (current != null) {
      state = current.submitMove(playerId, position);
    }
  }

  /// 状態をリセット（ラウンド完了時など）
  void reset() {
    state = null;
  }
}

final roundSubmissionProvider =
    StateNotifierProvider<RoundSubmissionNotifier, RoundSubmissionState?>((ref) {
  return RoundSubmissionNotifier();
});

/// ラウンドの現在のフェーズ
enum RoundPhase {
  selection,    // プレイヤーが手を選択している
  waiting,      // すべての手が提出されるのを待機中
  revealing,    // 同時公開アニメーション再生中
  finished,     // ラウンド完了、次ラウンドへ移行可能
}

/// ラウンドフェーズを管理するNotifier
class RoundPhaseNotifier extends StateNotifier<RoundPhase> {
  RoundPhaseNotifier() : super(RoundPhase.selection);

  void setSelection() => state = RoundPhase.selection;
  void setWaiting() => state = RoundPhase.waiting;
  void setRevealing() => state = RoundPhase.revealing;
  void setFinished() => state = RoundPhase.finished;
}

final roundPhaseProvider =
    StateNotifierProvider<RoundPhaseNotifier, RoundPhase>((ref) {
  return RoundPhaseNotifier();
});

/// ラウンド結果を保持するProvider（一時的）
class RoundResultNotifier extends StateNotifier<RoundResultModel?> {
  RoundResultNotifier() : super(null);

  void setResult(RoundResultModel result) {
    state = result;
  }

  void clear() {
    state = null;
  }
}

final roundResultProvider =
    StateNotifierProvider<RoundResultNotifier, RoundResultModel?>((ref) {
  return RoundResultNotifier();
});

/// Stream that ticks down from submission timeout to 0
/// Emits remaining milliseconds every 100ms
final timeRemainingProvider =
    StreamProvider<int>((ref) async* {
  final roundSubmission = ref.watch(roundSubmissionProvider);
  if (roundSubmission == null) {
    yield 0;
    return;
  }

  while (true) {
    final remaining = roundSubmission.msRemaining;
    yield remaining;

    if (remaining <= 0) {
      return;
    }

    await Future.delayed(const Duration(milliseconds: 100));
  }
});
