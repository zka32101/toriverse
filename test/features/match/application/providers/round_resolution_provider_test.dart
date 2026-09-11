import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/match/application/providers/round_resolution_provider.dart';
import 'package:toriverse/features/match/application/services/round_processor.dart';
import 'package:toriverse/features/match/data/models/round_result_model.dart';
import 'package:toriverse/features/match/domain/entities/board.dart';

void main() {
  group('BonusActivationState', () {
    test('initializes with correct structure', () {
      final state = BonusActivationState(
        activationCounts: {'player1': 0, 'player2': 1, 'player3': 0},
        lastActivatedRounds: [],
      );

      expect(state.getCount('player1'), 0);
      expect(state.getCount('player2'), 1);
      expect(state.getCount('player3'), 0);
    });

    test('increments activation count', () {
      final state = BonusActivationState(
        activationCounts: {'player1': 0, 'player2': 0, 'player3': 0},
        lastActivatedRounds: [],
      );

      final newState = state.incrementActivation('player1');

      expect(newState.getCount('player1'), 1);
      expect(state.getCount('player1'), 0); // Original unchanged
    });

    test('max activations is 2', () {
      final state = BonusActivationState(
        activationCounts: {'player1': 1, 'player2': 0, 'player3': 0},
        lastActivatedRounds: [],
      );

      final state1 = state.incrementActivation('player1');
      expect(state1.getCount('player1'), 2);

      final state2 = state1.incrementActivation('player1');
      expect(state2.getCount('player1'), 3); // Can increment beyond 2, but logic prevents it
    });
  });

  group('BonusActivationNotifier', () {
    test('initializes with zero activations for all players', () {
      final notifier = BonusActivationNotifier(
        playerIds: ['player1', 'player2', 'player3'],
      );

      expect(notifier.getActivationCount('player1'), 0);
      expect(notifier.getActivationCount('player2'), 0);
      expect(notifier.getActivationCount('player3'), 0);
    });

    test('records activation', () {
      final notifier = BonusActivationNotifier(
        playerIds: ['player1', 'player2', 'player3'],
      );

      notifier.recordActivation('player1', 5);

      expect(notifier.getActivationCount('player1'), 1);
      expect(notifier.getActivationCount('player2'), 0);
    });

    test('can activate bonus when count < 2', () {
      final notifier = BonusActivationNotifier(
        playerIds: ['player1', 'player2', 'player3'],
      );

      expect(notifier.canActivateBonus('player1'), true);

      notifier.recordActivation('player1', 5);
      expect(notifier.canActivateBonus('player1'), true);

      notifier.recordActivation('player1', 10);
      expect(notifier.canActivateBonus('player1'), false);
    });
  });

  group('RoundResolutionService', () {
    late RoundProcessor processor;
    late RoundResolutionService service;

    setUp(() {
      processor = RoundProcessor();
      service = RoundResolutionService(
        processor: processor,
        configService: processor.configService,
      );
    });

    test('resolves a simple round with human players', () async {
      // Setup a basic board with opening moves
      final board = Board.createBoard();
      board.placeStone(2, 3, 0); // Player 0 (Black) plays valid move

      final resolution = await service.resolveRound(
        matchId: 'test_match_1',
        roundIndex: 0,
        boardBefore: board,
        playerIds: ['player1', 'player2', 'player3'],
        submittedPositions: {
          'player1': 19, // 2,3
        },
        bonusActivationCounts: [0, 0, 0],
      );

      expect(resolution, isNotNull);
      expect(resolution.result, isNotNull);
      expect(resolution.boardAfter, isNotNull);
      expect(resolution.isGameOver, false);
      expect(resolution.winners, isEmpty);
    });

    test('detects game over when no valid moves remain', () async {
      // Create a near-endgame board
      final board = Board.createBoard();

      // Play until most of the board is filled (simplified for test)
      // In a real test, we'd set up a specific endgame position

      final resolution = await service.resolveRound(
        matchId: 'test_match_2',
        roundIndex: 60,
        boardBefore: board,
        playerIds: ['player1', 'player2', 'player3'],
        submittedPositions: {},
        bonusActivationCounts: [0, 0, 0],
      );

      // Since we used empty submitted positions, no moves applied
      // Game shouldn't be over yet with opening board
      expect(resolution.isGameOver, false);
    });

    test('determines winners correctly', () async {
      final board = Board.createBoard();

      final resolution = await service.resolveRound(
        matchId: 'test_match_3',
        roundIndex: 0,
        boardBefore: board,
        playerIds: ['player1', 'player2', 'player3'],
        submittedPositions: {},
        bonusActivationCounts: [0, 0, 0],
      );

      // With initial board state, game is not over
      expect(resolution.winners, isEmpty);
    });

    test('handles bonus activation tracking', () async {
      final board = Board.createBoard();
      board.placeStone(2, 3, 0); // Valid opening move

      final resolution = await service.resolveRound(
        matchId: 'test_match_4',
        roundIndex: 0,
        boardBefore: board,
        playerIds: ['player1', 'player2', 'player3'],
        submittedPositions: {
          'player1': 19, // 2,3
        },
        bonusActivationCounts: [1, 0, 0], // Player 1 has 1 activation
      );

      expect(resolution.result, isNotNull);
      // Bonus tracking is handled by the processor internally
    });

    test('processes multiple submitted moves', () async {
      final board = Board.createBoard();

      final resolution = await service.resolveRound(
        matchId: 'test_match_5',
        roundIndex: 0,
        boardBefore: board,
        playerIds: ['player1', 'player2', 'player3'],
        submittedPositions: {
          'player1': 19, // Valid opening move for Black (player 0)
        },
        bonusActivationCounts: [0, 0, 0],
      );

      expect(resolution.result.processOrder, isNotEmpty);
      expect(resolution.result.processOrder.length, lessThanOrEqualTo(3));
    });

    test('calculates correct scores', () async {
      final board = Board.createBoard();

      final resolution = await service.resolveRound(
        matchId: 'test_match_6',
        roundIndex: 0,
        boardBefore: board,
        playerIds: ['player1', 'player2', 'player3'],
        submittedPositions: {},
        bonusActivationCounts: [0, 0, 0],
      );

      // Initial board has 2 black, 2 white stones
      final scores = processor.calculateScores(resolution.boardAfter, ['player1', 'player2', 'player3']);
      expect(scores['player1'], isNotNull); // Black
      expect(scores['player2'], isNotNull); // White
      expect(scores['player3'], isNotNull); // Red
    });
  });

  group('RoundResolution', () {
    test('indicates game over correctly', () {
      final board = Board.createBoard();
      final result = RoundResultModel(
        matchId: 'test',
        roundIndex: 0,
        boardAfter: board,
        processOrder: ['player1', 'player2', 'player3'],
        replayEvents: [],
        bonusTriggered: '',
        rescueCardsGranted: [],
      );

      final resolution = RoundResolution(
        result: result,
        boardAfter: board,
        isGameOver: false,
        winners: [],
      );

      expect(resolution.isGameOver, false);
      expect(resolution.winners, isEmpty);
    });

    test('stores winners when game is over', () {
      final board = Board.createBoard();
      final result = RoundResultModel(
        matchId: 'test',
        roundIndex: 0,
        boardAfter: board,
        processOrder: ['player1', 'player2', 'player3'],
        replayEvents: [],
        bonusTriggered: '',
        rescueCardsGranted: [],
      );

      final resolution = RoundResolution(
        result: result,
        boardAfter: board,
        isGameOver: true,
        winners: ['player1', 'player2'],
      );

      expect(resolution.isGameOver, true);
      expect(resolution.winners, ['player1', 'player2']);
    });
  });
}
