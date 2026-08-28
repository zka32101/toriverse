import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../../analytics_and_moderation/domain/models/analytics_and_moderation.dart';

class AnalyticsAndModerationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAnalytics _analytics;

  AnalyticsAndModerationRepository({
    required FirebaseFirestore firestore,
    required FirebaseAnalytics analytics,
  })  : _firestore = firestore,
        _analytics = analytics;

  // ===== CREATOR ANALYTICS METHODS (8) =====

  /// Get creator analytics dashboard
  Future<CreatorAnalyticsDashboard> getCreatorAnalyticsDashboard(String creatorId) async {
    try {
      final doc = await _firestore
          .collection('creator_analytics')
          .doc(creatorId)
          .collection('metrics')
          .doc('dashboard')
          .get();

      if (doc.exists) {
        return CreatorAnalyticsDashboard.fromJson(doc.data()!);
      }

      return CreatorAnalyticsDashboard(
        creatorId: creatorId,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to get analytics dashboard: $e');
    }
  }

  /// Get individual content performance
  Future<ContentPerformance> getContentPerformance(String contentId) async {
    try {
      final doc = await _firestore
          .collectionGroup('content_performance')
          .where('contentId', isEqualTo: contentId)
          .limit(1)
          .get();

      if (doc.docs.isNotEmpty) {
        return ContentPerformance.fromJson(doc.docs.first.data());
      }

      return ContentPerformance(
        contentId: contentId,
        contentType: 'unknown',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to get content performance: $e');
    }
  }

  /// Get audience demographics
  Future<AudienceDemographics> getAudienceDemographics(String creatorId) async {
    try {
      final doc = await _firestore
          .collection('creator_analytics')
          .doc(creatorId)
          .collection('demographics')
          .doc('audience')
          .get();

      if (doc.exists) {
        return AudienceDemographics.fromJson(doc.data()!);
      }

      return AudienceDemographics(
        creatorId: creatorId,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to get audience demographics: $e');
    }
  }

  /// Get revenue analytics for period
  Future<RevenueAnalytics> getRevenueAnalytics(
    String creatorId, {
    String period = 'monthly',
  }) async {
    try {
      final doc = await _firestore
          .collection('creator_analytics')
          .doc(creatorId)
          .collection('revenue')
          .doc(period)
          .get();

      if (doc.exists) {
        return RevenueAnalytics.fromJson(doc.data()!);
      }

      return RevenueAnalytics(
        creatorId: creatorId,
        period: period,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to get revenue analytics: $e');
    }
  }

  /// Get creator's top content
  Future<List<ContentPerformance>> getTopContent(
    String creatorId, {
    int limit = 10,
    String period = 'month',
  }) async {
    try {
      final snapshot = await _firestore
          .collection('creator_analytics')
          .doc(creatorId)
          .collection('content_performance')
          .orderBy('views', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ContentPerformance.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get top content: $e');
    }
  }

  /// Get audience retention curve
  Future<Map<int, double>> getAudienceRetention(String contentId) async {
    try {
      final doc = await _firestore
          .collectionGroup('content_performance')
          .where('contentId', isEqualTo: contentId)
          .limit(1)
          .get();

      if (doc.docs.isNotEmpty) {
        final data = doc.docs.first.data() as Map<String, dynamic>;
        return Map<int, double>.from(data['retentionCurve'] ?? {});
      }

      return {};
    } catch (e) {
      throw Exception('Failed to get audience retention: $e');
    }
  }

  /// Get growth trends
  Future<Map<String, List<int>>> getGrowthTrends(
    String creatorId, {
    String period = 'month',
  }) async {
    try {
      final doc = await _firestore
          .collection('creator_analytics')
          .doc(creatorId)
          .collection('trends')
          .doc(period)
          .get();

      if (doc.exists) {
        return Map<String, List<int>>.from(doc.data()!);
      }

      return {};
    } catch (e) {
      throw Exception('Failed to get growth trends: $e');
    }
  }

  /// Export analytics report
  Future<String> exportAnalyticsReport(
    String creatorId, {
    String format = 'pdf',
  }) async {
    try {
      final dashboard = await getCreatorAnalyticsDashboard(creatorId);

      await _analytics.logEvent(
        name: 'analytics_report_exported',
        parameters: {
          'creator_id': creatorId,
          'format': format,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Return placeholder report URL
      return 'https://example.com/reports/$creatorId-${DateTime.now().millisecondsSinceEpoch}.$format';
    } catch (e) {
      throw Exception('Failed to export analytics report: $e');
    }
  }

  // ===== COMMUNITY SAFETY METHODS (8) =====

  /// Create user report
  Future<UserReport> createUserReport(
    String reporterId,
    String reportedUserId,
    ReportReason reason, {
    String? description,
    List<String>? evidence,
  }) async {
    try {
      final reportId = _firestore.collection('user_reports').doc().id;
      final report = UserReport(
        reportId: reportId,
        reporterId: reporterId,
        reportedUserId: reportedUserId,
        reason: reason,
        description: description,
        evidence: evidence ?? [],
        createdAt: DateTime.now(),
      );

      await _firestore.collection('user_reports').doc(reportId).set(report.toJson());

      await _analytics.logEvent(
        name: 'content_reported',
        parameters: {
          'reporter_id': reporterId,
          'reported_user_id': reportedUserId,
          'reason': reason.toString(),
        },
      );

      return report;
    } catch (e) {
      throw Exception('Failed to create user report: $e');
    }
  }

  /// Get user reports
  Future<List<UserReport>> getUserReports(
    String userId, {
    ReportStatus? status,
  }) async {
    try {
      Query query = _firestore
          .collection('user_reports')
          .where('reportedUserId', isEqualTo: userId);

      if (status != null) {
        query = query.where('status', isEqualTo: status.toString());
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) => UserReport.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to get user reports: $e');
    }
  }

  /// Get moderation queue
  Future<List<UserReport>> getReportsQueue({
    ReportStatus status = ReportStatus.open,
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('user_reports')
          .where('status', isEqualTo: status.toString())
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => UserReport.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get reports queue: $e');
    }
  }

  /// Update report status
  Future<void> updateReportStatus(
    String reportId,
    ReportStatus newStatus, {
    String? moderatorNotes,
  }) async {
    try {
      await _firestore.collection('user_reports').doc(reportId).update({
        'status': newStatus.toString(),
        'moderatorNotes': moderatorNotes,
        'reviewedAt': DateTime.now(),
      });

      await _analytics.logEvent(
        name: 'report_reviewed',
        parameters: {
          'report_id': reportId,
          'new_status': newStatus.toString(),
        },
      );
    } catch (e) {
      throw Exception('Failed to update report status: $e');
    }
  }

  /// Flag content for moderation
  Future<ContentModeration> flagContent(
    String contentId,
    ContentModerationReason reason, {
    String? description,
  }) async {
    try {
      final modId = _firestore.collection('content_moderation').doc().id;
      final moderation = ContentModeration(
        contentId: contentId,
        contentType: 'unknown',
        flagReason: reason,
        description: description,
      );

      await _firestore.collection('content_moderation').doc(modId).set(moderation.toJson());

      await _analytics.logEvent(
        name: 'content_flagged',
        parameters: {
          'content_id': contentId,
          'reason': reason.toString(),
        },
      );

      return moderation;
    } catch (e) {
      throw Exception('Failed to flag content: $e');
    }
  }

  /// Review flagged content
  Future<void> reviewFlaggedContent(
    String contentId,
    ModerationAction action, {
    String? notes,
  }) async {
    try {
      await _firestore.collection('content_moderation').doc(contentId).update({
        'status': ReportStatus.resolved.toString(),
        'reviewedAt': DateTime.now(),
        'moderatorNotes': notes,
      });

      await _analytics.logEvent(
        name: 'content_moderated',
        parameters: {
          'content_id': contentId,
          'action': action.toString(),
        },
      );
    } catch (e) {
      throw Exception('Failed to review flagged content: $e');
    }
  }

  /// Get moderation history for user
  Future<List<CommunityModeration>> getModerationHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('moderation_actions')
          .where('targetUserId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CommunityModeration.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get moderation history: $e');
    }
  }

  /// Appeal moderation action
  Future<void> appealModerationAction(String moderationId, String appeal) async {
    try {
      await _firestore.collection('moderation_actions').doc(moderationId).update({
        'status': ReportStatus.appealed.toString(),
        'appealDetails': appeal,
      });

      await _analytics.logEvent(
        name: 'moderation_appeal_submitted',
        parameters: {
          'moderation_id': moderationId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to appeal moderation action: $e');
    }
  }

  // ===== PUSH NOTIFICATION METHODS (5) =====

  /// Send push notification
  Future<PushNotification> sendPushNotification(
    String userId,
    NotificationType type,
    String title,
    String body, {
    String? deepLink,
  }) async {
    try {
      final notifId = _firestore.collection('push_notifications').doc().id;
      final notification = PushNotification(
        notificationId: notifId,
        userId: userId,
        type: type,
        title: title,
        body: body,
        deepLink: deepLink,
        createdAt: DateTime.now(),
        sentAt: DateTime.now(),
      );

      await _firestore
          .collection('push_notifications')
          .doc(notifId)
          .set(notification.toJson());

      await _analytics.logEvent(
        name: 'push_notification_sent',
        parameters: {
          'user_id': userId,
          'notification_type': type.toString(),
        },
      );

      return notification;
    } catch (e) {
      throw Exception('Failed to send push notification: $e');
    }
  }

  /// Get notification history
  Future<List<PushNotification>> getNotificationHistory(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('push_notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PushNotification.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get notification history: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('push_notifications').doc(notificationId).update({
        'readAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Update notification preferences
  Future<void> updateNotificationPreferences(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .set(preferences);
    } catch (e) {
      throw Exception('Failed to update notification preferences: $e');
    }
  }

  /// Send batch notifications
  Future<void> sendBatchNotifications(
    List<String> userIds,
    NotificationType type,
    String title,
    String body,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final userId in userIds) {
        final notifId = _firestore.collection('push_notifications').doc().id;
        final notification = PushNotification(
          notificationId: notifId,
          userId: userId,
          type: type,
          title: title,
          body: body,
          createdAt: DateTime.now(),
          sentAt: DateTime.now(),
        );

        batch.set(
          _firestore.collection('push_notifications').doc(notifId),
          notification.toJson(),
        );
      }

      await batch.commit();

      await _analytics.logEvent(
        name: 'batch_notifications_sent',
        parameters: {
          'user_count': userIds.length,
          'notification_type': type.toString(),
        },
      );
    } catch (e) {
      throw Exception('Failed to send batch notifications: $e');
    }
  }

  // ===== ENGAGEMENT METRICS METHODS (5) =====

  /// Record engagement action
  Future<void> recordEngagementAction(
    String userId,
    String actionType,
    Map<String, dynamic> metadata,
  ) async {
    try {
      final actionId = _firestore
          .collection('users')
          .doc(userId)
          .collection('engagement_actions')
          .doc()
          .id;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('engagement_actions')
          .doc(actionId)
          .set({
        'actionType': actionType,
        'metadata': metadata,
        'timestamp': DateTime.now(),
      });

      await _analytics.logEvent(
        name: 'engagement_action_recorded',
        parameters: {
          'user_id': userId,
          'action_type': actionType,
          ...metadata,
        },
      );
    } catch (e) {
      throw Exception('Failed to record engagement action: $e');
    }
  }

  /// Get user engagement score
  Future<int> getUserEngagementScore(String userId) async {
    try {
      final doc = await _firestore
          .collection('user_engagement')
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        return data['engagementScore'] ?? 50;
      }

      return 50;
    } catch (e) {
      throw Exception('Failed to get engagement score: $e');
    }
  }

  /// Get high churn risk users
  Future<List<UserEngagementMetrics>> getChurnRiskUsers({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('user_engagement')
          .where('churnRisk', isGreaterThan: 0.7)
          .orderBy('churnRisk', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => UserEngagementMetrics.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get churn risk users: $e');
    }
  }

  /// Get feature usage stats
  Future<Map<String, int>> getFeatureUsageStats(
    String featureId, {
    String period = 'daily',
  }) async {
    try {
      final doc = await _firestore
          .collection('feature_analytics')
          .doc('$featureId-$period')
          .get();

      if (doc.exists) {
        return Map<String, int>.from(doc.data()!);
      }

      return {};
    } catch (e) {
      throw Exception('Failed to get feature usage stats: $e');
    }
  }

  /// Get session analytics
  Future<Map<String, int>> getSessionAnalytics(String userId) async {
    try {
      final doc = await _firestore
          .collection('user_engagement')
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        return {
          'sessionDuration': data['sessionDuration'] ?? 0,
          'sessionCount': data['sessionCount'] ?? 0,
        };
      }

      return {'sessionDuration': 0, 'sessionCount': 0};
    } catch (e) {
      throw Exception('Failed to get session analytics: $e');
    }
  }

  // ===== PLATFORM MONITORING METHODS (4) =====

  /// Record platform metrics
  Future<void> recordPlatformMetrics(PlatformMetrics metrics) async {
    try {
      await _firestore
          .collection('platform_metrics')
          .doc(metrics.metricsId)
          .set(metrics.toJson());
    } catch (e) {
      throw Exception('Failed to record platform metrics: $e');
    }
  }

  /// Get platform health
  Future<Map<String, dynamic>> getPlatformHealth() async {
    try {
      final doc = await _firestore
          .collection('platform_metrics')
          .orderBy('generatedAt', descending: true)
          .limit(1)
          .get();

      if (doc.docs.isNotEmpty) {
        return doc.docs.first.data();
      }

      return {
        'status': 'unknown',
        'errorRate': 0.0,
        'apiLatency': 0.0,
      };
    } catch (e) {
      throw Exception('Failed to get platform health: $e');
    }
  }

  /// Get error rate for period
  Future<double> getErrorRate({String period = 'daily'}) async {
    try {
      final snapshot = await _firestore
          .collection('platform_metrics')
          .where('period', isEqualTo: period)
          .orderBy('generatedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return data['errorRate'] ?? 0.0;
      }

      return 0.0;
    } catch (e) {
      throw Exception('Failed to get error rate: $e');
    }
  }

  /// Get performance metrics
  Future<Map<String, dynamic>> getPerformanceMetrics({String period = 'daily'}) async {
    try {
      final snapshot = await _firestore
          .collection('platform_metrics')
          .where('period', isEqualTo: period)
          .orderBy('generatedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return {
          'apiLatencyP50': data['apiLatencyP50'] ?? 0.0,
          'apiLatencyP99': data['apiLatencyP99'] ?? 0.0,
          'cacheHitRate': data['cacheHitRate'] ?? 0.0,
          'errorRate': data['errorRate'] ?? 0.0,
        };
      }

      return {};
    } catch (e) {
      throw Exception('Failed to get performance metrics: $e');
    }
  }
}
