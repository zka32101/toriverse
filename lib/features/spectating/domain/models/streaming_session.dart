
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

Duration _parseDuration(dynamic value) {
  if (value is Duration) return value;
  if (value is int) return Duration(seconds: value);
  final match = RegExp(r'^(-?)(\d+):(\d{2}):(\d{2})\.(\d{6})$')
      .firstMatch(value as String);
  if (match == null) return Duration.zero;
  final sign = match.group(1) == '-' ? -1 : 1;
  final hours = int.parse(match.group(2)!);
  final minutes = int.parse(match.group(3)!);
  final seconds = int.parse(match.group(4)!);
  final micros = int.parse(match.group(5)!);
  return Duration(
    hours: sign * hours,
    minutes: sign * minutes,
    seconds: sign * seconds,
    microseconds: sign * micros,
  );
}

/// Streaming session model for streamer sessions
///
/// Represents a user's active streaming session across multiple platforms.
/// Tracks streaming status, viewer count, earnings, and platform metadata.
class StreamingSession {
  final String id;                    // Unique session ID
  final String matchId;               // Match being streamed
  final String userId;                // Streamer's user ID
  final String displayName;           // Streamer's name
  final DateTime startedAt;           // When stream started
  final DateTime? endedAt;            // When stream ended (null if active)
  final StreamingStatus status;       // Current streaming status
  final int viewerCount;              // Current concurrent viewers
  final int totalViews;               // Total cumulative views
  final List<String> connectedPlatforms;  // ['twitch', 'youtube', 'obs']
  final String? twitchChannelUrl;     // Twitch channel URL
  final String? youtubeStreamUrl;     // YouTube Live stream URL
  final String? obsSourceUrl;         // OBS browser source URL
  final double revenueEarned;         // Revenue from this stream (JPY)
  final StreamingMetadata? metadata;  // Platform-specific metadata
  final bool isHighlighted;           // Featured/highlighted stream
  final List<HighlightClip> generatedHighlights;  // Auto-generated highlight clips

