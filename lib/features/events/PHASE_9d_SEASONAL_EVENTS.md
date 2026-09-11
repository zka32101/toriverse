# Phase 9d: Seasonal Events - Campaign & Limited Cosmetics
**Status**: 🚀 Ready for Implementation  
**Date**: 2026-09-05  
**Goal**: Implement seasonal events with limited-time cosmetics, event challenges, and event-specific match modes

---

## Phase 9d Scope

### Core Features

1. **Event System**
   - Create/manage time-limited events (campaigns)
   - Event start/end dates with countdown
   - Event status tracking (upcoming, active, ended)
   - Event metadata: theme, description, rewards
   - Firestore: `events/{eventId}`, `events/{eventId}/challenges/{challengeId}`

2. **Event Challenges**
   - Daily/weekly challenges within events
   - Challenge types: win N matches, score X points, play with friends
   - Reward progression (bronze/silver/gold tiers)
   - Challenge completion tracking
   - Firestore: `users/{uid}/eventProgress/{eventId}/challenges/{challengeId}`

3. **Limited Edition Cosmetics**
   - Event-exclusive stone designs, board themes
   - Time-limited availability (only during event)
   - Automatic unlock on challenge completion
   - Event cosmetic display/showcase
   - Firestore: `cosmetics/limited/{eventId}`, `users/{uid}/eventCosmetics`

4. **Event Match Modes**
   - Bonus point multipliers (1.5x, 2x during events)
   - Event-specific rule variants
   - Special effects/visual themes
   - Rank point acceleration during events
   - Firestore: metadata in match records

5. **Event Leaderboard**
   - Separate leaderboard for event scores
   - Event-specific ranking calculation
   - Top 100 rankings with rewards
   - View leaderboard by event
   - Firestore: `events/{eventId}/leaderboard/{entryId}`

6. **Event Notifications & Reminders**
   - Event launch notification
   - Challenge completion notifications
   - Event ending countdown (24h, 1h before)
   - New challenge available notification
   - Cosmetic reward unlocked notification

---

## Data Models & Firestore Schema

### Event Collections

```dart
// Event document stored in events/{eventId}
Event {
  id: string,                        // Event identifier
  name: string,                      // "Summer Showdown 2026"
  theme: string,                     // Visual theme name
  description: string,               // Event description
  imageUrl: string,                  // Event banner image
  startDate: timestamp,              // When event starts
  endDate: timestamp,                // When event ends
  status: enum(upcoming, active, ended),
  maxRankPoints: int,               // Bonus multiplier base
  pointMultiplier: double,          // 1.5x, 2x, etc.
  totalRewardPool: int,             // Total cosmetics to distribute
  minRankToParticipate: int,        // Entry requirement (0 = all)
  createdAt: timestamp,
  updatedAt: timestamp,
}

// Challenge within event stored in events/{eventId}/challenges/{challengeId}
Challenge {
  id: string,
  eventId: string,
  name: string,                     // "Win 3 Matches"
  description: string,
  type: enum(win_matches, score_points, play_with_friends, win_streak),
  target: int,                      // e.g., 3 matches, 100 points
  reward: {
    tier: enum(bronze, silver, gold),
    cosmeticId: string,            // Cosmetic awarded
    rankPoints: int,               // Bonus points
    description: string,
  },
  startDate: timestamp,
  endDate: timestamp,
  isDaily: bool,                   // True if resets daily
  createdAt: timestamp,
}

// Event progress for user stored in users/{uid}/eventProgress/{eventId}
EventProgress {
  eventId: string,
  uid: string,
  totalScore: int,                 // Sum of all challenge points
  completedChallenges: [string],   // Challenge IDs completed
  unlockedCosmetics: [string],    // Cosmetic IDs earned
  currentRankPosition: int,        // Position on leaderboard
  lastUpdated: timestamp,
  joinedAt: timestamp,
}

// Event-specific cosmetic stored in cosmetics/limited/{eventId}
LimitedCosmetic {
  id: string,
  eventId: string,
  name: string,                    // "Sunset Stone"
  type: enum(stone, board, theme),
  description: string,
  imageUrl: string,
  colors: [string],               // Hex colors
  rarity: enum(common, uncommon, rare, legendary),
  requiresChallenge: string,      // Challenge ID that unlocks it
  basePrice: int,                 // If buyable after event
  eventExclusive: bool,           // Can't be bought after event
  createdAt: timestamp,
}

// Leaderboard entry stored in events/{eventId}/leaderboard/{entryId}
LeaderboardEntry {
  id: string,
  eventId: string,
  uid: string,
  displayName: string,
  score: int,                      // Event points
  rank: int,                       // Placement (1-100)
  completedChallenges: int,
  unlockedCosmetics: int,
  lastUpdated: timestamp,
}

// User's event cosmetics stored in users/{uid}/eventCosmetics/{cosmeticId}
UserEventCosmetic {
  cosmeticId: string,
  eventId: string,
  unlockedAt: timestamp,
  method: enum(challenge, purchase, gift),
  equipped: bool,
}
```

