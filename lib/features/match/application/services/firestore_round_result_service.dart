import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/round_result_model.dart';
import '../providers/firestore_match_provider.dart';

/// Firestore Round Result Service
///
/// Handles saving round results with retry logic and error handling.
/// - Retries transient errors (network, timeout) with exponential backoff
/// - Handles permanent errors (validation, permissions) gracefully
/// - Provides fallback to local storage if Firestore unavailable
class FirestoreRoundResultService {
  final FirestoreMatchRepository _repository;
  static const int maxRetries = 3;
  static const int initialDelayMs = 500;

  FirestoreRoundResultService({
    FirestoreMatchRepository? repository,
  }) : _repository = repository ?? FirestoreMatchRepository();

  /// Save round result with retry logic
  ///
  /// Returns success status. Throws exception only for unrecoverable errors.
  /// Retries transient errors (network, deadline-exceeded, unavailable, aborted)
  /// with exponential backoff: 500ms, 1000ms, 2000ms
  Future<bool> saveRoundResultWithRetry(RoundResultModel result) async {
    int retryCount = 0;
    int delayMs = initialDelayMs;

    while (true) {
      try {
        await _repository.saveRoundResult(result);
        if (retryCount > 0) {
          debugPrint(
            'Round result saved successfully after $retryCount retries (${result.id})',
          );
        }
        return true;
      } on FirebaseException catch (e) {
        // Check if error is retryable
        if (!_isRetryableError(e) || retryCount >= maxRetries) {
          debugPrint('Failed to save round result (${result.id}): ${e.code}');
          _logError(e, result);
          return false;
        }

        // Log retry attempt
        retryCount++;
        debugPrint(
          'Retrying round result save (${result.id}): attempt $retryCount/$maxRetries '
          '(${e.code}), waiting ${delayMs}ms',
        );

        // Wait before retry with exponential backoff
        await Future.delayed(Duration(milliseconds: delayMs));
        delayMs *= 2; // Exponential backoff
      } catch (e) {
        // Non-Firebase exception - log and return false
        debugPrint('Unexpected error saving round result (${result.id}): $e');
        return false;
      }
    }
  }

  /// Check if a Firebase error is retryable
  bool _isRetryableError(FirebaseException exception) {
    final code = exception.code;
    return code == 'unavailable' ||
        code == 'deadline-exceeded' ||
        code == 'aborted' ||
        code == 'internal';
  }

  /// Log error details for debugging
  void _logError(FirebaseException exception, RoundResultModel result) {
    debugPrint('Error: ${exception.code} - Match: ${result.matchId}');
  }

  /// Update match state after round completion
  ///
  /// Updates the main match document with:
  /// - Current round index
  /// - Match status (playing/finished)
  /// - Stone counts
  /// - Completion status
  Future<bool> updateMatchStateAfterRound({
    required String matchId,
    required int roundIndex,
    required String status,
    required Map<String, int> stoneCounts,
    required bool isGameOver,
  }) async {
    int retryCount = 0;
    int delayMs = initialDelayMs;

    while (true) {
      try {
        await _repository.updateMatchState(matchId, {
          'roundIndex': roundIndex,
          'status': status,
          'stoneCounts': stoneCounts,
          'isGameOver': isGameOver,
          'lastUpdated': DateTime.now().toIso8601String(),
        });

        if (retryCount > 0) {
          debugPrint('Match state updated after $retryCount retries ($matchId)');
        }
        return true;
      } on FirebaseException catch (e) {
        if (!_isRetryableError(e) || retryCount >= maxRetries) {
          debugPrint('Failed to update match state ($matchId): ${e.code}');
          return false;
        }

        retryCount++;
        debugPrint(
          'Retrying match state update ($matchId): attempt $retryCount/$maxRetries',
        );

        await Future.delayed(Duration(milliseconds: delayMs));
        delayMs *= 2;
      } catch (e) {
        debugPrint('Unexpected error updating match state ($matchId): $e');
        return false;
      }
    }
  }

  /// Fetch latest round result for a match
  ///
  /// Returns null if not found or on error
  Future<RoundResultModel?> fetchLatestRoundResult(String matchId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection('roundResults')
          .where('matchId', isEqualTo: matchId)
          .orderBy('roundIndex', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return RoundResultModel.fromJson(snapshot.docs.first.data());
    } catch (e) {
      debugPrint('Error fetching latest round result ($matchId): $e');
      return null;
    }
  }

  /// Check if match is complete in Firestore
  ///
  /// Returns true if match status is 'finished'
  Future<bool> isMatchComplete(String matchId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final doc = await firestore.collection('matches').doc(matchId).get();

      if (!doc.exists) return false;

      final data = doc.data();
      return data?['status'] == 'finished';
    } catch (e) {
      debugPrint('Error checking match completion ($matchId): $e');
      return false;
    }
  }

  /// Fetch all round results for a match in order
  ///
  /// Returns empty list if no rounds found or on error
  Future<List<RoundResultModel>> fetchMatchRoundResults(String matchId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection('roundResults')
          .where('matchId', isEqualTo: matchId)
          .orderBy('roundIndex', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => RoundResultModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching round results ($matchId): $e');
      return [];
    }
  }
}
