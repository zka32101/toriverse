
/// Helper: deep equality for List fields (avoids adding a package dependency).
bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Helper: deep equality for Map fields (avoids adding a package dependency).
bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
      return false;
    }
  }
  return true;
}

/// Generated clip from match highlight moment
///
/// Represents a video clip extracted from a match, ready for social sharing
class MatchClip {
  final String id;
  final String matchId;
  final String highlightId;
  final String creatorId;
  final String title;
  final String description;
  final int durationSeconds;
  final int startTimestamp; // Seconds into match
  final int endTimestamp;
  final String momentType; // upset, strategic_move, key_turn, final_reversal
  final bool isGenerated;
  final bool isProcessing;
  final DateTime? generatedAt;
  final DateTime? publishedAt;
  final List<String> formatIds; // IDs of formats available (square, vertical, landscape)
  final int totalViews;
  final int totalShares;
  final int totalLikes;
  final int engagementScore;

  MatchClip({
    required this.id,
    required this.matchId,
    required this.highlightId,
    required this.creatorId,
    required this.title,
    required this.description,
    int? durationSeconds,
    required this.startTimestamp,
    required this.endTimestamp,
    required this.momentType,
    this.isGenerated = false,
    this.isProcessing = false,
    this.generatedAt,
    this.publishedAt,
    this.formatIds = const [],
    this.totalViews = 0,
    this.totalShares = 0,
    this.totalLikes = 0,
    this.engagementScore = 0,
  }) : durationSeconds = durationSeconds ?? (endTimestamp - startTimestamp);

  Map<String, dynamic> toJson() => {
        'id': id,
        'matchId': matchId,
        'highlightId': highlightId,
        'creatorId': creatorId,
        'title': title,
        'description': description,
        'durationSeconds': durationSeconds,
        'startTimestamp': startTimestamp,
        'endTimestamp': endTimestamp,
        'momentType': momentType,
        'isGenerated': isGenerated,
        'isProcessing': isProcessing,
        'generatedAt': generatedAt?.toIso8601String(),
        'publishedAt': publishedAt?.toIso8601String(),
        'formatIds': formatIds,
        'totalViews': totalViews,
        'totalShares': totalShares,
        'totalLikes': totalLikes,
        'engagementScore': engagementScore,
      };

