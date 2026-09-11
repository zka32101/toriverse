import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toriverse/features/match/application/services/firestore_round_result_service.dart';
import 'package:toriverse/features/match/application/providers/firestore_match_provider.dart';
import 'package:toriverse/features/match/data/models/round_result_model.dart';

class MockFirestoreMatchRepository extends Mock
    implements FirestoreMatchRepository {}

/// Test exception that mimics FirebaseException behavior
class TestFirebaseException implements FirebaseException {
  @override
  final String code;

  TestFirebaseException(this.code);

  @override
  String get message => 'Firebase error: $code';

  @override
  StackTrace? get stackTrace => null;

  @override
  String toString() => 'TestFirebaseException($code)';
}

void main() {
  group('Firestore Match Integration Tests', () {
    late MockFirestoreMatchRepository mockRepository;
    late FirestoreRoundResultService service;

    setUp(() {
      mockRepository = MockFirestoreMatchRepository();
      service =
          FirestoreRoundResultService(repository: mockRepository);
    });

    group('Round Completion Flow', () {
      test('saves round result and updates match state on completion', () async {
        final roundResult = RoundResultModel(
          id: 'match_001_round_1',
          matchId: 'match_001',
          roundIndex: 1,
          createdAt: DateTime.now(),
        );

        when(mockRepository.saveRoundResult(any))
            .thenAnswer((_) async => null);
        when(mockRepository.updateMatchState(any, any))
            .thenAnswer((_) async => null);

        // Save round result
        final roundSaved =
            await service.saveRoundResultWithRetry(roundResult);
        expect(roundSaved, true);

        // Update match state
        final stateSaved = await service.updateMatchStateAfterRound(
          matchId: 'match_001',
          roundIndex: 2,
          status: 'playing',
          stoneCounts: {'player_1': 20, 'player_2': 22, 'player_3': 22},
          isGameOver: false,
        );
        expect(stateSaved, true);

        verify(mockRepository.saveRoundResult(any)).called(1);
        verify(mockRepository.updateMatchState(any, any)).called(1);
      });

      test('continues game flow even if round save fails', () async {
        final roundResult = RoundResultModel(
          id: 'match_001_round_1',
          matchId: 'match_001',
          roundIndex: 1,
          createdAt: DateTime.now(),
        );

        // First call fails, but game should continue
        when(mockRepository.saveRoundResult(any))
            .thenThrow(TestFirebaseException('unavailable'));

        final roundSaved =
            await service.saveRoundResultWithRetry(roundResult);
        expect(roundSaved, false);

        // Game flow continues - state update still attempted
        when(mockRepository.updateMatchState(any, any))
            .thenAnswer((_) async => null);

        final stateSaved = await service.updateMatchStateAfterRound(
          matchId: 'match_001',
          roundIndex: 2,
          status: 'playing',
          stoneCounts: {'player_1': 20, 'player_2': 22, 'player_3': 22},
          isGameOver: false,
        );
        expect(stateSaved, true);
      });

      test('handles game-over state updates correctly', () async {
        when(mockRepository.updateMatchState(any, any))
            .thenAnswer((_) async => null);

        final result = await service.updateMatchStateAfterRound(
          matchId: 'match_001',
          roundIndex: 8,
          status: 'finished',
          stoneCounts: {'player_1': 28, 'player_2': 20, 'player_3': 16},
          isGameOver: true,
        );

        expect(result, true);

        final captured = verify(mockRepository.updateMatchState(
                'match_001', captureAny))
            .captured;
        final updateData = captured[0] as Map<String, dynamic>;

        expect(updateData['status'], 'finished');
        expect(updateData['isGameOver'], true);
        expect(updateData['roundIndex'], 8);
      });
    });

    group('Error Recovery', () {
      test('recovers from transient error with retry', () async {
        final roundResult = RoundResultModel(
          id: 'match_001_round_2',
          matchId: 'match_001',
          roundIndex: 2,
          createdAt: DateTime.now(),
        );

        int attemptCount = 0;
        when(mockRepository.saveRoundResult(any)).thenAnswer((_) async {
          attemptCount++;
          if (attemptCount == 1) {
            throw TestFirebaseException('deadline-exceeded');
          }
        });

        final result = await service.saveRoundResultWithRetry(roundResult);

        expect(result, true);
        expect(attemptCount, 2);
      });

      test('gives up on permanent error immediately', () async {
        final roundResult = RoundResultModel(
          id: 'match_001_round_3',
          matchId: 'match_001',
          roundIndex: 3,
          createdAt: DateTime.now(),
        );

        int attemptCount = 0;
        when(mockRepository.saveRoundResult(any)).thenAnswer((_) async {
          attemptCount++;
          throw TestFirebaseException('permission-denied');
        });

        final result = await service.saveRoundResultWithRetry(roundResult);

        expect(result, false);
        expect(attemptCount, 1);
      });

      test('exhausts retries on persistent transient errors', () async {
        final roundResult = RoundResultModel(
          id: 'match_001_round_4',
          matchId: 'match_001',
          roundIndex: 4,
          createdAt: DateTime.now(),
        );

        int attemptCount = 0;
        when(mockRepository.saveRoundResult(any)).thenAnswer((_) async {
          attemptCount++;
          throw TestFirebaseException('unavailable');
        });

        final result = await service.saveRoundResultWithRetry(roundResult);

        expect(result, false);
        expect(attemptCount, 4); // 1 initial + 3 retries
      });
    });

    group('Match State Consistency', () {
      test('updates all required fields in match state', () async {
        final stoneCounts = {
          'player_1': 25,
          'player_2': 22,
          'player_3': 17,
        };

        when(mockRepository.updateMatchState(any, any))
            .thenAnswer((_) async => null);

        await service.updateMatchStateAfterRound(
          matchId: 'match_001',
          roundIndex: 5,
          status: 'playing',
          stoneCounts: stoneCounts,
          isGameOver: false,
        );

        final captured = verify(mockRepository.updateMatchState(
                'match_001', captureAny))
            .captured;
        final updateData = captured[0] as Map<String, dynamic>;

        expect(updateData.containsKey('roundIndex'), true);
        expect(updateData.containsKey('status'), true);
        expect(updateData.containsKey('stoneCounts'), true);
        expect(updateData.containsKey('isGameOver'), true);
        expect(updateData.containsKey('lastUpdated'), true);

        expect(updateData['roundIndex'], 5);
        expect(updateData['stoneCounts'], stoneCounts);
      });

      test('includes timestamp in all state updates', () async {
        when(mockRepository.updateMatchState(any, any))
            .thenAnswer((_) async => null);

        final beforeUpdate = DateTime.now();
        await service.updateMatchStateAfterRound(
          matchId: 'match_001',
          roundIndex: 3,
          status: 'playing',
          stoneCounts: {'player_1': 20, 'player_2': 22, 'player_3': 22},
          isGameOver: false,
        );
        final afterUpdate = DateTime.now();

        final captured = verify(mockRepository.updateMatchState(
                'match_001', captureAny))
            .captured;
        final updateData = captured[0] as Map<String, dynamic>;

        final lastUpdated =
            DateTime.parse(updateData['lastUpdated'] as String);
        expect(lastUpdated.isAfter(beforeUpdate), true);
        expect(lastUpdated.isBefore(afterUpdate), true);
      });
    });

    group('Graceful Degradation', () {
      test('game continues locally even if Firestore is unavailable', () async {
        final roundResult = RoundResultModel(
          id: 'match_001_round_5',
          matchId: 'match_001',
          roundIndex: 5,
          createdAt: DateTime.now(),
        );

        // Simulate complete Firestore outage
        when(mockRepository.saveRoundResult(any))
            .thenThrow(TestFirebaseException('unavailable'));
        when(mockRepository.updateMatchState(any, any))
            .thenThrow(TestFirebaseException('unavailable'));

        // Both operations should return false but not throw
        final roundSaved =
            await service.saveRoundResultWithRetry(roundResult);
        final stateSaved = await service.updateMatchStateAfterRound(
          matchId: 'match_001',
          roundIndex: 6,
          status: 'playing',
          stoneCounts: {'player_1': 20, 'player_2': 22, 'player_3': 22},
          isGameOver: false,
        );

        expect(roundSaved, false);
        expect(stateSaved, false);
        // No exceptions thrown - game can continue
      });
    });
  });
}
