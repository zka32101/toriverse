import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/spectating/data/repositories/live_match_repository.dart';
import 'package:toriverse/features/spectating/domain/models/live_match.dart';

// ============ REPOSITORY PROVIDER ============

final liveMatchRepositoryProvider = Provider<LiveMatchRepository>((ref) {
  return LiveMatchRepository();
});

// ============ PARAMETER CLASSES ============

class _WatchSessionParams {
  final String matchId;

  _WatchSessionParams(this.matchId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WatchSessionParams &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId;

  @override
  int get hashCode => matchId.hashCode;
}

class _WatchBoardParams {
  final String matchId;

  _WatchBoardParams(this.matchId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WatchBoardParams &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId;

  @override
  int get hashCode => matchId.hashCode;
}

class _WatchViewersParams {
  final String matchId;

  _WatchViewersParams(this.matchId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WatchViewersParams &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId;

  @override
  int get hashCode => matchId.hashCode;
}

class _WatchPredictionsParams {
  final String matchId;

  _WatchPredictionsParams(this.matchId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WatchPredictionsParams &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId;

  @override
  int get hashCode => matchId.hashCode;
}

class _WatchChatParams {
  final String matchId;

  _WatchChatParams(this.matchId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WatchChatParams &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId;

  @override
  int get hashCode => matchId.hashCode;
}

class _WatchHighlightsParams {
  final String matchId;

  _WatchHighlightsParams(this.matchId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WatchHighlightsParams &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId;

  @override
  int get hashCode => matchId.hashCode;
}

class _WatchLeaderboardParams {
  final String matchId;

  _WatchLeaderboardParams(this.matchId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WatchLeaderboardParams &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId;

  @override
  int get hashCode => matchId.hashCode;
}

class _WatchStatsParams {
  final String matchId;

  _WatchStatsParams(this.matchId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WatchStatsParams &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId;

  @override
  int get hashCode => matchId.hashCode;
}

class _WatchStreamInfoParams {
  final String matchId;

  _WatchStreamInfoParams(this.matchId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WatchStreamInfoParams &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId;

  @override
  int get hashCode => matchId.hashCode;
}

class _GetSpectatorRewardParams {
  final String matchId;
  final String viewerId;

  _GetSpectatorRewardParams(this.matchId, this.viewerId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _GetSpectatorRewardParams &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId &&
          viewerId == other.viewerId;

  @override
  int get hashCode => matchId.hashCode ^ viewerId.hashCode;
}

class _GetEngagementParams {
  final String viewerId;
  final String matchId;

