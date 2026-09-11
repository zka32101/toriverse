/// Friend system domain models
///
/// Defines data structures for friend relationships, friend requests,
/// presence tracking, and friend profiles.

import 'package:flutter/foundation.dart';

/// A friend relationship between two users
@immutable
class Friendship {
  final String userId;
  final List<String> friends; // UIDs of current friends
  final FriendRequests friendRequests;
  final List<String> blockedUsers;
  final DateTime lastUpdated;

  const Friendship({
    required this.userId,
    required this.friends,
    required this.friendRequests,
    required this.blockedUsers,
    required this.lastUpdated,
  });

  /// Convert to Firestore JSON format
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'friends': friends,
      'friendRequests': friendRequests.toJson(),
      'blockedUsers': blockedUsers,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Create from Firestore JSON
  factory Friendship.fromJson(Map<String, dynamic> json) {
    return Friendship(
      userId: json['userId'] as String,
      friends: List<String>.from(json['friends'] as List? ?? []),
      friendRequests: FriendRequests.fromJson(
        json['friendRequests'] as Map<String, dynamic>? ?? {},
      ),
      blockedUsers: List<String>.from(json['blockedUsers'] as List? ?? []),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  Friendship copyWith({
    String? userId,
    List<String>? friends,
    FriendRequests? friendRequests,
    List<String>? blockedUsers,
    DateTime? lastUpdated,
  }) {
    return Friendship(
      userId: userId ?? this.userId,
      friends: friends ?? this.friends,
      friendRequests: friendRequests ?? this.friendRequests,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Friendship &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          friends.length == other.friends.length &&
          blockedUsers.length == other.blockedUsers.length;

  @override
  int get hashCode =>
      userId.hashCode ^ friends.length.hashCode ^ blockedUsers.length.hashCode;
}

/// Friend request tracking
@immutable
class FriendRequests {
  final List<String> incoming; // UIDs from whom we received requests
  final List<String> outgoing; // UIDs to whom we sent requests

  const FriendRequests({
    required this.incoming,
    required this.outgoing,
  });

  Map<String, dynamic> toJson() {
    return {
      'incoming': incoming,
      'outgoing': outgoing,
    };
  }

  factory FriendRequests.fromJson(Map<String, dynamic> json) {
    return FriendRequests(
      incoming: List<String>.from(json['incoming'] as List? ?? []),
      outgoing: List<String>.from(json['outgoing'] as List? ?? []),
    );
  }

  FriendRequests copyWith({
    List<String>? incoming,
    List<String>? outgoing,
  }) {
    return FriendRequests(
      incoming: incoming ?? this.incoming,
      outgoing: outgoing ?? this.outgoing,
    );
  }
}

/// Friend profile (cached from leaderboard)
@immutable
class FriendProfile {
  final String uid;
  final String username;
  final String? avatar;
  final int currentRank;
  final int currentRankPoints;
  final int matchStreak;
  final bool isOnline;
  final DateTime lastSeenAt;

  const FriendProfile({
    required this.uid,
    required this.username,
    this.avatar,
    required this.currentRank,
    required this.currentRankPoints,
    required this.matchStreak,
    required this.isOnline,
    required this.lastSeenAt,
  });

  /// Convert to Firestore JSON format
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'avatar': avatar,
      'currentRank': currentRank,
      'currentRankPoints': currentRankPoints,
      'matchStreak': matchStreak,
      'isOnline': isOnline,
      'lastSeenAt': lastSeenAt.toIso8601String(),
    };
  }

  /// Create from Firestore JSON
  factory FriendProfile.fromJson(Map<String, dynamic> json) {
    return FriendProfile(
      uid: json['uid'] as String,
      username: json['username'] as String,
      avatar: json['avatar'] as String?,
      currentRank: json['currentRank'] as int? ?? 0,
      currentRankPoints: json['currentRankPoints'] as int? ?? 0,
      matchStreak: json['matchStreak'] as int? ?? 0,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.parse(json['lastSeenAt'] as String)
          : DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  FriendProfile copyWith({
    String? uid,
    String? username,
    String? avatar,
    int? currentRank,
    int? currentRankPoints,
    int? matchStreak,
    bool? isOnline,
    DateTime? lastSeenAt,
  }) {
    return FriendProfile(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      currentRank: currentRank ?? this.currentRank,
      currentRankPoints: currentRankPoints ?? this.currentRankPoints,
      matchStreak: matchStreak ?? this.matchStreak,
      isOnline: isOnline ?? this.isOnline,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendProfile &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          isOnline == other.isOnline;

  @override
  int get hashCode => uid.hashCode ^ isOnline.hashCode;
}

/// Friend request status
enum FriendRequestStatus {
  pending,
  accepted,
  rejected,
  cancelled,
}

/// Friend relationship status
@immutable
class FriendStatus {
  final String friendUid;
  final bool isFriend;
  final bool hasIncomingRequest;
  final bool hasOutgoingRequest;
  final bool isBlocked;

  const FriendStatus({
    required this.friendUid,
    required this.isFriend,
    required this.hasIncomingRequest,
    required this.hasOutgoingRequest,
    required this.isBlocked,
  });

  /// Check if relationship is blocked
  bool get isBlacklisted => isBlocked;

  /// Check if waiting for response
  bool get isPending => hasOutgoingRequest || hasIncomingRequest;
}

/// Friend activity event
@immutable
class FriendActivity {
  final String friendUid;
  final String friendUsername;
  final FriendActivityType type;
  final DateTime timestamp;
  final String? matchId;
  final String? metadata;

  const FriendActivity({
    required this.friendUid,
    required this.friendUsername,
    required this.type,
    required this.timestamp,
    this.matchId,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'friendUid': friendUid,
      'friendUsername': friendUsername,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'matchId': matchId,
      'metadata': metadata,
    };
  }
}

/// Types of friend activities
enum FriendActivityType {
  matchCompleted,
  rankChanged,
  streakMilestone,
  cosmeticPurchased,
  friendAdded,
  online,
  offline,
}
