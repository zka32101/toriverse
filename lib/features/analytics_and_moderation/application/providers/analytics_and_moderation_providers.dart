import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/repositories/analytics_and_moderation_repository.dart';
import '../../domain/models/analytics_and_moderation.dart';

part 'analytics_and_moderation_providers.freezed.dart';

// ===== PROVIDER PARAMETER CLASSES =====

@freezed
class RevenueAnalyticsParam with _$RevenueAnalyticsParam {
  const factory RevenueAnalyticsParam({
    required String creatorId,
    @Default('monthly') String period,
  }) = _RevenueAnalyticsParam;
}

@freezed
class TopContentParam with _$TopContentParam {
  const factory TopContentParam({
    required String creatorId,
    @Default(10) int limit,
    @Default('month') String period,
  }) = _TopContentParam;
}

@freezed
class GrowthTrendsParam with _$GrowthTrendsParam {
  const factory GrowthTrendsParam({
    required String creatorId,
    @Default('month') String period,
  }) = _GrowthTrendsParam;
}

@freezed
class ReportsQueueParam with _$ReportsQueueParam {
  const factory ReportsQueueParam({
    @Default(ReportStatus.open) ReportStatus status,
    @Default(50) int limit,
  }) = _ReportsQueueParam;
}

@freezed
class NotificationHistoryParam with _$NotificationHistoryParam {
  const factory NotificationHistoryParam({
    required String userId,
    @Default(50) int limit,
  }) = _NotificationHistoryParam;
}

@freezed
class FeatureUsageParam with _$FeatureUsageParam {
  const factory FeatureUsageParam({
    required String featureId,
    @Default('daily') String period,
  }) = _FeatureUsageParam;
}

@freezed
class PlatformMetricsParam with _$PlatformMetricsParam {
  const factory PlatformMetricsParam({
    @Default('daily') String period,
  }) = _PlatformMetricsParam;
}

// ===== REPOSITORY PROVIDER =====

final analyticsAndModerationRepositoryProvider = Provider((ref) {
  return AnalyticsAndModerationRepository(
    firestore: FirebaseFirestore.instance,
    analytics: FirebaseAnalytics.instance,
  );
});

// ===== STREAM PROVIDERS (Real-time) =====

/// Watch creator analytics dashboard in real-time
final watchCreatorAnalyticsDashboardProvider =
    StreamProvider.family<CreatorAnalyticsDashboard, String>((ref, creatorId) async* {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  try {
    final dashboard = await repo.getCreatorAnalyticsDashboard(creatorId);
    yield dashboard;

    // Refresh every 15 minutes
    await Future.delayed(const Duration(minutes: 15));
    final refreshed = await repo.getCreatorAnalyticsDashboard(creatorId);
    yield refreshed;
  } catch (e) {
    throw Exception('Failed to watch creator analytics dashboard: $e');
  }
});

/// Watch the moderation queue in real-time
final watchReportsQueueProvider =
    StreamProvider.family<List<UserReport>, ReportsQueueParam>((ref, params) async* {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  try {
    final queue = await repo.getReportsQueue(status: params.status, limit: params.limit);
    yield queue;

    // Refresh every minute for moderators
    await Future.delayed(const Duration(minutes: 1));
    final refreshed = await repo.getReportsQueue(status: params.status, limit: params.limit);
    yield refreshed;
  } catch (e) {
    throw Exception('Failed to watch reports queue: $e');
  }
});

/// Watch a user's notification history in real-time
final watchNotificationHistoryProvider =
    StreamProvider.family<List<PushNotification>, NotificationHistoryParam>(
        (ref, params) async* {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  try {
    final history = await repo.getNotificationHistory(params.userId, limit: params.limit);
    yield history;

    // Refresh every 30 seconds
    await Future.delayed(const Duration(seconds: 30));
    final refreshed = await repo.getNotificationHistory(params.userId, limit: params.limit);
    yield refreshed;
  } catch (e) {
    throw Exception('Failed to watch notification history: $e');
  }
});

/// Watch platform health in real-time (admin dashboard)
final watchPlatformHealthProvider = StreamProvider<Map<String, dynamic>>((ref) async* {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  try {
    final health = await repo.getPlatformHealth();
    yield health;

    // Refresh every 5 minutes
    await Future.delayed(const Duration(minutes: 5));
    final refreshed = await repo.getPlatformHealth();
    yield refreshed;
  } catch (e) {
    throw Exception('Failed to watch platform health: $e');
  }
});

