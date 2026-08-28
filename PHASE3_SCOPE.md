# Phase 3: Advanced Analytics, Creator Tools & Community Optimization

**Status**: Planning  
**Target**: Enhanced creator experience, platform analytics, community safety  
**Estimated Models**: 10-12 Freezed classes  
**Estimated Repository Methods**: 30-35  
**Estimated Riverpod Providers**: 25+  
**Estimated Widgets**: 6-8  
**Documentation**: 650+ lines  

---

## Vision

Build upon the Phase 2 "watch-to-enjoy" platform by empowering creators with **detailed analytics**, providing **community moderation tools**, and optimizing **platform performance**. Prepare toriverse for soft launch by enhancing creator monetization visibility, community safety, and user engagement metrics.

### Key Objectives
1. **Creator Empowerment**: Analytics dashboard for earnings, viewership, engagement
2. **Community Safety**: Moderation tools, content filtering, user reports
3. **Performance**: App speed optimization, lazy loading, caching strategies
4. **Engagement**: Notifications, achievements, user retention features
5. **Platform Health**: Monitoring tools, abuse detection, quality metrics

---

## Domain Models (10-12 Total)

### Creator Analytics (4 models)
1. **CreatorAnalyticsDashboard**
   - creatorId, totalViews, totalEarnings, followerGrowth, engagementRate
   - topContent, revenueBreakdown, audienceDemographics, timeSeriesData
   - Real-time dashboard aggregation

2. **ContentPerformance**
   - contentId, contentType (clip, match, stream), views, engagement
   - avgWatchDuration, shareCount, likeCount, completionRate
   - audienceRetention curve, peakViewTime

3. **AudienceDemographics**
   - creatorId, ageGroups, genders, regions, devices, platforms
   - topCountries, languagePreferences, activityTimes
   - Aggregated viewer profile

4. **RevenueAnalytics**
   - creatorId, period (daily, weekly, monthly), totalRevenue
   - subscriptionRevenue, giftRevenue, clipRevenue, adRevenue
   - fees, taxes, netRevenue, projectedAnnualRevenue

### Community Safety (3 models)
5. **UserReport**
   - reportId, reporterId, reportedUserId, reason (harassment, spam, abuse)
   - description, evidence (contentId, screenshot), createdAt
   - status (open, investigating, resolved, dismissed)

6. **ContentModeration**
   - contentId, contentType, flagReason (explicit, spam, misinformation, copyright)
   - status (flagged, reviewing, removed, approved)
   - moderatorNotes, reviewCount

7. **CommunityModeration**
   - moderationId, action (warn, mute, ban), targetUserId, actionReason
   - duration (temporary: hours; permanent), createdAt, createdBy
   - appealable, appealDetails

### Performance & Engagement (3-4 models)
8. **PushNotification**
   - notificationId, userId, type (match_result, friend_request, follower_activity)
   - title, body, deepLink, createdAt, sentAt, deliveredAt
   - readAt, clicked, clickedAt

9. **UserEngagementMetrics**
   - userId, DAU (daily active), MAU (monthly active), sessionDuration
   - featureUsage (search, recommendations, feed, chat), churnRisk
   - lastActiveAt, engagementScore (0-100)

10. **AchievementBadge** (optional Phase 3b)
    - badgeId, name, description, icon, requirement
    - unlockedByCount, rarityTier, category (gameplay, social, monetization)

### Platform Monitoring (1-2 models)
11. **PlatformMetrics**
    - metricsId, period (hourly, daily), DAU, MAU, sessionCount
    - avgSessionDuration, featurePopularity, errorRate, apiLatency
    - serverLoad, databaseQueries, cacheHitRate

---

## Repository Methods (30-35 Total)

### Creator Analytics (8 methods)
- `getCreatorAnalyticsDashboard(creatorId)` — Main dashboard data
- `getContentPerformance(contentId)` — Individual content metrics
- `getAudienceDemographics(creatorId)` — Viewer profile analysis
- `getRevenueAnalytics(creatorId, period)` — Earnings breakdown
- `getTopContent(creatorId, limit, period)` — Best performing content
- `getAudienceRetention(contentId)` — Watch duration curve
- `getGrowthTrends(creatorId, period)` — Follower/view trends
- `exportAnalyticsReport(creatorId, format)` — Download as PDF/CSV

### Community Safety (8 methods)
- `createUserReport(reporterId, reportedUserId, reason, description)` — File report
- `getUserReports(userId, status)` — User's report history
- `getReportsQueue(status, limit)` — Moderator queue
- `updateReportStatus(reportId, newStatus, moderatorNotes)` — Resolution
- `flagContent(contentId, reason, evidence)` — Content flag
- `reviewFlaggedContent(contentId)` — Moderation action
- `getModerationHistory(userId)` — User moderation log
- `appealModerationAction(moderationId, appeal)` — User appeal

