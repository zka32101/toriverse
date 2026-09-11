/// Presence service for tracking user online status
///
/// Manages online/offline status and last seen timestamps for users.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PresenceService {
  final FirebaseFirestore _firestore;

  static const String _presenceCollection = 'presence';
  static const String _presenceDurationSeconds = 300; // 5 minutes

  PresenceService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Update user's online status
  ///
  /// Should be called when user opens the app or becomes active.
  Future<void> setUserOnline(String userId) async {
    try {
      await _firestore
          .collection(_presenceCollection)
          .doc(userId)
          .set({
        'uid': userId,
        'isOnline': true,
        'lastSeenAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      debugPrint('Set user $userId online');
    } catch (e) {
      debugPrint('Error setting user online: $e');
      rethrow;
    }
  }

  /// Update user's offline status
  ///
  /// Should be called when user closes the app or becomes inactive.
  Future<void> setUserOffline(String userId) async {
    try {
      await _firestore
          .collection(_presenceCollection)
          .doc(userId)
          .set({
        'uid': userId,
        'isOnline': false,
        'lastSeenAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      debugPrint('Set user $userId offline');
    } catch (e) {
      debugPrint('Error setting user offline: $e');
      rethrow;
    }
  }

  /// Check if user is currently online
  Future<bool> isUserOnline(String userId) async {
    try {
      final doc = await _firestore
          .collection(_presenceCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        return false;
      }

      final data = doc.data()!;
      final isOnline = data['isOnline'] as bool? ?? false;

      // Check if last seen is recent enough (within timeout period)
      if (isOnline) {
        final lastSeenStr = data['lastSeenAt'] as String?;
        if (lastSeenStr != null) {
          final lastSeen = DateTime.parse(lastSeenStr);
          final now = DateTime.now();
          final differenceSeconds = now.difference(lastSeen).inSeconds;

          // If status is online but hasn't been updated in timeout period,
          // consider user offline
          if (differenceSeconds > _presenceDurationSeconds) {
            return false;
          }
        }
      }

      return isOnline;
    } catch (e) {
      debugPrint('Error checking user online status: $e');
      return false;
    }
  }

  /// Get user's last seen timestamp
  Future<DateTime?> getUserLastSeen(String userId) async {
    try {
      final doc = await _firestore
          .collection(_presenceCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      final lastSeenStr = data['lastSeenAt'] as String?;

      return lastSeenStr != null ? DateTime.parse(lastSeenStr) : null;
    } catch (e) {
      debugPrint('Error fetching user last seen: $e');
      return null;
    }
  }

  /// Get online status for multiple users
  Future<Map<String, bool>> getUsersOnlineStatus(List<String> userIds) async {
    try {
      final docs = await _firestore
          .collection(_presenceCollection)
          .where(FieldPath.documentId, whereIn: userIds)
          .get();

      final statusMap = <String, bool>{};

      for (final doc in docs.docs) {
        final uid = doc.id;
        final isOnline = doc['isOnline'] as bool? ?? false;

        // Validate with timeout
        if (isOnline) {
          final lastSeenStr = doc['lastSeenAt'] as String?;
          if (lastSeenStr != null) {
            final lastSeen = DateTime.parse(lastSeenStr);
            final now = DateTime.now();
            final differenceSeconds = now.difference(lastSeen).inSeconds;

            statusMap[uid] =
                differenceSeconds <= _presenceDurationSeconds;
          } else {
            statusMap[uid] = false;
          }
        } else {
          statusMap[uid] = false;
        }
      }

      // Add offline status for users not in presence collection
      for (final uid in userIds) {
        statusMap.putIfAbsent(uid, () => false);
      }

      return statusMap;
    } catch (e) {
      debugPrint('Error fetching batch user statuses: $e');
      return {};
    }
  }

  /// Stream user's online status
  Stream<bool> streamUserOnlineStatus(String userId) {
    return _firestore
        .collection(_presenceCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return false;
      }

      final data = snapshot.data()!;
      final isOnline = data['isOnline'] as bool? ?? false;

      // Validate with timeout
      if (isOnline) {
        final lastSeenStr = data['lastSeenAt'] as String?;
        if (lastSeenStr != null) {
          final lastSeen = DateTime.parse(lastSeenStr);
          final now = DateTime.now();
          final differenceSeconds = now.difference(lastSeen).inSeconds;

          return differenceSeconds <= _presenceDurationSeconds;
        }
      }

      return isOnline;
    }).handleError((e) {
      debugPrint('Error streaming user online status: $e');
    });
  }

  /// Heartbeat to keep user online status active
  ///
  /// Should be called periodically (e.g., every minute) while user is active.
  /// This prevents the online status from timing out.
  Future<void> heartbeat(String userId) async {
    try {
      await _firestore
          .collection(_presenceCollection)
          .doc(userId)
          .update({
        'lastSeenAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      debugPrint('Heartbeat sent for user $userId');
    } catch (e) {
      // If document doesn't exist, create it
      if (e.toString().contains('not found')) {
        await setUserOnline(userId);
      } else {
        debugPrint('Error sending heartbeat: $e');
        rethrow;
      }
    }
  }

  /// Clean up old presence records (server-side Cloud Function should do this)
  ///
  /// This is a helper that could be called by a Cloud Function
  /// to clean up presence entries for users that haven't been seen in a long time.
  Future<void> cleanupStalePresence({int staleDaysOld = 30}) async {
    try {
      final threshold =
          DateTime.now().subtract(Duration(days: staleDaysOld));

      await _firestore
          .collection(_presenceCollection)
          .where('lastSeenAt', isLessThan: threshold.toIso8601String())
          .get()
          .then((snapshot) async {
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      });

      debugPrint('Cleaned up presence records older than $staleDaysOld days');
    } catch (e) {
      debugPrint('Error cleaning up presence: $e');
      rethrow;
    }
  }
}