/// Watch high churn-risk users in real-time (admin dashboard)
final watchChurnRiskUsersProvider =
    StreamProvider.family<List<UserEngagementMetrics>, int>((ref, limit) async* {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  try {
    final users = await repo.getChurnRiskUsers(limit: limit);
    yield users;

    // Refresh hourly
    await Future.delayed(const Duration(hours: 1));
    final refreshed = await repo.getChurnRiskUsers(limit: limit);
    yield refreshed;
  } catch (e) {
    throw Exception('Failed to watch churn risk users: $e');
  }
});

// ===== FUTURE PROVIDERS (Async Caching) =====

/// Fetch creator analytics dashboard (cached)
final creatorAnalyticsDashboardProvider =
    FutureProvider.family<CreatorAnalyticsDashboard, String>((ref, creatorId) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  return repo.getCreatorAnalyticsDashboard(creatorId);
});

/// Fetch individual content performance (cached)
final contentPerformanceProvider =
    FutureProvider.family<ContentPerformance, String>((ref, contentId) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  return repo.getContentPerformance(contentId);
});

/// Fetch audience demographics (cached)
final audienceDemographicsProvider =
    FutureProvider.family<AudienceDemographics, String>((ref, creatorId) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  return repo.getAudienceDemographics(creatorId);
});

/// Fetch revenue analytics (cached)
final revenueAnalyticsProvider =
    FutureProvider.family<RevenueAnalytics, RevenueAnalyticsParam>((ref, params) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  return repo.getRevenueAnalytics(params.creatorId, period: params.period);
});

/// Fetch creator's top content (cached)
final topContentProvider =
    FutureProvider.family<List<ContentPerformance>, TopContentParam>((ref, params) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  return repo.getTopContent(params.creatorId, limit: params.limit, period: params.period);
});

/// Fetch audience retention curve (cached)
final audienceRetentionProvider =
    FutureProvider.family<Map<int, double>, String>((ref, contentId) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  return repo.getAudienceRetention(contentId);
});

/// Fetch growth trends (cached)
final growthTrendsProvider =
    FutureProvider.family<Map<String, List<int>>, GrowthTrendsParam>((ref, params) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  return repo.getGrowthTrends(params.creatorId, period: params.period);
});

/// Fetch a user's open reports (cached)
final userReportsProvider = FutureProvider.family<List<UserReport>,
    ({String userId, ReportStatus? status})>((ref, params) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  return repo.getUserReports(params.userId, status: params.status);
});

/// Fetch the moderation queue (cached)
final reportsQueueProvider =
    FutureProvider.family<List<UserReport>, ReportsQueueParam>((ref, params) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  return repo.getReportsQueue(status: params.status, limit: params.limit);
});

/// Fetch a user's moderation history (cached)
final moderationHistoryProvider =
    FutureProvider.family<List<CommunityModeration>, String>((ref, userId) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  return repo.getModerationHistory(userId);
});

/// Fetch notification history (cached)
final notificationHistoryProvider =
    FutureProvider.family<List<PushNotification>, NotificationHistoryParam>(
        (ref, params) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  return repo.getNotificationHistory(params.userId, limit: params.limit);
});

/// Fetch a user's engagement score (cached)
final userEngagementScoreProvider =
    FutureProvider.family<int, String>((ref, userId) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  return repo.getUserEngagementScore(userId);
});

/// Fetch high churn-risk users (cached)
final churnRiskUsersProvider =
    FutureProvider.family<List<UserEngagementMetrics>, int>((ref, limit) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  return repo.getChurnRiskUsers(limit: limit);
});

/// Fetch feature usage stats (cached)
final featureUsageStatsProvider =
    FutureProvider.family<Map<String, int>, FeatureUsageParam>((ref, params) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  return repo.getFeatureUsageStats(params.featureId, period: params.period);
});

/// Fetch session analytics (cached)
final sessionAnalyticsProvider =
    FutureProvider.family<Map<String, int>, String>((ref, userId) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  return repo.getSessionAnalytics(userId);
});

/// Fetch platform health snapshot (cached)
final platformHealthProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  return repo.getPlatformHealth();
});

/// Fetch platform error rate (cached)
final errorRateProvider =
    FutureProvider.family<double, PlatformMetricsParam>((ref, params) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  return repo.getErrorRate(period: params.period);
});

