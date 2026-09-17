import 'package:freezed_annotation/freezed_annotation.dart';

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
class PrizePool {
  const PrizePool({
    required int totalAmount, // JPY
    required Map<int, int> distribution, // position -> amount (1 -> 100000, 2 -> 50000, etc)
    required String currency, // JPY
    String? sponsorName,
  });
}

/// Tournament with metadata
class Tournament {
  const Tournament({
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
    List<String> tags, // competitive, beginner, regional, etc
    double avgMatchDuration, // minutes
    String? bannerUrl,
    String? logoUrl,
    Map<String, dynamic>? metadata,
  });
}

/// Participant in tournament
class TournamentParticipant {
  const TournamentParticipant({
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
    int trophies,
    int consecutiveWins,
  });
}

/// Match within tournament
class TournamentMatch {
  const TournamentMatch({
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
    int predictions,
    String? matchRecordId, // Link to actual game
    Map<String, int>? finalScores, // userId -> score
  });
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
class TournamentBracket {
  const TournamentBracket({
    required String id,
    required String tournamentId,
    required Map<int, List<TournamentMatch>> roundMatches, // round -> matches
    required List<TournamentParticipant> standings,
    required int currentRound,
    required DateTime? nextRoundTime,
  });
}

/// Viewer prediction/wagering
class MatchPrediction {
  const MatchPrediction({
    required String id,
    required String matchId,
    required String viewerId,
    required String predictedWinnerId,
    required int wageredPoints, // reward points, not money
    required bool isCorrect,
    required int pointsWon,
    required DateTime createdAt,
  });
}

/// Viewer reward for watching
class ViewerReward {
  const ViewerReward({
    required String id,
    required String tournamentId,
    required String viewerId,
    required int watchMinutes,
    required int pointsEarned,
    required int tokensEarned, // Premium currency (¥)
    bool isPremiumBonus, // Extra for subscribed viewers
    required DateTime earnedAt,
  });
}

/// Featured match display info
class FeaturedMatch {
  const FeaturedMatch({
    required String id,
    required String matchId,
    required String tournamentId,
    required String title, // "Finals: Top 2 Seeds"
    required String description,
    required DateTime startTime,
    required int expectedViewers,
    required int currentViewers,
    required double importance, // 0.0-1.0, used for ranking
    bool isLive,
    required DateTime featuredStartTime,
    required DateTime featuredEndTime,
    String? bannerUrl,
    List<String> relatedTags,
  });
}

/// Tournament standings snapshot
class TournamentStandings {
  const TournamentStandings({
    required String id,
    required String tournamentId,
    required List<StandingEntry> entries,
    required DateTime generatedAt,
  });
}

/// Individual standing entry
class StandingEntry {
  const StandingEntry({
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
  });
}

/// Tournament achievement/badge
class TournamentBadge {
  const TournamentBadge({
    required String id,
    required String tournamentId,
    required String name, // "Champion", "Finalist", "Undefeated"
    required String emoji,
    required String description,
    required List<String> unlockedBy, // userIds who earned it
    required int rarity, // 1-5, higher = rarer
  });
}

/// Highlight moment in tournament
class TournamentHighlight {
  const TournamentHighlight({
    required String id,
    required String tournamentId,
    required String matchId,
    required String title,
    required String description,
    required DateTime timestamp,
    required String videoUrl,
    required int views,
    required List<String> playerIds,
    String type, // epic, upset, comeback, etc
  });
}

/// Tournament invitation to player
class TournamentInvitation {
  const TournamentInvitation({
    required String id,
    required String tournamentId,
    required String invitedUserId,
    required String invitedByUserId,
    required String tournamentName,
    required DateTime invitedAt,
    DateTime? respondedAt,
    String status, // pending, accepted, declined
  });
}
