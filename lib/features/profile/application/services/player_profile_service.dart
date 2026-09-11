/// Player profile service for managing player profiles and achievements
///
/// Handles profile CRUD, stats calculation, achievements, and badges.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../profile/domain/models/player_profile_models.dart';

class PlayerProfileService {
  final FirebaseFirestore _firestore;

  static const String _usersCollection = 'users';
  static const String _profilesCollection = 'profiles';
  static const String _achievementsCollection = 'achievements';

  PlayerProfileService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Create or update player profile
  Future<void> upsertProfile({
    required String uid,
    required String username,
    String? avatar,
    String? bio,
  }) async {
    try {
      final now = DateTime.now();

      await _firestore.collection(_profilesCollection).doc(uid).set({
        'uid': uid,
        'username': username,
        'avatar': avatar,
        'bio': bio,
        'joinedAt': now.toIso8601String(),
        'totalMatches': 0,
        'totalWins': 0,
        'totalLosses': 0,
        'winRate': 0.0,
        'currentRank': 0,
        'currentRankPoints': 0,
        'matchStreak': 0,
        'bestStreak': 0,
        'friendCount': 0,
        'blockedCount': 0,
        'isPublic': true,
        'lastUpdated': now.toIso8601String(),
      }, SetOptions(merge: true));

      debugPrint('Upserted profile for user $uid');
    } catch (e) {
      debugPrint('Error upserting profile: $e');
      rethrow;
    }
  }

  /// Get player profile
  Future<PlayerProfile?> getProfile(String uid) async {
    try {
      final doc =
          await _firestore.collection(_profilesCollection).doc(uid).get();

      if (!doc.exists) {
        return null;
      }

      return PlayerProfile.fromJson({...doc.data()!, 'uid': uid});
    } catch (e) {
      debugPrint('Error fetching profile for $uid: $e');
      return null;
    }
  }

