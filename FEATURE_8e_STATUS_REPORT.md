# Feature 8e: Push Notifications & LiveOps
**Status Report** | 2026-09-02

---

## Overview

**Feature 8e** (Phase 5 of Feature 8) implements Firebase Cloud Messaging for push notifications and LiveOps campaign management infrastructure. This layer enables direct player engagement through timely notifications and dynamic campaign content without requiring app updates.

**Repository**: `https://github.com/zka32101/toriverse`  
**Branch**: `claude/triverse-development-r2e05a`  
**Previous Phases**: Features 8a-8d complete (761d594)

---

## Deliverables

### ✅ Firebase Cloud Messaging Layer (1 file, 280 LOC)

#### **FirebaseMessagingService** (280 LOC)
**Location**: `lib/shared/services/firebase_messaging_service.dart`

**Purpose**: Core push notification infrastructure with Firebase Cloud Messaging

**Features**:
- ✅ FCM initialization with iOS/Android permission handling
- ✅ Local notifications plugin integration
- ✅ Foreground message display (app open)
- ✅ Background message handling (app in background)
- ✅ Notification tap routing by event type
- ✅ Android notification channels (4 channels)
- ✅ iOS rich notification support
- ✅ Device token management
- ✅ Topic-based subscriptions for bulk messaging
- ✅ Graceful error handling (silent fail)

**Notification Channels** (Android):
1. **milestone_channel** — Streak milestones (high importance, sound + vibration)
2. **streak_reset_channel** — Streak recovery prompts (high importance)
3. **campaign_channel** — Seasonal events & promotions (default importance)
4. **match_channel** — Match availability (default importance, no sound)

**Methods**:
```dart
Future<void> initialize()
Stream<String> get onTokenRefresh
Future<String?> getFcmToken()
Future<void> subscribeToTopic(String topic)
Future<void> unsubscribeFromTopic(String topic)
Future<void> unsubscribeFromAll()
```

**Callbacks**:
```dart
onMilestoneNotification → MilestoneReachedDialog
onStreakResetNotification → Streak recovery prompt
onCampaignNotification → Campaign details screen
onMatchAvailableNotification → Matchmaking screen
```

**Error Resilience**:
- All Firebase operations wrapped in try/catch
- Permission errors don't crash app
- Token refresh failures handled gracefully
- Invalid notification data silently ignored

---

### ✅ Push Notification Manager (1 file, 320 LOC)

#### **PushNotificationManager** (320 LOC)
**Location**: `lib/features/match/application/services/push_notification_manager.dart`

**Purpose**: Game-specific notification logic and cohort management

**Event Types**:
1. **Milestone Achievement** — 🎉 Celebration + reward preview
   - Example: "🎉 Milestone 10! You earned: Obsidian Board (Legendary)"
   - Sent immediately after milestone confirmed
2. **Streak Recovery** — 💪 Encouragement to play again
   - Example: "Come back! You were on a 25-match streak 💪"
   - Sent 2-4 hours after streak loss (tuned via Remote Config)
3. **Campaign/Event** — 🎊 Promotional content
   - Example: "🎊 Weekend Double Streak! Play 3 matches for 2x points"
   - Sent when campaign launches
4. **Match Available** — ⚡ Opponent waiting
   - Example: "Match waiting! 5 players ready. Start in ~2 min"
   - Sent to idle players via topic delivery

**Cohort Topics**:
- `new_players_day_1` → First 24 hours (onboarding engagement)
- `high_engagement` → Daily active users (growth)
- `at_risk_churn` → Inactive 7+ days (retention)
- `vip_subscribers` → Paid tier (monetization)
- `locale_japan` → Regional targeting (localization)

**Methods**:
```dart
Future<void> initialize()
Future<void> sendMilestoneNotification({...})
Future<void> sendStreakRecoveryNotification({...})
Future<void> broadcastMatchAvailableNotification({...})
Future<void> sendCampaignNotification({...})
Future<void> subscribeToCohortTopic(String cohort)
Future<void> unsubscribeFromCohortTopic(String cohort)
Future<String?> getDeviceToken()
Stream<String> get onTokenRefresh
Future<void> disableAllNotifications()
Future<void> enableAllNotifications()
```

