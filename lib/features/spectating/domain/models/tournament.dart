import 'package:freezed_annotation/freezed_annotation.dart';

part 'tournament.freezed.dart';
part 'tournament.g.dart';

/// Tournament format and rules
enum TournamentFormat {
  singleElimination,
  doubleElimination,
  roundRobin,
  swiss,
  ladder;

  String get label => switch (this) {
    TournamentFormat.singleElimination => 'Single Elimination',
    TournamentFormat.doubleElimination => 'Double Elimination',
    TournamentFormat.roundRobin => 'Round Robin',
    TournamentFormat.swiss => 'Swiss System',
    TournamentFormat.ladder => 'Ladder',
  };

  String get description => switch (this) {
    TournamentFormat.singleElimination => 'One loss and you\'re out',
    TournamentFormat.doubleElimination => 'One more chance in losers bracket',
    TournamentFormat.roundRobin => 'Everyone plays everyone',
    TournamentFormat.swiss => 'Balanced pairings by skill',
    TournamentFormat.ladder => 'Climbing rankings continuously',
  };

  int get maxPlayers => switch (this) {
    TournamentFormat.singleElimination => 64,
    TournamentFormat.doubleElimination => 32,
    TournamentFormat.roundRobin => 16,
    TournamentFormat.swiss => 128,
    TournamentFormat.ladder => 1000,
  };

  int get minPlayers => 3;
}

/// Tournament status
enum TournamentStatus {
  draft,
  registration,
  inProgress,
  finished,
  cancelled;

  String get label => switch (this) {
    TournamentStatus.draft => 'Draft',
    TournamentStatus.registration => 'Registration Open',
    TournamentStatus.inProgress => 'In Progress',
    TournamentStatus.finished => 'Finished',
    TournamentStatus.cancelled => 'Cancelled',
  };

  bool get isActive => this == TournamentStatus.inProgress || this == TournamentStatus.registration;
  bool get canRegister => this == TournamentStatus.registration;
}

/// Prize distribution model
@freezed
class PrizePool with _$PrizePool {
  const factory PrizePool({
    required int totalAmount, // JPY
    required Map<int, int> distribution, // position -> amount (1 -> 100000, 2 -> 50000, etc)
    required String currency, // JPY
    String? sponsorName,
  }) = _PrizePool;

  factory PrizePool.fromJson(Map<String, dynamic> json) => _$PrizePoolFromJson(json);
}

/// Tournament with metadata
@freezed
class Tournament with _$Tournament {
  const factory Tournament({
    required String id,
    required String name,
    required String description,
    required TournamentFormat format,
    required TournamentStatus status,
    required DateTime startDate,
    required DateTime? endDate,
    required DateTime registrationDeadline,
    required int maxParticipants,
    required int currentParticipants,
    required PrizePool prizePool,
    required String organizerId,
    required String organizerName,
    required List<String> rules, // Tournament-specific rules
    required bool isFeatured, // Display on home/discovery
    required int viewerCount,
    required int totalMatches,
    required int completedMatches,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default([]) List<String> tags, // competitive, beginner, regional, etc
    @Default(0.0) double avgMatchDuration, // minutes
    String? bannerUrl,
    String? logoUrl,
    Map<String, dynamic>? metadata,
  }) = _Tournament;

  factory Tournament.fromJson(Map<String, dynamic> json) => _$TournamentFromJson(json);
}

/// Participant in tournament
@freezed
class TournamentParticipant with _$TournamentParticipant {
  const factory TournamentParticipant({
    required String id,
    required String tournamentId,
    required String userId,
    required String displayName,
    required int seedRank, // 1 = top seed, lower = better
    required int wins,
    required int losses,
    required double winRate,
    required int points,
    required bool isActive,
    required DateTime joinedAt,
    DateTime? eliminatedAt,
    @Default(0) int trophies,
    @Default(0) int consecutiveWins,
  }) = _TournamentParticipant;

  factory TournamentParticipant.fromJson(Map<String, dynamic> json) => _$TournamentParticipantFromJson(json);
}

/// Match within tournament
@freezed
class TournamentMatch with _$TournamentMatch {
  const factory TournamentMatch({
    required String id,
    required String tournamentId,
    required int round,
    required int matchNumber,
    required List<String> playerIds, // Always 3 for tri-Othello
    required List<String>? playerNames,
    required List<int>? playerSeeds,
    String? winnerId,
    required MatchStatus status,
    required DateTime scheduledTime,
    DateTime? completedTime,
    required bool isFeatured, // Highlighted match
    required int viewerCount,
    @Default(0) int predictions,
    String? matchRecordId, // Link to actual game
    Map<String, int>? finalScores, // userId -> score
  }) = _TournamentMatch;

  factory TournamentMatch.fromJson(Map<String, dynamic> json) => _$TournamentMatchFromJson(json);
}

/// Match status
enum MatchStatus {
  scheduled,
  live,
  completed,
  cancelled;

