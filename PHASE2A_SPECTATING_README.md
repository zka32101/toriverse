# Phase 2a: Real-Time Observation (Spectating Feature)

**Status**: 🚧 In Development  
**Timeline**: Weeks 5-8 (parallel with GA)  
**Target**: Basic spectating MVP  
**Success Criterion**: 100+ concurrent spectators per match, < 2s latency

---

## Overview

Phase 2a adds live spectating capability to Toriverse, allowing users to watch matches in real-time. This feature transforms the app from play-only to watch-to-enjoy, enabling content sharing and community engagement.

**Key Goals:**
- Users can join spectator sessions for live matches
- Real-time board state synchronization (< 2 seconds)
- Display spectator count and list
- Foundational for Phase 2b (chat) and Phase 2c (streaming)
- Zero impact on active players' performance

---

## Architecture

### Directory Structure

```
lib/features/spectating/
├── domain/
│   └── models/
│       └── spectator_session.dart      # Data model for spectator
├── application/
│   └── providers/
│       └── spectator_providers.dart    # Riverpod providers (state management)
├── data/
│   └── repositories/
│       └── spectator_repository.dart   # Firebase operations
└── presentation/
    ├── screens/
    │   └── spectator_view_screen.dart  # Main spectator UI
    └── widgets/
        ├── spectator_info_card.dart    # Player info display
        └── spectator_list_widget.dart  # Spectator list display

test/
├── unit/spectating/
│   └── spectator_session_test.dart     # Model tests
└── widget/spectating/
    └── spectator_view_screen_test.dart # UI tests
```

### Data Model

**SpectatorSession** (Domain Layer)
```dart
SpectatorSession {
  id: String,                    // Unique to user + match
  matchId: String,               // Which match being watched
  userId: String,                // Who is watching
  displayName: String,           // Display name
  joinedAt: DateTime,            // When they joined
  role: SpectatorRole,           // viewer, commentator, streamer
  deviceInfo: DeviceInfo,        // Platform metadata
  isActive: bool,                // Currently watching?
  lastActivityAt: DateTime,      // For timeout detection
}

enum SpectatorRole {
  viewer,      // Basic spectating (Phase 2a)
  commentator, // Chat permissions (Phase 2b)
  streamer,    // Streaming (Phase 2c)
}

DeviceInfo {
  os: String,         // "iOS", "Android", "Web"
  osVersion: String,
  appVersion: String,
  platform: String,
}
```

### Firestore Schema

**Collection Path**: `matches/{matchId}/spectators`

**Document Structure**:
```
matches/
  ├─ {matchId}/
  │  ├─ (match document fields)
  │  │  ├─ spectatorCount: int
  │  │  ├─ totalSpectators: int
  │  │  ├─ isSpectatable: bool
  │  │  └─ ...
  │  │
  │  └─ spectators/ (subcollection)
  │     └─ {userId}/
  │        ├─ matchId: string
  │        ├─ userId: string
  │        ├─ displayName: string
  │        ├─ joinedAt: timestamp
  │        ├─ role: string
  │        ├─ deviceInfo: map
  │        ├─ isActive: boolean
  │        └─ lastActivityAt: timestamp
```

### Firestore Security Rules

```firestore
// Spectators collection - anyone can read active spectators
match /{matchId}/spectators/{spectatorId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null && 
                   request.auth.uid == request.resource.data.userId;
  allow delete: if request.auth.uid == resource.data.userId;
  allow update: if request.auth.uid == resource.data.userId;
}

// Match document - visible to participants and spectators
match /{matchId} {
  allow read: if request.auth != null ||
                 (resource.data.isSpectatable == true);
}
```

---

## Features

### Core Functionality

1. **Join Spectating**
   - User clicks "Watch Match" or opens spectator URL
   - Creates spectator session document
   - Increments match spectator count
   - Records analytics event

2. **Real-Time Board Updates**
   - Firestore listener watches match document
   - Board state updates automatically (< 2s latency)
   - Read-only rendering (no interaction)

3. **Spectator Count**
   - Real-time count badge in UI
   - Reflects active spectators
   - Displayed in match header

