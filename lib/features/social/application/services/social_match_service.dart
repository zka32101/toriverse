/// Social match service for managing ranked and social matches
///
/// Integrates match results with rank points, friend challenges, and social features.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../leaderboard/application/services/rank_calculation_service.dart';
import '../../../leaderboard/domain/models/leaderboard_models.dart';
import '../domain/models/friend_models.dart';

enum MatchType {
  ranked,
  casual,
  friendChallenge,
  tournamentQualifier,
}

/// Social match data with ranking integration
class SocialMatch {
  final String id;
  final MatchType matchType;
  final List<String> players; // 3 player UIDs or 'AI'
  final List<int> finalPlacement; // [1st_uid_index, 2nd_uid_index, 3rd_uid_index]
  final String? invitedBy; // Friend who created the match
  final List<String>? spectatorUids; // For Phase 17
  final Map<String, int> rankPointsAwarded;
  final bool rankChangeApplied;
  final DateTime createdAt;
  final DateTime? completedAt;

  SocialMatch({
    required this.id,
    required this.matchType,
    required this.players,
    required this.finalPlacement,
    this.invitedBy,
    this.spectatorUids,
    required this.rankPointsAwarded,
    this.rankChangeApplied = false,
    required this.createdAt,
    this.completedAt,
  });

