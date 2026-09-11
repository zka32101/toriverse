import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/match_room_model.dart';

/// Service for managing match rooms and invitations
class MatchRoomService {
  final FirebaseFirestore _firestore;
  static const _inviteExpiryHours = 24;

  const MatchRoomService(this._firestore);

  /// Create a new match room
  Future<String> createMatchRoom({
    required String creatorUid,
    bool isPrivate = true,
    int maxPlayers = 3,
  }) async {
    try {
      if (creatorUid.isEmpty) {
        throw Exception('Invalid creator UID');
      }

      final roomDoc = await _firestore.collection('matchRooms').add({
        'creatorUid': creatorUid,
        'players': [creatorUid],
        'status': 'waiting',
        'createdAt': FieldValue.serverTimestamp(),
        'startedAt': null,
        'finishedAt': null,
        'matchId': null,
        'settings': {
          'isPrivate': isPrivate,
          'inviteExpiry': DateTime.now()
              .add(Duration(hours: _inviteExpiryHours))
              .toIso8601String(),
          'maxPlayers': maxPlayers,
        },
      });

      return roomDoc.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Invite a friend to a match room
  Future<String> inviteFriendToRoom({
    required String roomId,
    required String fromUid,
    required String toUid,
  }) async {
    try {
      // Validate
      if (fromUid == toUid) {
        throw Exception('Cannot invite yourself');
      }

      if (roomId.isEmpty || fromUid.isEmpty || toUid.isEmpty) {
        throw Exception('Invalid parameters');
      }

      // Verify room exists
      final roomDoc = await _firestore
          .collection('matchRooms')
          .doc(roomId)
          .get();

      if (!roomDoc.exists) {
        throw Exception('Match room not found');
      }

      final room = MatchRoom.fromJson(
        roomDoc.data() as Map<String, dynamic>,
      );

      // Check if room is not full
      if (room.players.length >= (room.settings['maxPlayers'] ?? 3)) {
        throw Exception('Match room is full');
      }

      // Check if already invited or in room
      if (room.players.contains(toUid)) {
        throw Exception('User is already in the room');
      }

      // Create invitation
      final expiryTime = DateTime.now().add(
        Duration(hours: _inviteExpiryHours),
      );

      final inviteDoc = await _firestore.collection('invitations').add({
        'roomId': roomId,
        'fromUid': fromUid,
        'toUid': toUid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiryTime),
        'respondedAt': null,
      });

      // Store in subcollections for easy querying
      final batch = _firestore.batch();

      batch.set(
        _firestore
            .collection('users')
            .doc(fromUid)
            .collection('sentInvitations')
            .doc(inviteDoc.id),
        {'invitationId': inviteDoc.id, 'createdAt': FieldValue.serverTimestamp()},
      );

      batch.set(
        _firestore
            .collection('users')
            .doc(toUid)
            .collection('receivedInvitations')
            .doc(inviteDoc.id),
        {'invitationId': inviteDoc.id, 'createdAt': FieldValue.serverTimestamp()},
      );

      await batch.commit();

      return inviteDoc.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Accept a match room invitation
  Future<void> acceptInvitation({
    required String invitationId,
    required String acceptingUid,
  }) async {
    try {
      final inviteDoc = await _firestore
          .collection('invitations')
          .doc(invitationId)
          .get();

      if (!inviteDoc.exists) {
        throw Exception('Invitation not found');
      }

      final invitation = Invitation.fromJson(
        inviteDoc.data() as Map<String, dynamic>,
      );

      // Validate
      if (invitation.toUid != acceptingUid) {
        throw Exception('Cannot accept invitation not sent to you');
      }

      if (invitation.status != 'pending') {
        throw Exception('Invitation is no longer pending');
      }

      if (invitation.expiresAt.isBefore(DateTime.now())) {
        throw Exception('Invitation has expired');
      }

      // Get the room
      final roomDoc = await _firestore
          .collection('matchRooms')
          .doc(invitation.roomId)
          .get();

      if (!roomDoc.exists) {
        throw Exception('Match room not found');
      }

      final room = MatchRoom.fromJson(
        roomDoc.data() as Map<String, dynamic>,
      );

      // Check room capacity
      if (room.players.length >= (room.settings['maxPlayers'] ?? 3)) {
        throw Exception('Room is now full');
      }

      // Update invitation status
      await inviteDoc.reference.update({
        'status': 'accepted',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      // Add player to room
      await roomDoc.reference.update({
        'players': FieldValue.arrayUnion([acceptingUid]),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Decline an invitation
  Future<void> declineInvitation({
    required String invitationId,
    required String decliningUid,
  }) async {
    try {
      final inviteDoc = await _firestore
          .collection('invitations')
          .doc(invitationId)
          .get();

      if (!inviteDoc.exists) {
        throw Exception('Invitation not found');
      }

      final invitation = Invitation.fromJson(
        inviteDoc.data() as Map<String, dynamic>,
      );

      if (invitation.toUid != decliningUid) {
        throw Exception('Cannot decline invitation not sent to you');
      }

      await inviteDoc.reference.update({
        'status': 'declined',
        'respondedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Get room status
  Future<MatchRoom?> getRoomStatus(String roomId) async {
    try {
      final doc = await _firestore
          .collection('matchRooms')
          .doc(roomId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return MatchRoom.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Get room status as a stream
  Stream<MatchRoom?> watchRoomStatus(String roomId) {
    return _firestore
        .collection('matchRooms')
        .doc(roomId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return MatchRoom.fromJson(snapshot.data() as Map<String, dynamic>);
    }).handleError((e) {
      return null;
    });
  }

  /// Start a match from a room
  Future<void> startMatchFromRoom({
    required String roomId,
    required String matchId,
  }) async {
    try {
      await _firestore.collection('matchRooms').doc(roomId).update({
        'status': 'in_progress',
        'startedAt': FieldValue.serverTimestamp(),
        'matchId': matchId,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Finish a match room
  Future<void> finishRoom(String roomId) async {
    try {
      await _firestore.collection('matchRooms').doc(roomId).update({
        'status': 'finished',
        'finishedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Cancel a room (creator only)
  Future<void> cancelRoom({
    required String roomId,
    required String creatorUid,
  }) async {
    try {
      final roomDoc = await _firestore
          .collection('matchRooms')
          .doc(roomId)
          .get();

      if (!roomDoc.exists) {
        throw Exception('Room not found');
      }

      final room = MatchRoom.fromJson(
        roomDoc.data() as Map<String, dynamic>,
      );

      if (room.creatorUid != creatorUid) {
        throw Exception('Only room creator can cancel');
      }

      // Delete the room and associated invitations
      final batch = _firestore.batch();
      batch.delete(roomDoc.reference);

      // Find and delete related invitations
      final invites = await _firestore
          .collection('invitations')
          .where('roomId', isEqualTo: roomId)
          .get();

      for (final invite in invites.docs) {
        batch.delete(invite.reference);
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Get user's active rooms
  Stream<List<MatchRoom>> getActiveRoomsStream(String uid) {
    return _firestore
        .collection('matchRooms')
        .where('players', arrayContains: uid)
        .where('status', isNotEqualTo: 'finished')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MatchRoom.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    }).handleError((e) {
      return [];
    });
  }

  /// Get user's invitations as a stream
  Stream<List<Invitation>> getInvitationsStream(String uid) {
    return _firestore
        .collection('invitations')
        .where('toUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Invitation.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    }).handleError((e) {
      return [];
    });
  }
}
