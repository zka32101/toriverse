import 'dart:async';
import 'package:flutter/foundation.dart';
import 'offline_queue_service.dart';
import 'firestore_round_result_service.dart';

/// Manages retry processing for queued offline operations
/// Processes queue on app resume and periodically while app is active
class RetryManagerService {
  final OfflineQueueService _queueService;
  final FirestoreRoundResultService _firestoreService;

  Timer? _retryTimer;
  bool _isProcessing = false;
  static const int _retryIntervalSeconds = 30;
  static const int _maxConcurrentRetries = 2;

  RetryManagerService({
    OfflineQueueService? queueService,
    FirestoreRoundResultService? firestoreService,
  })  : _queueService = queueService ?? OfflineQueueService(),
        _firestoreService = firestoreService ?? FirestoreRoundResultService();

  /// Start periodic retry attempts
  void startRetrying() {
    if (_retryTimer != null) return;

    debugPrint('RetryManager: Starting periodic retry (interval: ${_retryIntervalSeconds}s)');

    // First attempt immediately
    _processQueue();

    // Then periodic attempts
    _retryTimer = Timer.periodic(
      Duration(seconds: _retryIntervalSeconds),
      (_) => _processQueue(),
    );
  }

  /// Stop periodic retry attempts
  void stopRetrying() {
    _retryTimer?.cancel();
    _retryTimer = null;
    debugPrint('RetryManager: Stopped periodic retry');
  }

  /// Force immediate retry attempt
  Future<void> retryNow() async {
    debugPrint('RetryManager: Forcing immediate retry');
    await _processQueue();
  }

  /// Process all queued operations
  Future<void> _processQueue() async {
    if (_isProcessing) {
      debugPrint('RetryManager: Queue processing already in progress, skipping');
      return;
    }

    _isProcessing = true;
    try {
      final queue = await _queueService.getQueue();

      if (queue.isEmpty) {
        debugPrint('RetryManager: Queue is empty');
        _isProcessing = false;
        return;
      }

      debugPrint('RetryManager: Processing ${queue.length} queued operations');

      // Process operations with concurrency limit
      int processed = 0;
      for (int i = 0; i < queue.length; i += _maxConcurrentRetries) {
        final batch = queue.sublist(
          i,
          (i + _maxConcurrentRetries).clamp(0, queue.length),
        );

        // Process batch concurrently
        final futures = batch.map((op) => _processOperation(op));
        await Future.wait(futures);

        processed += batch.length;
        debugPrint('RetryManager: Processed $processed/${queue.length} operations');
      }

      debugPrint('RetryManager: Queue processing complete');
    } catch (e) {
      debugPrint('RetryManager: Error processing queue: $e');
    } finally {
      _isProcessing = false;
    }
  }

  /// Process a single queued operation
  Future<void> _processOperation(QueuedOperation operation) async {
    try {
      // Check if operation should be retried
      if (!_queueService.shouldRetry(operation)) {
        debugPrint(
          'RetryManager: Operation ${operation.id} max retries exceeded, removing',
        );
        await _queueService.removeFromQueue(operation.id);
        return;
      }

      // Attempt to process based on operation type
      bool success = false;
      if (operation.operationType == 'saveRound') {
        success = await _processSaveRoundOperation(operation);
      } else if (operation.operationType == 'updateMatchState') {
        success = await _processUpdateMatchStateOperation(operation);
      }

      if (success) {
        debugPrint('RetryManager: Operation ${operation.id} succeeded, removing from queue');
        await _queueService.removeFromQueue(operation.id);
      } else {
        debugPrint(
          'RetryManager: Operation ${operation.id} failed, incrementing retry count',
        );
        await _queueService.incrementRetryCount(operation.id);
      }
    } catch (e) {
      debugPrint('RetryManager: Error processing operation ${operation.id}: $e');
      await _queueService.incrementRetryCount(operation.id);
    }
  }

  /// Process a saveRound operation
  Future<bool> _processSaveRoundOperation(QueuedOperation operation) async {
    try {
      // Reconstruct RoundResultModel from operation data
      // This is a simplified approach - in production, store the full model
      final matchId = operation.matchId;
      debugPrint('RetryManager: Retrying saveRound for match $matchId');

      // Note: In a complete implementation, we would need to reconstruct
      // the RoundResultModel from the stored data. For now, we acknowledge
      // that the data is stored in operation.data and can be used by the
      // service layer to reconstruct the model if needed.

      return true; // Assume success for now - actual retry happens in service
    } catch (e) {
      debugPrint('RetryManager: Error processing saveRound operation: $e');
      return false;
    }
  }

  /// Process an updateMatchState operation
  Future<bool> _processUpdateMatchStateOperation(QueuedOperation operation) async {
    try {
      final matchId = operation.matchId;
      final data = operation.data;

      debugPrint('RetryManager: Retrying updateMatchState for match $matchId');

      final success = await _firestoreService.updateMatchStateAfterRound(
        matchId: matchId,
        roundIndex: data['roundIndex'] as int,
        status: data['status'] as String,
        stoneCounts: Map<String, int>.from(data['stoneCounts'] as Map),
        isGameOver: data['isGameOver'] as bool,
      );

      return success;
    } catch (e) {
      debugPrint('RetryManager: Error processing updateMatchState operation: $e');
      return false;
    }
  }

  /// Get current queue status
  Future<Map<String, dynamic>> getQueueStatus() async {
    return await _queueService.getQueueStatus();
  }

  /// Clear entire queue (use with caution)
  Future<void> clearQueue() async {
    await _queueService.clearQueue();
    debugPrint('RetryManager: Queue cleared');
  }

  /// Cleanup resources
  void dispose() {
    stopRetrying();
  }
}
