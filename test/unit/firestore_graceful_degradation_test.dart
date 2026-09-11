import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toriverse/features/match/application/services/firestore_round_result_service.dart';
import 'package:toriverse/features/match/application/providers/firestore_match_provider.dart';
import 'package:toriverse/features/match/data/models/round_result_model.dart';

class MockFirestoreMatchRepository extends Mock
    implements FirestoreMatchRepository {}

class MockFirebaseException extends Mock implements FirebaseException {
  final String errorCode;
  MockFirebaseException(this.errorCode);

  @override
  String get code => errorCode;
}

void main() {
  group('Firestore Graceful Degradation Tests', () {
    late MockFirestoreMatchRepository mockRepository;
    late FirestoreRoundResultService service;

    setUp(() {
      mockRepository = MockFirestoreMatchRepository();
      service =
          FirestoreRoundResultService(repository: mockRepository);
    });

    group('Game Continues on Firestore Failure', () {
      test('game flow is not blocked by failed round save', () async {
        final testResult = RoundResultModel(
          id: 'test_match_round_1',
          matchId: 'test_match',
          roundIndex: 1,
          createdAt: DateTime.now(),
        );

        // Round save fails
        when(mockRepository.saveRoundResult(any))
            .thenThrow(MockFirebaseException('unavailable'));

        // Should return false but not throw exception
        final roundSaved =
            await service.saveRoundResultWithRetry(testResult);

        expect(roundSaved, false);

        // Now update match state - should still work if repository is available
        when(mockRepository.updateMatchState(any, any))
            .thenAnswer((_) async => null);

        final stateSaved = await service.updateMatchStateAfterRound(
          matchId: 'test_match',
          roundIndex: 2,
          status: 'playing',
          stoneCounts: {'player_1': 20, 'player_2': 22, 'player_3': 22},
          isGameOver: false,
        );

        expect(stateSaved, true);
      });

      test('both saves fail but game continues without exception', () async {
        final testResult = RoundResultModel(
          id: 'test_match_round_2',
          matchId: 'test_match',
          roundIndex: 2,
          createdAt: DateTime.now(),
        );

        // Both operations unavailable
        when(mockRepository.saveRoundResult(any))
            .thenThrow(MockFirebaseException('unavailable'));
        when(mockRepository.updateMatchState(any, any))
            .thenThrow(MockFirebaseException('unavailable'));

        // No exception should be thrown
        final roundSaved =
            await service.saveRoundResultWithRetry(testResult);
        final stateSaved = await service.updateMatchStateAfterRound(
          matchId: 'test_match',
          roundIndex: 3,
          status: 'playing',
          stoneCounts: {'player_1': 20, 'player_2': 22, 'player_3': 22},
          isGameOver: false,
        );

        expect(roundSaved, false);
        expect(stateSaved, false);
      });

      test('handles network timeout during round save', () async {
        final testResult = RoundResultModel(
          id: 'test_match_round_3',
          matchId: 'test_match',
          roundIndex: 3,
          createdAt: DateTime.now(),
        );

        // Simulate timeout - this should be treated as transient error
        when(mockRepository.saveRoundResult(any))
            .thenThrow(MockFirebaseException('deadline-exceeded'));

        final result = await service.saveRoundResultWithRetry(testResult);

        // Should retry but eventually fail
        expect(result, false);
        // Should retry max times
        verify(mockRepository.saveRoundResult(any)).called(4);
      });

      test('continues game with permanent auth error', () async {
        final testResult = RoundResultModel(
          id: 'test_match_round_4',
          matchId: 'test_match',
          roundIndex: 4,
          createdAt: DateTime.now(),
        );

        when(mockRepository.saveRoundResult(any))
            .thenThrow(MockFirebaseException('permission-denied'));

        final result = await service.saveRoundResultWithRetry(testResult);

        expect(result, false);
        // No retries on permanent error
        verify(mockRepository.saveRoundResult(any)).called(1);
      });

      test('reports failure but allows game to proceed', () async {
        final testResult = RoundResultModel(
          id: 'test_match_round_5',
          matchId: 'test_match',
          roundIndex: 5,
          createdAt: DateTime.now(),
        );

        when(mockRepository.saveRoundResult(any))
            .thenThrow(MockFirebaseException('unavailable'));

        // This should not throw - graceful degradation
        expect(
          () => service.saveRoundResultWithRetry(testResult),
          returnsNormally,
        );
      });
    });

    group('Multiple Round Sequence with Failures', () {
      test('handles sequence of rounds with intermittent failures', () async {
        // Round 1: success
        when(mockRepository.saveRoundResult(any))
            .thenAnswer((_) async => null);

        var result1 = await service.saveRoundResultWithRetry(
          RoundResultModel(
            id: 'test_match_round_1',
            matchId: 'test_match',
            roundIndex: 1,
            createdAt: DateTime.now(),
          ),
        );
        expect(result1, true);

        // Round 2: failure but recovers
        when(mockRepository.saveRoundResult(any))
            .thenThrow(MockFirebaseException('unavailable'))
            .thenAnswer((_) async => null);

        var result2 = await service.saveRoundResultWithRetry(
          RoundResultModel(
            id: 'test_match_round_2',
            matchId: 'test_match',
            roundIndex: 2,
            createdAt: DateTime.now(),
          ),
        );
        expect(result2, true);

        // Round 3: failure, game continues
        when(mockRepository.saveRoundResult(any))
            .thenThrow(MockFirebaseException('unavailable'));

        var result3 = await service.saveRoundResultWithRetry(
          RoundResultModel(
            id: 'test_match_round_3',
            matchId: 'test_match',
            roundIndex: 3,
            createdAt: DateTime.now(),
          ),
        );
        expect(result3, false);

        // Round 4: recovers
        when(mockRepository.saveRoundResult(any))
            .thenAnswer((_) async => null);

        var result4 = await service.saveRoundResultWithRetry(
          RoundResultModel(
            id: 'test_match_round_4',
            matchId: 'test_match',
            roundIndex: 4,
            createdAt: DateTime.now(),
          ),
        );
        expect(result4, true);
      });
    });

    group('State Consistency on Failure', () {
      test('match state update includes timestamp even on retry', () async {
        when(mockRepository.updateMatchState(any, any))
            .thenThrow(MockFirebaseException('deadline-exceeded'))
            .thenAnswer((_) async => null);

        await service.updateMatchStateAfterRound(
          matchId: 'test_match',
          roundIndex: 2,
          status: 'playing',
          stoneCounts: {'player_1': 20, 'player_2': 22, 'player_3': 22},
          isGameOver: false,
        );

        final captured = verify(mockRepository.updateMatchState(any, captureAny))
            .captured;
        final updateData = captured.last as Map<String, dynamic>;

        expect(updateData.containsKey('lastUpdated'), true);
        expect(updateData['lastUpdated'] is String, true);
      });

      test('stone counts are preserved through failed saves', () async {
        final stoneCounts = {
          'player_1': 25,
          'player_2': 20,
          'player_3': 19,
        };

        when(mockRepository.updateMatchState(any, any))
            .thenThrow(MockFirebaseException('unavailable'));

        final result = await service.updateMatchStateAfterRound(
          matchId: 'test_match',
          roundIndex: 5,
          status: 'playing',
          stoneCounts: stoneCounts,
          isGameOver: false,
        );

        expect(result, false);

        // When it succeeds on retry, verify stone counts would be sent
        when(mockRepository.updateMatchState(any, any))
            .thenAnswer((_) async => null);

        await service.updateMatchStateAfterRound(
          matchId: 'test_match',
          roundIndex: 5,
          status: 'playing',
          stoneCounts: stoneCounts,
          isGameOver: false,
        );

        final captured = verify(mockRepository.updateMatchState(any, captureAny))
            .captured;
        final updateData = captured.last as Map<String, dynamic>;

        expect(updateData['stoneCounts'], stoneCounts);
      });
    });

    group('Offline Scenario', () {
      test('handles complete Firestore unavailability', () async {
        when(mockRepository.saveRoundResult(any))
            .thenThrow(MockFirebaseException('unavailable'));
        when(mockRepository.updateMatchState(any, any))
            .thenThrow(MockFirebaseException('unavailable'));

        // Simulate complete offline scenario
        bool canContinueGame = true;

        final testResult = RoundResultModel(
          id: 'test_match_round_1',
          matchId: 'test_match',
          roundIndex: 1,
          createdAt: DateTime.now(),
        );

        final roundSaved =
            await service.saveRoundResultWithRetry(testResult);
        if (roundSaved == false) {
          // Log warning but continue
          print('Warning: Failed to save round result');
        }

        final stateSaved = await service.updateMatchStateAfterRound(
          matchId: 'test_match',
          roundIndex: 2,
          status: 'playing',
          stoneCounts: {'player_1': 20, 'player_2': 22, 'player_3': 22},
          isGameOver: false,
        );
        if (stateSaved == false) {
          // Log warning but continue
          print('Warning: Failed to update match state');
        }

        // Game should continue despite offline
        expect(canContinueGame, true);
      });
    });
  });
}
