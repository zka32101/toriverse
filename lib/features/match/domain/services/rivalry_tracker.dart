import '../entities/board.dart';

/// 対立関係トラッカー（GAME_DESIGN_UI_REFORM.md §2.2「二強連合」可視化システム）
///
/// 3人対戦オセロの本質的な面白さである「2人が結託して1人を叩く」流動的な
/// 力学を可視化するための独立ロジック。直近ラウンドで誰が誰の石を最も
/// 多く挟んだか（攻撃したか）を集計し、対立関係を算出する。
///
/// 注意: 弱者ボーナス・救済カードの判定ロジック（bonus_calculator.dart）
/// とは完全に独立しており、一切関与しない。表示専用の集計レイヤー。
class RivalryTracker {
  /// 対立スコア集計に用いるデフォルトの直近ラウンド数
  static const int defaultWindowRounds = 3;

  /// 1手分の攻撃内訳を、着手前後の盤面スナップショットの差分から算出する。
  ///
  /// 戻り値: { 攻撃された側の色: 奪取された石数 }
  /// mover と異なる色から mover の色に変化したマスをすべて数える。
  /// Board の公開APIのみを使用し、内部実装には依存しない。
  static Map<int, int> computeAttackBreakdown({
    required Board boardBefore,
    required Board boardAfter,
    required int mover,
  }) {
    final breakdown = <int, int>{};
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final before = boardBefore.getStone(row, col);
        final after = boardAfter.getStone(row, col);
        if (before != Board.empty && before != mover && after == mover) {
          breakdown[before] = (breakdown[before] ?? 0) + 1;
        }
      }
    }
    return breakdown;
  }

  /// 直近ラウンド分の攻撃内訳リストから、対立スコアを累積集計する。
  ///
  /// [recentRounds] は古い順のラウンドごとの攻撃内訳
  /// （{ 攻撃側の色: { 被害側の色: 奪取石数 } }）のリスト。
  /// [windowRounds] より古いラウンドは切り捨てる（直近のみを反映）。
  static Map<int, Map<int, int>> aggregateRivalryScores(
    List<Map<int, Map<int, int>>> recentRounds, {
    int windowRounds = defaultWindowRounds,
  }) {
    final windowed = recentRounds.length > windowRounds
        ? recentRounds.sublist(recentRounds.length - windowRounds)
        : recentRounds;

    final scores = <int, Map<int, int>>{};
    for (final round in windowed) {
      round.forEach((attacker, targets) {
        final attackerScores = scores.putIfAbsent(attacker, () => {});
        targets.forEach((target, count) {
          attackerScores[target] = (attackerScores[target] ?? 0) + count;
        });
      });
    }
    return scores;
  }

  /// [targetPlayer] を最も攻撃しているプレイヤーを返す（同点の場合は複数）。
  /// 攻撃実績がなければ空リストを返す。
  static List<int> getTopAggressorsAgainst(
    Map<int, Map<int, int>> rivalryScores,
    int targetPlayer,
  ) {
    final tally = <int, int>{};
    rivalryScores.forEach((attacker, targets) {
      final count = targets[targetPlayer];
      if (count != null && count > 0) {
        tally[attacker] = count;
      }
    });

    if (tally.isEmpty) return [];

    final maxCount = tally.values.reduce((a, b) => a > b ? a : b);
    final topAggressors = tally.entries
        .where((entry) => entry.value == maxCount)
        .map((entry) => entry.key)
        .toList();
    topAggressors.sort();
    return topAggressors;
  }

  /// [targetPlayer] が複数のプレイヤーから結託して狙われているか（二強連合）
  /// を判定する。各アグレッサーの攻撃回数が [minAttacksEach] 以上であれば
  /// カウントする。
  static bool isDoubleTargeted(
    Map<int, Map<int, int>> rivalryScores,
    int targetPlayer,
    List<int> allPlayers, {
    int minAttacksEach = 1,
  }) {
    final aggressorCount = allPlayers
        .where((player) => player != targetPlayer)
        .where((player) {
          final count = rivalryScores[player]?[targetPlayer] ?? 0;
          return count >= minAttacksEach;
        })
        .length;

    return aggressorCount >= 2;
  }
}