### Firestore Structure

```
firestore/
├── events/
│   └── {eventId}/
│       ├── name
│       ├── startDate
│       ├── endDate
│       ├── status
│       ├── pointMultiplier
│       ├── challenges/
│       │   └── {challengeId}
│       │       ├── type
│       │       ├── target
│       │       └── reward
│       └── leaderboard/
│           └── {entryId}
│               ├── uid
│               ├── score
│               └── rank
│
├── cosmetics/
│   └── limited/
│       └── {eventId}/
│           └── {cosmeticId}
│               ├── name
│               ├── type
│               ├── eventExclusive
│               └── requiresChallenge
│
└── users/{uid}/
    ├── eventProgress/
    │   └── {eventId}
    │       ├── totalScore
    │       ├── completedChallenges
    │       └── unlockedCosmetics
    │
    └── eventCosmetics/
        └── {cosmeticId}
            ├── unlockedAt
            ├── method
            └── equipped
```

---

## Implementation Layers

### 1. Domain Services (lib/features/events/domain/services)

**EventService** (300 LOC)
- `getActiveEvents()` → Stream of current events
- `getEventDetails(eventId)` → Fetch event with challenges
- `joinEvent(uid, eventId)` → Register user for event
- `getEventProgress(uid, eventId)` → User's progress in event
- `completeChallenge(uid, eventId, challengeId)` → Mark challenge done
- `getEventLeaderboard(eventId, limit)` → Top rankings

**ChallengeService** (250 LOC)
- `getChallengesToday(uid, eventId)` → Daily challenges for user
- `validateChallengeCompletion(uid, challenge)` → Check if earned
- `rewardChallenge(uid, challenge)` → Award cosmetic + points
- `getChallengeProgress(uid, challenge)` → User's progress on challenge

**CosmeticEventService** (250 LOC)
- `getLimitedCosmetics(eventId)` → Event's cosmetics
- `unlockCosmetic(uid, cosmeticId)` → Unlock for user
- `equipEventCosmetic(uid, cosmeticId)` → Set as active
- `getUnlockedCosmetics(uid, eventId)` → User's event items
- `isEventExclusiveCosmetic(cosmeticId)` → Check availability

**EventLeaderboardService** (200 LOC)
- `getLeaderboard(eventId, limit)` → Top 100 players
- `getUserRank(uid, eventId)` → Get user's position
- `updateLeaderboardEntry(uid, eventId, score)` → Update ranking
- `getRewardsForRank(eventId, rank)` → Rank-based rewards

---

### 2. Riverpod Providers (lib/features/events/application/providers)

**EventProviders** (250 LOC)
```dart
final activeEventsProvider = StreamProvider<List<Event>>
final eventDetailsProvider = FutureProvider.family<Event, String>
final currentEventProvider = StreamProvider<Event?>  // Active event
final eventNotifierProvider = StateNotifierProvider<EventNotifier, AsyncValue>
```

**ChallengeProviders** (200 LOC)
```dart
final todaysChallengesProvider = StreamProvider<List<Challenge>>
final challengeProgressProvider = FutureProvider.family<int, String>  // Progress %
final completedChallengesProvider = StreamProvider<List<String>>
```

**CosmeticEventProviders** (200 LOC)
```dart
final limitedCosmeticsProvider = FutureProvider.family<List<LimitedCosmetic>, String>
final unlockedCosmeticsProvider = StreamProvider<List<UserEventCosmetic>>
final equippedEventCosmeticProvider = FutureProvider<UserEventCosmetic?>
```

