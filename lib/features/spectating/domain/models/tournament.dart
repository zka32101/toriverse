
/// Parses a DateTime from JSON. Tolerates ISO-8601 strings (our own
/// [toJson] output), raw [DateTime] instances, and duck-typed Firestore
/// `Timestamp` objects (which expose a `toDate()` method) since some
/// fields are written server-side via `FieldValue.serverTimestamp()` and
/// read back without going through [toJson].
DateTime _parseDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.parse(value);
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  try {
    return (value as dynamic).toDate() as DateTime;
  } catch (_) {
    return DateTime.now();
  }
}

DateTime? _parseDateTimeOrNull(dynamic value) {
  if (value == null) return null;
  return _parseDateTime(value);
}

List<String> _stringList(dynamic value) =>
    (value as List<dynamic>?)?.map((e) => e as String).toList() ?? const [];

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
  final int totalAmount;
  final Map<int, int> distribution;
  final String currency;
  final String? sponsorName;

  const PrizePool({
    required this.totalAmount, // JPY
    required this.distribution, // position -> amount (1 -> 100000, 2 -> 50000, etc)
    required this.currency, // JPY
    this.sponsorName,
  });

  Map<String, dynamic> toJson() => {
        'totalAmount': totalAmount,
        'distribution': distribution.map((k, v) => MapEntry(k.toString(), v)),
        'currency': currency,
        'sponsorName': sponsorName,
      };

  factory PrizePool.fromJson(Map<String, dynamic> json) {
    final rawDistribution =
        (json['distribution'] as Map<dynamic, dynamic>?) ?? const {};
    return PrizePool(
      totalAmount: json['totalAmount'] as int,
      distribution: rawDistribution.map(
        (k, v) => MapEntry(int.parse(k.toString()), v as int),
      ),
      currency: json['currency'] as String,
      sponsorName: json['sponsorName'] as String?,
    );
  }
}

/// Tournament with metadata
class Tournament {
  final String id;
  final String name;
  final String description;
  final TournamentFormat format;
  final TournamentStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime registrationDeadline;
  final int maxParticipants;
  final int currentParticipants;
  final PrizePool prizePool;
  final String organizerId;
  final String organizerName;
  final List<String> rules;
  final bool isFeatured;
  final int viewerCount;
  final int totalMatches;
  final int completedMatches;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final double avgMatchDuration;
  final String? bannerUrl;
  final String? logoUrl;
  final Map<String, dynamic>? metadata;

