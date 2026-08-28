# Phase 3: Advanced Analytics, Creator Tools & Community Optimization

**Status**: ✅ Implemented
**Feature Directory**: `lib/features/analytics_and_moderation/`
**Scope Document**: [`PHASE3_SCOPE.md`](./PHASE3_SCOPE.md)

---

## 1. Overview

Phase 3 builds on the Phase 2 "watch-to-enjoy" creator platform (spectating, clipping, monetization, tournaments, leaderboards, discovery) by adding the operational layer every platform needs before a soft launch:

1. **Creator empowerment** — a real analytics dashboard so creators can see earnings, viewership, and audience composition.
2. **Community safety** — user reporting, content moderation, and moderator tooling.
3. **Engagement** — push notifications, engagement scoring, achievement badges.
4. **Platform health** — error rate, latency, and cache metrics for the ops/admin surface.

All Cloud Firestore writes go through `AnalyticsAndModerationRepository`; the Riverpod layer wraps it with caching (`FutureProvider`), live updates (`StreamProvider`), and transactional mutations with cache-invalidation cascades, following the same pattern established in Phase 2k's Discovery Engine.

---

## 2. Domain Models (11 Freezed classes)

All models live in `lib/features/analytics_and_moderation/domain/models/analytics_and_moderation.dart`.

### Enums
| Enum | Values |
|---|---|
| `ReportReason` | harassment, spam, abuse, misinformation, copyright, other |
| `ContentModerationReason` | explicit, spam, misinformation, copyright, hateSpeech |
| `ModerationAction` | warn, mute, suspend, ban, contentRemoval |
| `ModerationType` | temporary, permanent |
| `NotificationType` | matchResult, friendRequest, followerActivity, newClip, liveStream |
| `ReportStatus` | open, investigating, resolved, dismissed, appealed |

### Creator Analytics (4)
- **`CreatorAnalyticsDashboard`** — aggregated dashboard: `totalViews`, `totalEarnings`, `followerGrowth`, `engagementRate`, `topContent`, `revenueBreakdown`, `audienceDemographics`.
- **`ContentPerformance`** — per-content metrics: `views`, `engagement`, `avgWatchDuration`, `shareCount`, `likeCount`, `completionRate`.
- **`AudienceDemographics`** — `ageGroups`, `genders`, `regions`, `devices`, `topCountries`, `languagePreference` (defaults to `'en'`), `activityTimes`.
- **`RevenueAnalytics`** — full breakdown by source: `subscriptionRevenue`, `giftRevenue`, `clipRevenue`, `adRevenue`, minus `fees`/`taxes` → `netRevenue`, plus `projectedAnnualRevenue`.

### Community Safety (3)
- **`UserReport`** — `reporterId`, `reportedUserId`, `reason`, `evidence`, `status` (defaults `open`), `moderatorNotes`.
- **`ContentModeration`** — flagged content with `flagReason`, `status`, `reviewCount`, `reviewedAt`.
- **`CommunityModeration`** — moderator action log: `action`, `durationType` (defaults `permanent`), `durationHours`, `appealable` (defaults `true`), `appealDetails`.

### Notification & Engagement (3)
- **`PushNotification`** — full delivery lifecycle: `createdAt` → `sentAt` → `deliveredAt` → `readAt`/`clicked`/`clickedAt`.
- **`UserEngagementMetrics`** — `dailyActiveUsers`, `monthlyActiveUsers`, `sessionDuration`, `featureUsage`, `churnRisk`, `engagementScore` (defaults `50`).
- **`AchievementBadge`** — `name`, `description`, `requirement`, `unlockedByCount`, `rarityTier`, `category`.

### Platform Monitoring (1)
- **`PlatformMetrics`** — `dailyActiveUsers`/`monthlyActiveUsers`, `sessionCount`, `avgSessionDuration`, `featurePopularity`, `errorRate`, `apiLatencyP50`/`apiLatencyP99`, `serverLoad`, `databaseQueries`, `cacheHitRate`.

---

## 3. Repository (30 methods)

`lib/features/analytics_and_moderation/data/repositories/analytics_and_moderation_repository.dart`

