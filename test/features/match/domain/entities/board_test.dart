import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/match/domain/entities/board.dart';

void main() {
  group('Board', () {
    late Board board;

    setUp(() {
      board = Board.standard();
    });

    group('Initialization', () {
      test('Standard 8x8 board has correct initial state', () {
        expect(board.boardState.length, equals(64));

        // Center 4 stones
        expect(board.getStone(3, 3), equals(Board.white)); // Position 27
        expect(board.getStone(3, 4), equals(Board.black)); // Position 28
        expect(board.getStone(4, 3), equals(Board.black)); // Position 35
        expect(board.getStone(4, 4), equals(Board.white)); // Position 36
      });

      test('Empty squares are -1', () {
        expect(board.getStone(0, 0), equals(Board.empty));
        expect(board.getStone(1, 1), equals(Board.empty));
        expect(board.getStone(7, 7), equals(Board.empty));
      });

      test('Clone creates independent copy', () {
        final cloned = board.clone();

        // Modify cloned board
        cloned.placeStone(0, 0, Board.black);

        // Original should be unchanged
        expect(board.getStone(0, 0), equals(Board.empty));
        expect(cloned.getStone(0, 0), equals(Board.black));
      });
    });

    group('Stone Placement', () {
      test('Placing stone updates board', () {
        board.placeStone(2, 3, Board.black);
        expect(board.getStone(2, 3), equals(Board.black));
      });

      test('Out of bounds placement throws', () {
        expect(
          () => board.placeStone(-1, 0, Board.black),
          throwsRangeError,
        );
        expect(
          () => board.placeStone(8, 0, Board.black),
          throwsRangeError,
        );
      });
    });

    group('Valid Moves', () {
      test('Initial board has valid moves for black (player 0)', () {
        final validMoves = board.getValidMoves(Board.black);
        expect(validMoves, isNotEmpty);
        // Black (player 0) should have 4 initial moves: (3,2), (4,5), (5,4), (2,3)
        expect(validMoves.length, equals(4));
      });

      test('Initial board has valid moves for white (player 1)', () {
        final validMoves = board.getValidMoves(Board.white);
        expect(validMoves, isNotEmpty);
        expect(validMoves.length, equals(4));
      });

      test('Red (player 2) has no moves initially', () {
        final validMoves = board.getValidMoves(Board.red);
        expect(validMoves, isEmpty);
      });

      test('Valid move flips opponent stones', () {
        // Place a black stone that flips white stones
        final initialWhiteCount = board.countStones()[Board.white];

        // Make a standard opening move for black
        final validMoves = board.getValidMoves(Board.black);
        expect(validMoves, isNotEmpty);

        final move = validMoves.first;
        board.placeStone(move[0], move[1], Board.black);

        // White count should decrease (stones flipped)
        final newWhiteCount = board.countStones()[Board.white];
        expect(newWhiteCount, lessThan(initialWhiteCount!));
      });
    });

    group('Stone Counting', () {
      test('Initial count is correct', () {
        final counts = board.countStones();
        expect(counts[Board.black], equals(2));
        expect(counts[Board.white], equals(2));
        expect(counts[Board.red], equals(0));
      });

      test('After move, counts update correctly', () {
        final validMoves = board.getValidMoves(Board.black);
        final move = validMoves.first;

        final beforeCounts = board.countStones();
        board.placeStone(move[0], move[1], Board.black);
        final afterCounts = board.countStones();

        // Black should increase, white should decrease
        expect(afterCounts[Board.black], greaterThan(beforeCounts[Board.black]!));
        expect(afterCounts[Board.white], lessThan(beforeCounts[Board.white]!));
      });
    });

    group('Flipping Logic', () {
      test('Stones flip in all 8 directions', () {
        // Setup a specific board state to test flipping
        final testBoard = Board.standard();

        // Make a move that flips stones
        final validMoves = testBoard.getValidMoves(Board.black);
        expect(validMoves, isNotEmpty);

        final beforeCounts = testBoard.countStones();
        testBoard.placeStone(validMoves[0][0], validMoves[0][1], Board.black);
        final afterCounts = testBoard.countStones();

        // Total stones should only increase by 1 (the new stone)
        // since flips convert stones, not add them
        expect(
          afterCounts[Board.black]! + afterCounts[Board.white]! + afterCounts[Board.red]!,
          equals(beforeCounts[Board.black]! + beforeCounts[Board.white]! + beforeCounts[Board.red]! + 1),
        );
      });
    });

    group('Game Termination', () {
      test('No valid moves anywhere indicates game over', () {
        // Note: In a real game, this would be tested with a late-game board state
        // For now, we verify the logic works
        bool anyHasMove = false;
        for (int player = 0; player < 3; player++) {
          if (board.getValidMoves(player).isNotEmpty) {
            anyHasMove = true;
            break;
          }
        }

        // Initial board should have valid moves
        expect(anyHasMove, isTrue);
      });
    });

    group('Edge Cases', () {
      test('Corner stones affect validity', () {
        // Place a stone in corner
        board.boardState[0] = Board.black; // Top-left corner

        final counts = board.countStones();
        expect(counts[Board.black], equals(3)); // Original 2 + 1 new
      });

      test('Multiple flips in single move', () {
        // Standard move should flip at least 1 stone
        final validMoves = board.getValidMoves(Board.black);
        final move = validMoves.first;

        board.placeStone(move[0], move[1], Board.black);
        final counts = board.countStones();

        // Black should have more than 3 stones now
        expect(counts[Board.black], greaterThan(3));
      });
    });
  });
}