  const Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.format,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.registrationDeadline,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.prizePool,
    required this.organizerId,
    required this.organizerName,
    required this.rules, // Tournament-specific rules
    required this.isFeatured, // Display on home/discovery
    required this.viewerCount,
    required this.totalMatches,
    required this.completedMatches,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [], // competitive, beginner, regional, etc
    this.avgMatchDuration = 0.0, // minutes
    this.bannerUrl,
    this.logoUrl,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'format': format.name,
        'status': status.name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'registrationDeadline': registrationDeadline.toIso8601String(),
        'maxParticipants': maxParticipants,
        'currentParticipants': currentParticipants,
        'prizePool': prizePool.toJson(),
        'organizerId': organizerId,
        'organizerName': organizerName,
        'rules': rules,
        'isFeatured': isFeatured,
        'viewerCount': viewerCount,
        'totalMatches': totalMatches,
        'completedMatches': completedMatches,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'tags': tags,
        'avgMatchDuration': avgMatchDuration,
        'bannerUrl': bannerUrl,
        'logoUrl': logoUrl,
        'metadata': metadata,
      };

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      format: TournamentFormat.values.byName(json['format'] as String),
      status: TournamentStatus.values.byName(json['status'] as String),
      startDate: _parseDateTime(json['startDate']),
      endDate: _parseDateTimeOrNull(json['endDate']),
      registrationDeadline: _parseDateTime(json['registrationDeadline']),
      maxParticipants: json['maxParticipants'] as int,
      currentParticipants: json['currentParticipants'] as int,
      prizePool: PrizePool.fromJson(json['prizePool'] as Map<String, dynamic>),
      organizerId: json['organizerId'] as String,
      organizerName: json['organizerName'] as String,
      rules: _stringList(json['rules']),
      isFeatured: json['isFeatured'] as bool,
      viewerCount: json['viewerCount'] as int,
      totalMatches: json['totalMatches'] as int,
      completedMatches: json['completedMatches'] as int,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      tags: _stringList(json['tags']),
      avgMatchDuration: (json['avgMatchDuration'] as num?)?.toDouble() ?? 0.0,
      bannerUrl: json['bannerUrl'] as String?,
      logoUrl: json['logoUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Participant in tournament
class TournamentParticipant {
  final String id;
  final String tournamentId;
  final String userId;
  final String displayName;
  final int seedRank;
  final int wins;
  final int losses;
  final double winRate;
  final int points;
  final bool isActive;
  final DateTime joinedAt;
  final DateTime? eliminatedAt;
  final int trophies;
  final int consecutiveWins;

  const TournamentParticipant({
    required this.id,
    required this.tournamentId,
    required this.userId,
    required this.displayName,
    required this.seedRank, // 1 = top seed, lower = better
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.points,
    required this.isActive,
    required this.joinedAt,
    this.eliminatedAt,
    this.trophies = 0,
    this.consecutiveWins = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tournamentId': tournamentId,
        'userId': userId,
        'displayName': displayName,
        'seedRank': seedRank,
        'wins': wins,
        'losses': losses,
        'winRate': winRate,
        'points': points,
        'isActive': isActive,
        'joinedAt': joinedAt.toIso8601String(),
        'eliminatedAt': eliminatedAt?.toIso8601String(),
        'trophies': trophies,
        'consecutiveWins': consecutiveWins,
      };

  factory TournamentParticipant.fromJson(Map<String, dynamic> json) {
    return TournamentParticipant(
      id: json['id'] as String,
      tournamentId: json['tournamentId'] as String,
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      seedRank: json['seedRank'] as int,
      wins: json['wins'] as int,
      losses: json['losses'] as int,
      winRate: (json['winRate'] as num).toDouble(),
      points: json['points'] as int,
      isActive: json['isActive'] as bool,
      joinedAt: _parseDateTime(json['joinedAt']),
      eliminatedAt: _parseDateTimeOrNull(json['eliminatedAt']),
      trophies: json['trophies'] as int? ?? 0,
      consecutiveWins: json['consecutiveWins'] as int? ?? 0,
    );
  }
}

/// Match within tournament
class TournamentMatch {
  final String id;
  final String tournamentId;
  final int round;
  final int matchNumber;
  final List<String> playerIds;
  final List<String>? playerNames;
  final List<int>? playerSeeds;
  final String? winnerId;
  final MatchStatus status;
  final DateTime scheduledTime;
  final DateTime? completedTime;
  final bool isFeatured;
  final int viewerCount;
  final int predictions;
  final String? matchRecordId;
  final Map<String, int>? finalScores;

  const TournamentMatch({
    required this.id,
    required this.tournamentId,
    required this.round,
    required this.matchNumber,
    required this.playerIds, // Always 3 for tri-Othello
    this.playerNames,
    this.playerSeeds,
    this.winnerId,
    required this.status,
    required this.scheduledTime,
    this.completedTime,
    required this.isFeatured, // Highlighted match
    required this.viewerCount,
    this.predictions = 0,
    this.matchRecordId, // Link to actual game
    this.finalScores, // userId -> score
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tournamentId': tournamentId,
        'round': round,
        'matchNumber': matchNumber,
        'playerIds': playerIds,
        'playerNames': playerNames,
        'playerSeeds': playerSeeds,
        'winnerId': winnerId,
        'status': status.name,
        'scheduledTime': scheduledTime.toIso8601String(),
        'completedTime': completedTime?.toIso8601String(),
        'isFeatured': isFeatured,
        'viewerCount': viewerCount,
        'predictions': predictions,
        'matchRecordId': matchRecordId,
        'finalScores': finalScores,
      };

  factory TournamentMatch.fromJson(Map<String, dynamic> json) {
    return TournamentMatch(
      id: json['id'] as String,
      tournamentId: json['tournamentId'] as String,
      round: json['round'] as int,
      matchNumber: json['matchNumber'] as int,
      playerIds: _stringList(json['playerIds']),
      playerNames: json['playerNames'] != null
          ? _stringList(json['playerNames'])
          : null,
      playerSeeds: (json['playerSeeds'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      winnerId: json['winnerId'] as String?,
      status: MatchStatus.values.byName(json['status'] as String),
      scheduledTime: _parseDateTime(json['scheduledTime']),
      completedTime: _parseDateTimeOrNull(json['completedTime']),
      isFeatured: json['isFeatured'] as bool,
      viewerCount: json['viewerCount'] as int,
      predictions: json['predictions'] as int? ?? 0,
      matchRecordId: json['matchRecordId'] as String?,
      finalScores: (json['finalScores'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as int)),
    );
  }
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
  final String id;
  final String tournamentId;
  final Map<int, List<TournamentMatch>> roundMatches;
  final List<TournamentParticipant> standings;
  final int currentRound;
  final DateTime? nextRoundTime;

  const TournamentBracket({
    required this.id,
    required this.tournamentId,
    required this.roundMatches, // round -> matches
    required this.standings,
    required this.currentRound,
    required this.nextRoundTime,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tournamentId': tournamentId,
        'roundMatches': roundMatches.map(
          (k, v) => MapEntry(
            k.toString(),
            v.map((m) => m.toJson()).toList(),
          ),
        ),
        'standings': standings.map((e) => e.toJson()).toList(),
        'currentRound': currentRound,
        'nextRoundTime': nextRoundTime?.toIso8601String(),
      };

  factory TournamentBracket.fromJson(Map<String, dynamic> json) {
    final rawRoundMatches =
        (json['roundMatches'] as Map<dynamic, dynamic>?) ?? const {};
    return TournamentBracket(
      id: json['id'] as String,
      tournamentId: json['tournamentId'] as String,
      roundMatches: rawRoundMatches.map(
        (k, v) => MapEntry(
          int.parse(k.toString()),
          (v as List<dynamic>)
              .map((m) => TournamentMatch.fromJson(m as Map<String, dynamic>))
              .toList(),
        ),
      ),
      standings: (json['standings'] as List<dynamic>? ?? const [])
          .map((e) =>
              TournamentParticipant.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentRound: json['currentRound'] as int,
      nextRoundTime: _parseDateTimeOrNull(json['nextRoundTime']),
    );
  }
}

/// Viewer prediction/wagering
class MatchPrediction {
  final String id;
  final String matchId;
  final String viewerId;
  final String predictedWinnerId;
  final int wageredPoints;
  final bool isCorrect;
  final int pointsWon;
  final DateTime createdAt;

  const MatchPrediction({
    required this.id,
    required this.matchId,
    required this.viewerId,
    required this.predictedWinnerId,
    required this.wageredPoints, // reward points, not money
    required this.isCorrect,
    required this.pointsWon,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'matchId': matchId,
        'viewerId': viewerId,
        'predictedWinnerId': predictedWinnerId,
        'wageredPoints': wageredPoints,
        'isCorrect': isCorrect,
        'pointsWon': pointsWon,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MatchPrediction.fromJson(Map<String, dynamic> json) {
    return MatchPrediction(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      viewerId: json['viewerId'] as String,
      predictedWinnerId: json['predictedWinnerId'] as String,
      wageredPoints: json['wageredPoints'] as int,
      isCorrect: json['isCorrect'] as bool,
      pointsWon: json['pointsWon'] as int,
      createdAt: _parseDateTime(json['createdAt']),
    );
  }
}

/// Viewer reward for watching
class ViewerReward {
  final String id;
  final String tournamentId;
  final String viewerId;
  final int watchMinutes;
  final int pointsEarned;
  final int tokensEarned;
  final bool isPremiumBonus;
  final DateTime earnedAt;

  const ViewerReward({
    required this.id,
    required this.tournamentId,
    required this.viewerId,
    required this.watchMinutes,
    required this.pointsEarned,
    required this.tokensEarned, // Premium currency (¥)
    this.isPremiumBonus = false, // Extra for subscribed viewers
    required this.earnedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tournamentId': tournamentId,
        'viewerId': viewerId,
        'watchMinutes': watchMinutes,
        'pointsEarned': pointsEarned,
        'tokensEarned': tokensEarned,
        'isPremiumBonus': isPremiumBonus,
        'earnedAt': earnedAt.toIso8601String(),
      };

  factory ViewerReward.fromJson(Map<String, dynamic> json) {
    return ViewerReward(
      id: json['id'] as String,
      tournamentId: json['tournamentId'] as String,
      viewerId: json['viewerId'] as String,
      watchMinutes: json['watchMinutes'] as int,
      pointsEarned: json['pointsEarned'] as int,
      tokensEarned: json['tokensEarned'] as int,
      isPremiumBonus: json['isPremiumBonus'] as bool? ?? false,
      earnedAt: _parseDateTime(json['earnedAt']),
    );
  }
}

/// Featured match display info
class FeaturedMatch {
  final String id;
  final String matchId;
  final String tournamentId;
  final String title;
  final String description;
  final DateTime startTime;
  final int expectedViewers;
  final int currentViewers;
  final double importance;
  final bool isLive;
  final DateTime featuredStartTime;
  final DateTime featuredEndTime;
  final String? bannerUrl;
  final List<String> relatedTags;

  const FeaturedMatch({
    required this.id,
    required this.matchId,
    required this.tournamentId,
    required this.title, // "Finals: Top 2 Seeds"
    required this.description,
    required this.startTime,
    required this.expectedViewers,
    required this.currentViewers,
    required this.importance, // 0.0-1.0, used for ranking
    this.isLive = false,
    required this.featuredStartTime,
    required this.featuredEndTime,
    this.bannerUrl,
    this.relatedTags = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'matchId': matchId,
        'tournamentId': tournamentId,
        'title': title,
        'description': description,
        'startTime': startTime.toIso8601String(),
        'expectedViewers': expectedViewers,
        'currentViewers': currentViewers,
        'importance': importance,
        'isLive': isLive,
        'featuredStartTime': featuredStartTime.toIso8601String(),
        'featuredEndTime': featuredEndTime.toIso8601String(),
        'bannerUrl': bannerUrl,
        'relatedTags': relatedTags,
      };

  factory FeaturedMatch.fromJson(Map<String, dynamic> json) {
    return FeaturedMatch(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      tournamentId: json['tournamentId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: _parseDateTime(json['startTime']),
      expectedViewers: json['expectedViewers'] as int,
      currentViewers: json['currentViewers'] as int,
      importance: (json['importance'] as num).toDouble(),
      isLive: json['isLive'] as bool? ?? false,
      featuredStartTime: _parseDateTime(json['featuredStartTime']),
      featuredEndTime: _parseDateTime(json['featuredEndTime']),
      bannerUrl: json['bannerUrl'] as String?,
      relatedTags: _stringList(json['relatedTags']),
    );
  }
}

/// Tournament standings snapshot
class TournamentStandings {
  final String id;
  final String tournamentId;
  final List<StandingEntry> entries;
  final DateTime generatedAt;

  const TournamentStandings({
    required this.id,
    required this.tournamentId,
    required this.entries,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tournamentId': tournamentId,
        'entries': entries.map((e) => e.toJson()).toList(),
        'generatedAt': generatedAt.toIso8601String(),
      };

  factory TournamentStandings.fromJson(Map<String, dynamic> json) {
    return TournamentStandings(
      id: json['id'] as String,
      tournamentId: json['tournamentId'] as String,
      entries: (json['entries'] as List<dynamic>? ?? const [])
          .map((e) => StandingEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      generatedAt: _parseDateTime(json['generatedAt']),
    );
  }
}

/// Individual standing entry
class StandingEntry {
  final int rank;
  final String playerId;
  final String playerName;
  final int wins;
  final int losses;
  final int draws;
  final double winRate;
  final int pointsFor;
  final int pointsAgainst;
  final int pointDiff;
  final int trophies;
  final String? tier;

  const StandingEntry({
    required this.rank,
    required this.playerId,
    required this.playerName,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.winRate,
    required this.pointsFor,
    required this.pointsAgainst,
    required this.pointDiff,
    required this.trophies,
    required this.tier, // S/A/B/C etc
  });

  Map<String, dynamic> toJson() => {
        'rank': rank,
        'playerId': playerId,
        'playerName': playerName,
        'wins': wins,
        'losses': losses,
        'draws': draws,
        'winRate': winRate,
        'pointsFor': pointsFor,
        'pointsAgainst': pointsAgainst,
        'pointDiff': pointDiff,
        'trophies': trophies,
        'tier': tier,
      };

  factory StandingEntry.fromJson(Map<String, dynamic> json) {
    return StandingEntry(
      rank: json['rank'] as int,
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      wins: json['wins'] as int,
      losses: json['losses'] as int,
      draws: json['draws'] as int,
      winRate: (json['winRate'] as num).toDouble(),
      pointsFor: json['pointsFor'] as int,
      pointsAgainst: json['pointsAgainst'] as int,
      pointDiff: json['pointDiff'] as int,
      trophies: json['trophies'] as int,
      tier: json['tier'] as String?,
    );
  }
}

/// Tournament achievement/badge
class TournamentBadge {
  final String id;
  final String tournamentId;
  final String name;
  final String emoji;
  final String description;
  final List<String> unlockedBy;
  final int rarity;

  const TournamentBadge({
    required this.id,
    required this.tournamentId,
    required this.name, // "Champion", "Finalist", "Undefeated"
    required this.emoji,
    required this.description,
    required this.unlockedBy, // userIds who earned it
    required this.rarity, // 1-5, higher = rarer
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tournamentId': tournamentId,
        'name': name,
        'emoji': emoji,
        'description': description,
        'unlockedBy': unlockedBy,
        'rarity': rarity,
      };

  factory TournamentBadge.fromJson(Map<String, dynamic> json) {
    return TournamentBadge(
      id: json['id'] as String,
      tournamentId: json['tournamentId'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      description: json['description'] as String,
      unlockedBy: _stringList(json['unlockedBy']),
      rarity: json['rarity'] as int,
    );
  }
}

/// Highlight moment in tournament
class TournamentHighlight {
  final String id;
  final String tournamentId;
  final String matchId;
  final String title;
  final String description;
  final DateTime timestamp;
  final String videoUrl;
  final int views;
  final List<String> playerIds;
  final String type;

  const TournamentHighlight({
    required this.id,
    required this.tournamentId,
    required this.matchId,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.videoUrl,
    required this.views,
    required this.playerIds,
    this.type = '', // epic, upset, comeback, etc
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tournamentId': tournamentId,
        'matchId': matchId,
        'title': title,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'videoUrl': videoUrl,
        'views': views,
        'playerIds': playerIds,
        'type': type,
      };

  factory TournamentHighlight.fromJson(Map<String, dynamic> json) {
    return TournamentHighlight(
      id: json['id'] as String,
      tournamentId: json['tournamentId'] as String,
      matchId: json['matchId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: _parseDateTime(json['timestamp']),
      videoUrl: json['videoUrl'] as String,
      views: json['views'] as int,
      playerIds: _stringList(json['playerIds']),
      type: json['type'] as String? ?? '',
    );
  }
}

/// Tournament invitation to player
class TournamentInvitation {
  final String id;
  final String tournamentId;
  final String invitedUserId;
  final String invitedByUserId;
  final String tournamentName;
  final DateTime invitedAt;
  final DateTime? respondedAt;
  final String status;

  const TournamentInvitation({
    required this.id,
    required this.tournamentId,
    required this.invitedUserId,
    required this.invitedByUserId,
    required this.tournamentName,
    required this.invitedAt,
    this.respondedAt,
    this.status = 'pending', // pending, accepted, declined
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tournamentId': tournamentId,
        'invitedUserId': invitedUserId,
        'invitedByUserId': invitedByUserId,
        'tournamentName': tournamentName,
        'invitedAt': invitedAt.toIso8601String(),
        'respondedAt': respondedAt?.toIso8601String(),
        'status': status,
      };

  factory TournamentInvitation.fromJson(Map<String, dynamic> json) {
    return TournamentInvitation(
      id: json['id'] as String,
      tournamentId: json['tournamentId'] as String,
      invitedUserId: json['invitedUserId'] as String,
      invitedByUserId: json['invitedByUserId'] as String,
      tournamentName: json['tournamentName'] as String,
      invitedAt: _parseDateTime(json['invitedAt']),
      respondedAt: _parseDateTimeOrNull(json['respondedAt']),
      status: json['status'] as String? ?? 'pending',
    );
  }
}
