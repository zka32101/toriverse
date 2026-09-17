import 'package:freezed_annotation/freezed_annotation.dart';

// Enums
enum ReportReason { harassment, spam, abuse, misinformation, copyright, other }

enum ContentModerationReason { explicit, spam, misinformation, copyright, hateSpeech }

enum ModerationAction { warn, mute, suspend, ban, contentRemoval }

enum ModerationType { temporary, permanent }

enum NotificationType { matchResult, friendRequest, followerActivity, newClip, liveStream }

enum ReportStatus { open, investigating, resolved, dismissed, appealed }

// Creator Analytics Models

/// Creator dashboard with aggregated metrics
class CreatorAnalyticsDashboard {
  const CreatorAnalyticsDashboard({
    required String creatorId,
    int totalViews,
    double totalEarnings,
    int followerGrowth,
    double engagementRate,
    List<Map<String, dynamic>> topContent,
    Map<String, dynamic> revenueBreakdown,
    Map<String, dynamic> audienceDemographics,
    required DateTime updatedAt,
  });
}

/// Individual content performance metrics
class ContentPerformance {
  const ContentPerformance({
    required String contentId,
    required String contentType,
    int views,
    int engagement,
    int avgWatchDuration,
    int shareCount,
    int likeCount,
    double completionRate,
    required DateTime createdAt,
  });
}

/// Aggregated viewer demographics
class AudienceDemographics {
  const AudienceDemographics({
    required String creatorId,
    Map<String, int> ageGroups,
    Map<String, int> genders,
    Map<String, int> regions,
    Map<String, int> devices,
    List<String> topCountries,
    String languagePreference,
    Map<String, int> activityTimes,
    required DateTime updatedAt,
  });
}

/// Revenue breakdown by source and period
class RevenueAnalytics {
  const RevenueAnalytics({
    required String creatorId,
    required String period,
    double totalRevenue,
    double subscriptionRevenue,
    double giftRevenue,
    double clipRevenue,
    double adRevenue,
    double fees,
    double taxes,
    double netRevenue,
    double projectedAnnualRevenue,
    required DateTime generatedAt,
  });
}

// Community Safety Models

/// User report for abuse/spam/harassment
class UserReport {
  const UserReport({
    required String reportId,
    required String reporterId,
    required String reportedUserId,
    required ReportReason reason,
    String? description,
    List<String> evidence,
    required DateTime createdAt,
    ReportStatus status,
    String? moderatorNotes,
  });
}

/// Content flagged for moderation
class ContentModeration {
  const ContentModeration({
    required String contentId,
    required String contentType,
    required ContentModerationReason flagReason,
    String? description,
    ReportStatus status,
    String? moderatorNotes,
    int reviewCount,
    DateTime? reviewedAt,
  });
}

/// Moderation action taken on user
class CommunityModeration {
  const CommunityModeration({
    required String moderationId,
    required ModerationAction action,
    required String targetUserId,
    required String actionReason,
    ModerationType durationType,
    int durationHours,
    required DateTime createdAt,
    String? createdBy,
    bool appealable,
    String? appealDetails,
  });
}

// Notification & Engagement Models

/// Push notification
class PushNotification {
  const PushNotification({
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
    bool clicked,
    DateTime? clickedAt,
  });
}

/// User engagement metrics
class UserEngagementMetrics {
  const UserEngagementMetrics({
    required String userId,
    int dailyActiveUsers,
    int monthlyActiveUsers,
    int sessionDuration,
    Map<String, int> featureUsage,
    double churnRisk,
    DateTime? lastActiveAt,
    int engagementScore,
    required DateTime calculatedAt,
  });
}

/// Achievement badge
class AchievementBadge {
  const AchievementBadge({
    required String badgeId,
    required String name,
    required String description,
    String? iconUrl,
    required String requirement,
    int unlockedByCount,
    String? rarityTier,
    String? category,
    required DateTime createdAt,
  });
}

// Platform Monitoring

/// Platform-wide metrics
class PlatformMetrics {
  const PlatformMetrics({
    required String metricsId,
    required String period,
    int dailyActiveUsers,
    int monthlyActiveUsers,
    int sessionCount,
    int avgSessionDuration,
    Map<String, int> featurePopularity,
    double errorRate,
    double apiLatencyP50,
    double apiLatencyP99,
    int serverLoad,
    int databaseQueries,
    double cacheHitRate,
    required DateTime generatedAt,
  });
}