**Notification Payloads** (Type-safe models):
```dart
MilestoneNotificationPayload(
  milestone: 10,
  rewardId: 'board_obsidian',
  rewardName: 'Obsidian Board',
  rewardRarity: 'legendary',
)

StreakResetNotificationPayload(
  streakLost: 25,
  reason: 'match_loss',
)

CampaignNotificationPayload(
  campaignId: 'weekend_double_24',
  campaignName: 'Weekend Double Streak',
  description: 'Play 3 matches for 2x points!',
  imageUrl: 'https://cdn.example.com/weekend_banner.jpg',
  rewardValue: 300, // Bonus points
)
```

---

### ✅ LiveOps Campaign Service (1 file, 420 LOC)

#### **LiveOpsCampaignService** (420 LOC)
**Location**: `lib/features/match/application/services/liveops_campaign_service.dart`

**Purpose**: Manage dynamic campaigns and seasonal events without redeployment

**Features**:
- ✅ Fetch active campaigns from Firestore
- ✅ Featured campaign endpoint (home screen banner)
- ✅ Real-time campaign stream (reactive updates)
- ✅ Campaign reward fetching
- ✅ User campaign progress tracking
- ✅ Reward claiming workflow
- ✅ Special event bonuses (weekend multipliers, holidays)
- ✅ Analytics integration (participation tracking)

**Campaign Models**:

1. **Campaign** (active/live campaigns)
   - id, name, description
   - startTime, endTime, currentlyLive
   - isFeatured, priority
   - bannerImageUrl
   - campaignType (seasonal/promotional/limited_time)
   - cosmeticRewards[]

2. **CampaignReward** (individual reward in campaign)
   - rewardType (cosmetic/cosmetic_voucher/rank_points)
   - rewardId, description, quantity

