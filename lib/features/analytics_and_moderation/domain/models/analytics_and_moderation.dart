import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_and_moderation.freezed.dart';
part 'analytics_and_moderation.g.dart';

// Enums
enum ReportReason { harassment, spam, abuse, misinformation, copyright, other }

enum ContentModerationReason { explicit, spam, misinformation, copyright, hateSpeech }

enum ModerationAction { warn, mute, suspend, ban, contentRemoval }

enum ModerationType { temporary, permanent }

enum NotificationType { matchResult, friendRequest, followerActivity, newClip, liveStream }

enum ReportStatus { open, investigating, resolved, dismissed, appealed }

// Creator Analytics Models

/// Creator dashboard with aggregated metrics
@freezed
class CreatorAnalyticsDashboard with _$CreatorAnalyticsDashboard {
  const factory CreatorAnalyticsDashboard({
    required String creatorId,
    @Default(0) int totalViews,
    @Default(0.0) double totalEarnings,
    @Default(0) int followerGrowth,
    @Default(0.0) double engagementRate,
    @Default([]) List<Map<String, dynamic>> topContent,
    @Default({}) Map<String, dynamic> revenueBreakdown,
    @Default({}) Map<String, dynamic> audienceDemographics,
    required DateTime updatedAt,
  }) = _CreatorAnalyticsDashboard;

  factory CreatorAnalyticsDashboard.fromJson(Map<String, dynamic> json) =>
      _$CreatorAnalyticsDashboardFromJson(json);
}

/// Individual content performance metrics
@freezed
class ContentPerformance with _$ContentPerformance {
  const factory ContentPerformance({
    required String contentId,
    required String contentType,
    @Default(0) int views,
    @Default(0) int engagement,
    @Default(0) int avgWatchDuration,
    @Default(0) int shareCount,
    @Default(0) int likeCount,
    @Default(0.0) double completionRate,
    required DateTime createdAt,
  }) = _ContentPerformance;

  factory ContentPerformance.fromJson(Map<String, dynamic> json) =>
      _$ContentPerformanceFromJson(json);
}

/// Aggregated viewer demographics
@freezed
class AudienceDemographics with _$AudienceDemographics {
  const factory AudienceDemographics({
    required String creatorId,
    @Default({}) Map<String, int> ageGroups,
    @Default({}) Map<String, int> genders,
    @Default({}) Map<String, int> regions,
    @Default({}) Map<String, int> devices,
    @Default([]) List<String> topCountries,
    @Default('en') String languagePreference,
    @Default({}) Map<String, int> activityTimes,
    required DateTime updatedAt,
  }) = _AudienceDemographics;

  factory AudienceDemographics.fromJson(Map<String, dynamic> json) =>
      _$AudienceDemographicsFromJson(json);
}

/// Revenue breakdown by source and period
@freezed
class RevenueAnalytics with _$RevenueAnalytics {
  const factory RevenueAnalytics({
    required String creatorId,
    required String period,
    @Default(0.0) double totalRevenue,
    @Default(0.0) double subscriptionRevenue,
    @Default(0.0) double giftRevenue,
    @Default(0.0) double clipRevenue,
    @Default(0.0) double adRevenue,
    @Default(0.0) double fees,
    @Default(0.0) double taxes,
    @Default(0.0) double netRevenue,
    @Default(0.0) double projectedAnnualRevenue,
    required DateTime generatedAt,
  }) = _RevenueAnalytics;

  factory RevenueAnalytics.fromJson(Map<String, dynamic> json) =>
      _$RevenueAnalyticsFromJson(json);
}

// Community Safety Models

/// User report for abuse/spam/harassment
@freezed
class UserReport with _$UserReport {
  const factory UserReport({
    required String reportId,
    required String reporterId,
    required String reportedUserId,
    required ReportReason reason,
    String? description,
    @Default([]) List<String> evidence,
    required DateTime createdAt,
    @Default(ReportStatus.open) ReportStatus status,
    String? moderatorNotes,
  }) = _UserReport;

