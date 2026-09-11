import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_relationship_models.freezed.dart';
part 'social_relationship_models.g.dart';

// ============================================================================
// SOCIAL - RELATIONSHIPS (3 Models)
// ============================================================================

enum RelationshipType { friend, follower, blocked, muted }

enum FriendRequestStatus { pending, accepted, declined }

@freezed
class UserRelationship with _$UserRelationship {
  const factory UserRelationship({
    required String id,
    required String userId,
    required String relatedUserId,
    required RelationshipType type,
    FriendRequestStatus? friendRequestStatus,
    required DateTime followedAt,
    DateTime? acceptedAt,
  }) = _UserRelationship;

  factory UserRelationship.fromJson(Map<String, dynamic> json) =>
      _$UserRelationshipFromJson(json);
}

enum FriendStatus { pending, accepted, rejected }

@freezed
class Friend with _$Friend {
  const factory Friend({
    required String id,
    required String userId,
    required String friendId,
    required FriendStatus status,
    required DateTime requestedAt,
    DateTime? acceptedAt,
    @Default(false) bool isFavorite,
  }) = _Friend;

  factory Friend.fromJson(Map<String, dynamic> json) =>
      _$FriendFromJson(json);
}

@freezed
class Follower with _$Follower {
  const factory Follower({
    required String id,
    required String userId, // content creator
    required String followerId, // the follower
    required DateTime followedAt,
    required bool isNotificationEnabled,
  }) = _Follower;

  factory Follower.fromJson(Map<String, dynamic> json) =>
      _$FollowerFromJson(json);
}
