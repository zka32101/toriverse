import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:toriverse/features/match/application/services/retry_manager_service.dart';
import 'package:toriverse/features/match/application/services/offline_queue_service.dart';
import 'package:toriverse/features/match/application/services/firestore_round_result_service.dart';

// Mock implementations
class MockOfflineQueueService extends Mock implements OfflineQueueService {}

class MockFirestoreRoundResultService extends Mock
    implements FirestoreRoundResultService {}

void main() {
  group('RetryManagerService', () {
    late MockOfflineQueueService mockQueueService;
    late MockFirestoreRoundResultService mockFirestoreService;
    late RetryManagerService retryManager;

    setUp(() {
      mockQueueService = MockOfflineQueueService();
      mockFirestoreService = MockFirestoreRoundResultService();
      retryManager = RetryManagerService(
        queueService: mockQueueService,
        firestoreService: mockFirestoreService,
      );
    });

    tearDown(() {
      retryManager.dispose();
    });

    test('startRetrying initializes periodic timer', () async {
      when(mockQueueService.getQueue()).thenAnswer((_) async => []);

      retryManager.startRetrying();
      await Future.delayed(const Duration(milliseconds: 100));

      verify(mockQueueService.getQueue()).called(greaterThan(0));
      retryManager.stopRetrying();
    });

    test('stopRetrying cancels timer', () async {
      when(mockQueueService.getQueue()).thenAnswer((_) async => []);

      retryManager.startRetrying();
      await Future.delayed(const Duration(milliseconds: 100));
      retryManager.stopRetrying();

      final callCount =
          verify(mockQueueService.getQueue()).callCount;
      expect(callCount, greaterThan(0));
    });

    test('retryNow processes queue immediately', () async {
      when(mockQueueService.getQueue()).thenAnswer((_) async => []);

      await retryManager.retryNow();

      verify(mockQueueService.getQueue()).called(1);
    });

    test('empty queue does not attempt processing', () async {
      when(mockQueueService.getQueue()).thenAnswer((_) async => []);

      await retryManager.retryNow();

      verify(mockQueueService.getQueue()).called(1);
      verifyNever(mockQueueService.incrementRetryCount(any));
    });

    test('removes successful operations from queue', () async {
      final operation = QueuedOperation(
        id: 'test_op_1',
        operationType: 'updateMatchState',
        matchId: 'match_1',
        data: {
          'roundIndex': 1,
          'status': 'playing',
          'stoneCounts': {'p1': 10, 'p2': 12, 'p3': 14},
          'isGameOver': false,
        },
        enqueuedAt: DateTime.now(),
      );

      when(mockQueueService.getQueue())
          .thenAnswer((_) async => [operation]);
      when(mockQueueService.shouldRetry(operation)).thenReturn(true);
      when(mockFirestoreService.updateMatchStateAfterRound(
        matchId: 'match_1',
        roundIndex: 1,
        status: 'playing',
        stoneCounts: {'p1': 10, 'p2': 12, 'p3': 14},
        isGameOver: false,
      )).thenAnswer((_) async => true);

      await retryManager.retryNow();

      verify(mockQueueService.removeFromQueue('test_op_1')).called(1);
      verifyNever(mockQueueService.incrementRetryCount('test_op_1'));
    });

    test('increments retry count on failed operations', () async {
      final operation = QueuedOperation(
        id: 'test_op_2',
        operationType: 'updateMatchState',
        matchId: 'match_2',
        data: {
          'roundIndex': 2,
          'status': 'playing',
          'stoneCounts': {'p1': 8, 'p2': 16, 'p3': 12},
          'isGameOver': false,
        },
        enqueuedAt: DateTime.now(),
      );

      when(mockQueueService.getQueue())
          .thenAnswer((_) async => [operation]);
      when(mockQueueService.shouldRetry(operation)).thenReturn(true);
      when(mockFirestoreService.updateMatchStateAfterRound(
        matchId: 'match_2',
        roundIndex: 2,
        status: 'playing',
        stoneCounts: {'p1': 8, 'p2': 16, 'p3': 12},
        isGameOver: false,
      )).thenAnswer((_) async => false);

      await retryManager.retryNow();

      verify(mockQueueService.incrementRetryCount('test_op_2')).called(1);
      verifyNever(mockQueueService.removeFromQueue('test_op_2'));
    });

    test('removes operations that exceed max retries', () async {
      final operation = QueuedOperation(
        id: 'test_op_3',
        operationType: 'updateMatchState',
        matchId: 'match_3',
        data: {
          'roundIndex': 3,
          'status': 'playing',
          'stoneCounts': {'p1': 20, 'p2': 8, 'p3': 8},
          'isGameOver': false,
        },
        enqueuedAt: DateTime.now(),
        retryCount: 3,
      );

      when(mockQueueService.getQueue())
          .thenAnswer((_) async => [operation]);
      when(mockQueueService.shouldRetry(operation)).thenReturn(false);

      await retryManager.retryNow();

      verify(mockQueueService.removeFromQueue('test_op_3')).called(1);
      verifyNever(mockQueueService.incrementRetryCount('test_op_3'));
    });

    test('getQueueStatus returns status from queue service', () async {
      final status = {
        'totalOperations': 2,
        'roundSaves': 1,
        'matchStateUpdates': 1,
      };

      when(mockQueueService.getQueueStatus()).thenAnswer((_) async => status);

      final result = await retryManager.getQueueStatus();

      expect(result, equals(status));
      verify(mockQueueService.getQueueStatus()).called(1);
    });

    test('clearQueue delegates to queue service', () async {
      await retryManager.clearQueue();

      verify(mockQueueService.clearQueue()).called(1);
    });

    test('does not process queue concurrently', () async {
      when(mockQueueService.getQueue())
          .thenAnswer((_) async => Future.delayed(
            const Duration(milliseconds: 100),
            () => [],
          ));

      // Start two retries
      final future1 = retryManager.retryNow();
      final future2 = retryManager.retryNow();

      await Future.wait([future1, future2]);

      // getQueue should only be called once due to concurrency guard
      verify(mockQueueService.getQueue()).called(1);
    });

    test('processes updateMatchState operations correctly', () async {
      final operation = QueuedOperation(
        id: 'state_op_1',
        operationType: 'updateMatchState',
        matchId: 'match_4',
        data: {
          'roundIndex': 4,
          'status': 'finished',
          'stoneCounts': {'p1': 18, 'p2': 20, 'p3': 10},
          'isGameOver': true,
        },
        enqueuedAt: DateTime.now(),
      );

      when(mockQueueService.getQueue())
          .thenAnswer((_) async => [operation]);
      when(mockQueueService.shouldRetry(operation)).thenReturn(true);
      when(mockFirestoreService.updateMatchStateAfterRound(
        matchId: 'match_4',
        roundIndex: 4,
        status: 'finished',
        stoneCounts: {'p1': 18, 'p2': 20, 'p3': 10},
        isGameOver: true,
      )).thenAnswer((_) async => true);

      await retryManager.retryNow();

      verify(mockFirestoreService.updateMatchStateAfterRound(
        matchId: 'match_4',
        roundIndex: 4,
        status: 'finished',
        stoneCounts: {'p1': 18, 'p2': 20, 'p3': 10},
        isGameOver: true,
      )).called(1);
      verify(mockQueueService.removeFromQueue('state_op_1')).called(1);
    });

    test('handles multiple operations in queue', () async {
      final op1 = QueuedOperation(
        id: 'op_1',
        operationType: 'updateMatchState',
        matchId: 'match_5',
        data: {
          'roundIndex': 1,
          'status': 'playing',
          'stoneCounts': {'p1': 10, 'p2': 10, 'p3': 14},
          'isGameOver': false,
        },
        enqueuedAt: DateTime.now(),
      );

      final op2 = QueuedOperation(
        id: 'op_2',
        operationType: 'updateMatchState',
        matchId: 'match_6',
        data: {
          'roundIndex': 2,
          'status': 'playing',
          'stoneCounts': {'p1': 12, 'p2': 8, 'p3': 16},
          'isGameOver': false,
        },
        enqueuedAt: DateTime.now(),
      );

      when(mockQueueService.getQueue()).thenAnswer((_) async => [op1, op2]);
      when(mockQueueService.shouldRetry(any)).thenReturn(true);
      when(mockFirestoreService.updateMatchStateAfterRound(
        matchId: 'match_5',
        roundIndex: 1,
        status: 'playing',
        stoneCounts: {'p1': 10, 'p2': 10, 'p3': 14},
        isGameOver: false,
      )).thenAnswer((_) async => true);
      when(mockFirestoreService.updateMatchStateAfterRound(
        matchId: 'match_6',
        roundIndex: 2,
        status: 'playing',
        stoneCounts: {'p1': 12, 'p2': 8, 'p3': 16},
        isGameOver: false,
      )).thenAnswer((_) async => true);

      await retryManager.retryNow();

      verify(mockQueueService.removeFromQueue('op_1')).called(1);
      verify(mockQueueService.removeFromQueue('op_2')).called(1);
    });

    test('handles exceptions during operation processing', () async {
      final operation = QueuedOperation(
        id: 'error_op',
        operationType: 'updateMatchState',
        matchId: 'match_error',
        data: {
          'roundIndex': 1,
          'status': 'playing',
          'stoneCounts': {'p1': 10, 'p2': 12, 'p3': 14},
          'isGameOver': false,
        },
        enqueuedAt: DateTime.now(),
      );

      when(mockQueueService.getQueue())
          .thenAnswer((_) async => [operation]);
      when(mockQueueService.shouldRetry(operation)).thenReturn(true);
      when(mockFirestoreService.updateMatchStateAfterRound(
        matchId: 'match_error',
        roundIndex: 1,
        status: 'playing',
        stoneCounts: {'p1': 10, 'p2': 12, 'p3': 14},
        isGameOver: false,
      )).thenThrow(Exception('Network error'));

      // Should not throw, should handle gracefully
      await retryManager.retryNow();

      verify(mockQueueService.incrementRetryCount('error_op')).called(1);
      verifyNever(mockQueueService.removeFromQueue('error_op'));
    });
  });
}