### Push Notifications (5 methods)
- `sendPushNotification(userId, notification)` — Send notification
- `getNotificationHistory(userId, limit)` — User's notifications
- `markAsRead(notificationId)` — Read receipt
- `updateNotificationPreferences(userId, preferences)` — Notification settings
- `sendBatchNotifications(userIds, notification)` — Bulk send

### Engagement Metrics (5 methods)
- `recordEngagementAction(userId, action, metadata)` — Log user action
- `getUserEngagementScore(userId)` — Calculate engagement metric
- `getChurnRiskUsers(limit)` — High churn risk cohort
- `getFeatureUsageStats(featureId, period)` — Feature adoption
- `getSessionAnalytics(userId)` — Session duration/frequency

### Platform Monitoring (4 methods)
- `recordPlatformMetrics(metrics)` — Store platform stats
- `getPlatformHealth()` — Overall platform status
- `getErrorRate(period)` — Error tracking
- `getPerformanceMetrics(period)` — Latency/throughput data

### Additional Methods (5+)
- `getAbusePatterns()` — Detect spam/abuse trends
- `recordContentRemoval(contentId, reason)` — Content deletion tracking
- `getModeratorWorkload()` — Moderation queue metrics
- `syncAnalyticsCache()` — Refresh analytics data
- `getRetentionCohort(cohortDate)` — Cohort analysis

---

## Riverpod Providers (25+ Total)

### StreamProviders (Real-time, 10 total)
- `watchCreatorAnalyticsDashboardProvider` — Real-time earnings/views
- `watchContentPerformanceProvider` — Live content metrics
- `watchRevenueAnalyticsProvider` — Live revenue updates
- `watchPlatformMetricsProvider` — System health (admin only)
- `watchReportsQueueProvider` — Moderator queue updates
- `watchUserEngagementProvider` — User activity tracking
- `watchNotificationsProvider` — Real-time notifications
- `watchModeratorActivityProvider` — Moderation log updates
- `watchAbuseDetectionProvider` — Anomaly detection alerts
- `watchFeatureAnalyticsProvider` — Feature usage real-time

### FutureProviders (Async, 10+ total)
- `creatorAnalyticsDashboardProvider` — Cached dashboard
- `contentPerformanceProvider` — Content metrics cache
- `audienceDemographicsProvider` — Viewer profile cache
- `revenueAnalyticsProvider` — Earnings cache
- `topContentProvider` — Best content cache
- `userEngagementMetricsProvider` — Engagement scores
- `platformHealthProvider` — System health cache
- `churnRiskUsersProvider` — High-risk users
- `moderationHistoryProvider` — User moderation log
- `notificationHistoryProvider` — User notifications cache

### MutationProviders (Transactions, 5+ total)
- `createUserReportProvider` → Invalidates reports queue
- `updateReportStatusProvider` → Invalidates moderator queue
- `sendPushNotificationProvider` → Logs notification
- `recordEngagementActionProvider` → Invalidates engagement metrics
- `flagContentProvider` → Invalidates content moderation queue

---

## Widgets (6-8 Total)

### 1. CreatorAnalyticsDashboardWidget
- Earnings summary (total, this month, projected annual)
- Key metrics grid (views, followers, engagement rate)
- Revenue breakdown (subscriptions, gifts, clips, ads)
- Chart: Views/earnings trend (line chart, selectable period)
- Top content carousel
- Audience demographics summary

### 2. ContentPerformanceWidget
- Individual content analytics
- Watch retention curve (line chart)
- Engagement metrics (likes, shares, completion rate)
- Audience demographics for this content
- Similar content recommendations

### 3. UserReportingWidget
- Report submission form
- Report reason selection (dropdown)
- Evidence upload/screenshot
- Report tracking for user
- Appeal option for moderated content

### 4. ModerationDashboardWidget (Admin only)
- Reports queue with filters
- Content moderation queue
- User moderation history
- Pending appeals
- Action buttons (approve, remove, warn, ban)

### 5. PushNotificationSettingsWidget
- Toggle notification types (matches, friends, content)
- Frequency selector (all, daily digest, off)
- Quiet hours configuration
- Notification history view

### 6. EngagementMetricsWidget
- User engagement score (0-100 gauge)
- Feature usage breakdown (pie chart)
- Session duration trends
- Churn risk indicator
- Re-engagement suggestions

### 7. PlatformHealthWidget (Admin only)
- DAU/MAU metrics
- Error rate and types
- API latency percentiles
- Server load indicator
- Database performance

### 8. AchievementBadgesWidget (Phase 3b optional)
- User's unlocked badges
- Progress toward locked badges
- Badge categories
- Rarity indicators
- Share achievements

---

## Firestore Schema & Indexes

