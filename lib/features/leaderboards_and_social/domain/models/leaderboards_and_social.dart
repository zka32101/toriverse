/// Leaderboards & Social domain models
///
/// Covers global/seasonal/creator/clan rankings, user social profiles,
/// friend/follower relationships, messaging, clans, activity feed,
/// online presence, and looking-for-group (LFG) posts.

import 'package:flutter/foundation.dart';

// ============================================================================
// LEADERBOARD MODELS
// ============================================================================

/// Competitive rank tier
enum RankTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
  master,
  grandmaster,
}

/// Content creator tier
enum CreatorTier {
  rising,
  established,
  featured,
  elite,
}

/// A player's position on the global ranked leaderboard
@immutable
class GlobalRanking {
  final String id;
  final String userId;
  final int rank;
  final int rating;
  final int wins;
  final int losses;
  final double winRate;
  final int totalMatches;
  final int streakCurrent;
  final int streakBest;
  final RankTier tier;
  final DateTime lastUpdatedAt;

  const GlobalRanking({
    required this.id,
    required this.userId,
    required this.rank,
    required this.rating,
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.totalMatches,
    required this.streakCurrent,
    required this.streakBest,
    required this.tier,
    required this.lastUpdatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'rank': rank,
      'rating': rating,
      'wins': wins,
      'losses': losses,
      'winRate': winRate,
      'totalMatches': totalMatches,
      'streakCurrent': streakCurrent,
      'streakBest': streakBest,
      'tier': tier.name,
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    };
  }

  factory GlobalRanking.fromJson(Map<String, dynamic> json) {
    return GlobalRanking(
      id: json['id'] as String,
      userId: json['userId'] as String,
      rank: json['rank'] as int,
      rating: json['rating'] as int,
      wins: json['wins'] as int,
      losses: json['losses'] as int,
      winRate: (json['winRate'] as num).toDouble(),
      totalMatches: json['totalMatches'] as int,
      streakCurrent: json['streakCurrent'] as int,
      streakBest: json['streakBest'] as int,
      tier: RankTier.values.byName(json['tier'] as String),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
    );
  }
}

/// A player's position on a time-boxed seasonal leaderboard
@immutable
class SeasonalRanking {
  final String id;
  final String userId;
  final String seasonId;
  final int rank;
  final int rating;
  final int seasonWins;
  final int seasonLosses;
  final int promotedFrom;
  final int demotedTo;
  final RankTier tier;
  final DateTime seasonStartDate;
  final DateTime lastUpdatedAt;

  const SeasonalRanking({
    required this.id,
    required this.userId,
    required this.seasonId,
    required this.rank,
    required this.rating,
    required this.seasonWins,
    required this.seasonLosses,
    required this.promotedFrom,
    required this.demotedTo,
    required this.tier,
    required this.seasonStartDate,
    required this.lastUpdatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'seasonId': seasonId,
      'rank': rank,
      'rating': rating,
      'seasonWins': seasonWins,
      'seasonLosses': seasonLosses,
      'promotedFrom': promotedFrom,
      'demotedTo': demotedTo,
      'tier': tier.name,
      'seasonStartDate': seasonStartDate.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    };
  }

  factory SeasonalRanking.fromJson(Map<String, dynamic> json) {
    return SeasonalRanking(
      id: json['id'] as String,
      userId: json['userId'] as String,
      seasonId: json['seasonId'] as String,
      rank: json['rank'] as int,
      rating: json['rating'] as int,
      seasonWins: json['seasonWins'] as int,
      seasonLosses: json['seasonLosses'] as int,
      promotedFrom: json['promotedFrom'] as int,
      demotedTo: json['demotedTo'] as int,
      tier: RankTier.values.byName(json['tier'] as String),
      seasonStartDate: DateTime.parse(json['seasonStartDate'] as String),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
    );
  }
}

/// A content creator's position on the creator earnings/virality leaderboard
@immutable
class CreatorRanking {
  final String id;
  final String creatorId;
  final int rank;
  final int totalEarnings;
  final int followerCount;
  final double viralScore;
  final String topClipId;
  final int averageClipEarnings;
  final CreatorTier creatorTier;
  final int totalClipsMonetized;
  final DateTime lastUpdatedAt;

