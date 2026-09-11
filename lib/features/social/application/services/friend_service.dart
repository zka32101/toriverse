/// Friend service for managing friend relationships
///
/// Handles friend requests, friend list management, and blocking.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../social/domain/models/friend_models.dart';

class FriendService {
  final FirebaseFirestore _firestore;

  static const String _usersCollection = 'users';
  static const String _friendshipsCollection = 'friendships';

  FriendService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Send friend request to another user
  Future<void> sendFriendRequest({
    required String fromUid,
    required String toUid,
  }) async {
    try {
      if (fromUid == toUid) {
        throw ArgumentError('Cannot send friend request to yourself');
      }

      final batch = _firestore.batch();

      // Add to sender's outgoing requests
      final fromDocRef = _firestore
          .collection(_friendshipsCollection)
          .doc(fromUid);
      batch.update(fromDocRef, {
        'friendRequests.outgoing': FieldValue.arrayUnion([toUid]),
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      // Add to receiver's incoming requests
      final toDocRef = _firestore
          .collection(_friendshipsCollection)
          .doc(toUid);
      batch.update(toDocRef, {
        'friendRequests.incoming': FieldValue.arrayUnion([fromUid]),
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      await batch.commit();

      debugPrint('Sent friend request from $fromUid to $toUid');
    } catch (e) {
      debugPrint('Error sending friend request: $e');
      rethrow;
    }
  }

  /// Accept friend request
  Future<void> acceptFriendRequest({
    required String userId,
    required String fromUid,
  }) async {
    try {
      final batch = _firestore.batch();

      // Add to user's friend list
      final userDocRef = _firestore
          .collection(_friendshipsCollection)
          .doc(userId);
      batch.update(userDocRef, {
        'friends': FieldValue.arrayUnion([fromUid]),
        'friendRequests.incoming': FieldValue.arrayRemove([fromUid]),
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      // Add to sender's friend list
      final senderDocRef = _firestore
          .collection(_friendshipsCollection)
          .doc(fromUid);
      batch.update(senderDocRef, {
        'friends': FieldValue.arrayUnion([userId]),
        'friendRequests.outgoing': FieldValue.arrayRemove([userId]),
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      await batch.commit();

      debugPrint('Accepted friend request: $userId accepted $fromUid');
    } catch (e) {
      debugPrint('Error accepting friend request: $e');
      rethrow;
    }
  }

  /// Reject friend request
  Future<void> rejectFriendRequest({
    required String userId,
    required String fromUid,
  }) async {
    try {
      final batch = _firestore.batch();

      // Remove from user's incoming requests
      final userDocRef = _firestore
          .collection(_friendshipsCollection)
          .doc(userId);
      batch.update(userDocRef, {
        'friendRequests.incoming': FieldValue.arrayRemove([fromUid]),
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      // Remove from sender's outgoing requests
      final senderDocRef = _firestore
          .collection(_friendshipsCollection)
          .doc(fromUid);
      batch.update(senderDocRef, {
        'friendRequests.outgoing': FieldValue.arrayRemove([userId]),
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      await batch.commit();

      debugPrint('Rejected friend request: $userId rejected $fromUid');
    } catch (e) {
      debugPrint('Error rejecting friend request: $e');
      rethrow;
    }
  }

  /// Remove a friend
  Future<void> removeFriend({
    required String userId,
    required String friendUid,
  }) async {
    try {
      final batch = _firestore.batch();

      // Remove from user's friend list
      final userDocRef = _firestore
          .collection(_friendshipsCollection)
          .doc(userId);
      batch.update(userDocRef, {
        'friends': FieldValue.arrayRemove([friendUid]),
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      // Remove from friend's friend list
      final friendDocRef = _firestore
          .collection(_friendshipsCollection)
          .doc(friendUid);
      batch.update(friendDocRef, {
        'friends': FieldValue.arrayRemove([userId]),
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      await batch.commit();

      debugPrint('Removed friend: $userId removed $friendUid');
    } catch (e) {
      debugPrint('Error removing friend: $e');
      rethrow;
    }
  }

  /// Block a user
  Future<void> blockUser({
    required String userId,
    required String blockedUid,
  }) async {
    try {
      final batch = _firestore.batch();

      // Add to blocked list and remove from friends if applicable
      final userDocRef = _firestore
          .collection(_friendshipsCollection)
          .doc(userId);
      batch.update(userDocRef, {
        'blockedUsers': FieldValue.arrayUnion([blockedUid]),
        'friends': FieldValue.arrayRemove([blockedUid]),
        'friendRequests.incoming': FieldValue.arrayRemove([blockedUid]),
        'friendRequests.outgoing': FieldValue.arrayRemove([blockedUid]),
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      await batch.commit();

      debugPrint('Blocked user: $userId blocked $blockedUid');
    } catch (e) {
      debugPrint('Error blocking user: $e');
      rethrow;
    }
  }

  /// Unblock a user
  Future<void> unblockUser({
    required String userId,
    required String blockedUid,
  }) async {
    try {
      final userDocRef = _firestore
          .collection(_friendshipsCollection)
          .doc(userId);
      await userDocRef.update({
        'blockedUsers': FieldValue.arrayRemove([blockedUid]),
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      debugPrint('Unblocked user: $userId unblocked $blockedUid');
    } catch (e) {
      debugPrint('Error unblocking user: $e');
      rethrow;
    }
  }

  /// Get user's friend list
  Future<List<String>> getFriendList(String userId) async {
    try {
      final doc = await _firestore
          .collection(_friendshipsCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        return [];
      }

      final data = doc.data()!;
      return List<String>.from(data['friends'] as List? ?? []);
    } catch (e) {
      debugPrint('Error fetching friend list for $userId: $e');
      return [];
    }
  }

  /// Get incoming friend requests
  Future<List<String>> getIncomingRequests(String userId) async {
    try {
      final doc = await _firestore
          .collection(_friendshipsCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        return [];
      }

      final data = doc.data()!;
      final requests = data['friendRequests'] as Map<String, dynamic>? ?? {};
      return List<String>.from(requests['incoming'] as List? ?? []);
    } catch (e) {
      debugPrint('Error fetching incoming requests for $userId: $e');
      return [];
    }
  }

  /// Get outgoing friend requests
  Future<List<String>> getOutgoingRequests(String userId) async {
    try {
      final doc = await _firestore
          .collection(_friendshipsCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        return [];
      }

      final data = doc.data()!;
      final requests = data['friendRequests'] as Map<String, dynamic>? ?? {};
      return List<String>.from(requests['outgoing'] as List? ?? []);
    } catch (e) {
      debugPrint('Error fetching outgoing requests for $userId: $e');
      return [];
    }
  }

  /// Get user's friendship data
  Future<Friendship?> getFriendship(String userId) async {
    try {
      final doc = await _firestore
          .collection(_friendshipsCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return Friendship.fromJson({...doc.data()!, 'userId': userId});
    } catch (e) {
      debugPrint('Error fetching friendship for $userId: $e');
      return null;
    }
  }

  /// Check if two users are friends
  Future<bool> areFriends({
    required String userId,
    required String otherUid,
  }) async {
    try {
      final friends = await getFriendList(userId);
      return friends.contains(otherUid);
    } catch (e) {
      debugPrint('Error checking friendship: $e');
      return false;
    }
  }

  /// Check if user is blocked
  Future<bool> isUserBlocked({
    required String userId,
    required String otherUid,
  }) async {
    try {
      final doc = await _firestore
          .collection(_friendshipsCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        return false;
      }

      final data = doc.data()!;
      final blockedUsers = List<String>.from(data['blockedUsers'] as List? ?? []);
      return blockedUsers.contains(otherUid);
    } catch (e) {
      debugPrint('Error checking if user is blocked: $e');
      return false;
    }
  }

  /// Initialize friendship document for new user
  Future<void> initializeFriendship(String userId) async {
    try {
      final doc = await _firestore
          .collection(_friendshipsCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        await _firestore
            .collection(_friendshipsCollection)
            .doc(userId)
            .set({
          'userId': userId,
          'friends': [],
          'friendRequests': {
            'incoming': [],
            'outgoing': [],
          },
          'blockedUsers': [],
          'lastUpdated': DateTime.now().toIso8601String(),
        });

        debugPrint('Initialized friendship for user $userId');
      }
    } catch (e) {
      debugPrint('Error initializing friendship for $userId: $e');
      rethrow;
    }
  }

  /// Stream user's friend list
  Stream<Friendship?> streamFriendship(String userId) {
    return _firestore
        .collection(_friendshipsCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      return Friendship.fromJson({...snapshot.data()!, 'userId': userId});
    }).handleError((e) {
      debugPrint('Error streaming friendship for $userId: $e');
    });
  }
}
