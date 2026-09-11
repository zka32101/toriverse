/// Player profile domain models
///
/// Defines data structures for player profiles, stats, achievements, and badges.

import 'package:flutter/foundation.dart';

/// Complete player profile with stats and achievements
@immutable
class PlayerProfile {
  final String uid;
  final String username;
  final String? avatar;
  final String? bio;
  final DateTime joinedAt;

  // Stats
  final int totalMatches;
  final int totalWins;
  final int totalLosses;
  final double winRate;
  final int currentRank;
  final int currentRankPoints;
  final int matchStreak;
  final int bestStreak;

  // Social
  final int friendCount;
  final int blockedCount;

  // Settings
  final bool isPublic;
  final DateTime lastUpdated;

  const PlayerProfile({
    required this.uid,
    required this.username,
    this.avatar,
    this.bio,
    required this.joinedAt,
    required this.totalMatches,
    required this.totalWins,
    required this.totalLosses,
    required this.winRate,
    required this.currentRank,
    required this.currentRankPoints,
    required this.matchStreak,
    required this.bestStreak,
    required this.friendCount,
    required this.blockedCount,
    required this.isPublic,
    required this.lastUpdated,
  });

  /// Convert to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'avatar': avatar,
      'bio': bio,
      'joinedAt': joinedAt.toIso8601String(),
      'totalMatches': totalMatches,
      'totalWins': totalWins,
      'totalLosses': totalLosses,
      'winRate': winRate,
      'currentRank': currentRank,
      'currentRankPoints': currentRankPoints,
      'matchStreak': matchStreak,
      'bestStreak': bestStreak,
      'friendCount': friendCount,
      'blockedCount': blockedCount,
      'isPublic': isPublic,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Create from Firestore JSON
  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      uid: json['uid'] as String,
      username: json['username'] as String,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      totalMatches: json['totalMatches'] as int? ?? 0,
      totalWins: json['totalWins'] as int? ?? 0,
      totalLosses: json['totalLosses'] as int? ?? 0,
      winRate: (json['winRate'] as num?)?.toDouble() ?? 0.0,
      currentRank: json['currentRank'] as int? ?? 0,
      currentRankPoints: json['currentRankPoints'] as int? ?? 0,
      matchStreak: json['matchStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      friendCount: json['friendCount'] as int? ?? 0,
      blockedCount: json['blockedCount'] as int? ?? 0,
      isPublic: json['isPublic'] as bool? ?? true,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  PlayerProfile copyWith({
    String? uid,
    String? username,
    String? avatar,
    String? bio,
    DateTime? joinedAt,
    int? totalMatches,
    int? totalWins,
    int? totalLosses,
    double? winRate,
    int? currentRank,
    int? currentRankPoints,
    int? matchStreak,
    int? bestStreak,
    int? friendCount,
    int? blockedCount,
    bool? isPublic,
    DateTime? lastUpdated,
  }) {
    return PlayerProfile(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      joinedAt: joinedAt ?? this.joinedAt,
      totalMatches: totalMatches ?? this.totalMatches,
      totalWins: totalWins ?? this.totalWins,
      totalLosses: totalLosses ?? this.totalLosses,
      winRate: winRate ?? this.winRate,
      currentRank: currentRank ?? this.currentRank,
      currentRankPoints: currentRankPoints ?? this.currentRankPoints,
      matchStreak: matchStreak ?? this.matchStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      friendCount: friendCount ?? this.friendCount,
      blockedCount: blockedCount ?? this.blockedCount,
      isPublic: isPublic ?? this.isPublic,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Get match loss count
  int get matchesNotWon => totalMatches - totalWins;

  /// Check if account is new (< 7 days old)
  bool get isNewAccount =>
      DateTime.now().difference(joinedAt).inDays < 7;

  /// Get account age in days
  int get accountAgeDays =>
      DateTime.now().difference(joinedAt).inDays;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerProfile &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          currentRankPoints == other.currentRankPoints &&
          currentRank == other.currentRank;

  @override
  int get hashCode =>
      uid.hashCode ^ currentRankPoints.hashCode ^ currentRank.hashCode;
}

/// Player achievement/badge
@immutable
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final AchievementType type;
  final DateTime unlockedAt;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    required this.unlockedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'type': type.toString(),
      'unlockedAt': unlockedAt.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      type: _parseAchievementType(json['type'] as String?),
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
    );
  }
}

