
/// Friend relationship stored in users/{uid}/friends/{friendUid}
class Friend {
  const Friend({
    required String uid, // Friend's UID
    required DateTime addedAt,
    DateTime? lastInteraction, // Last match/message together
    bool isFavorite, // Pinned friend
    String? notes, // User's personal notes
  });
}

/// Friend request stored in friendRequests/{requestId}
class FriendRequest {
  const FriendRequest({
    required String id,
    required String fromUid, // Requester
    required String toUid, // Recipient
    String status, // pending, accepted, declined, blocked
    required DateTime createdAt,
    DateTime? respondedAt, // When recipient acted
  });
}
