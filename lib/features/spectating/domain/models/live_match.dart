import 'package:freezed_annotation/freezed_annotation.dart';

part 'live_match.freezed.dart';
part 'live_match.g.dart';

/// Live match viewing session
@freezed
class LiveMatchSession with _$LiveMatchSession {
  const factory LiveMatchSession({
    required String id,
    required String matchId,
    required String tournamentId,
    @Default([]) List<String> playerIds,
    @Default('') String currentPlayerTurn,
    @Default(0) int roundNumber,
    @Default(0) int timeRemainingSeconds,
    @Default('waiting') String status, // waiting, playing, paused, finished
    required DateTime startedAt,
    DateTime? finishedAt,
    @Default(0) int liveViewerCount,
    @Default(0) int totalViewsToday,
    @Default([]) List<SpectatorAction> recentActions,
  }) = _LiveMatchSession;

  factory LiveMatchSession.fromJson(Map<String, dynamic> json) =>
      _$LiveMatchSessionFromJson(json);
}

/// Real-time board state for spectators
@freezed
class LiveBoardState with _$LiveBoardState {
  const factory LiveBoardState({
    required String matchId,
    required List<int> boardState, // 8x8 = 64 cells (0=empty, 1=black, 2=white, 3=red)
    @Default([]) List<String> blackPieces,
    @Default([]) List<String> whitePieces,
    @Default([]) List<String> redPieces,
    @Default(0) int blackScore,
    @Default(0) int whiteScore,
    @Default(0) int redScore,
    @Default(-1) int lastMovePosition, // Position of last move for highlight
    @Default(false) bool isSimultaneousReveal, // For simultaneous move reveal
    @Default(null) DateTime? lastUpdateAt,
  }) = _LiveBoardState;

  factory LiveBoardState.fromJson(Map<String, dynamic> json) =>
      _$LiveBoardStateFromJson(json);
}

/// Spectator action/interaction
@freezed
class SpectatorAction with _$SpectatorAction {
  const factory SpectatorAction({
    required String id,
    required String viewerId,
    required String actionType, // comment, prediction, reaction, chat
    required String content,
    @Default(null) DateTime? createdAt,
    @Default(0) int likes,
    @Default([]) List<String> likedBy,
  }) = _SpectatorAction;

  factory SpectatorAction.fromJson(Map<String, dynamic> json) =>
      _$SpectatorActionFromJson(json);
}

/// Live viewer participation record
@freezed
class LiveViewer with _$LiveViewer {
  const factory LiveViewer({
    required String id,
    required String matchId,
    required String viewerId,
    required String displayName,
    @Default(null) DateTime? joinedAt,
    @Default(null) DateTime? leftAt,
    @Default(0) int watchDurationSeconds,
    @Default([]) List<String> predictions,
    @Default(0) int correctPredictions,
    @Default(false) bool isPremium,
    @Default(false) bool isStreaming,
  }) = _LiveViewer;

  factory LiveViewer.fromJson(Map<String, dynamic> json) =>
      _$LiveViewerFromJson(json);
}

/// Live match interaction (chat, reactions, predictions)
@freezed
class MatchInteraction with _$MatchInteraction {
  const factory MatchInteraction({
    required String id,
    required String matchId,
    required String userId,
    required String userDisplayName,
    required String type, // chat, prediction, reaction, highlight
    required String content,
    @Default(0) int timestamp, // seconds into match
    @Default(null) DateTime? createdAt,
    @Default(0) int reactionCount,
    @Default([]) List<String> likedBy,
    @Default(false) bool isPinned, // For important predictions/moments
  }) = _MatchInteraction;

  factory MatchInteraction.fromJson(Map<String, dynamic> json) =>
      _$MatchInteractionFromJson(json);
}

/// Live prediction during match
@freezed
class LivePrediction with _$LivePrediction {
  const factory LivePrediction({
    required String id,
    required String matchId,
    required String viewerId,
    required String predictType, // winner, nextMove, finalScore
    required String prediction,
    @Default(100) int confidenceScore, // 0-100
    @Default(null) DateTime? createdAt,
    @Default(false) bool isCorrect,
    @Default(0) int pointsAwarded,
    @Default(null) DateTime? resolvedAt,
  }) = _LivePrediction;

  factory LivePrediction.fromJson(Map<String, dynamic> json) =>
      _$LivePredictionFromJson(json);
}

