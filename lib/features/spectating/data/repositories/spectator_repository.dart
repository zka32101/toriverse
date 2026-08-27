import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../../domain/models/spectator_session.dart';
import '../../application/providers/spectator_providers.dart';

/// Repository for managing spectator sessions and analytics
class SpectatorRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static const String _spectatorsCollection = 'matches';
  static const String _subCollection = 'spectators';

  SpectatorRepository(this._firestore, this._auth);

  /// Watch all spectators currently watching a match (real-time stream)
  Stream<List<SpectatorSession>> watchMatchSpectators(String matchId) {
    return _firestore
        .collection(_spectatorsCollection)
        .doc(matchId)
        .collection(_subCollection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SpectatorSession.fromJson(doc.data()))
          .toList();
    });
  }

  /// Watch spectator sessions for a specific user (real-time stream)
  Stream<List<SpectatorSession>> watchUserSpectatorSessions(String userId) {
    return _firestore
        .collectionGroup(_subCollection)
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SpectatorSession.fromJson(doc.data()))
          .toList();
    });
  }

  /// Join a spectator session for a match
  ///
  /// Creates spectator document and increments match spectator count
  Future<void> joinSpectatorSession({
    required String matchId,
    required String userId,
    required String displayName,
  }) async {
    final now = DateTime.now();

    // Get device info
    final deviceInfo = DeviceInfo(
      os: 'Unknown',  // Would be determined by platform check in real implementation
      osVersion: '0',
      appVersion: '1.0.0',
      platform: 'mobile',
    );

    // Create spectator session document
    final spectatorSession = SpectatorSession(
      id: userId,
      matchId: matchId,
      userId: userId,
      displayName: displayName,
      joinedAt: now,
      role: SpectatorRole.viewer,
      deviceInfo: deviceInfo,
      isActive: true,
      lastActivityAt: now,
    );

    // Write spectator session
    await _firestore
        .collection(_spectatorsCollection)
        .doc(matchId)
        .collection(_subCollection)
        .doc(userId)
        .set(spectatorSession.toJson());

    // Increment match spectator count
    await _firestore
        .collection(_spectatorsCollection)
        .doc(matchId)
        .update({
      'spectatorCount': FieldValue.increment(1),
      'totalSpectators': FieldValue.increment(1),
    });

    // Record analytics
    await _analytics.logEvent(
      name: 'spectator_joined',
      parameters: {
        'matchId': matchId,
        'joinMethod': 'direct', // Could be 'url_share', 'friend_invite', etc.
        'userRole': 'viewer',
      },
    );
  }

  /// Leave a spectator session
  ///
  /// Removes spectator document and decrements match spectator count
  Future<void> leaveSpectatorSession({
    required String matchId,
    required String userId,
  }) async {
    // Get watch duration before deleting
    final doc = await _firestore
        .collection(_spectatorsCollection)
        .doc(matchId)
        .collection(_subCollection)
        .doc(userId)
        .get();

    final spectatorData = doc.data();
    int watchDurationSeconds = 0;

    if (spectatorData != null) {
      final joinedAt = (spectatorData['joinedAt'] as Timestamp).toDate();
      watchDurationSeconds =
          DateTime.now().difference(joinedAt).inSeconds;
    }

    // Remove spectator document
    await _firestore
        .collection(_spectatorsCollection)
        .doc(matchId)
        .collection(_subCollection)
        .doc(userId)
        .delete();

    // Decrement match spectator count
    await _firestore
        .collection(_spectatorsCollection)
        .doc(matchId)
        .update({
      'spectatorCount': FieldValue.increment(-1),
    });

    // Record analytics
    await _analytics.logEvent(
      name: 'spectator_left',
      parameters: {
        'matchId': matchId,
        'watchDurationSeconds': watchDurationSeconds,
      },
    );
  }

  /// Record spectator analytics event
  Future<void> recordSpectatorEvent(SpectatorAnalyticsEvent event) async {
    await _analytics.logEvent(
      name: event.eventType,
      parameters: {
        'matchId': event.matchId,
        ...event.parameters,
      },
    );
  }

  /// Update spectator activity timestamp (called on user interaction)
  Future<void> updateSpectatorActivity({
    required String matchId,
    required String userId,
  }) async {
    await _firestore
        .collection(_spectatorsCollection)
        .doc(matchId)
        .collection(_subCollection)
        .doc(userId)
        .update({
      'lastActivityAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get current spectator count for a match
  Future<int> getMatchSpectatorCount(String matchId) async {
    final snapshot = await _firestore
        .collection(_spectatorsCollection)
        .doc(matchId)
        .collection(_subCollection)
        .where('isActive', isEqualTo: true)
        .count()
        .get();

    return snapshot.count;
  }

  /// Get match metadata including spectator info
  Future<Map<String, dynamic>?> getMatchMetadata(String matchId) async {
    final doc = await _firestore
        .collection(_spectatorsCollection)
        .doc(matchId)
        .get();

    return doc.data();
  }

  /// Update match to enable/disable spectating
  Future<void> setMatchSpectatable({
    required String matchId,
    required bool isSpectatable,
  }) async {
    await _firestore
        .collection(_spectatorsCollection)
        .doc(matchId)
        .update({
      'isSpectatable': isSpectatable,
    });
  }
}
