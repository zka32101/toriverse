import 'package:freezed_annotation/freezed_annotation.dart';

/// Generated clip from match highlight moment
///
/// Represents a video clip extracted from a match, ready for social sharing
class MatchClip {
  const MatchClip({
    required String id,
    required String matchId,
    required String highlightId,
    required String creatorId,
    required String title,
    required String description,
    int durationSeconds,
    int startTimestamp, // Seconds into match
    int endTimestamp,
    required String momentType, // upset, strategic_move, key_turn, final_reversal
    bool isGenerated,
    bool isProcessing,
    DateTime? generatedAt,
    DateTime? publishedAt,
    List<String> formatIds, // IDs of formats available (square, vertical, landscape)
    int totalViews,
    int totalShares,
    int totalLikes,
    int engagementScore,
  });
}

/// Different format versions of a clip
///
/// Clips are generated in multiple aspect ratios for different platforms
class ClipFormat {
  const ClipFormat({
    required String id,
    required String clipId,
    required String aspectRatio, // 16:9, 9:16, 1:1
    required String platform, // youtube, instagram, tiktok, twitter, twitch
    required String videoUrl, // CDN URL to video file
    String thumbnailUrl,
    int fileSize, // Bytes
    int bitrate, // kbps
    required String resolution, // 1080p, 720p, 480p
    bool isReady,
    DateTime? uploadedAt,
    DateTime? expiredAt, // For temporary formats
    int views,
    int likes,
    int shares,
  });
}

/// Clip upload status to social platform
///
/// Tracks clip distribution across social media platforms
class ClipUploadStatus {
  const ClipUploadStatus({
    required String id,
    required String clipId,
    required String platform, // youtube, instagram, tiktok, twitter, twitch
    required String status, // pending, uploading, uploaded, failed, processing
    String platformClipId, // External platform ID (YouTube video ID, Instagram post ID)
    String platformUrl, // Direct link to posted clip
    DateTime? uploadedAt,
    DateTime? scheduledAt, // For scheduled posts
    String errorMessage,
    int retryCount,
    DateTime? lastRetryAt,
  });
}

/// Social sharing record
///
/// Tracks when and where clips are shared
class ClipShare {
  const ClipShare({
    required String id,
    required String clipId,
    required String userId,
    required String platform, // facebook, twitter, whatsapp, telegram, email, etc
    required String shareType, // direct_link, embed, video_upload, story, etc
    DateTime? sharedAt,
    bool isTracked,
    String trackingUrl, // URL with utm parameters
    int clickCount,
    int impressions,
  });
}

/// Clip engagement metrics
///
/// Aggregated view/like/share counts across all platforms
class ClipMetrics {
  const ClipMetrics({
    required String id,
    required String clipId,
    int totalViews,
    int youtubeViews,
    int instagramViews,
    int tiktokViews,
    int twitterViews,
    int twitchViews,
    int totalLikes,
    int totalShares,
    int totalComments,
    int totalClicks,
    double avgEngagementRate, // (likes + comments + shares) / views
    int viralScore, // Custom metric for virality
    DateTime? updatedAt,
  });
}

/// Clip generation configuration
///
/// Settings for how clips should be generated
class ClipGenerationConfig {
  const ClipGenerationConfig({
    required String id,
    String template, // standard, highlight_reel, dramatic, funny, etc
    bool includeMusic,
    String bgmTrackId,
    double bgmVolume, // 0.0 - 1.0
    bool includeEffects, // Transitions, overlays, animations
    bool includeTextOverlay, // Player names, scores, stats
    String textStyle, // default, modern, retro, minimal
    bool autoGenerateThumbnail,
    bool generateVertical, // 9:16 for TikTok/Instagram
    bool generateSquare, // 1:1 for Instagram/Twitter
    bool generateLandscape, // 16:9 for YouTube/Twitch
    String colorGrade, // Color grading preset
    double playbackSpeed, // Slow-mo or speed-up
    List<String> platforms, // Which platforms to generate for
  });
}

/// Clip generation job
///
/// Tracks the progress of clip generation from highlight to finished product
class ClipGenerationJob {
  const ClipGenerationJob({
    required String id,
    required String clipId,
    required String status, // queued, processing, completed, failed
    double progress, // 0.0 - 1.0
    DateTime? startedAt,
    DateTime? completedAt,
    String errorMessage,
    int retryCount,
    String processorId, // ID of processing worker
    Map<String, dynamic> processingMetadata,
  });
}

/// Clip recommendation
///
/// Clips recommended to viewers based on viewing history
class ClipRecommendation {
  const ClipRecommendation({
    required String id,
    required String userId,
    required String clipId,
    String reason, // similar_match, trending, liked_by_friends, etc
    double relevanceScore, // 0.0 - 1.0
    DateTime? recommendedAt,
    bool isClicked,
    DateTime? clickedAt,
    bool isShared,
  });
}

/// Trending clip
///
/// Clips currently trending on the platform
class TrendingClip {
  const TrendingClip({
    required String rank,
    required String clipId,
    required String title,
    int viewsLast24h,
    int sharesLast24h,
    double trendingVelocity, // Growth rate
    int totalViews,
    String thumbnailUrl,
    DateTime? trendingStartedAt,
    bool isFeatured,
  });
}

/// Clip creator profile
///
/// Statistics for clip creators
class ClipCreatorProfile {
  const ClipCreatorProfile({
    required String userId,
    int totalClipsCreated,
    int totalViews,
    int totalShares,
    int totalLikes,
    double avgEngagementRate,
    int viralClips, // Clips with > 100k views
    DateTime? lastClipAt,
    int followerCount,
    bool isVerified,
    int creatorRating, // 1-5 stars
  });
}

/// Clip comment/reaction
///
/// User reactions to clips on the platform
class ClipComment {
  const ClipComment({
    required String id,
    required String clipId,
    required String userId,
    required String displayName,
    required String comment,
    DateTime? createdAt,
    int likes,
    List<String> likedBy,
    String platform, // Which platform this comment is from
    String platformCommentId,
  });
}

/// Viral tracking data
///
/// Tracks how clips spread across the network
class ViralTrackingData {
  const ViralTrackingData({
    required String id,
    required String clipId,
    int totalShares,
    List<String> sharedByUserIds,
    int shareDepth, // Max distance from original sharer
    int uniqueReachers, // Unique users who saw the clip via shares
    double viralCoefficient, // Avg shares per viewer
    DateTime? measuredAt,
    List<String> topSharerIds, // Most active sharers
  });
}
