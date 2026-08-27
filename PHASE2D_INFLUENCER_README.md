# Phase 2d: Influencer Program

**Status**: 🚧 In Development  
**Timeline**: Weeks 17-20 (40-50 hour sprint)  
**Target**: Streamer monetization, referral growth, analytics dashboard  
**Success Criterion**: 100+ verified streamers, 0.3-0.5 viral coefficient, $1k monthly earnings for top streamers

---

## Overview

Phase 2d transforms Toriverse streamers into an ecosystem of content creators, influencers, and evangelists. The influencer program monetizes streaming content through tiered earnings, incentivizes referrals, and provides analytics dashboards to drive growth.

**Key Goals:**
- Multi-tier streamer verification (Affiliate → Partner → Premium)
- Revenue sharing based on tier (20-40%)
- Referral program with bonuses and ongoing commissions
- Leaderboard system for gamification
- Achievement badges for milestones
- Analytics dashboard for performance tracking
- Account suspension for policy violations

---

## Architecture

### Directory Structure

```
lib/features/spectating/
├── domain/
│   └── models/
│       ├── spectator_session.dart        # Phase 2a
│       ├── spectator_message.dart        # Phase 2b
│       ├── streaming_session.dart        # Phase 2c
│       └── influencer_program.dart       # Phase 2d - Tiers, verification, referrals
├── application/
│   └── providers/
│       ├── spectator_providers.dart         # Phase 2a
│       ├── spectator_chat_providers.dart    # Phase 2b
│       ├── streaming_providers.dart         # Phase 2c
│       └── influencer_program_providers.dart # Phase 2d - Program state
├── data/
│   └── repositories/
│       ├── spectator_repository.dart        # Phase 2a
│       ├── spectator_chat_repository.dart   # Phase 2b
│       ├── streaming_repository.dart        # Phase 2c
│       └── influencer_program_repository.dart # Phase 2d - Tier management, referrals
└── presentation/
    └── widgets/
        ├── spectator_info_card.dart         # Phase 2a
        ├── spectator_list_widget.dart       # Phase 2a
        ├── spectator_chat_widget.dart       # Phase 2b
        ├── streamer_dashboard_widget.dart   # Phase 2c
        ├── obs_config_widget.dart           # Phase 2c
        ├── highlight_manager_widget.dart    # Phase 2c
        ├── tier_upgrade_card.dart           # Phase 2d - Tier UI
        ├── referral_manager_widget.dart     # Phase 2d - Referral UI
        └── streamer_analytics_widget.dart   # Phase 2d - Analytics dashboard

test/
├── unit/spectating/
│   ├── spectator_session_test.dart
│   ├── spectator_message_test.dart
│   ├── streaming_session_test.dart
│   └── influencer_program_test.dart        # Phase 2d
└── widget/spectating/
    ├── spectator_view_screen_test.dart
    ├── spectator_chat_widget_test.dart
    ├── streamer_dashboard_widget_test.dart
    ├── obs_config_widget_test.dart
    ├── highlight_manager_widget_test.dart
    └── influencer_widgets_test.dart         # Phase 2d
```

### Data Models

**StreamerVerification** (Domain Layer)
```dart
StreamerVerification {
  userId: String,                    // Streamer ID
  tier: StreamerTier,                // Current tier
  isVerified: bool,                  // Verification status
  followerCount: int,                // Total followers
  totalStreams: int,                 // Lifetime streams
  avgViewerCount: double,            // Average concurrent viewers
  badges: List<String>,              // Achievement badges
  isSuspended: bool,                 // Account status
  suspensionReason: String?,         // Why suspended
}

enum StreamerTier {
  unverified,   // 0% revenue share (must verify)
  affiliate,    // 20% revenue share (100 followers, 10 streams)
  partner,      // 30% revenue share (1k followers, 50 streams)
  premium,      // 40% revenue share (10k followers, 200 streams)
}
```

