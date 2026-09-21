
/// Event (campaign) stored in events/{eventId}
class Event {
  final String id;
  final String name;
  final String theme;
  final String? description;
  final String? imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // upcoming, active, ended
  final int maxRankPoints;
  final double pointMultiplier;
  final int totalRewardPool;
  final int minRankToParticipate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Event({
    required this.id,
    required this.name,
    required this.theme,
    this.description,
    this.imageUrl,
    required this.startDate,
    required this.endDate,
    this.status = 'upcoming',
    this.maxRankPoints = 0,
    this.pointMultiplier = 1.0,
    this.totalRewardPool = 0,
    this.minRankToParticipate = 0,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'theme': theme,
        'description': description,
        'imageUrl': imageUrl,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'status': status,
        'maxRankPoints': maxRankPoints,
        'pointMultiplier': pointMultiplier,
        'totalRewardPool': totalRewardPool,
        'minRankToParticipate': minRankToParticipate,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      name: json['name'] as String,
      theme: json['theme'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String? ?? 'upcoming',
      maxRankPoints: json['maxRankPoints'] as int? ?? 0,
      pointMultiplier: (json['pointMultiplier'] as num?)?.toDouble() ?? 1.0,
      totalRewardPool: json['totalRewardPool'] as int? ?? 0,
      minRankToParticipate: json['minRankToParticipate'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }
}

/// Challenge within event stored in events/{eventId}/challenges/{challengeId}
class Challenge {
  final String id;
  final String eventId;
  final String name;
  final String? description;
  final String type; // win_matches, score_points, play_with_friends, win_streak
  final int target;
  final ChallengeReward reward;
  final DateTime startDate;
  final DateTime endDate;
  final bool isDaily;
  final DateTime createdAt;

  const Challenge({
    required this.id,
    required this.eventId,
    required this.name,
    this.description,
    this.type = 'win_matches',
    required this.target,
    required this.reward,
    required this.startDate,
    required this.endDate,
    this.isDaily = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventId': eventId,
        'name': name,
        'description': description,
        'type': type,
        'target': target,
        'reward': reward.toJson(),
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'isDaily': isDaily,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'win_matches',
      target: json['target'] as int,
      reward: ChallengeReward.fromJson(json['reward'] as Map<String, dynamic>),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isDaily: json['isDaily'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Challenge reward
class ChallengeReward {
  final String tier; // bronze, silver, gold
  final String cosmeticId;
  final int rankPoints;
  final String? description;

  const ChallengeReward({
    this.tier = 'bronze',
    required this.cosmeticId,
    this.rankPoints = 0,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'tier': tier,
        'cosmeticId': cosmeticId,
        'rankPoints': rankPoints,
        'description': description,
      };

  factory ChallengeReward.fromJson(Map<String, dynamic> json) {
    return ChallengeReward(
      tier: json['tier'] as String? ?? 'bronze',
      cosmeticId: json['cosmeticId'] as String,
      rankPoints: json['rankPoints'] as int? ?? 0,
      description: json['description'] as String?,
    );
  }
}

/// Event progress for user stored in users/{uid}/eventProgress/{eventId}
class EventProgress {
  final String eventId;
  final String uid;
  final int totalScore;
  final List<String> completedChallenges;
  final List<String> unlockedCosmetics;
  final int currentRankPosition;
  final DateTime joinedAt;
  final DateTime? lastUpdated;

  const EventProgress({
    required this.eventId,
    required this.uid,
    this.totalScore = 0,
    this.completedChallenges = const [],
    this.unlockedCosmetics = const [],
    this.currentRankPosition = 0,
    required this.joinedAt,
    this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'uid': uid,
        'totalScore': totalScore,
        'completedChallenges': completedChallenges,
        'unlockedCosmetics': unlockedCosmetics,
        'currentRankPosition': currentRankPosition,
        'joinedAt': joinedAt.toIso8601String(),
        'lastUpdated': lastUpdated?.toIso8601String(),
      };

  factory EventProgress.fromJson(Map<String, dynamic> json) {
    return EventProgress(
      eventId: json['eventId'] as String,
      uid: json['uid'] as String,
      totalScore: json['totalScore'] as int? ?? 0,
      completedChallenges: json['completedChallenges'] != null
          ? List<String>.from(json['completedChallenges'] as List)
          : const [],
      unlockedCosmetics: json['unlockedCosmetics'] != null
          ? List<String>.from(json['unlockedCosmetics'] as List)
          : const [],
      currentRankPosition: json['currentRankPosition'] as int? ?? 0,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated'] as String) : null,
    );
  }
}
