import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:toriverse/features/spectating/domain/models/streaming_session.dart';
import 'package:crypto/crypto.dart';

/// Repository for streaming platform integrations
///
/// Handles Twitch, YouTube Live, and OBS browser source operations.
/// Manages streaming sessions, highlight generation, and earnings tracking.
class StreamingRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAnalytics _analytics;

  // Platform API keys (loaded from environment)
  final String? _twitchClientId;
  final String? _twitchClientSecret;
  final String? _youtubeApiKey;

  StreamingRepository({
    FirebaseFirestore? firestore,
    FirebaseAnalytics? analytics,
    String? twitchClientId,
    String? twitchClientSecret,
    String? youtubeApiKey,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _analytics = analytics ?? FirebaseAnalytics.instance,
        _twitchClientId = twitchClientId,
        _twitchClientSecret = twitchClientSecret,
        _youtubeApiKey = youtubeApiKey;

  /// Start a streaming session
  ///
  /// Creates a new streaming session and generates platform URLs.
  Future<StreamingSession> startStreamingSession({
    required String matchId,
    required String userId,
    required String displayName,
    required List<StreamingPlatform> targetPlatforms,
    String? streamTitle,
    String? streamDescription,
  }) async {
    final sessionRef = _firestore.collection('streamingSessions').doc();
    final sessionId = sessionRef.id;

    // Generate platform-specific URLs
    final twitchUrl = targetPlatforms.contains(StreamingPlatform.twitch)
        ? await _getTwitchStreamUrl(userId, streamTitle)
        : null;

    final youtubeUrl = targetPlatforms.contains(StreamingPlatform.youtube)
        ? await _getYouTubeStreamUrl(userId, streamTitle)
        : null;

    final obsUrl = _generateOBSSourceUrl(matchId, sessionId);

    // Create session document
    final session = StreamingSession(
      id: sessionId,
      matchId: matchId,
      userId: userId,
      displayName: displayName,
      startedAt: DateTime.now(),
      status: StreamingStatus.starting,
      connectedPlatforms: targetPlatforms.map((p) => p.name).toList(),
      twitchChannelUrl: twitchUrl,
      youtubeStreamUrl: youtubeUrl,
      obsSourceUrl: obsUrl,
    );

    await sessionRef.set(session.toJson());

    // Update match with streaming indicator
    await _firestore
        .collection('matches')
        .doc(matchId)
        .update({
      'isBeingStreamed': true,
      'streamingSessionId': sessionId,
      'activeStreamerCount': FieldValue.increment(1),
    });

    // Log analytics
    await _logStreamingEvent(
      streamingSessionId: sessionId,
      eventType: 'stream_started',
      parameters: {
        'platforms': targetPlatforms.map((p) => p.label).toList(),
        'userId': userId,
      },
    );

    return session;
  }

  /// Generate OBS browser source URL
  ///
  /// Creates a unique, time-limited URL for OBS browser source integration.
  String _generateOBSSourceUrl(String matchId, String sessionId) {
    // Generate stream key (one-time use)
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final streamKey = sha256
        .convert('$matchId:$sessionId:$timestamp'.codeUnits)
        .toString()
        .substring(0, 32);

    final config = OBSSourceConfig(
      matchId: matchId,
      streamKey: streamKey,
      expiresAt: Duration(hours: 24),
      showChat: true,
      showScoreboard: true,
      showPlayerNames: true,
    );

    return config.sourceUrl;
  }

  /// Get Twitch streaming URL
  ///
  /// Initializes Twitch Live streaming if credentials are available.
  Future<String?> _getTwitchStreamUrl(
    String userId,
    String? streamTitle,
  ) async {
    if (_twitchClientId == null || _twitchClientSecret == null) {
      print('Twitch integration not configured');
      return null;
    }

    try {
      // TODO: Implement Twitch API call to create live stream
      // 1. Get user's Twitch OAuth token from database
      // 2. Call Twitch API to create live stream
      // 3. Return stream URL
      //
      // Placeholder: would call Twitch Create Stream API
      // POST https://api.twitch.tv/helix/streams
      // with title, game category, etc.

      final twitchUrl = 'https://twitch.tv/$userId/live';
      return twitchUrl;
    } catch (e) {
      print('Twitch integration error: $e');
      return null;
    }
  }

  /// Get YouTube Live streaming URL
  ///
  /// Initializes YouTube Live broadcast if credentials are available.
  Future<String?> _getYouTubeStreamUrl(
    String userId,
    String? streamTitle,
  ) async {
    if (_youtubeApiKey == null) {
      print('YouTube integration not configured');
      return null;
    }

    try {
      // TODO: Implement YouTube API call to create live event
      // 1. Get user's YouTube OAuth token from database
      // 2. Call YouTube API to create live event
      // 3. Return stream URL
      //
      // Placeholder: would call YouTube Live API
      // POST https://www.googleapis.com/youtube/v3/liveBroadcasts
      // with title, description, etc.

      final youtubeUrl = 'https://youtube.com/live/$userId';
      return youtubeUrl;
    } catch (e) {
      print('YouTube integration error: $e');
      return null;
    }
  }

  /// End streaming session
  ///
  /// Closes the stream and finalizes viewer/earnings data.
  Future<void> endStreamingSession({
    required String sessionId,
    required String matchId,
  }) async {
    final now = DateTime.now();

    // Get session for duration calculation
    final sessionDoc =
        await _firestore.collection('streamingSessions').doc(sessionId).get();
    final session = StreamingSession.fromJson(sessionDoc.data()!);
    final streamDuration =
        now.difference(session.startedAt).inMinutes.toDouble();

    // Update session
    await _firestore
        .collection('streamingSessions')
        .doc(sessionId)
        .update({
      'status': 'offline_vod',
      'endedAt': now,
    });

    // Update match
    await _firestore
        .collection('matches')
        .doc(matchId)
        .update({
      'isBeingStreamed': false,
      'activeStreamerCount': FieldValue.increment(-1),
    });

    // Calculate and store earnings
    await _calculateStreamEarnings(
      userId: session.userId,
      streamDuration: streamDuration,
      viewerCount: session.viewerCount,
    );

    // Log analytics
    await _logStreamingEvent(
      streamingSessionId: sessionId,
      eventType: 'stream_ended',
      parameters: {
        'durationMinutes': streamDuration.toInt(),
        'totalViewers': session.viewerCount,
      },
    );
  }

  /// Update viewer count for active stream
  ///
  /// Called periodically to sync concurrent viewer count.
  Future<void> updateViewerCount(
    String sessionId,
    int viewerCount,
  ) async {
    await _firestore
        .collection('streamingSessions')
        .doc(sessionId)
        .update({
      'viewerCount': viewerCount,
      'totalViews': FieldValue.increment(viewerCount),
    });
  }

  /// Watch real-time viewer count for a stream
  Stream<int> watchViewerCount(String sessionId) {
    return _firestore
        .collection('streamingSessions')
        .doc(sessionId)
        .snapshots()
        .map((doc) => doc.data()?['viewerCount'] as int? ?? 0);
  }

  /// Generate highlight clips from stream
  ///
  /// Automatically creates highlight clips on milestone events.
  Future<HighlightClip> generateHighlightClip({
    required String sessionId,
    required String matchId,
    required String title,
    required String description,
    required Duration startTime,
    required Duration endTime,
    required HighlightType type,
  }) async {
    final clipRef =
        _firestore
            .collection('streamingSessions')
            .doc(sessionId)
            .collection('highlightClips')
            .doc();

    final clip = HighlightClip(
      id: clipRef.id,
      streamingSessionId: sessionId,
      matchId: matchId,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      type: type,
      createdAt: DateTime.now(),
    );

    await clipRef.set(clip.toJson());

    // Log analytics
    await _logStreamingEvent(
      streamingSessionId: sessionId,
      eventType: 'highlight_generated',
      parameters: {
        'clipType': type.label,
        'duration': endTime.inSeconds - startTime.inSeconds,
      },
    );

    return clip;
  }

  /// Watch highlight clips for a session
  Stream<List<HighlightClip>> watchHighlightClips(String sessionId) {
    return _firestore
        .collection('streamingSessions')
        .doc(sessionId)
        .collection('highlightClips')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => HighlightClip.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    });
  }

  /// Get streamer earnings summary
  ///
  /// Calculates earnings for a given period.
  Future<StreamerEarnings> getStreamerEarnings({
    required String userId,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    final snapshot = await _firestore
        .collection('streamingSessions')
        .where('userId', isEqualTo: userId)
        .where('startedAt', isGreaterThanOrEqualTo: periodStart)
        .where('startedAt', isLessThanOrEqualTo: periodEnd)
        .get();

    int totalStreamMinutes = 0;
    int totalViewerMinutes = 0;
    int totalClipViews = 0;
    double streamingRevenue = 0.0;
    double clipRevenue = 0.0;

    for (final doc in snapshot.docs) {
      final session = StreamingSession.fromJson(doc.data());

      // Calculate stream minutes
      final streamEnd = session.endedAt ?? DateTime.now();
      final streamMinutes =
          streamEnd.difference(session.startedAt).inMinutes;
      totalStreamMinutes += streamMinutes;

      // Calculate viewer-minutes (streamer earnings metric)
      totalViewerMinutes += session.viewerCount * streamMinutes;

      // Calculate clip views and revenue
      totalClipViews += session.generatedHighlights.fold(
        0,
        (sum, clip) => sum + clip.viewCount,
      );
    }

    // Calculate revenue (placeholder rates)
    streamingRevenue = totalStreamMinutes * 10.0; // ¥10 per minute
    clipRevenue = totalClipViews * 5.0; // ¥5 per clip view
    final totalEarnings = streamingRevenue + clipRevenue;

    return StreamerEarnings(
      userId: userId,
      periodStart: periodStart,
      periodEnd: periodEnd,
      totalStreamMinutes: totalStreamMinutes,
      totalViewerMinutes: totalViewerMinutes,
      totalClipViews: totalClipViews,
      streamingRevenue: streamingRevenue,
      clipRevenue: clipRevenue,
      totalEarnings: totalEarnings,
    );
  }

  /// Calculate and store streamer earnings
  Future<void> _calculateStreamEarnings({
    required String userId,
    required double streamDuration,
    required int viewerCount,
  }) async {
    // Rate per minute streamed: ¥10
    final streamRevenue = streamDuration * 10.0;

    // Update user's earnings in database
    await _firestore.collection('users').doc(userId).update({
      'totalEarnings': FieldValue.increment(streamRevenue),
      'streamingMinutes': FieldValue.increment(streamDuration.toInt()),
    });
  }

  /// Get OBS overlay configuration for stream
  ///
  /// Returns customizable overlay settings for OBS display.
  Future<OBSSourceConfig> getOBSConfig(String sessionId) async {
    final doc =
        await _firestore.collection('streamingSessions').doc(sessionId).get();
    final session = StreamingSession.fromJson(doc.data()!);

    // Extract stream key from OBS URL
    final obsUrl = session.obsSourceUrl ?? '';
    final streamKeyMatch = RegExp(r'streamKey=([^&]+)').firstMatch(obsUrl);
    final streamKey = streamKeyMatch?.group(1) ?? '';

    return OBSSourceConfig(
      matchId: session.matchId,
      streamKey: streamKey,
      showChat: true,
      showScoreboard: true,
      showPlayerNames: true,
      overlayTheme: 'dark',
    );
  }

  /// Log streaming analytics event
  Future<void> _logStreamingEvent({
    required String streamingSessionId,
    required String eventType,
    required Map<String, dynamic> parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: eventType,
        parameters: {
          'streamingSessionId': streamingSessionId,
          ...parameters,
        },
      );
    } catch (e) {
      print('Analytics logging failed: $e');
    }
  }

  /// Get public stream status for display
  ///
  /// Returns minimal data for showing stream status on home screen.
  Future<Map<String, dynamic>> getPublicStreamStatus(
    String userId,
  ) async {
    final query = await _firestore
        .collection('streamingSessions')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'live')
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return {'isLive': false};
    }

    final session = StreamingSession.fromJson(query.docs.first.data());
    return {
      'isLive': true,
      'displayName': session.displayName,
      'viewerCount': session.viewerCount,
      'platforms': session.connectedPlatforms,
      'matchId': session.matchId,
    };
  }

  /// Clean up ended streaming sessions (7-day retention)
  Future<void> cleanupOldSessions() async {
    final sevenDaysAgo =
        DateTime.now().subtract(const Duration(days: 7));

    final snapshot = await _firestore
        .collection('streamingSessions')
        .where('endedAt', isLessThan: sevenDaysAgo)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