**ReferralRecord** (Domain Layer)
```dart
ReferralRecord {
  id: String,                        // Unique referral ID
  referrerId: String,                // Who referred
  referredUserId: String,            // Who was referred
  referralCode: String,              // Unique code (REF_*)
  referralBonus: int,                // One-time bonus (¥500)
  commissionRate: double,            // Ongoing rate (5%)
  status: ReferralStatus,            // pending, active, inactive
  activatedAt: DateTime?,            // When referred user started paying
  totalCommissionEarned: int?,       // Total commission earned
}
```

**StreamerAnalytics** (Domain Layer)
```dart
StreamerAnalytics {
  userId: String,
  periodStart: DateTime,
  periodEnd: DateTime,
  totalStreams: int,
  totalStreamMinutes: int,
  totalViewerMinutes: int,           // viewer-minutes (engagement metric)
  peakViewerCount: int,
  avgViewerCount: int,
  totalClips: int,
  totalClipViews: int,
  streamingRevenue: double,          // From streams (¥10/min)
  clipRevenue: double,               // From clips (¥5/view)
  affiliateCommission: double,       // From referrals (5%)
  totalRevenue: double,              // Total earned (before platform fee)
}
```

**StreamerBadge** (Domain Layer)
```dart
StreamerBadge {
  id: String,
  name: String,                      // "100 Hours Streamed"
  emoji: String,                     // Display icon
  type: StreamerBadgeType,           // milestone, engagement, etc.
  unlockedAt: DateTime,              // When earned
}

enum StreamerBadgeType {
  milestone,     // Stream hour milestones
  engagement,    // Community engagement records
  content,       // Content quality achievements
  growth,        // Growth milestones (followers)
  special,       // Limited-time events
}
```

### Firestore Schema

**streamerVerifications** collection:
```
streamerVerifications/
  ├─ {userId}/
  │  ├─ tier: string (unverified|affiliate|partner|premium)
  │  ├─ isVerified: boolean
  │  ├─ followerCount: int
  │  ├─ totalStreams: int
  │  ├─ avgViewerCount: number
  │  ├─ verifiedAt: timestamp
  │  ├─ tierUpgradedAt: timestamp
  │  ├─ badges: array [badge_ids]
  │  ├─ isSuspended: boolean
  │  ├─ suspensionReason: string
  │  └─ badges/ (subcollection)
  │     └─ {badgeId}/
  │        ├─ name: string
  │        ├─ emoji: string
  │        ├─ type: string
  │        └─ unlockedAt: timestamp
```

**referralRecords** collection:
```
referralRecords/
  ├─ {referralCode}/
  │  ├─ referrerId: string
  │  ├─ referredUserId: string
  │  ├─ referralCode: string
  │  ├─ referralBonus: int (500)
  │  ├─ commissionRate: number (0.05)
  │  ├─ status: string (pending|active|inactive)
  │  ├─ referredAt: timestamp
  │  ├─ activatedAt: timestamp (null if not yet)
  │  └─ totalCommissionEarned: int
```

**streamerAnalytics** collection (monthly):
```
streamerAnalytics/
  ├─ {userId}_{year}_{month}/
  │  ├─ userId: string
  │  ├─ periodStart: timestamp
  │  ├─ periodEnd: timestamp
  │  ├─ totalStreams: int
  │  ├─ totalStreamMinutes: int
  │  ├─ streamingRevenue: number
  │  ├─ clipRevenue: number
  │  ├─ affiliateCommission: number
  │  ├─ totalRevenue: number
  │  └─ platformFee: number (30%)
```

### Firestore Security Rules

```firestore
// Streamer verification - public read, user/admin write
match /streamerVerifications/{userId} {
  allow read: if request.auth != null;
  allow create, update: if request.auth.uid == userId ||
                           userHasRole(request.auth.uid, 'admin');
  allow delete: if userHasRole(request.auth.uid, 'admin');
}

// Badges subcollection
match /streamerVerifications/{userId}/badges/{badgeId} {
  allow read: if request.auth != null;
  allow write: if userHasRole(request.auth.uid, 'admin');
}

// Referral records - create by anyone, read/manage by admin
match /referralRecords/{referralCode} {
  allow read, create: if request.auth != null;
  allow update, delete: if userHasRole(request.auth.uid, 'admin');
}
```

