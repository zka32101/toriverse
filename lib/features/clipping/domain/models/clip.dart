import 'package:freezed_annotation/freezed_annotation.dart';

part 'clip.freezed.dart';
part 'clip.g.dart';

/// Generated clip from match highlight moment
///
/// Represents a video clip extracted from a match, ready for social sharing
@freezed
class MatchClip with _$MatchClip {
  const factory MatchClip({
    required String id,
    required String matchId,
    required String highlightId,
    required String creatorId,
    required String title,
    required String description,
    @Default(0) int durationSeconds,
    @Default(0) int startTimestamp, // Seconds into match
    @Default(0) int endTimestamp,
    required String momentType, // upset, strategic_move, key_turn, final_reversal
    @Default(false) bool isGenerated,
    @Default(false) bool isProcessing,
    DateTime? generatedAt,
    DateTime? publishedAt,
    @Default([]) List<String> formatIds, // IDs of formats available (square, vertical, landscape)
    @Default(0) int totalViews,
    @Default(0) int totalShares,
    @Default(0) int totalLikes,
    @Default(0) int engagementScore,
  }) = _MatchClip;

  factory MatchClip.fromJson(Map<String, dynamic> json) =>
      _$MatchClipFromJson(json);
}

/// Different format versions of a clip
///
/// Clips are generated in multiple aspect ratios for different platforms
@freezed
class ClipFormat with _$ClipFormat {
  const factory ClipFormat({
    required String id,
    required String clipId,
    required String aspectRatio, // 16:9, 9:16, 1:1
    required String platform, // youtube, instagram, tiktok, twitter, twitch
    required String videoUrl, // CDN URL to video file
    @Default('') String thumbnailUrl,
    @Default(0) int fileSize, // Bytes
    @Default(0) int bitrate, // kbps
    required String resolution, // 1080p, 720p, 480p
    @Default(false) bool isReady,
    DateTime? uploadedAt,
    DateTime? expiredAt, // For temporary formats
    @Default(0) int views,
    @Default(0) int likes,
    @Default(0) int shares,
  }) = _ClipFormat;

  factory ClipFormat.fromJson(Map<String, dynamic> json) =>
      _$ClipFormatFromJson(json);
}

/// Clip upload status to social platform
///
/// Tracks clip distribution across social media platforms
@freezed
class ClipUploadStatus with _$ClipUploadStatus {
  const factory ClipUploadStatus({
    required String id,
    required String clipId,
    required String platform, // youtube, instagram, tiktok, twitter, twitch
    required String status, // pending, uploading, uploaded, failed, processing
    @Default('') String platformClipId, // External platform ID (YouTube video ID, Instagram post ID)
    @Default('') String platformUrl, // Direct link to posted clip
    DateTime? uploadedAt,
    DateTime? scheduledAt, // For scheduled posts
    @Default('') String errorMessage,
    @Default(0) int retryCount,
    DateTime? lastRetryAt,
  }) = _ClipUploadStatus;

  factory ClipUploadStatus.fromJson(Map<String, dynamic> json) =>
      _$ClipUploadStatusFromJson(json);
}

/// Social sharing record
///
/// Tracks when and where clips are shared
@freezed
class ClipShare with _$ClipShare {
  const factory ClipShare({
    required String id,
    required String clipId,
    required String userId,
    required String platform, // facebook, twitter, whatsapp, telegram, email, etc
    required String shareType, // direct_link, embed, video_upload, story, etc
    DateTime? sharedAt,
    @Default(false) bool isTracked,
    @Default('') String trackingUrl, // URL with utm parameters
    @Default(0) int clickCount,
    @Default(0) int impressions,
  }) = _ClipShare;

  factory ClipShare.fromJson(Map<String, dynamic> json) =>
      _$ClipShareFromJson(json);
}

/// Clip engagement metrics
///
/// Aggregated view/like/share counts across all platforms
@freezed
class ClipMetrics with _$ClipMetrics {
  const factory ClipMetrics({
    required String id,
    required String clipId,
    @Default(0) int totalViews,
    @Default(0) int youtubeViews,
    @Default(0) int instagramViews,
    @Default(0) int tiktokViews,
    @Default(0) int twitterViews,
    @Default(0) int twitchViews,
    @Default(0) int totalLikes,
    @Default(0) int totalShares,
    @Default(0) int totalComments,
    @Default(0) int totalClicks,
    @Default(0.0) double avgEngagementRate, // (likes + comments + shares) / views
    @Default(0) int viralScore, // Custom metric for virality
    DateTime? updatedAt,
  }) = _ClipMetrics;

  factory ClipMetrics.fromJson(Map<String, dynamic> json) =>
      _$ClipMetricsFromJson(json);
}

