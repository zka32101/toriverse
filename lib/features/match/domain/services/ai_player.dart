import 'dart:math';
import '../entities/board.dart';

/// AI プレイヤーの実装（簡易ミニマックスアルゴリズム）
///
/// 特徴:
/// - 深さ3-4のミニマックス探索
/// - 盤面評価関数（隅・辺・中央で重み付け）
/// - 3色オセロ対応
class AIPlayer {
  /// 探索の深さ（調整可能、深いほど強いが遅い）
  static const int defaultDepth = 3;

  /// 最高スコアの手を検索
  static int? suggestMove(Board board, int aiPlayer, {int depth = defaultDepth}) {
    int bestScore = -10000;
    int? bestMove;

    final validMoves = board.getValidMoves(aiPlayer);
    if (validMoves.isEmpty) {
      return null; // 合法手なし
    }

    for (final move in validMoves) {
      final testBoard = board.clone();
      testBoard.placeStone(move[0], move[1], aiPlayer);

      final score = _minimax(
        testBoard,
        depth - 1,
        aiPlayer,
        false, // 最初は最小化側（敵のターン）
      );

      if (score > bestScore) {
        bestScore = score;
        bestMove = move[0] * 8 + move[1];
      }
    }

    return bestMove;
  }

  /// ミニマックスアルゴリズム（内部用）
  static int _minimax(
    Board board,
    int depth,
    int aiPlayer,
    bool isMaximizing,
  ) {
    // ベースケース: 深さ0 or 合法手がない
    if (depth == 0) {
      return _evaluateBoard(board, aiPlayer);
    }

    // 現在のターンプレイヤーを決定
    // 簡略化: isMaximizing が true なら AI、false なら敵
    final currentPlayer = isMaximizing ? aiPlayer : (aiPlayer + 1) % 3;

    final validMoves = board.getValidMoves(currentPlayer);

    // 合法手がないターンをスキップ
    if (validMoves.isEmpty) {
      // 別のプレイヤーのターンへ（簡略化のため現在は敵プレイヤーのみ）
      final nextPlayer = (currentPlayer + 1) % 3;
      return _minimax(board, depth, aiPlayer, !isMaximizing);
    }

    int score = isMaximizing ? -10000 : 10000;

    for (final move in validMoves) {
      final testBoard = board.clone();
      testBoard.placeStone(move[0], move[1], currentPlayer);

      final newScore = _minimax(testBoard, depth - 1, aiPlayer, !isMaximizing);

      if (isMaximizing) {
        score = max(score, newScore);
      } else {
        score = min(score, newScore);
      }
    }

    return score;
  }

  /// 盤面を評価（AI にとってのスコア）
  ///
  /// 評価基準:
  /// 1. 石数の差（重要度: 低）
  /// 2. 隅の確保（重要度: 高、各+30）
  /// 3. 辺の確保（重要度: 中、各+10）
  /// 4. 動きの自由度（合法手数）
  static int _evaluateBoard(Board board, int aiPlayer) {
    final counts = board.countStones();
    final aiStones = counts[aiPlayer] ?? 0;

    // ベーススコア: AI の石数 - 敵の石数
    var score = 0;

    // 全プレイヤーとの差分をカウント
    for (int player = 0; player < 3; player++) {
      if (player != aiPlayer) {
        final enemyStones = counts[player] ?? 0;
        score += aiStones - enemyStones;
      }
    }

    // 隅の価値（高）
    const corners = [
      [0, 0], [0, 7],
      [7, 0], [7, 7],
    ];
    for (final corner in corners) {
      if (board.getStone(corner[0], corner[1]) == aiPlayer) {
        score += 30;
      } else if (board.getStone(corner[0], corner[1]) != Board.empty) {
        score -= 10; // 敵が隅を取ったペナルティ
      }
    }

    // 辺の価値（中）
    // 隅ではない辺
    for (int i = 0; i < 8; i++) {
      // 上辺
      if (i != 0 && i != 7) {
        if (board.getStone(0, i) == aiPlayer) score += 10;
      }
      // 下辺
      if (i != 0 && i != 7) {
        if (board.getStone(7, i) == aiPlayer) score += 10;
      }
      // 左辺
      if (i != 0 && i != 7) {
        if (board.getStone(i, 0) == aiPlayer) score += 10;
      }
      // 右辺
      if (i != 0 && i != 7) {
        if (board.getStone(i, 7) == aiPlayer) score += 10;
      }
    }

    // 動きの自由度（合法手数）
    final myMoves = board.getValidMoves(aiPlayer).length;
    final enemyMoves = _countEnemyValidMoves(board, aiPlayer);
    score += (myMoves - enemyMoves) * 2;

    return score;
  }

  /// 敵の合法手数をカウント（評価用）
  static int _countEnemyValidMoves(Board board, int aiPlayer) {
    int totalEnemyMoves = 0;
    for (int player = 0; player < 3; player++) {
      if (player != aiPlayer) {
        totalEnemyMoves += board.getValidMoves(player).length;
      }
    }
    return totalEnemyMoves;
  }

  /// AI の難易度設定
  static int getDepthByDifficulty(String difficulty) {
    return switch (difficulty) {
      'easy' => 1,      // ほぼ ランダム
      'normal' => 3,    // バランス型
      'hard' => 4,      // 高度な先読み
      'expert' => 5,    // 非常に強い
      _ => 3,
    };
  }
}
