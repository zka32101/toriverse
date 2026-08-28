import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/analytics_and_moderation/domain/models/analytics_and_moderation.dart';

void main() {
  group('Analytics & Moderation Models Tests', () {
    group('CreatorAnalyticsDashboard', () {
      test('should create dashboard with default zero metrics', () {
        final dashboard = CreatorAnalyticsDashboard(
          creatorId: 'creator_001',
          updatedAt: DateTime.now(),
        );

        expect(dashboard.creatorId, 'creator_001');
        expect(dashboard.totalViews, 0);
        expect(dashboard.totalEarnings, 0.0);
        expect(dashboard.engagementRate, 0.0);
        expect(dashboard.topContent, isEmpty);
      });

      test('should serialize and deserialize dashboard', () {
        final original = CreatorAnalyticsDashboard(
          creatorId: 'creator_001',
          totalViews: 15000,
          totalEarnings: 250.50,
          followerGrowth: 320,
          engagementRate: 0.42,
          topContent: const [
            {'title': 'Epic Comeback', 'views': 5000}
          ],
          updatedAt: DateTime(2026, 8, 28),
        );

        final json = original.toJson();
        final restored = CreatorAnalyticsDashboard.fromJson(json);

        expect(restored.creatorId, original.creatorId);
        expect(restored.totalViews, 15000);
        expect(restored.totalEarnings, 250.50);
        expect(restored.followerGrowth, 320);
        expect(restored.topContent.length, 1);
      });
    });

    group('ContentPerformance', () {
      test('should create content performance with metrics', () {
        final perf = ContentPerformance(
          contentId: 'clip_001',
          contentType: 'clip',
          views: 10000,
          engagement: 800,
          avgWatchDuration: 45,
          shareCount: 120,
          likeCount: 950,
          completionRate: 0.72,
          createdAt: DateTime.now(),
        );

        expect(perf.views, 10000);
        expect(perf.completionRate, 0.72);
        expect(perf.shareCount, 120);
      });

      test('should default numeric fields to zero', () {
        final perf = ContentPerformance(
          contentId: 'clip_002',
          contentType: 'match',
          createdAt: DateTime.now(),
        );

        expect(perf.views, 0);
        expect(perf.engagement, 0);
        expect(perf.completionRate, 0.0);
      });
    });

    group('AudienceDemographics', () {
      test('should aggregate demographic breakdowns', () {
        final demographics = AudienceDemographics(
          creatorId: 'creator_001',
          ageGroups: const {'18-24': 400, '25-34': 600},
          genders: const {'male': 700, 'female': 300},
          regions: const {'JP': 800, 'US': 200},
          devices: const {'ios': 500, 'android': 500},
          topCountries: const ['JP', 'US', 'KR'],
          languagePreference: 'ja',
          updatedAt: DateTime.now(),
        );

        expect(demographics.ageGroups['18-24'], 400);
        expect(demographics.topCountries, contains('JP'));
        expect(demographics.languagePreference, 'ja');
      });

      test('should default to English language preference', () {
        final demographics = AudienceDemographics(
          creatorId: 'creator_001',
          updatedAt: DateTime.now(),
        );

        expect(demographics.languagePreference, 'en');
      });
    });

    group('RevenueAnalytics', () {
      test('should track revenue breakdown by source', () {
        final revenue = RevenueAnalytics(
          creatorId: 'creator_001',
          period: 'monthly',
          totalRevenue: 1000.0,
          subscriptionRevenue: 600.0,
          giftRevenue: 250.0,
          clipRevenue: 100.0,
          adRevenue: 50.0,
          fees: 80.0,
          taxes: 40.0,
          netRevenue: 880.0,
          generatedAt: DateTime.now(),
        );

        expect(revenue.totalRevenue, 1000.0);
        expect(revenue.subscriptionRevenue, 600.0);
        expect(revenue.netRevenue, 880.0);
      });

      test('should serialize and deserialize revenue analytics', () {
        final original = RevenueAnalytics(
          creatorId: 'creator_001',
          period: 'monthly',
          totalRevenue: 500.0,
          generatedAt: DateTime(2026, 8, 1),
        );

        final json = original.toJson();
        final restored = RevenueAnalytics.fromJson(json);

        expect(restored.creatorId, original.creatorId);
        expect(restored.totalRevenue, 500.0);
      });
    });

    group('UserReport', () {
      test('should create report with open status by default', () {
        final report = UserReport(
          reportId: 'report_001',
          reporterId: 'user_001',
          reportedUserId: 'user_002',
          reason: ReportReason.harassment,
          createdAt: DateTime.now(),
        );

        expect(report.status, ReportStatus.open);
        expect(report.evidence, isEmpty);
      });

      test('should support all report reasons', () {
        for (final reason in ReportReason.values) {
          final report = UserReport(
            reportId: 'report_${reason.name}',
            reporterId: 'user_001',
            reportedUserId: 'user_002',
            reason: reason,
            createdAt: DateTime.now(),
          );
          expect(report.reason, reason);
        }
      });

      test('should serialize and deserialize with evidence', () {
        final original = UserReport(
          reportId: 'report_001',
          reporterId: 'user_001',
          reportedUserId: 'user_002',
          reason: ReportReason.spam,
          description: 'Repeated unsolicited messages',
          evidence: const ['screenshot_1.png', 'screenshot_2.png'],
          createdAt: DateTime(2026, 8, 28),
          status: ReportStatus.investigating,
        );

        final json = original.toJson();
        final restored = UserReport.fromJson(json);

        expect(restored.evidence.length, 2);
        expect(restored.status, ReportStatus.investigating);
      });
    });

    group('ContentModeration', () {
      test('should create flagged content with open status', () {
        final moderation = ContentModeration(
          contentId: 'clip_001',
          contentType: 'clip',
          flagReason: ContentModerationReason.explicit,
        );

        expect(moderation.status, ReportStatus.open);
        expect(moderation.reviewCount, 0);
      });

      test('should support all moderation reasons', () {
        for (final reason in ContentModerationReason.values) {
          final moderation = ContentModeration(
            contentId: 'content_${reason.name}',
            contentType: 'clip',
            flagReason: reason,
          );
          expect(moderation.flagReason, reason);
        }
      });
    });

    group('CommunityModeration', () {
      test('should create permanent moderation action by default', () {
        final moderation = CommunityModeration(
          moderationId: 'mod_001',
          action: ModerationAction.ban,
          targetUserId: 'user_002',
          actionReason: 'Repeated harassment',
          createdAt: DateTime.now(),
        );

        expect(moderation.durationType, ModerationType.permanent);
        expect(moderation.appealable, true);
      });

      test('should support temporary suspension with duration', () {
        final moderation = CommunityModeration(
          moderationId: 'mod_002',
          action: ModerationAction.suspend,
          targetUserId: 'user_002',
          actionReason: 'Spam',
          durationType: ModerationType.temporary,
          durationHours: 24,
          createdAt: DateTime.now(),
        );

        expect(moderation.durationType, ModerationType.temporary);
        expect(moderation.durationHours, 24);
      });
    });

    group('PushNotification', () {
      test('should create notification with required fields', () {
        final notification = PushNotification(
          notificationId: 'notif_001',
          userId: 'user_001',
          type: NotificationType.matchResult,
          title: 'You won!',
          body: 'Great game, check out the replay.',
          createdAt: DateTime.now(),
        );

        expect(notification.type, NotificationType.matchResult);
        expect(notification.clicked, false);
      });

      test('should track delivery and read lifecycle', () {
        final now = DateTime.now();
        final notification = PushNotification(
          notificationId: 'notif_001',
          userId: 'user_001',
          type: NotificationType.newClip,
          title: 'New clip from a followed creator',
          body: 'Check it out',
          createdAt: now,
          sentAt: now.add(const Duration(seconds: 1)),
          deliveredAt: now.add(const Duration(seconds: 2)),
          readAt: now.add(const Duration(minutes: 5)),
          clicked: true,
          clickedAt: now.add(const Duration(minutes: 5)),
        );

        expect(notification.readAt, isNotNull);
        expect(notification.clicked, true);
      });
    });

    group('UserEngagementMetrics', () {
      test('should default engagement score to 50', () {
        final metrics = UserEngagementMetrics(
          userId: 'user_001',
          calculatedAt: DateTime.now(),
        );

        expect(metrics.engagementScore, 50);
        expect(metrics.churnRisk, 0.0);
      });

      test('should track feature usage and churn risk', () {
        final metrics = UserEngagementMetrics(
          userId: 'user_001',
          dailyActiveUsers: 1,
          sessionDuration: 600,
          featureUsage: const {'match': 5, 'clip_share': 2},
          churnRisk: 0.85,
          engagementScore: 20,
          calculatedAt: DateTime.now(),
        );

        expect(metrics.churnRisk, 0.85);
        expect(metrics.featureUsage['match'], 5);
        expect(metrics.engagementScore, 20);
      });
    });

    group('AchievementBadge', () {
      test('should create badge with requirement description', () {
        final badge = AchievementBadge(
          badgeId: 'badge_001',
          name: 'Comeback King',
          description: 'Win a match after being in last place',
          requirement: 'win_from_last_place',
          createdAt: DateTime.now(),
        );

        expect(badge.name, 'Comeback King');
        expect(badge.unlockedByCount, 0);
      });

      test('should track rarity tier and unlock count', () {
        final badge = AchievementBadge(
          badgeId: 'badge_002',
          name: 'Perfect Streak',
          description: 'Complete 10 matches in a row',
          requirement: 'streak_10',
          unlockedByCount: 42,
          rarityTier: 'legendary',
          category: 'streak',
          createdAt: DateTime.now(),
        );

        expect(badge.rarityTier, 'legendary');
        expect(badge.unlockedByCount, 42);
      });
    });

    group('PlatformMetrics', () {
      test('should aggregate platform-wide health metrics', () {
        final metrics = PlatformMetrics(
          metricsId: 'metrics_2026_08_28',
          period: 'daily',
          dailyActiveUsers: 5000,
          monthlyActiveUsers: 50000,
          sessionCount: 12000,
          avgSessionDuration: 480,
          errorRate: 0.002,
          apiLatencyP50: 120.0,
          apiLatencyP99: 850.0,
          serverLoad: 65,
          cacheHitRate: 0.92,
          generatedAt: DateTime.now(),
        );

        expect(metrics.dailyActiveUsers, 5000);
        expect(metrics.errorRate, 0.002);
        expect(metrics.cacheHitRate, 0.92);
      });

      test('should serialize and deserialize platform metrics', () {
        final original = PlatformMetrics(
          metricsId: 'metrics_001',
          period: 'daily',
          generatedAt: DateTime(2026, 8, 28),
        );

        final json = original.toJson();
        final restored = PlatformMetrics.fromJson(json);

        expect(restored.metricsId, original.metricsId);
        expect(restored.period, 'daily');
      });
    });
  });
}
