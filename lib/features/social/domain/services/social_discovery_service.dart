import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_public_profile_model.dart';

/// Service for discovering and viewing social profiles
class SocialDiscoveryService {
  final FirebaseFirestore _firestore;

  const SocialDiscoveryService(this._firestore);

  /// Search for users by username or UID
  Future<List<UserPublicProfile>> searchUsers(
    String query, {
    int limit = 20,
  }) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      final lowerQuery = query.toLowerCase();

      // Search by exact UID match first
      final uidMatch = await _firestore
          .collection('users')
          .doc(query)
          .collection('profiles')
          .doc('public')
          .get();

      if (uidMatch.exists) {
        return [
          UserPublicProfile.fromJson(
            uidMatch.data() as Map<String, dynamic>,
          ),
        ];
      }

      // Search by displayName (case-insensitive prefix matching)
      final nameSnapshot = await _firestore
          .collectionGroup('public')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThan: '${query}z')
          .limit(limit)
          .get();

      return nameSnapshot.docs
          .map((doc) => UserPublicProfile.fromJson(
            doc.data() as Map<String, dynamic>,
          ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get a user's public profile
  Future<UserPublicProfile?> getUserPublicProfile(String uid) async {
    try {
      if (uid.isEmpty) {
        throw Exception('Invalid UID');
      }

      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('profiles')
          .doc('public')
          .get();

      if (!doc.exists) {
        return null;
      }

      return UserPublicProfile.fromJson(
        doc.data() as Map<String, dynamic>,
      );
    } catch (e) {
      return null;
    }
  }

  /// Watch user's public profile as a stream
  Stream<UserPublicProfile?> watchUserPublicProfile(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('profiles')
        .doc('public')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return UserPublicProfile.fromJson(
        snapshot.data() as Map<String, dynamic>,
      );
    }).handleError((e) {
      return null;
    });
  }

  /// Get recent players from user's recent matches
  Future<List<UserPublicProfile>> getRecentPlayers(
    String uid, {
    int limit = 10,
  }) async {
    try {
      if (uid.isEmpty) {
        throw Exception('Invalid UID');
      }

      // Get recent matches from matchHistory or similar
      // For now, return empty - this would need match history collection
      // TODO: Implement once match history is available
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get leaderboard of users sorted by specified criteria
  Future<List<UserPublicProfile>> getLeaderboard({
    String sortBy = 'rankPoints', // rankPoints, followers, socialRank
    int limit = 100,
  }) async {
    try {
      Query query = _firestore.collectionGroup('public');

      if (sortBy == 'rankPoints') {
        query = query
            .orderBy('rankPoints', descending: true)
            .limit(limit);
      } else if (sortBy == 'followers') {
        query = query
            .orderBy('followers', descending: true)
            .limit(limit);
      } else if (sortBy == 'socialRank') {
        query = query
            .orderBy('socialRank', descending: true)
            .limit(limit);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => UserPublicProfile.fromJson(
            doc.data() as Map<String, dynamic>,
          ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Follow a user (one-way social connection)
  Future<void> followUser({
    required String followerUid,
    required String followingUid,
  }) async {
    try {
      if (followerUid == followingUid) {
        throw Exception('Cannot follow yourself');
      }

      if (followerUid.isEmpty || followingUid.isEmpty) {
        throw Exception('Invalid UIDs');
      }

      final batch = _firestore.batch();

      // Add to follower's following list
      batch.set(
        _firestore
            .collection('users')
            .doc(followerUid)
            .collection('following')
            .doc(followingUid),
        {
          'followedUid': followingUid,
          'followedAt': FieldValue.serverTimestamp(),
        },
      );

      // Add to followed user's followers list
      batch.set(
        _firestore
            .collection('users')
            .doc(followingUid)
            .collection('followers')
            .doc(followerUid),
        {
          'followerUid': followerUid,
          'followedAt': FieldValue.serverTimestamp(),
        },
      );

      // Increment follower count on public profile
      batch.update(
        _firestore
            .collection('users')
            .doc(followingUid)
            .collection('profiles')
            .doc('public'),
        {'followers': FieldValue.increment(1)},
      );

      // Increment following count on follower's public profile
      batch.update(
        _firestore
            .collection('users')
            .doc(followerUid)
            .collection('profiles')
            .doc('public'),
        {'following': FieldValue.increment(1)},
      );

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Unfollow a user
  Future<void> unfollowUser({
    required String followerUid,
    required String followingUid,
  }) async {
    try {
      if (followerUid.isEmpty || followingUid.isEmpty) {
        throw Exception('Invalid UIDs');
      }

      final batch = _firestore.batch();

      // Remove from follower's following list
      batch.delete(
        _firestore
            .collection('users')
            .doc(followerUid)
            .collection('following')
            .doc(followingUid),
      );

      // Remove from followed user's followers list
      batch.delete(
        _firestore
            .collection('users')
            .doc(followingUid)
            .collection('followers')
            .doc(followerUid),
      );

      // Decrement follower count on public profile
      batch.update(
        _firestore
            .collection('users')
            .doc(followingUid)
            .collection('profiles')
            .doc('public'),
        {'followers': FieldValue.increment(-1)},
      );

      // Decrement following count on follower's public profile
      batch.update(
        _firestore
            .collection('users')
            .doc(followerUid)
            .collection('profiles')
            .doc('public'),
        {'following': FieldValue.increment(-1)},
      );

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Check if user is following another user
  Future<bool> isFollowing({
    required String followerUid,
    required String followingUid,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(followerUid)
          .collection('following')
          .doc(followingUid)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get follower count for a user
  Future<int> getFollowerCount(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('followers')
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get following count for a user
  Future<int> getFollowingCount(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('following')
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get users followed by a user as a stream
  Stream<List<UserPublicProfile>> getFollowingStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('following')
        .snapshots()
        .asyncMap((snapshot) async {
      final profiles = <UserPublicProfile>[];

      for (final doc in snapshot.docs) {
        final followedUid = doc['followedUid'] as String?;
        if (followedUid != null) {
          final profile = await getUserPublicProfile(followedUid);
          if (profile != null) {
            profiles.add(profile);
          }
        }
      }

      return profiles;
    }).handleError((e) {
      return [];
    });
  }
}