### Creator Analytics (8)
`getCreatorAnalyticsDashboard`, `getContentPerformance`, `getAudienceDemographics`, `getRevenueAnalytics`, `getTopContent`, `getAudienceRetention`, `getGrowthTrends`, `exportAnalyticsReport`

### Community Safety (8)
`createUserReport`, `getUserReports`, `getReportsQueue`, `updateReportStatus`, `flagContent`, `reviewFlaggedContent`, `getModerationHistory`, `appealModerationAction`

### Push Notifications (5)
`sendPushNotification`, `getNotificationHistory`, `markAsRead`, `updateNotificationPreferences`, `sendBatchNotifications`

### Engagement Metrics (5)
`recordEngagementAction`, `getUserEngagementScore`, `getChurnRiskUsers`, `getFeatureUsageStats`, `getSessionAnalytics`

### Platform Monitoring (4)
`recordPlatformMetrics`, `getPlatformHealth`, `getErrorRate`, `getPerformanceMetrics`

Every method wraps its Firestore call in try/catch and raises a descriptive `Exception`; state-changing methods (`createUserReport`, `updateReportStatus`, `flagContent`, `reviewFlaggedContent`, `appealModerationAction`, `sendPushNotification`, `sendBatchNotifications`, `recordEngagementAction`, `exportAnalyticsReport`) also log a matching Firebase Analytics event.

---

## 4. Riverpod Providers

`lib/features/analytics_and_moderation/application/providers/analytics_and_moderation_providers.dart`

### Parameter classes (`@freezed`)
`RevenueAnalyticsParam`, `TopContentParam`, `GrowthTrendsParam`, `ReportsQueueParam`, `NotificationHistoryParam`, `FeatureUsageParam`, `PlatformMetricsParam`

### Repository provider
`analyticsAndModerationRepositoryProvider` — singleton `Provider` wiring `FirebaseFirestore.instance` + `FirebaseAnalytics.instance`.

### StreamProviders — real-time (5)
| Provider | Refresh interval |
|---|---|
| `watchCreatorAnalyticsDashboardProvider(creatorId)` | 15 min |
| `watchReportsQueueProvider(ReportsQueueParam)` | 1 min (moderator queue) |
| `watchNotificationHistoryProvider(NotificationHistoryParam)` | 30 sec |
| `watchPlatformHealthProvider` | 5 min (admin) |
| `watchChurnRiskUsersProvider(limit)` | 1 hr (admin) |

### FutureProviders — cached async (18)
`creatorAnalyticsDashboardProvider`, `contentPerformanceProvider`, `audienceDemographicsProvider`, `revenueAnalyticsProvider`, `topContentProvider`, `audienceRetentionProvider`, `growthTrendsProvider`, `userReportsProvider`, `reportsQueueProvider`, `moderationHistoryProvider`, `notificationHistoryProvider`, `userEngagementScoreProvider`, `churnRiskUsersProvider`, `featureUsageStatsProvider`, `sessionAnalyticsProvider`, `platformHealthProvider`, `errorRateProvider`, `performanceMetricsProvider`

### MutationProviders — transactions with invalidation cascades (12)
| Provider | Invalidates |
|---|---|
| `exportAnalyticsReportProvider` | — |
| `createUserReportProvider` | `reportsQueueProvider`, `watchReportsQueueProvider` |
| `updateReportStatusProvider` | `reportsQueueProvider`, `watchReportsQueueProvider` |
| `flagContentProvider` | — |
| `reviewFlaggedContentProvider` | — |
| `appealModerationActionProvider` | `moderationHistoryProvider` |
| `sendPushNotificationProvider` | `notificationHistoryProvider`, `watchNotificationHistoryProvider` |
| `markNotificationAsReadProvider` | `notificationHistoryProvider` |
| `updateNotificationPreferencesProvider` | — |
| `sendBatchNotificationsProvider` | — |
| `recordEngagementActionProvider` | `userEngagementScoreProvider` |
| `recordPlatformMetricsProvider` | `platformHealthProvider`, `watchPlatformHealthProvider` |

---

## 5. Widgets (8)

`lib/features/analytics_and_moderation/presentation/widgets/`

