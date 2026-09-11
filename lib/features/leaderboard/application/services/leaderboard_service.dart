/// Leaderboard service for querying and managing rankings
///
/// Handles leaderboard queries, ranking updates, and real-time listeners.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../leaderboard/domain/models/leaderboard_models.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore;

  static const String _playersCollection = 'players';
  static const String _leaderboardsCollection = 'leaderboards';
  static const String _globalLeaderboardDoc = 'global';

  LeaderboardService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get global leaderboard (top N players)
  Future<Leaderboard> getGlobalLeaderboard({int limit = 100}) async {
    try {
      final snapshot = await _firestore
          .collection(_leaderboardsCollection)
          .doc(_globalLeaderboardDoc)
          .collection('entries')
          .orderBy('rankPoints', descending: true)
          .orderBy('username', descending: false)
          .limit(limit)
          .get();

      final entries = snapshot.docs.map((doc) {
        final data = doc.data();
        return PlayerLeaderboardEntry.fromJson({...data, 'uid': doc.id});
      }).toList();

      // Assign ranks
      final entriesWithRanks = entries.asMap().entries.map((entry) {
        return entry.value.copyWith(rank: entry.key + 1);
      }).toList();

      return Leaderboard(
        entries: entriesWithRanks,
        period: 'all-time',
        fetchedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error fetching global leaderboard: $e');
      rethrow;
    }
  }

  /// Get player's current rank
  Future<int?> getPlayerRank(String uid) async {
    try {
      final snapshot = await _firestore
          .collection(_leaderboardsCollection)
          .doc(_globalLeaderboardDoc)
          .collection('entries')
          .orderBy('rankPoints', descending: true)
          .orderBy('username', descending: false)
          .get();

      final entries = snapshot.docs;
      for (int i = 0; i < entries.length; i++) {
        if (entries[i].id == uid) {
          return i + 1; // 1-indexed rank
        }
      }
      return null; // Player not in leaderboard
    } catch (e) {
      debugPrint('Error fetching player rank for $uid: $e');
      return null;
    }
  }

  /// Get player's leaderboard entry
  Future<PlayerLeaderboardEntry?> getPlayerEntry(String uid) async {
    try {
      final doc = await _firestore
          .collection(_leaderboardsCollection)
          .doc(_globalLeaderboardDoc)
          .collection('entries')
          .doc(uid)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      return PlayerLeaderboardEntry.fromJson({...data, 'uid': uid});
    } catch (e) {
      debugPrint('Error fetching leaderboard entry for $uid: $e');
      return null;
    }
  }

  /// Get leaderboard around a specific rank
  Future<List<PlayerLeaderboardEntry>> getPlayersNearRank(
    String uid, {
    int radius = 5,
  }) async {
    try {
      final playerRank = await getPlayerRank(uid);
      if (playerRank == null) {
        return [];
      }

      final snapshot = await _firestore
          .collection(_leaderboardsCollection)
          .doc(_globalLeaderboardDoc)
          .collection('entries')
          .orderBy('rankPoints', descending: true)
          .orderBy('username', descending: false)
          .get();

      final start = (playerRank - radius - 1).clamp(0, snapshot.docs.length);
      final end =
          (playerRank + radius).clamp(0, snapshot.docs.length);

      final entries = snapshot.docs
          .sublist(start, end)
          .asMap()
          .entries
          .map((entry) {
        final data = entry.value.data();
        return PlayerLeaderboardEntry.fromJson({
          ...data,
          'uid': entry.value.id,
          'rank': start + entry.key + 1,
        });
      }).toList();

      return entries;
    } catch (e) {
      debugPrint('Error fetching players near rank for $uid: $e');
      return [];
    }
  }

  /// Search leaderboard by username (prefix search)
  Future<List<PlayerLeaderboardEntry>> searchByUsername(
    String query, {
    int limit = 20,
  }) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      final snapshot = await _firestore
          .collection(_leaderboardsCollection)
          .doc(_globalLeaderboardDoc)
          .collection('entries')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThan: query + 'z')
          .orderBy('username')
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return PlayerLeaderboardEntry.fromJson({...data, 'uid': doc.id});
      }).toList();
    } catch (e) {
      debugPrint('Error searching players by username: $e');
      return [];
    }
  }

  /// Update player's rank points (server-side via Cloud Function in production)
  Future<void> updatePlayerRankPoints({
    required String uid,
    required int pointsChange,
    required String reason,
  }) async {
    try {
      await _firestore
          .collection(_leaderboardsCollection)
          .doc(_globalLeaderboardDoc)
          .collection('entries')
          .doc(uid)
          .update({
        'rankPoints': FieldValue.increment(pointsChange),
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      debugPrint(
        'Updated rank points for $uid: $pointsChange ($reason)',
      );
    } catch (e) {
      debugPrint('Error updating rank points for $uid: $e');
      rethrow;
    }
  }

  /// Stream global leaderboard changes
  Stream<Leaderboard> streamGlobalLeaderboard({int limit = 100}) {
    return _firestore
        .collection(_leaderboardsCollection)
        .doc(_globalLeaderboardDoc)
        .collection('entries')
        .orderBy('rankPoints', descending: true)
        .orderBy('username', descending: false)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final entries = snapshot.docs
          .asMap()
          .entries
          .map((entry) {
        final data = entry.value.data();
        return PlayerLeaderboardEntry.fromJson({
          ...data,
          'uid': entry.value.id,
          'rank': entry.key + 1,
        });
      }).toList();

      return Leaderboard(
        entries: entries,
        period: 'all-time',
        fetchedAt: DateTime.now(),
      );
    }).handleError((e) {
      debugPrint('Error streaming leaderboard: $e');
    });
  }

  /// Stream a specific player's leaderboard entry
  Stream<PlayerLeaderboardEntry?> streamPlayerEntry(String uid) {
    return _firestore
        .collection(_leaderboardsCollection)
        .doc(_globalLeaderboardDoc)
        .collection('entries')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data()!;
      return PlayerLeaderboardEntry.fromJson({...data, 'uid': uid});
    }).handleError((e) {
      debugPrint('Error streaming player entry for $uid: $e');
    });
  }

  /// Initialize player in leaderboard (called after first match)
  Future<void> initializePlayerLeaderboard({
    required String uid,
    required String username,
  }) async {
    try {
      final existingDoc = await _firestore
          .collection(_leaderboardsCollection)
          .doc(_globalLeaderboardDoc)
          .collection('entries')
          .doc(uid)
          .get();

      if (!existingDoc.exists) {
        await _firestore
            .collection(_leaderboardsCollection)
            .doc(_globalLeaderboardDoc)
            .collection('entries')
            .doc(uid)
            .set({
          'username': username,
          'rankPoints': 0,
          'completedMatchStreak': 0,
          'totalMatches': 0,
          'totalWins': 0,
          'totalLosses': 0,
          'winRate': 0.0,
          'lastUpdated': DateTime.now().toIso8601String(),
        });

        debugPrint('Initialized leaderboard for player $uid');
      }
    } catch (e) {
      debugPrint('Error initializing leaderboard for $uid: $e');
      rethrow;
    }
  }

  /// Get top N friends (used by friend leaderboard)
  Future<List<PlayerLeaderboardEntry>> getTopFriends(
    String uid,
    List<String> friendUids, {
    int limit = 50,
  }) async {
    try {
      if (friendUids.isEmpty) {
        return [];
      }

      final snapshot = await _firestore
          .collection(_leaderboardsCollection)
          .doc(_globalLeaderboardDoc)
          .collection('entries')
          .where(FieldPath.documentId, whereIn: friendUids)
          .orderBy('rankPoints', descending: true)
          .orderBy('username', descending: false)
          .limit(limit)
          .get();

      return snapshot.docs.asMap().entries.map((entry) {
        final data = entry.value.data();
        return PlayerLeaderboardEntry.fromJson({
          ...data,
          'uid': entry.value.id,
          'rank': entry.key + 1, // Rank among friends
        });
      }).toList();
    } catch (e) {
      debugPrint('Error fetching top friends for $uid: $e');
      return [];
    }
  }
}