  /// Convert to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'matchType': matchType.toString(),
      'players': players,
      'finalPlacement': finalPlacement,
      'invitedBy': invitedBy,
      'spectatorUids': spectatorUids ?? [],
      'rankPointsAwarded': rankPointsAwarded,
      'rankChangeApplied': rankChangeApplied,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  /// Create from Firestore JSON
  factory SocialMatch.fromJson(String id, Map<String, dynamic> json) {
    return SocialMatch(
      id: id,
      matchType: _parseMatchType(json['matchType'] as String?),
      players: List<String>.from(json['players'] as List? ?? []),
      finalPlacement:
          List<int>.from(json['finalPlacement'] as List? ?? []),
      invitedBy: json['invitedBy'] as String?,
      spectatorUids: List<String>.from(json['spectatorUids'] as List? ?? []),
      rankPointsAwarded:
          Map<String, int>.from(json['rankPointsAwarded'] as Map? ?? {}),
      rankChangeApplied: json['rankChangeApplied'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  /// Get point value for specific placement
  int getPointsForUid(String uid) {
    return rankPointsAwarded[uid] ?? 0;
  }

  /// Check if user participated
  bool didUserParticipate(String uid) {
    return players.contains(uid);
  }

  /// Get user's placement (1, 2, or 3)
  int? getUserPlacement(String uid) {
    final playerIndex = players.indexWhere((p) => p == uid);
    if (playerIndex == -1) return null;

    for (int i = 0; i < finalPlacement.length; i++) {
      if (finalPlacement[i] == playerIndex) {
        return i + 1;
      }
    }
    return null;
  }
}

/// Service for social match management
class SocialMatchService {
  final FirebaseFirestore _firestore;
  final RankCalculationService _rankCalculationService;

  static const String _matchesCollection = 'matches';
  static const String _matchHistoryCollection = 'matchHistory';

  SocialMatchService({
    required FirebaseFirestore firestore,
    required RankCalculationService rankCalculationService,
  })  : _firestore = firestore,
        _rankCalculationService = rankCalculationService;

  /// Create a new match (ranked or casual)
  Future<String> createMatch({
    required MatchType matchType,
    required List<String> playerUids,
    String? invitedBy,
  }) async {
    try {
      if (playerUids.length != 3) {
        throw ArgumentError('Match must have exactly 3 players');
      }

      final matchId = _firestore.collection(_matchesCollection).doc().id;
      final now = DateTime.now();

      await _firestore.collection(_matchesCollection).doc(matchId).set({
        'matchType': matchType.toString(),
        'players': playerUids,
        'finalPlacement': [],
        'invitedBy': invitedBy,
        'spectatorUids': [],
        'rankPointsAwarded': {},
        'rankChangeApplied': false,
        'createdAt': now.toIso8601String(),
        'completedAt': null,
      });

      // Add to each player's history
      for (final uid in playerUids) {
        await _firestore
            .collection('users')
            .doc(uid)
            .collection(_matchHistoryCollection)
            .doc(matchId)
            .set({
          'matchId': matchId,
          'matchType': matchType.toString(),
          'participants': playerUids,
          'joinedAt': now.toIso8601String(),
          'completedAt': null,
        });
      }

      debugPrint('Created $matchType match: $matchId with players $playerUids');
      return matchId;
    } catch (e) {
      debugPrint('Error creating match: $e');
      rethrow;
    }
  }

  /// Complete a match and apply rank points
  Future<void> completeMatch({
    required String matchId,
    required List<String> finalPlacement, // [1st_uid, 2nd_uid, 3rd_uid]
    required MatchType matchType,
  }) async {
    try {
      if (finalPlacement.length != 3) {
        throw ArgumentError('Final placement must have exactly 3 players');
      }

      // Calculate rank points
      final rankPoints = _rankCalculationService.calculateMatchPoints(
        placements: finalPlacement,
        matchType: matchType.name,
      );

      // Validate
      if (!_rankCalculationService.validateMatchPoints(
        finalPlacement,
        rankPoints,
      )) {
        throw StateError('Invalid match points calculated');
      }

      // Update match
      await _firestore.collection(_matchesCollection).doc(matchId).update({
        'finalPlacement': finalPlacement,
        'rankPointsAwarded': rankPoints,
        'rankChangeApplied': false,
        'completedAt': DateTime.now().toIso8601String(),
      });

      // Update player match history
      for (int i = 0; i < finalPlacement.length; i++) {
        final uid = finalPlacement[i];
        final placement = i + 1;
        final points = rankPoints[uid] ?? 0;

        await _firestore
            .collection('users')
            .doc(uid)
            .collection(_matchHistoryCollection)
            .doc(matchId)
            .update({
          'placement': placement,
          'pointsAwarded': points,
          'completedAt': DateTime.now().toIso8601String(),
        });
      }

      debugPrint(
        'Completed match $matchId with placement $finalPlacement, '
        'rank points: $rankPoints',
      );
    } catch (e) {
      debugPrint('Error completing match: $e');
      rethrow;
    }
  }

  /// Apply rank points to players (called after server-side validation)
  Future<void> applyRankPoints({
    required String matchId,
    required Map<String, int> rankPointsAwarded,
  }) async {
    try {
      final batch = _firestore.batch();

      // Update each player's rank
      for (final entry in rankPointsAwarded.entries) {
        final uid = entry.key;
        final points = entry.value;

        if (points != 0) {
          final playerRankRef = _firestore
              .collection('leaderboards')
              .doc('global')
              .collection('entries')
              .doc(uid);

          batch.update(playerRankRef, {
            'rankPoints': FieldValue.increment(points),
            'lastUpdated': DateTime.now().toIso8601String(),
          });
        }
      }

      // Mark rank points as applied
      batch.update(
        _firestore.collection(_matchesCollection).doc(matchId),
        {'rankChangeApplied': true},
      );

      await batch.commit();

      debugPrint('Applied rank points for match $matchId');
    } catch (e) {
      debugPrint('Error applying rank points: $e');
      rethrow;
    }
  }

  /// Get match details
  Future<SocialMatch?> getMatch(String matchId) async {
    try {
      final doc =
          await _firestore.collection(_matchesCollection).doc(matchId).get();

      if (!doc.exists) {
        return null;
      }

      return SocialMatch.fromJson(matchId, doc.data()!);
    } catch (e) {
      debugPrint('Error fetching match: $e');
      return null;
    }
  }

  /// Get user's match history
  Future<List<SocialMatch>> getUserMatchHistory(
    String uid, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection(_matchHistoryCollection)
          .orderBy('joinedAt', descending: true)
          .limit(limit)
          .get();

      final matches = <SocialMatch>[];
      for (final doc in snapshot.docs) {
        final matchId = doc['matchId'] as String;
        final match = await getMatch(matchId);
        if (match != null) {
          matches.add(match);
        }
      }

      return matches;
    } catch (e) {
      debugPrint('Error fetching user match history: $e');
      return [];
    }
  }

  /// Get recent matches for a user
  Future<List<SocialMatch>> getRecentMatches(
    String uid, {
    Duration withinDays = const Duration(days: 7),
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(withinDays);

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection(_matchHistoryCollection)
          .where('joinedAt', isGreaterThan: cutoffDate.toIso8601String())
          .orderBy('joinedAt', descending: true)
          .get();

      final matches = <SocialMatch>[];
      for (final doc in snapshot.docs) {
        final matchId = doc['matchId'] as String;
        final match = await getMatch(matchId);
        if (match != null) {
          matches.add(match);
        }
      }

      return matches;
    } catch (e) {
      debugPrint('Error fetching recent matches: $e');
      return [];
    }
  }

  /// Create a friend challenge
  Future<String> createFriendChallenge({
    required String creatorUid,
    required String friendUid,
    String? thirdPlayerUid,
  }) async {
    try {
      final players = [
        creatorUid,
        friendUid,
        thirdPlayerUid ?? 'AI',
      ];

      return await createMatch(
        matchType: MatchType.friendChallenge,
        playerUids: players,
        invitedBy: creatorUid,
      );
    } catch (e) {
      debugPrint('Error creating friend challenge: $e');
      rethrow;
    }
  }

  /// Get matches between friends
  Future<List<SocialMatch>> getFriendMatches(
    String uid,
    List<String> friendUids, {
    int limit = 20,
  }) async {
    try {
      final allMatches = await getUserMatchHistory(uid, limit: limit * 2);

      return allMatches
          .where((match) {
            // Filter for friend challenge or ranked matches with friends
            if (match.matchType == MatchType.friendChallenge) {
              return match.didUserParticipate(uid);
            }

            // Check if any friend participated
            return match.players
                .any((p) => friendUids.contains(p) && p != 'AI');
          })
          .take(limit)
          .toList();
    } catch (e) {
      debugPrint('Error fetching friend matches: $e');
      return [];
    }
  }

  /// Stream match updates
  Stream<SocialMatch?> streamMatch(String matchId) {
    return _firestore
        .collection(_matchesCollection)
        .doc(matchId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      return SocialMatch.fromJson(matchId, snapshot.data()!);
    }).handleError((e) {
      debugPrint('Error streaming match: $e');
    });
  }

  /// Get match statistics for user
  Future<Map<String, dynamic>> getUserMatchStats(String uid) async {
    try {
      final matches = await getUserMatchHistory(uid, limit: 100);

      int ranked1st = 0;
      int ranked2nd = 0;
      int ranked3rd = 0;
      int casual = 0;
      int friendChallenges = 0;
      int totalPoints = 0;

      for (final match in matches) {
        final placement = match.getUserPlacement(uid);
        final points = match.getPointsForUid(uid);

        switch (match.matchType) {
          case MatchType.ranked:
            switch (placement) {
              case 1:
                ranked1st++;
              case 2:
                ranked2nd++;
              case 3:
                ranked3rd++;
              default:
            }
            totalPoints += points;
          case MatchType.casual:
            casual++;
          case MatchType.friendChallenge:
            friendChallenges++;
            totalPoints += points;
          case MatchType.tournamentQualifier:
            break;
        }
      }

      return {
        'totalMatches': matches.length,
        'ranked1st': ranked1st,
        'ranked2nd': ranked2nd,
        'ranked3rd': ranked3rd,
        'casual': casual,
        'friendChallenges': friendChallenges,
        'totalPoints': totalPoints,
        'winRate': matches.isNotEmpty
            ? (ranked1st + friendChallenges) / matches.length
            : 0.0,
      };
    } catch (e) {
      debugPrint('Error calculating match stats: $e');
      return {};
    }
  }
}

/// Helper function to parse match type
MatchType _parseMatchType(String? typeStr) {
  if (typeStr == null) return MatchType.casual;

  return MatchType.values.firstWhere(
    (type) => type.toString() == typeStr,
    orElse: () => MatchType.casual,
  );
}