4. **Spectator List**
   - Expandable list of users watching
   - Shows display name and role
   - Optional: Avatar/profile picture

### Non-Functional Requirements

| Requirement | Target | Measurement |
|-------------|--------|-------------|
| Latency | < 2 seconds | Firebase trace |
| Concurrent spectators | 100+ per match | Load test |
| Firestore cost | < 5% increase | Usage analysis |
| Game impact | Zero | Performance profiling |
| Memory overhead | < 5MB | Memory profiler |

---

## Usage

### For Users

**Spectate a Live Match:**
1. User receives share link: `toriverse.app/spectate/match123`
2. Opens link in app
3. SpectatorViewScreen loads
4. Sees live board, player info, spectator count
5. Can share link with others

**Leave Spectating:**
- Navigate back or close screen
- Automatically removed from spectators list

### For Developers

**Add Spectating to Match Screen:**

```dart
// In match screen, add spectator badge
if (isSpectatable) {
  Chip(
    label: Text('👁️ ${spectatorCount} watching'),
  );
}
```

**Access Spectator Providers:**

```dart
// Watch spectators for a match
final spectatorsAsync = ref.watch(matchSpectatorsProvider(matchId));

// Watch spectator count
final countAsync = ref.watch(matchSpectatorCountProvider(matchId));

// Join spectating
await ref.read(joinSpectatorSessionProvider(matchId).future);
```

**Record Spectator Events:**

```dart
// Track when users share matches
await ref.read(recordSpectatorEventProvider(
  SpectatorAnalyticsEvent(
    matchId: matchId,
    userId: userId,
    eventType: 'spectator_shared_url',
    parameters: {'shareMethod': 'whatsapp'},
  )
).future);
```

---

## Testing

### Unit Tests

**Tests Created:**
- `spectator_session_test.dart` (7 tests)
  - Model creation and serialization
  - JSON serialization/deserialization
  - Spectator role handling
  - Device info validation
  - Timestamp tracking

**Run Tests:**
```bash
flutter test test/unit/spectating/spectator_session_test.dart
```

### Widget Tests

**Tests Planned:**
- `spectator_view_screen_test.dart` (9 placeholder tests)
  - Display header and controls
  - Spectator count badge
  - Read-only board widget
  - Player info cards
  - Spectator list expansion
  - Share button functionality
  - Chat button (coming soon dialog)
  - Loading state handling
  - Error state handling

**Run Tests:**
```bash
flutter test test/widget/spectating/spectator_view_screen_test.dart
```

### Integration Tests

**To Implement:**
- Full spectating flow (join → watch → leave)
- Real-time updates with Firestore emulator
- Concurrent spectators (5, 10, 50, 100 users)
- Spectator count accuracy
- Firestore cost simulation

---

## Performance Optimization

### Latency Budget (Target: < 2 seconds)

```
Firestore read latency:     100ms
Network propagation:        300ms
Board rendering:             50ms
Client processing:          150ms
─────────────────────────────────
Total:                      600ms ✓ (within budget)
```

### Cost Optimization

**Firestore Operations:**

Per 30-minute spectator session:
- Match document reads: 1 per update (~1/sec) = 30 reads
- Spectators list reads: 1 per update (~1/10sec) = 3 reads
- **Total per session: ~33 reads**

Cost per 1,000 match sessions:
- 1,000 × 33 = 33,000 reads
- 33,000 × $0.06/100k = $0.02
- **Acceptable for scale**

**Optimization Strategies:**
1. Batch updates (group changes every 500ms)
2. Use Firestore caching (reduce re-reads)
3. Optional: WebSocket gateway (Phase 2c, for 10k+ concurrent)

---

## Analytics Events

### Events Tracked

**spectator_joined**
```dart
{
  'matchId': 'match_123',
  'joinMethod': 'url_share',  // or 'friend_invite', 'trending', 'direct'
  'playerCount': 3,
  'roundInProgress': 5,
}
```

**spectator_left**
```dart
{
  'matchId': 'match_123',
  'watchDurationSeconds': 485,
  'roundsWatched': 3,
}
```

