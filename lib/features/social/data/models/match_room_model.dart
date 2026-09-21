
/// Match room for private friend matches stored in matchRooms/{roomId}
class MatchRoom {
  final String id; // Room identifier
  final String creatorUid; // Who created room
  final List<String> players; // UIDs of invited players (0-2 others)
  final String status; // waiting, in_progress, finished
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final String? matchId; // Link to actual match once started
  final Map<String, dynamic> settings; // isPrivate, inviteExpiry, maxPlayers

  const MatchRoom({
    required this.id,
    required this.creatorUid,
    this.players = const [],
    this.status = 'waiting',
    required this.createdAt,
    this.startedAt,
    this.finishedAt,
    this.matchId,
    this.settings = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'creatorUid': creatorUid,
    'players': players,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'startedAt': startedAt?.toIso8601String(),
    'finishedAt': finishedAt?.toIso8601String(),
    'matchId': matchId,
    'settings': settings,
  };

  factory MatchRoom.fromJson(Map<String, dynamic> json) => MatchRoom(
    id: json['id'] as String,
    creatorUid: json['creatorUid'] as String,
    players: json['players'] != null
        ? List<String>.from(json['players'] as List)
        : const [],
    status: json['status'] as String? ?? 'waiting',
    createdAt: DateTime.parse(json['createdAt'] as String),
    startedAt: json['startedAt'] != null
        ? DateTime.parse(json['startedAt'] as String)
        : null,
    finishedAt: json['finishedAt'] != null
        ? DateTime.parse(json['finishedAt'] as String)
        : null,
    matchId: json['matchId'] as String?,
    settings: json['settings'] != null
        ? Map<String, dynamic>.from(json['settings'] as Map)
        : const {},
  );
}

/// Match invitation stored in invitations/{invitationId}
class Invitation {
  final String id;
  final String roomId;
  final String fromUid; // Who sent invite
  final String toUid; // Who received
  final String status; // pending, accepted, declined, expired
  final DateTime createdAt;
  final DateTime expiresAt; // 24h from creation
  final DateTime? respondedAt;

  const Invitation({
    required this.id,
    required this.roomId,
    required this.fromUid,
    required this.toUid,
    this.status = 'pending',
    required this.createdAt,
    required this.expiresAt,
    this.respondedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'roomId': roomId,
    'fromUid': fromUid,
    'toUid': toUid,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'respondedAt': respondedAt?.toIso8601String(),
  };

  factory Invitation.fromJson(Map<String, dynamic> json) => Invitation(
    id: json['id'] as String,
    roomId: json['roomId'] as String,
    fromUid: json['fromUid'] as String,
    toUid: json['toUid'] as String,
    status: json['status'] as String? ?? 'pending',
    createdAt: DateTime.parse(json['createdAt'] as String),
    expiresAt: DateTime.parse(json['expiresAt'] as String),
    respondedAt: json['respondedAt'] != null
        ? DateTime.parse(json['respondedAt'] as String)
        : null,
  );
}
