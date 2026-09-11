import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_model.freezed.dart';
part 'friend_model.g.dart';

/// Friend relationship stored in users/{uid}/friends/{friendUid}
@freezed
class Friend with _$Friend {
  const factory Friend({
    required String uid, // Friend's UID
    required DateTime addedAt,
    DateTime? lastInteraction, // Last match/message together
    @Default(false) bool isFavorite, // Pinned friend
    String? notes, // User's personal notes
  }) = _Friend;

  factory Friend.fromJson(Map<String, dynamic> json) =>
      _$FriendFromJson(json);
}

/// Friend request stored in friendRequests/{requestId}
@freezed
class FriendRequest with _$FriendRequest {
  const factory FriendRequest({
    required String id,
    required String fromUid, // Requester
    required String toUid, // Recipient
    @Default('pending') String status, // pending, accepted, declined, blocked
    required DateTime createdAt,
    DateTime? respondedAt, // When recipient acted
  }) = _FriendRequest;

  factory FriendRequest.fromJson(Map<String, dynamic> json) =>
      _$FriendRequestFromJson(json);
}
