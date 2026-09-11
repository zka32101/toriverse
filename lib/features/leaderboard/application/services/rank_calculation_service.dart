/// Rank calculation service for determining rank point changes
///
/// Calculates rank point awards/deductions based on match outcomes,
/// opponent skill levels, and other factors.

import 'package:flutter/foundation.dart';
import '../../../leaderboard/domain/models/leaderboard_models.dart';

class RankCalculationService {
  final RankPointsConfig config;

  RankCalculationService({required this.config});

  /// Calculate rank points for a match result
  ///
  /// Returns points for each player based on placement
  /// [placements]: List of player UIDs in order of finish (1st, 2nd, 3rd)
  Map<String, int> calculateMatchPoints({
    required List<String> placements, // [1st_uid, 2nd_uid, 3rd_uid]
    required String matchType, // 'ranked', 'casual', 'friendChallenge'
  }) {
    if (placements.length != 3) {
      debugPrint('Error: Expected 3 players, got ${placements.length}');
      return {};
    }

    final points = <String, int>{};

    // Determine if this match affects ranking
    final affectsRanking = matchType == 'ranked' || matchType == 'friendChallenge';

    if (!affectsRanking) {
      // Casual matches don't award points
      return {
        for (final uid in placements) uid: 0,
      };
    }

    // Award points based on placement
    points[placements[0]] = config.winPoints1st; // 1st place
    points[placements[1]] = config.winPoints2nd; // 2nd place
    points[placements[2]] = config.winPoints3rd; // 3rd place

    debugPrint(
      'Calculated match points: 1st=${points[placements[0]]} '
      '2nd=${points[placements[1]]} 3rd=${points[placements[2]]}',
    );

    return points;
  }

  /// Calculate points for a friend challenge
  Map<String, int> calculateFriendChallengePoints({
    required String winnerUid,
    required String loserUid,
  }) {
    return {
      winnerUid: config.winPointsFriendChallenge,
      loserUid: config.lossPointsFriendChallenge,
    };
  }

  /// Calculate win rate
  static double calculateWinRate({
    required int wins,
    required int totalMatches,
  }) {
    if (totalMatches == 0) {
      return 0.0;
    }
    return wins / totalMatches;
  }

  /// Determine if a match should count toward ranking
  bool matchAffectsRanking(String matchType) {
    return matchType == 'ranked' || matchType == 'friendChallenge';
  }

  /// Get points for a specific placement
  int getPointsForPlacement(int placement) {
    switch (placement) {
      case 1:
        return config.winPoints1st;
      case 2:
        return config.winPoints2nd;
      case 3:
        return config.winPoints3rd;
      default:
        return 0;
    }
  }

  /// Estimate opponent skill based on rank points
  static PlayerSkillLevel estimateSkillLevel(int rankPoints) {
    if (rankPoints < 100) {
      return PlayerSkillLevel.beginner;
    } else if (rankPoints < 500) {
      return PlayerSkillLevel.intermediate;
    } else if (rankPoints < 1500) {
      return PlayerSkillLevel.advanced;
    } else if (rankPoints < 3000) {
      return PlayerSkillLevel.expert;
    } else {
      return PlayerSkillLevel.master;
    }
  }

  /// Validate match points (security check)
  bool validateMatchPoints(
    List<String> placements,
    Map<String, int> points,
  ) {
    if (points.length != 3) {
      return false;
    }

    if (placements.length != 3) {
      return false;
    }

    for (final uid in placements) {
      if (!points.containsKey(uid)) {
        return false;
      }
    }

    return true;
  }
}

/// Player skill level estimation
enum PlayerSkillLevel {
  beginner,
  intermediate,
  advanced,
  expert,
  master,
}

extension SkillLevelExtension on PlayerSkillLevel {
  String get displayName {
    switch (this) {
      case PlayerSkillLevel.beginner:
        return 'Beginner';
      case PlayerSkillLevel.intermediate:
        return 'Intermediate';
      case PlayerSkillLevel.advanced:
        return 'Advanced';
      case PlayerSkillLevel.expert:
        return 'Expert';
      case PlayerSkillLevel.master:
        return 'Master';
    }
  }

  int get minPoints {
    switch (this) {
      case PlayerSkillLevel.beginner:
        return 0;
      case PlayerSkillLevel.intermediate:
        return 100;
      case PlayerSkillLevel.advanced:
        return 500;
      case PlayerSkillLevel.expert:
        return 1500;
      case PlayerSkillLevel.master:
        return 3000;
    }
  }

  int get maxPoints {
    switch (this) {
      case PlayerSkillLevel.beginner:
        return 99;
      case PlayerSkillLevel.intermediate:
        return 499;
      case PlayerSkillLevel.advanced:
        return 1499;
      case PlayerSkillLevel.expert:
        return 2999;
      case PlayerSkillLevel.master:
        return 999999;
    }
  }
}

/// Match result data for rank calculation
class MatchResult {
  final String matchId;
  final List<String> playerOrder; // [1st_uid, 2nd_uid, 3rd_uid]
  final String matchType; // 'ranked', 'casual', 'friendChallenge'
  final DateTime completedAt;
  final Map<String, int> stoneCountsFinal;

  MatchResult({
    required this.matchId,
    required this.playerOrder,
    required this.matchType,
    required this.completedAt,
    required this.stoneCountsFinal,
  });

  /// Calculate points for this match
  Map<String, int> calculatePoints(RankCalculationService calculator) {
    return calculator.calculateMatchPoints(
      placements: playerOrder,
      matchType: matchType,
    );
  }
}
