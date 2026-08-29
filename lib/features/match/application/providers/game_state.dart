import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/board.dart';
import '../../domain/services/ai_player.dart';

/// ゲーム状態の定義
class GameState {
  final Board board;
  final List<String> playerIds; // [player_0, player_1, "AI"] など
  final int currentPlayerIndex;
  final int roundIndex;
  final GameStatus status;
  final Map<String, int> stoneCounts; // プレイヤーごとの石数
  final List<int> bonusActivationCount; // 弱者ボーナスの発動回数
  final DateTime? gameStartedAt;
  final DateTime? lastMoveAt;

  GameState({
    required this.board,
    required this.playerIds,
    required this.currentPlayerIndex,
    required this.roundIndex,
    required this.status,
    required this.stoneCounts,
    required this.bonusActivationCount,
    this.gameStartedAt,
    this.lastMoveAt,
  });

  /// コピーコンストラクタ（状態更新用）
  GameState copyWith({
    Board? board,
    List<String>? playerIds,
    int? currentPlayerIndex,
    int? roundIndex,
    GameStatus? status,
    Map<String, int>? stoneCounts,
    List<int>? bonusActivationCount,
    DateTime? gameStartedAt,
    DateTime? lastMoveAt,
  }) {
    return GameState(
      board: board ?? this.board,
      playerIds: playerIds ?? this.playerIds,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      roundIndex: roundIndex ?? this.roundIndex,
      status: status ?? this.status,
      stoneCounts: stoneCounts ?? this.stoneCounts,
      bonusActivationCount: bonusActivationCount ?? this.bonusActivationCount,
      gameStartedAt: gameStartedAt ?? this.gameStartedAt,
      lastMoveAt: lastMoveAt ?? this.lastMoveAt,
    );
  }

  /// 現在のプレイヤーIDを取得
  String get currentPlayerId => playerIds[currentPlayerIndex];

  /// 合法手の一覧
  List<List<int>> get validMoves => board.getValidMoves(currentPlayerIndex);

  /// ゲーム終了かどうか
  bool get isGameOver => status == GameStatus.finished;
}

/// ゲームステータス
enum GameStatus {
  waiting,     // 対局待機中
  playing,     // 対局中
  paused,      // 一時停止
  finished,    // 終局
}

/// GameState NotifierProvider（状態管理）
class GameStateNotifier extends StateNotifier<GameState?> {
  GameStateNotifier() : super(null);

  /// 新規ゲームを開始
  void startGame({
    required List<String> playerIds,
  }) {
    final board = Board.initial();
    final counts = board.countStones();

    state = GameState(
      board: board,
      playerIds: playerIds,
      currentPlayerIndex: 0, // 黒（プレイヤー0）から開始
      roundIndex: 0,
      status: GameStatus.playing,
      stoneCounts: {
        playerIds[0]: counts[Board.black] ?? 0,
        playerIds[1]: counts[Board.white] ?? 0,
        playerIds[2]: counts[Board.red] ?? 0,
      },
      bonusActivationCount: [0, 0, 0],
      gameStartedAt: DateTime.now(),
      lastMoveAt: null,
    );
  }

  /// 手を打つ
  Future<void> placeStone(int row, int col) async {
    final currentState = state;
    if (currentState == null || currentState.isGameOver) return;

    try {
      // 盤面に石を置く
      final newBoard = currentState.board.clone();
      newBoard.placeStone(row, col, currentState.currentPlayerIndex);

      // 石数をカウント
      final newCounts = newBoard.countStones();
      final newStoneCounts = {
        currentState.playerIds[0]: newCounts[Board.black] ?? 0,
        currentState.playerIds[1]: newCounts[Board.white] ?? 0,
        currentState.playerIds[2]: newCounts[Board.red] ?? 0,
      };

      // 次のプレイヤーに交代
      int nextPlayerIndex = (currentState.currentPlayerIndex + 1) % 3;

      // 次のプレイヤーに合法手がなければスキップ
      // (3人対戦では複数プレイヤーが合法手なしの場合がある)
      while (nextPlayerIndex != currentState.currentPlayerIndex &&
          newBoard.getValidMoves(nextPlayerIndex).isEmpty) {
        nextPlayerIndex = (nextPlayerIndex + 1) % 3;
      }

      // すべてのプレイヤーに合法手がなければゲーム終了
      bool anyHasMove = false;
      for (int i = 0; i < 3; i++) {
        if (newBoard.getValidMoves(i).isNotEmpty) {
          anyHasMove = true;
          break;
        }
      }

      state = currentState.copyWith(
        board: newBoard,
        currentPlayerIndex: nextPlayerIndex,
        roundIndex: currentState.roundIndex + 1,
        status: anyHasMove ? GameStatus.playing : GameStatus.finished,
        stoneCounts: newStoneCounts,
        lastMoveAt: DateTime.now(),
      );
    } catch (e) {
      print('Error placing stone: $e');
    }
  }