3. **CampaignProgress** (user's campaign state)
   - campaignId
   - claimedRewards[]
   - challengesCompleted/Required
   - rewardClaimedAt

4. **SpecialEventBonuses** (seasonal multipliers)
   - streakMultiplier (2.0 for weekend double points)
   - cosmeticDropRateIncrease (0.05 for +5%)
   - bonusMatchRewardsMultiplier (1.5 for 50% bonus)

**Methods**:
```dart
Future<List<Campaign>> fetchActiveCampaigns()
Future<Campaign?> fetchFeaturedCampaign()
Stream<List<Campaign>> streamActiveCampaigns()
Future<List<CampaignReward>> fetchCampaignRewards(String campaignId)
Future<void> trackCampaignParticipation({...})
Future<CampaignProgress?> getUserCampaignProgress({...})
Future<bool> claimCampaignReward({...})
Future<SpecialEventBonuses> getSpecialEventBonuses()
```

**Firestore Schema**:
```
firestore/
├── campaigns/
│   ├── weekend_double_24
│   │   ├── name: "Weekend Double Streak"
│   │   ├── description: "Earn 2x points on weekends"
│   │   ├── start_time: "2026-09-06T00:00:00Z"
│   │   ├── end_time: "2026-09-08T23:59:59Z"
│   │   ├── currently_live: true
│   │   ├── is_featured: true
│   │   ├── priority: 1
│   │   ├── campaign_type: "seasonal"
│   │   ├── banner_image_url: "https://..."
│   │   ├── cosmetic_rewards: ["board_obsidian"]
│   │   └── rewards/
│   │       └── bonus_points
│   │           ├── reward_type: "rank_points"
│   │           ├── quantity: 300
│   │           └── description: "Weekend bonus"
│   └── [more campaigns...]
│
└── users/{uid}/
    ├── campaign_participation/
    │   ├── doc1
    │   │   ├── campaign_id: "weekend_double_24"
    │   │   ├── event_type: "viewed"
    │   │   └── timestamp: "2026-09-02T12:30:00Z"
    │   └── [participation events...]
    └── campaign_progress/
        ├── weekend_double_24
        │   ├── claimed_rewards: ["bonus_points"]
        │   ├── challenges_completed: 3
        │   ├── challenges_required: 3
        │   └── reward_claimed_at: "2026-09-02T18:45:00Z"
        └── [campaign progress...]
```

---

### ✅ Notification State Management (1 file, 180 LOC)

#### **NotificationPreferencesProvider** (180 LOC)
**Location**: `lib/features/match/application/providers/notification_state.dart`

**Purpose**: User notification preferences with Riverpod integration

**NotificationPreferences Model**:
```dart
const NotificationPreferences(
  enabled: true,
  milestoneNotifications: true,
  streakRecoveryNotifications: true,
  campaignNotifications: true,
  matchAvailableNotifications: false,
  soundEnabled: true,
  vibrationEnabled: true,
  quietHourStart: TimeOfDay(hour: 23),
  quietHourEnd: TimeOfDay(hour: 8),
)
```

**Providers**:
1. **notificationPreferencesProvider** (mutable)
   - Full notification preferences state
   - Methods: toggleAll(), toggleMilestoneNotifications(), toggleSound(), etc.

2. **milestoneNotificationsEnabledProvider** (read-only)
   - Boolean for milestone notification enabled

3. **streakRecoveryNotificationsEnabledProvider** (read-only)
   - Boolean for streak recovery enabled

4. **campaignNotificationsEnabledProvider** (read-only)
   - Boolean for campaign notifications enabled

**Methods**:
```dart
void toggleAll(bool enabled)
void toggleMilestoneNotifications(bool enabled)
void toggleStreakRecoveryNotifications(bool enabled)
void toggleCampaignNotifications(bool enabled)
void toggleMatchAvailableNotifications(bool enabled)
void toggleSound(bool enabled)
void toggleVibration(bool enabled)
void setQuietHours(TimeOfDay? start, TimeOfDay? end)
void reset()
```

**Quiet Hours**:
- Optional time range for suppressing notifications
- Example: 23:00 - 08:00 for sleep hours
- Persisted to local storage or Firestore

---

## Architecture & Integration

### Push Notification Flow

```
Game Event (Milestone Reached)
  ↓
Server Cloud Function triggered
  ├─ Fetch user's FCM token
  ├─ Check notification preferences
  └─ Send via Firebase Messaging API
  ↓
FirebaseMessagingService receives message
  ├─ Display local notification
  └─ Route to onMilestoneNotification
  ↓
PushNotificationManager handles callback
  ├─ Show celebration dialog
  └─ Log analytics
  ↓
User sees: "🎉 Milestone 10! You earned: Obsidian Board"
```

### LiveOps Campaign Flow

```
Admin creates campaign in Firestore
  ↓
Campaign goes live:
  ├─ Featured: Show on home banner
  ├─ Active: List in campaigns screen
  └─ Broadcast: Send notification to all_players topic
  ↓
Player views campaign
  ├─ Track participation event
  └─ Show campaign details with banner
  ↓
Player claims reward
  ├─ Update claimed_rewards[]
  ├─ Grant cosmetic to player
  └─ Log analytics: campaign_reward_claimed
  ↓
Admin checks analytics in Firebase Console
  ├─ Participation rate: 45%
  ├─ Claim rate: 78%
  └─ Engagement increase: +12%
```

### Notification Preferences

```
Settings Screen
  ├─ Toggle all notifications
  ├─ Milestone achievements
  ├─ Streak recovery prompts
  ├─ Campaigns & events
  ├─ Match availability
  ├─ Sound (on/off)
  ├─ Vibration (on/off)
  └─ Quiet hours (optional)
  ↓
NotificationPreferencesNotifier
  ├─ Persists to local SharedPreferences
  └─ Optional: Sync to Firestore
  ↓
FirebaseMessagingService checks preferences
  ├─ Don't show if disabled
  ├─ Don't show during quiet hours
  └─ Respect sound/vibration settings
```

---

## Quality Metrics

### Code Quality
- ✅ Type Safety: Full type annotations on all functions
- ✅ Null Safety: No unchecked null access
- ✅ Error Handling: All network calls wrapped in try/catch
- ✅ Documentation: Doc comments on public APIs
- ✅ Immutability: Const constructors for models

### Testing Strategy (For Phase 8f)
- FirebaseMessagingService: Mock Firebase Messaging plugin
- PushNotificationManager: Verify event routing and cohort subscriptions
- LiveOpsCampaignService: Mock Firestore, test campaign filtering
- NotificationPreferences: State transitions, persistence

### Performance
- ✅ FCM: Native service, minimal overhead
- ✅ Local Notifications: Async delivery
- ✅ Campaign Fetch: 10-second timeout
- ✅ Stream Updates: Real-time Firestore listeners
- ✅ Topic Delivery: Bulk messaging via FCM Topics

---

## Firestore Setup Required

### Collections to Create

1. **campaigns/** (for LiveOps)
   - Documents: seasonal/promotional campaigns
   - Fields: name, description, dates, featured, rewards
   - Sub-collection: rewards/

2. **users/{uid}/campaign_participation/** (analytics)
   - Tracks: viewed, clicked, claimed for each campaign
   - Used to measure campaign effectiveness

3. **users/{uid}/campaign_progress/** (user state)
   - Tracks: claimed rewards, challenges completed
   - Used for UI state (show claim button vs checkmark)

### Security Rules

```
match /campaigns/{document=**} {
  allow read: if request.auth != null;
  allow write: if false; // Admin only
}

match /users/{uid}/campaign_participation/{document=**} {
  allow read, write: if request.auth.uid == uid;
}

match /users/{uid}/campaign_progress/{document=**} {
  allow read, write: if request.auth.uid == uid;
}
```

### Remote Config Values for LiveOps

- `weekend_streak_multiplier` (default: "1.0")
- `special_event_cosmetic_drop_rate` (default: "0.0")
- `holiday_bonus_match_rewards` (default: "1.0")

---

## Deployment Checklist

### Phase 8e Completion
- [x] FirebaseMessagingService created
- [x] Android notification channels defined
- [x] iOS notification support
- [x] FCM token management
- [x] Topic subscriptions
- [x] PushNotificationManager created
- [x] Event routing by type
- [x] Cohort topic support
- [x] LiveOpsCampaignService created
- [x] Campaign Firestore integration
- [x] Campaign progress tracking
- [x] Special event bonuses
- [x] NotificationPreferences state management
- [x] Quiet hours support
- [x] Documentation complete

### Firebase Setup (Team Responsibility)
- [ ] Enable Cloud Messaging (Production & Test)
- [ ] Create campaigns collection in Firestore
- [ ] Set security rules
- [ ] Create campaign documents for testing
- [ ] Configure Remote Config LiveOps parameters
- [ ] Test push notifications on Android/iOS devices
- [ ] Set up analytics dashboard for campaign metrics

### Phase 8f Next (Testing & Integration)
- [ ] FirebaseMessagingService unit tests (20+ cases)
- [ ] PushNotificationManager integration tests
- [ ] LiveOpsCampaignService Firestore tests
- [ ] NotificationPreferences state tests
- [ ] E2E: Campaign creation → notification delivery
- [ ] E2E: Milestone reached → celebration + notification

---

## Files Created This Phase

### New Files (4)
- `lib/shared/services/firebase_messaging_service.dart` (280 LOC)
- `lib/features/match/application/services/push_notification_manager.dart` (320 LOC)
- `lib/features/match/application/services/liveops_campaign_service.dart` (420 LOC)
- `lib/features/match/application/providers/notification_state.dart` (180 LOC)

### Total
- **Lines Added**: 1,200
- **Files Added**: 4
- **Services**: 3 (Messaging, Notifications, LiveOps)
- **Providers**: 4 (preferences + related)
- **Breaking Changes**: 0

---

## Known Limitations & Next Steps

### Current Limitations
1. **No Local Queue**: Events only sent when online (Phase 8f: add local queue)
2. **No Tests Yet**: Will add in Phase 8f
3. **Campaign Rewards Hardcoded**: No UI yet (Phase 8g: campaign screen)
4. **No Analytics Dashboard**: Available in Firebase Console only

### Phase 8f: Testing & E2E
- Unit tests for all services
- Mock Firestore for campaign tests
- Integration tests for notification routing
- E2E: Campaign creation → delivery

### Phase 8g: UI & Campaign Screens
- Campaign details screen
- Reward claiming UI
- Progress indicator (challenges completed)
- Campaign analytics dashboard
- Notification preferences settings screen

---

## Usage Examples

### Initialize on App Startup
```dart
final messaging = FirebaseMessagingService();
await messaging.initialize();

final pushManager = PushNotificationManager(
  messaging: messaging,
  remoteConfig: ref.read(remoteConfigServiceProvider),
);
await pushManager.initialize();
```

### Subscribe to Campaign Updates
```dart
final campaigns = await ref.watch(activeCampaignsProvider).when(
  data: (list) => list,
  loading: () => [],
  error: (e, st) => [],
);
```

### Check Notification Preferences
```dart
final prefs = ref.watch(notificationPreferencesProvider);
if (prefs.milestoneNotifications && prefs.enabled) {
  // Send milestone notification
}
```

### Track Campaign Participation
```dart
await campaignService.trackCampaignParticipation(
  userId: userId,
  campaignId: 'weekend_double_24',
  eventType: 'claimed_reward',
);
```

---

**Status**: ✅ **PHASE 8E COMPLETE (Foundations)**  
**Completion Level**: 100% (Services & state management ready)  
**Next Phase**: Phase 8f - Testing & E2E verification  
**Timeline**: ~3-5 days for tests + Phase 8g screens

---

*Document created: 2026-09-02*  
*Responsible: Claude Code / zka32101*