/// Live spectator reward for watching
@freezed
class LiveSpectatorReward with _$LiveSpectatorReward {
  const factory LiveSpectatorReward({
    required String id,
    required String matchId,
    required String viewerId,
    @Default(0) int basePointsEarned, // 1 point per minute watched
    @Default(0) int predictionBonusPoints, // From correct predictions
    @Default(0) int engagementBonusPoints, // From comments/reactions
    @Default(0) int premiumBonusPoints, // 50% premium multiplier
    @Default(0) int totalPointsEarned,
    @Default(null) DateTime? claimedAt,
  }) = _LiveSpectatorReward;

  factory LiveSpectatorReward.fromJson(Map<String, dynamic> json) =>
      _$LiveSpectatorRewardFromJson(json);
}

/// Spectator leaderboard entry (during live match)
@freezed
class LiveLeaderboardEntry with _$LiveLeaderboardEntry {
  const factory LiveLeaderboardEntry({
    required String rank,
    required String viewerId,
    required String displayName,
    @Default(0) int pointsEarned,
    @Default(0) int correctPredictions,
    @Default(0) int engagementScore, // Comments + reactions
    @Default(false) bool isPremium,
  }) = _LiveLeaderboardEntry;

  factory LiveLeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LiveLeaderboardEntryFromJson(json);
}

/// Highlight moment during live match
@freezed
class MatchHighlightMoment with _$MatchHighlightMoment {
  const factory MatchHighlightMoment({
    required String id,
    required String matchId,
    required int timestamp, // seconds into match
    required String momentType, // upset, strategic_move, key_turn, final_reversal
    required String description,
    @Default(0) int viewerReactions, // Emoji/reaction count
    @Default(false) bool isFeatured, // Highlighted by organizer
    @Default(null) DateTime? markedAt,
  }) = _MatchHighlightMoment;

  factory MatchHighlightMoment.fromJson(Map<String, dynamic> json) =>
      _$MatchHighlightMomentFromJson(json);
}

/// Live chat message (for match discussion)
@freezed
class LiveChatMessage with _$LiveChatMessage {
  const factory LiveChatMessage({
    required String id,
    required String matchId,
    required String userId,
    required String displayName,
    required String message,
    @Default(null) DateTime? createdAt,
    @Default(0) int likes,
    @Default([]) List<String> likedBy,
    @Default(false) bool isModerator,
    @Default(false) bool isPinned,
  }) = _LiveChatMessage;

  factory LiveChatMessage.fromJson(Map<String, dynamic> json) =>
      _$LiveChatMessageFromJson(json);
}

/// Stream info for live spectating
@freezed
class MatchStreamInfo with _$MatchStreamInfo {
  const factory MatchStreamInfo({
    required String matchId,
    required String streamUrl, // HLS/DASH stream
    @Default('') String streamTitle,
    @Default('') String streamerName,
    @Default('') String streamerChannel, // Twitch/YouTube URL
    @Default(false) bool isOfficialStream,
    @Default(0) int totalViewers,
    @Default(0) int peakViewers,
    @Default(null) DateTime? startedAt,
  }) = _MatchStreamInfo;

  factory MatchStreamInfo.fromJson(Map<String, dynamic> json) =>
      _$MatchStreamInfoFromJson(json);
}

/// Live match viewer statistics
@freezed
class LiveMatchStats with _$LiveMatchStats {
  const factory LiveMatchStats({
    required String matchId,
    @Default(0) int currentViewerCount,
    @Default(0) int peakViewerCount,
    @Default(0) int totalWatchMinutes,
    @Default(0) int totalPredictions,
    @Default(0) int correctPredictions,
    @Default(0) double avgPredictionAccuracy, // percentage
    @Default(0) int totalChatMessages,
    @Default(0) int totalHighlights,
    @Default(0) int totalPointsDistributed,
  }) = _LiveMatchStats;

  factory LiveMatchStats.fromJson(Map<String, dynamic> json) =>
      _$LiveMatchStatsFromJson(json);
}

/// Spectator engagement metrics
@freezed
class SpectatorEngagement with _$SpectatorEngagement {
  const factory SpectatorEngagement({
    required String viewerId,
    required String matchId,
    @Default(0) int watchDurationSeconds,
    @Default(0) int commentsPosted,
    @Default(0) int predictionsPlaced,
    @Default(0) int correctPredictions,
    @Default(0) int reactionsGiven,
    @Default(0) int engagementScore, // Weighted score
    @Default(false) bool completedMatch, // Watched until end
  }) = _SpectatorEngagement;

  factory SpectatorEngagement.fromJson(Map<String, dynamic> json) =>
      _$SpectatorEngagementFromJson(json);
}
