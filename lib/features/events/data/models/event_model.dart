
/// Event (campaign) stored in events/{eventId}
class Event {
  const Event({
    required String id,
    required String name,
    required String theme,
    String? description,
    String? imageUrl,
    required DateTime startDate,
    required DateTime endDate,
    String status, // upcoming, active, ended
    int maxRankPoints,
    double pointMultiplier,
    int totalRewardPool,
    int minRankToParticipate,
    required DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// Challenge within event stored in events/{eventId}/challenges/{challengeId}
class Challenge {
  const Challenge({
    required String id,
    required String eventId,
    required String name,
    String? description,
    
    String type, // win_matches, score_points, play_with_friends, win_streak
    required int target,
    required ChallengeReward reward,
    required DateTime startDate,
    required DateTime endDate,
    bool isDaily,
    required DateTime createdAt,
  });
}

/// Challenge reward
class ChallengeReward {
  const ChallengeReward({
    String tier, // bronze, silver, gold
    required String cosmeticId,
    int rankPoints,
    String? description,
  });
}

/// Event progress for user stored in users/{uid}/eventProgress/{eventId}
class EventProgress {
  const EventProgress({
    required String eventId,
    required String uid,
    int totalScore,
    List<String> completedChallenges,
    List<String> unlockedCosmetics,
    int currentRankPosition,
    required DateTime joinedAt,
    DateTime? lastUpdated,
  });
}