---

## Features

### Core Functionality

1. **Tier Verification System**
   - Unverified: No monetization (must meet requirements)
   - Affiliate: 20% revenue share (100 followers, 10 streams, 5 avg viewers)
   - Partner: 30% revenue share (1k followers, 50 streams, 25 avg viewers)
   - Premium: 40% revenue share (10k followers, 200 streams, 100 avg viewers)

2. **Tier Upgrade Process**
   - Check eligibility against requirements
   - Display progress toward next tier
   - Automatic tier upgrade when all requirements met
   - Badge awarded at each tier level

3. **Referral Program**
   - Generate unique referral codes (REF_USERID_RANDOM)
   - ¥500 one-time bonus when referred user activates
   - 5% ongoing commission from referred user's earnings
   - Leaderboard showing top referrers
   - Commission tracking and payout

4. **Analytics Dashboard**
   - KPI grid: streams, stream minutes, avg viewers, peak viewers
   - Revenue breakdown: streams + clips + affiliate
   - Viewership stats: viewer-minutes, unique viewers
   - Clip performance: generated, views, shares
   - Engagement metrics: chat engagement, clip share rate

5. **Achievement Badges**
   - Milestone badges (100h, 1k viewers, etc.)
   - Engagement badges (high chat participation)
   - Content badges (high-quality clips)
   - Growth badges (follower milestones)
   - Special badges (limited-time events)

6. **Leaderboard System**
   - Multiple metrics: viewers, followers, earnings, growth
   - Weekly/monthly rankings
   - Badge indicators for achievements
   - Tier badges shown next to name

7. **Account Management**
   - Suspension for policy violations
   - Termination of referral commissions
   - Ban from program
   - Appeal process (TBD Phase 2d+)

### Non-Functional Requirements

| Requirement | Target | Measurement |
|-------------|--------|-------------|
| Tier verification latency | < 2 seconds | Query time |
| Referral code generation | < 1 second | Code creation |
| Analytics calculation | < 5 seconds | Aggregation |
| Leaderboard update | < 10 seconds | Batch processing |
| Uptime | 99.5%+ | System availability |

---

## Implementation Details

### Revenue Share Formula

**Tier-Based Revenue Split:**
```
Gross Revenue = Streaming + Clips + Affiliates
Platform Fee = Gross Revenue × 0.30 (30%)
Streamer Payout = Gross Revenue × Tier.revenueShare

Example - Partner Tier (30% share):
Gross: ¥20,000
Platform: ¥6,000 (30%)
Streamer: ¥6,000 (30% of ¥20k)
Remaining ¥8,000: Split with payment processor/taxes
```

### Referral Commission Flow

```
User A (Referrer) → Generates Code → REF_USERA_ABC123
                    ↓
User B (New) → Signs up with code → Activation
                    ↓
System: Awards ¥500 bonus to User A
System: Tracks User B's earnings (streaming + clips)
Monthly: Calculates 5% commission for User A
Monthly: Transfers commission to User A wallet
```

### Tier Eligibility Checking

```dart
// Requirements per tier
Affiliate: 100 followers AND 10+ streams AND 5 avg viewers
Partner: 1,000 followers AND 50+ streams AND 25 avg viewers
Premium: 10,000 followers AND 200+ streams AND 100 avg viewers

// Check process
1. Fetch StreamerVerification
2. Compare against requirements
3. Identify missing criteria
4. Calculate days until eligible (if not met)
5. Return TierUpgradeEligibility with detailed breakdown
```

### Badge Unlock Triggers

**Milestone Badges:**
- 10 hours streamed
- 100 hours streamed
- 1,000 hours streamed
- 100 total viewers
- 1,000 peak concurrent viewers
- 10,000 peak concurrent viewers

**Engagement Badges:**
- 100 messages in spectator chat
- 1,000 chat messages
- 50 clip generates
- 100 clip generations

**Growth Badges:**
- 100 followers
- 1,000 followers
- 10,000 followers
- 100% growth in 30 days

---

## Testing

### Unit Tests (20 tests) ✅

