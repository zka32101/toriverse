import 'package:riverpod/riverpod.dart';
import '../services/retry_manager_service.dart';
import '../services/offline_queue_service.dart';
import '../services/firestore_round_result_service.dart';

/// Provides the RetryManagerService singleton
/// Automatically starts retry processing when first accessed
final retryManagerProvider = Provider<RetryManagerService>((ref) {
  final offlineQueueService = ref.watch(offlineQueueServiceProvider);
  final firestoreService = ref.watch(firestoreRoundResultServiceProvider);

  final retryManager = RetryManagerService(
    queueService: offlineQueueService,
    firestoreService: firestoreService,
  );

  // Start retry processing
  retryManager.startRetrying();

  // Cleanup on disposal
  ref.onDispose(() {
    retryManager.dispose();
  });

  return retryManager;
});

/// Provides the OfflineQueueService singleton
final offlineQueueServiceProvider = Provider<OfflineQueueService>((ref) {
  return OfflineQueueService();
});

/// Provides the FirestoreRoundResultService with offline queue support
final firestoreRoundResultServiceProvider = Provider<FirestoreRoundResultService>((ref) {
  final offlineQueueService = ref.watch(offlineQueueServiceProvider);
  return FirestoreRoundResultService(
    offlineQueue: offlineQueueService,
  );
});

/// Watch offline queue status
/// Returns queue statistics including total operations and retry counts
final offlineQueueStatusProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final retryManager = ref.watch(retryManagerProvider);
  return await retryManager.getQueueStatus();
});

/// Watch if there are any queued operations
/// Useful for showing sync indicators in the UI
final hasQueuedOperationsProvider = FutureProvider<bool>((ref) async {
  final status = await ref.watch(offlineQueueStatusProvider.future);
  return (status['totalOperations'] as int? ?? 0) > 0;
});

/// Get count of queued operations
final queuedOperationsCountProvider = FutureProvider<int>((ref) async {
  final status = await ref.watch(offlineQueueStatusProvider.future);
  return status['totalOperations'] as int? ?? 0;
});

/// Trigger immediate retry of queued operations
class RetryQueueNotifier extends StateNotifier<AsyncValue<void>> {
  final RetryManagerService _retryManager;

  RetryQueueNotifier(this._retryManager) : super(const AsyncValue.data(null));

  Future<void> retry() async {
    state = const AsyncValue.loading();
    try {
      await _retryManager.retryNow();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

/// Provides manual retry trigger for queued operations
final retryQueueProvider = StateNotifierProvider<RetryQueueNotifier, AsyncValue<void>>(
  (ref) {
    final retryManager = ref.watch(retryManagerProvider);
    return RetryQueueNotifier(retryManager);
  },
);
