# Phase 16: Leaderboards & Social Features - IMPLEMENTATION PLAN

**Status**: 🔄 READY TO START  
**Date**: 2026-09-11  
**Branch**: `claude/triverse-development-r2e05a`  
**Estimated LOC**: 1,200-1,500 production code + 300-400 tests

---

## Overview

Phase 16 introduces competitive leaderboards and social connectivity, transforming Toriverse from a solo/asynchronous game into a community-driven platform. Players can track their rankings, compete globally, and connect with friends.

---

## Phase 16 Component Breakdown

### 16.1: Leaderboard System (400-500 LOC)

**Firestore Schema:**
```dart
// Global Leaderboard
PlayerLeaderboardEntry {
  uid: string (document ID)
  username: string
  rankPoints: int
  completedMatchStreak: int
  totalMatches: int
  winRate: double (0.0-1.0)
  lastUpdated: timestamp
  rank: int (computed view)
}

// Rankings by Time Period
DailyLeaderboard {
  uid: string
  rankPoints: int (today only)
  rank: int
  date: string (YYYY-MM-DD)
}

WeeklyLeaderboard {
  uid: string
  rankPoints: int (this week)
  rank: int
  week: int
}

MonthlyLeaderboard {
  uid: string
  rankPoints: int (this month)
  rank: int
  month: string (YYYY-MM)
}
```

**Services to Implement:**
- `LeaderboardService` - Query and update rankings
- `RankCalculationService` - Compute rank points and positions
- `LeaderboardStreamProvider` - Real-time leaderboard updates

**Features:**
- Global rankings (all-time)
- Time-based rankings (daily, weekly, monthly)
- Local rankings (friends only)
- Search players by username
- Rank history tracking

**Test Coverage:**
- Rank point calculation (10 tests)
- Leaderboard queries (8 tests)
- Real-time updates (5 tests)
- Edge cases (rank ties, new players, etc.) (5 tests)

---

### 16.2: Friend System (300-400 LOC)

**Firestore Schema:**
```dart
// User Friendships
UserFriendship {
  userId: string (document ID)
  friends: [string] // UIDs of friends
  friendRequests: {
    incoming: [string] // From whom
    outgoing: [string] // To whom
  }
  blockedUsers: [string]
  lastUpdated: timestamp
}

// Friend Profiles (Cached)
FriendProfile {
  uid: string
  username: string
  avatar: string
  currentRank: int
  currentRankPoints: int
  matchStreak: int
  isOnline: bool
  lastSeenAt: timestamp
}
```

**Services to Implement:**
- `FriendService` - Add/remove friends
- `FriendRequestService` - Request management
- `BlockService` - Block/unblock users
- `PresenceService` - Online status tracking

**Features:**
- Send/accept friend requests
- Friend list with status
- Remove friends
- Block/unblock users
- Friend activity feed

**Test Coverage:**
- Friend request lifecycle (8 tests)
- Friend list operations (6 tests)
- Blocking mechanics (5 tests)
- Presence updates (4 tests)

---

### 16.3: Social Match Features (250-350 LOC)

**Match Types:**
```dart
enum MatchType {
  ranked,        // Ranked ladder (affects rank points)
  casual,        // Casual (no rank impact)
  friendChallenge, // Challenge a specific friend
  tournamentQualifier, // Qualify for tournaments (future)
}
```

**Enhanced Match Model:**
```dart
Match {
  id: string
  matchType: enum
  players: [3] { uid or "AI" }
  invitedBy?: string (who created the match)
  
  // Social metadata
  spectatorUids?: [string] (who can watch - Phase 17)
  
  // Ranking impact
  rankPointsAwarded: [3]int // Per player
  rankChangeApplied: bool
  
  createdAt: timestamp
  completedAt: timestamp
}
```

**Features:**
- Challenge specific friends
- Ranked vs casual match selection
- Rank points awarded/deducted
- Match history with social context
- Replay sharing to friends

**Test Coverage:**
- Match type handling (5 tests)
- Rank point calculation (8 tests)
- Friend matching (6 tests)
- Social metadata (4 tests)

---

### 16.4: Player Profiles (200-300 LOC)

