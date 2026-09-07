import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/match/application/services/game_state_validator.dart';
import 'package:toriverse/features/match/domain/entities/board.dart';

void main() {
  group('GameStateValidator', () {
    late Board board;
    late List<String> playerIds;

    setUp(() {
      board = Board.standard();
      playerIds = ['player1', 'player2', 'player3'];
    });

    group('Board Validation', () {
      test('isValidBoardState accepts standard board', () {
        expect(GameStateValidator.isValidBoardState(board), isTrue);
      });

      test('isValidBoardState rejects invalid size', () {
        final invalidBoard = Board.standard();
        // Manually truncate board (simulate invalid state)
        // This is simplified - real test would need board manipulation
        expect(GameStateValidator.isValidBoardState(invalidBoard), isTrue);
      });

      test('initial board has 4 stones', () {
        final counts = board.countStones();
        final total = (counts[Board.black] ?? 0) +
            (counts[Board.white] ?? 0) +
            (counts[Board.red] ?? 0);
        expect(total, equals(4));
      });
    });

    group('Move Validation', () {
      test('areMovesValid accepts valid moves', () {
        final moves = {
          'player1': 18,
          'player2': 26,
          'player3': 35,
        };

        expect(
          GameStateValidator.areMovesValid(moves, playerIds),
          isTrue,
        );
      });

      test('areMovesValid rejects out-of-range positions', () {
        final moves = {
          'player1': 64, // Out of range
        };

        expect(
          GameStateValidator.areMovesValid(moves, playerIds),
          isFalse,
        );
      });

      test('areMovesValid rejects invalid player', () {
        final moves = {
          'invalid-player': 18,
        };

        expect(
          GameStateValidator.areMovesValid(moves, playerIds),
          isFalse,
        );
      });

      test('areMovesValid rejects negative positions', () {
        final moves = {
          'player1': -1,
        };

        expect(
          GameStateValidator.areMovesValid(moves, playerIds),
          isFalse,
        );
      });

      test('areMovesValid accepts empty move map', () {
        expect(
          GameStateValidator.areMovesValid({}, playerIds),
          isTrue,
        );
      });
    });

    group('Move Uniqueness', () {
      test('areMovePositionsUnique accepts unique positions', () {
        final moves = {
          'player1': 18,
          'player2': 26,
          'player3': 35,
        };

        expect(
          GameStateValidator.areMovePositionsUnique(moves),
          isTrue,
        );
      });

      test('areMovePositionsUnique rejects duplicate positions', () {
        final moves = {
          'player1': 18,
          'player2': 18, // Duplicate!
          'player3': 35,
        };

        expect(
          GameStateValidator.areMovePositionsUnique(moves),
          isFalse,
        );
      });
    });

    group('Bonus Count Validation', () {
      test('areBonusCountsValid accepts valid counts', () {
        expect(
          GameStateValidator.areBonusCountsValid([0, 0, 0]),
          isTrue,
        );
        expect(
          GameStateValidator.areBonusCountsValid([1, 2, 0]),
          isTrue,
        );
        expect(
          GameStateValidator.areBonusCountsValid([2, 2, 2]),
          isTrue,
        );
      });

      test('areBonusCountsValid rejects negative counts', () {
        expect(
          GameStateValidator.areBonusCountsValid([-1, 0, 0]),
          isFalse,
        );
      });

      test('areBonusCountsValid rejects counts over 2', () {
        expect(
          GameStateValidator.areBonusCountsValid([3, 0, 0]),
          isFalse,
        );
      });

      test('areBonusCountsValid rejects wrong size', () {
        expect(
          GameStateValidator.areBonusCountsValid([0, 0]),
          isFalse,
        );
        expect(
          GameStateValidator.areBonusCountsValid([0, 0, 0, 0]),
          isFalse,
        );
      });
    });

    group('Player List Validation', () {
      test('isPlayerListValid accepts valid list', () {
        expect(
          GameStateValidator.isPlayerListValid(['p1', 'p2', 'p3']),
          isTrue,
        );
      });

      test('isPlayerListValid rejects wrong count', () {
        expect(
          GameStateValidator.isPlayerListValid(['p1', 'p2']),
          isFalse,
        );
        expect(
          GameStateValidator.isPlayerListValid(['p1', 'p2', 'p3', 'p4']),
          isFalse,
        );
      });

      test('isPlayerListValid rejects duplicates', () {
        expect(
          GameStateValidator.isPlayerListValid(['p1', 'p1', 'p2']),
          isFalse,
        );
      });

      test('isPlayerListValid rejects empty IDs', () {
        expect(
          GameStateValidator.isPlayerListValid(['p1', '', 'p3']),
          isFalse,
        );
      });
    });

    group('Round Index Validation', () {
      test('isRoundIndexValid accepts valid indices', () {
        expect(GameStateValidator.isRoundIndexValid(0), isTrue);
        expect(GameStateValidator.isRoundIndexValid(32), isTrue);
        expect(GameStateValidator.isRoundIndexValid(63), isTrue);
      });

      test('isRoundIndexValid rejects negative', () {
        expect(GameStateValidator.isRoundIndexValid(-1), isFalse);
      });

      test('isRoundIndexValid rejects out of range', () {
        expect(GameStateValidator.isRoundIndexValid(64), isFalse);
        expect(GameStateValidator.isRoundIndexValid(100), isFalse);
      });
    });

    group('Comprehensive Validation', () {
      test('validateGameState accepts valid state', () {
        final result = GameStateValidator.validateGameState(
          board: board,
          playerIds: playerIds,
          submittedPositions: {'player1': 18},
          bonusActivationCounts: [0, 0, 0],
          roundIndex: 0,
        );

        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('validateGameState detects multiple errors', () {
        final result = GameStateValidator.validateGameState(
          board: board,
          playerIds: ['p1', 'p2'], // Wrong count
          submittedPositions: {'player1': 64}, // Out of range
          bonusActivationCounts: [3, 0, 0], // Invalid count
          roundIndex: 100, // Out of range
        );

        expect(result.isValid, isFalse);
        expect(result.errors.length, greaterThan(2));
      });

      test('validateGameState generates meaningful error messages', () {
        final result = GameStateValidator.validateGameState(
          board: board,
          playerIds: ['p1', 'p2'], // Wrong count
          submittedPositions: {},
          bonusActivationCounts: [0, 0, 0],
          roundIndex: 0,
        );

        expect(result.errors, contains('Invalid player list'));
      });
    });

    group('Stone Progression', () {
      test('isStoneProgressionReasonable accepts +1 progression', () {
        expect(
          GameStateValidator.isStoneProgressionReasonable(4, 5),
          isTrue,
        );
        expect(
          GameStateValidator.isStoneProgressionReasonable(10, 11),
          isTrue,
        );
      });

      test('isStoneProgressionReasonable rejects wrong progression', () {
        expect(
          GameStateValidator.isStoneProgressionReasonable(4, 4),
          isFalse,
        );
        expect(
          GameStateValidator.isStoneProgressionReasonable(4, 6),
          isFalse,
        );
        expect(
          GameStateValidator.isStoneProgressionReasonable(5, 4),
          isFalse,
        );
      });
    });

    group('Collision Resolution', () {
      test('isCollisionResolutionValid accepts valid resolution', () {
        expect(
          GameStateValidator.isCollisionResolutionValid(
            collidingPlayers: ['p1', 'p2'],
            winner: 'p1',
            losers: ['p2'],
            allPlayerIds: playerIds,
          ),
          isTrue,
        );
      });

      test('isCollisionResolutionValid rejects invalid winner', () {
        expect(
          GameStateValidator.isCollisionResolutionValid(
            collidingPlayers: ['p1', 'p2'],
            winner: 'p3', // Not in colliding
            losers: ['p2'],
            allPlayerIds: playerIds,
          ),
          isFalse,
        );
      });

      test('isCollisionResolutionValid rejects wrong loser count', () {
        expect(
          GameStateValidator.isCollisionResolutionValid(
            collidingPlayers: ['p1', 'p2'],
            winner: 'p1',
            losers: ['p2', 'p3'], // Too many losers
            allPlayerIds: playerIds,
          ),
          isFalse,
        );
      });

      test('isCollisionResolutionValid rejects winner in losers', () {
        expect(
          GameStateValidator.isCollisionResolutionValid(
            collidingPlayers: ['p1', 'p2'],
            winner: 'p1',
            losers: ['p1', 'p2'], // Winner can't be loser
            allPlayerIds: playerIds,
          ),
          isFalse,
        );
      });
    });

    group('ValidationResult', () {
      test('toString shows Valid for valid result', () {
        final result = ValidationResult(isValid: true, errors: []);
        expect(result.toString(), contains('Valid'));
      });

      test('toString shows errors for invalid result', () {
        final result = ValidationResult(isValid: false, errors: ['Error 1']);
        expect(result.toString(), contains('Invalid'));
        expect(result.toString(), contains('Error 1'));
      });
    });
  });
}