  factory MatchClip.fromJson(Map<String, dynamic> json) => MatchClip(
        id: json['id'] as String,
        matchId: json['matchId'] as String,
        highlightId: json['highlightId'] as String,
        creatorId: json['creatorId'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
        startTimestamp: (json['startTimestamp'] as num).toInt(),
        endTimestamp: (json['endTimestamp'] as num).toInt(),
        momentType: json['momentType'] as String,
        isGenerated: json['isGenerated'] as bool? ?? false,
        isProcessing: json['isProcessing'] as bool? ?? false,
        generatedAt: json['generatedAt'] != null
            ? DateTime.parse(json['generatedAt'] as String)
            : null,
        publishedAt: json['publishedAt'] != null
            ? DateTime.parse(json['publishedAt'] as String)
            : null,
        formatIds: (json['formatIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        totalViews: (json['totalViews'] as num?)?.toInt() ?? 0,
        totalShares: (json['totalShares'] as num?)?.toInt() ?? 0,
        totalLikes: (json['totalLikes'] as num?)?.toInt() ?? 0,
        engagementScore: (json['engagementScore'] as num?)?.toInt() ?? 0,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchClip &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          matchId == other.matchId &&
          highlightId == other.highlightId &&
          creatorId == other.creatorId &&
          title == other.title &&
          description == other.description &&
          durationSeconds == other.durationSeconds &&
          startTimestamp == other.startTimestamp &&
          endTimestamp == other.endTimestamp &&
          momentType == other.momentType &&
          isGenerated == other.isGenerated &&
          isProcessing == other.isProcessing &&
          generatedAt == other.generatedAt &&
          publishedAt == other.publishedAt &&
          _listEquals(formatIds, other.formatIds) &&
          totalViews == other.totalViews &&
          totalShares == other.totalShares &&
          totalLikes == other.totalLikes &&
          engagementScore == other.engagementScore;

  @override
  int get hashCode => Object.hashAll([
        id,
        matchId,
        highlightId,
        creatorId,
        title,
        description,
        durationSeconds,
        startTimestamp,
        endTimestamp,
        momentType,
        isGenerated,
        isProcessing,
        generatedAt,
        publishedAt,
        Object.hashAll(formatIds),
        totalViews,
        totalShares,
        totalLikes,
        engagementScore,
      ]);
}

/// Different format versions of a clip
///
/// Clips are generated in multiple aspect ratios for different platforms
class ClipFormat {
  final String id;
  final String clipId;
  final String aspectRatio; // 16:9, 9:16, 1:1
  final String platform; // youtube, instagram, tiktok, twitter, twitch
  final String videoUrl; // CDN URL to video file
  final String thumbnailUrl;
  final int fileSize; // Bytes
  final int bitrate; // kbps
  final String resolution; // 1080p, 720p, 480p
  final bool isReady;
  final DateTime? uploadedAt;
  final DateTime? expiredAt; // For temporary formats
  final int views;
  final int likes;
  final int shares;

  const ClipFormat({
    required this.id,
    required this.clipId,
    required this.aspectRatio,
    required this.platform,
    required this.videoUrl,
    this.thumbnailUrl = '',
    this.fileSize = 0,
    this.bitrate = 0,
    required this.resolution,
    this.isReady = false,
    this.uploadedAt,
    this.expiredAt,
    this.views = 0,
    this.likes = 0,
    this.shares = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'clipId': clipId,
        'aspectRatio': aspectRatio,
        'platform': platform,
        'videoUrl': videoUrl,
        'thumbnailUrl': thumbnailUrl,
        'fileSize': fileSize,
        'bitrate': bitrate,
        'resolution': resolution,
        'isReady': isReady,
        'uploadedAt': uploadedAt?.toIso8601String(),
        'expiredAt': expiredAt?.toIso8601String(),
        'views': views,
        'likes': likes,
        'shares': shares,
      };

  factory ClipFormat.fromJson(Map<String, dynamic> json) => ClipFormat(
        id: json['id'] as String,
        clipId: json['clipId'] as String,
        aspectRatio: json['aspectRatio'] as String,
        platform: json['platform'] as String,
        videoUrl: json['videoUrl'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
        fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
        bitrate: (json['bitrate'] as num?)?.toInt() ?? 0,
        resolution: json['resolution'] as String,
        isReady: json['isReady'] as bool? ?? false,
        uploadedAt: json['uploadedAt'] != null
            ? DateTime.parse(json['uploadedAt'] as String)
            : null,
        expiredAt: json['expiredAt'] != null
            ? DateTime.parse(json['expiredAt'] as String)
            : null,
        views: (json['views'] as num?)?.toInt() ?? 0,
        likes: (json['likes'] as num?)?.toInt() ?? 0,
        shares: (json['shares'] as num?)?.toInt() ?? 0,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClipFormat &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          clipId == other.clipId &&
          aspectRatio == other.aspectRatio &&
          platform == other.platform &&
          videoUrl == other.videoUrl &&
          thumbnailUrl == other.thumbnailUrl &&
          fileSize == other.fileSize &&
          bitrate == other.bitrate &&
          resolution == other.resolution &&
          isReady == other.isReady &&
          uploadedAt == other.uploadedAt &&
          expiredAt == other.expiredAt &&
          views == other.views &&
          likes == other.likes &&
          shares == other.shares;

  @override
  int get hashCode => Object.hashAll([
        id,
        clipId,
        aspectRatio,
        platform,
        videoUrl,
        thumbnailUrl,
        fileSize,
        bitrate,
        resolution,
        isReady,
        uploadedAt,
        expiredAt,
        views,
        likes,
        shares,
      ]);
}

/// Clip upload status to social platform
///
/// Tracks clip distribution across social media platforms
class ClipUploadStatus {
  final String id;
  final String clipId;
  final String platform; // youtube, instagram, tiktok, twitter, twitch
  final String status; // pending, uploading, uploaded, failed, processing
  final String platformClipId; // External platform ID (YouTube video ID, Instagram post ID)
  final String platformUrl; // Direct link to posted clip
  final DateTime? uploadedAt;
  final DateTime? scheduledAt; // For scheduled posts
  final String errorMessage;
  final int retryCount;
  final DateTime? lastRetryAt;

  const ClipUploadStatus({
    required this.id,
    required this.clipId,
    required this.platform,
    required this.status,
    this.platformClipId = '',
    this.platformUrl = '',
    this.uploadedAt,
    this.scheduledAt,
    this.errorMessage = '',
    this.retryCount = 0,
    this.lastRetryAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'clipId': clipId,
        'platform': platform,
        'status': status,
        'platformClipId': platformClipId,
        'platformUrl': platformUrl,
        'uploadedAt': uploadedAt?.toIso8601String(),
        'scheduledAt': scheduledAt?.toIso8601String(),
        'errorMessage': errorMessage,
        'retryCount': retryCount,
        'lastRetryAt': lastRetryAt?.toIso8601String(),
      };

  factory ClipUploadStatus.fromJson(Map<String, dynamic> json) => ClipUploadStatus(
        id: json['id'] as String,
        clipId: json['clipId'] as String,
        platform: json['platform'] as String,
        status: json['status'] as String,
        platformClipId: json['platformClipId'] as String? ?? '',
        platformUrl: json['platformUrl'] as String? ?? '',
        uploadedAt: json['uploadedAt'] != null
            ? DateTime.parse(json['uploadedAt'] as String)
            : null,
        scheduledAt: json['scheduledAt'] != null
            ? DateTime.parse(json['scheduledAt'] as String)
            : null,
        errorMessage: json['errorMessage'] as String? ?? '',
        retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
        lastRetryAt: json['lastRetryAt'] != null
            ? DateTime.parse(json['lastRetryAt'] as String)
            : null,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClipUploadStatus &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          clipId == other.clipId &&
          platform == other.platform &&
          status == other.status &&
          platformClipId == other.platformClipId &&
          platformUrl == other.platformUrl &&
          uploadedAt == other.uploadedAt &&
          scheduledAt == other.scheduledAt &&
          errorMessage == other.errorMessage &&
          retryCount == other.retryCount &&
          lastRetryAt == other.lastRetryAt;

  @override
  int get hashCode => Object.hashAll([
        id,
        clipId,
        platform,
        status,
        platformClipId,
        platformUrl,
        uploadedAt,
        scheduledAt,
        errorMessage,
        retryCount,
        lastRetryAt,
      ]);
}

/// Social sharing record
///
/// Tracks when and where clips are shared
class ClipShare {
  final String id;
  final String clipId;
  final String userId;
  final String platform; // facebook, twitter, whatsapp, telegram, email, etc
  final String shareType; // direct_link, embed, video_upload, story, etc
  final DateTime? sharedAt;
  final bool isTracked;
  final String trackingUrl; // URL with utm parameters
  final int clickCount;
  final int impressions;

  const ClipShare({
    required this.id,
    required this.clipId,
    required this.userId,
    required this.platform,
    required this.shareType,
    this.sharedAt,
    this.isTracked = false,
    this.trackingUrl = '',
    this.clickCount = 0,
    this.impressions = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'clipId': clipId,
        'userId': userId,
        'platform': platform,
        'shareType': shareType,
        'sharedAt': sharedAt?.toIso8601String(),
        'isTracked': isTracked,
        'trackingUrl': trackingUrl,
        'clickCount': clickCount,
        'impressions': impressions,
      };

  factory ClipShare.fromJson(Map<String, dynamic> json) => ClipShare(
        id: json['id'] as String,
        clipId: json['clipId'] as String,
        userId: json['userId'] as String,
        platform: json['platform'] as String,
        shareType: json['shareType'] as String,
        sharedAt: json['sharedAt'] != null
            ? DateTime.parse(json['sharedAt'] as String)
            : null,
        isTracked: json['isTracked'] as bool? ?? false,
        trackingUrl: json['trackingUrl'] as String? ?? '',
        clickCount: (json['clickCount'] as num?)?.toInt() ?? 0,
        impressions: (json['impressions'] as num?)?.toInt() ?? 0,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClipShare &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          clipId == other.clipId &&
          userId == other.userId &&
          platform == other.platform &&
          shareType == other.shareType &&
          sharedAt == other.sharedAt &&
          isTracked == other.isTracked &&
          trackingUrl == other.trackingUrl &&
          clickCount == other.clickCount &&
          impressions == other.impressions;

  @override
  int get hashCode => Object.hashAll([
        id,
        clipId,
        userId,
        platform,
        shareType,
        sharedAt,
        isTracked,
        trackingUrl,
        clickCount,
        impressions,
      ]);
}

/// Clip engagement metrics
///
/// Aggregated view/like/share counts across all platforms
class ClipMetrics {
  final String id;
  final String clipId;
  final int totalViews;
  final int youtubeViews;
  final int instagramViews;
  final int tiktokViews;
  final int twitterViews;
  final int twitchViews;
  final int totalLikes;
  final int totalShares;
  final int totalComments;
  final int totalClicks;
  final double avgEngagementRate; // (likes + comments + shares) / views
  final int viralScore; // Custom metric for virality
  final DateTime? updatedAt;

  const ClipMetrics({
    required this.id,
    required this.clipId,
    this.totalViews = 0,
    this.youtubeViews = 0,
    this.instagramViews = 0,
    this.tiktokViews = 0,
    this.twitterViews = 0,
    this.twitchViews = 0,
    this.totalLikes = 0,
    this.totalShares = 0,
    this.totalComments = 0,
    this.totalClicks = 0,
    this.avgEngagementRate = 0.0,
    this.viralScore = 0,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'clipId': clipId,
        'totalViews': totalViews,
        'youtubeViews': youtubeViews,
        'instagramViews': instagramViews,
        'tiktokViews': tiktokViews,
        'twitterViews': twitterViews,
        'twitchViews': twitchViews,
        'totalLikes': totalLikes,
        'totalShares': totalShares,
        'totalComments': totalComments,
        'totalClicks': totalClicks,
        'avgEngagementRate': avgEngagementRate,
        'viralScore': viralScore,
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory ClipMetrics.fromJson(Map<String, dynamic> json) => ClipMetrics(
        id: json['id'] as String,
        clipId: json['clipId'] as String,
        totalViews: (json['totalViews'] as num?)?.toInt() ?? 0,
        youtubeViews: (json['youtubeViews'] as num?)?.toInt() ?? 0,
        instagramViews: (json['instagramViews'] as num?)?.toInt() ?? 0,
        tiktokViews: (json['tiktokViews'] as num?)?.toInt() ?? 0,
        twitterViews: (json['twitterViews'] as num?)?.toInt() ?? 0,
        twitchViews: (json['twitchViews'] as num?)?.toInt() ?? 0,
        totalLikes: (json['totalLikes'] as num?)?.toInt() ?? 0,
        totalShares: (json['totalShares'] as num?)?.toInt() ?? 0,
        totalComments: (json['totalComments'] as num?)?.toInt() ?? 0,
        totalClicks: (json['totalClicks'] as num?)?.toInt() ?? 0,
        avgEngagementRate: (json['avgEngagementRate'] as num?)?.toDouble() ?? 0.0,
        viralScore: (json['viralScore'] as num?)?.toInt() ?? 0,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClipMetrics &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          clipId == other.clipId &&
          totalViews == other.totalViews &&
          youtubeViews == other.youtubeViews &&
          instagramViews == other.instagramViews &&
          tiktokViews == other.tiktokViews &&
          twitterViews == other.twitterViews &&
          twitchViews == other.twitchViews &&
          totalLikes == other.totalLikes &&
          totalShares == other.totalShares &&
          totalComments == other.totalComments &&
          totalClicks == other.totalClicks &&
          avgEngagementRate == other.avgEngagementRate &&
          viralScore == other.viralScore &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hashAll([
        id,
        clipId,
        totalViews,
        youtubeViews,
        instagramViews,
        tiktokViews,
        twitterViews,
        twitchViews,
        totalLikes,
        totalShares,
        totalComments,
        totalClicks,
        avgEngagementRate,
        viralScore,
        updatedAt,
      ]);
}

/// Clip generation configuration
///
/// Settings for how clips should be generated
class ClipGenerationConfig {
  final String id;
  final String template; // standard, highlight_reel, dramatic, funny, etc
  final bool includeMusic;
  final String bgmTrackId;
  final double bgmVolume; // 0.0 - 1.0
  final bool includeEffects; // Transitions, overlays, animations
  final bool includeTextOverlay; // Player names, scores, stats
  final String textStyle; // default, modern, retro, minimal
  final bool autoGenerateThumbnail;
  final bool generateVertical; // 9:16 for TikTok/Instagram
  final bool generateSquare; // 1:1 for Instagram/Twitter
  final bool generateLandscape; // 16:9 for YouTube/Twitch
  final String colorGrade; // Color grading preset
  final double playbackSpeed; // Slow-mo or speed-up
  final List<String> platforms; // Which platforms to generate for

  const ClipGenerationConfig({
    required this.id,
    this.template = 'standard',
    this.includeMusic = true,
    this.bgmTrackId = '',
    this.bgmVolume = 1.0,
    this.includeEffects = true,
    this.includeTextOverlay = true,
    this.textStyle = 'default',
    this.autoGenerateThumbnail = true,
    this.generateVertical = true,
    this.generateSquare = true,
    this.generateLandscape = true,
    this.colorGrade = '',
    this.playbackSpeed = 1.0,
    this.platforms = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'template': template,
        'includeMusic': includeMusic,
        'bgmTrackId': bgmTrackId,
        'bgmVolume': bgmVolume,
        'includeEffects': includeEffects,
        'includeTextOverlay': includeTextOverlay,
        'textStyle': textStyle,
        'autoGenerateThumbnail': autoGenerateThumbnail,
        'generateVertical': generateVertical,
        'generateSquare': generateSquare,
        'generateLandscape': generateLandscape,
        'colorGrade': colorGrade,
        'playbackSpeed': playbackSpeed,
        'platforms': platforms,
      };

  factory ClipGenerationConfig.fromJson(Map<String, dynamic> json) => ClipGenerationConfig(
        id: json['id'] as String,
        template: json['template'] as String? ?? 'standard',
        includeMusic: json['includeMusic'] as bool? ?? true,
        bgmTrackId: json['bgmTrackId'] as String? ?? '',
        bgmVolume: (json['bgmVolume'] as num?)?.toDouble() ?? 1.0,
        includeEffects: json['includeEffects'] as bool? ?? true,
        includeTextOverlay: json['includeTextOverlay'] as bool? ?? true,
        textStyle: json['textStyle'] as String? ?? 'default',
        autoGenerateThumbnail: json['autoGenerateThumbnail'] as bool? ?? true,
        generateVertical: json['generateVertical'] as bool? ?? true,
        generateSquare: json['generateSquare'] as bool? ?? true,
        generateLandscape: json['generateLandscape'] as bool? ?? true,
        colorGrade: json['colorGrade'] as String? ?? '',
        playbackSpeed: (json['playbackSpeed'] as num?)?.toDouble() ?? 1.0,
        platforms: (json['platforms'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClipGenerationConfig &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          template == other.template &&
          includeMusic == other.includeMusic &&
          bgmTrackId == other.bgmTrackId &&
          bgmVolume == other.bgmVolume &&
          includeEffects == other.includeEffects &&
          includeTextOverlay == other.includeTextOverlay &&
          textStyle == other.textStyle &&
          autoGenerateThumbnail == other.autoGenerateThumbnail &&
          generateVertical == other.generateVertical &&
          generateSquare == other.generateSquare &&
          generateLandscape == other.generateLandscape &&
          colorGrade == other.colorGrade &&
          playbackSpeed == other.playbackSpeed &&
          _listEquals(platforms, other.platforms);

  @override
  int get hashCode => Object.hashAll([
        id,
        template,
        includeMusic,
        bgmTrackId,
        bgmVolume,
        includeEffects,
        includeTextOverlay,
        textStyle,
        autoGenerateThumbnail,
        generateVertical,
        generateSquare,
        generateLandscape,
        colorGrade,
        playbackSpeed,
        Object.hashAll(platforms),
      ]);
}

/// Clip generation job
///
/// Tracks the progress of clip generation from highlight to finished product
class ClipGenerationJob {
  final String id;
  final String clipId;
  final String status; // queued, processing, completed, failed
  final double progress; // 0.0 - 1.0
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String errorMessage;
  final int retryCount;
  final String processorId; // ID of processing worker
  final Map<String, dynamic> processingMetadata;

  const ClipGenerationJob({
    required this.id,
    required this.clipId,
    required this.status,
    this.progress = 0.0,
    this.startedAt,
    this.completedAt,
    this.errorMessage = '',
    this.retryCount = 0,
    this.processorId = '',
    this.processingMetadata = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'clipId': clipId,
        'status': status,
        'progress': progress,
        'startedAt': startedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'errorMessage': errorMessage,
        'retryCount': retryCount,
        'processorId': processorId,
        'processingMetadata': processingMetadata,
      };

  factory ClipGenerationJob.fromJson(Map<String, dynamic> json) => ClipGenerationJob(
        id: json['id'] as String,
        clipId: json['clipId'] as String,
        status: json['status'] as String,
        progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
        startedAt: json['startedAt'] != null
            ? DateTime.parse(json['startedAt'] as String)
            : null,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
        errorMessage: json['errorMessage'] as String? ?? '',
        retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
        processorId: json['processorId'] as String? ?? '',
        processingMetadata: json['processingMetadata'] != null
            ? Map<String, dynamic>.from(json['processingMetadata'] as Map)
            : const {},
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClipGenerationJob &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          clipId == other.clipId &&
          status == other.status &&
          progress == other.progress &&
          startedAt == other.startedAt &&
          completedAt == other.completedAt &&
          errorMessage == other.errorMessage &&
          retryCount == other.retryCount &&
          processorId == other.processorId &&
          _mapEquals(processingMetadata, other.processingMetadata);

  @override
  int get hashCode => Object.hashAll([
        id,
        clipId,
        status,
        progress,
        startedAt,
        completedAt,
        errorMessage,
        retryCount,
        processorId,
        Object.hashAll(processingMetadata.entries.map((e) => Object.hash(e.key, e.value))),
      ]);
}

/// Clip recommendation
///
/// Clips recommended to viewers based on viewing history
class ClipRecommendation {
  final String id;
  final String userId;
  final String clipId;
  final String reason; // similar_match, trending, liked_by_friends, etc
  final double relevanceScore; // 0.0 - 1.0
  final DateTime? recommendedAt;
  final bool isClicked;
  final DateTime? clickedAt;
  final bool isShared;

  const ClipRecommendation({
    required this.id,
    required this.userId,
    required this.clipId,
    this.reason = '',
    this.relevanceScore = 0.0,
    this.recommendedAt,
    this.isClicked = false,
    this.clickedAt,
    this.isShared = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'clipId': clipId,
        'reason': reason,
        'relevanceScore': relevanceScore,
        'recommendedAt': recommendedAt?.toIso8601String(),
        'isClicked': isClicked,
        'clickedAt': clickedAt?.toIso8601String(),
        'isShared': isShared,
      };

  factory ClipRecommendation.fromJson(Map<String, dynamic> json) => ClipRecommendation(
        id: json['id'] as String,
        userId: json['userId'] as String,
        clipId: json['clipId'] as String,
        reason: json['reason'] as String? ?? '',
        relevanceScore: (json['relevanceScore'] as num?)?.toDouble() ?? 0.0,
        recommendedAt: json['recommendedAt'] != null
            ? DateTime.parse(json['recommendedAt'] as String)
            : null,
        isClicked: json['isClicked'] as bool? ?? false,
        clickedAt: json['clickedAt'] != null
            ? DateTime.parse(json['clickedAt'] as String)
            : null,
        isShared: json['isShared'] as bool? ?? false,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClipRecommendation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          clipId == other.clipId &&
          reason == other.reason &&
          relevanceScore == other.relevanceScore &&
          recommendedAt == other.recommendedAt &&
          isClicked == other.isClicked &&
          clickedAt == other.clickedAt &&
          isShared == other.isShared;

  @override
  int get hashCode => Object.hashAll([
        id,
        userId,
        clipId,
        reason,
        relevanceScore,
        recommendedAt,
        isClicked,
        clickedAt,
        isShared,
      ]);
}

/// Trending clip
///
/// Clips currently trending on the platform
class TrendingClip {
  final String rank;
  final String clipId;
  final String title;
  final int viewsLast24h;
  final int sharesLast24h;
  final double trendingVelocity; // Growth rate
  final int totalViews;
  final String thumbnailUrl;
  final DateTime? trendingStartedAt;
  final bool isFeatured;

  const TrendingClip({
    required this.rank,
    required this.clipId,
    required this.title,
    this.viewsLast24h = 0,
    this.sharesLast24h = 0,
    this.trendingVelocity = 0.0,
    this.totalViews = 0,
    this.thumbnailUrl = '',
    this.trendingStartedAt,
    this.isFeatured = false,
  });

  Map<String, dynamic> toJson() => {
        'rank': rank,
        'clipId': clipId,
        'title': title,
        'viewsLast24h': viewsLast24h,
        'sharesLast24h': sharesLast24h,
        'trendingVelocity': trendingVelocity,
        'totalViews': totalViews,
        'thumbnailUrl': thumbnailUrl,
        'trendingStartedAt': trendingStartedAt?.toIso8601String(),
        'isFeatured': isFeatured,
      };

  factory TrendingClip.fromJson(Map<String, dynamic> json) => TrendingClip(
        rank: json['rank'] as String,
        clipId: json['clipId'] as String,
        title: json['title'] as String,
        viewsLast24h: (json['viewsLast24h'] as num?)?.toInt() ?? 0,
        sharesLast24h: (json['sharesLast24h'] as num?)?.toInt() ?? 0,
        trendingVelocity: (json['trendingVelocity'] as num?)?.toDouble() ?? 0.0,
        totalViews: (json['totalViews'] as num?)?.toInt() ?? 0,
        thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
        trendingStartedAt: json['trendingStartedAt'] != null
            ? DateTime.parse(json['trendingStartedAt'] as String)
            : null,
        isFeatured: json['isFeatured'] as bool? ?? false,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrendingClip &&
          runtimeType == other.runtimeType &&
          rank == other.rank &&
          clipId == other.clipId &&
          title == other.title &&
          viewsLast24h == other.viewsLast24h &&
          sharesLast24h == other.sharesLast24h &&
          trendingVelocity == other.trendingVelocity &&
          totalViews == other.totalViews &&
          thumbnailUrl == other.thumbnailUrl &&
          trendingStartedAt == other.trendingStartedAt &&
          isFeatured == other.isFeatured;

  @override
  int get hashCode => Object.hashAll([
        rank,
        clipId,
        title,
        viewsLast24h,
        sharesLast24h,
        trendingVelocity,
        totalViews,
        thumbnailUrl,
        trendingStartedAt,
        isFeatured,
      ]);
}

/// Clip creator profile
///
/// Statistics for clip creators
class ClipCreatorProfile {
  final String userId;
  final int totalClipsCreated;
  final int totalViews;
  final int totalShares;
  final int totalLikes;
  final double avgEngagementRate;
  final int viralClips; // Clips with > 100k views
  final DateTime? lastClipAt;
  final int followerCount;
  final bool isVerified;
  final int creatorRating; // 1-5 stars

  const ClipCreatorProfile({
    required this.userId,
    this.totalClipsCreated = 0,
    this.totalViews = 0,
    this.totalShares = 0,
    this.totalLikes = 0,
    this.avgEngagementRate = 0.0,
    this.viralClips = 0,
    this.lastClipAt,
    this.followerCount = 0,
    this.isVerified = false,
    this.creatorRating = 0,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'totalClipsCreated': totalClipsCreated,
        'totalViews': totalViews,
        'totalShares': totalShares,
        'totalLikes': totalLikes,
        'avgEngagementRate': avgEngagementRate,
        'viralClips': viralClips,
        'lastClipAt': lastClipAt?.toIso8601String(),
        'followerCount': followerCount,
        'isVerified': isVerified,
        'creatorRating': creatorRating,
      };

  factory ClipCreatorProfile.fromJson(Map<String, dynamic> json) => ClipCreatorProfile(
        userId: json['userId'] as String,
        totalClipsCreated: (json['totalClipsCreated'] as num?)?.toInt() ?? 0,
        totalViews: (json['totalViews'] as num?)?.toInt() ?? 0,
        totalShares: (json['totalShares'] as num?)?.toInt() ?? 0,
        totalLikes: (json['totalLikes'] as num?)?.toInt() ?? 0,
        avgEngagementRate: (json['avgEngagementRate'] as num?)?.toDouble() ?? 0.0,
        viralClips: (json['viralClips'] as num?)?.toInt() ?? 0,
        lastClipAt: json['lastClipAt'] != null
            ? DateTime.parse(json['lastClipAt'] as String)
            : null,
        followerCount: (json['followerCount'] as num?)?.toInt() ?? 0,
        isVerified: json['isVerified'] as bool? ?? false,
        creatorRating: (json['creatorRating'] as num?)?.toInt() ?? 0,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClipCreatorProfile &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          totalClipsCreated == other.totalClipsCreated &&
          totalViews == other.totalViews &&
          totalShares == other.totalShares &&
          totalLikes == other.totalLikes &&
          avgEngagementRate == other.avgEngagementRate &&
          viralClips == other.viralClips &&
          lastClipAt == other.lastClipAt &&
          followerCount == other.followerCount &&
          isVerified == other.isVerified &&
          creatorRating == other.creatorRating;

  @override
  int get hashCode => Object.hashAll([
        userId,
        totalClipsCreated,
        totalViews,
        totalShares,
        totalLikes,
        avgEngagementRate,
        viralClips,
        lastClipAt,
        followerCount,
        isVerified,
        creatorRating,
      ]);
}

/// Clip comment/reaction
///
/// User reactions to clips on the platform
class ClipComment {
  final String id;
  final String clipId;
  final String userId;
  final String displayName;
  final String comment;
  final DateTime? createdAt;
  final int likes;
  final List<String> likedBy;
  final String platform; // Which platform this comment is from
  final String platformCommentId;

  const ClipComment({
    required this.id,
    required this.clipId,
    required this.userId,
    required this.displayName,
    required this.comment,
    this.createdAt,
    this.likes = 0,
    this.likedBy = const [],
    this.platform = '',
    this.platformCommentId = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'clipId': clipId,
        'userId': userId,
        'displayName': displayName,
        'comment': comment,
        'createdAt': createdAt?.toIso8601String(),
        'likes': likes,
        'likedBy': likedBy,
        'platform': platform,
        'platformCommentId': platformCommentId,
      };

  factory ClipComment.fromJson(Map<String, dynamic> json) => ClipComment(
        id: json['id'] as String,
        clipId: json['clipId'] as String,
        userId: json['userId'] as String,
        displayName: json['displayName'] as String,
        comment: json['comment'] as String,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        likes: (json['likes'] as num?)?.toInt() ?? 0,
        likedBy: (json['likedBy'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        platform: json['platform'] as String? ?? '',
        platformCommentId: json['platformCommentId'] as String? ?? '',
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClipComment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          clipId == other.clipId &&
          userId == other.userId &&
          displayName == other.displayName &&
          comment == other.comment &&
          createdAt == other.createdAt &&
          likes == other.likes &&
          _listEquals(likedBy, other.likedBy) &&
          platform == other.platform &&
          platformCommentId == other.platformCommentId;

  @override
  int get hashCode => Object.hashAll([
        id,
        clipId,
        userId,
        displayName,
        comment,
        createdAt,
        likes,
        Object.hashAll(likedBy),
        platform,
        platformCommentId,
      ]);
}

/// Viral tracking data
///
/// Tracks how clips spread across the network
class ViralTrackingData {
  final String id;
  final String clipId;
  final int totalShares;
  final List<String> sharedByUserIds;
  final int shareDepth; // Max distance from original sharer
  final int uniqueReachers; // Unique users who saw the clip via shares
  final double viralCoefficient; // Avg shares per viewer
  final DateTime? measuredAt;
  final List<String> topSharerIds; // Most active sharers

  const ViralTrackingData({
    required this.id,
    required this.clipId,
    this.totalShares = 0,
    this.sharedByUserIds = const [],
    this.shareDepth = 0,
    this.uniqueReachers = 0,
    this.viralCoefficient = 0.0,
    this.measuredAt,
    this.topSharerIds = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'clipId': clipId,
        'totalShares': totalShares,
        'sharedByUserIds': sharedByUserIds,
        'shareDepth': shareDepth,
        'uniqueReachers': uniqueReachers,
        'viralCoefficient': viralCoefficient,
        'measuredAt': measuredAt?.toIso8601String(),
        'topSharerIds': topSharerIds,
      };

  factory ViralTrackingData.fromJson(Map<String, dynamic> json) => ViralTrackingData(
        id: json['id'] as String,
        clipId: json['clipId'] as String,
        totalShares: (json['totalShares'] as num?)?.toInt() ?? 0,
        sharedByUserIds: (json['sharedByUserIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        shareDepth: (json['shareDepth'] as num?)?.toInt() ?? 0,
        uniqueReachers: (json['uniqueReachers'] as num?)?.toInt() ?? 0,
        viralCoefficient: (json['viralCoefficient'] as num?)?.toDouble() ?? 0.0,
        measuredAt: json['measuredAt'] != null
            ? DateTime.parse(json['measuredAt'] as String)
            : null,
        topSharerIds: (json['topSharerIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViralTrackingData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          clipId == other.clipId &&
          totalShares == other.totalShares &&
          _listEquals(sharedByUserIds, other.sharedByUserIds) &&
          shareDepth == other.shareDepth &&
          uniqueReachers == other.uniqueReachers &&
          viralCoefficient == other.viralCoefficient &&
          measuredAt == other.measuredAt &&
          _listEquals(topSharerIds, other.topSharerIds);

  @override
  int get hashCode => Object.hashAll([
        id,
        clipId,
        totalShares,
        Object.hashAll(sharedByUserIds),
        shareDepth,
        uniqueReachers,
        viralCoefficient,
        measuredAt,
        Object.hashAll(topSharerIds),
      ]);
}