  /// AI の手を自動実行
  Future<void> executeAIMove() async {
    final currentState = state;
    if (currentState == null || currentState.isGameOver) return;

    // 現在のプレイヤーが AI かどうか確認
    if (!currentState.currentPlayerId.startsWith('AI')) return;

    // AI の提案を取得
    final move = AIPlayer.suggestMove(
      currentState.board,
      currentState.currentPlayerIndex,
      depth: AIPlayer.getDepthByDifficulty('normal'),
    );

    if (move != null) {
      final row = move ~/ 8;
      final col = move % 8;
      await placeStone(row, col);
    }
  }

  /// ゲームをリセット
  void resetGame() {
    state = null;
  }

  /// ゲームを一時停止
  void pauseGame() {
    final currentState = state;
    if (currentState != null) {
      state = currentState.copyWith(status: GameStatus.paused);
    }
  }

  /// ゲームを再開
  void resumeGame() {
    final currentState = state;
    if (currentState != null) {
      state = currentState.copyWith(status: GameStatus.playing);
    }
  }

  /// ゲーム状態を更新（同時提出フロー用）
  void updateGameState({
    Board? board,
    int? roundIndex,
    GameStatus? status,
    Map<String, int>? stoneCounts,
  }) {
    final currentState = state;
    if (currentState == null) return;

    state = currentState.copyWith(
      board: board ?? currentState.board,
      roundIndex: roundIndex ?? currentState.roundIndex,
      status: status ?? currentState.status,
      stoneCounts: stoneCounts ?? currentState.stoneCounts,
      lastMoveAt: DateTime.now(),
    );
  }
}

/// GameState Provider
final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameState?>((ref) {
  return GameStateNotifier();
});

/// 現在の盤面 Provider
final boardProvider = Provider<Board?>((ref) {
  return ref.watch(gameStateProvider)?.board;
});

/// 現在のプレイヤー Provider
final currentPlayerProvider = Provider<String?>((ref) {
  return ref.watch(gameStateProvider)?.currentPlayerId;
});

/// 合法手リスト Provider
final validMovesProvider = Provider<List<List<int>>>((ref) {
  return ref.watch(gameStateProvider)?.validMoves ?? [];
});

/// 石数カウント Provider
final stoneCountsProvider = Provider<Map<String, int>?>((ref) {
  return ref.watch(gameStateProvider)?.stoneCounts;
});

/// ゲーム終了かどうか Provider
final isGameOverProvider = Provider<bool>((ref) {
  return ref.watch(gameStateProvider)?.isGameOver ?? false;
});

/// ラウンド番号 Provider
final roundIndexProvider = Provider<int>((ref) {
  return ref.watch(gameStateProvider)?.roundIndex ?? 0;
});

/// ゲーム進行時間 Provider
final gameElapsedTimeProvider = StreamProvider<Duration>((ref) async* {
  final gameState = ref.watch(gameStateProvider);
  if (gameState == null || gameState.gameStartedAt == null) return;

  while (!gameState.isGameOver) {
    final elapsed = DateTime.now().difference(gameState.gameStartedAt!);
    yield elapsed;
    await Future.delayed(const Duration(seconds: 1));
  }
});