  String get label => switch (this) {
    MatchStatus.scheduled => 'Scheduled',
    MatchStatus.live => 'Live Now',
    MatchStatus.completed => 'Finished',
    MatchStatus.cancelled => 'Cancelled',
  };

  bool get isLive => this == MatchStatus.live;
}

/// Tournament bracket/standings
@freezed
class TournamentBracket with _$TournamentBracket {
  const factory TournamentBracket({
    required String id,
    required String tournamentId,
    required Map<int, List<TournamentMatch>> roundMatches, // round -> matches
    required List<TournamentParticipant> standings,
    required int currentRound,
    required DateTime? nextRoundTime,
  }) = _TournamentBracket;

  factory TournamentBracket.fromJson(Map<String, dynamic> json) => _$TournamentBracketFromJson(json);
}

/// Viewer prediction/wagering
@freezed
class MatchPrediction with _$MatchPrediction {
  const factory MatchPrediction({
    required String id,
    required String matchId,
    required String viewerId,
    required String predictedWinnerId,
    required int wageredPoints, // reward points, not money
    required bool isCorrect,
    required int pointsWon,
    required DateTime createdAt,
  }) = _MatchPrediction;

  factory MatchPrediction.fromJson(Map<String, dynamic> json) => _$MatchPredictionFromJson(json);
}

/// Viewer reward for watching
@freezed
class ViewerReward with _$ViewerReward {
  const factory ViewerReward({
    required String id,
    required String tournamentId,
    required String viewerId,
    required int watchMinutes,
    required int pointsEarned,
    required int tokensEarned, // Premium currency (¥)
    @Default(false) bool isPremiumBonus, // Extra for subscribed viewers
    required DateTime earnedAt,
  }) = _ViewerReward;

  factory ViewerReward.fromJson(Map<String, dynamic> json) => _$ViewerRewardFromJson(json);
}

/// Featured match display info
@freezed
class FeaturedMatch with _$FeaturedMatch {
  const factory FeaturedMatch({
    required String id,
    required String matchId,
    required String tournamentId,
    required String title, // "Finals: Top 2 Seeds"
    required String description,
    required DateTime startTime,
    required int expectedViewers,
    required int currentViewers,
    required double importance, // 0.0-1.0, used for ranking
    @Default(false) bool isLive,
    required DateTime featuredStartTime,
    required DateTime featuredEndTime,
    String? bannerUrl,
    @Default([]) List<String> relatedTags,
  }) = _FeaturedMatch;

  factory FeaturedMatch.fromJson(Map<String, dynamic> json) => _$FeaturedMatchFromJson(json);
}

/// Tournament standings snapshot
@freezed
class TournamentStandings with _$TournamentStandings {
  const factory TournamentStandings({
    required String id,
    required String tournamentId,
    required List<StandingEntry> entries,
    required DateTime generatedAt,
  }) = _TournamentStandings;

  factory TournamentStandings.fromJson(Map<String, dynamic> json) => _$TournamentStandingsFromJson(json);
}

/// Individual standing entry
@freezed
class StandingEntry with _$StandingEntry {
  const factory StandingEntry({
    required int rank,
    required String playerId,
    required String playerName,
    required int wins,
    required int losses,
    required int draws,
    required double winRate,
    required int pointsFor,
    required int pointsAgainst,
    required int pointDiff,
    required int trophies,
    required String? tier, // S/A/B/C etc
  }) = _StandingEntry;

  factory StandingEntry.fromJson(Map<String, dynamic> json) => _$StandingEntryFromJson(json);
}

/// Tournament achievement/badge
@freezed
class TournamentBadge with _$TournamentBadge {
  const factory TournamentBadge({
    required String id,
    required String tournamentId,
    required String name, // "Champion", "Finalist", "Undefeated"
    required String emoji,
    required String description,
    required List<String> unlockedBy, // userIds who earned it
    required int rarity, // 1-5, higher = rarer
  }) = _TournamentBadge;

  factory TournamentBadge.fromJson(Map<String, dynamic> json) => _$TournamentBadgeFromJson(json);
}

/// Highlight moment in tournament
@freezed
class TournamentHighlight with _$TournamentHighlight {
  const factory TournamentHighlight({
    required String id,
    required String tournamentId,
    required String matchId,
    required String title,
    required String description,
    required DateTime timestamp,
    required String videoUrl,
    required int views,
    required List<String> playerIds,
    @Default('epic') String type, // epic, upset, comeback, etc
  }) = _TournamentHighlight;

  factory TournamentHighlight.fromJson(Map<String, dynamic> json) => _$TournamentHighlightFromJson(json);
}

/// Tournament invitation to player
@freezed
class TournamentInvitation with _$TournamentInvitation {
  const factory TournamentInvitation({
    required String id,
    required String tournamentId,
    required String invitedUserId,
    required String invitedByUserId,
    required String tournamentName,
    required DateTime invitedAt,
    DateTime? respondedAt,
    @Default('pending') String status, // pending, accepted, declined
  }) = _TournamentInvitation;

  factory TournamentInvitation.fromJson(Map<String, dynamic> json) => _$TournamentInvitationFromJson(json);
}