/// Clip generation configuration
///
/// Settings for how clips should be generated
@freezed
class ClipGenerationConfig with _$ClipGenerationConfig {
  const factory ClipGenerationConfig({
    required String id,
    @Default('standard') String template, // standard, highlight_reel, dramatic, funny, etc
    @Default(true) bool includeMusic,
    @Default('') String bgmTrackId,
    @Default(1.0) double bgmVolume, // 0.0 - 1.0
    @Default(true) bool includeEffects, // Transitions, overlays, animations
    @Default(true) bool includeTextOverlay, // Player names, scores, stats
    @Default('default') String textStyle, // default, modern, retro, minimal
    @Default(true) bool autoGenerateThumbnail,
    @Default(true) bool generateVertical, // 9:16 for TikTok/Instagram
    @Default(true) bool generateSquare, // 1:1 for Instagram/Twitter
    @Default(true) bool generateLandscape, // 16:9 for YouTube/Twitch
    @Default('') String colorGrade, // Color grading preset
    @Default(1.0) double playbackSpeed, // Slow-mo or speed-up
    @Default([]) List<String> platforms, // Which platforms to generate for
  }) = _ClipGenerationConfig;

  factory ClipGenerationConfig.fromJson(Map<String, dynamic> json) =>
      _$ClipGenerationConfigFromJson(json);
}

/// Clip generation job
///
/// Tracks the progress of clip generation from highlight to finished product
@freezed
class ClipGenerationJob with _$ClipGenerationJob {
  const factory ClipGenerationJob({
    required String id,
    required String clipId,
    required String status, // queued, processing, completed, failed
    @Default(0.0) double progress, // 0.0 - 1.0
    DateTime? startedAt,
    DateTime? completedAt,
    @Default('') String errorMessage,
    @Default(0) int retryCount,
    @Default('') String processorId, // ID of processing worker
    @Default({}) Map<String, dynamic> processingMetadata,
  }) = _ClipGenerationJob;

  factory ClipGenerationJob.fromJson(Map<String, dynamic> json) =>
      _$ClipGenerationJobFromJson(json);
}

/// Clip recommendation
///
/// Clips recommended to viewers based on viewing history
@freezed
class ClipRecommendation with _$ClipRecommendation {
  const factory ClipRecommendation({
    required String id,
    required String userId,
    required String clipId,
    @Default('') String reason, // similar_match, trending, liked_by_friends, etc
    @Default(0.0) double relevanceScore, // 0.0 - 1.0
    DateTime? recommendedAt,
    @Default(false) bool isClicked,
    DateTime? clickedAt,
    @Default(false) bool isShared,
  }) = _ClipRecommendation;

  factory ClipRecommendation.fromJson(Map<String, dynamic> json) =>
      _$ClipRecommendationFromJson(json);
}

/// Trending clip
///
/// Clips currently trending on the platform
@freezed
class TrendingClip with _$TrendingClip {
  const factory TrendingClip({
    required String rank,
    required String clipId,
    required String title,
    @Default(0) int viewsLast24h,
    @Default(0) int sharesLast24h,
    @Default(0.0) double trendingVelocity, // Growth rate
    @Default(0) int totalViews,
    @Default('') String thumbnailUrl,
    DateTime? trendingStartedAt,
    @Default(false) bool isFeatured,
  }) = _TrendingClip;

  factory TrendingClip.fromJson(Map<String, dynamic> json) =>
      _$TrendingClipFromJson(json);
}

/// Clip creator profile
///
/// Statistics for clip creators
@freezed
class ClipCreatorProfile with _$ClipCreatorProfile {
  const factory ClipCreatorProfile({
    required String userId,
    @Default(0) int totalClipsCreated,
    @Default(0) int totalViews,
    @Default(0) int totalShares,
    @Default(0) int totalLikes,
    @Default(0.0) double avgEngagementRate,
    @Default(0) int viralClips, // Clips with > 100k views
    DateTime? lastClipAt,
    @Default(0) int followerCount,
    @Default(false) bool isVerified,
    @Default(0) int creatorRating, // 1-5 stars
  }) = _ClipCreatorProfile;

  factory ClipCreatorProfile.fromJson(Map<String, dynamic> json) =>
      _$ClipCreatorProfileFromJson(json);
}

/// Clip comment/reaction
///
/// User reactions to clips on the platform
@freezed
class ClipComment with _$ClipComment {
  const factory ClipComment({
    required String id,
    required String clipId,
    required String userId,
    required String displayName,
    required String comment,
    DateTime? createdAt,
    @Default(0) int likes,
    @Default([]) List<String> likedBy,
    @Default('') String platform, // Which platform this comment is from
    @Default('') String platformCommentId,
  }) = _ClipComment;

  factory ClipComment.fromJson(Map<String, dynamic> json) =>
      _$ClipCommentFromJson(json);
}

/// Viral tracking data
///
/// Tracks how clips spread across the network
@freezed
class ViralTrackingData with _$ViralTrackingData {
  const factory ViralTrackingData({
    required String id,
    required String clipId,
    @Default(0) int totalShares,
    @Default([]) List<String> sharedByUserIds,
    @Default(0) int shareDepth, // Max distance from original sharer
    @Default(0) int uniqueReachers, // Unique users who saw the clip via shares
    @Default(0.0) double viralCoefficient, // Avg shares per viewer
    DateTime? measuredAt,
    @Default([]) List<String> topSharerIds, // Most active sharers
  }) = _ViralTrackingData;

  factory ViralTrackingData.fromJson(Map<String, dynamic> json) =>
      _$ViralTrackingDataFromJson(json);
}