/// Achievement types
enum AchievementType {
  milestone, // Win 10/50/100 matches
  skill, // Reach rank thresholds
  social, // Add 5/10/25 friends
  special, // Limited time events
}

/// Achievement definitions
class AchievementDefinitions {
  static const List<Achievement> ALL = [
    Achievement(
      id: 'first_win',
      name: 'First Victory',
      description: 'Win your first match',
      icon: '🏆',
      type: AchievementType.milestone,
      unlockedAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    Achievement(
      id: 'ten_wins',
      name: 'Ten-Time Winner',
      description: 'Win 10 matches',
      icon: '🎖️',
      type: AchievementType.milestone,
      unlockedAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    Achievement(
      id: 'fifty_wins',
      name: 'Seasoned Player',
      description: 'Win 50 matches',
      icon: '⭐',
      type: AchievementType.milestone,
      unlockedAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    Achievement(
      id: 'rank_advanced',
      name: 'Advanced Strategist',
      description: 'Reach Advanced rank (500 points)',
      icon: '📈',
      type: AchievementType.skill,
      unlockedAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    Achievement(
      id: 'rank_expert',
      name: 'Expert Player',
      description: 'Reach Expert rank (1500 points)',
      icon: '🥇',
      type: AchievementType.skill,
      unlockedAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    Achievement(
      id: 'first_friend',
      name: 'Social Butterfly',
      description: 'Add your first friend',
      icon: '👥',
      type: AchievementType.social,
      unlockedAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
  ];

  static Achievement? getAchievementById(String id) {
    try {
      return ALL.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Badge/cosmetic reward
@immutable
class Badge {
  final String id;
  final String name;
  final String description;
  final BadgeRarity rarity;
  final DateTime earnedAt;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.earnedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'rarity': rarity.toString(),
      'earnedAt': earnedAt.toIso8601String(),
    };
  }

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      rarity: _parseBadgeRarity(json['rarity'] as String?),
      earnedAt: DateTime.parse(json['earnedAt'] as String),
    );
  }
}

/// Badge rarity levels
enum BadgeRarity {
  common,
  uncommon,
  rare,
  legendary,
}

/// Player profile settings
@immutable
class ProfileSettings {
  final bool isPublic;
  final bool showMatchHistory;
  final bool showFriendsList;
  final bool allowFriendRequests;
  final bool allowMessages;

  const ProfileSettings({
    this.isPublic = true,
    this.showMatchHistory = true,
    this.showFriendsList = true,
    this.allowFriendRequests = true,
    this.allowMessages = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'isPublic': isPublic,
      'showMatchHistory': showMatchHistory,
      'showFriendsList': showFriendsList,
      'allowFriendRequests': allowFriendRequests,
      'allowMessages': allowMessages,
    };
  }

  factory ProfileSettings.fromJson(Map<String, dynamic> json) {
    return ProfileSettings(
      isPublic: json['isPublic'] as bool? ?? true,
      showMatchHistory: json['showMatchHistory'] as bool? ?? true,
      showFriendsList: json['showFriendsList'] as bool? ?? true,
      allowFriendRequests: json['allowFriendRequests'] as bool? ?? true,
      allowMessages: json['allowMessages'] as bool? ?? true,
    );
  }

  ProfileSettings copyWith({
    bool? isPublic,
    bool? showMatchHistory,
    bool? showFriendsList,
    bool? allowFriendRequests,
    bool? allowMessages,
  }) {
    return ProfileSettings(
      isPublic: isPublic ?? this.isPublic,
      showMatchHistory: showMatchHistory ?? this.showMatchHistory,
      showFriendsList: showFriendsList ?? this.showFriendsList,
      allowFriendRequests: allowFriendRequests ?? this.allowFriendRequests,
      allowMessages: allowMessages ?? this.allowMessages,
    );
  }
}

// Helper functions
AchievementType _parseAchievementType(String? typeStr) {
  if (typeStr == null) return AchievementType.milestone;
  return AchievementType.values.firstWhere(
    (type) => type.toString() == typeStr,
    orElse: () => AchievementType.milestone,
  );
}

BadgeRarity _parseBadgeRarity(String? rarityStr) {
  if (rarityStr == null) return BadgeRarity.common;
  return BadgeRarity.values.firstWhere(
    (rarity) => rarity.toString() == rarityStr,
    orElse: () => BadgeRarity.common,
  );
}
