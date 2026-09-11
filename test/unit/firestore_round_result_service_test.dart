import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:toriverse/features/match/application/services/firestore_round_result_service.dart';
import 'package:toriverse/features/match/application/providers/firestore_match_provider.dart';
import 'package:toriverse/features/match/data/models/round_result_model.dart';

// Mock classes
class MockFirestoreMatchRepository extends Mock
    implements FirestoreMatchRepository {}

class MockFirebaseException extends Mock implements FirebaseException {
  final String errorCode;

  MockFirebaseException(this.errorCode);

  @override
  String get code => errorCode;
}

void main() {
  late MockFirestoreMatchRepository mockRepository;
  late FirestoreRoundResultService service;

  setUp(() {
    mockRepository = MockFirestoreMatchRepository();
    service =
        FirestoreRoundResultService(repository: mockRepository);
  });

  group('FirestoreRoundResultService', () {
    group('saveRoundResultWithRetry', () {
      late RoundResultModel testResult;

      setUp(() {
        testResult = RoundResultModel(
          id: 'match_001_round_1',
          matchId: 'match_001',
          roundIndex: 1,
          createdAt: DateTime.now(),
        );
      });

      test('saves successfully on first attempt', () async {
        when(mockRepository.saveRoundResult(any))
            .thenAnswer((_) async => null);

        final result = await service.saveRoundResultWithRetry(testResult);

        expect(result, true);
        verify(mockRepository.saveRoundResult(testResult)).called(1);
      });

      test('retries on retryable error', () async {
        when(mockRepository.saveRoundResult(any))
            .thenThrow(MockFirebaseException('unavailable'))
            .thenAnswer((_) async => null);

        final result = await service.saveRoundResultWithRetry(testResult);

        expect(result, true);
        verify(mockRepository.saveRoundResult(testResult)).called(2);
      });

      test('returns false after max retries exceeded', () async {
        when(mockRepository.saveRoundResult(any))
            .thenThrow(MockFirebaseException('unavailable'));

        final result = await service.saveRoundResultWithRetry(testResult);

        expect(result, false);
        verify(mockRepository.saveRoundResult(testResult)).called(4); // 1 + 3 retries
      });

      test('does not retry on non-retryable error', () async {
        when(mockRepository.saveRoundResult(any))
            .thenThrow(MockFirebaseException('permission-denied'));

        final result = await service.saveRoundResultWithRetry(testResult);

        expect(result, false);
        verify(mockRepository.saveRoundResult(testResult)).called(1);
      });

      test('handles deadline-exceeded as retryable', () async {
        when(mockRepository.saveRoundResult(any))
            .thenThrow(MockFirebaseException('deadline-exceeded'))
            .thenAnswer((_) async => null);

        final result = await service.saveRoundResultWithRetry(testResult);

        expect(result, true);
        verify(mockRepository.saveRoundResult(testResult)).called(2);
      });

      test('handles aborted as retryable', () async {
        when(mockRepository.saveRoundResult(any))
            .thenThrow(MockFirebaseException('aborted'))
            .thenAnswer((_) async => null);

        final result = await service.saveRoundResultWithRetry(testResult);

        expect(result, true);
        verify(mockRepository.saveRoundResult(testResult)).called(2);
      });

      test('handles internal as retryable', () async {
        when(mockRepository.saveRoundResult(any))
            .thenThrow(MockFirebaseException('internal'))
            .thenAnswer((_) async => null);

        final result = await service.saveRoundResultWithRetry(testResult);

        expect(result, true);
        verify(mockRepository.saveRoundResult(testResult)).called(2);
      });

      test('does not retry on invalid-argument error', () async {
        when(mockRepository.saveRoundResult(any))
            .thenThrow(MockFirebaseException('invalid-argument'));

        final result = await service.saveRoundResultWithRetry(testResult);

        expect(result, false);
        verify(mockRepository.saveRoundResult(testResult)).called(1);
      });

      test('does not retry on not-found error', () async {
        when(mockRepository.saveRoundResult(any))
            .thenThrow(MockFirebaseException('not-found'));

        final result = await service.saveRoundResultWithRetry(testResult);

        expect(result, false);
        verify(mockRepository.saveRoundResult(testResult)).called(1);
      });

      test('handles non-Firebase exceptions gracefully', () async {
        when(mockRepository.saveRoundResult(any))
            .thenThrow(Exception('Network error'));

        final result = await service.saveRoundResultWithRetry(testResult);

        expect(result, false);
        verify(mockRepository.saveRoundResult(testResult)).called(1);
      });
    });

    group('updateMatchStateAfterRound', () {
      test('updates match state successfully', () async {
        when(mockRepository.updateMatchState(any, any))
            .thenAnswer((_) async => null);

        final result = await service.updateMatchStateAfterRound(
          matchId: 'match_001',
          roundIndex: 2,
          status: 'playing',
          stoneCounts: {'player_1': 20, 'player_2': 22, 'player_3': 22},
          isGameOver: false,
        );

        expect(result, true);
        verify(mockRepository.updateMatchState(any, any)).called(1);
      });

      test('retries on retryable error', () async {
        when(mockRepository.updateMatchState(any, any))
            .thenThrow(MockFirebaseException('deadline-exceeded'))
            .thenAnswer((_) async => null);

        final result = await service.updateMatchStateAfterRound(
          matchId: 'match_001',
          roundIndex: 2,
          status: 'playing',
          stoneCounts: {'player_1': 20, 'player_2': 22, 'player_3': 22},
          isGameOver: false,
        );

        expect(result, true);
        verify(mockRepository.updateMatchState(any, any)).called(2);
      });

      test('returns false after max retries', () async {
        when(mockRepository.updateMatchState(any, any))
            .thenThrow(MockFirebaseException('unavailable'));

        final result = await service.updateMatchStateAfterRound(
          matchId: 'match_001',
          roundIndex: 2,
          status: 'playing',
          stoneCounts: {'player_1': 20, 'player_2': 22, 'player_3': 22},
          isGameOver: false,
        );

        expect(result, false);
        verify(mockRepository.updateMatchState(any, any)).called(4);
      });

      test('sets isGameOver in update payload when true', () async {
        when(mockRepository.updateMatchState(any, any))
            .thenAnswer((_) async => null);

        await service.updateMatchStateAfterRound(
          matchId: 'match_001',
          roundIndex: 5,
          status: 'finished',
          stoneCounts: {'player_1': 25, 'player_2': 20, 'player_3': 19},
          isGameOver: true,
        );

        final captured = verify(mockRepository.updateMatchState(any, captureAny))
            .captured;
        expect((captured[0] as Map)['isGameOver'], true);
        expect((captured[0] as Map)['status'], 'finished');
      });
    });
  });
}
