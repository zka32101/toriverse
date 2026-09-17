import 'package:freezed_annotation/freezed_annotation.dart';

/// Live match viewing session
class LiveMatchSession {
  const LiveMatchSession({
    required String id,
    required String matchId,
    required String tournamentId,
    List<String> playerIds,
    String currentPlayerTurn,
    int roundNumber,
    int timeRemainingSeconds,
    String status, // waiting, playing, paused, finished
    required DateTime startedAt,
    DateTime? finishedAt,
    int liveViewerCount,
    int totalViewsToday,
    List<SpectatorAction> recentActions,
  });
}

/// Real-time board state for spectators
class LiveBoardState {
  const LiveBoardState({
    required String matchId,
    required List<int> boardState, // 8x8 = 64 cells (0=empty, 1=black, 2=white, 3=red)
    List<String> blackPieces,
    List<String> whitePieces,
    List<String> redPieces,
    int blackScore,
    int whiteScore,
    int redScore,
    int lastMovePosition, // Position of last move for highlight
    bool isSimultaneousReveal, // For simultaneous move reveal
    DateTime? lastUpdateAt,
  });
}

/// Spectator action/interaction
class SpectatorAction {
  const SpectatorAction({
    required String id,
    required String viewerId,
    required String actionType, // comment, prediction, reaction, chat
    required String content,
    DateTime? createdAt,
    int likes,
    List<String> likedBy,
  });
}

/// Live viewer participation record
class LiveViewer {
  const LiveViewer({
    required String id,
    required String matchId,
    required String viewerId,
    required String displayName,
    DateTime? joinedAt,
    DateTime? leftAt,
    int watchDurationSeconds,
    List<String> predictions,
    int correctPredictions,
    bool isPremium,
    bool isStreaming,
  });
}

/// Live match interaction (chat, reactions, predictions)
class MatchInteraction {
  const MatchInteraction({
    required String id,
    required String matchId,
    required String userId,
    required String userDisplayName,
    required String type, // chat, prediction, reaction, highlight
    required String content,
    int timestamp, // seconds into match
    DateTime? createdAt,
    int reactionCount,
    List<String> likedBy,
    bool isPinned, // For important predictions/moments
  });
}

/// Live prediction during match
class LivePrediction {
  const LivePrediction({
    required String id,
    required String matchId,
    required String viewerId,
    required String predictType, // winner, nextMove, finalScore
    required String prediction,
    int confidenceScore, // 0-100
    DateTime? createdAt,
    bool isCorrect,
    int pointsAwarded,
    DateTime? resolvedAt,
  });
}

/// Live spectator reward for watching
class LiveSpectatorReward {
  const LiveSpectatorReward({
    required String id,
    required String matchId,
    required String viewerId,
    int basePointsEarned, // 1 point per minute watched
    int predictionBonusPoints, // From correct predictions
    int engagementBonusPoints, // From comments/reactions
    int premiumBonusPoints, // 50% premium multiplier
    int totalPointsEarned,
    DateTime? claimedAt,
  });
}

/// Spectator leaderboard entry (during live match)
class LiveLeaderboardEntry {
  const LiveLeaderboardEntry({
    required String rank,
    required String viewerId,
    required String displayName,
    int pointsEarned,
    int correctPredictions,
    int engagementScore, // Comments + reactions
    bool isPremium,
  });
}

/// Highlight moment during live match
class MatchHighlightMoment {
  const MatchHighlightMoment({
    required String id,
    required String matchId,
    required int timestamp, // seconds into match
    required String momentType, // upset, strategic_move, key_turn, final_reversal
    required String description,
    int viewerReactions, // Emoji/reaction count
    bool isFeatured, // Highlighted by organizer
    DateTime? markedAt,
  });
}

/// Live chat message (for match discussion)
class LiveChatMessage {
  const LiveChatMessage({
    required String id,
    required String matchId,
    required String userId,
    required String displayName,
    required String message,
    DateTime? createdAt,
    int likes,
    List<String> likedBy,
    bool isModerator,
    bool isPinned,
  });
}

/// Stream info for live spectating
class MatchStreamInfo {
  const MatchStreamInfo({
    required String matchId,
    required String streamUrl, // HLS/DASH stream
    String streamTitle,
    String streamerName,
    String streamerChannel, // Twitch/YouTube URL
    bool isOfficialStream,
    int totalViewers,
    int peakViewers,
    DateTime? startedAt,
  });
}

/// Live match viewer statistics
class LiveMatchStats {
  const LiveMatchStats({
    required String matchId,
    int currentViewerCount,
    int peakViewerCount,
    int totalWatchMinutes,
    int totalPredictions,
    int correctPredictions,
    double avgPredictionAccuracy, // percentage
    int totalChatMessages,
    int totalHighlights,
    int totalPointsDistributed,
  });
}

/// Spectator engagement metrics
class SpectatorEngagement {
  const SpectatorEngagement({
    required String viewerId,
    required String matchId,
    int watchDurationSeconds,
    int commentsPosted,
    int predictionsPlaced,
    int correctPredictions,
    int reactionsGiven,
    int engagementScore, // Weighted score
    bool completedMatch, // Watched until end
  });
}
