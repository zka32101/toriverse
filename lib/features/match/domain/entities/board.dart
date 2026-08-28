/// オセロ盤面の表現と操作
///
/// 内部では石を以下の値で管理（混同防止）:
/// - 0: 黒
/// - 1: 白
/// - 2: 赤
/// - 3: 空
class Board {
  static const int black = 0;
  static const int white = 1;
  static const int red = 2;
  static const int empty = 3;

  /// 8×8 の盤面（内部管理）
  late List<List<int>> _grid;

  /// 初期配置の盤面を作成
  Board.initial() {
    _grid = List.generate(8, (_) => List.filled(8, empty));

    // 初期配置（中央4マス）
    // 白: (3,3), (4,4)
    // 黒: (3,4), (4,3)
    _grid[3][3] = white;
    _grid[3][4] = black;
    _grid[4][3] = black;
    _grid[4][4] = white;
  }

  /// テスト用：任意の盤面を作成
  Board.fromGrid(List<List<int>> grid) {
    _grid = List.generate(8, (i) => List.from(grid[i]));
  }

  /// 盤面のクローン作成
  Board clone() {
    return Board.fromGrid(_grid);
  }

  /// 指定位置の石を取得
  int getStone(int row, int col) {
    if (row < 0 || row >= 8 || col < 0 || col >= 8) return empty;
    return _grid[row][col];
  }

  /// 合法手かどうかを判定
  ///
  /// ルール:
  /// - 空のマスである
  /// - 少なくとも1方向で相手の石を挟んで自分の色で閉じる
  bool isValidMove(int row, int col, int player) {
    // 範囲チェック
    if (row < 0 || row >= 8 || col < 0 || col >= 8) return false;

    // 既に石が置いてあればNG
    if (_grid[row][col] != empty) return false;

    // 8方向をチェック
    const directions = [
      [-1, 0], [1, 0],   // 縦
      [0, -1], [0, 1],   // 横
      [-1, -1], [-1, 1], // 斜め
      [1, -1], [1, 1],   // 斜め
    ];

    for (final dir in directions) {
      if (_hasFlippableInDirection(row, col, player, dir[0], dir[1])) {
        return true;
      }
    }
    return false;
  }

  /// 指定方向で挟める石があるかチェック（内部用）
  ///
  /// 3色オセロでは「相手」は単一色ではないため、自分以外の色（黒・白・赤の
  /// うち自分の色を除いた2色）が連続する区間を自分の色で挟めれば成立する。
  /// 区間内で相手2色が混在していても（例: 白→赤→白）挟み対象になる。
  bool _hasFlippableInDirection(
    int startRow,
    int startCol,
    int player,
    int dr,
    int dc,
  ) {
    int r = startRow + dr;
    int c = startCol + dc;

    // 最低1つの相手の石（自分以外の色）を通す必要がある
    bool foundOpponent = false;

    while (r >= 0 && r < 8 && c >= 0 && c < 8) {
      final stone = _grid[r][c];

      if (stone == empty) {
        // 空マスに到達 → 挟めない
        return false;
      }

      if (stone == player) {
        // 自分の色で閉じた → 条件を満たす
        return foundOpponent;
      } else {
        // 自分以外の色（3色なので2色ありうる。混在も可）→ 記録して続ける
        foundOpponent = true;
      }

      r += dr;
      c += dc;
    }

    // 盤の端まで到達 → 挟めない
    return false;
  }

  /// 手を確定（指定位置に石を置き、8方向で反転処理）
  void placeStone(int row, int col, int player) {
    if (!isValidMove(row, col, player)) {
      throw ArgumentError('Invalid move at ($row, $col)');
    }

    _grid[row][col] = player;

    const directions = [
      [-1, 0], [1, 0],
      [0, -1], [0, 1],
      [-1, -1], [-1, 1],
      [1, -1], [1, 1],
    ];

    for (final dir in directions) {
      _flipInDirection(row, col, player, dir[0], dir[1]);
    }
  }

  /// 指定方向の石を反転（内部用）
  ///
  /// 自分以外の色（黒・白・赤のうち自分の色を除く、混在可）が連続する
  /// 区間を自分の色で挟んだ場合、その区間すべてを自分の色に反転する。
  void _flipInDirection(int startRow, int startCol, int player, int dr, int dc) {
    int r = startRow + dr;
    int c = startCol + dc;

    // 反転対象のマスを収集
    final toFlip = <List<int>>[];

    while (r >= 0 && r < 8 && c >= 0 && c < 8) {
      final stone = _grid[r][c];

      if (stone == empty) {
        break;
      }

      if (stone == player) {
        // 自分の色で閉じた → 収集した相手の石を反転
        for (final flip in toFlip) {
          _grid[flip[0]][flip[1]] = player;
        }
        return;
      } else {
        // 自分以外の色（混在可） → 記録して続ける
        toFlip.add([r, c]);
      }

      r += dr;
      c += dc;
    }
  }

  /// 盤面の石の個数をカウント
  Map<int, int> countStones() {
    final counts = {black: 0, white: 0, red: 0, empty: 0};
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        counts[_grid[row][col]] = (counts[_grid[row][col]] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// 合法手の一覧を取得
  List<List<int>> getValidMoves(int player) {
    final validMoves = <List<int>>[];
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (isValidMove(row, col, player)) {
          validMoves.add([row, col]);
        }
      }
    }
    return validMoves;
  }

  /// 盤面を文字列で表現（デバッグ用）
  String toDebugString() {
    const stoneChars = {
      0: '●', // 黒
      1: '○', // 白
      2: '◉', // 赤
      3: '·', // 空
    };

    final buffer = StringBuffer();
    buffer.writeln('  0 1 2 3 4 5 6 7');
    for (int row = 0; row < 8; row++) {
      buffer.write('$row ');
      for (int col = 0; col < 8; col++) {
        final stone = _grid[row][col];
        buffer.write('${stoneChars[stone]} ');
      }
      buffer.writeln();
    }
    return buffer.toString();
  }
}