**File**: `test/unit/spectating/influencer_program_test.dart`

```dart
test('creates streamer verification with correct data')
test('serializes verification to JSON')
test('deserializes verification from JSON')
test('tier extension returns correct labels')
test('tier extension returns correct revenue shares')
test('tier extension returns correct icons')
test('canMonetize returns correct values')
test('permission methods return correct values')
test('creates referral record with correct data')
test('serializes referral to JSON')
test('deserializes referral from JSON')
test('referral status extension returns labels')
test('referral isEarning returns correct values')
test('creates analytics with correct data')
test('creates badge with correct data')
test('badge type extension returns labels')
test('creates leaderboard entry with correct data')
test('creates tier upgrade eligibility')
test('detects when all requirements met')
test('calculates days until eligible')
```

**Run command:**
```bash
flutter test test/unit/spectating/influencer_program_test.dart
```

### Widget Tests (30 placeholders) 🔄

**TierUpgradeCard** (7 tests):
1. Display current and next tier
2. Display requirements list
3. Show upgrade button when eligible
4. Show maximum tier message when at top
5. Display revenue share information
6. Handle loading state
7. Handle error state

**ReferralManagerWidget** (8 tests):
1. Display code generation button
2. Generate and display referral code
3. Copy referral code button
4. Display referral stats
5. Display referral history
6. Show empty state
7. Share referral dialog
8. Display bonus/commission info

**StreamerAnalyticsWidget** (10 tests):
1. Display KPI grid
2. Display revenue breakdown
3. Display viewership stats
4. Display clip performance
5. Display engagement metrics
6. Scroll when content large
7. Handle loading state
8. Handle error state
9. Color code revenue streams
10. Display help text

**Run commands:**
```bash
flutter test test/widget/spectating/influencer_widgets_test.dart
```

---

## Analytics Events

### tier_upgraded
```dart
{
  'userId': 'user_123',
  'newTier': 'partner',
  'revenueShare': 0.3,
}
```

### referral_claimed
```dart
{
  'userId': 'referrer_123',
  'referralCode': 'REF_...',
  'newUserId': 'user_456',
  'bonus': 500,
}
```

### badge_awarded
```dart
{
  'userId': 'user_123',
  'badgeName': '100 Hours Streamed',
  'badgeType': 'milestone',
}
```

### referral_commission_calculated
```dart
{
  'referrerId': 'user_123',
  'referredUserId': 'user_456',
  'commissionAmount': 250,
  'period': '2026-09',
}
```

---

## Performance Optimization

### Latency Budget (Target: < 5 seconds for analytics)

| Component | Budget | Allocation |
|-----------|--------|------------|
| Verification fetch | 500ms | Firestore read |
| Eligibility check | 500ms | Logic processing |
| Analytics aggregation | 2000ms | Multi-doc scan |
| Leaderboard sort | 1000ms | Ranking calc |
| Display render | 500ms | UI update |
| **Total** | **4.5s** | ✅ Within 5s |

### Cost Optimization

**Per verified streamer per month:**
- Tier check: 2 reads
- Analytics aggregation: 30+ reads (streaming sessions)
- Referral updates: 1 write per commission
- **Estimated: 50-100 operations/streamer**

Cost per 10,000 verified streamers:
- 10,000 × 75 = 750,000 operations
- Estimated: < $0.30 per 10k streamers monthly

---

## Rollout Strategy

### Week 17: Foundation
- Deploy domain models and repository
- Implement tier verification logic
- Set up analytics aggregation
- Deploy influencer_program_providers

### Week 18: Verification & Tiers
- Implement TierUpgradeCard widget
- Add tier check endpoints
- Deploy tier upgrade workflow
- Start tier migration for existing streamers

### Week 19: Referrals & Analytics
- Implement ReferralManagerWidget
- Deploy StreamerAnalyticsWidget
- Enable referral code generation
- Commission calculation

### Week 20: Testing & Launch
- Complete widget tests (30/30)
- Integration testing
- Load testing with 1k+ verified streamers
- 10% user rollout
- Leaderboard initialization
- Badge distribution

---

## Success Criteria

