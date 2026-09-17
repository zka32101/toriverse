import 'package:freezed_annotation/freezed_annotation.dart';

part 'leaderboard_ranking_models.freezed.dart';
part 'leaderboard_ranking_models.g.dart';

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