  const StreamingSession({
    required this.id,
    required this.matchId,
    required this.userId,
    required this.displayName,
    required this.startedAt,
    this.endedAt,
    this.status = StreamingStatus.offline,
    this.viewerCount = 0,
    this.totalViews = 0,
    this.connectedPlatforms = const [],
    this.twitchChannelUrl,
    this.youtubeStreamUrl,
    this.obsSourceUrl,
    this.revenueEarned = 0.0,
    this.metadata,
    this.isHighlighted = false,
    this.generatedHighlights = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'matchId': matchId,
    'userId': userId,
    'displayName': displayName,
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'status': status.name,
    'viewerCount': viewerCount,
    'totalViews': totalViews,
    'connectedPlatforms': connectedPlatforms,
    'twitchChannelUrl': twitchChannelUrl,
    'youtubeStreamUrl': youtubeStreamUrl,
    'obsSourceUrl': obsSourceUrl,
    'revenueEarned': revenueEarned,
    'metadata': metadata?.toJson(),
    'isHighlighted': isHighlighted,
    'generatedHighlights': generatedHighlights.map((c) => c.toJson()).toList(),
  };

  factory StreamingSession.fromJson(Map<String, dynamic> json) {
    return StreamingSession(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      startedAt: _parseDateTime(json['startedAt']),
      endedAt: _parseDateTimeOrNull(json['endedAt']),
      status: StreamingStatus.values.byName(
        json['status'] as String? ?? 'offline',
      ),
      viewerCount: json['viewerCount'] as int? ?? 0,
      totalViews: json['totalViews'] as int? ?? 0,
      connectedPlatforms: (json['connectedPlatforms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      twitchChannelUrl: json['twitchChannelUrl'] as String?,
      youtubeStreamUrl: json['youtubeStreamUrl'] as String?,
      obsSourceUrl: json['obsSourceUrl'] as String?,
      revenueEarned: (json['revenueEarned'] as num?)?.toDouble() ?? 0.0,
      metadata: json['metadata'] != null
          ? StreamingMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
      isHighlighted: json['isHighlighted'] as bool? ?? false,
      generatedHighlights: (json['generatedHighlights'] as List<dynamic>?)
              ?.map((e) => HighlightClip.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
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
class StreamingMetadata {
  final String platform;                 // 'twitch', 'youtube', 'obs'
  final String? platformUserId;          // User ID on platform
  final String? streamTitle;             // Stream title
  final String? streamDescription;       // Stream description
  final List<String> tags;               // Stream tags/categories
  final String? gameTitleOverride;       // Custom game title for platform
  final bool autoArchive;                // Auto-save VOD after stream
  final DateTime? scheduleTime;          // Pre-scheduled stream time

  const StreamingMetadata({
    required this.platform,
    this.platformUserId,
    this.streamTitle,
    this.streamDescription,
    this.tags = const [],
    this.gameTitleOverride,
    this.autoArchive = false,
    this.scheduleTime,
  });

  Map<String, dynamic> toJson() => {
    'platform': platform,
    'platformUserId': platformUserId,
    'streamTitle': streamTitle,
    'streamDescription': streamDescription,
    'tags': tags,
    'gameTitleOverride': gameTitleOverride,
    'autoArchive': autoArchive,
    'scheduleTime': scheduleTime?.toIso8601String(),
  };

  factory StreamingMetadata.fromJson(Map<String, dynamic> json) {
    return StreamingMetadata(
      platform: json['platform'] as String,
      platformUserId: json['platformUserId'] as String?,
      streamTitle: json['streamTitle'] as String?,
      streamDescription: json['streamDescription'] as String?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      gameTitleOverride: json['gameTitleOverride'] as String?,
      autoArchive: json['autoArchive'] as bool? ?? false,
      scheduleTime: _parseDateTimeOrNull(json['scheduleTime']),
    );
  }
}

/// Auto-generated highlight clip from stream
class HighlightClip {
  final String id;                    // Unique clip ID
  final String streamingSessionId;    // Parent session
  final String matchId;               // Associated match
  final String title;                 // Clip title
  final String description;           // What happened
  final Duration startTime;           // Time in stream
  final Duration endTime;             // Clip duration
  final HighlightType type;           // milestone, epic, turnover, etc.
  final int viewCount;                // Total clip views
  final int shareCount;               // Times shared
  final String? videoUrl;             // Processed video URL
  final bool isApproved;              // Streamer approved
  final DateTime? createdAt;          // When clip was generated
  final List<String> tags;            // Searchable tags

  const HighlightClip({
    required this.id,
    required this.streamingSessionId,
    required this.matchId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.type = HighlightType.milestone,
    this.viewCount = 0,
    this.shareCount = 0,
    this.videoUrl,
    this.isApproved = false,
    this.createdAt,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'streamingSessionId': streamingSessionId,
    'matchId': matchId,
    'title': title,
    'description': description,
    'startTime': startTime.toString(),
    'endTime': endTime.toString(),
    'type': type.name,
    'viewCount': viewCount,
    'shareCount': shareCount,
    'videoUrl': videoUrl,
    'isApproved': isApproved,
    'createdAt': createdAt?.toIso8601String(),
    'tags': tags,
  };

  factory HighlightClip.fromJson(Map<String, dynamic> json) {
    return HighlightClip(
      id: json['id'] as String,
      streamingSessionId: json['streamingSessionId'] as String,
      matchId: json['matchId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: _parseDuration(json['startTime']),
      endTime: _parseDuration(json['endTime']),
      type: HighlightType.values.byName(
        json['type'] as String? ?? 'milestone',
      ),
      viewCount: json['viewCount'] as int? ?? 0,
      shareCount: json['shareCount'] as int? ?? 0,
      videoUrl: json['videoUrl'] as String?,
      isApproved: json['isApproved'] as bool? ?? false,
      createdAt: _parseDateTimeOrNull(json['createdAt']),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }
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
class StreamerEarnings {
  final String userId;                // Streamer ID
  final DateTime periodStart;         // Earnings period start
  final DateTime periodEnd;           // Earnings period end
  final int totalStreamMinutes;       // Total minutes streamed
  final int totalViewerMinutes;       // Total viewer-minutes
  final int totalClipViews;           // Total highlight clip views
  final double streamingRevenue;      // From stream subscriptions (JPY)
  final double clipRevenue;           // From clip views (JPY)
  final double referralRevenue;       // From referrals (JPY)
  final double totalEarnings;         // Total earnings this period (JPY)

  const StreamerEarnings({
    required this.userId,
    required this.periodStart,
    required this.periodEnd,
    this.totalStreamMinutes = 0,
    this.totalViewerMinutes = 0,
    this.totalClipViews = 0,
    this.streamingRevenue = 0.0,
    this.clipRevenue = 0.0,
    this.referralRevenue = 0.0,
    this.totalEarnings = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'periodStart': periodStart.toIso8601String(),
    'periodEnd': periodEnd.toIso8601String(),
    'totalStreamMinutes': totalStreamMinutes,
    'totalViewerMinutes': totalViewerMinutes,
    'totalClipViews': totalClipViews,
    'streamingRevenue': streamingRevenue,
    'clipRevenue': clipRevenue,
    'referralRevenue': referralRevenue,
    'totalEarnings': totalEarnings,
  };

  factory StreamerEarnings.fromJson(Map<String, dynamic> json) {
    return StreamerEarnings(
      userId: json['userId'] as String,
      periodStart: _parseDateTime(json['periodStart']),
      periodEnd: _parseDateTime(json['periodEnd']),
      totalStreamMinutes: json['totalStreamMinutes'] as int? ?? 0,
      totalViewerMinutes: json['totalViewerMinutes'] as int? ?? 0,
      totalClipViews: json['totalClipViews'] as int? ?? 0,
      streamingRevenue: (json['streamingRevenue'] as num?)?.toDouble() ?? 0.0,
      clipRevenue: (json['clipRevenue'] as num?)?.toDouble() ?? 0.0,
      referralRevenue: (json['referralRevenue'] as num?)?.toDouble() ?? 0.0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