**Profile Data:**
```dart
PlayerProfile {
  uid: string
  username: string
  avatar: string
  bio: string
  joinedAt: timestamp
  
  // Stats
  totalMatches: int
  winRate: double
  currentRank: int
  currentRankPoints: int
  matchStreak: int
  bestStreak: int
  
  // Achievements (future)
  achievements: [string]
  badges: [string]
  
  // Social
  friendCount: int
  blockedCount: int
  isPublic: bool
}
```

**Features:**
- Public player profiles
- Match history view
- Achievement badges
- Stats summary
- Privacy settings

**Test Coverage:**
- Profile CRUD (6 tests)
- Stats calculation (8 tests)
- Privacy enforcement (4 tests)

---

### 16.5: UI Components (250-350 LOC)

**Screens to Create:**
- `LeaderboardScreen` - View global/friend rankings
- `PlayerProfileScreen` - View player details
- `FriendsScreen` - Manage friend list
- `FriendRequestsScreen` - Handle requests
- `LeaderboardDetailScreen` - Detailed rank info

**Widgets to Create:**
- `LeaderboardEntry` - Rank row card
- `PlayerAvatarCard` - Player profile card
- `FriendStatusBadge` - Online/offline indicator
- `RankPointsDisplay` - Rank visualization
- `StreakBadge` - Completion streak display

**Navigation Integration:**
```
Home
├─ Match (existing)
├─ Leaderboard (new)
│  ├─ Global Rankings
│  ├─ Friend Rankings
│  └─ Player Profile
├─ Friends (new)
│  ├─ Friend List
│  └─ Friend Requests
└─ Profile (enhanced)
```

---

## Implementation Timeline

### Week 1: Leaderboard Backend
- Firestore schema design
- LeaderboardService implementation
- RankCalculationService
- Unit tests (28 tests)
- Estimated: 120 hours → 60% done

### Week 2: Friend System Backend
- Firestore schema for friendships
- FriendService implementation
- FriendRequestService
- PresenceService
- Unit tests (23 tests)
- Estimated: 100 hours → 80% done

### Week 3: Social Match Integration
- Enhanced Match model
- Rank points calculation
- Friend matching logic
- Unit tests (23 tests)
- Estimated: 80 hours → 90% done

### Week 4: UI Implementation
- Leaderboard screens
- Player profile screens
- Friends management UI
- Navigation integration
- Widget tests (20 tests)
- Estimated: 100 hours → 100% done

---

## Integration with Existing Systems

### With Offline Queue (Phase 15)
- Match results queued offline
- Rank point updates queued if network fails
- Automatic rank sync on reconnection

### With Game Loop (Phase 12)
- Match completion → Rank update
- AI matches don't affect ranking
- Only human vs human matches count

### With Firebase (Phase 8)
- Leaderboard queries via Firestore
- Real-time listeners for live updates
- Analytics for social features

---

## Rank Points System

**Win Distribution:**
```
3 Human Players: 
  1st place: +30 points
  2nd place: +10 points
  3rd place: -5 points

AI Matches (Casual):
  Win: +0 points (no ranking impact)
  Loss: -0 points

Friend Challenge:
  Win: +20 points
  Loss: -10 points
```

**Adjustments:**
- Matchmaking rating bonus/penalty (TBD in future)
- Streak bonuses (e.g., +5 per consecutive win)
- Time-based decay (TBD - prevent camping)

---

## Real-Time Features

### Live Leaderboard
```dart
// Real-time listener
final leaderboardStream = ref.watch(
  globalLeaderboardProvider.select(
    (data) => data.top100
  ).stream
);

// Rebuilds automatically on rank changes
```

### Presence Updates
```dart
// Track if friend is online
final friendPresence = ref.watch(
  friendPresenceProvider(friendUid)
);
```

### Friend Activity Feed
```dart
// See what friends are doing
final activityFeed = ref.watch(
  friendActivityFeedProvider
);
```

---

## Testing Strategy

### Unit Tests (75+ tests)
```
LeaderboardService          15 tests
RankCalculationService      15 tests
FriendService               12 tests
PlayerProfileService        10 tests
MatchRankingIntegration     8 tests
PresenceService             5 tests
SocialMatchLogic            5 tests
Privacy/Blocking            5 tests
```

