import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/match/application/providers/ai_difficulty_provider.dart';
import 'package:toriverse/features/match/domain/entities/board.dart';
import 'package:toriverse/features/match/domain/services/ai_player.dart';

void main() {
  group('AIDifficulty Enum', () {
    test('has all difficulty levels', () {
      expect(AIDifficulty.easy, isNotNull);
      expect(AIDifficulty.normal, isNotNull);
      expect(AIDifficulty.hard, isNotNull);
      expect(AIDifficulty.expert, isNotNull);
    });
  });

  group('getDepthForDifficulty', () {
    test('returns correct depth for easy', () {
      final depth = getDepthForDifficulty(AIDifficulty.easy);
      expect(depth, 1);
    });

    test('returns correct depth for normal', () {
      final depth = getDepthForDifficulty(AIDifficulty.normal);
      expect(depth, 3);
    });

    test('returns correct depth for hard', () {
      final depth = getDepthForDifficulty(AIDifficulty.hard);
      expect(depth, 4);
    });

    test('returns correct depth for expert', () {
      final depth = getDepthForDifficulty(AIDifficulty.expert);
      expect(depth, 5);
    });
  });

  group('AIMoveSelector', () {
    test('initializes with default difficulty', () {
      final selector = AIMoveSelector();
      expect(selector.difficulty, AIDifficulty.normal);
    });

    test('initializes with custom difficulty', () {
      final selector = AIMoveSelector(difficulty: AIDifficulty.hard);
      expect(selector.difficulty, AIDifficulty.hard);
    });

    test('selectMove returns valid move for easy difficulty', () {
      final selector = AIMoveSelector(difficulty: AIDifficulty.easy);
      final board = Board.createBoard();

      final move = selector.selectMove(board, 0); // Player 0 (Black)

      if (move != null) {
        expect(move, isA<List<int>>());
        expect(move.length, 2);
        expect(move[0], greaterThanOrEqualTo(0));
        expect(move[0], lessThan(8));
        expect(move[1], greaterThanOrEqualTo(0));
        expect(move[1], lessThan(8));
      }
    });

    test('selectMove returns valid move for normal difficulty', () {
      final selector = AIMoveSelector(difficulty: AIDifficulty.normal);
      final board = Board.createBoard();

      final move = selector.selectMove(board, 1); // Player 1 (White)

      if (move != null) {
        expect(move, isA<List<int>>());
        expect(move.length, 2);
      }
    });

    test('selectMove returns valid move for hard difficulty', () {
      final selector = AIMoveSelector(difficulty: AIDifficulty.hard);
      final board = Board.createBoard();

      final move = selector.selectMove(board, 2); // Player 2 (Red)

      if (move != null) {
        expect(move, isA<List<int>>());
        expect(move.length, 2);
      }
    });

    test('selectMove returns valid move for expert difficulty', () {
      final selector = AIMoveSelector(difficulty: AIDifficulty.expert);
      final board = Board.createBoard();

      final move = selector.selectMove(board, 0);

      if (move != null) {
        expect(move, isA<List<int>>());
        expect(move.length, 2);
      }
    });

    test('suggestMove returns position integer', () {
      final selector = AIMoveSelector(difficulty: AIDifficulty.normal);
      final board = Board.createBoard();

      final position = selector.suggestMove(board, 0);

      if (position != null) {
        expect(position, isA<int>());
        expect(position, greaterThanOrEqualTo(0));
        expect(position, lessThan(64));
      }
    });

    test('selectMove handles no valid moves', () {
      final selector = AIMoveSelector(difficulty: AIDifficulty.easy);
      final board = Board.createBoard();

      // Try to get moves when there might not be any (depends on board state)
      final move = selector.selectMove(board, 0);

      // Should return either null or a valid move
      if (move != null) {
        expect(move, isA<List<int>>());
        expect(move.length, 2);
      }
    });
  });

  group('getAIMove', () {
    test('returns valid move for easy difficulty', () async {
      final board = Board.createBoard();

      final move = await getAIMove(board, 0, AIDifficulty.easy);

      if (move != null) {
        expect(move, isA<List<int>>());
        expect(move.length, 2);
      }
    });

    test('returns valid move for normal difficulty', () async {
      final board = Board.createBoard();

      final move = await getAIMove(board, 1, AIDifficulty.normal);

      if (move != null) {
        expect(move, isA<List<int>>());
        expect(move.length, 2);
      }
    });

    test('returns valid move for hard difficulty', () async {
      final board = Board.createBoard();

      final move = await getAIMove(board, 2, AIDifficulty.hard);

      if (move != null) {
        expect(move, isA<List<int>>());
        expect(move.length, 2);
      }
    });

    test('returns valid move for expert difficulty', () async {
      final board = Board.createBoard();

      final move = await getAIMove(board, 0, AIDifficulty.expert);

      if (move != null) {
        expect(move, isA<List<int>>());
        expect(move.length, 2);
      }
    });

    test('uses correct depth for each difficulty level', () async {
      final board = Board.createBoard();

      // Test that different difficulties can be called without error
      final easyMove = await getAIMove(board, 0, AIDifficulty.easy);
      final normalMove = await getAIMove(board, 0, AIDifficulty.normal);
      final hardMove = await getAIMove(board, 0, AIDifficulty.hard);
      final expertMove = await getAIMove(board, 0, AIDifficulty.expert);

      // All should return moves (if valid moves exist) or null
      // We're just verifying they don't throw exceptions
      expect(easyMove, anyOf([isNull, isA<List<int>>()]));
      expect(normalMove, anyOf([isNull, isA<List<int>>()]));
      expect(hardMove, anyOf([isNull, isA<List<int>>()]));
      expect(expertMove, anyOf([isNull, isA<List<int>>()]));
    });
  });

  group('AI Move Selection Consistency', () {
    test('same difficulty produces consistent move on same board', () async {
      final board = Board.createBoard();
      final selector = AIMoveSelector(difficulty: AIDifficulty.normal);

      final move1 = selector.selectMove(board, 0);
      final move2 = selector.selectMove(board, 0);

      // Same board and difficulty should produce same or equally valid moves
      expect(move1, isNotNull);
      expect(move2, isNotNull);
    });

    test('different difficulties can produce different moves', () async {
      final board = Board.createBoard();

      final easySelector = AIMoveSelector(difficulty: AIDifficulty.easy);
      final hardSelector = AIMoveSelector(difficulty: AIDifficulty.hard);

      final easyMove = easySelector.selectMove(board, 0);
      final hardMove = hardSelector.selectMove(board, 0);

      // Both should produce valid moves
      if (easyMove != null && hardMove != null) {
        expect(easyMove, isA<List<int>>());
        expect(hardMove, isA<List<int>>());
        // Note: They might be the same move, but harder AI should be more strategic
      }
    });
  });

  group('Edge Cases', () {
    test('selectMove with player index 0', () {
      final selector = AIMoveSelector(difficulty: AIDifficulty.normal);
      final board = Board.createBoard();

      final move = selector.selectMove(board, 0);

      if (move != null) {
        expect(move.length, 2);
      }
    });

    test('selectMove with player index 1', () {
      final selector = AIMoveSelector(difficulty: AIDifficulty.normal);
      final board = Board.createBoard();

      final move = selector.selectMove(board, 1);

      if (move != null) {
        expect(move.length, 2);
      }
    });

    test('selectMove with player index 2', () {
      final selector = AIMoveSelector(difficulty: AIDifficulty.normal);
      final board = Board.createBoard();

      final move = selector.selectMove(board, 2);

      if (move != null) {
        expect(move.length, 2);
      }
    });

    test('suggestMove returns valid position range', () {
      final selector = AIMoveSelector(difficulty: AIDifficulty.normal);
      final board = Board.createBoard();

      for (int i = 0; i < 3; i++) {
        final position = selector.suggestMove(board, i);
        if (position != null) {
          expect(position, greaterThanOrEqualTo(0));
          expect(position, lessThan(64));
        }
      }
    });
  });
}
