import 'package:freezed_annotation/freezed_annotation.dart';

part 'leaderboards_and_social.freezed.dart';
part 'leaderboards_and_social.g.dart';

// ============================================================================
// LEADERBOARDS (4 Models)
// ============================================================================

enum RankTier { bronze, silver, gold, platinum, diamond, legendary }

@freezed
class GlobalRanking with _$GlobalRanking {
  const factory GlobalRanking({
    required String id,
    required String userId,
    required int rank,
    required double rating,
    required int wins,
    required int losses,
    required double winRate,
    required int totalMatches,
    required int streakCurrent,
    required int streakBest,
    required RankTier tier,
    required DateTime lastUpdatedAt,
  }) = _GlobalRanking;

  factory GlobalRanking.fromJson(Map<String, dynamic> json) =>
      _$GlobalRankingFromJson(json);
}

@freezed
class SeasonalRanking with _$SeasonalRanking {
  const factory SeasonalRanking({
    required String id,
    required String userId,
    required String seasonId,
    required int rank,
    required double rating,
    required int seasonWins,
    required int seasonLosses,
    required int promotedFrom,
    required int demotedTo,
    required RankTier tier,
    required DateTime seasonStartDate,
    required DateTime lastUpdatedAt,
  }) = _SeasonalRanking;

  factory SeasonalRanking.fromJson(Map<String, dynamic> json) =>
      _$SeasonalRankingFromJson(json);
}

enum CreatorTier { standard, verified, featured, elite }

@freezed
class CreatorRanking with _$CreatorRanking {
  const factory CreatorRanking({
    required String id,
    required String creatorId,
    required int rank,
    required double totalEarnings,
    required int followerCount,
    required double viralScore,
    required String topClipId,
    required double averageClipEarnings,
    required CreatorTier creatorTier,
    required int totalClipsMonetized,
    required DateTime lastUpdatedAt,
  }) = _CreatorRanking;

  factory CreatorRanking.fromJson(Map<String, dynamic> json) =>
      _$CreatorRankingFromJson(json);
}

@freezed
class ClanRanking with _$ClanRanking {
  const factory ClanRanking({
    required String id,
    required String clanId,
    required int rank,
    required int totalMatches,
    required double clanRating,
    required int memberCount,
    required int winStreak,
    required int tournamentWins,
    required double totalEarnings,
    required DateTime lastUpdatedAt,
  }) = _ClanRanking;

  factory ClanRanking.fromJson(Map<String, dynamic> json) =>
      _$ClanRankingFromJson(json);
}

// ============================================================================
// SOCIAL - USER PROFILE (1 Model)
// ============================================================================

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String userId,
    required String displayName,
    required String bio,
    required String avatarUrl,
    required bool creatorBadge,
    required bool isVerified,
    required bool isMuted,
    required bool isBlocked,
    required String preferredColorScheme,
    required int totalMatches,
    required int totalWins,
    required int totalClipsCreated,
    required DateTime joinedAt,
    required DateTime lastUpdatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

// ============================================================================
// SOCIAL - RELATIONSHIPS (4 Models)
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
    required FriendRequestStatus? friendRequestStatus,
    required DateTime followedAt,
    required DateTime? acceptedAt,
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
    required DateTime? acceptedAt,
    required bool isFavorite,
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

// ============================================================================
// SOCIAL - MESSAGING (1 Model)
// ============================================================================

@freezed
class UserMessage with _$UserMessage {
  const factory UserMessage({
    required String messageId,
    required String senderId,
    required String recipientId,
    required String content,
    required DateTime sentAt,
    required DateTime? readAt,
    required bool isStarred,
    required String? replyToMessageId,
  }) = _UserMessage;

  factory UserMessage.fromJson(Map<String, dynamic> json) =>
      _$UserMessageFromJson(json);
}

// ============================================================================
// COMMUNITY - CLANS (2 Models)
// ============================================================================

