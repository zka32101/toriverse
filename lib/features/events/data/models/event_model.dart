import 'package:freezed_annotation/freezed_annotation.dart';



/// Event (campaign) stored in events/{eventId}
class Event {
  const factory Event({
    required String id,
    required String name,
    required String theme,
    String? description,
    String? imageUrl,
    required DateTime startDate,
    required DateTime endDate,
    @Default('active') String status, // upcoming, active, ended
    @Default(0) int maxRankPoints,
    @Default(1.0) double pointMultiplier,
    @Default(0) int totalRewardPool,
    @Default(0) int minRankToParticipate,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) =>
      _$EventFromJson(json);
}

/// Challenge within event stored in events/{eventId}/challenges/{challengeId}
class Challenge {
  const factory Challenge({
    required String id,
    required String eventId,
    required String name,
    String? description,
    @Default('win_matches')
    String type, // win_matches, score_points, play_with_friends, win_streak
    required int target,
    required ChallengeReward reward,
    required DateTime startDate,
    required DateTime endDate,
    @Default(false) bool isDaily,
    required DateTime createdAt,
  }) = _Challenge;

  factory Challenge.fromJson(Map<String, dynamic> json) =>
      _$ChallengeFromJson(json);
}

/// Challenge reward
class ChallengeReward {
  const factory ChallengeReward({
    @Default('bronze') String tier, // bronze, silver, gold
    required String cosmeticId,
    @Default(0) int rankPoints,
    String? description,
  }) = _ChallengeReward;

  factory ChallengeReward.fromJson(Map<String, dynamic> json) =>
      _$ChallengeRewardFromJson(json);
}

/// Event progress for user stored in users/{uid}/eventProgress/{eventId}
class EventProgress {
  const factory EventProgress({
    required String eventId,
    required String uid,
    @Default(0) int totalScore,
    @Default([]) List<String> completedChallenges,
    @Default([]) List<String> unlockedCosmetics,
    @Default(0) int currentRankPosition,
    required DateTime joinedAt,
    DateTime? lastUpdated,
  }) = _EventProgress;

  factory EventProgress.fromJson(Map<String, dynamic> json) =>
      _$EventProgressFromJson(json);
}