1. **`CreatorAnalyticsDashboardWidget`** — metric tile grid (views, earnings, follower growth, engagement rate), top content list, export button. Backed by `watchCreatorAnalyticsDashboardProvider`.
2. **`ContentPerformanceWidget`** — ranked list of a creator's top content with views/likes/shares/completion rate. Backed by `topContentProvider`.
3. **`UserReportingWidget`** — stateful report submission form (reason dropdown + description) calling `createUserReport` directly through the repository, with loading/error snackbar handling.
4. **`ModerationDashboardWidget`** — live moderation queue with a per-report status popup menu calling `updateReportStatus`. Backed by `watchReportsQueueProvider`.
5. **`PushNotificationSettingsWidget`** — per-`NotificationType` switch list persisting via `updateNotificationPreferences`.
6. **`EngagementMetricsWidget`** — engagement score progress bar + session duration/count chips. Backed by `userEngagementScoreProvider` and `sessionAnalyticsProvider`.
7. **`PlatformHealthWidget`** (admin) — system status banner (operational/degraded threshold at 1% error rate) plus latency/cache metric rows. Backed by `watchPlatformHealthProvider`.
8. **`AchievementBadgesWidget`** — presentational grid of earned badges with rarity-tinted icons and description tooltips (accepts a `List<AchievementBadge>` directly since badge unlocking isn't backed by a dedicated repository method in this phase).

---

## 6. Firestore Schema

```
firestore/
├── creator_analytics/{creatorId}/
│   ├── metrics/dashboard: CreatorAnalyticsDashboard
│   ├── content_performance/{contentId}: ContentPerformance
│   ├── demographics/audience: AudienceDemographics
│   ├── revenue/{period}: RevenueAnalytics
│   └── trends/{period}: growth trend data
├── user_reports/{reportId}: UserReport
├── content_moderation/{contentId}: ContentModeration
├── moderation_actions/{moderationId}: CommunityModeration
├── push_notifications/{notificationId}: PushNotification
├── users/{userId}/
│   ├── settings/notifications: notification preferences
│   └── engagement_actions/{actionId}: raw engagement events
├── user_engagement/{userId}: UserEngagementMetrics
├── feature_analytics/{featureId-period}: feature usage stats
└── platform_metrics/{metricsId}: PlatformMetrics
```

### Composite indexes required
1. `user_reports` (status ASC, createdAt DESC)
2. `content_moderation` (status ASC, flagReason ASC)
3. `moderation_actions` (targetUserId ASC, createdAt DESC)
4. `push_notifications` (userId ASC, createdAt DESC)
5. `user_engagement` (churnRisk DESC)
6. `creator_analytics/{creatorId}/content_performance` (views DESC)
7. `platform_metrics` (period ASC, generatedAt DESC)

---

## 7. Analytics Events

`content_reported`, `report_reviewed`, `content_flagged`, `content_moderated`, `moderation_appeal_submitted`, `push_notification_sent`, `batch_notifications_sent`, `engagement_action_recorded`, `analytics_report_exported`

---

## 8. Testing

- **Unit tests** — `test/unit/analytics_and_moderation/analytics_and_moderation_models_test.dart`: 25 specs covering all 11 models (construction, defaults, JSON round-trip, enum coverage).
- **Widget tests** — `test/widget/analytics_and_moderation/analytics_and_moderation_widgets_test.dart`: 32 TODO-scaffolded specs across all 8 widgets plus 3 integration scenarios (report → moderation queue, resolve → queue filtering, revenue update → dashboard refresh).

---

## 9. Known Limitations & Phase 4+ Backlog

- `AchievementBadge` has no dedicated repository/provider layer yet — badge unlocking logic and Firestore persistence are deferred; `AchievementBadgesWidget` is presentation-only for now.
- `exportAnalyticsReport` returns a placeholder URL; real PDF/CSV generation needs a Cloud Function.
- Abuse-pattern detection, moderator workload metrics, and cohort retention analysis (listed as "Additional Methods" in the scope doc) are deferred to Phase 4.
- Widget tests are scaffolded with TODOs, matching the pattern from Phase 2k — full `ProviderScope` mocking to be filled in during the Phase 4 QA pass.

---

**Next**: Phase 4 (QA/Testing) or a focused core-game UI/UX & game-design pass, per current roadmap discussion.