  const CreatorRanking({
    required this.id,
    required this.creatorId,
    required this.rank,
    required this.totalEarnings,
    required this.followerCount,
    required this.viralScore,
    required this.topClipId,
    required this.averageClipEarnings,
    required this.creatorTier,
    required this.totalClipsMonetized,
    required this.lastUpdatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'rank': rank,
      'totalEarnings': totalEarnings,
      'followerCount': followerCount,
      'viralScore': viralScore,
      'topClipId': topClipId,
      'averageClipEarnings': averageClipEarnings,
      'creatorTier': creatorTier.name,
      'totalClipsMonetized': totalClipsMonetized,
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    };
  }

  factory CreatorRanking.fromJson(Map<String, dynamic> json) {
    return CreatorRanking(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      rank: json['rank'] as int,
      totalEarnings: json['totalEarnings'] as int,
      followerCount: json['followerCount'] as int,
      viralScore: (json['viralScore'] as num).toDouble(),
      topClipId: json['topClipId'] as String,
      averageClipEarnings: json['averageClipEarnings'] as int,
      creatorTier: CreatorTier.values.byName(json['creatorTier'] as String),
      totalClipsMonetized: json['totalClipsMonetized'] as int,
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
    );
  }
}

/// A clan's position on the clan leaderboard
@immutable
class ClanRanking {
  final String id;
  final String clanId;
  final int rank;
  final int totalMatches;
  final int clanRating;
  final int memberCount;
  final int winStreak;
  final int tournamentWins;
  final int totalEarnings;
  final DateTime lastUpdatedAt;

  const ClanRanking({
    required this.id,
    required this.clanId,
    required this.rank,
    required this.totalMatches,
    required this.clanRating,
    required this.memberCount,
    required this.winStreak,
    required this.tournamentWins,
    required this.totalEarnings,
    required this.lastUpdatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clanId': clanId,
      'rank': rank,
      'totalMatches': totalMatches,
      'clanRating': clanRating,
      'memberCount': memberCount,
      'winStreak': winStreak,
      'tournamentWins': tournamentWins,
      'totalEarnings': totalEarnings,
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    };
  }

  factory ClanRanking.fromJson(Map<String, dynamic> json) {
    return ClanRanking(
      id: json['id'] as String,
      clanId: json['clanId'] as String,
      rank: json['rank'] as int,
      totalMatches: json['totalMatches'] as int,
      clanRating: json['clanRating'] as int,
      memberCount: json['memberCount'] as int,
      winStreak: json['winStreak'] as int,
      tournamentWins: json['tournamentWins'] as int,
      totalEarnings: json['totalEarnings'] as int,
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
    );
  }
}

// ============================================================================
// SOCIAL MODELS
// ============================================================================

/// Friend relationship status
enum FriendStatus {
  pending,
  accepted,
  declined,
  blocked,
}

/// A user's public social profile
@immutable
class UserProfile {
  final String userId;
  final String displayName;
  final String bio;
  final String avatarUrl;
  final bool creatorBadge;
  final bool isVerified;
  final bool isMuted;
  final bool isBlocked;
  final String preferredColorScheme;
  final int totalMatches;
  final int totalWins;
  final int totalClipsCreated;
  final DateTime joinedAt;
  final DateTime lastUpdatedAt;

