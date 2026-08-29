import 'dart:math';

import '../../application/services/remote_config_service.dart';
import '../../data/models/round_result_model.dart';

/// 弱者ボーナス判定ロジック
///
/// 発動条件（すべてを満たす必要がある）:
/// 1. 残りラウンド数が11手以下（終盤） ← Remote Config で調整可能
/// 2. 石差が下位20%以下（劣勢） ← Remote Config で調整可能
/// 3. 1局最大2回までの発動上限 ← Remote Config で調整可能
class BonusCalculator {
  /// 弱者ボーナスを発動できるかチェック
  ///
  /// Remote Config に基づいて判定条件をチューニング可能
  static bool shouldActivateBonus({
    required int roundsRemaining,     // 残りラウンド数
    required List<int> stoneCounts,   // 各プレイヤーの石数
    required int previousActivations, // これまでの発動回数（0-2）
    required int playerIndex,         // このプレイヤーのインデックス
    RemoteConfigService? configService, // Optional for testing
  }) {
    final config = configService ?? RemoteConfigService();

    // 条件1: 残りラウンド数が閾値以下（終盤判定）
    // デフォルト: 11手以下 → Remote Config で調整可能
    if (roundsRemaining > config.getWeakBonusRoundThreshold()) {
      return false;
    }

    // 条件2: 石差が下位20%以下（劣勢判定）
    if (!_isInBottomPercentile(stoneCounts, playerIndex, config)) {
      return false;
    }

    // 条件3: 発動回数上限（Remote Config で調整可能）
    // デフォルト: 2回まで
    if (previousActivations >= config.getWeakBonusMaxActivationsPerMatch()) {
      return false;
    }

    return true;
  }

  /// プレイヤーが下位20%の劣勢にあるかチェック
  /// Remote Config の stone_diff_threshold に基づいて判定
  static bool _isInBottomPercentile(
    List<int> stoneCounts,
    int playerIndex,
    RemoteConfigService config,
  ) {
    final myStones = stoneCounts[playerIndex];
    final maxStones = stoneCounts.reduce((a, b) => max(a, b));
    final minStones = stoneCounts.reduce((a, b) => min(a, b));

    // 石差
    final diff = maxStones - myStones;

    // 下位20%の目安: 石数の差が一定以上 or 最下位
    // Remote Config で threshold を調整可能（デフォルト: 8石）
    final thresholdDifference = config.getWeakBonusStoneDiffThreshold();

    return diff >= thresholdDifference || myStones == minStones;
  }

  /// ボーナス効果を適用（例：追加手数）
  ///
  /// 返値: ボーナス内容（例：`+1手`）
  static Map<String, dynamic> applyBonus({
    required int playerIndex,
    required int currentScore,
  }) {
    return {
      'type': 'extra_move',
      'value': 1, // 1手追加
      'description': '弱者ボーナス: 追加で1手配置できます',
      'playerId': playerIndex,
    };
  }
}

/// 救済カード発動判定ロジック
///
/// 発動条件:
/// - 同一相手から連続で攻撃された（回数は Remote Config で調整可能、デフォルト: 2ラウンド）
/// - 自動的に2手連続実行権を付与
class RescueCardCalculator {
  /// 救済カードを付与すべきかチェック
  ///
  /// Remote Config の rescue_card_consecutive_attacks に基づいて判定
  static bool shouldGrantRescueCard({
    required int consecutiveAttackCount, // 連続被弾数
    required bool cardAlreadyActive,     // カード既に有効か
    RemoteConfigService? configService,  // Optional for testing
  }) {
    final config = configService ?? RemoteConfigService();
    final threshold = config.getRescueCardConsecutiveAttacksThreshold();

    // 連続攻撃回数が閾値以上で、かつカードが未有効なら付与
    return consecutiveAttackCount >= threshold && !cardAlreadyActive;
  }

  /// 救済カード効果を適用
  static Map<String, dynamic> applyRescueCard({
    required int playerIndex,
  }) {
    return {
      'type': 'double_move',
      'value': 2, // 2手連続実行
      'duration': 'next_round',
      'description': '救済カード発動: 次のラウンドで2手配置できます',
      'playerId': playerIndex,
    };
  }

  /// 連続被弾カウントをリセット
  static void resetConsecutiveAttackCount() {
    // サーバー側で管理
  }
}

/// 同マス被り時のランダム抽選
///
/// 複数プレイヤーが同じマスに着手した場合、
/// ランダムに1人を選出し、他は救済カードを付与
class CollisionResolver {
  static final Random _random = Random();

  /// 衝突を解決（誰が置けるかをランダムに決定）
  static Map<String, dynamic> resolveCollision({
    required List<String> playerIds,      // 衝突したプレイヤーのID
    required int boardRow,
    required int boardCol,
  }) {
    // ランダムに勝者を選出
    final winner = playerIds[_random.nextInt(playerIds.length)];
    final losers = playerIds.where((id) => id != winner).toList();

    return {
      'winner': winner,
      'losers': losers,
      'position': [boardRow, boardCol],
      'rescueCardGranted': true, // 外れた側に救済カード付与
      'description':
          '同マス被り! $winner が着手、${losers.length}人に救済カードが付与されました',
    };
  }
}

/// 処理順のランダム抽選
///
/// ラウンドごとに処理順をランダムに決定し、
/// くじ引き演出を実施
class ProcessOrderRandomizer {
  static final Random _random = Random();

  /// 3人プレイヤーの処理順をランダムに決定
  static List<String> randomizeOrder(List<String> playerIds) {
    final order = List<String>.from(playerIds);
    order.shuffle(_random);
    return order;
  }

  /// 処理順に基づくアニメーション用シーケンス
  static List<Map<String, dynamic>> generateAnimationSequence({
    required List<String> processOrder,
    required Map<String, Map<String, dynamic>> moveResults,
  }) {
    final sequence = <Map<String, dynamic>>[];

    // くじ引き演出
    sequence.add({
      'type': 'lottery',
      'duration': 500,
      'description': 'くじ引き中...',
    });

    // 順番発表
    for (int i = 0; i < processOrder.length; i++) {
      sequence.add({
        'type': 'announce_turn',
        'order': i + 1,
        'playerId': processOrder[i],
        'duration': 300,
      });
    }

    // 反転アニメ再生
    for (final playerId in processOrder) {
      if (moveResults.containsKey(playerId)) {
        sequence.add({
          'type': 'flip_animation',
          'playerId': playerId,
          'result': moveResults[playerId],
          'duration': 800,
        });
      }
    }

    return sequence;
  }

  /// [generateAnimationSequence] の生Mapシーケンスを、
  /// SimultaneousRevealWidget が消費する [ReplayEvent] のリストに変換する。
  static List<ReplayEvent> toReplayEvents(
    List<Map<String, dynamic>> sequence,
  ) {
    return sequence
        .map(
          (event) => ReplayEvent(
            type: event['type'] as String,
            data: event,
            delayMs: (event['duration'] as int?) ?? 0,
          ),
        )
        .toList();
  }
}
