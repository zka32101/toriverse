/// Leaderboard domain models for ranking and statistics
///
/// Defines data structures for player rankings, leaderboard entries,
/// and time-based rank tracking.

import 'package:flutter/foundation.dart';

/// A player's entry in the global leaderboard
@immutable
class PlayerLeaderboardEntry {
  final String uid;
  final String username;
  final int rankPoints;
  final int completedMatchStreak;
  final int totalMatches;
  final int totalWins;
  final int totalLosses;
  final double winRate; // 0.0-1.0
  final DateTime lastUpdated;
  final int rank; // Current rank position (1-indexed)

  const PlayerLeaderboardEntry({
    required this.uid,
    required this.username,
    required this.rankPoints,
    required this.completedMatchStreak,
    required this.totalMatches,
    required this.totalWins,
    required this.totalLosses,
    required this.winRate,
    required this.lastUpdated,
    required this.rank,
  });

  /// Convert to Firestore JSON format
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'rankPoints': rankPoints,
      'completedMatchStreak': completedMatchStreak,
      'totalMatches': totalMatches,
      'totalWins': totalWins,
      'totalLosses': totalLosses,
      'winRate': winRate,
      'lastUpdated': lastUpdated.toIso8601String(),
      'rank': rank,
    };
  }

  /// Create from Firestore JSON
  factory PlayerLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return PlayerLeaderboardEntry(
      uid: json['uid'] as String,
      username: json['username'] as String,
      rankPoints: json['rankPoints'] as int? ?? 0,
      completedMatchStreak: json['completedMatchStreak'] as int? ?? 0,
      totalMatches: json['totalMatches'] as int? ?? 0,
      totalWins: json['totalWins'] as int? ?? 0,
      totalLosses: json['totalLosses'] as int? ?? 0,
      winRate: (json['winRate'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
      rank: json['rank'] as int? ?? 0,
    );
  }

  /// Create a copy with updated fields
  PlayerLeaderboardEntry copyWith({
    String? uid,
    String? username,
    int? rankPoints,
    int? completedMatchStreak,
    int? totalMatches,
    int? totalWins,
    int? totalLosses,
    double? winRate,
    DateTime? lastUpdated,
    int? rank,
  }) {
    return PlayerLeaderboardEntry(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      rankPoints: rankPoints ?? this.rankPoints,
      completedMatchStreak: completedMatchStreak ?? this.completedMatchStreak,
      totalMatches: totalMatches ?? this.totalMatches,
      totalWins: totalWins ?? this.totalWins,
      totalLosses: totalLosses ?? this.totalLosses,
      winRate: winRate ?? this.winRate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rank: rank ?? this.rank,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerLeaderboardEntry &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          rankPoints == other.rankPoints &&
          rank == other.rank;

  @override
  int get hashCode => uid.hashCode ^ rankPoints.hashCode ^ rank.hashCode;
}

/// Time-period specific leaderboard entry
@immutable
class TimePeriodLeaderboardEntry {
  final String uid;
  final String username;
  final int rankPoints; // Points during this period only
  final int rank; // Rank during this period
  final DateTime periodStart;
  final DateTime periodEnd;

  const TimePeriodLeaderboardEntry({
    required this.uid,
    required this.username,
    required this.rankPoints,
    required this.rank,
    required this.periodStart,
    required this.periodEnd,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'rankPoints': rankPoints,
      'rank': rank,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
    };
  }

  factory TimePeriodLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return TimePeriodLeaderboardEntry(
      uid: json['uid'] as String,
      username: json['username'] as String,
      rankPoints: json['rankPoints'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
    );
  }
}

/// Aggregated leaderboard for a specific time period
@immutable
class Leaderboard {
  final List<PlayerLeaderboardEntry> entries;
  final String period; // 'all-time', 'daily', 'weekly', 'monthly'
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime fetchedAt;

  const Leaderboard({
    required this.entries,
    required this.period,
    this.startDate,
    this.endDate,
    required this.fetchedAt,
  });

  /// Get top N entries
  List<PlayerLeaderboardEntry> getTop(int limit) {
    return entries.take(limit).toList();
  }

  /// Get player's rank and position
  PlayerLeaderboardEntry? getPlayerEntry(String uid) {
    try {
      return entries.firstWhere((entry) => entry.uid == uid);
    } catch (e) {
      return null;
    }
  }

  /// Get players near a specific rank
  List<PlayerLeaderboardEntry> getPlayersNear(int rank, {int radius = 5}) {
    final start = (rank - radius - 1).clamp(0, entries.length - 1);
    final end = (rank + radius).clamp(0, entries.length);
    return entries.sublist(start, end);
  }

  /// Check if leaderboard is stale (older than specified duration)
  bool isStale(Duration maxAge) {
    return DateTime.now().difference(fetchedAt) > maxAge;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Leaderboard &&
          runtimeType == other.runtimeType &&
          period == other.period &&
          entries.length == other.entries.length;

  @override
  int get hashCode => period.hashCode ^ entries.length.hashCode;
}

/// Rank update event for streaming/watching
@immutable
class RankChangeEvent {
  final String uid;
  final int previousRank;
  final int newRank;
  final int pointsChanged;
  final DateTime timestamp;
  final String reason; // 'match_win', 'match_loss', 'decay', etc.

  const RankChangeEvent({
    required this.uid,
    required this.previousRank,
    required this.newRank,
    required this.pointsChanged,
    required this.timestamp,
    required this.reason,
  });
}

/// Rank points configuration (adjustable via Remote Config)
@immutable
class RankPointsConfig {
  final int winPoints1st; // 1st place in 3-player
  final int winPoints2nd;
  final int winPoints3rd;
  final int winPointsFriendChallenge;
  final int lossPointsFriendChallenge;
  final int aiMatchPoints; // AI matches don't affect ranking
  final int casualMatchPoints; // Casual mode doesn't affect ranking
  final int streakBonusPerWin; // Bonus per consecutive win

  const RankPointsConfig({
    this.winPoints1st = 30,
    this.winPoints2nd = 10,
    this.winPoints3rd = -5,
    this.winPointsFriendChallenge = 20,
    this.lossPointsFriendChallenge = -10,
    this.aiMatchPoints = 0,
    this.casualMatchPoints = 0,
    this.streakBonusPerWin = 5,
  });

  /// Create from Remote Config (Firebase)
  factory RankPointsConfig.fromRemoteConfig(Map<String, dynamic> config) {
    return RankPointsConfig(
      winPoints1st: (config['rank_points_1st_place'] as num?)?.toInt() ?? 30,
      winPoints2nd: (config['rank_points_2nd_place'] as num?)?.toInt() ?? 10,
      winPoints3rd: (config['rank_points_3rd_place'] as num?)?.toInt() ?? -5,
      winPointsFriendChallenge:
          (config['rank_points_friend_win'] as num?)?.toInt() ?? 20,
      lossPointsFriendChallenge:
          (config['rank_points_friend_loss'] as num?)?.toInt() ?? -10,
      aiMatchPoints: (config['rank_points_ai_match'] as num?)?.toInt() ?? 0,
      casualMatchPoints:
          (config['rank_points_casual_match'] as num?)?.toInt() ?? 0,
      streakBonusPerWin:
          (config['rank_streak_bonus_per_win'] as num?)?.toInt() ?? 5,
    );
  }
}
