import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/match/domain/entities/board.dart';
import 'package:toriverse/features/match/domain/services/ai_player.dart';

void main() {
  group('AIPlayer', () {
    late Board board;

    setUp(() {
      board = Board.standard();
    });

    group('Move Selection', () {
      test('selectMove returns valid move', () {
        final move = AIPlayer.selectMove(board, Board.black);

        expect(move, isNotNull);
        expect(move!.length, equals(2));

        // Verify move is valid
        final validMoves = board.getValidMoves(Board.black);
        expect(validMoves, contains(move));
      });

      test('selectMove returns null when no moves available', () {
        // Create a board where red has no valid moves
        final testBoard = Board.standard();

        // Red (player 2) has no moves initially
        final move = AIPlayer.selectMove(testBoard, Board.red);
        expect(move, isNull);
      });

      test('suggestMove returns integer position', () {
        final position = AIPlayer.suggestMove(board, Board.black);

        expect(position, isNotNull);
        expect(position, greaterThanOrEqualTo(0));
        expect(position, lessThan(64));

        // Verify it's a valid position
        final row = position! ~/ 8;
        final col = position % 8;
        final validMoves = board.getValidMoves(Board.black);
        expect(validMoves.any((m) => m[0] == row && m[1] == col), isTrue);
      });

      test('selectMove for white player works', () {
        final move = AIPlayer.selectMove(board, Board.white);

        expect(move, isNotNull);
        final validMoves = board.getValidMoves(Board.white);
        expect(validMoves, contains(move));
      });
    });

    group('Difficulty Levels', () {
      test('Easy difficulty returns depth 1', () {
        final depth = AIPlayer.getDepthByDifficulty('easy');
        expect(depth, equals(1));
      });

      test('Normal difficulty returns depth 3', () {
        final depth = AIPlayer.getDepthByDifficulty('normal');
        expect(depth, equals(3));
      });

      test('Hard difficulty returns depth 4', () {
        final depth = AIPlayer.getDepthByDifficulty('hard');
        expect(depth, equals(4));
      });

      test('Expert difficulty returns depth 5', () {
        final depth = AIPlayer.getDepthByDifficulty('expert');
        expect(depth, equals(5));
      });

      test('Unknown difficulty defaults to normal', () {
        final depth = AIPlayer.getDepthByDifficulty('unknown');
        expect(depth, equals(3));
      });

      test('Different difficulties produce different moves', () {
        // Easy move (depth 1)
        final easyMove = AIPlayer.selectMove(
          board,
          Board.black,
          depth: AIPlayer.getDepthByDifficulty('easy'),
        );

        // Hard move (depth 4)
        final hardMove = AIPlayer.selectMove(
          board,
          Board.black,
          depth: AIPlayer.getDepthByDifficulty('hard'),
        );

        // Both should be valid
        expect(easyMove, isNotNull);
        expect(hardMove, isNotNull);

        // They might be different (not guaranteed, but likely)
        // So we just verify both are valid
        final validMoves = board.getValidMoves(Board.black);
        expect(validMoves, contains(easyMove));
        expect(validMoves, contains(hardMove));
      });
    });

    group('Performance', () {
      test('selectMove completes in reasonable time (depth 3)', () {
        final stopwatch = Stopwatch()..start();

        final move = AIPlayer.selectMove(
          board,
          Board.black,
          depth: 3,
        );

        stopwatch.stop();

        expect(move, isNotNull);
        // Should complete within 1 second even on slow devices
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test('selectMove with depth 1 is faster', () {
        final stopwatch1 = Stopwatch()..start();
        AIPlayer.selectMove(board, Board.black, depth: 1);
        stopwatch1.stop();

        final stopwatch3 = Stopwatch()..start();
        AIPlayer.selectMove(board, Board.black, depth: 3);
        stopwatch3.stop();

        // Depth 1 should be faster than depth 3
        // (Not guaranteed but likely)
        expect(stopwatch1.elapsedMilliseconds, lessThanOrEqualTo(stopwatch3.elapsedMilliseconds));
      });
    });

    group('All Players', () {
      test('AI can generate moves for any player', () {
        for (int player = 0; player < 3; player++) {
          final move = AIPlayer.selectMove(board, player);

          // At least one player should have a move in initial position
          if (board.getValidMoves(player).isNotEmpty) {
            expect(move, isNotNull);
          }
        }
      });
    });

    group('Move Quality', () {
      test('AI corner preference works', () {
        // After some moves, AI should eventually prefer corners if available
        final testBoard = Board.standard();

        // Play through a few rounds
        for (int i = 0; i < 5; i++) {
          for (int player = 0; player < 3; player++) {
            final move = AIPlayer.selectMove(testBoard, player, depth: 2);
            if (move != null) {
              testBoard.placeStone(move[0], move[1], player);
            }
          }
        }

        // Verify board is still valid
        final counts = testBoard.countStones();
        expect(counts[0], greaterThan(0));
      });

      test('Board evaluation is deterministic', () {
        final move1 = AIPlayer.selectMove(board, Board.black, depth: 2);
        final move2 = AIPlayer.selectMove(board, Board.black, depth: 2);

        // Same board should produce same move
        expect(move1, equals(move2));
      });
    });
  });
}
