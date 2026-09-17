
/// Match room for private friend matches stored in matchRooms/{roomId}
class MatchRoom {
  const MatchRoom({
    required String id, // Room identifier
    required String creatorUid, // Who created room
    List<String> players, // UIDs of invited players (0-2 others)
    String status, // waiting, in_progress, finished
    required DateTime createdAt,
    DateTime? startedAt,
    DateTime? finishedAt,
    String? matchId, // Link to actual match once started
    Map<String, dynamic> settings, // isPrivate, inviteExpiry, maxPlayers
  });
}

/// Match invitation stored in invitations/{invitationId}
class Invitation {
  const Invitation({
    required String id,
    required String roomId,
    required String fromUid, // Who sent invite
    required String toUid, // Who received
    String status, // pending, accepted, declined, expired
    required DateTime createdAt,
    required DateTime expiresAt, // 24h from creation
    DateTime? respondedAt,
  });
}