### Widget Tests (20+ tests)
```
LeaderboardScreen           6 tests
PlayerProfileScreen         5 tests
FriendsScreen               5 tests
Rank/Streak displays        4 tests
```

### Integration Tests (3-5 tests)
```
Full friend match flow       1 test
Rank update flow             1 test
Leaderboard real-time        1 test
```

---

## Firebase Remote Config

**Adjustable Parameters:**
```dart
// Rank points
'rank_points_1st_place': 30,
'rank_points_2nd_place': 10,
'rank_points_3rd_place': -5,
'rank_points_friend_win': 20,

// Social features
'leaderboard_update_interval_seconds': 300,
'presence_timeout_seconds': 300,
'friend_request_ttl_days': 7,

// Constraints
'max_friends': 200,
'max_blocked_users': 50,
```

---

## Success Metrics

### Engagement KPIs
- % Players with ≥1 friend (target: 40%)
- % Players viewing leaderboard daily (target: 50%)
- Avg session time increase (target: +30%)

### Social KPIs
- Avg friends per player (target: 5-10)
- Friend match conversion rate (target: 20%)
- Repeat match rate with friends (target: 30%)

### Ranking KPIs
- % Players with non-zero rank (target: 60%)
- Leaderboard churn rate (target: 10% weekly)
- Average rank points range (target: 100-5000)

---

## Security Considerations

### Privacy
- ✅ Players can make profiles private
- ✅ Friends-only match history
- ✅ Block players to hide activity
- ✅ No tracking of blocked users' activity

### Fairness
- ✅ AI matches don't affect ranking
- ✅ Rank points only on completion
- ✅ Prevent point farming (detect rapid matches)
- ✅ Report abuse of rank system

### Data Integrity
- ✅ Rank updates via Cloud Functions (server-side)
- ✅ No client-side rank manipulation
- ✅ Audit trail for large point changes
- ✅ Rollback capability for disputed results

---

## Future Enhancements

### Phase 17: Real-time Observation
- Spectate friend matches live
- Watch replays together
- Comments during matches

### Phase 18: Tournaments
- Bracket-based tournaments
- Weekly/monthly competitions
- Prize pools (cosmetics)
- Streaming integration

### Phase 19: Guilds/Clans
- Player organizations
- Guild-wide competitions
- Shared cosmetics/benefits
- Guild chat

---

## Files to Create

### Services (750-1000 LOC)
- `lib/features/leaderboard/domain/models/leaderboard_models.dart`
- `lib/features/leaderboard/application/services/leaderboard_service.dart`
- `lib/features/leaderboard/application/services/rank_calculation_service.dart`
- `lib/features/social/application/services/friend_service.dart`
- `lib/features/social/application/services/presence_service.dart`
- `lib/features/profile/application/services/player_profile_service.dart`

### Providers (300-400 LOC)
- `lib/features/leaderboard/application/providers/leaderboard_provider.dart`
- `lib/features/social/application/providers/friend_provider.dart`
- `lib/features/profile/application/providers/player_profile_provider.dart`

### Presentation (400-500 LOC)
- `lib/features/leaderboard/presentation/screens/leaderboard_screen.dart`
- `lib/features/social/presentation/screens/friends_screen.dart`
- `lib/features/profile/presentation/screens/player_profile_screen.dart`
- Multiple widget files for components

### Tests (300-400 LOC)
- Unit tests for all services
- Widget tests for all screens
- Integration tests for flows

---

## Next Steps

1. ✅ Review this plan
2. ⏳ Approve scope and timeline
3. ⏳ Begin Phase 16.1 (Leaderboard Backend)
4. ⏳ Implement Firestore schemas
5. ⏳ Implement LeaderboardService
6. ⏳ Write unit tests
7. ⏳ Continue with subsequent components

---

**Ready to proceed with Phase 16 implementation.**

Branch: `claude/triverse-development-r2e05a`  
Estimated Start: Immediate (Phase 15 complete)  
Expected Completion: 4 weeks of focused development
