import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:toriverse/features/spectating/domain/models/live_match.dart';

/// Repository for live match spectating operations
///
/// Handles real-time board synchronization, viewer management,
/// predictions, chat, rewards, and leaderboards.
class LiveMatchRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAnalytics _analytics;

  LiveMatchRepository({
    FirebaseFirestore? firestore,
    FirebaseAnalytics? analytics,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _analytics = analytics ?? FirebaseAnalytics.instance;

  // ============ LIVE MATCH SESSION ============

  /// Watch live match session in real-time
  Stream<LiveMatchSession> watchLiveMatchSession(String matchId) {
    return _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('session')
        .snapshots()
        .map((snap) {
      if (!snap.exists) {
        throw Exception('Live match session not found');
      }
      return LiveMatchSession.fromJson(snap.data() as Map<String, dynamic>);
    });
  }

  /// Start live match viewing session
  Future<void> startLiveSession(String matchId, List<String> playerIds) async {
    final session = LiveMatchSession(
      id: 'session_$matchId',
      matchId: matchId,
      tournamentId: '', // Retrieved from match doc
      playerIds: playerIds,
      currentPlayerTurn: playerIds[0],
      roundNumber: 1,
      timeRemainingSeconds: 30,
      status: 'playing',
      startedAt: DateTime.now(),
      liveViewerCount: 0,
      totalViewsToday: 0,
      recentActions: [],
    );

    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('session')
        .set(session.toJson(), SetOptions(merge: true));

    await _analytics.logEvent(
      name: 'live_session_started',
      parameters: {'match_id': matchId},
    );
  }

  /// Update live session status
  Future<void> updateSessionStatus(String matchId, String status) async {
    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('session')
        .update({'status': status, 'updatedAt': FieldValue.serverTimestamp()});
  }

  /// Finish live match session
  Future<void> finishLiveSession(String matchId) async {
    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('session')
        .update({
      'status': 'finished',
      'finishedAt': FieldValue.serverTimestamp(),
    });

    await _analytics.logEvent(
      name: 'live_session_finished',
      parameters: {'match_id': matchId},
    );
  }

  // ============ LIVE BOARD STATE ============

  /// Watch live board state in real-time (< 1 second latency)
  Stream<LiveBoardState> watchLiveBoardState(String matchId) {
    return _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('board')
        .snapshots()
        .map((snap) {
      if (!snap.exists) {
        throw Exception('Live board state not found');
      }
      return LiveBoardState.fromJson(snap.data() as Map<String, dynamic>);
    });
  }

  /// Initialize live board state at match start
  Future<void> initializeBoardState(
    String matchId,
    List<int> boardState,
    List<String> blackPieces,
    List<String> whitePieces,
    List<String> redPieces,
  ) async {
    final board = LiveBoardState(
      matchId: matchId,
      boardState: boardState,
      blackPieces: blackPieces,
      whitePieces: whitePieces,
      redPieces: redPieces,
      blackScore: blackPieces.length,
      whiteScore: whitePieces.length,
      redScore: redPieces.length,
      lastMovePosition: -1,
      isSimultaneousReveal: false,
      lastUpdateAt: DateTime.now(),
    );

    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('board')
        .set(board.toJson());
  }

  /// Update board state after move reveal
  Future<void> updateBoardState(
    String matchId, {
    required List<int> boardState,
    required List<String> blackPieces,
    required List<String> whitePieces,
    required List<String> redPieces,
    required int blackScore,
    required int whiteScore,
    required int redScore,
    required int lastMovePosition,
    required bool isSimultaneousReveal,
  }) async {
    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('board')
        .update({
      'boardState': boardState,
      'blackPieces': blackPieces,
      'whitePieces': whitePieces,
      'redPieces': redPieces,
      'blackScore': blackScore,
      'whiteScore': whiteScore,
      'redScore': redScore,
      'lastMovePosition': lastMovePosition,
      'isSimultaneousReveal': isSimultaneousReveal,
      'lastUpdateAt': FieldValue.serverTimestamp(),
    });

    await _analytics.logEvent(
      name: 'board_state_updated',
      parameters: {
        'match_id': matchId,
        'last_move': lastMovePosition,
      },
    );
  }

  // ============ LIVE VIEWERS ============

  /// Watch live viewer list in real-time
  Stream<List<LiveViewer>> watchLiveViewers(String matchId) {
    return _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('session')
        .collection('viewers')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => LiveViewer.fromJson(doc.data()))
            .toList());
  }

  /// Join live match as viewer
  Future<void> joinLiveMatch(
    String matchId,
    String viewerId,
    String displayName,
  ) async {
    final viewer = LiveViewer(
      id: 'viewer_${matchId}_$viewerId',
      matchId: matchId,
      viewerId: viewerId,
      displayName: displayName,
      joinedAt: DateTime.now(),
      watchDurationSeconds: 0,
      isPremium: false,
      isStreaming: false,
    );

    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('session')
        .collection('viewers')
        .doc(viewerId)
        .set(viewer.toJson(), SetOptions(merge: true));

    // Increment live viewer count
    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('session')
        .update({
      'liveViewerCount': FieldValue.increment(1),
    });

    await _analytics.logEvent(
      name: 'viewer_joined',
      parameters: {
        'match_id': matchId,
        'viewer_id': viewerId,
      },
    );
  }

  /// Leave live match
  Future<void> leaveLiveMatch(String matchId, String viewerId) async {
    final doc = _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('session')
        .collection('viewers')
        .doc(viewerId);

    final viewer = await doc.get();
    if (viewer.exists) {
      final data = viewer.data() as Map<String, dynamic>;
      final joinedAt = (data['joinedAt'] as Timestamp).toDate();
      final duration = DateTime.now().difference(joinedAt).inSeconds;

      await doc.update({
        'leftAt': FieldValue.serverTimestamp(),
        'watchDurationSeconds': duration,
      });
    }

    // Decrement live viewer count
    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('session')
        .update({
      'liveViewerCount': FieldValue.increment(-1),
    });

    await _analytics.logEvent(
      name: 'viewer_left',
      parameters: {
        'match_id': matchId,
        'viewer_id': viewerId,
        'watch_duration': viewer.exists
            ? (viewer.data() as Map<String, dynamic>)['watchDurationSeconds']
            : 0,
      },
    );
  }

  /// Get current live viewer count
  Future<int> getLiveViewerCount(String matchId) async {
    final doc = await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('session')
        .get();

    if (doc.exists) {
      return (doc.data() as Map<String, dynamic>)['liveViewerCount'] as int? ?? 0;
    }
    return 0;
  }

  // ============ PREDICTIONS ============

  /// Place prediction during live match
  Future<void> placePrediction({
    required String matchId,
    required String viewerId,
    required String predictType,
    required String prediction,
    required int confidenceScore,
  }) async {
    final predictionId = 'pred_${matchId}_${viewerId}_${DateTime.now().millisecondsSinceEpoch}';

    final livePrediction = LivePrediction(
      id: predictionId,
      matchId: matchId,
      viewerId: viewerId,
      predictType: predictType,
      prediction: prediction,
      confidenceScore: confidenceScore,
      createdAt: DateTime.now(),
      isCorrect: false,
      pointsAwarded: 0,
    );

    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('session')
        .collection('predictions')
        .doc(predictionId)
        .set(livePrediction.toJson());

    await _analytics.logEvent(
      name: 'prediction_placed',
      parameters: {
        'match_id': matchId,
        'predict_type': predictType,
        'confidence': confidenceScore,
      },
    );
  }

  /// Watch predictions for a match
  Stream<List<LivePrediction>> watchLivePredictions(String matchId) {
    return _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('session')
        .collection('predictions')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => LivePrediction.fromJson(doc.data()))
            .toList());
  }

  /// Resolve prediction (mark as correct/incorrect)
  Future<void> resolvePrediction(
    String matchId,
    String predictionId,
    bool isCorrect,
    int pointsAwarded,
  ) async {
    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('session')
        .collection('predictions')
        .doc(predictionId)
        .update({
      'isCorrect': isCorrect,
      'pointsAwarded': pointsAwarded,
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============ LIVE CHAT ============

  /// Send live chat message
  Future<void> sendChatMessage({
    required String matchId,
    required String userId,
    required String displayName,
    required String message,
    required bool isModerator,
  }) async {
    final chatId = 'chat_${matchId}_${DateTime.now().millisecondsSinceEpoch}';

    final chatMessage = LiveChatMessage(
      id: chatId,
      matchId: matchId,
      userId: userId,
      displayName: displayName,
      message: message,
      createdAt: DateTime.now(),
      likes: 0,
      likedBy: [],
      isModerator: isModerator,
      isPinned: false,
    );

    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('session')
        .collection('chat')
        .doc(chatId)
        .set(chatMessage.toJson());

    await _analytics.logEvent(
      name: 'chat_message_sent',
      parameters: {'match_id': matchId},
    );
  }

  /// Watch live chat messages
  Stream<List<LiveChatMessage>> watchLiveChat(String matchId) {
    return _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('session')
        .collection('chat')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => LiveChatMessage.fromJson(doc.data()))
            .toList());
  }

  /// Like chat message
  Future<void> likeChatMessage(
    String matchId,
    String chatId,
    String viewerId,
  ) async {
    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('session')
        .collection('chat')
        .doc(chatId)
        .update({
      'likes': FieldValue.increment(1),
      'likedBy': FieldValue.arrayUnion([viewerId]),
    });
  }

  /// Pin chat message (moderator only)
  Future<void> pinChatMessage(String matchId, String chatId) async {
    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('session')
        .collection('chat')
        .doc(chatId)
        .update({'isPinned': true});
  }

  // ============ HIGHLIGHT MOMENTS ============

  /// Record highlight moment during match
  Future<void> recordHighlightMoment({
    required String matchId,
    required int timestamp,
    required String momentType,
    required String description,
  }) async {
    final highlightId = 'highlight_${matchId}_$timestamp';

    final moment = MatchHighlightMoment(
      id: highlightId,
      matchId: matchId,
      timestamp: timestamp,
      momentType: momentType,
      description: description,
      viewerReactions: 0,
      isFeatured: false,
      markedAt: DateTime.now(),
    );

    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('session')
        .collection('highlights')
        .doc(highlightId)
        .set(moment.toJson());

    await _analytics.logEvent(
      name: 'highlight_recorded',
      parameters: {
        'match_id': matchId,
        'moment_type': momentType,
      },
    );
  }

  /// Watch highlight moments
  Stream<List<MatchHighlightMoment>> watchHighlights(String matchId) {
    return _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('session')
        .collection('highlights')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => MatchHighlightMoment.fromJson(doc.data()))
            .toList());
  }

  /// React to highlight moment
  Future<void> reactToHighlight(
    String matchId,
    String highlightId,
  ) async {
    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('session')
        .collection('highlights')
        .doc(highlightId)
        .update({
      'viewerReactions': FieldValue.increment(1),
    });
  }

  /// Mark moment as featured (organizer/admin)
  Future<void> markHighlightFeatured(String matchId, String highlightId) async {
    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('session')
        .collection('highlights')
        .doc(highlightId)
        .update({'isFeatured': true});
  }

  // ============ SPECTATOR REWARDS ============

  /// Calculate and store spectator rewards
  Future<void> calculateSpectatorReward({
    required String matchId,
    required String viewerId,
    required int watchDurationSeconds,
    required int correctPredictions,
    required int commentsPosted,
    required bool isPremium,
  }) async {
    final basePoints = (watchDurationSeconds / 60).toInt(); // 1 point per minute
    final predictionBonus = correctPredictions * 10;
    final engagementBonus = commentsPosted * 5;
    final premiumBonus =
        isPremium ? ((basePoints + predictionBonus + engagementBonus) ~/ 2) : 0;
    final totalPoints =
        basePoints + predictionBonus + engagementBonus + premiumBonus;

    final reward = LiveSpectatorReward(
      id: 'reward_${matchId}_$viewerId',
      matchId: matchId,
      viewerId: viewerId,
      basePointsEarned: basePoints,
      predictionBonusPoints: predictionBonus,
      engagementBonusPoints: engagementBonus,
      premiumBonusPoints: premiumBonus,
      totalPointsEarned: totalPoints,
    );

    await _firestore
        .collection('users')
        .doc(viewerId)
        .collection('spectator_rewards')
        .doc('reward_${matchId}_$viewerId')
        .set(reward.toJson(), SetOptions(merge: true));

    // Update user's total spectator points
    await _firestore.collection('users').doc(viewerId).update({
      'spectatorPointsTotal': FieldValue.increment(totalPoints),
    });

    await _analytics.logEvent(
      name: 'reward_calculated',
      parameters: {
        'match_id': matchId,
        'total_points': totalPoints,
        'watch_duration': watchDurationSeconds,
      },
    );
  }

  /// Get spectator reward for a match
  Future<LiveSpectatorReward?> getSpectatorReward(
    String matchId,
    String viewerId,
  ) async {
    final doc = await _firestore
        .collection('users')
        .doc(viewerId)
        .collection('spectator_rewards')
        .doc('reward_${matchId}_$viewerId')
        .get();

    if (doc.exists) {
      return LiveSpectatorReward.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  /// Claim spectator reward
  Future<void> claimSpectatorReward(String matchId, String viewerId) async {
    await _firestore
        .collection('users')
        .doc(viewerId)
        .collection('spectator_rewards')
        .doc('reward_${matchId}_$viewerId')
        .update({
      'claimedAt': FieldValue.serverTimestamp(),
    });

    await _analytics.logEvent(
      name: 'reward_claimed',
      parameters: {
        'match_id': matchId,
      },
    );
  }

  // ============ LIVE LEADERBOARD ============

  /// Get live leaderboard for match
  Future<List<LiveLeaderboardEntry>> getLiveLeaderboard(String matchId) async {
    final snap = await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('session')
        .collection('leaderboard')
        .orderBy('pointsEarned', descending: true)
        .limit(100)
        .get();

    return snap.docs
        .map((doc) => LiveLeaderboardEntry.fromJson(doc.data()))
        .toList();
  }

  /// Watch live leaderboard (real-time updates)
  Stream<List<LiveLeaderboardEntry>> watchLiveLeaderboard(String matchId) {
    return _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('session')
        .collection('leaderboard')
        .orderBy('pointsEarned', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => LiveLeaderboardEntry.fromJson(doc.data()))
            .toList());
  }

  /// Update leaderboard entry
  Future<void> updateLeaderboardEntry({
    required String matchId,
    required String viewerId,
    required String displayName,
    required int pointsEarned,
    required int correctPredictions,
    required int engagementScore,
    required bool isPremium,
  }) async {
    final entry = LiveLeaderboardEntry(
      rank: '', // Calculated on read
      viewerId: viewerId,
      displayName: displayName,
      pointsEarned: pointsEarned,
      correctPredictions: correctPredictions,
      engagementScore: engagementScore,
      isPremium: isPremium,
    );

    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('session')
        .collection('leaderboard')
        .doc(viewerId)
        .set(entry.toJson(), SetOptions(merge: true));
  }

  // ============ MATCH STATISTICS ============

  /// Get live match statistics
  Future<LiveMatchStats> getLiveMatchStats(String matchId) async {
    final doc = await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('stats')
        .get();

    if (doc.exists) {
      return LiveMatchStats.fromJson(doc.data() as Map<String, dynamic>);
    }

    // Return default stats if not found
    return LiveMatchStats(matchId: matchId);
  }

  /// Watch live match statistics
  Stream<LiveMatchStats> watchLiveMatchStats(String matchId) {
    return _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('stats')
        .snapshots()
        .map((snap) {
      if (snap.exists) {
        return LiveMatchStats.fromJson(snap.data() as Map<String, dynamic>);
      }
      return LiveMatchStats(matchId: matchId);
    });
  }

  /// Update live match statistics
  Future<void> updateLiveMatchStats({
    required String matchId,
    required int currentViewerCount,
    required int peakViewerCount,
    required int totalWatchMinutes,
    required int totalPredictions,
    required int correctPredictions,
    required double avgPredictionAccuracy,
    required int totalChatMessages,
    required int totalHighlights,
    required int totalPointsDistributed,
  }) async {
    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('stats')
        .set({
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
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ============ STREAM INFO ============

  /// Record stream info for match
  Future<void> recordStreamInfo({
    required String matchId,
    required String streamUrl,
    required String streamTitle,
    required String streamerName,
    required String streamerChannel,
    required bool isOfficialStream,
  }) async {
    final streamInfo = MatchStreamInfo(
      matchId: matchId,
      streamUrl: streamUrl,
      streamTitle: streamTitle,
      streamerName: streamerName,
      streamerChannel: streamerChannel,
      isOfficialStream: isOfficialStream,
      totalViewers: 0,
      peakViewers: 0,
      startedAt: DateTime.now(),
    );

    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('stream')
        .set(streamInfo.toJson());
  }

  /// Watch stream info
  Stream<MatchStreamInfo?> watchStreamInfo(String matchId) {
    return _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('stream')
        .snapshots()
        .map((snap) {
      if (snap.exists) {
        return MatchStreamInfo.fromJson(snap.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  /// Update stream viewer counts
  Future<void> updateStreamViewers(
    String matchId,
    int currentViewers,
    int peakViewers,
  ) async {
    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('live')
        .doc('stream')
        .update({
      'totalViewers': currentViewers,
      'peakViewers': peakViewers,
    });
  }

  // ============ SPECTATOR ENGAGEMENT ============

  /// Record spectator engagement metrics
  Future<void> recordEngagementMetrics({
    required String viewerId,
    required String matchId,
    required int watchDurationSeconds,
    required int commentsPosted,
    required int predictionsPlaced,
    required int correctPredictions,
    required int reactionsGiven,
    required bool completedMatch,
  }) async {
    final engagementScore =
        (commentsPosted * 10) + (predictionsPlaced * 5) + (reactionsGiven * 2);

    final engagement = SpectatorEngagement(
      viewerId: viewerId,
      matchId: matchId,
      watchDurationSeconds: watchDurationSeconds,
      commentsPosted: commentsPosted,
      predictionsPlaced: predictionsPlaced,
      correctPredictions: correctPredictions,
      reactionsGiven: reactionsGiven,
      engagementScore: engagementScore,
      completedMatch: completedMatch,
    );

    await _firestore
        .collection('users')
        .doc(viewerId)
        .collection('spectator_engagement')
        .doc('engagement_$matchId')
        .set(engagement.toJson(), SetOptions(merge: true));

    // Update user's spectator stats
    await _firestore.collection('users').doc(viewerId).update({
      'totalWatchMinutes': FieldValue.increment(watchDurationSeconds ~/ 60),
      'totalEngagementScore': FieldValue.increment(engagementScore),
      'totalMatchesWatched': FieldValue.increment(1),
    });

    await _analytics.logEvent(
      name: 'engagement_recorded',
      parameters: {
        'match_id': matchId,
        'engagement_score': engagementScore,
        'watch_duration': watchDurationSeconds,
        'completed': completedMatch,
      },
    );
  }

  /// Get spectator engagement for a match
  Future<SpectatorEngagement?> getSpectatorEngagement(
    String viewerId,
    String matchId,
  ) async {
    final doc = await _firestore
        .collection('users')
        .doc(viewerId)
        .collection('spectator_engagement')
        .doc('engagement_$matchId')
        .get();

    if (doc.exists) {
      return SpectatorEngagement.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }
}
