import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/event_model.dart';

/// Service for managing events and campaigns
class EventService {
  final FirebaseFirestore _firestore;

  const EventService(this._firestore);

  /// Get all active events as a stream
  Stream<List<Event>> getActiveEventsStream() {
    return _firestore
        .collection('events')
        .where('status', isEqualTo: 'active')
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    }).handleError((e) {
      return [];
    });
  }

  /// Get upcoming events
  Future<List<Event>> getUpcomingEvents({int limit = 5}) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .where('status', isEqualTo: 'upcoming')
          .orderBy('startDate')
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get event details by ID
  Future<Event?> getEventDetails(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();

      if (!doc.exists) {
        return null;
      }

      return Event.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Watch event details as a stream
  Stream<Event?> watchEventDetails(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return Event.fromJson(snapshot.data() as Map<String, dynamic>);
    }).handleError((e) {
      return null;
    });
  }

  /// Get challenges for an event
  Future<List<Challenge>> getEventChallenges(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('challenges')
          .orderBy('startDate')
          .get();

      return snapshot.docs
          .map((doc) => Challenge.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get challenges as a stream
  Stream<List<Challenge>> getChallengesStream(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('challenges')
        .orderBy('startDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Challenge.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    }).handleError((e) {
      return [];
    });
  }

  /// Join an event
  Future<void> joinEvent({
    required String uid,
    required String eventId,
  }) async {
    try {
      if (uid.isEmpty || eventId.isEmpty) {
        throw Exception('Invalid parameters');
      }

      // Check event exists
      final eventDoc =
          await _firestore.collection('events').doc(eventId).get();

      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      final event =
          Event.fromJson(eventDoc.data() as Map<String, dynamic>);

      // Check if already joined
      final existingProgress = await _firestore
          .collection('users')
          .doc(uid)
          .collection('eventProgress')
          .doc(eventId)
          .get();

      if (existingProgress.exists) {
        throw Exception('Already joined this event');
      }

      // Create event progress
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('eventProgress')
          .doc(eventId)
          .set({
        'eventId': eventId,
        'uid': uid,
        'totalScore': 0,
        'completedChallenges': [],
        'unlockedCosmetics': [],
        'currentRankPosition': 0,
        'joinedAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Get user's progress in an event
  Future<EventProgress?> getEventProgress({
    required String uid,
    required String eventId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('eventProgress')
          .doc(eventId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return EventProgress.fromJson(
        doc.data() as Map<String, dynamic>,
      );
    } catch (e) {
      return null;
    }
  }

  /// Watch event progress as a stream
  Stream<EventProgress?> watchEventProgress({
    required String uid,
    required String eventId,
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('eventProgress')
        .doc(eventId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      return EventProgress.fromJson(
        snapshot.data() as Map<String, dynamic>,
      );
    }).handleError((e) {
      return null;
    });
  }

  /// Add score to user's event progress
  Future<void> addEventScore({
    required String uid,
    required String eventId,
    required int points,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('eventProgress')
          .doc(eventId)
          .update({
        'totalScore': FieldValue.increment(points),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silent failure
    }
  }

  /// Mark challenge as completed
  Future<void> completeChallenge({
    required String uid,
    required String eventId,
    required String challengeId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('eventProgress')
          .doc(eventId)
          .update({
        'completedChallenges': FieldValue.arrayUnion([challengeId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Unlock cosmetic for user in event
  Future<void> unlockCosmetic({
    required String uid,
    required String eventId,
    required String cosmeticId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('eventProgress')
          .doc(eventId)
          .update({
        'unlockedCosmetics': FieldValue.arrayUnion([cosmeticId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Get all user's active events
  Future<List<EventProgress>> getUserActiveEvents(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('eventProgress')
          .where('joinedAt',
              isLessThanOrEqualTo:
                  DateTime.now()) // Only joined events
          .get();

      return snapshot.docs
          .map(
            (doc) => EventProgress.fromJson(
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get event leaderboard
  Future<List<LeaderboardEntry>> getEventLeaderboard(
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
          .map((doc) {
            final data = doc.data();
            return LeaderboardEntry.fromJson(data);
          })
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Watch event leaderboard as a stream
  Stream<List<LeaderboardEntry>> watchEventLeaderboard(
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

  /// Get user's rank in event
  Future<int?> getUserRank({
    required String uid,
    required String eventId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('leaderboard')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return LeaderboardEntry.fromJson(
        snapshot.docs.first.data() as Map<String, dynamic>,
      ).rank;
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
      // Get current rank (simplified - in production, use batch transaction)
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
        'rank': 0, // Would be calculated in transaction
        'completedChallenges': completedChallenges,
        'unlockedCosmetics': unlockedCosmetics,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Silent failure
    }
  }

  /// Check if user has joined event
  Future<bool> hasJoinedEvent({
    required String uid,
    required String eventId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('eventProgress')
          .doc(eventId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}