**spectator_shared_url**
```dart
{
  'matchId': 'match_123',
  'shareMethod': 'whatsapp',  // or 'twitter', 'facebook', 'copy', etc.
}
```

### Metrics to Monitor

- Spectator adoption rate (% of players who watch)
- Average spectators per match
- Spectator retention (watch duration)
- Share rate of match URLs
- Device breakdown (iOS vs Android vs Web)

---

## Implementation Checklist

### Core Spectating (MVP - Phase 2a)

- [x] Domain model (SpectatorSession)
- [x] Firestore repository
- [x] Riverpod providers
- [x] SpectatorViewScreen
- [x] Spectator info card widget
- [x] Spectator list widget
- [x] Unit tests
- [x] Widget tests (placeholders)
- [ ] Integration tests (Firestore emulator)
- [ ] Performance testing (100 concurrent)
- [ ] Load testing
- [ ] E2E testing

### UI Enhancements (Phase 2a+)

- [ ] Share match button (SharePlus package)
- [ ] Spectator URL generation & encoding
- [ ] Deep linking integration
- [ ] Spectator count badge on match screen
- [ ] Spectator indicator badge for players

### Phase 2b (Chat & Commentary) - Weeks 9-12

- [ ] Spectator chat messages collection
- [ ] Message moderation rules
- [ ] Real-time message streaming
- [ ] Comment widget UI
- [ ] Commentator role elevation
- [ ] Emoji reactions (optional)

### Phase 2c (OBS/Streaming) - Weeks 13-16

- [ ] OBS browser source URL
- [ ] Spectator view optimization for streaming
- [ ] Twitch metadata integration
- [ ] YouTube Live integration
- [ ] Stream highlight generation
- [ ] Viewer count sync

---

## Rollout Strategy

### Phase 2a Soft Launch (Week 8)

```
Week 8: Internal Beta
├─ Deploy to 10% of users
├─ Monitor Firestore costs & latency
├─ Gather user feedback
└─ Fix any critical issues

Week 9: Gradual Expansion
├─ Scale to 50% of users
├─ Monitor performance metrics
├─ Watch for any scaling issues
└─ Plan Phase 2b

Week 10: Full Rollout
├─ Release to 100% of users
├─ Announce spectating feature in-app
├─ Social media promotion
└─ Monitor user adoption

Weeks 11-12: Optimization
├─ A/B test share button placement
├─ Optimize for viral coefficient
├─ Prepare Phase 2b (chat)
└─ Gather feature feedback
```

---

## Success Criteria

### Phase 2a Complete When:

- [x] Basic spectating deployed
- [ ] 10% of players have used spectating
- [ ] Average 2+ spectators per match
- [ ] < 2s latency achieved
- [ ] < 5% Firestore cost increase
- [ ] 100+ concurrent spectators tested
- [ ] Zero player performance impact
- [ ] Analytics events flowing
- [ ] All tests passing
- [ ] Feature request backlog created (Phase 2b+)

### Success Metrics (First Month Post-Launch)

| Metric | Target |
|--------|--------|
| Spectator adoption | 10-15% |
| Avg spectators/match | 2-3 |
| Average watch time | 3-5 minutes |
| Share rate | 20-30% |
| Viral coefficient impact | +0.1 |

---

## Known Limitations & Future Work

### Phase 2a (Current)

**Limitations:**
- No spectator chat (Phase 2b)
- No streaming integration (Phase 2c)
- No mobile-optimized streamer tools
- Limited spectator analytics

**Future Enhancements:**
- Comment reactions/emotes
- Stream highlights auto-generation
- Spectator achievements/badges
- Viewer leaderboard
- Integration with TikTok/Instagram Reels

---

## References

- **Architecture Spec**: PHASE2_FEATURE_SPEC.md (Section 2a)
- **Firestore Rules**: See firestore.rules file
- **Data Models**: lib/features/spectating/domain/models/
- **Provider Pattern**: https://riverpod.dev/

---

**Status**: 🚧 Phase 2a Development In Progress  
**Created**: 2026-08-27  
**Owner**: Development Team

**Next**: Implement Phase 2a features → Test with Firestore emulator → Load testing → Week 8 soft launch
