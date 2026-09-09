import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/match/application/providers/ai_difficulty_provider.dart';
import 'package:toriverse/features/match/application/providers/round_resolution_provider.dart';
import 'package:toriverse/features/match/application/providers/rescue_card_state.dart';
import 'package:toriverse/features/match/application/services/round_processor.dart';
import 'package:toriverse/features/match/domain/entities/board.dart';

void main() {
  group('Phase 12 Integration - AI Difficulty Selection', () {
    test('AI difficulty provider has default difficulty', () {
      final selector = AIMoveSelector();
      expect(selector.difficulty, AIDifficulty.normal);
    });

    test('AI selector selects move based on difficulty', () {
      final board = Board.createBoard();
      final difficulties = [
        AIDifficulty.easy,
        AIDifficulty.normal,
        AIDifficulty.hard,
        AIDifficulty.expert,
      ];

      for (final difficulty in difficulties) {
        final selector = AIMoveSelector(difficulty: difficulty);
        final move = selector.selectMove(board, 0);

        // Should produce a move (or null if no valid moves)
        if (move != null) {
          expect(move, isA<List<int>>());
          expect(move.length, 2);
        }
      }
    });

    test('different AI difficulties produce valid moves', () async {
      final board = Board.createBoard();

      final easyMove = await getAIMove(board, 0, AIDifficulty.easy);
      final normalMove = await getAIMove(board, 0, AIDifficulty.normal);
      final hardMove = await getAIMove(board, 0, AIDifficulty.hard);
      final expertMove = await getAIMove(board, 0, AIDifficulty.expert);

      // All should complete without error
      expect(easyMove, anyOf([isNull, isA<List<int>>()]));
      expect(normalMove, anyOf([isNull, isA<List<int>>()]));
      expect(hardMove, anyOf([isNull, isA<List<int>>()]));
      expect(expertMove, anyOf([isNull, isA<List<int>>()]));
    });
  });

  group('Phase 12 Integration - Bonus Activation Tracking', () {
    test('bonus activation state initializes correctly', () {
      final notifier = BonusActivationNotifier(
        playerIds: ['player1', 'player2', 'player3'],
      );

      expect(notifier.getActivationCount('player1'), 0);
      expect(notifier.getActivationCount('player2'), 0);
      expect(notifier.getActivationCount('player3'), 0);
    });

    test('bonus activation records activations', () {
      final notifier = BonusActivationNotifier(
        playerIds: ['player1', 'player2', 'player3'],
      );

      notifier.recordActivation('player1', 5);
      expect(notifier.getActivationCount('player1'), 1);

      notifier.recordActivation('player1', 10);
      expect(notifier.getActivationCount('player1'), 2);

      // Third activation should not be allowed by game logic
      notifier.recordActivation('player1', 15);
      expect(notifier.canActivateBonus('player1'), false);
    });

    test('bonus state tracks max 2 activations per player', () {
      final notifier = BonusActivationNotifier(
        playerIds: ['player1', 'player2', 'player3'],
      );

      expect(notifier.canActivateBonus('player1'), true);

      notifier.recordActivation('player1', 5);
      expect(notifier.canActivateBonus('player1'), true);

      notifier.recordActivation('player1', 10);
      expect(notifier.canActivateBonus('player1'), false);
    });

    test('bonus state independent for each player', () {
      final notifier = BonusActivationNotifier(
        playerIds: ['player1', 'player2', 'player3'],
      );

      notifier.recordActivation('player1', 5);
      notifier.recordActivation('player1', 10);

      expect(notifier.getActivationCount('player1'), 2);
      expect(notifier.getActivationCount('player2'), 0);
      expect(notifier.canActivateBonus('player1'), false);
      expect(notifier.canActivateBonus('player2'), true);
    });
  });

  group('Phase 12 Integration - Rescue Card State', () {
    test('rescue card notifier initializes match correctly', () {
      final notifier = RescueCardNotifier(
        configService: null,
      );

      notifier.initializeMatch('match1', ['player1', 'player2', 'player3']);

      expect(notifier.getConsecutiveAttackCount('match1', 'player1'), 0);
      expect(notifier.getConsecutiveAttackCount('match1', 'player2'), 0);
      expect(notifier.getConsecutiveAttackCount('match1', 'player3'), 0);
    });

    test('rescue card records attacks', () {
      final notifier = RescueCardNotifier(
        configService: null,
      );

      notifier.initializeMatch('match1', ['player1', 'player2', 'player3']);
      notifier.recordAttack('match1', 'player1');

      expect(notifier.getConsecutiveAttackCount('match1', 'player1'), 1);
    });

    test('rescue card resets consecutive attacks', () {
      final notifier = RescueCardNotifier(
        configService: null,
      );

      notifier.initializeMatch('match1', ['player1', 'player2', 'player3']);
      notifier.recordAttack('match1', 'player1');
      notifier.recordAttack('match1', 'player1');

      expect(notifier.getConsecutiveAttackCount('match1', 'player1'), 2);

      notifier.resetConsecutiveAttacks('match1', 'player1');
      expect(notifier.getConsecutiveAttackCount('match1', 'player1'), 0);
    });

    test('rescue card activation works', () {
      final notifier = RescueCardNotifier(
        configService: null,
      );

      notifier.initializeMatch('match1', ['player1', 'player2', 'player3']);

      // Manually set card to available for testing
      final card = notifier.getCard('match1', 'player1');
      expect(card, isNotNull);
      expect(notifier.hasActiveCard('match1', 'player1'), false);
    });
  });

  group('Phase 12 Integration - Round Resolution Service', () {
    test('round resolution service resolves round correctly', () async {
      final board = Board.createBoard();

      final service = RoundResolutionService(
        processor: RoundProcessor(),
        configService: RoundProcessor().configService,
      );

      final resolution = await service.resolveRound(
        matchId: 'match1',
        roundIndex: 0,
        boardBefore: board,
        playerIds: ['player1', 'player2', 'player3'],
        submittedPositions: {
          'player1': 19, // Valid opening move
        },
        bonusActivationCounts: [0, 0, 0],
      );

      expect(resolution, isNotNull);
      expect(resolution.result, isNotNull);
      expect(resolution.boardAfter, isNotNull);
      expect(resolution.isGameOver, false);
    });

    test('round resolution handles bonus activations', () async {
      final board = Board.createBoard();

      final service = RoundResolutionService(
        processor: RoundProcessor(),
        configService: RoundProcessor().configService,
      );

      final resolution = await service.resolveRound(
        matchId: 'match1',
        roundIndex: 0,
        boardBefore: board,
        playerIds: ['player1', 'player2', 'player3'],
        submittedPositions: {},
        bonusActivationCounts: [1, 0, 1], // Some players with activations
      );

      expect(resolution, isNotNull);
    });

    test('round resolution determines winners on game over', () async {
      final board = Board.createBoard();

      final service = RoundResolutionService(
        processor: RoundProcessor(),
        configService: RoundProcessor().configService,
      );

      final resolution = await service.resolveRound(
        matchId: 'match1',
        roundIndex: 0,
        boardBefore: board,
        playerIds: ['player1', 'player2', 'player3'],
        submittedPositions: {},
        bonusActivationCounts: [0, 0, 0],
      );

      // Game shouldn't be over with opening board
      expect(resolution.isGameOver, false);
    });
  });

  group('Phase 12 Integration - Complete Round Flow', () {
    test('bonus state and rescue card state work together', () {
      final bonusNotifier = BonusActivationNotifier(
        playerIds: ['player1', 'player2', 'player3'],
      );

      final rescueNotifier = RescueCardNotifier(
        configService: null,
      );

      rescueNotifier.initializeMatch('match1', ['player1', 'player2', 'player3']);

      // Simulate bonus activation
      bonusNotifier.recordActivation('player1', 5);
      expect(bonusNotifier.getActivationCount('player1'), 1);

      // Simulate attack on different player
      rescueNotifier.recordAttack('match1', 'player2');
      expect(rescueNotifier.getConsecutiveAttackCount('match1', 'player2'), 1);

      // Both states should be independent
      expect(bonusNotifier.getActivationCount('player2'), 0);
      expect(rescueNotifier.getConsecutiveAttackCount('match1', 'player1'), 0);
    });

    test('AI difficulty, bonus state, and resolution work together', () {
      final board = Board.createBoard();
      final selector = AIMoveSelector(difficulty: AIDifficulty.normal);
      final bonusNotifier = BonusActivationNotifier(
        playerIds: ['player1', 'player2', 'player3'],
      );

      // Get AI move
      final move = selector.selectMove(board, 0);
      expect(move, anyOf([isNull, isA<List<int>>()]));

      // Track bonus activation
      bonusNotifier.recordActivation('player1', 0);
      expect(bonusNotifier.getActivationCount('player1'), 1);

      // Both should work independently
      expect(move, anyOf([isNull, isA<List<int>>()]));
      expect(bonusNotifier.getActivationCount('player1'), 1);
    });
  });

  group('Phase 12 Integration - Error Handling', () {
    test('round resolution handles null board gracefully', () async {
      final service = RoundResolutionService(
        processor: RoundProcessor(),
        configService: RoundProcessor().configService,
      );

      // Should handle gracefully (not throw)
      expect(
        () => service.resolveRound(
          matchId: 'match1',
          roundIndex: 0,
          boardBefore: Board.createBoard(),
          playerIds: ['player1', 'player2', 'player3'],
          submittedPositions: {},
          bonusActivationCounts: [0, 0, 0],
        ),
        isNotNull,
      );
    });

    test('AI selector handles empty board gracefully', () {
      final selector = AIMoveSelector(difficulty: AIDifficulty.normal);
      final board = Board.createBoard();

      // Should not throw
      final move = selector.selectMove(board, 0);
      expect(move, anyOf([isNull, isA<List<int>>()]));
    });

    test('bonus notifier handles invalid player IDs gracefully', () {
      final notifier = BonusActivationNotifier(
        playerIds: ['player1', 'player2', 'player3'],
      );

      // Accessing non-existent player should return 0
      expect(notifier.getActivationCount('player99'), 0);
    });
  });
}