  const UserProfile({
    required this.userId,
    required this.displayName,
    required this.bio,
    required this.avatarUrl,
    required this.creatorBadge,
    required this.isVerified,
    required this.isMuted,
    required this.isBlocked,
    required this.preferredColorScheme,
    required this.totalMatches,
    required this.totalWins,
    required this.totalClipsCreated,
    required this.joinedAt,
    required this.lastUpdatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'creatorBadge': creatorBadge,
      'isVerified': isVerified,
      'isMuted': isMuted,
      'isBlocked': isBlocked,
      'preferredColorScheme': preferredColorScheme,
      'totalMatches': totalMatches,
      'totalWins': totalWins,
      'totalClipsCreated': totalClipsCreated,
      'joinedAt': joinedAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      bio: json['bio'] as String,
      avatarUrl: json['avatarUrl'] as String,
      creatorBadge: json['creatorBadge'] as bool,
      isVerified: json['isVerified'] as bool,
      isMuted: json['isMuted'] as bool,
      isBlocked: json['isBlocked'] as bool,
      preferredColorScheme: json['preferredColorScheme'] as String,
      totalMatches: json['totalMatches'] as int,
      totalWins: json['totalWins'] as int,
      totalClipsCreated: json['totalClipsCreated'] as int,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
    );
  }
}

/// A friend relationship between two users
@immutable
class Friend {
  final String id;
  final String userId;
  final String friendId;
  final FriendStatus status;
  final DateTime requestedAt;
  final DateTime? acceptedAt;
  final bool isFavorite;

  const Friend({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.status,
    required this.requestedAt,
    this.acceptedAt,
    required this.isFavorite,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'friendId': friendId,
      'status': status.name,
      'requestedAt': requestedAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as String,
      userId: json['userId'] as String,
      friendId: json['friendId'] as String,
      status: FriendStatus.values.byName(json['status'] as String),
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'] as String)
          : null,
      isFavorite: json['isFavorite'] as bool,
    );
  }