```
firestore/
├── creator_analytics/
│   └── {creatorId}/
│       ├── dashboard: CreatorAnalyticsDashboard
│       ├── content_performance/
│       │   └── {contentId}: ContentPerformance
│       ├── audience_demographics: AudienceDemographics
│       └── revenue_analytics/{period}: RevenueAnalytics
├── user_reports/
│   └── {reportId}: UserReport
├── content_moderation/
│   └── {contentId}: ContentModeration
├── moderation_actions/
│   └── {moderationId}: CommunityModeration
├── push_notifications/
│   └── {notificationId}: PushNotification
├── user_engagement/
│   └── {userId}: UserEngagementMetrics
├── platform_metrics/
│   └── {metricsId}: PlatformMetrics
└── achievement_badges/
    └── {badgeId}: AchievementBadge
```

### Composite Indexes (8 total)
1. `user_reports` (status ASC, createdAt DESC)
2. `content_moderation` (status ASC, flagReason ASC)
3. `moderation_actions` (targetUserId ASC, createdAt DESC)
4. `push_notifications` (userId ASC, createdAt DESC)
5. `user_engagement` (engagementScore DESC, lastActiveAt DESC)
6. `creator_analytics` (totalEarnings DESC, followerGrowth DESC)
7. `platform_metrics` (period DESC, DAU DESC)
8. `content_performance` (views DESC, engagementRate DESC)

---

## Analytics Events (15+ KPIs)

- `creator_dashboard_viewed` { creator_id, metrics_type, timestamp }
- `content_reported` { reporter_id, reported_content_id, reason }
- `report_reviewed` { moderator_id, report_id, action }
- `content_moderated` { moderator_id, content_id, action, reason }
- `user_warned` { moderator_id, warned_user_id, reason }
- `user_banned` { moderator_id, banned_user_id, duration, reason }
- `push_notification_sent` { user_id, notification_type, timestamp }
- `push_notification_clicked` { user_id, notification_id, timestamp }
- `engagement_action_recorded` { user_id, action_type, feature_id }
- `churn_risk_detected` { user_id, churn_score, timestamp }
- `moderation_appeal_submitted` { user_id, appeal_id }
- `achievement_unlocked` { user_id, badge_id, timestamp }
- `platform_health_degraded` { metric, value, severity }
- `abuse_pattern_detected` { pattern_type, count, timestamp }
- `analytics_report_exported` { creator_id, format, timestamp }

---

## Performance Targets

| Metric | Target |
|--------|--------|
| Analytics dashboard load | < 1.5s |
| Content performance metrics | < 1.0s |
| Moderation queue load | < 800ms |
| Push notification delivery | < 2s |
| Report processing | < 200ms |
| User engagement score calc | < 500ms |
| Platform health check | < 300ms |

---

## Testing Strategy

- **Unit Tests** (25+ specs): Metrics calculation, moderation logic, engagement scoring
- **Widget Tests** (35+ specs): Analytics UI, moderation interface, settings
- **Integration Tests** (4 specs): Report → moderation → action flow, analytics → export

---

## Implementation Plan

### Step 1: Domain Models (10-12 classes)
- Creator analytics, revenue, audience
- User reports, content moderation
- Platform metrics, engagement

### Step 2: Repository (30-35 methods)
- Analytics retrieval and aggregation
- Report and moderation operations
- Notification management
- Metrics tracking

### Step 3: Riverpod Providers (25+ providers)
- StreamProviders for real-time analytics
- FutureProviders for cached metrics
- MutationProviders for reports/moderation

### Step 4: UI Widgets (6-8 widgets)
- Creator analytics dashboard
- Content performance details
- Moderation tools (admin)
- Notification settings
- Engagement metrics

### Step 5: Tests & Documentation
- Comprehensive test specs
- 650+ line documentation

---

## Success Metrics

✅ All 10-12 models compile  
✅ All 30-35 repository methods work  
✅ All 25+ providers with proper invalidation  
✅ All 6-8 widgets render correctly  
✅ Analytics dashboard < 1.5s load  
✅ Moderation queue updates real-time  
✅ Push notifications deliver < 2s  
✅ Community reports tracked completely  
✅ 95%+ test coverage on models  
✅ 25+ unit tests passing  
✅ 35+ widget tests passing  
✅ 4 integration tests passing  

---

**Next Steps:**
1. Confirm Phase 3 scope ✓
2. Implement domain models
3. Implement repository
4. Implement providers
5. Implement widgets
6. Test & document
7. Create PR #14
8. Merge & move to Phase 4

**Estimated Duration**: 5-7 hours continuous development

---

*Phase 3 Objective: After Phase 3 complete, toriverse platform is feature-complete and optimized for soft launch (Phase 6).*

*Remaining Phases: Phase 4 (QA/Testing), Phase 5 (Pre-Launch Polish), Phase 6+ (Soft Launch & GA)*
