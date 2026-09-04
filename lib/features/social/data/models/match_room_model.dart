import 'package:freezed_annotation/freezed_annotation.dart';

part 'match_room_model.freezed.dart';
part 'match_room_model.g.dart';

/// Match room for private friend matches stored in matchRooms/{roomId}
@freezed
class MatchRoom with _$MatchRoom {
  const factory MatchRoom({
    required String id, // Room identifier
    required String creatorUid, // Who created room
    @Default([]) List<String> players, // UIDs of invited players (0-2 others)
    @Default('waiting') String status, // waiting, in_progress, finished
    required DateTime createdAt,
    DateTime? startedAt,
    DateTime? finishedAt,
    String? matchId, // Link to actual match once started
    @Default({}) Map<String, dynamic> settings, // isPrivate, inviteExpiry, maxPlayers
  }) = _MatchRoom;

  factory MatchRoom.fromJson(Map<String, dynamic> json) =>
      _$MatchRoomFromJson(json);
}

/// Match invitation stored in invitations/{invitationId}
@freezed
class Invitation with _$Invitation {
  const factory Invitation({
    required String id,
    required String roomId,
    required String fromUid, // Who sent invite
    required String toUid, // Who received
    @Default('pending') String status, // pending, accepted, declined, expired
    required DateTime createdAt,
    required DateTime expiresAt, // 24h from creation
    DateTime? respondedAt,
  }) = _Invitation;

  factory Invitation.fromJson(Map<String, dynamic> json) =>
      _$InvitationFromJson(json);
}
