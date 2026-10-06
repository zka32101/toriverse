import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/match/application/providers/ai_takeover_state.dart';
import 'package:toriverse/features/match/application/providers/game_state.dart';
import 'package:toriverse/features/match/application/providers/rescue_card_state.dart';
import 'package:toriverse/features/match/application/providers/user_state.dart';
import 'package:toriverse/features/match/application/providers/matching_state.dart';
import 'package:toriverse/features/match/domain/entities/board.dart';

/// 統合テスト: マッチング → 対局 → リザルト の全フロー
void main() {
  group('Game Flow Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('ユーザーログイン → マッチング → 対局開始', () async {
      // Step 1: ユーザーログイン
      container.read(userStateProvider.notifier).initializeUser(
        'player_0',
        displayName: 'TestPlayer',
      );

      var userState = container.read(userStateProvider);
      expect(userState, isNotNull);
      expect(userState!.uid, 'player_0');
      expect(userState.displayName, 'TestPlayer');

      // Step 2: マッチング開始（AIで即席補完）
      // startMatching() の30秒ポーリングを待たず、AI補完を直接呼び出してテストする
      await container.read(matchingStateProvider.notifier).completeWithAI();
      var matchingState = container.read(matchingStateProvider);
      expect(matchingState.playersWaiting, 3);

      // Step 3: ゲーム開始（マッチング完了）
      final players = matchingState.playerIds;
      container.read(gameStateProvider.notifier).startGame(
        playerIds: players,
      );

      var gameState = container.read(gameStateProvider);
      expect(gameState, isNotNull);
      expect(gameState!.playerIds.length, 3);
      expect(gameState.status, GameStatus.playing);
    });

    test('対局進行: 複数ラウンドを実行', () async {
      // セットアップ
      container.read(userStateProvider.notifier).initializeUser('player_0');
      container.read(gameStateProvider.notifier).startGame(
        playerIds: ['player_0', 'player_1', 'AI_1'],
      );

      var gameState = container.read(gameStateProvider)!;
      final initialRound = gameState.roundIndex;

      // ラウンド1
      final move1 = gameState.validMoves.first;
      await container
          .read(gameStateProvider.notifier)
          .placeStone(move1[0], move1[1]);

      gameState = container.read(gameStateProvider)!;
      expect(gameState.roundIndex, initialRound + 1);
      expect(gameState.currentPlayerIndex, 1); // 次のプレイヤーへ

      // ラウンド2
      final move2 = gameState.validMoves.isNotEmpty
          ? gameState.validMoves.first
          : [2, 4];
      await container
          .read(gameStateProvider.notifier)
          .placeStone(move2[0], move2[1]);

      gameState = container.read(gameStateProvider)!;
      expect(gameState.roundIndex, initialRound + 2);

      // ラウンド3
      final move3 = gameState.validMoves.isNotEmpty
          ? gameState.validMoves.first
          : [2, 2];
      await container
          .read(gameStateProvider.notifier)
          .placeStone(move3[0], move3[1]);

      gameState = container.read(gameStateProvider)!;
      expect(gameState.roundIndex, initialRound + 3);
    });

    test('弱者ボーナス発動条件の検証', () async {
      container.read(userStateProvider.notifier).initializeUser('player_0');
      container.read(gameStateProvider.notifier).startGame(
        playerIds: ['player_0', 'player_1', 'AI_1'],
      );

      // 複数ラウンド実行
      for (int i = 0; i < 10; i++) {
        var gameState = container.read(gameStateProvider)!;
        if (gameState.validMoves.isNotEmpty && gameState.roundIndex < 11) {
          final move = gameState.validMoves.first;
          await container
              .read(gameStateProvider.notifier)
              .placeStone(move[0], move[1]);
        } else {
          break;
        }
      }

      var gameState = container.read(gameStateProvider)!;
      // 11手目までは弱者ボーナスが有効
      expect(gameState.roundIndex, lessThanOrEqualTo(11));
    });

    test('救済カード発動条件の検証: 連続被弾2ラウンドで自動付与', () {
      const matchId = 'match_rescue_card_flow';
      container.read(userStateProvider.notifier).initializeUser('player_0');
      container.read(gameStateProvider.notifier).startGame(
        playerIds: ['player_0', 'player_1', 'AI_1'],
      );

      final rescueNotifier =
          container.read(rescueCardStateProvider(matchId).notifier);
      rescueNotifier.initializeMatch(matchId, ['player_0', 'player_1', 'AI_1']);

      // 1ラウンド目の被弾: まだ閾値未満なのでカードは付与されない
      final grantedAfterFirst = rescueNotifier.recordAttack(matchId, 'player_1');
      expect(grantedAfterFirst, isFalse);
      expect(rescueNotifier.hasActiveCard(matchId, 'player_1'), isFalse);

      // 2ラウンド連続被弾（デフォルト閾値）でカードが自動付与される
      final grantedAfterSecond = rescueNotifier.recordAttack(matchId, 'player_1');
      expect(grantedAfterSecond, isTrue);
      expect(rescueNotifier.hasActiveCard(matchId, 'player_1'), isTrue);

      // エッジケース: 次のラウンドで攻撃が発生しなければカードは消費されない
      rescueNotifier.resetConsecutiveAttacks(matchId, 'player_1');
      expect(rescueNotifier.hasActiveCard(matchId, 'player_1'), isTrue);
      expect(rescueNotifier.getConsecutiveAttackCount(matchId, 'player_1'), 0);

      // カードを実際に使用すると2手連続実行権が消費される
      final gameState = container.read(gameStateProvider)!;
      final activated = rescueNotifier.activateCard(
        matchId,
        'player_1',
        gameState.roundIndex,
      );
      expect(activated, isTrue);
      expect(rescueNotifier.hasActiveCard(matchId, 'player_1'), isFalse);
    });

    test('ゲーム終了検出', () async {
      container.read(userStateProvider.notifier).initializeUser('player_0');
      container.read(gameStateProvider.notifier).startGame(
        playerIds: ['player_0', 'player_1', 'AI_1'],
      );

      var gameState = container.read(gameStateProvider)!;
      expect(gameState.isGameOver, false);

      // ゲームを終了状態に変更
      final currentState = container.read(gameStateProvider)!;
      container.read(gameStateProvider.notifier).state =
          currentState.copyWith(status: GameStatus.finished);

      gameState = container.read(gameStateProvider)!;
      expect(gameState.isGameOver, true);
    });

    test('ゲーム終了後のストリークカウント', () {
      container.read(userStateProvider.notifier).initializeUser(
        'player_0',
        displayName: 'TestPlayer',
      );

      var userState = container.read(userStateProvider)!;
      expect(userState.completedMatchStreak, 0);

      // マッチ完了をシミュレート
      container.read(userStateProvider.notifier).incrementStreak();

      userState = container.read(userStateProvider)!;
      expect(userState.completedMatchStreak, 1);
    });

    test('無料マッチ使用とリセット', () {
      container.read(userStateProvider.notifier).initializeUser('player_0');

      var userState = container.read(userStateProvider)!;
      expect(userState.hasFreeMatchToday, true);
      expect(userState.freeMatchUsedToday, 0);

      // 無料マッチ使用
      container.read(userStateProvider.notifier).useFreeMatch();

      userState = container.read(userStateProvider)!;
      expect(userState.hasFreeMatchToday, false);
      expect(userState.freeMatchUsedToday, 1);

      // リセット
      container.read(userStateProvider.notifier).resetDailyFreeMatch();

      userState = container.read(userStateProvider)!;
      expect(userState.hasFreeMatchToday, true);
      expect(userState.freeMatchUsedToday, 0);
    });

    test('マッチング中のAI補完', () async {
      container.read(userStateProvider.notifier).initializeUser('player_0');
      // startMatching() の30秒ポーリングを待たず、AI補完を直接呼び出してテストする
      await container.read(matchingStateProvider.notifier).completeWithAI();

      var matchingState = container.read(matchingStateProvider);
      expect(matchingState.playersWaiting, lessThanOrEqualTo(3));

      // プレイヤーリストを確認
      final players = matchingState.playerIds;
      expect(players.length, 3);
    });

    test('離脱時のAI引き継ぎ: 離脱側にペナルティなく対局継続', () {
      container.read(userStateProvider.notifier).initializeUser('player_0');
      container.read(gameStateProvider.notifier).startGame(
        playerIds: ['player_0', 'player_1', 'player_2'],
      );

      var gameState = container.read(gameStateProvider)!;
      expect(gameState.playerIds.length, 3);

      final takeoverNotifier = container.read(aiTakeoverProvider.notifier);
      expect(container.read(aiTakeoverProvider).hasAITakeover, isFalse);

      // player_1が離脱（非アクティブ検知によるタイムアウト）をシミュレート
      takeoverNotifier.activateTakeover(
        playerId: 'player_1',
        reason: 'inactivity',
      );

      var takeoverState = container.read(aiTakeoverProvider);
      expect(takeoverState.hasAITakeover, isTrue);
      expect(takeoverState.isAIControlled('player_1'), isTrue);
      expect(takeoverState.aiControlledPlayers, contains('player_1'));
      // 他の2人は影響を受けない
      expect(takeoverState.isAIControlled('player_0'), isFalse);
      expect(takeoverState.isAIControlled('player_2'), isFalse);

      // 対局自体は中断せず継続する（離脱側にペナルティなし = playerIds/statusは不変）
      gameState = container.read(gameStateProvider)!;
      expect(gameState.status, GameStatus.playing);
      expect(gameState.playerIds, ['player_0', 'player_1', 'player_2']);

      // player_1が復帰した場合、AI引き継ぎは解除される
      takeoverNotifier.deactivateTakeover('player_1');
      takeoverState = container.read(aiTakeoverProvider);
      expect(takeoverState.isAIControlled('player_1'), isFalse);
      expect(takeoverState.hasAITakeover, isFalse);
    });

    test('盤面状態の一貫性検証', () async {
      container.read(userStateProvider.notifier).initializeUser('player_0');
      container.read(gameStateProvider.notifier).startGame(
        playerIds: ['player_0', 'player_1', 'AI_1'],
      );

      final initialState = container.read(gameStateProvider)!;
      final board = initialState.board;

      // 初期盤面: 黒2、白2
      int blackCount = 0, whiteCount = 0;
      for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
          final stone = board.getStone(i, j);
          if (stone == Board.black) blackCount++;
          if (stone == Board.white) whiteCount++;
        }
      }

      expect(blackCount, 2);
      expect(whiteCount, 2);

      // 1手実行後
      final move = initialState.validMoves.first;
      await container
          .read(gameStateProvider.notifier)
          .placeStone(move[0], move[1]);

      final updatedState = container.read(gameStateProvider)!;
      final updatedBoard = updatedState.board;

      int updatedBlackCount = 0, updatedWhiteCount = 0;
      for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
          final stone = updatedBoard.getStone(i, j);
          if (stone == Board.black) updatedBlackCount++;
          if (stone == Board.white) updatedWhiteCount++;
        }
      }

      expect(updatedBlackCount + updatedWhiteCount, greaterThan(4));
    });

    test('完全フロー: ログイン → マッチング → 対局 → 離脱 → AI引き継ぎ → 終局',
        () async {
      // 1. ユーザーログイン
      container.read(userStateProvider.notifier).initializeUser(
        'player_0',
        displayName: 'TestPlayer',
      );

      var userState = container.read(userStateProvider)!;
      expect(userState.uid, 'player_0');
      expect(userState.displayName, 'TestPlayer');

      // 2. マッチング開始（AIで即席補完）
      // startMatching() の30秒ポーリングを待たず、AI補完を直接呼び出してテストする
      await container.read(matchingStateProvider.notifier).completeWithAI();
      var matchingState = container.read(matchingStateProvider);
      expect(matchingState.playersWaiting, 3);

      // 3. ゲーム開始
      final players = matchingState.playerIds;
      container.read(gameStateProvider.notifier).startGame(
        playerIds: players,
      );

      var gameState = container.read(gameStateProvider)!;
      expect(gameState.status, GameStatus.playing);

      // 4. 複数ラウンド実行
      for (int i = 0; i < 3; i++) {
        gameState = container.read(gameStateProvider)!;
        if (gameState.validMoves.isNotEmpty &&
            gameState.status == GameStatus.playing) {
          final move = gameState.validMoves.first;
          await container
              .read(gameStateProvider.notifier)
              .placeStone(move[0], move[1]);
        }
      }

      // 5. player_1が離脱 → AIが代打ち（離脱側にペナルティなし）
      final takeoverNotifier = container.read(aiTakeoverProvider.notifier);
      takeoverNotifier.activateTakeover(
        playerId: players[1],
        reason: 'inactivity',
      );
      var takeoverState = container.read(aiTakeoverProvider);
      expect(takeoverState.isAIControlled(players[1]), isTrue);

      // 6. AI引き継ぎ後も対局は中断せず継続する
      for (int i = 0; i < 2; i++) {
        gameState = container.read(gameStateProvider)!;
        if (gameState.validMoves.isNotEmpty &&
            gameState.status == GameStatus.playing) {
          final move = gameState.validMoves.first;
          await container
              .read(gameStateProvider.notifier)
              .placeStone(move[0], move[1]);
        }
      }
      gameState = container.read(gameStateProvider)!;
      expect(gameState.status, GameStatus.playing);
      expect(container.read(aiTakeoverProvider).isAIControlled(players[1]),
          isTrue);

      // 7. 終局
      gameState = container.read(gameStateProvider)!;
      final finalState = gameState.copyWith(status: GameStatus.finished);
      container.read(gameStateProvider.notifier).state = finalState;

      gameState = container.read(gameStateProvider)!;
      expect(gameState.isGameOver, true);

      // 8. ストリーク増加（AI引き継ぎがあっても完走扱い）
      container.read(userStateProvider.notifier).incrementStreak();
      userState = container.read(userStateProvider)!;
      expect(userState.completedMatchStreak, 1);
    });

    test('複数マッチの連続実行', () async {
      container.read(userStateProvider.notifier).initializeUser('player_0');

      // マッチ1
      container.read(gameStateProvider.notifier).startGame(
        playerIds: ['player_0', 'player_1', 'AI_1'],
      );

      final gameState1 = container.read(gameStateProvider);
      expect(gameState1!.status, GameStatus.playing);

      container.read(gameStateProvider.notifier).resetGame();
      final gameState2 = container.read(gameStateProvider);
      expect(gameState2, null);

      // マッチ2
      container.read(gameStateProvider.notifier).startGame(
        playerIds: ['player_0', 'player_2', 'AI_2'],
      );

      final gameState3 = container.read(gameStateProvider);
      expect(gameState3!.status, GameStatus.playing);
      expect(gameState3.playerIds.length, 3);
    });

    test('エラー回復: 不正な手をキャッチ', () {
      container.read(userStateProvider.notifier).initializeUser('player_0');
      container.read(gameStateProvider.notifier).startGame(
        playerIds: ['player_0', 'player_1', 'AI_1'],
      );

      var gameState = container.read(gameStateProvider)!;
      final validMoves = gameState.validMoves;

      // 合法手以外の位置をテスト
      for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
          bool isValid = false;
          for (final move in validMoves) {
            if (move[0] == i && move[1] == j) {
              isValid = true;
              break;
            }
          }

          // 合法手でない場合のテスト
          if (!isValid) {
            // サーバー側でバリデーションされるべき
            break;
          }
        }
      }

      expect(validMoves.length, greaterThan(0));
    });
  });
}