**LeaderboardProviders** (150 LOC)
```dart
final eventLeaderboardProvider = FutureProvider.family<List<LeaderboardEntry>, String>
final userRankProvider = FutureProvider.family<int?, String>  // eventId
final leaderboardNotifierProvider = StateNotifierProvider<LeaderboardNotifier, AsyncValue>
```

---

### 3. UI Layer (lib/features/events/presentation)

**Screens** (1,400 LOC total)

1. **EventsHomeScreen** (350 LOC)
   - Active event banner with countdown timer
   - Upcoming events list (coming soon)
   - Past events archive
   - Featured event highlight
   - Analytics: `event_home_viewed`

2. **EventDetailScreen** (400 LOC)
   - Event description and theme
   - Challenge list with progress bars
   - Event leaderboard (top 10 preview, view all button)
   - Earned cosmetics showcase
   - Join/Participate button
   - Analytics: `event_details_viewed`

3. **ChallengesScreen** (350 LOC)
   - Daily challenges section
   - Challenge cards with rewards
   - Progress indicators
   - Completion notifications
   - Reward claim buttons
   - Analytics: `challenges_screen_viewed`

4. **EventLeaderboardScreen** (300 LOC)
   - Full leaderboard rankings
   - User's position highlighted
   - Rank-based rewards display
   - Sorting options (score, completion rate)
   - Analytics: `leaderboard_viewed`

**Widgets** (800 LOC total)

1. **EventBannerCard** (120 LOC)
   - Event image with countdown timer
   - Status badge (active, upcoming, ended)
   - Quick join button
   - Points multiplier display

2. **ChallengeCard** (150 LOC)
   - Challenge name and description
   - Progress bar (visual + percentage)
   - Target (e.g., "3/5 wins")
   - Reward preview (cosmetic thumbnail + points)
   - Claim button when completed

3. **LeaderboardEntry** (100 LOC)
   - Player rank, name, score
   - Cosmetics earned count
   - User avatar
   - Highlight for current player

4. **LimitedCosmeticCard** (150 LOC)
   - Cosmetic preview (rotating 3D effect or animation)
   - Rarity indicator
   - Unlock method ("Complete Challenge XYZ")
   - "Equip" button if owned
   - Event countdown

5. **EventCountdownTimer** (80 LOC)
   - Days, hours, minutes remaining
   - Color changes as event ends
   - Animated tick animation

6. **ProgressIndicator** (120 LOC)
   - Circular or linear progress
   - Percentage text
   - Milestone markers
   - Tier badges (bronze/silver/gold)

7. **RewardPreview** (80 LOC)
   - Cosmetic thumbnail
   - Rarity star rating
   - Points value
   - "Claimed" checkmark if earned

---

### 4. Routing Integration (lib/config/router.dart)

New routes:
```dart
GoRoute(path: '/events', builder: ..., EventsHomeScreen()),
GoRoute(path: '/events/:eventId', builder: ..., EventDetailScreen()),
GoRoute(path: '/events/:eventId/challenges', builder: ..., ChallengesScreen()),
GoRoute(path: '/events/:eventId/leaderboard', builder: ..., EventLeaderboardScreen()),
```

---

### 5. Analytics Integration

**New Events** (12 events)
```dart
'event_home_viewed'                    // params: none
'event_details_viewed'                 // params: event_id
'challenge_completed'                  // params: event_id, challenge_id, tier
'cosmetic_unlocked'                    // params: event_id, cosmetic_id, rarity
'cosmetic_equipped'                    // params: cosmetic_id, event_id
'leaderboard_viewed'                   // params: event_id
'user_rank_achieved'                   // params: event_id, rank, rewards_count
'event_participated'                   // params: event_id
'challenge_claimed'                    // params: event_id, challenge_id, reward_points
'points_multiplier_applied'            // params: event_id, match_id, multiplier
'event_joined'                         // params: event_id
'event_ended'                          // params: event_id, user_rank, cosmetics_earned
```

---

## Testing Strategy (250+ tests)

### Unit Tests (120 tests)

**EventService** (30 tests)
- Create/retrieve events
- Join event validation
- Event status transitions
- Progress tracking accuracy

**ChallengeService** (30 tests)
- Daily challenge resets
- Completion validation
- Reward calculation
- Progress calculations

