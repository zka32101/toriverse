import 'package:freezed_annotation/freezed_annotation.dart';

part 'streaming_session.freezed.dart';
part 'streaming_session.g.dart';

/// Streaming session model for streamer sessions
///
/// Represents a user's active streaming session across multiple platforms.
/// Tracks streaming status, viewer count, earnings, and platform metadata.
@freezed
class StreamingSession with _$StreamingSession {
  const factory StreamingSession({
    required String id,                    // Unique session ID
    required String matchId,               // Match being streamed
    required String userId,                // Streamer's user ID
    required String displayName,           // Streamer's name
    required DateTime startedAt,           // When stream started
    DateTime? endedAt,                     // When stream ended (null if active)
    @Default(StreamingStatus.offline)
      StreamingStatus status,              // Current streaming status
    @Default(0) int viewerCount,           // Current concurrent viewers
    @Default(0) int totalViews,            // Total cumulative views
    @Default([]) List<String>
      connectedPlatforms,                  // ['twitch', 'youtube', 'obs']
    String? twitchChannelUrl,              // Twitch channel URL
    String? youtubeStreamUrl,              // YouTube Live stream URL
    String? obsSourceUrl,                  // OBS browser source URL
    @Default(0.0) double revenueEarned,    // Revenue from this stream (JPY)
    StreamingMetadata? metadata,           // Platform-specific metadata
    @Default(false) bool isHighlighted,    // Featured/highlighted stream
    @Default([]) List<HighlightClip>
      generatedHighlights,                 // Auto-generated highlight clips
  }) = _StreamingSession;

  factory StreamingSession.fromJson(Map<String, dynamic> json) =>
      _$StreamingSessionFromJson(json);
}

/// Streaming status enumeration
enum StreamingStatus {
  offline,       // Not currently streaming
  starting,      // Stream initialization in progress
  live,          // Currently broadcasting
  paused,        // Stream temporarily paused
  ending,        // Stream shutdown in progress
  offline_vod,   // Stream ended, saved as VOD (Video On Demand)
}

extension StreamingStatusExt on StreamingStatus {
  String get label {
    switch (this) {
      case StreamingStatus.offline:
        return 'Offline';
      case StreamingStatus.starting:
        return 'Starting...';
      case StreamingStatus.live:
        return 'Live 🔴';
      case StreamingStatus.paused:
        return 'Paused';
      case StreamingStatus.ending:
        return 'Ending...';
      case StreamingStatus.offline_vod:
        return 'VOD Available';
    }
  }

  bool get isActive {
    return this == StreamingStatus.live || this == StreamingStatus.starting;
  }
}

/// Streaming platform enumeration
enum StreamingPlatform {
  twitch,    // Twitch.tv streaming
  youtube,   // YouTube Live streaming
  obs,       // OBS browser source (local)
}

extension StreamingPlatformExt on StreamingPlatform {
  String get label {
    switch (this) {
      case StreamingPlatform.twitch:
        return 'Twitch';
      case StreamingPlatform.youtube:
        return 'YouTube Live';
      case StreamingPlatform.obs:
        return 'OBS Browser Source';
    }
  }

  String get icon {
    switch (this) {
      case StreamingPlatform.twitch:
        return '📺';
      case StreamingPlatform.youtube:
        return '📹';
      case StreamingPlatform.obs:
        return '🎬';
    }
  }
}

/// Platform-specific streaming metadata
@freezed
class StreamingMetadata with _$StreamingMetadata {
  const factory StreamingMetadata({
    required String platform,              // 'twitch', 'youtube', 'obs'
    String? platformUserId,                // User ID on platform
    String? streamTitle,                   // Stream title
    String? streamDescription,             // Stream description
    @Default([]) List<String> tags,        // Stream tags/categories
    String? gameTitleOverride,             // Custom game title for platform
    @Default(false) bool autoArchive,      // Auto-save VOD after stream
    DateTime? scheduleTime,                // Pre-scheduled stream time
  }) = _StreamingMetadata;

  factory StreamingMetadata.fromJson(Map<String, dynamic> json) =>
      _$StreamingMetadataFromJson(json);
}

/// Auto-generated highlight clip from stream
@freezed
class HighlightClip with _$HighlightClip {
  const factory HighlightClip({
    required String id,                    // Unique clip ID
    required String streamingSessionId,    // Parent session
    required String matchId,               // Associated match
    required String title,                 // Clip title
    required String description,           // What happened
    required Duration startTime,           // Time in stream
    required Duration endTime,             // Clip duration
    @Default(HighlightType.milestone)
      HighlightType type,                  // milestone, epic, turnover, etc.
    @Default(0) int viewCount,             // Total clip views
    @Default(0) int shareCount,            // Times shared
    String? videoUrl,                      // Processed video URL
    @Default(false) bool isApproved,       // Streamer approved
    DateTime? createdAt,                   // When clip was generated
    @Default([]) List<String> tags,        // Searchable tags
  }) = _HighlightClip;

