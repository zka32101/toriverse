
/// Friend relationship stored in users/{uid}/friends/{friendUid}
class Friend {
  final String uid; // Friend's UID
  final DateTime addedAt;
  final DateTime? lastInteraction; // Last match/message together
  final bool isFavorite; // Pinned friend
  final String? notes; // User's personal notes

  const Friend({
    required this.uid,
    required this.addedAt,
    this.lastInteraction,
    this.isFavorite = false,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'addedAt': addedAt.toIso8601String(),
    'lastInteraction': lastInteraction?.toIso8601String(),
    'isFavorite': isFavorite,
    'notes': notes,
  };

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
    uid: json['uid'] as String,
    addedAt: DateTime.parse(json['addedAt'] as String),
    lastInteraction: json['lastInteraction'] != null
        ? DateTime.parse(json['lastInteraction'] as String)
        : null,
    isFavorite: json['isFavorite'] as bool? ?? false,
    notes: json['notes'] as String?,
  );
}

/// Friend request stored in friendRequests/{requestId}
class FriendRequest {
  final String id;
  final String fromUid; // Requester
  final String toUid; // Recipient
  final String status; // pending, accepted, declined, blocked
  final DateTime createdAt;
  final DateTime? respondedAt; // When recipient acted

  const FriendRequest({
    required this.id,
    required this.fromUid,
    required this.toUid,
    this.status = 'pending',
    required this.createdAt,
    this.respondedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromUid': fromUid,
    'toUid': toUid,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'respondedAt': respondedAt?.toIso8601String(),
  };

  factory FriendRequest.fromJson(Map<String, dynamic> json) => FriendRequest(
    id: json['id'] as String,
    fromUid: json['fromUid'] as String,
    toUid: json['toUid'] as String,
    status: json['status'] as String? ?? 'pending',
    createdAt: DateTime.parse(json['createdAt'] as String),
    respondedAt: json['respondedAt'] != null
        ? DateTime.parse(json['respondedAt'] as String)
        : null,
  );
}
