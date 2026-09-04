import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../match/data/models/user_model.dart';
import '../../data/models/friend_model.dart';

/// Service for managing friend relationships and requests
class FriendService {
  final FirebaseFirestore _firestore;

  const FriendService(this._firestore);

  /// Send a friend request from one user to another
  Future<void> sendFriendRequest({
    required String fromUid,
    required String toUid,
  }) async {
    try {
      // Validate inputs
      if (fromUid == toUid) {
        throw Exception('Cannot send friend request to yourself');
      }

      if (fromUid.isEmpty || toUid.isEmpty) {
        throw Exception('Invalid user IDs');
      }

      // Check if request already exists
      final existing = await _firestore
          .collection('friendRequests')
          .where('fromUid', isEqualTo: fromUid)
          .where('toUid', isEqualTo: toUid)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('Friend request already pending');
      }

      // Check if already friends
      final alreadyFriends = await _firestore
          .collection('users')
          .doc(fromUid)
          .collection('friends')
          .doc(toUid)
          .get();

      if (alreadyFriends.exists) {
        throw Exception('Already friends with this user');
      }

      // Create the request
      await _firestore.collection('friendRequests').add({
        'fromUid': fromUid,
        'toUid': toUid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'respondedAt': null,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Accept a friend request
  Future<void> acceptFriendRequest({
    required String requestId,
    required String acceptingUid,
  }) async {
    try {
      final batch = _firestore.batch();

      // Get the request
      final requestDoc = await _firestore
          .collection('friendRequests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        throw Exception('Friend request not found');
      }

      final request = FriendRequest.fromJson(
        requestDoc.data() as Map<String, dynamic>,
      );

      // Validate
      if (request.toUid != acceptingUid) {
        throw Exception('Cannot accept request not sent to you');
      }

      if (request.status != 'pending') {
        throw Exception('Request is no longer pending');
      }

      // Update request status
      batch.update(requestDoc.reference, {
        'status': 'accepted',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      // Add friend to both sides
      batch.set(
        _firestore
            .collection('users')
            .doc(request.fromUid)
            .collection('friends')
            .doc(request.toUid),
        {
          'uid': request.toUid,
          'addedAt': FieldValue.serverTimestamp(),
          'lastInteraction': null,
          'isFavorite': false,
          'notes': null,
        },
      );

      batch.set(
        _firestore
            .collection('users')
            .doc(request.toUid)
            .collection('friends')
            .doc(request.fromUid),
        {
          'uid': request.fromUid,
          'addedAt': FieldValue.serverTimestamp(),
          'lastInteraction': null,
          'isFavorite': false,
          'notes': null,
        },
      );

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Decline a friend request
  Future<void> declineFriendRequest({
    required String requestId,
    required String decliningUid,
  }) async {
    try {
      final requestDoc = await _firestore
          .collection('friendRequests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        throw Exception('Friend request not found');
      }

      final request = FriendRequest.fromJson(
        requestDoc.data() as Map<String, dynamic>,
      );

      if (request.toUid != decliningUid) {
        throw Exception('Cannot decline request not sent to you');
      }

      await requestDoc.reference.update({
        'status': 'declined',
        'respondedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Remove a friend
  Future<void> removeFriend({
    required String uid,
    required String friendUid,
  }) async {
    try {
      final batch = _firestore.batch();

      // Remove from both sides
      batch.delete(
        _firestore
            .collection('users')
            .doc(uid)
            .collection('friends')
            .doc(friendUid),
      );

      batch.delete(
        _firestore
            .collection('users')
            .doc(friendUid)
            .collection('friends')
            .doc(uid),
      );

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Block a user
  Future<void> blockUser({
    required String uid,
    required String blockedUid,
  }) async {
    try {
      if (uid == blockedUid) {
        throw Exception('Cannot block yourself');
      }

      final batch = _firestore.batch();

      // Remove friendship if exists
      batch.delete(
        _firestore
            .collection('users')
            .doc(uid)
            .collection('friends')
            .doc(blockedUid),
      );

      batch.delete(
        _firestore
            .collection('users')
            .doc(blockedUid)
            .collection('friends')
            .doc(uid),
      );

      // Create block record
      batch.set(
        _firestore
            .collection('users')
            .doc(uid)
            .collection('blockedUsers')
            .doc(blockedUid),
        {
          'blockedUid': blockedUid,
          'blockedAt': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Get user's friends list as a stream
  Stream<List<Friend>> getFriendsListStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('friends')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => Friend.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    }).handleError((e) {
      // Silent degradation - return empty list on error
      return [];
    });
  }

  /// Get pending friend requests as a stream
  Stream<List<FriendRequest>> getPendingRequestsStream(String uid) {
    return _firestore
        .collection('friendRequests')
        .where('toUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => FriendRequest.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    }).handleError((e) {
      return [];
    });
  }

  /// Get friend status by UID
  Future<bool> isFriend({
    required String uid,
    required String potentialFriendUid,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('friends')
          .doc(potentialFriendUid)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get friend count
  Future<int> getFriendCount(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('friends')
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Update friend notes
  Future<void> updateFriendNotes({
    required String uid,
    required String friendUid,
    required String notes,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('friends')
          .doc(friendUid)
          .update({'notes': notes});
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle favorite friend
  Future<void> toggleFavoriteFriend({
    required String uid,
    required String friendUid,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('friends')
          .doc(friendUid)
          .get();

      if (!doc.exists) {
        throw Exception('Friend not found');
      }

      final friend = Friend.fromJson(doc.data() as Map<String, dynamic>);

      await doc.reference.update({
        'isFavorite': !friend.isFavorite,
      });
    } catch (e) {
      rethrow;
    }
  }
}