/// Fetch platform performance metrics (cached)
final performanceMetricsProvider =
    FutureProvider.family<Map<String, dynamic>, PlatformMetricsParam>((ref, params) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  return repo.getPerformanceMetrics(period: params.period);
});

// ===== MUTATION PROVIDERS (Transactions) =====

/// Export an analytics report for a creator
final exportAnalyticsReportProvider = FutureProvider.family<String,
    ({String creatorId, String format})>((ref, params) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  return repo.exportAnalyticsReport(params.creatorId, format: params.format);
});

/// Create a user report (abuse/spam/harassment)
final createUserReportProvider = FutureProvider.family<UserReport,
    ({
      String reporterId,
      String reportedUserId,
      ReportReason reason,
      String? description,
      List<String>? evidence,
    })>((ref, params) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);

  final report = await repo.createUserReport(
    params.reporterId,
    params.reportedUserId,
    params.reason,
    description: params.description,
    evidence: params.evidence,
  );

  // Invalidate moderation queue so it appears immediately
  ref.invalidate(reportsQueueProvider);
  ref.invalidate(watchReportsQueueProvider);

  return report;
});

/// Update the status of a user report (moderator action)
final updateReportStatusProvider = FutureProvider.family<void,
    ({String reportId, ReportStatus newStatus, String? moderatorNotes})>((ref, params) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);

  await repo.updateReportStatus(
    params.reportId,
    params.newStatus,
    moderatorNotes: params.moderatorNotes,
  );

  ref.invalidate(reportsQueueProvider);
  ref.invalidate(watchReportsQueueProvider);
});

/// Flag content for moderation review
final flagContentProvider = FutureProvider.family<ContentModeration,
    ({String contentId, ContentModerationReason reason, String? description})>((ref, params) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  return repo.flagContent(params.contentId, params.reason, description: params.description);
});

/// Review flagged content and resolve it
final reviewFlaggedContentProvider = FutureProvider.family<void,
    ({String contentId, ModerationAction action, String? notes})>((ref, params) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  await repo.reviewFlaggedContent(params.contentId, params.action, notes: params.notes);
});

/// Appeal a moderation action
final appealModerationActionProvider =
    FutureProvider.family<void, ({String moderationId, String appeal})>((ref, params) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  await repo.appealModerationAction(params.moderationId, params.appeal);

  ref.invalidate(moderationHistoryProvider);
});

/// Send a push notification to a single user
final sendPushNotificationProvider = FutureProvider.family<PushNotification,
    ({
      String userId,
      NotificationType type,
      String title,
      String body,
      String? deepLink,
    })>((ref, params) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);

  final notification = await repo.sendPushNotification(
    params.userId,
    params.type,
    params.title,
    params.body,
    deepLink: params.deepLink,
  );

  ref.invalidate(notificationHistoryProvider);
  ref.invalidate(watchNotificationHistoryProvider);

  return notification;
});

/// Mark a notification as read
final markNotificationAsReadProvider =
    FutureProvider.family<void, String>((ref, notificationId) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  await repo.markAsRead(notificationId);

  ref.invalidate(notificationHistoryProvider);
});

/// Update a user's notification preferences
final updateNotificationPreferencesProvider = FutureProvider.family<void,
    ({String userId, Map<String, dynamic> preferences})>((ref, params) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  await repo.updateNotificationPreferences(params.userId, params.preferences);
});

/// Send a batch of push notifications (broadcast / segment)
final sendBatchNotificationsProvider = FutureProvider.family<void,
    ({
      List<String> userIds,
      NotificationType type,
      String title,
      String body,
    })>((ref, params) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  await repo.sendBatchNotifications(params.userIds, params.type, params.title, params.body);
});

/// Record a user engagement action
final recordEngagementActionProvider = FutureProvider.family<void,
    ({String userId, String actionType, Map<String, dynamic> metadata})>((ref, params) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  await repo.recordEngagementAction(params.userId, params.actionType, params.metadata);

  ref.invalidate(userEngagementScoreProvider);
});

/// Record platform-wide metrics (server/ops use)
final recordPlatformMetricsProvider =
    FutureProvider.family<void, PlatformMetrics>((ref, metrics) async {
  final repo = ref.watch(analyticsAndModerationRepositoryProvider);
  await repo.recordPlatformMetrics(metrics);

  ref.invalidate(platformHealthProvider);
  ref.invalidate(watchPlatformHealthProvider);
});