  _GetEngagementParams(this.viewerId, this.matchId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _GetEngagementParams &&
          runtimeType == other.runtimeType &&
          viewerId == other.viewerId &&
          matchId == other.matchId;

  @override
  int get hashCode => viewerId.hashCode ^ matchId.hashCode;
}

// ============ STREAM PROVIDERS (Real-time) ============

/// Watch live match session in real-time
final watchLiveMatchSessionProvider =
    StreamProvider.autoDispose.family<LiveMatchSession, String>((ref, matchId) {
  final repo = ref.watch(liveMatchRepositoryProvider);
  return repo.watchLiveMatchSession(matchId);
});

/// Watch live board state (< 1 second latency)
final watchLiveBoardStateProvider =
    StreamProvider.autoDispose.family<LiveBoardState, String>((ref, matchId) {
  final repo = ref.watch(liveMatchRepositoryProvider);
  return repo.watchLiveBoardState(matchId);
});

/// Watch live viewers list
final watchLiveViewersProvider =
    StreamProvider.autoDispose.family<List<LiveViewer>, String>((ref, matchId) {
  final repo = ref.watch(liveMatchRepositoryProvider);
  return repo.watchLiveViewers(matchId);
});

/// Watch live predictions
final watchLivePredictionsProvider = StreamProvider.autoDispose
    .family<List<LivePrediction>, String>((ref, matchId) {
  final repo = ref.watch(liveMatchRepositoryProvider);
  return repo.watchLivePredictions(matchId);
});

/// Watch live chat messages
final watchLiveChatProvider =
    StreamProvider.autoDispose.family<List<LiveChatMessage>, String>(
        (ref, matchId) {
  final repo = ref.watch(liveMatchRepositoryProvider);
  return repo.watchLiveChat(matchId);
});

/// Watch highlight moments
final watchHighlightsProvider = StreamProvider.autoDispose
    .family<List<MatchHighlightMoment>, String>((ref, matchId) {
  final repo = ref.watch(liveMatchRepositoryProvider);
  return repo.watchHighlights(matchId);
});

/// Watch live leaderboard
final watchLiveLeaderboardProvider = StreamProvider.autoDispose
    .family<List<LiveLeaderboardEntry>, String>((ref, matchId) {
  final repo = ref.watch(liveMatchRepositoryProvider);
  return repo.watchLiveLeaderboard(matchId);
});

/// Watch live match statistics
final watchLiveMatchStatsProvider = StreamProvider.autoDispose
    .family<LiveMatchStats, String>((ref, matchId) {
  final repo = ref.watch(liveMatchRepositoryProvider);
  return repo.watchLiveMatchStats(matchId);
});

/// Watch stream info
final watchStreamInfoProvider = StreamProvider.autoDispose
    .family<MatchStreamInfo?, String>((ref, matchId) {
  final repo = ref.watch(liveMatchRepositoryProvider);
  return repo.watchStreamInfo(matchId);
});

// ============ FUTURE PROVIDERS ============

/// Get live viewer count
final liveViewerCountProvider =
    FutureProvider.autoDispose.family<int, String>((ref, matchId) {
  final repo = ref.watch(liveMatchRepositoryProvider);
  return repo.getLiveViewerCount(matchId);
});

/// Get live match statistics
final liveMatchStatsProvider =
    FutureProvider.autoDispose.family<LiveMatchStats, String>((ref, matchId) {
  final repo = ref.watch(liveMatchRepositoryProvider);
  return repo.getLiveMatchStats(matchId);
});

/// Get spectator reward
final spectatorRewardProvider = FutureProvider.autoDispose
    .family<LiveSpectatorReward?, _GetSpectatorRewardParams>((ref, params) {
  final repo = ref.watch(liveMatchRepositoryProvider);
  return repo.getSpectatorReward(params.matchId, params.viewerId);
});

/// Get spectator engagement
final spectatorEngagementProvider = FutureProvider.autoDispose
    .family<SpectatorEngagement?, _GetEngagementParams>((ref, params) {
  final repo = ref.watch(liveMatchRepositoryProvider);
  return repo.getSpectatorEngagement(params.viewerId, params.matchId);
});

// ============ MUTATION PROVIDERS ============

/// Join live match (start watching)
final joinLiveMatchProvider =
    FutureProvider.family<void, (String, String, String)>((ref, params) async {
  final (matchId, viewerId, displayName) = params;
  final repo = ref.watch(liveMatchRepositoryProvider);

  await repo.joinLiveMatch(matchId, viewerId, displayName);

  // Invalidate related providers
  ref.invalidate(watchLiveViewersProvider(matchId));
  ref.invalidate(liveViewerCountProvider(matchId));
});

/// Leave live match
final leaveLiveMatchProvider =
    FutureProvider.family<void, (String, String)>((ref, params) async {
  final (matchId, viewerId) = params;
  final repo = ref.watch(liveMatchRepositoryProvider);

  await repo.leaveLiveMatch(matchId, viewerId);

  // Invalidate related providers
  ref.invalidate(watchLiveViewersProvider(matchId));
  ref.invalidate(liveViewerCountProvider(matchId));
});

/// Place prediction during live match
final placePredictionProvider = FutureProvider.family<void,
    (String, String, String, String, int)>((ref, params) async {
  final (matchId, viewerId, predictType, prediction, confidence) = params;
  final repo = ref.watch(liveMatchRepositoryProvider);

  await repo.placePrediction(
    matchId: matchId,
    viewerId: viewerId,
    predictType: predictType,
    prediction: prediction,
    confidenceScore: confidence,
  );

  // Invalidate predictions
  ref.invalidate(watchLivePredictionsProvider(matchId));
});

/// Send chat message
final sendChatMessageProvider =
    FutureProvider.family<void, (String, String, String, String, bool)>(
        (ref, params) async {
  final (matchId, userId, displayName, message, isModerator) = params;
  final repo = ref.watch(liveMatchRepositoryProvider);

  await repo.sendChatMessage(
    matchId: matchId,
    userId: userId,
    displayName: displayName,
    message: message,
    isModerator: isModerator,
  );

  // Invalidate chat
  ref.invalidate(watchLiveChatProvider(matchId));
});

/// Like chat message
final likeChatMessageProvider =
    FutureProvider.family<void, (String, String, String)>((ref, params) async {
  final (matchId, chatId, viewerId) = params;
  final repo = ref.watch(liveMatchRepositoryProvider);

  await repo.likeChatMessage(matchId, chatId, viewerId);

  // Invalidate chat
  ref.invalidate(watchLiveChatProvider(matchId));
});

/// Pin chat message (moderator)
final pinChatMessageProvider =
    FutureProvider.family<void, (String, String)>((ref, params) async {
  final (matchId, chatId) = params;
  final repo = ref.watch(liveMatchRepositoryProvider);

  await repo.pinChatMessage(matchId, chatId);

  // Invalidate chat
  ref.invalidate(watchLiveChatProvider(matchId));
});

/// Record highlight moment
final recordHighlightMomentProvider =
    FutureProvider.family<void, (String, int, String, String)>(
        (ref, params) async {
  final (matchId, timestamp, momentType, description) = params;
  final repo = ref.watch(liveMatchRepositoryProvider);

  await repo.recordHighlightMoment(
    matchId: matchId,
    timestamp: timestamp,
    momentType: momentType,
    description: description,
  );

  // Invalidate highlights
  ref.invalidate(watchHighlightsProvider(matchId));
});

/// React to highlight moment
final reactToHighlightProvider =
    FutureProvider.family<void, (String, String)>((ref, params) async {
  final (matchId, highlightId) = params;
  final repo = ref.watch(liveMatchRepositoryProvider);

  await repo.reactToHighlight(matchId, highlightId);

  // Invalidate highlights
  ref.invalidate(watchHighlightsProvider(matchId));
});

/// Mark highlight as featured (organizer/admin)
final markHighlightFeaturedProvider =
    FutureProvider.family<void, (String, String)>((ref, params) async {
  final (matchId, highlightId) = params;
  final repo = ref.watch(liveMatchRepositoryProvider);

  await repo.markHighlightFeatured(matchId, highlightId);

  // Invalidate highlights
  ref.invalidate(watchHighlightsProvider(matchId));
});

/// Calculate and store spectator rewards
final calculateSpectatorRewardProvider =
    FutureProvider.family<void, (String, String, int, int, int, bool)>(
        (ref, params) async {
  final (matchId, viewerId, watchDuration, correctPreds, comments, isPremium) =
      params;
  final repo = ref.watch(liveMatchRepositoryProvider);

  await repo.calculateSpectatorReward(
    matchId: matchId,
    viewerId: viewerId,
    watchDurationSeconds: watchDuration,
    correctPredictions: correctPreds,
    commentsPosted: comments,
    isPremium: isPremium,
  );

  // Invalidate reward
  ref.invalidate(spectatorRewardProvider(
      _GetSpectatorRewardParams(matchId, viewerId)));
});

/// Claim spectator reward
final claimSpectatorRewardProvider =
    FutureProvider.family<void, (String, String)>((ref, params) async {
  final (matchId, viewerId) = params;
  final repo = ref.watch(liveMatchRepositoryProvider);

  await repo.claimSpectatorReward(matchId, viewerId);

  // Invalidate reward
  ref.invalidate(spectatorRewardProvider(
      _GetSpectatorRewardParams(matchId, viewerId)));
});

/// Update leaderboard entry
final updateLeaderboardEntryProvider = FutureProvider.family<void,
    (String, String, String, int, int, int, bool)>(
    (ref, params) async {
  final (matchId, viewerId, displayName, points, correctPreds, engagement,
      isPremium) = params;
  final repo = ref.watch(liveMatchRepositoryProvider);

  await repo.updateLeaderboardEntry(
    matchId: matchId,
    viewerId: viewerId,
    displayName: displayName,
    pointsEarned: points,
    correctPredictions: correctPreds,
    engagementScore: engagement,
    isPremium: isPremium,
  );

  // Invalidate leaderboard
  ref.invalidate(watchLiveLeaderboardProvider(matchId));
});

/// Record engagement metrics
final recordEngagementProvider = FutureProvider.family<void,
    (String, String, int, int, int, int, int, bool)>(
    (ref, params) async {
  final (viewerId, matchId, watchDuration, comments, predictions,
      correctPreds, reactions, completed) = params;
  final repo = ref.watch(liveMatchRepositoryProvider);

  await repo.recordEngagementMetrics(
    viewerId: viewerId,
    matchId: matchId,
    watchDurationSeconds: watchDuration,
    commentsPosted: comments,
    predictionsPlaced: predictions,
    correctPredictions: correctPreds,
    reactionsGiven: reactions,
    completedMatch: completed,
  );

  // Invalidate engagement
  ref.invalidate(spectatorEngagementProvider(
      _GetEngagementParams(viewerId, matchId)));
});

/// Resolve prediction (mark as correct/incorrect)
final resolvePredictionProvider =
    FutureProvider.family<void, (String, String, bool, int)>(
        (ref, params) async {
  final (matchId, predictionId, isCorrect, points) = params;
  final repo = ref.watch(liveMatchRepositoryProvider);

  await repo.resolvePrediction(matchId, predictionId, isCorrect, points);

  // Invalidate predictions
  ref.invalidate(watchLivePredictionsProvider(matchId));
});

/// Update board state after moves
final updateBoardStateProvider =
    FutureProvider.family<void, (String, List<int>, List<String>, List<String>, List<String>, int, int, int, int, bool)>(
        (ref, params) async {
  final (matchId, boardState, blackPieces, whitePieces, redPieces,
      blackScore, whiteScore, redScore, lastMove, simultaneous) = params;
  final repo = ref.watch(liveMatchRepositoryProvider);

  await repo.updateBoardState(
    matchId,
    boardState: boardState,
    blackPieces: blackPieces,
    whitePieces: whitePieces,
    redPieces: redPieces,
    blackScore: blackScore,
    whiteScore: whiteScore,
    redScore: redScore,
    lastMovePosition: lastMove,
    isSimultaneousReveal: simultaneous,
  );

  // Invalidate board state
  ref.invalidate(watchLiveBoardStateProvider(matchId));
});

/// Update stream viewer counts
final updateStreamViewersProvider =
    FutureProvider.family<void, (String, int, int)>((ref, params) async {
  final (matchId, current, peak) = params;
  final repo = ref.watch(liveMatchRepositoryProvider);

  await repo.updateStreamViewers(matchId, current, peak);

  // Invalidate stream info
  ref.invalidate(watchStreamInfoProvider(matchId));
});