  /// Update profile bio
  Future<void> updateBio({
    required String uid,
    required String bio,
  }) async {
    try {
      await _firestore.collection(_profilesCollection).doc(uid).update({
        'bio': bio,
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      debugPrint('Updated bio for user $uid');
    } catch (e) {
      debugPrint('Error updating bio: $e');
      rethrow;
    }
  }

  /// Update avatar URL
  Future<void> updateAvatar({
    required String uid,
    required String avatarUrl,
  }) async {
    try {
      await _firestore.collection(_profilesCollection).doc(uid).update({
        'avatar': avatarUrl,
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      debugPrint('Updated avatar for user $uid');
    } catch (e) {
      debugPrint('Error updating avatar: $e');
      rethrow;
    }
  }

  /// Update profile visibility
  Future<void> setProfileVisibility({
    required String uid,
    required bool isPublic,
  }) async {
    try {
      await _firestore.collection(_profilesCollection).doc(uid).update({
        'isPublic': isPublic,
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      debugPrint('Updated visibility for user $uid to $isPublic');
    } catch (e) {
      debugPrint('Error updating visibility: $e');
      rethrow;
    }
  }

  /// Update player stats (typically called by match completion)
  Future<void> updateStats({
    required String uid,
    required int totalMatches,
    required int totalWins,
    required int totalLosses,
    required double winRate,
    required int matchStreak,
    required int bestStreak,
  }) async {
    try {
      await _firestore.collection(_profilesCollection).doc(uid).update({
        'totalMatches': totalMatches,
        'totalWins': totalWins,
        'totalLosses': totalLosses,
        'winRate': winRate,
        'matchStreak': matchStreak,
        'bestStreak': bestStreak,
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      debugPrint('Updated stats for user $uid');
    } catch (e) {
      debugPrint('Error updating stats: $e');
      rethrow;
    }
  }

  /// Update rank info (called by leaderboard updates)
  Future<void> updateRankInfo({
    required String uid,
    required int rank,
    required int rankPoints,
  }) async {
    try {
      await _firestore.collection(_profilesCollection).doc(uid).update({
        'currentRank': rank,
        'currentRankPoints': rankPoints,
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      debugPrint('Updated rank info for user $uid: rank=$rank, points=$rankPoints');
    } catch (e) {
      debugPrint('Error updating rank info: $e');
      rethrow;
    }
  }

  /// Update friend/blocked counts
  Future<void> updateSocialCounts({
    required String uid,
    required int friendCount,
    required int blockedCount,
  }) async {
    try {
      await _firestore.collection(_profilesCollection).doc(uid).update({
        'friendCount': friendCount,
        'blockedCount': blockedCount,
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      debugPrint('Updated social counts for user $uid');
    } catch (e) {
      debugPrint('Error updating social counts: $e');
      rethrow;
    }
  }

  /// Unlock achievement
  Future<void> unlockAchievement({
    required String uid,
    required String achievementId,
  }) async {
    try {
      // Check if already unlocked
      final existing = await _firestore
          .collection(_profilesCollection)
          .doc(uid)
          .collection(_achievementsCollection)
          .doc(achievementId)
          .get();

      if (existing.exists) {
        return; // Already unlocked
      }

      final achievement = AchievementDefinitions.getAchievementById(achievementId);
      if (achievement == null) {
        throw ArgumentError('Unknown achievement: $achievementId');
      }

      await _firestore
          .collection(_profilesCollection)
          .doc(uid)
          .collection(_achievementsCollection)
          .doc(achievementId)
          .set(achievement.toJson());

      debugPrint('Unlocked achievement $achievementId for user $uid');
    } catch (e) {
      debugPrint('Error unlocking achievement: $e');
      rethrow;
    }
  }

  /// Get player achievements
  Future<List<Achievement>> getAchievements(String uid) async {
    try {
      final snapshot = await _firestore
          .collection(_profilesCollection)
          .doc(uid)
          .collection(_achievementsCollection)
          .get();

      return snapshot.docs
          .map((doc) => Achievement.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching achievements for $uid: $e');
      return [];
    }
  }

  /// Get specific achievement status
  Future<bool> hasAchievement({
    required String uid,
    required String achievementId,
  }) async {
    try {
      final doc = await _firestore
          .collection(_profilesCollection)
          .doc(uid)
          .collection(_achievementsCollection)
          .doc(achievementId)
          .get();

      return doc.exists;
    } catch (e) {
      debugPrint('Error checking achievement status: $e');
      return false;
    }
  }

  /// Stream player profile
  Stream<PlayerProfile?> streamProfile(String uid) {
    return _firestore
        .collection(_profilesCollection)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      return PlayerProfile.fromJson({...snapshot.data()!, 'uid': uid});
    }).handleError((e) {
      debugPrint('Error streaming profile for $uid: $e');
    });
  }

  /// Search profiles by username (case-insensitive prefix)
  Future<List<PlayerProfile>> searchProfiles({
    required String query,
    int limit = 20,
  }) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      final queryLower = query.toLowerCase();

      // Firestore prefix search
      final snapshot = await _firestore
          .collection(_profilesCollection)
          .where('username', isGreaterThanOrEqualTo: queryLower)
          .where('username', isLessThan: queryLower + 'z')
          .where('isPublic', isEqualTo: true)
          .orderBy('username')
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PlayerProfile.fromJson({...doc.data(), 'uid': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('Error searching profiles: $e');
      return [];
    }
  }

  /// Get trending players by rank points
  Future<List<PlayerProfile>> getTrendingPlayers({
    Duration withinDays = const Duration(days: 7),
    int limit = 20,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(withinDays);

      final snapshot = await _firestore
          .collection(_profilesCollection)
          .where('isPublic', isEqualTo: true)
          .where('lastUpdated',
              isGreaterThan: cutoffDate.toIso8601String())
          .orderBy('lastUpdated', descending: true)
          .orderBy('currentRankPoints', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PlayerProfile.fromJson({...doc.data(), 'uid': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('Error fetching trending players: $e');
      return [];
    }
  }

  /// Delete profile (account deletion)
  Future<void> deleteProfile(String uid) async {
    try {
      final batch = _firestore.batch();

      // Delete achievements
      final achievements = await _firestore
          .collection(_profilesCollection)
          .doc(uid)
          .collection(_achievementsCollection)
          .get();

      for (final doc in achievements.docs) {
        batch.delete(doc.reference);
      }

      // Delete profile
      batch.delete(
        _firestore.collection(_profilesCollection).doc(uid),
      );

      await batch.commit();

      debugPrint('Deleted profile for user $uid');
    } catch (e) {
      debugPrint('Error deleting profile: $e');
      rethrow;
    }
  }
}
