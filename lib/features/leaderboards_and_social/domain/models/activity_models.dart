import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_models.freezed.dart';
part 'activity_models.g.dart';

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
