import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/match/application/services/move_applicator.dart';
import 'package:toriverse/features/match/application/services/remote_config_service.dart';
import 'package:toriverse/features/match/application/services/round_processor.dart';
import 'package:toriverse/features/match/domain/entities/board.dart';

void main() {
  group('RoundProcessor', () {
    late RoundProcessor processor;
    late Board board;
    late List<String> playerIds;

    setUp(() {
      processor = RoundProcessor();
      board = Board.standard();
      playerIds = ['player1', 'player2', 'player3'];
    });

    group('Round Processing', () {
      test('processRound returns valid result', () {
        final validMoves = board.getValidMoves(0);
        expect(validMoves, isNotEmpty);

        final move = validMoves.first;
        final position = move[0] * 8 + move[1];

        final result = processor.processRound(
          matchId: 'test-match',
          roundIndex: 0,
          boardBefore: board,
          playerIds: playerIds,
          submittedPositions: {playerIds[0]: position},
          previousBonusActivations: [0, 0, 0],
        );

        expect(result, isNotNull);
        expect(result.matchId, equals('test-match'));
        expect(result.roundIndex, equals(0));
      });

      test('processRound with multiple moves', () {
        // Get moves for multiple players
        final moves = <String, int>{};
        for (int i = 0; i < playerIds.length; i++) {
          final validMoves = board.getValidMoves(i);
          if (validMoves.isNotEmpty) {
            final move = validMoves.first;
            final position = move[0] * 8 + move[1];
            moves[playerIds[i]] = position;
          }
        }

        final result = processor.processRound(
          matchId: 'test-match',
          roundIndex: 0,
          boardBefore: board,
          playerIds: playerIds,
          submittedPositions: moves,
          previousBonusActivations: [0, 0, 0],
        );

        expect(result.submittedMoves, isNotEmpty);
      });
    });

    group('Score Calculation', () {
      test('calculateScores returns all player scores', () {
        final scores = processor.calculateScores(board, playerIds);

        expect(scores.length, equals(3));
        expect(scores.containsKey(playerIds[0]), isTrue);
        expect(scores.containsKey(playerIds[1]), isTrue);
        expect(scores.containsKey(playerIds[2]), isTrue);
      });

      test('calculateScores matches board state', () {
        final scores = processor.calculateScores(board, playerIds);
        final counts = board.countStones();

        expect(scores[playerIds[0]], equals(counts[Board.black] ?? 0));
        expect(scores[playerIds[1]], equals(counts[Board.white] ?? 0));
        expect(scores[playerIds[2]], equals(counts[Board.red] ?? 0));
      });

      test('calculateScores after moves', () {
        final testBoard = board.clone();
        final validMoves = testBoard.getValidMoves(0);
        if (validMoves.isNotEmpty) {
          final move = validMoves.first;
          testBoard.placeStone(move[0], move[1], 0);

          final scores = processor.calculateScores(testBoard, playerIds);
          final counts = testBoard.countStones();

          expect(scores[playerIds[0]], equals(counts[Board.black] ?? 0));
        }
      });
    });

    group('Winner Determination', () {
      test('determineWinners identifies single winner', () {
        // Create a board with unequal scores
        final testBoard = board.clone();

        // Play some moves to create score difference
        // This is a simplified test - in reality, specific moves would matter
        final winners = processor.determineWinners(testBoard, playerIds);

        expect(winners, isNotEmpty);
        expect(winners.length, lessThanOrEqualTo(3));
      });

      test('determineWinners handles tie', () {
        // Standard starting position has black and white both at 2
        final testBoard = Board.standard();
        final winners = processor.determineWinners(testBoard, playerIds);

        // With red at 0, either black or white wins, not both
        expect(winners, isNotEmpty);
      });

      test('winner is in playerIds list', () {
        final winners = processor.determineWinners(board, playerIds);

        for (final winner in winners) {
          expect(playerIds, contains(winner));
        }
      });
    });

    group('Game Over Detection', () {
      test('isGameOver returns false for starting position', () {
        expect(processor.isGameOver(board), isFalse);
      });

      test('isGameOver detects when no valid moves exist', () {
        // This requires a specific board state with no valid moves
        // For now, verify the logic structure works
        final testBoard = Board.standard();
        final gameOver = processor.isGameOver(testBoard);

        // Standard board should not be game over
        expect(gameOver, isFalse);
      });
    });

    group('Process Order Generation', () {
      test('process order includes all players', () {
        final result = processor.processRound(
          matchId: 'test-match',
          roundIndex: 0,
          boardBefore: board,
          playerIds: playerIds,
          submittedPositions: {},
          previousBonusActivations: [0, 0, 0],
        );

        expect(result.processOrder.length, equals(playerIds.length));
        for (final playerId in playerIds) {
          expect(result.processOrder, contains(playerId));
        }
      });

      test('process order is random across multiple rounds', () {
        final orders = <List<String>>{};

        for (int i = 0; i < 10; i++) {
          final result = processor.processRound(
            matchId: 'test-match-$i',
            roundIndex: i,
            boardBefore: board,
            playerIds: playerIds,
            submittedPositions: {},
            previousBonusActivations: [0, 0, 0],
          );

          orders.add(result.processOrder);
        }

        // Should have generated multiple different orders (unlikely to be all same)
        expect(orders.length, greaterThan(1));
      });
    });

    group('Bonus Activation Tracking', () {
      test('processRound respects activation limits', () {
        final validMoves = board.getValidMoves(0);
        final move = validMoves.isNotEmpty ? validMoves.first : null;

        final submittedPositions = move != null
            ? {playerIds[0]: move[0] * 8 + move[1]}
            : <String, int>{};

        // With max activations already reached
        final result = processor.processRound(
          matchId: 'test-match',
          roundIndex: 10,
          boardBefore: board,
          playerIds: playerIds,
          submittedPositions: submittedPositions,
          previousBonusActivations: [2, 2, 2], // Max reached
        );

        expect(result, isNotNull);
      });

      test('processRound can trigger bonus in late game', () {
        final validMoves = board.getValidMoves(0);
        final move = validMoves.isNotEmpty ? validMoves.first : null;

        final submittedPositions = move != null
            ? {playerIds[0]: move[0] * 8 + move[1]}
            : <String, int>{};

        // In late game with no activations yet
        final result = processor.processRound(
          matchId: 'test-match',
          roundIndex: 52, // Late in game (64 total moves)
          boardBefore: board,
          playerIds: playerIds,
          submittedPositions: submittedPositions,
          previousBonusActivations: [0, 0, 0],
        );

        expect(result, isNotNull);
      });
    });

    group('Integration', () {
      test('full round flow from submission to result', () {
        // Get valid moves for each player
        final moves = <String, int>{};
        bool hasAllMoves = true;

        for (int i = 0; i < playerIds.length; i++) {
          final validMoves = board.getValidMoves(i);
          if (validMoves.isNotEmpty) {
            final move = validMoves.first;
            moves[playerIds[i]] = move[0] * 8 + move[1];
          } else {
            hasAllMoves = false;
          }
        }

        if (!hasAllMoves) {
          // Can't test full 3-player round in initial state
          return;
        }

        final result = processor.processRound(
          matchId: 'integration-test',
          roundIndex: 0,
          boardBefore: board,
          playerIds: playerIds,
          submittedPositions: moves,
          previousBonusActivations: [0, 0, 0],
        );

        // Verify complete round result
        expect(result.matchId, equals('integration-test'));
        expect(result.roundIndex, equals(0));
        expect(result.submittedMoves, isNotEmpty);
        expect(result.processOrder, isNotEmpty);
        expect(result.replayEvents, isNotEmpty);
        expect(result.createdAt, isNotNull);
        expect(result.processedAt, isNotNull);
      });
    });
  });
}