  factory UserReport.fromJson(Map<String, dynamic> json) =>
      _$UserReportFromJson(json);
}

/// Content flagged for moderation
@freezed
class ContentModeration with _$ContentModeration {
  const factory ContentModeration({
    required String contentId,
    required String contentType,
    required ContentModerationReason flagReason,
    String? description,
    @Default(ReportStatus.open) ReportStatus status,
    String? moderatorNotes,
    @Default(0) int reviewCount,
    DateTime? reviewedAt,
  }) = _ContentModeration;

  factory ContentModeration.fromJson(Map<String, dynamic> json) =>
      _$ContentModerationFromJson(json);
}

/// Moderation action taken on user
@freezed
class CommunityModeration with _$CommunityModeration {
  const factory CommunityModeration({
    required String moderationId,
    required ModerationAction action,
    required String targetUserId,
    required String actionReason,
    @Default(ModerationType.permanent) ModerationType durationType,
    @Default(0) int durationHours,
    required DateTime createdAt,
    String? createdBy,
    @Default(true) bool appealable,
    String? appealDetails,
  }) = _CommunityModeration;

  factory CommunityModeration.fromJson(Map<String, dynamic> json) =>
      _$CommunityModerationFromJson(json);
}

// Notification & Engagement Models

/// Push notification
@freezed
class PushNotification with _$PushNotification {
  const factory PushNotification({
    required String notificationId,
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    String? deepLink,
    required DateTime createdAt,
    DateTime? sentAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    @Default(false) bool clicked,
    DateTime? clickedAt,
  }) = _PushNotification;

  factory PushNotification.fromJson(Map<String, dynamic> json) =>
      _$PushNotificationFromJson(json);
}

/// User engagement metrics
@freezed
class UserEngagementMetrics with _$UserEngagementMetrics {
  const factory UserEngagementMetrics({
    required String userId,
    @Default(0) int dailyActiveUsers,
    @Default(0) int monthlyActiveUsers,
    @Default(0) int sessionDuration,
    @Default({}) Map<String, int> featureUsage,
    @Default(0.0) double churnRisk,
    DateTime? lastActiveAt,
    @Default(50) int engagementScore,
    required DateTime calculatedAt,
  }) = _UserEngagementMetrics;

  factory UserEngagementMetrics.fromJson(Map<String, dynamic> json) =>
      _$UserEngagementMetricsFromJson(json);
}

/// Achievement badge
@freezed
class AchievementBadge with _$AchievementBadge {
  const factory AchievementBadge({
    required String badgeId,
    required String name,
    required String description,
    String? iconUrl,
    required String requirement,
    @Default(0) int unlockedByCount,
    String? rarityTier,
    String? category,
    required DateTime createdAt,
  }) = _AchievementBadge;

  factory AchievementBadge.fromJson(Map<String, dynamic> json) =>
      _$AchievementBadgeFromJson(json);
}

// Platform Monitoring

/// Platform-wide metrics
@freezed
class PlatformMetrics with _$PlatformMetrics {
  const factory PlatformMetrics({
    required String metricsId,
    required String period,
    @Default(0) int dailyActiveUsers,
    @Default(0) int monthlyActiveUsers,
    @Default(0) int sessionCount,
    @Default(0) int avgSessionDuration,
    @Default({}) Map<String, int> featurePopularity,
    @Default(0.0) double errorRate,
    @Default(0.0) double apiLatencyP50,
    @Default(0.0) double apiLatencyP99,
    @Default(0) int serverLoad,
    @Default(0) int databaseQueries,
    @Default(0.0) double cacheHitRate,
    required DateTime generatedAt,
  }) = _PlatformMetrics;

  factory PlatformMetrics.fromJson(Map<String, dynamic> json) =>
      _$PlatformMetricsFromJson(json);
}
