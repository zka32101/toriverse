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
  group('Firestore Retry Logic Tests', () {
    late MockFirestoreMatchRepository mockRepository;
    late FirestoreRoundResultService service;

    setUp(() {
      mockRepository = MockFirestoreMatchRepository();
      service =
          FirestoreRoundResultService(repository: mockRepository);
    });

    group('Retryable Error Classification', () {
      test('unavailable error is retryable', () async {
        final testResult = RoundResultModel(
          id: 'test_match_round_1',
          matchId: 'test_match',
          roundIndex: 1,
          createdAt: DateTime.now(),
        );

        when(mockRepository.saveRoundResult(any))
            .thenThrow(TestFirebaseException('unavailable'))
            .thenAnswer((_) async => null);

        final result = await service.saveRoundResultWithRetry(testResult);
        expect(result, true);
      });

      test('deadline-exceeded error is retryable', () async {
        final testResult = RoundResultModel(
          id: 'test_match_round_2',
          matchId: 'test_match',
          roundIndex: 2,
          createdAt: DateTime.now(),
        );

        when(mockRepository.saveRoundResult(any))
            .thenThrow(TestFirebaseException('deadline-exceeded'))
            .thenAnswer((_) async => null);

        final result = await service.saveRoundResultWithRetry(testResult);
        expect(result, true);
      });

      test('aborted error is retryable', () async {
        final testResult = RoundResultModel(
          id: 'test_match_round_3',
          matchId: 'test_match',
          roundIndex: 3,
          createdAt: DateTime.now(),
        );

        when(mockRepository.saveRoundResult(any))
            .thenThrow(TestFirebaseException('aborted'))
            .thenAnswer((_) async => null);

        final result = await service.saveRoundResultWithRetry(testResult);
        expect(result, true);
      });

      test('internal error is retryable', () async {
        final testResult = RoundResultModel(
          id: 'test_match_round_4',
          matchId: 'test_match',
          roundIndex: 4,
          createdAt: DateTime.now(),
        );

        when(mockRepository.saveRoundResult(any))
            .thenThrow(TestFirebaseException('internal'))
            .thenAnswer((_) async => null);

        final result = await service.saveRoundResultWithRetry(testResult);
        expect(result, true);
      });

      test('permission-denied error is not retryable', () async {
        final testResult = RoundResultModel(
          id: 'test_match_round_5',
          matchId: 'test_match',
          roundIndex: 5,
          createdAt: DateTime.now(),
        );

        when(mockRepository.saveRoundResult(any))
            .thenThrow(TestFirebaseException('permission-denied'));

        final result = await service.saveRoundResultWithRetry(testResult);
        expect(result, false);
        verify(mockRepository.saveRoundResult(any)).called(1);
      });

      test('invalid-argument error is not retryable', () async {
        final testResult = RoundResultModel(
          id: 'test_match_round_6',
          matchId: 'test_match',
          roundIndex: 6,
          createdAt: DateTime.now(),
        );

        when(mockRepository.saveRoundResult(any))
            .thenThrow(TestFirebaseException('invalid-argument'));

        final result = await service.saveRoundResultWithRetry(testResult);
        expect(result, false);
        verify(mockRepository.saveRoundResult(any)).called(1);
      });

      test('not-found error is not retryable', () async {
        final testResult = RoundResultModel(
          id: 'test_match_round_7',
          matchId: 'test_match',
          roundIndex: 7,
          createdAt: DateTime.now(),
        );

        when(mockRepository.saveRoundResult(any))
            .thenThrow(TestFirebaseException('not-found'));

        final result = await service.saveRoundResultWithRetry(testResult);
        expect(result, false);
        verify(mockRepository.saveRoundResult(any)).called(1);
      });
    });

    group('Retry Attempt Count', () {
      test('succeeds on first attempt without retries', () async {
        final testResult = RoundResultModel(
          id: 'test_match_round_8',
          matchId: 'test_match',
          roundIndex: 8,
          createdAt: DateTime.now(),
        );

        when(mockRepository.saveRoundResult(any))
            .thenAnswer((_) async => null);

        await service.saveRoundResultWithRetry(testResult);
        verify(mockRepository.saveRoundResult(any)).called(1);
      });

      test('retries once on first transient error then succeeds', () async {
        final testResult = RoundResultModel(
          id: 'test_match_round_9',
          matchId: 'test_match',
          roundIndex: 9,
          createdAt: DateTime.now(),
        );

        when(mockRepository.saveRoundResult(any))
            .thenThrow(TestFirebaseException('unavailable'))
            .thenAnswer((_) async => null);

        await service.saveRoundResultWithRetry(testResult);
        verify(mockRepository.saveRoundResult(any)).called(2);
      });

      test('retries twice on repeated transient errors then succeeds', () async {
        final testResult = RoundResultModel(
          id: 'test_match_round_10',
          matchId: 'test_match',
          roundIndex: 10,
          createdAt: DateTime.now(),
        );

        when(mockRepository.saveRoundResult(any))
            .thenThrow(TestFirebaseException('unavailable'))
            .thenThrow(TestFirebaseException('unavailable'))
            .thenAnswer((_) async => null);

        await service.saveRoundResultWithRetry(testResult);
        verify(mockRepository.saveRoundResult(any)).called(3);
      });

      test('respects max retry limit of 3', () async {
        final testResult = RoundResultModel(
          id: 'test_match_round_11',
          matchId: 'test_match',
          roundIndex: 11,
          createdAt: DateTime.now(),
        );

        when(mockRepository.saveRoundResult(any))
            .thenThrow(TestFirebaseException('unavailable'));

        await service.saveRoundResultWithRetry(testResult);
        verify(mockRepository.saveRoundResult(any)).called(4); // 1 + 3 retries
      });
    });

    group('Exception Handling', () {
      test('handles Firebase exception with error code', () async {
        final testResult = RoundResultModel(
          id: 'test_match_round_12',
          matchId: 'test_match',
          roundIndex: 12,
          createdAt: DateTime.now(),
        );

        when(mockRepository.saveRoundResult(any))
            .thenThrow(TestFirebaseException('unauthenticated'));

        final result = await service.saveRoundResultWithRetry(testResult);
        expect(result, false);
      });

      test('handles non-Firebase exceptions gracefully', () async {
        final testResult = RoundResultModel(
          id: 'test_match_round_13',
          matchId: 'test_match',
          roundIndex: 13,
          createdAt: DateTime.now(),
        );

        when(mockRepository.saveRoundResult(any))
            .thenThrow(Exception('Unexpected error'));

        final result = await service.saveRoundResultWithRetry(testResult);
        expect(result, false);
      });

      test('does not throw exceptions, always returns bool', () async {
        final testResult = RoundResultModel(
          id: 'test_match_round_14',
          matchId: 'test_match',
          roundIndex: 14,
          createdAt: DateTime.now(),
        );

        when(mockRepository.saveRoundResult(any))
            .thenThrow(Exception('Fatal error'));

        expect(() async {
          await service.saveRoundResultWithRetry(testResult);
        }, returnsNormally);
      });
    });

    group('Exponential Backoff Configuration', () {
      test('initial delay is 500ms', () {
        // This tests the constant definition
        expect(FirestoreRoundResultService.initialDelayMs, 500);
      });

      test('max retries is 3', () {
        expect(FirestoreRoundResultService.maxRetries, 3);
      });

      test('total wait time for 3 retries is 3500ms (500+1000+2000)', () async {
        // 500ms + 1000ms + 2000ms = 3500ms total backoff time
        final testResult = RoundResultModel(
          id: 'test_match_round_15',
          matchId: 'test_match',
          roundIndex: 15,
          createdAt: DateTime.now(),
        );

        when(mockRepository.saveRoundResult(any))
            .thenThrow(TestFirebaseException('unavailable'));

        final stopwatch = Stopwatch()..start();
        await service.saveRoundResultWithRetry(testResult);
        stopwatch.stop();

        // Should have waited at least 3.5 seconds (3500ms) for backoff
        // Adding 500ms buffer for execution time
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(3500));
      });
    });
  });
}
