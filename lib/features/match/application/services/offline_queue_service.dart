import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/round_result_model.dart';

/// Represents a queued Firestore operation
class QueuedOperation {
  final String id;
  final String operationType; // 'saveRound' or 'updateMatchState'
  final String matchId;
  final Map<String, dynamic> data;
  final DateTime enqueuedAt;
  final int retryCount;

  QueuedOperation({
    required this.id,
    required this.operationType,
    required this.matchId,
    required this.data,
    required this.enqueuedAt,
    this.retryCount = 0,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'operationType': operationType,
    'matchId': matchId,
    'data': data,
    'enqueuedAt': enqueuedAt.toIso8601String(),
    'retryCount': retryCount,
  };

  /// Create from JSON
  factory QueuedOperation.fromJson(Map<String, dynamic> json) {
    return QueuedOperation(
      id: json['id'] as String,
      operationType: json['operationType'] as String,
      matchId: json['matchId'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      enqueuedAt: DateTime.parse(json['enqueuedAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }
}

/// Manages offline queue of failed Firestore operations
class OfflineQueueService {
  static const String _queueKey = 'firestore_queue';
  static const int _maxRetries = 3;
  static const int _maxQueueSize = 100;

  final FlutterSecureStorage _storage;

  OfflineQueueService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Queue a failed round save operation
  Future<void> queueRoundSave({
    required String matchId,
    required RoundResultModel roundResult,
  }) async {
    final operation = QueuedOperation(
      id: 'round_${matchId}_${DateTime.now().millisecondsSinceEpoch}',
      operationType: 'saveRound',
      matchId: matchId,
      data: roundResult.toJson(),
      enqueuedAt: DateTime.now(),
    );

    await _addToQueue(operation);
    debugPrint(
      'Queued round save for $matchId (queue size: ${await getQueueSize()})',
    );
  }

  /// Queue a failed match state update
  Future<void> queueMatchStateUpdate({
    required String matchId,
    required int roundIndex,
    required String status,
    required Map<String, int> stoneCounts,
    required bool isGameOver,
  }) async {
    final operation = QueuedOperation(
      id: 'state_${matchId}_${DateTime.now().millisecondsSinceEpoch}',
      operationType: 'updateMatchState',
      matchId: matchId,
      data: {
        'matchId': matchId,
        'roundIndex': roundIndex,
        'status': status,
        'stoneCounts': stoneCounts,
        'isGameOver': isGameOver,
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      enqueuedAt: DateTime.now(),
    );

    await _addToQueue(operation);
    debugPrint(
      'Queued match state update for $matchId (queue size: ${await getQueueSize()})',
    );
  }

  /// Get all queued operations
  Future<List<QueuedOperation>> getQueue() async {
    try {
      final queueJson = await _storage.read(key: _queueKey);
      if (queueJson == null || queueJson.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(queueJson) as List<dynamic>;
      return decoded
          .map(
            (item) => QueuedOperation.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('Error reading queue: $e');
      return [];
    }
  }

  /// Get queue size
  Future<int> getQueueSize() async {
    final queue = await getQueue();
    return queue.length;
  }

  /// Remove operation from queue
  Future<void> removeFromQueue(String operationId) async {
    try {
      final queue = await getQueue();
      queue.removeWhere((op) => op.id == operationId);
      await _saveQueue(queue);
      debugPrint('Removed $operationId from queue');
    } catch (e) {
      debugPrint('Error removing from queue: $e');
    }
  }

  /// Remove all operations for a match from queue
  Future<void> removeMatchOperations(String matchId) async {
    try {
      final queue = await getQueue();
      queue.removeWhere((op) => op.matchId == matchId);
      await _saveQueue(queue);
      debugPrint('Removed all operations for $matchId from queue');
    } catch (e) {
      debugPrint('Error removing match operations: $e');
    }
  }

  /// Increment retry count for an operation
  Future<void> incrementRetryCount(String operationId) async {
    try {
      final queue = await getQueue();
      final index = queue.indexWhere((op) => op.id == operationId);
      if (index >= 0) {
        final op = queue[index];
        queue[index] = QueuedOperation(
          id: op.id,
          operationType: op.operationType,
          matchId: op.matchId,
          data: op.data,
          enqueuedAt: op.enqueuedAt,
          retryCount: op.retryCount + 1,
        );
        await _saveQueue(queue);
      }
    } catch (e) {
      debugPrint('Error incrementing retry count: $e');
    }
  }

  /// Check if operation should be retried
  bool shouldRetry(QueuedOperation operation) {
    return operation.retryCount < _maxRetries;
  }

  /// Clear entire queue
  Future<void> clearQueue() async {
    try {
      await _storage.delete(key: _queueKey);
      debugPrint('Queue cleared');
    } catch (e) {
      debugPrint('Error clearing queue: $e');
    }
  }

  /// Get queue status
  Future<Map<String, dynamic>> getQueueStatus() async {
    try {
      final queue = await getQueue();
      return {
        'totalOperations': queue.length,
        'roundSaves': queue
            .where((op) => op.operationType == 'saveRound')
            .length,
        'matchStateUpdates': queue
            .where((op) => op.operationType == 'updateMatchState')
            .length,
        'oldestOperation': queue.isEmpty
            ? null
            : queue.reduce(
          (a, b) => a.enqueuedAt.isBefore(b.enqueuedAt) ? a : b,
        ).enqueuedAt,
        'newestOperation': queue.isEmpty
            ? null
            : queue.reduce(
          (a, b) => a.enqueuedAt.isAfter(b.enqueuedAt) ? a : b,
        ).enqueuedAt,
      };
    } catch (e) {
      debugPrint('Error getting queue status: $e');
      return {};
    }
  }

  /// Private helper: add operation to queue
  Future<void> _addToQueue(QueuedOperation operation) async {
    try {
      final queue = await getQueue();

      // Check queue size limit
      if (queue.length >= _maxQueueSize) {
        debugPrint('Warning: Queue size limit reached, removing oldest operation');
        queue.removeAt(0);
      }

      queue.add(operation);
      await _saveQueue(queue);
    } catch (e) {
      debugPrint('Error adding to queue: $e');
    }
  }

  /// Private helper: save queue to storage
  Future<void> _saveQueue(List<QueuedOperation> queue) async {
    try {
      final jsonList = queue.map((op) => op.toJson()).toList();
      final encoded = jsonEncode(jsonList);
      await _storage.write(key: _queueKey, value: encoded);
    } catch (e) {
      debugPrint('Error saving queue: $e');
      rethrow;
    }
  }
}
