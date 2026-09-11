import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Analytics service for tracking offline queue operations
/// Monitors sync success rates, retry attempts, and performance metrics
class OfflineQueueAnalyticsService {
  final FirebaseAnalytics _analytics;

  static const String eventQueueOperationQueued = 'queue_operation_queued';
  static const String eventQueueOperationSynced = 'queue_operation_synced';
  static const String eventQueueOperationFailed = 'queue_operation_failed';
  static const String eventQueueRetryAttempted = 'queue_retry_attempted';
  static const String eventQueueSyncLatency = 'queue_sync_latency';
  static const String eventQueueStatusChecked = 'queue_status_checked';

  // Parameter names
  static const String paramOperationType = 'operation_type';
  static const String paramMatchId = 'match_id';
  static const String paramRetryCount = 'retry_count';
  static const String paramErrorCode = 'error_code';
  static const String paramSyncLatencyMs = 'sync_latency_ms';
  static const String paramQueueSize = 'queue_size';
  static const String paramSuccessRate = 'success_rate';
  static const String paramTotalOperations = 'total_operations';
  static const String paramRoundSaveCount = 'round_save_count';
  static const String paramStateUpdateCount = 'state_update_count';
  static const String paramOldestOperationAgeMs = 'oldest_operation_age_ms';

  OfflineQueueAnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  /// Log when an operation is queued due to Firestore failure
  Future<void> logOperationQueued({
    required String operationType,
    required String matchId,
    required int retryCount,
  }) async {
    try {
      await _analytics.logEvent(
        name: eventQueueOperationQueued,
        parameters: {
          paramOperationType: operationType,
          paramMatchId: matchId,
          paramRetryCount: retryCount,
        },
      );
      debugPrint('Analytics: Operation queued ($operationType, $matchId)');
    } catch (e) {
      debugPrint('Error logging queue operation: $e');
    }
  }

  /// Log when a queued operation is successfully synced to Firestore
  Future<void> logOperationSynced({
    required String operationType,
    required String matchId,
    required int retriesNeeded,
    required int syncLatencyMs,
  }) async {
    try {
      await _analytics.logEvent(
        name: eventQueueOperationSynced,
        parameters: {
          paramOperationType: operationType,
          paramMatchId: matchId,
          paramRetryCount: retriesNeeded,
          paramSyncLatencyMs: syncLatencyMs,
        },
      );
      debugPrint(
        'Analytics: Operation synced ($operationType, retries: $retriesNeeded, latency: ${syncLatencyMs}ms)',
      );
    } catch (e) {
      debugPrint('Error logging synced operation: $e');
    }
  }

  /// Log when a queued operation fails permanently
  Future<void> logOperationFailed({
    required String operationType,
    required String matchId,
    required int retryCount,
    required String errorCode,
  }) async {
    try {
      await _analytics.logEvent(
        name: eventQueueOperationFailed,
        parameters: {
          paramOperationType: operationType,
          paramMatchId: matchId,
          paramRetryCount: retryCount,
          paramErrorCode: errorCode,
        },
      );
      debugPrint(
        'Analytics: Operation failed ($operationType, error: $errorCode, retries: $retryCount)',
      );
    } catch (e) {
      debugPrint('Error logging failed operation: $e');
    }
  }

  /// Log retry attempt for queued operation
  Future<void> logRetryAttempt({
    required String operationType,
    required String matchId,
    required int attemptNumber,
    required int delayMs,
  }) async {
    try {
      await _analytics.logEvent(
        name: eventQueueRetryAttempted,
        parameters: {
          paramOperationType: operationType,
          paramMatchId: matchId,
          paramRetryCount: attemptNumber,
          'delay_ms': delayMs,
        },
      );
      debugPrint(
        'Analytics: Retry attempted ($operationType, attempt: $attemptNumber)',
      );
    } catch (e) {
      debugPrint('Error logging retry attempt: $e');
    }
  }

  /// Log queue sync latency measurement
  Future<void> logSyncLatency({
    required int latencyMs,
    required int operationsProcessed,
  }) async {
    try {
      await _analytics.logEvent(
        name: eventQueueSyncLatency,
        parameters: {
          paramSyncLatencyMs: latencyMs,
          'operations_processed': operationsProcessed,
          'latency_per_operation_ms': operationsProcessed > 0
              ? (latencyMs / operationsProcessed).toStringAsFixed(2)
              : '0',
        },
      );
      debugPrint(
        'Analytics: Sync latency recorded (${latencyMs}ms for $operationsProcessed ops)',
      );
    } catch (e) {
      debugPrint('Error logging sync latency: $e');
    }
  }

  /// Log queue health check
  Future<void> logQueueStatus({
    required int totalOperations,
    required int roundSaveCount,
    required int stateUpdateCount,
    required int? oldestOperationAgeMs,
    required double successRate,
  }) async {
    try {
      await _analytics.logEvent(
        name: eventQueueStatusChecked,
        parameters: {
          paramQueueSize: totalOperations,
          paramRoundSaveCount: roundSaveCount,
          paramStateUpdateCount: stateUpdateCount,
          paramSuccessRate: successRate.toStringAsFixed(2),
          if (oldestOperationAgeMs != null)
            paramOldestOperationAgeMs: oldestOperationAgeMs,
        },
      );
      debugPrint(
        'Analytics: Queue status checked (size: $totalOperations, success rate: ${(successRate * 100).toStringAsFixed(1)}%)',
      );
    } catch (e) {
      debugPrint('Error logging queue status: $e');
    }
  }

  /// Log when queue is cleared (manual or automatic)
  Future<void> logQueueCleared({
    required int operationsRemoved,
    required String reason,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'queue_cleared',
        parameters: {
          'operations_removed': operationsRemoved,
          'reason': reason, // e.g., 'manual', 'max_retries_exceeded', 'sync_complete'
        },
      );
      debugPrint(
        'Analytics: Queue cleared ($operationsRemoved operations, reason: $reason)',
      );
    } catch (e) {
      debugPrint('Error logging queue cleared: $e');
    }
  }

  /// Calculate and log queue health metrics
  Future<void> logQueueHealthMetrics({
    required Map<String, dynamic> queueStatus,
    required int totalSyncedOperations,
    required int totalFailedOperations,
  }) async {
    try {
      final total = totalSyncedOperations + totalFailedOperations;
      final successRate = total > 0 ? totalSyncedOperations / total : 1.0;

      final totalOps = queueStatus['totalOperations'] as int? ?? 0;
      final roundSaves = queueStatus['roundSaves'] as int? ?? 0;
      final stateUpdates = queueStatus['matchStateUpdates'] as int? ?? 0;
      final oldestOp = queueStatus['oldestOperation'] as DateTime?;

      int? oldestAgeMs;
      if (oldestOp != null) {
        oldestAgeMs = DateTime.now().difference(oldestOp).inMilliseconds;
      }

      await logQueueStatus(
        totalOperations: totalOps,
        roundSaveCount: roundSaves,
        stateUpdateCount: stateUpdates,
        oldestOperationAgeMs: oldestAgeMs,
        successRate: successRate,
      );
    } catch (e) {
      debugPrint('Error logging queue health metrics: $e');
    }
  }
}