enum JoinPolicy { open, approval, closed }

@freezed
class Clan with _$Clan {
  const factory Clan({
    required String clanId,
    required String clanName,
    required String description,
    required String founderUserId,
    required DateTime createdAt,
    required int memberCount,
    required int totalMatches,
    required int totalWins,
    required double clanRating,
    required String tagColor,
    required String bannerUrl,
    required bool isRecruiting,
    required JoinPolicy joinPolicy,
  }) = _Clan;

  factory Clan.fromJson(Map<String, dynamic> json) => _$ClanFromJson(json);
}

enum ClanMemberRole { founder, officer, member }

@freezed
class ClanMembership with _$ClanMembership {
  const factory ClanMembership({
    required String memberId,
    required String clanId,
    required String userId,
    required DateTime joinedAt,
    required ClanMemberRole role,
    required bool isOwner,
    required bool isOfficer,
    required int contributionScore,
  }) = _ClanMembership;

  factory ClanMembership.fromJson(Map<String, dynamic> json) =>
      _$ClanMembershipFromJson(json);
}

// ============================================================================
// COMMUNITY - ACTIVITY & STATUS (2 Models)
// ============================================================================

enum ActivityType {
  matchWon,
  tierUp,
  tierDown,
  clipViral,
  friendAdded,
  clanJoined,
  clanPromoted,
  achievementUnlocked,
  streakMilestone,
}

@freezed
class ActivityFeed with _$ActivityFeed {
  const factory ActivityFeed({
    required String feedId,
    required String userId,
    required ActivityType activityType,
    required String? relatedUserId,
    required String? matchId,
    required String? clipId,
    required String? clanId,
    required Map<String, dynamic>? metadata,
    required DateTime createdAt,
  }) = _ActivityFeed;

  factory ActivityFeed.fromJson(Map<String, dynamic> json) =>
      _$ActivityFeedFromJson(json);
}

enum OnlineStatusType { online, offline, idle, inMatch }

@freezed
class OnlineStatus with _$OnlineStatus {
  const factory OnlineStatus({
    required String userId,
    required OnlineStatusType status,
    required DateTime lastSeenAt,
    required String? currentMatchId,
    required bool isBusyStatus,
  }) = _OnlineStatus;

  factory OnlineStatus.fromJson(Map<String, dynamic> json) =>
      _$OnlineStatusFromJson(json);
}

// ============================================================================
// COMMUNITY - LFG (LOOKING FOR GROUP) (1 Model)
// ============================================================================

enum SkillLevel { beginner, intermediate, advanced }

enum LFGFillStatus { open, closed }

@freezed
class LFGPost with _$LFGPost {
  const factory LFGPost({
    required String postId,
    required String creatorId,
    required String title,
    required String description,
    required SkillLevel skillLevel,
    required String matchType,
    required List<String> preferredPlatforms,
    required DateTime createdAt,
    required LFGFillStatus fillStatus,
    required List<String> applicantIds,
    required int maxParticipants,
  }) = _LFGPost;

  factory LFGPost.fromJson(Map<String, dynamic> json) =>
      _$LFGPostFromJson(json);
}

// ============================================================================
// COMMUNITY - BLOCKING & MUTING (1 Model)
// ============================================================================

@freezed
class UserBlock with _$UserBlock {
  const factory UserBlock({
    required String blockId,
    required String userId,
    required String blockedUserId,
    required String reason,
    required DateTime blockedAt,
  }) = _UserBlock;

  factory UserBlock.fromJson(Map<String, dynamic> json) =>
      _$UserBlockFromJson(json);
}

@freezed
class UserMute with _$UserMute {
  const factory UserMute({
    required String muteId,
    required String userId,
    required String mutedUserId,
    required DateTime mutedAt,
  }) = _UserMute;

  factory UserMute.fromJson(Map<String, dynamic> json) =>
      _$UserMuteFromJson(json);
}