**CosmeticEventService** (30 tests)
- Unlock logic
- Equip/unequip functionality
- Limited availability checks
- Event-exclusive validation

**EventLeaderboardService** (30 tests)
- Rank calculation
- Score ordering
- Tie breaking
- Position updates

### Widget Tests (60 tests)

**EventBannerCard**: Countdown rendering, status display  
**ChallengeCard**: Progress bar, completion state  
**LeaderboardEntry**: Ranking display, tie handling  
**LimitedCosmeticCard**: Rarity display, lock/unlock states  

### Integration Tests (70+ tests)

- User joins event → completes challenge → earns cosmetic → appears on leaderboard
- Multiple users competing in same event
- Event ending transitions (active → ended)
- Cosmetic equipping persists across sessions
- Leaderboard reflects real-time score updates

---

## Success Criteria

✅ **Feature Completion**:
- Events fully CRUD-able
- Challenges complete with rewards
- Leaderboards functional
- Event cosmetics unlock system working
- 250+ tests passing

✅ **User Experience**:
- Event countdown visible everywhere
- Challenge completion feels rewarding
- Leaderboard update < 5 second latency
- Cosmetics preview before earning

✅ **Metrics**:
- Event participation rate: 60%+
- Challenge completion rate: 40%+
- Cosmetic unlock/equip rate: 75%+
- Average event engagement: 10+ challenges completed per user

✅ **Technical**:
- Real-time leaderboard updates
- Efficient challenge validation
- No N+1 queries
- Proper index on event queries

---

## Development Timeline

| Task | LOC | Duration |
|------|-----|----------|
| Firestore schema + migrations | 100 | 1.5h |
| Domain Services | 1,000 | 10h |
| Riverpod Providers | 800 | 6h |
| UI Screens (4 screens) | 1,400 | 12h |
| UI Widgets (7 widgets) | 800 | 8h |
| Router Integration | 150 | 1.5h |
| Analytics Integration | 200 | 2h |
| Testing (250+ tests) | 1,200 | 14h |
| Documentation | 150 | 1.5h |
| **Total** | **6,400** | **40h** |

---

## Deliverables Summary

### Code Files (24+ new files)

**Domain Services** (4 files, 1,000 LOC)
- event_service.dart
- challenge_service.dart
- cosmetic_event_service.dart
- event_leaderboard_service.dart

**Riverpod Providers** (4 files, 800 LOC)
- event_providers.dart
- challenge_providers.dart
- cosmetic_event_providers.dart
- leaderboard_providers.dart

**Presentation Screens** (4 files, 1,400 LOC)
- events_home_screen.dart
- event_detail_screen.dart
- challenges_screen.dart
- event_leaderboard_screen.dart

**Presentation Widgets** (7 files, 800 LOC)
- event_banner_card.dart
- challenge_card.dart
- leaderboard_entry.dart
- limited_cosmetic_card.dart
- event_countdown_timer.dart
- progress_indicator.dart
- reward_preview.dart

**Tests** (6 files, 1,200 LOC)
- event_service_test.dart
- challenge_service_test.dart
- cosmetic_event_service_test.dart
- event_leaderboard_service_test.dart
- events_screen_test.dart
- integration_tests.dart

---

## Integration with Existing Features

**With Phase 9c (Social)**:
- Friend-focused challenges ("Play with friend N times")
- Cosmetics visible on friend profiles
- Leaderboard friends' rankings highlighted

**With Match System**:
- Point multipliers applied during event matches
- Event cosmetics equippable in match lobby
- Challenge completion on match end

**With Shop/Cosmetics**:
- Event cosmetics in separate "Limited" section
- After-event purchase option (premium pricing)
- Rarity indicators matching main cosmetics

**With Analytics**:
- Event participation tracked in cohort analysis
- Retention impact of events measured
- Cosmetic engagement metrics

---

## Next Phase (Phase 9e)

**Phase 9e: In-Game Commentary & Spectating**
- Real-time match observation for friends
- AI-generated or curated commentary
- Highlight clips from notable matches
- Estimated: 50h implementation

---

**Status**: ✅ Ready for implementation  
**Blocked By**: None - independent of previous phases  
**Can Start**: Immediately  
**Estimated Completion**: 40 hours of focused development