### Phase 2d Complete When:

- [x] Tier verification models and logic
- [x] Referral program infrastructure
- [x] Analytics calculation engine
- [x] Achievement badge system
- [x] Presenter widgets (3 widgets)
- [x] Unit tests passing (20/20)
- [x] Widget test placeholders (30/30)
- [ ] Widget test implementation (30/30)
- [ ] Integration tests (tier upgrades, referrals)
- [ ] Load testing (1k+ verified streamers)
- [ ] Analytics accuracy verified
- [ ] Commission calculations accurate
- [ ] Leaderboard working
- [ ] All tests passing
- [ ] Phase 2e architecture (optional) started

### Success Metrics (First 3 Months Post-Launch)

| Metric | Target |
|--------|--------|
| Verified streamers | 100+ |
| Affiliate tier | 80%+ of verified |
| Partner tier | 15-20% of verified |
| Premium tier | 2-5% of verified |
| Avg referrals/streamer | 0.5+ |
| Viral coefficient | 0.3-0.5 |
| Tier upgrade rate | 5%+ monthly |
| Commission payouts | $2k+ monthly |
| User satisfaction | 4+ / 5 stars |

---

## Known Limitations & Future Work

### Phase 2d (Current)

**Limitations:**
- No appeal process for account suspension
- Commissions calculated offline (batch)
- No tax withholding calculations
- Limited badge variety (extensible)
- No streamer tier requirements customization

**Future Enhancements:**
- Appeal system for suspended accounts
- Real-time commission calculation
- Tax withholding and 1099 support
- Seasonal tier promotions
- Custom tier configurations per region
- Premium badge sales

### Phase 2e (Optional - Streaming Partnerships)

**Dependencies on Phase 2d:**
- Verified streamer database
- Accurate earnings tracking
- Leaderboard rankings
- Achievement system

---

## Files Changed

### New Files (8 total)

**Domain:**
- `lib/features/spectating/domain/models/influencer_program.dart` — Tiers, verification, referrals, badges, analytics

**Application:**
- `lib/features/spectating/application/providers/influencer_program_providers.dart` — Riverpod influencer providers

**Data:**
- `lib/features/spectating/data/repositories/influencer_program_repository.dart` — Firestore program operations

**Presentation:**
- `lib/features/spectating/presentation/widgets/tier_upgrade_card.dart` — Tier upgrade UI
- `lib/features/spectating/presentation/widgets/referral_manager_widget.dart` — Referral code UI
- `lib/features/spectating/presentation/widgets/streamer_analytics_widget.dart` — Analytics dashboard

**Testing:**
- `test/unit/spectating/influencer_program_test.dart` — 20 unit tests
- `test/widget/spectating/influencer_widgets_test.dart` — 30 widget test placeholders

**Documentation:**
- `PHASE2D_INFLUENCER_README.md` — This file

---

## Implementation Checklist

### Core Influencer Program

- [x] Domain models (StreamerVerification, ReferralRecord, Analytics)
- [x] Tier system with revenue shares
- [x] Firestore repository implementation
- [x] Riverpod provider setup
- [x] Tier upgrade card widget
- [x] Referral manager widget
- [x] Analytics dashboard widget
- [x] Unit tests (20 tests)
- [x] Widget test placeholders (30 tests)
- [ ] Widget test implementation (30/30)
- [ ] Integration tests (Firestore)
- [ ] Load testing (1k+ streamers)
- [ ] Performance profiling

### Monetization Features

- [ ] Revenue share calculation
- [ ] Commission payout system
- [ ] Tax withholding (Phase 2d+)
- [ ] Payment processor integration

### Advanced Features (Phase 2d+)

- [ ] Leaderboard API endpoint
- [ ] Badge trigger automation
- [ ] Streak tracking
- [ ] Seasonal promotions
- [ ] Suspension appeal process

---

**Status**: 🚧 Phase 2d Development In Progress  
**Created**: 2026-08-27  
**Owner**: Development Team

**Next**: Implement 30 widget tests → Integration testing with Firestore emulator → Load testing → Phase 2d rollout (Week 20+)
