
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

/// Live match viewing session
class LiveMatchSession {
  final String id;
  final String matchId;
  final String tournamentId;
  final List<String> playerIds;
  final String currentPlayerTurn;
  final int roundNumber;
  final int timeRemainingSeconds;
  final String status; // waiting, playing, paused, finished
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int liveViewerCount;
  final int totalViewsToday;
  final List<SpectatorAction> recentActions;

  const LiveMatchSession({
    required this.id,
    required this.matchId,
    required this.tournamentId,
    this.playerIds = const [],
    this.currentPlayerTurn = '',
    this.roundNumber = 0,
    this.timeRemainingSeconds = 0,
    this.status = 'waiting',
    required this.startedAt,
    this.finishedAt,
    this.liveViewerCount = 0,
    this.totalViewsToday = 0,
    this.recentActions = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'matchId': matchId,
        'tournamentId': tournamentId,
        'playerIds': playerIds,
        'currentPlayerTurn': currentPlayerTurn,
        'roundNumber': roundNumber,
        'timeRemainingSeconds': timeRemainingSeconds,
        'status': status,
        'startedAt': startedAt.toIso8601String(),
        'finishedAt': finishedAt?.toIso8601String(),
        'liveViewerCount': liveViewerCount,
        'totalViewsToday': totalViewsToday,
        'recentActions': recentActions.map((e) => e.toJson()).toList(),
      };

  factory LiveMatchSession.fromJson(Map<String, dynamic> json) {
    return LiveMatchSession(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      tournamentId: json['tournamentId'] as String,
      playerIds: _stringList(json['playerIds']),
      currentPlayerTurn: json['currentPlayerTurn'] as String? ?? '',
      roundNumber: json['roundNumber'] as int? ?? 0,
      timeRemainingSeconds: json['timeRemainingSeconds'] as int? ?? 0,
      status: json['status'] as String? ?? 'waiting',
      startedAt: _parseDateTime(json['startedAt']),
      finishedAt: _parseDateTimeOrNull(json['finishedAt']),
      liveViewerCount: json['liveViewerCount'] as int? ?? 0,
      totalViewsToday: json['totalViewsToday'] as int? ?? 0,
      recentActions: (json['recentActions'] as List<dynamic>?)
              ?.map((e) => SpectatorAction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  LiveMatchSession copyWith({
    String? id,
    String? matchId,
    String? tournamentId,
    List<String>? playerIds,
    String? currentPlayerTurn,
    int? roundNumber,
    int? timeRemainingSeconds,
    String? status,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? liveViewerCount,
    int? totalViewsToday,
    List<SpectatorAction>? recentActions,
  }) {
    return LiveMatchSession(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      tournamentId: tournamentId ?? this.tournamentId,
      playerIds: playerIds ?? this.playerIds,
      currentPlayerTurn: currentPlayerTurn ?? this.currentPlayerTurn,
      roundNumber: roundNumber ?? this.roundNumber,
      timeRemainingSeconds: timeRemainingSeconds ?? this.timeRemainingSeconds,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      liveViewerCount: liveViewerCount ?? this.liveViewerCount,
      totalViewsToday: totalViewsToday ?? this.totalViewsToday,
      recentActions: recentActions ?? this.recentActions,
    );
  }
}

/// Real-time board state for spectators
class LiveBoardState {
  final String matchId;
  final List<int> boardState; // 8x8 = 64 cells (0=empty, 1=black, 2=white, 3=red)
  final List<String> blackPieces;
  final List<String> whitePieces;
  final List<String> redPieces;
  final int blackScore;
  final int whiteScore;
  final int redScore;
  final int lastMovePosition; // Position of last move for highlight
  final bool isSimultaneousReveal; // For simultaneous move reveal
  final DateTime? lastUpdateAt;

  const LiveBoardState({
    required this.matchId,
    required this.boardState,
    this.blackPieces = const [],
    this.whitePieces = const [],
    this.redPieces = const [],
    this.blackScore = 0,
    this.whiteScore = 0,
    this.redScore = 0,
    this.lastMovePosition = -1,
    this.isSimultaneousReveal = false,
    this.lastUpdateAt,
  });

  Map<String, dynamic> toJson() => {
        'matchId': matchId,
        'boardState': boardState,
        'blackPieces': blackPieces,
        'whitePieces': whitePieces,
        'redPieces': redPieces,
        'blackScore': blackScore,
        'whiteScore': whiteScore,
        'redScore': redScore,
        'lastMovePosition': lastMovePosition,
        'isSimultaneousReveal': isSimultaneousReveal,
        'lastUpdateAt': lastUpdateAt?.toIso8601String(),
      };

  factory LiveBoardState.fromJson(Map<String, dynamic> json) {
    return LiveBoardState(
      matchId: json['matchId'] as String,
      boardState:
          (json['boardState'] as List<dynamic>).map((e) => e as int).toList(),
      blackPieces: _stringList(json['blackPieces']),
      whitePieces: _stringList(json['whitePieces']),
      redPieces: _stringList(json['redPieces']),
      blackScore: json['blackScore'] as int? ?? 0,
      whiteScore: json['whiteScore'] as int? ?? 0,
      redScore: json['redScore'] as int? ?? 0,
      lastMovePosition: json['lastMovePosition'] as int? ?? -1,
      isSimultaneousReveal: json['isSimultaneousReveal'] as bool? ?? false,
      lastUpdateAt: _parseDateTimeOrNull(json['lastUpdateAt']),
    );
  }
}

/// Spectator action/interaction
class SpectatorAction {
  final String id;
  final String viewerId;
  final String actionType; // comment, prediction, reaction, chat
  final String content;
  final DateTime? createdAt;
  final int likes;
  final List<String> likedBy;

  const SpectatorAction({
    required this.id,
    required this.viewerId,
    required this.actionType,
    required this.content,
    this.createdAt,
    this.likes = 0,
    this.likedBy = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'viewerId': viewerId,
        'actionType': actionType,
        'content': content,
        'createdAt': createdAt?.toIso8601String(),
        'likes': likes,
        'likedBy': likedBy,
      };

  factory SpectatorAction.fromJson(Map<String, dynamic> json) {
    return SpectatorAction(
      id: json['id'] as String,
      viewerId: json['viewerId'] as String,
      actionType: json['actionType'] as String,
      content: json['content'] as String,
      createdAt: _parseDateTimeOrNull(json['createdAt']),
      likes: json['likes'] as int? ?? 0,
      likedBy: _stringList(json['likedBy']),
    );
  }
}

/// Live viewer participation record
class LiveViewer {
  final String id;
  final String matchId;
  final String viewerId;
  final String displayName;
  final DateTime? joinedAt;
  final DateTime? leftAt;
  final int watchDurationSeconds;
  final List<String> predictions;
  final int correctPredictions;
  final bool isPremium;
  final bool isStreaming;

  const LiveViewer({
    required this.id,
    required this.matchId,
    required this.viewerId,
    required this.displayName,
    this.joinedAt,
    this.leftAt,
    this.watchDurationSeconds = 0,
    this.predictions = const [],
    this.correctPredictions = 0,
    this.isPremium = false,
    this.isStreaming = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'matchId': matchId,
        'viewerId': viewerId,
        'displayName': displayName,
        'joinedAt': joinedAt?.toIso8601String(),
        'leftAt': leftAt?.toIso8601String(),
        'watchDurationSeconds': watchDurationSeconds,
        'predictions': predictions,
        'correctPredictions': correctPredictions,
        'isPremium': isPremium,
        'isStreaming': isStreaming,
      };

  factory LiveViewer.fromJson(Map<String, dynamic> json) {
    return LiveViewer(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      viewerId: json['viewerId'] as String,
      displayName: json['displayName'] as String,
      joinedAt: _parseDateTimeOrNull(json['joinedAt']),
      leftAt: _parseDateTimeOrNull(json['leftAt']),
      watchDurationSeconds: json['watchDurationSeconds'] as int? ?? 0,
      predictions: _stringList(json['predictions']),
      correctPredictions: json['correctPredictions'] as int? ?? 0,
      isPremium: json['isPremium'] as bool? ?? false,
      isStreaming: json['isStreaming'] as bool? ?? false,
    );
  }

  LiveViewer copyWith({
    String? id,
    String? matchId,
    String? viewerId,
    String? displayName,
    DateTime? joinedAt,
    DateTime? leftAt,
    int? watchDurationSeconds,
    List<String>? predictions,
    int? correctPredictions,
    bool? isPremium,
    bool? isStreaming,
  }) {
    return LiveViewer(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      viewerId: viewerId ?? this.viewerId,
      displayName: displayName ?? this.displayName,
      joinedAt: joinedAt ?? this.joinedAt,
      leftAt: leftAt ?? this.leftAt,
      watchDurationSeconds: watchDurationSeconds ?? this.watchDurationSeconds,
      predictions: predictions ?? this.predictions,
      correctPredictions: correctPredictions ?? this.correctPredictions,
      isPremium: isPremium ?? this.isPremium,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}

/// Live match interaction (chat, reactions, predictions)
class MatchInteraction {
  final String id;
  final String matchId;
  final String userId;
  final String userDisplayName;
  final String type; // chat, prediction, reaction, highlight
  final String content;
  final int timestamp; // seconds into match
  final DateTime? createdAt;
  final int reactionCount;
  final List<String> likedBy;
  final bool isPinned; // For important predictions/moments

  const MatchInteraction({
    required this.id,
    required this.matchId,
    required this.userId,
    required this.userDisplayName,
    required this.type,
    required this.content,
    this.timestamp = 0,
    this.createdAt,
    this.reactionCount = 0,
    this.likedBy = const [],
    this.isPinned = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'matchId': matchId,
        'userId': userId,
        'userDisplayName': userDisplayName,
        'type': type,
        'content': content,
        'timestamp': timestamp,
        'createdAt': createdAt?.toIso8601String(),
        'reactionCount': reactionCount,
        'likedBy': likedBy,
        'isPinned': isPinned,
      };

  factory MatchInteraction.fromJson(Map<String, dynamic> json) {
    return MatchInteraction(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      userId: json['userId'] as String,
      userDisplayName: json['userDisplayName'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      timestamp: json['timestamp'] as int? ?? 0,
      createdAt: _parseDateTimeOrNull(json['createdAt']),
      reactionCount: json['reactionCount'] as int? ?? 0,
      likedBy: _stringList(json['likedBy']),
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }
}

/// Live prediction during match
class LivePrediction {
  final String id;
  final String matchId;
  final String viewerId;
  final String predictType; // winner, nextMove, finalScore
  final String prediction;
  final int confidenceScore; // 0-100
  final DateTime? createdAt;
  final bool isCorrect;
  final int pointsAwarded;
  final DateTime? resolvedAt;

  const LivePrediction({
    required this.id,
    required this.matchId,
    required this.viewerId,
    required this.predictType,
    required this.prediction,
    this.confidenceScore = 0,
    this.createdAt,
    this.isCorrect = false,
    this.pointsAwarded = 0,
    this.resolvedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'matchId': matchId,
        'viewerId': viewerId,
        'predictType': predictType,
        'prediction': prediction,
        'confidenceScore': confidenceScore,
        'createdAt': createdAt?.toIso8601String(),
        'isCorrect': isCorrect,
        'pointsAwarded': pointsAwarded,
        'resolvedAt': resolvedAt?.toIso8601String(),
      };

  factory LivePrediction.fromJson(Map<String, dynamic> json) {
    return LivePrediction(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      viewerId: json['viewerId'] as String,
      predictType: json['predictType'] as String,
      prediction: json['prediction'] as String,
      confidenceScore: json['confidenceScore'] as int? ?? 0,
      createdAt: _parseDateTimeOrNull(json['createdAt']),
      isCorrect: json['isCorrect'] as bool? ?? false,
      pointsAwarded: json['pointsAwarded'] as int? ?? 0,
      resolvedAt: _parseDateTimeOrNull(json['resolvedAt']),
    );
  }

  LivePrediction copyWith({
    String? id,
    String? matchId,
    String? viewerId,
    String? predictType,
    String? prediction,
    int? confidenceScore,
    DateTime? createdAt,
    bool? isCorrect,
    int? pointsAwarded,
    DateTime? resolvedAt,
  }) {
    return LivePrediction(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      viewerId: viewerId ?? this.viewerId,
      predictType: predictType ?? this.predictType,
      prediction: prediction ?? this.prediction,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      createdAt: createdAt ?? this.createdAt,
      isCorrect: isCorrect ?? this.isCorrect,
      pointsAwarded: pointsAwarded ?? this.pointsAwarded,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}

/// Live spectator reward for watching
class LiveSpectatorReward {
  final String id;
  final String matchId;
  final String viewerId;
  final int basePointsEarned; // 1 point per minute watched
  final int predictionBonusPoints; // From correct predictions
  final int engagementBonusPoints; // From comments/reactions
  final int premiumBonusPoints; // 50% premium multiplier
  final int totalPointsEarned;
  final DateTime? claimedAt;

  const LiveSpectatorReward({
    required this.id,
    required this.matchId,
    required this.viewerId,
    this.basePointsEarned = 0,
    this.predictionBonusPoints = 0,
    this.engagementBonusPoints = 0,
    this.premiumBonusPoints = 0,
    this.totalPointsEarned = 0,
    this.claimedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'matchId': matchId,
        'viewerId': viewerId,
        'basePointsEarned': basePointsEarned,
        'predictionBonusPoints': predictionBonusPoints,
        'engagementBonusPoints': engagementBonusPoints,
        'premiumBonusPoints': premiumBonusPoints,
        'totalPointsEarned': totalPointsEarned,
        'claimedAt': claimedAt?.toIso8601String(),
      };

  factory LiveSpectatorReward.fromJson(Map<String, dynamic> json) {
    return LiveSpectatorReward(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      viewerId: json['viewerId'] as String,
      basePointsEarned: json['basePointsEarned'] as int? ?? 0,
      predictionBonusPoints: json['predictionBonusPoints'] as int? ?? 0,
      engagementBonusPoints: json['engagementBonusPoints'] as int? ?? 0,
      premiumBonusPoints: json['premiumBonusPoints'] as int? ?? 0,
      totalPointsEarned: json['totalPointsEarned'] as int? ?? 0,
      claimedAt: _parseDateTimeOrNull(json['claimedAt']),
    );
  }

  LiveSpectatorReward copyWith({
    String? id,
    String? matchId,
    String? viewerId,
    int? basePointsEarned,
    int? predictionBonusPoints,
    int? engagementBonusPoints,
    int? premiumBonusPoints,
    int? totalPointsEarned,
    DateTime? claimedAt,
  }) {
    return LiveSpectatorReward(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      viewerId: viewerId ?? this.viewerId,
      basePointsEarned: basePointsEarned ?? this.basePointsEarned,
      predictionBonusPoints:
          predictionBonusPoints ?? this.predictionBonusPoints,
      engagementBonusPoints:
          engagementBonusPoints ?? this.engagementBonusPoints,
      premiumBonusPoints: premiumBonusPoints ?? this.premiumBonusPoints,
      totalPointsEarned: totalPointsEarned ?? this.totalPointsEarned,
      claimedAt: claimedAt ?? this.claimedAt,
    );
  }
}

/// Spectator leaderboard entry (during live match)
class LiveLeaderboardEntry {
  final String rank;
  final String viewerId;
  final String displayName;
  final int pointsEarned;
  final int correctPredictions;
  final int engagementScore; // Comments + reactions
  final bool isPremium;

  const LiveLeaderboardEntry({
    required this.rank,
    required this.viewerId,
    required this.displayName,
    this.pointsEarned = 0,
    this.correctPredictions = 0,
    this.engagementScore = 0,
    this.isPremium = false,
  });

  Map<String, dynamic> toJson() => {
        'rank': rank,
        'viewerId': viewerId,
        'displayName': displayName,
        'pointsEarned': pointsEarned,
        'correctPredictions': correctPredictions,
        'engagementScore': engagementScore,
        'isPremium': isPremium,
      };

  factory LiveLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LiveLeaderboardEntry(
      rank: json['rank'] as String,
      viewerId: json['viewerId'] as String,
      displayName: json['displayName'] as String,
      pointsEarned: json['pointsEarned'] as int? ?? 0,
      correctPredictions: json['correctPredictions'] as int? ?? 0,
      engagementScore: json['engagementScore'] as int? ?? 0,
      isPremium: json['isPremium'] as bool? ?? false,
    );
  }
}

/// Highlight moment during live match
class MatchHighlightMoment {
  final String id;
  final String matchId;
  final int timestamp; // seconds into match
  final String momentType; // upset, strategic_move, key_turn, final_reversal
  final String description;
  final int viewerReactions; // Emoji/reaction count
  final bool isFeatured; // Highlighted by organizer
  final DateTime? markedAt;

  const MatchHighlightMoment({
    required this.id,
    required this.matchId,
    required this.timestamp,
    required this.momentType,
    required this.description,
    this.viewerReactions = 0,
    this.isFeatured = false,
    this.markedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'matchId': matchId,
        'timestamp': timestamp,
        'momentType': momentType,
        'description': description,
        'viewerReactions': viewerReactions,
        'isFeatured': isFeatured,
        'markedAt': markedAt?.toIso8601String(),
      };

  factory MatchHighlightMoment.fromJson(Map<String, dynamic> json) {
    return MatchHighlightMoment(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      timestamp: json['timestamp'] as int,
      momentType: json['momentType'] as String,
      description: json['description'] as String,
      viewerReactions: json['viewerReactions'] as int? ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      markedAt: _parseDateTimeOrNull(json['markedAt']),
    );
  }

  MatchHighlightMoment copyWith({
    String? id,
    String? matchId,
    int? timestamp,
    String? momentType,
    String? description,
    int? viewerReactions,
    bool? isFeatured,
    DateTime? markedAt,
  }) {
    return MatchHighlightMoment(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      timestamp: timestamp ?? this.timestamp,
      momentType: momentType ?? this.momentType,
      description: description ?? this.description,
      viewerReactions: viewerReactions ?? this.viewerReactions,
      isFeatured: isFeatured ?? this.isFeatured,
      markedAt: markedAt ?? this.markedAt,
    );
  }
}

/// Live chat message (for match discussion)
class LiveChatMessage {
  final String id;
  final String matchId;
  final String userId;
  final String displayName;
  final String message;
  final DateTime? createdAt;
  final int likes;
  final List<String> likedBy;
  final bool isModerator;
  final bool isPinned;

  const LiveChatMessage({
    required this.id,
    required this.matchId,
    required this.userId,
    required this.displayName,
    required this.message,
    this.createdAt,
    this.likes = 0,
    this.likedBy = const [],
    this.isModerator = false,
    this.isPinned = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'matchId': matchId,
        'userId': userId,
        'displayName': displayName,
        'message': message,
        'createdAt': createdAt?.toIso8601String(),
        'likes': likes,
        'likedBy': likedBy,
        'isModerator': isModerator,
        'isPinned': isPinned,
      };

  factory LiveChatMessage.fromJson(Map<String, dynamic> json) {
    return LiveChatMessage(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      message: json['message'] as String,
      createdAt: _parseDateTimeOrNull(json['createdAt']),
      likes: json['likes'] as int? ?? 0,
      likedBy: _stringList(json['likedBy']),
      isModerator: json['isModerator'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }

  LiveChatMessage copyWith({
    String? id,
    String? matchId,
    String? userId,
    String? displayName,
    String? message,
    DateTime? createdAt,
    int? likes,
    List<String>? likedBy,
    bool? isModerator,
    bool? isPinned,
  }) {
    return LiveChatMessage(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      isModerator: isModerator ?? this.isModerator,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}

/// Stream info for live spectating
class MatchStreamInfo {
  final String matchId;
  final String streamUrl; // HLS/DASH stream
  final String streamTitle;
  final String streamerName;
  final String streamerChannel; // Twitch/YouTube URL
  final bool isOfficialStream;
  final int totalViewers;
  final int peakViewers;
  final DateTime? startedAt;

  const MatchStreamInfo({
    required this.matchId,
    required this.streamUrl,
    this.streamTitle = '',
    this.streamerName = '',
    this.streamerChannel = '',
    this.isOfficialStream = false,
    this.totalViewers = 0,
    this.peakViewers = 0,
    this.startedAt,
  });

  Map<String, dynamic> toJson() => {
        'matchId': matchId,
        'streamUrl': streamUrl,
        'streamTitle': streamTitle,
        'streamerName': streamerName,
        'streamerChannel': streamerChannel,
        'isOfficialStream': isOfficialStream,
        'totalViewers': totalViewers,
        'peakViewers': peakViewers,
        'startedAt': startedAt?.toIso8601String(),
      };

  factory MatchStreamInfo.fromJson(Map<String, dynamic> json) {
    return MatchStreamInfo(
      matchId: json['matchId'] as String,
      streamUrl: json['streamUrl'] as String,
      streamTitle: json['streamTitle'] as String? ?? '',
      streamerName: json['streamerName'] as String? ?? '',
      streamerChannel: json['streamerChannel'] as String? ?? '',
      isOfficialStream: json['isOfficialStream'] as bool? ?? false,
      totalViewers: json['totalViewers'] as int? ?? 0,
      peakViewers: json['peakViewers'] as int? ?? 0,
      startedAt: _parseDateTimeOrNull(json['startedAt']),
    );
  }
}

/// Live match viewer statistics
class LiveMatchStats {
  final String matchId;
  final int currentViewerCount;
  final int peakViewerCount;
  final int totalWatchMinutes;
  final int totalPredictions;
  final int correctPredictions;
  final double avgPredictionAccuracy; // percentage
  final int totalChatMessages;
  final int totalHighlights;
  final int totalPointsDistributed;

  const LiveMatchStats({
    required this.matchId,
    this.currentViewerCount = 0,
    this.peakViewerCount = 0,
    this.totalWatchMinutes = 0,
    this.totalPredictions = 0,
    this.correctPredictions = 0,
    this.avgPredictionAccuracy = 0.0,
    this.totalChatMessages = 0,
    this.totalHighlights = 0,
    this.totalPointsDistributed = 0,
  });

  Map<String, dynamic> toJson() => {
        'matchId': matchId,
        'currentViewerCount': currentViewerCount,
        'peakViewerCount': peakViewerCount,
        'totalWatchMinutes': totalWatchMinutes,
        'totalPredictions': totalPredictions,
        'correctPredictions': correctPredictions,
        'avgPredictionAccuracy': avgPredictionAccuracy,
        'totalChatMessages': totalChatMessages,
        'totalHighlights': totalHighlights,
        'totalPointsDistributed': totalPointsDistributed,
      };

  factory LiveMatchStats.fromJson(Map<String, dynamic> json) {
    return LiveMatchStats(
      matchId: json['matchId'] as String,
      currentViewerCount: json['currentViewerCount'] as int? ?? 0,
      peakViewerCount: json['peakViewerCount'] as int? ?? 0,
      totalWatchMinutes: json['totalWatchMinutes'] as int? ?? 0,
      totalPredictions: json['totalPredictions'] as int? ?? 0,
      correctPredictions: json['correctPredictions'] as int? ?? 0,
      avgPredictionAccuracy:
          (json['avgPredictionAccuracy'] as num?)?.toDouble() ?? 0.0,
      totalChatMessages: json['totalChatMessages'] as int? ?? 0,
      totalHighlights: json['totalHighlights'] as int? ?? 0,
      totalPointsDistributed: json['totalPointsDistributed'] as int? ?? 0,
    );
  }

  LiveMatchStats copyWith({
    String? matchId,
    int? currentViewerCount,
    int? peakViewerCount,
    int? totalWatchMinutes,
    int? totalPredictions,
    int? correctPredictions,
    double? avgPredictionAccuracy,
    int? totalChatMessages,
    int? totalHighlights,
    int? totalPointsDistributed,
  }) {
    return LiveMatchStats(
      matchId: matchId ?? this.matchId,
      currentViewerCount: currentViewerCount ?? this.currentViewerCount,
      peakViewerCount: peakViewerCount ?? this.peakViewerCount,
      totalWatchMinutes: totalWatchMinutes ?? this.totalWatchMinutes,
      totalPredictions: totalPredictions ?? this.totalPredictions,
      correctPredictions: correctPredictions ?? this.correctPredictions,
      avgPredictionAccuracy:
          avgPredictionAccuracy ?? this.avgPredictionAccuracy,
      totalChatMessages: totalChatMessages ?? this.totalChatMessages,
      totalHighlights: totalHighlights ?? this.totalHighlights,
      totalPointsDistributed:
          totalPointsDistributed ?? this.totalPointsDistributed,
    );
  }
}

/// Spectator engagement metrics
class SpectatorEngagement {
  final String viewerId;
  final String matchId;
  final int watchDurationSeconds;
  final int commentsPosted;
  final int predictionsPlaced;
  final int correctPredictions;
  final int reactionsGiven;
  final int engagementScore; // Weighted score
  final bool completedMatch; // Watched until end

  const SpectatorEngagement({
    required this.viewerId,
    required this.matchId,
    this.watchDurationSeconds = 0,
    this.commentsPosted = 0,
    this.predictionsPlaced = 0,
    this.correctPredictions = 0,
    this.reactionsGiven = 0,
    this.engagementScore = 0,
    this.completedMatch = false,
  });

  Map<String, dynamic> toJson() => {
        'viewerId': viewerId,
        'matchId': matchId,
        'watchDurationSeconds': watchDurationSeconds,
        'commentsPosted': commentsPosted,
        'predictionsPlaced': predictionsPlaced,
        'correctPredictions': correctPredictions,
        'reactionsGiven': reactionsGiven,
        'engagementScore': engagementScore,
        'completedMatch': completedMatch,
      };

  factory SpectatorEngagement.fromJson(Map<String, dynamic> json) {
    return SpectatorEngagement(
      viewerId: json['viewerId'] as String,
      matchId: json['matchId'] as String,
      watchDurationSeconds: json['watchDurationSeconds'] as int? ?? 0,
      commentsPosted: json['commentsPosted'] as int? ?? 0,
      predictionsPlaced: json['predictionsPlaced'] as int? ?? 0,
      correctPredictions: json['correctPredictions'] as int? ?? 0,
      reactionsGiven: json['reactionsGiven'] as int? ?? 0,
      engagementScore: json['engagementScore'] as int? ?? 0,
      completedMatch: json['completedMatch'] as bool? ?? false,
    );
  }

  SpectatorEngagement copyWith({
    String? viewerId,
    String? matchId,
    int? watchDurationSeconds,
    int? commentsPosted,
    int? predictionsPlaced,
    int? correctPredictions,
    int? reactionsGiven,
    int? engagementScore,
    bool? completedMatch,
  }) {
    return SpectatorEngagement(
      viewerId: viewerId ?? this.viewerId,
      matchId: matchId ?? this.matchId,
      watchDurationSeconds: watchDurationSeconds ?? this.watchDurationSeconds,
      commentsPosted: commentsPosted ?? this.commentsPosted,
      predictionsPlaced: predictionsPlaced ?? this.predictionsPlaced,
      correctPredictions: correctPredictions ?? this.correctPredictions,
      reactionsGiven: reactionsGiven ?? this.reactionsGiven,
      engagementScore: engagementScore ?? this.engagementScore,
      completedMatch: completedMatch ?? this.completedMatch,
    );
  }
}
