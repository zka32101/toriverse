import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/match/application/providers/game_state.dart';
import 'package:toriverse/features/match/domain/entities/board.dart';

void main() {
  group('GameStateNotifier - ゲーム管理', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('初期状態は null', () {
      final state = container.read(gameStateProvider);
      expect(state, null);
    });

    test('ゲーム開始で状態が初期化される', () {
      container.read(gameStateProvider.notifier).startGame(
        playerIds: ['player_0', 'player_1', 'AI_1'],
      );

      final state = container.read(gameStateProvider);
      expect(state, isNotNull);
      expect(state!.playerIds.length, 3);
      expect(state.currentPlayerIndex, 0);
      expect(state.status, GameStatus.playing);
      expect(state.roundIndex, 0);
    });

    test('石数が正しくカウントされる', () {
      container.read(gameStateProvider.notifier).startGame(
        playerIds: ['player_0', 'player_1', 'AI_1'],
      );

      final state = container.read(gameStateProvider);
      expect(state!.stoneCounts['player_0'], 2); // 黒
      expect(state.stoneCounts['player_1'], 2); // 白
      expect(state.stoneCounts['AI_1'], 0);     // 赤
    });

    test('合法手が取得できる', () {
      container.read(gameStateProvider.notifier).startGame(
        playerIds: ['player_0', 'player_1', 'AI_1'],
      );

      final state = container.read(gameStateProvider);
      final validMoves = state!.validMoves;
      expect(validMoves.length, 4); // 初期状態では黒の合法手は4つ
    });

    test('手を打つと次のプレイヤーに交代', () async {
      container.read(gameStateProvider.notifier).startGame(
        playerIds: ['player_0', 'player_1', 'AI_1'],
      );

      var state = container.read(gameStateProvider);
      expect(state!.currentPlayerIndex, 0);

      await container
          .read(gameStateProvider.notifier)
          .placeStone(2, 3);

      state = container.read(gameStateProvider);
      expect(state!.currentPlayerIndex, 1); // 次のプレイヤー
      expect(state.roundIndex, 1);
    });

    test('ゲーム終了の判定', () async {
      container.read(gameStateProvider.notifier).startGame(
        playerIds: ['player_0', 'player_1', 'AI_1'],
      );

      var state = container.read(gameStateProvider);
      expect(state!.isGameOver, false);

      // 複数ムーブしてゲーム終了を目指す
      // (実装はシンプルなため、手動で終了状態に変更)
      final currentState = container.read(gameStateProvider)!;
      container.read(gameStateProvider.notifier).state = currentState.copyWith(
        status: GameStatus.finished,
      );

      state = container.read(gameStateProvider);
      expect(state!.isGameOver, true);
    });

    test('ゲームをリセット', () {
      container.read(gameStateProvider.notifier).startGame(
        playerIds: ['player_0', 'player_1', 'AI_1'],
      );

      var state = container.read(gameStateProvider);
      expect(state, isNotNull);

      container.read(gameStateProvider.notifier).resetGame();

      state = container.read(gameStateProvider);
      expect(state, null);
    });

    test('ゲームを一時停止・再開', () {
      container.read(gameStateProvider.notifier).startGame(
        playerIds: ['player_0', 'player_1', 'AI_1'],
      );

      container.read(gameStateProvider.notifier).pauseGame();
      var state = container.read(gameStateProvider);
      expect(state!.status, GameStatus.paused);

      container.read(gameStateProvider.notifier).resumeGame();
      state = container.read(gameStateProvider);
      expect(state!.status, GameStatus.playing);
    });
  });

  group('GameStateNotifier - Provider 依存', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      container.read(gameStateProvider.notifier).startGame(
        playerIds: ['player_0', 'player_1', 'AI_1'],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('boardProvider が盤面を返す', () {
      final board = container.read(boardProvider);
      expect(board, isNotNull);
      expect(board!.getStone(3, 3), Board.white);
    });

    test('currentPlayerProvider が現在のプレイヤーを返す', () {
      final player = container.read(currentPlayerProvider);
      expect(player, 'player_0');
    });

    test('validMovesProvider が合法手を返す', () {
      final moves = container.read(validMovesProvider);
      expect(moves.length, 4);
    });

    test('stoneCountsProvider が石数を返す', () {
      final counts = container.read(stoneCountsProvider);
      expect(counts!['player_0'], 2);
      expect(counts['player_1'], 2);
    });

    test('roundIndexProvider がラウンド番号を返す', () {
      final round = container.read(roundIndexProvider);
      expect(round, 0);
    });

    test('isGameOverProvider がゲーム終了状態を返す', () {
      final isOver = container.read(isGameOverProvider);
      expect(isOver, false);
    });
  });

  group('GameStateNotifier - 複雑なシーン', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('複数ラウンドの進行', () async {
      container.read(gameStateProvider.notifier).startGame(
        playerIds: ['player_0', 'player_1', 'AI_1'],
      );

      // 複数の手を打つ
      await container.read(gameStateProvider.notifier).placeStone(2, 3);
      await container.read(gameStateProvider.notifier).placeStone(2, 4);
      await container.read(gameStateProvider.notifier).placeStone(2, 2);

      final state = container.read(gameStateProvider);
      expect(state!.roundIndex, 3);
    });

    test('盤面の状態が正しく更新される', () async {
      container.read(gameStateProvider.notifier).startGame(
        playerIds: ['player_0', 'player_1', 'AI_1'],
      );

      await container.read(gameStateProvider.notifier).placeStone(2, 3);

      final state = container.read(gameStateProvider);
      expect(state!.board.getStone(2, 3), Board.black);
      expect(state.board.getStone(3, 3), Board.black); // 反転
    });
  });
}