  factory HighlightClip.fromJson(Map<String, dynamic> json) =>
      _$HighlightClipFromJson(json);
}

/// Types of highlight clips
enum HighlightType {
  milestone,      // Match milestone (e.g., match end, final round)
  epic,           // Epic/impressive moment
  turnover,       // Dramatic reversal
  funny,          // Humorous moment
  close_call,     // Nearly-lost moment
  championship,   // Tournament/championship moment
}

extension HighlightTypeExt on HighlightType {
  String get label {
    switch (this) {
      case HighlightType.milestone:
        return 'Milestone';
      case HighlightType.epic:
        return 'Epic Moment';
      case HighlightType.turnover:
        return 'Turnaround';
      case HighlightType.funny:
        return 'Funny Moment';
      case HighlightType.close_call:
        return 'Close Call';
      case HighlightType.championship:
        return 'Championship';
    }
  }

  String get emoji {
    switch (this) {
      case HighlightType.milestone:
        return '🏁';
      case HighlightType.epic:
        return '🔥';
      case HighlightType.turnover:
        return '💫';
      case HighlightType.funny:
        return '😂';
      case HighlightType.close_call:
        return '😰';
      case HighlightType.championship:
        return '👑';
    }
  }
}

/// OBS Browser Source configuration
class OBSSourceConfig {
  final String matchId;
  final String streamKey;                // One-time key for verification
  final Duration? expiresAt;             // Key expiration
  final bool showChat;                   // Include chat overlay
  final bool showScoreboard;             // Include scoreboard overlay
  final bool showPlayerNames;            // Include player name overlays
  final String? overlayTheme;            // 'dark', 'light', 'custom'

  OBSSourceConfig({
    required this.matchId,
    required this.streamKey,
    this.expiresAt,
    this.showChat = true,
    this.showScoreboard = true,
    this.showPlayerNames = true,
    this.overlayTheme = 'dark',
  });

  /// Generate OBS browser source URL
  String get sourceUrl {
    final params = [
      'matchId=$matchId',
      'streamKey=$streamKey',
      if (showChat) 'showChat=true',
      if (showScoreboard) 'showScoreboard=true',
      if (showPlayerNames) 'showPlayerNames=true',
      if (overlayTheme != null) 'theme=$overlayTheme',
    ];
    return 'https://toriverse.app/spectate/obs?${params.join('&')}';
  }

  /// Export configuration as JSON
  Map<String, dynamic> toJson() => {
    'matchId': matchId,
    'streamKey': streamKey,
    'expiresAt': expiresAt?.toString(),
    'showChat': showChat,
    'showScoreboard': showScoreboard,
    'showPlayerNames': showPlayerNames,
    'overlayTheme': overlayTheme,
  };
}

/// Streaming analytics event
class StreamingAnalyticsEvent {
  final String streamingSessionId;
  final String eventType;                // 'stream_started', 'viewer_joined', 'highlight_generated', etc.
  final Map<String, dynamic> parameters;
  final DateTime timestamp;

  StreamingAnalyticsEvent({
    required this.streamingSessionId,
    required this.eventType,
    required this.parameters,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'streamingSessionId': streamingSessionId,
    'eventType': eventType,
    'parameters': parameters,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Streamer earnings tracking
@freezed
class StreamerEarnings with _$StreamerEarnings {
  const factory StreamerEarnings({
    required String userId,                // Streamer ID
    required DateTime periodStart,         // Earnings period start
    required DateTime periodEnd,           // Earnings period end
    @Default(0) int totalStreamMinutes,    // Total minutes streamed
    @Default(0) int totalViewerMinutes,    // Total viewer-minutes
    @Default(0) int totalClipViews,        // Total highlight clip views
    @Default(0.0) double streamingRevenue, // From stream subscriptions (JPY)
    @Default(0.0) double clipRevenue,      // From clip views (JPY)
    @Default(0.0) double referralRevenue,  // From referrals (JPY)
    @Default(0.0) double totalEarnings,    // Total earnings this period (JPY)
  }) = _StreamerEarnings;

  factory StreamerEarnings.fromJson(Map<String, dynamic> json) =>
      _$StreamerEarningsFromJson(json);
}