  Friend copyWith({
    String? id,
    String? userId,
    String? friendId,
    FriendStatus? status,
    DateTime? requestedAt,
    DateTime? acceptedAt,
    bool? isFavorite,
  }) {
    return Friend(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      friendId: friendId ?? this.friendId,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// A follower relationship (one-directional, e.g. for creators)
@immutable
class Follower {
  final String id;
  final String userId;
  final String followerId;
  final DateTime followedAt;
  final bool isNotificationEnabled;

  const Follower({
    required this.id,
    required this.userId,
    required this.followerId,
    required this.followedAt,
    required this.isNotificationEnabled,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'followerId': followerId,
      'followedAt': followedAt.toIso8601String(),
      'isNotificationEnabled': isNotificationEnabled,
    };
  }

  factory Follower.fromJson(Map<String, dynamic> json) {
    return Follower(
      id: json['id'] as String,
      userId: json['userId'] as String,
      followerId: json['followerId'] as String,
      followedAt: DateTime.parse(json['followedAt'] as String),
      isNotificationEnabled: json['isNotificationEnabled'] as bool,
    );
  }

  Follower copyWith({
    String? id,
    String? userId,
    String? followerId,
    DateTime? followedAt,
    bool? isNotificationEnabled,
  }) {
    return Follower(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      followerId: followerId ?? this.followerId,
      followedAt: followedAt ?? this.followedAt,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
    );
  }
}

/// A direct message between two users
@immutable
class UserMessage {
  final String messageId;
  final String senderId;
  final String recipientId;
  final String content;
  final DateTime sentAt;
  final DateTime? readAt;
  final bool isStarred;
  final String? replyToMessageId;

  const UserMessage({
    required this.messageId,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.sentAt,
    this.readAt,
    required this.isStarred,
    this.replyToMessageId,
  });

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'recipientId': recipientId,
      'content': content,
      'sentAt': sentAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'isStarred': isStarred,
      'replyToMessageId': replyToMessageId,
    };
  }

  factory UserMessage.fromJson(Map<String, dynamic> json) {
    return UserMessage(
      messageId: json['messageId'] as String,
      senderId: json['senderId'] as String,
      recipientId: json['recipientId'] as String,
      content: json['content'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      isStarred: json['isStarred'] as bool,
      replyToMessageId: json['replyToMessageId'] as String?,
    );
  }

  UserMessage copyWith({
    String? messageId,
    String? senderId,
    String? recipientId,
    String? content,
    DateTime? sentAt,
    DateTime? readAt,
    bool? isStarred,
    String? replyToMessageId,
  }) {
    return UserMessage(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      content: content ?? this.content,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
      isStarred: isStarred ?? this.isStarred,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
    );
  }
}

// ============================================================================
// COMMUNITY MODELS
// ============================================================================

/// Clan join policy
enum JoinPolicy {
  open,
  approval,
  inviteOnly,
}

/// Clan member role
enum ClanMemberRole {
  member,
  officer,
  founder,
}

/// Activity feed entry type
enum ActivityType {
  matchWon,
  matchLost,
  tierUp,
  tierDown,
  friendAdded,
  clipViral,
  achievement,
}

/// Online presence status
enum OnlineStatusType {
  offline,
  online,
  away,
  inMatch,
}

/// LFG (looking for group) skill level
enum SkillLevel {
  beginner,
  intermediate,
  advanced,
}

/// LFG post fill status
enum LFGFillStatus {
  open,
  closed,
  full,
}

/// A player clan/guild
@immutable
class Clan {
  final String clanId;
  final String clanName;
  final String description;
  final String founderUserId;
  final DateTime createdAt;
  final int memberCount;
  final int totalMatches;
  final int totalWins;
  final int clanRating;
  final String tagColor;
  final String bannerUrl;
  final bool isRecruiting;
  final JoinPolicy joinPolicy;

  const Clan({
    required this.clanId,
    required this.clanName,
    required this.description,
    required this.founderUserId,
    required this.createdAt,
    required this.memberCount,
    required this.totalMatches,
    required this.totalWins,
    required this.clanRating,
    required this.tagColor,
    required this.bannerUrl,
    required this.isRecruiting,
    required this.joinPolicy,
  });

  Map<String, dynamic> toJson() {
    return {
      'clanId': clanId,
      'clanName': clanName,
      'description': description,
      'founderUserId': founderUserId,
      'createdAt': createdAt.toIso8601String(),
      'memberCount': memberCount,
      'totalMatches': totalMatches,
      'totalWins': totalWins,
      'clanRating': clanRating,
      'tagColor': tagColor,
      'bannerUrl': bannerUrl,
      'isRecruiting': isRecruiting,
      'joinPolicy': joinPolicy.name,
    };
  }

  factory Clan.fromJson(Map<String, dynamic> json) {
    return Clan(
      clanId: json['clanId'] as String,
      clanName: json['clanName'] as String,
      description: json['description'] as String,
      founderUserId: json['founderUserId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      memberCount: json['memberCount'] as int,
      totalMatches: json['totalMatches'] as int,
      totalWins: json['totalWins'] as int,
      clanRating: json['clanRating'] as int,
      tagColor: json['tagColor'] as String,
      bannerUrl: json['bannerUrl'] as String,
      isRecruiting: json['isRecruiting'] as bool,
      joinPolicy: JoinPolicy.values.byName(json['joinPolicy'] as String),
    );
  }

  Clan copyWith({
    String? clanId,
    String? clanName,
    String? description,
    String? founderUserId,
    DateTime? createdAt,
    int? memberCount,
    int? totalMatches,
    int? totalWins,
    int? clanRating,
    String? tagColor,
    String? bannerUrl,
    bool? isRecruiting,
    JoinPolicy? joinPolicy,
  }) {
    return Clan(
      clanId: clanId ?? this.clanId,
      clanName: clanName ?? this.clanName,
      description: description ?? this.description,
      founderUserId: founderUserId ?? this.founderUserId,
      createdAt: createdAt ?? this.createdAt,
      memberCount: memberCount ?? this.memberCount,
      totalMatches: totalMatches ?? this.totalMatches,
      totalWins: totalWins ?? this.totalWins,
      clanRating: clanRating ?? this.clanRating,
      tagColor: tagColor ?? this.tagColor,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      isRecruiting: isRecruiting ?? this.isRecruiting,
      joinPolicy: joinPolicy ?? this.joinPolicy,
    );
  }
}

/// A user's membership within a clan
@immutable
class ClanMembership {
  final String memberId;
  final String clanId;
  final String userId;
  final DateTime joinedAt;
  final ClanMemberRole role;
  final bool isOwner;
  final bool isOfficer;
  final int contributionScore;

  const ClanMembership({
    required this.memberId,
    required this.clanId,
    required this.userId,
    required this.joinedAt,
    required this.role,
    required this.isOwner,
    required this.isOfficer,
    required this.contributionScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'clanId': clanId,
      'userId': userId,
      'joinedAt': joinedAt.toIso8601String(),
      'role': role.name,
      'isOwner': isOwner,
      'isOfficer': isOfficer,
      'contributionScore': contributionScore,
    };
  }

  factory ClanMembership.fromJson(Map<String, dynamic> json) {
    return ClanMembership(
      memberId: json['memberId'] as String,
      clanId: json['clanId'] as String,
      userId: json['userId'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      role: ClanMemberRole.values.byName(json['role'] as String),
      isOwner: json['isOwner'] as bool,
      isOfficer: json['isOfficer'] as bool,
      contributionScore: json['contributionScore'] as int,
    );
  }

  ClanMembership copyWith({
    String? memberId,
    String? clanId,
    String? userId,
    DateTime? joinedAt,
    ClanMemberRole? role,
    bool? isOwner,
    bool? isOfficer,
    int? contributionScore,
  }) {
    return ClanMembership(
      memberId: memberId ?? this.memberId,
      clanId: clanId ?? this.clanId,
      userId: userId ?? this.userId,
      joinedAt: joinedAt ?? this.joinedAt,
      role: role ?? this.role,
      isOwner: isOwner ?? this.isOwner,
      isOfficer: isOfficer ?? this.isOfficer,
      contributionScore: contributionScore ?? this.contributionScore,
    );
  }
}

/// A single entry in a user's activity feed/timeline
@immutable
class ActivityFeed {
  final String feedId;
  final String userId;
  final ActivityType activityType;
  final String? relatedUserId;
  final String? matchId;
  final String? clipId;
  final String? clanId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const ActivityFeed({
    required this.feedId,
    required this.userId,
    required this.activityType,
    this.relatedUserId,
    this.matchId,
    this.clipId,
    this.clanId,
    this.metadata,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'feedId': feedId,
      'userId': userId,
      'activityType': activityType.name,
      'relatedUserId': relatedUserId,
      'matchId': matchId,
      'clipId': clipId,
      'clanId': clanId,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ActivityFeed.fromJson(Map<String, dynamic> json) {
    return ActivityFeed(
      feedId: json['feedId'] as String,
      userId: json['userId'] as String,
      activityType: ActivityType.values.byName(json['activityType'] as String),
      relatedUserId: json['relatedUserId'] as String?,
      matchId: json['matchId'] as String?,
      clipId: json['clipId'] as String?,
      clanId: json['clanId'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// A user's live online/presence status
@immutable
class OnlineStatus {
  final String userId;
  final OnlineStatusType status;
  final DateTime lastSeenAt;
  final String? currentMatchId;
  final bool isBusyStatus;

  const OnlineStatus({
    required this.userId,
    required this.status,
    required this.lastSeenAt,
    this.currentMatchId,
    required this.isBusyStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'status': status.name,
      'lastSeenAt': lastSeenAt.toIso8601String(),
      'currentMatchId': currentMatchId,
      'isBusyStatus': isBusyStatus,
    };
  }

  factory OnlineStatus.fromJson(Map<String, dynamic> json) {
    return OnlineStatus(
      userId: json['userId'] as String,
      status: OnlineStatusType.values.byName(json['status'] as String),
      lastSeenAt: DateTime.parse(json['lastSeenAt'] as String),
      currentMatchId: json['currentMatchId'] as String?,
      isBusyStatus: json['isBusyStatus'] as bool,
    );
  }

  OnlineStatus copyWith({
    String? userId,
    OnlineStatusType? status,
    DateTime? lastSeenAt,
    String? currentMatchId,
    bool? isBusyStatus,
  }) {
    return OnlineStatus(
      userId: userId ?? this.userId,
      status: status ?? this.status,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      currentMatchId: currentMatchId ?? this.currentMatchId,
      isBusyStatus: isBusyStatus ?? this.isBusyStatus,
    );
  }
}

/// A "looking for group" post for finding match partners
@immutable
class LFGPost {
  final String postId;
  final String creatorId;
  final String title;
  final String description;
  final SkillLevel skillLevel;
  final String matchType;
  final List<String> preferredPlatforms;
  final DateTime createdAt;
  final LFGFillStatus fillStatus;
  final List<String> applicantIds;
  final int maxParticipants;

  const LFGPost({
    required this.postId,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.skillLevel,
    required this.matchType,
    required this.preferredPlatforms,
    required this.createdAt,
    required this.fillStatus,
    required this.applicantIds,
    required this.maxParticipants,
  });

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'creatorId': creatorId,
      'title': title,
      'description': description,
      'skillLevel': skillLevel.name,
      'matchType': matchType,
      'preferredPlatforms': preferredPlatforms,
      'createdAt': createdAt.toIso8601String(),
      'fillStatus': fillStatus.name,
      'applicantIds': applicantIds,
      'maxParticipants': maxParticipants,
    };
  }

  factory LFGPost.fromJson(Map<String, dynamic> json) {
    return LFGPost(
      postId: json['postId'] as String,
      creatorId: json['creatorId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      skillLevel: SkillLevel.values.byName(json['skillLevel'] as String),
      matchType: json['matchType'] as String,
      preferredPlatforms:
          List<String>.from(json['preferredPlatforms'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      fillStatus: LFGFillStatus.values.byName(json['fillStatus'] as String),
      applicantIds: List<String>.from(json['applicantIds'] as List),
      maxParticipants: json['maxParticipants'] as int,
    );
  }

  LFGPost copyWith({
    String? postId,
    String? creatorId,
    String? title,
    String? description,
    SkillLevel? skillLevel,
    String? matchType,
    List<String>? preferredPlatforms,
    DateTime? createdAt,
    LFGFillStatus? fillStatus,
    List<String>? applicantIds,
    int? maxParticipants,
  }) {
    return LFGPost(
      postId: postId ?? this.postId,
      creatorId: creatorId ?? this.creatorId,
      title: title ?? this.title,
      description: description ?? this.description,
      skillLevel: skillLevel ?? this.skillLevel,
      matchType: matchType ?? this.matchType,
      preferredPlatforms: preferredPlatforms ?? this.preferredPlatforms,
      createdAt: createdAt ?? this.createdAt,
      fillStatus: fillStatus ?? this.fillStatus,
      applicantIds: applicantIds ?? this.applicantIds,
      maxParticipants: maxParticipants ?? this.maxParticipants,
    );
  }
}

/// A record of one user blocking another
@immutable
class UserBlock {
  final String blockId;
  final String userId;
  final String blockedUserId;
  final String reason;
  final DateTime blockedAt;

  const UserBlock({
    required this.blockId,
    required this.userId,
    required this.blockedUserId,
    required this.reason,
    required this.blockedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'blockId': blockId,
      'userId': userId,
      'blockedUserId': blockedUserId,
      'reason': reason,
      'blockedAt': blockedAt.toIso8601String(),
    };
  }

  factory UserBlock.fromJson(Map<String, dynamic> json) {
    return UserBlock(
      blockId: json['blockId'] as String,
      userId: json['userId'] as String,
      blockedUserId: json['blockedUserId'] as String,
      reason: json['reason'] as String,
      blockedAt: DateTime.parse(json['blockedAt'] as String),
    );
  }
}

/// A record of one user muting another
@immutable
class UserMute {
  final String muteId;
  final String userId;
  final String mutedUserId;
  final DateTime mutedAt;

  const UserMute({
    required this.muteId,
    required this.userId,
    required this.mutedUserId,
    required this.mutedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'muteId': muteId,
      'userId': userId,
      'mutedUserId': mutedUserId,
      'mutedAt': mutedAt.toIso8601String(),
    };
  }

  factory UserMute.fromJson(Map<String, dynamic> json) {
    return UserMute(
      muteId: json['muteId'] as String,
      userId: json['userId'] as String,
      mutedUserId: json['mutedUserId'] as String,
      mutedAt: DateTime.parse(json['mutedAt'] as String),
    );
  }
}
