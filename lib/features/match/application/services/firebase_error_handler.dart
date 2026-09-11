import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// Firebase-specific error handling
class FirebaseErrorHandler {
  /// Handle Firebase exceptions with logging and user-friendly messages
  static String handleFirestoreError(FirebaseException e) {
    developer.log(
      'Firestore Error: ${e.code} - ${e.message}',
      name: 'FirebaseErrorHandler',
      level: 900,
    );

    switch (e.code) {
      case 'permission-denied':
        return 'この操作を実行する権限がありません';
      case 'not-found':
        return 'データが見つかりません';
      case 'already-exists':
        return 'このデータは既に存在します';
      case 'invalid-argument':
        return '無効なデータが渡されました';
      case 'failed-precondition':
        return 'この操作を実行するための前提条件が満たされていません';
      case 'aborted':
        return '操作がキャンセルされました';
      case 'out-of-range':
        return 'データの範囲が不正です';
      case 'unimplemented':
        return 'この機能は実装されていません';
      case 'internal':
        return 'サーバーでエラーが発生しました';
      case 'unavailable':
        return 'サービスが一時的に利用できません。もう一度お試しください';
      case 'data-loss':
        return 'データの損失が発生しました';
      case 'unauthenticated':
        return '認証が必要です。ログインしてください';
      case 'deadline-exceeded':
        return 'リクエストがタイムアウトしました';
      default:
        return 'エラーが発生しました: ${e.message}';
    }
  }

  /// Retry logic for transient failures
  static Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(milliseconds: 100),
  }) async {
    int retryCount = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        return await operation();
      } on FirebaseException catch (e) {
        // Only retry on transient errors
        if (!_isTransientError(e.code) || retryCount >= maxRetries) {
          rethrow;
        }

        retryCount++;
        developer.log(
          'Retrying operation (attempt $retryCount/$maxRetries) after $delay',
          name: 'FirebaseErrorHandler',
        );

        await Future.delayed(delay);
        delay = Duration(milliseconds: delay.inMilliseconds * 2);
      }
    }
  }

  /// Check if error is transient (worth retrying)
  static bool _isTransientError(String code) {
    return code == 'unavailable' ||
        code == 'deadline-exceeded' ||
        code == 'internal' ||
        code == 'aborted';
  }

  /// Check if error is permission-related (not worth retrying)
  static bool isPermissionError(FirebaseException e) {
    return e.code == 'permission-denied' || e.code == 'unauthenticated';
  }

  /// Check if error is data validation error
  static bool isValidationError(FirebaseException e) {
    return e.code == 'invalid-argument' ||
        e.code == 'out-of-range' ||
        e.code == 'failed-precondition';
  }
}

/// Error state for UI
class FirebaseErrorState {
  final String message;
  final String code;
  final DateTime timestamp;
  final bool isRetryable;

  FirebaseErrorState({
    required this.message,
    required this.code,
    this.isRetryable = true,
  }) : timestamp = DateTime.now();

  @override
  String toString() => '$code: $message';
}
