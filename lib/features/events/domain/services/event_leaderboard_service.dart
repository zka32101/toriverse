import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/leaderboard_model.dart';

/// Service for managing event leaderboards
class EventLeaderboardService {
  final FirebaseFirestore _firestore;

  const EventLeaderboardService(this._firestore);

  /// Get event leaderboard as a stream
  Stream<List<LeaderboardEntry>> watchLeaderboard(
    String eventId, {
    int limit = 100,
  }) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('leaderboard')
        .orderBy('rank')
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              LeaderboardEntry.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    }).handleError((e) {
      return [];
    });
  }

  /// Get leaderboard entries
  Future<List<LeaderboardEntry>> getLeaderboard(
    String eventId, {
    int limit = 100,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('leaderboard')
          .orderBy('rank')
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) =>
              LeaderboardEntry.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get user's rank in event
  Future<LeaderboardEntry?> getUserRankEntry({
    required String eventId,
    required String uid,
  }) async {
    try {
      final entryId = '${eventId}_${uid}';
      final doc = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('leaderboard')
          .doc(entryId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return LeaderboardEntry.fromJson(
        doc.data() as Map<String, dynamic>,
      );
    } catch (e) {
      return null;
    }
  }

  /// Update leaderboard entry
  Future<void> updateLeaderboardEntry({
    required String eventId,
    required String uid,
    required String displayName,
    required int score,
    required int completedChallenges,
    required int unlockedCosmetics,
  }) async {
    try {
      final entryId = '${eventId}_${uid}';

      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('leaderboard')
          .doc(entryId)
          .set({
        'id': entryId,
        'eventId': eventId,
        'uid': uid,
        'displayName': displayName,
        'score': score,
        'rank': 0, // Would be recalculated in transaction
        'completedChallenges': completedChallenges,
        'unlockedCosmetics': unlockedCosmetics,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  /// Add points to leaderboard entry
  Future<void> addPoints({
    required String eventId,
    required String uid,
    required int points,
  }) async {
    try {
      final entryId = '${eventId}_${uid}';

      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('leaderboard')
          .doc(entryId)
          .update({
        'score': FieldValue.increment(points),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silent failure
    }
  }

  /// Increment challenge completion count
  Future<void> incrementChallengeCount({
    required String eventId,
    required String uid,
  }) async {
    try {
      final entryId = '${eventId}_${uid}';

      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('leaderboard')
          .doc(entryId)
          .update({
        'completedChallenges': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silent failure
    }
  }

  /// Increment unlocked cosmetics count
  Future<void> incrementCosmeticCount({
    required String eventId,
    required String uid,
  }) async {
    try {
      final entryId = '${eventId}_${uid}';

      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('leaderboard')
          .doc(entryId)
          .update({
        'unlockedCosmetics': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silent failure
    }
  }

  /// Get top N players
  Future<List<LeaderboardEntry>> getTopPlayers(
    String eventId, {
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('leaderboard')
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) =>
              LeaderboardEntry.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get players around user's rank
  Future<List<LeaderboardEntry>> getPlayersAroundRank({
    required String eventId,
    required String uid,
    int range = 5, // Show 5 above and 5 below
  }) async {
    try {
      // Get user's entry
      final userEntry = await getUserRankEntry(
        eventId: eventId,
        uid: uid,
      );

      if (userEntry == null) {
        return [];
      }

      // Get surrounding entries
      final minRank = (userEntry.rank - range).clamp(1, 999999);
      final maxRank = userEntry.rank + range;

      final snapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('leaderboard')
          .where('rank', isGreaterThanOrEqualTo: minRank)
          .where('rank', isLessThanOrEqualTo: maxRank)
          .orderBy('rank')
          .get();

      return snapshot.docs
          .map((doc) =>
              LeaderboardEntry.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get total participants
  Future<int> getTotalParticipants(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('leaderboard')
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
