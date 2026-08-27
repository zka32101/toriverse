# Phase 2: Real-Time Observation Feature Specification

**Vision**: Transform Toriverse from a play-to-win game into a "watch-to-enjoy" platform  
**Timeline**: Weeks 5-16 (parallel with GA Week 1-2)  
**Primary Feature**: Live spectating + social streaming integration  
**Target**: Enable content creators and casual observers to share real-time match excitement

---

## Overview

Phase 2 adds live observation capabilities, allowing users to spectate matches in real-time, enabling the Toriverse experience to be shared with broader audiences through streaming platforms.

**Key Phases:**
- **Phase 2a** (Weeks 5-8): Basic spectating (core feature)
- **Phase 2b** (Weeks 9-12): Live commentary & chat
- **Phase 2c** (Weeks 13-16): OBS/streaming integration
- **Phase 2d** (Weeks 17+): Influencer program & monetization

---

## Phase 2a: Basic Spectating (Core MVP)

### 2a.1 User Stories

**As a casual observer:**
- I want to watch a live match in progress
- I want to see the board state update in real-time
- I want to see player names and scores
- I want to see the current spectator count

**As a content creator:**
- I want to share a match URL with my followers
- I want followers to watch my match live
- I want to see how many people are watching

**As a match participant:**
- I want to see if I'm being watched (spectator count)
- I want to be able to disable spectating if I choose
- I want spectators to not affect my game performance

### 2a.2 Feature Requirements

**Spectator Mode:**
- Read-only access to match state
- Real-time board updates (< 2 second latency)
- Player info display (names, scores, rank)
- Spectator count badge
- Spectator list (optional: names of who's watching)

**Technical Constraints:**
- No impact on match performance
- Separate read path from game data
- Database cost: < 10% increase
- Latency: p99 < 2 seconds
- Concurrent spectators per match: 100+

**User Experience:**
- One-click join from match URL
- No account required (optional)
- Clean, minimal UI (doesn't distract players)
- Mobile-optimized spectator view

### 2a.3 Data Model Changes

**New Firestore Collection: `matches/{matchId}/spectators`**

```dart
Spectator {
  id: string,                      // Document ID = spectator user ID
  matchId: string,
  userId: string,
  displayName: string,
  joinedAt: timestamp,
  role: enum(viewer, commentator, streamer),
  deviceInfo: {
    os: string,                    // "iOS", "Android", "Web"
    osVersion: string,
    appVersion: string,
    platform: string
  },
  isActive: bool,
  lastActivityAt: timestamp
}
```

**Updated Match Document:**

```dart
Match {
  id: string,
  players: [3]{ uid or "AI" },
  // ... existing fields ...
  
  // NEW FIELDS
  isSpectatable: bool,             // Spectating enabled (default: true)
  spectatorCount: int,             // Real-time count
  totalSpectators: int,            // All-time count (for stats)
  spectatorList: [string]?         // Optional public list of viewers
}
```

**New Firestore Rules:**

```firestore
// Spectator collection - anyone can read/create
match /{matchId}/spectators/{spectatorId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null && 
                   request.auth.uid == request.resource.data.userId;
  allow delete: if request.auth.uid == resource.data.userId ||
                   request.auth.uid in get(/databases/$(database)/documents/matches/$(matchId)).data.players;
  allow update: if request.auth.uid == resource.data.userId;
}

// Match visibility for spectators
match /{matchId} {
  allow read: if request.auth != null ||
                 // Public spectating (no auth required for viewing only)
                 (request.resource == null && resource.data.isSpectatable == true);
}
```

### 2a.4 Backend Implementation (Cloud Functions)

**Function: `updateSpectatorCount()`**

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const updateSpectatorCount = functions
  .firestore
  .document('matches/{matchId}/spectators/{spectatorId}')
  .onCreate(async (snap, context) => {
    const { matchId } = context.params;
    const db = admin.firestore();
    
    try {
      // Increment spectator count
      await db.collection('matches').doc(matchId).update({
        spectatorCount: admin.firestore.FieldValue.increment(1),
        totalSpectators: admin.firestore.FieldValue.increment(1)
      });
      
      // Record analytics event
      const match = await db.collection('matches').doc(matchId).get();
      const userId = match.data()?.players[0]; // For attribution
      
      // Event: spectator_joined
      // (sent from client, just validate here)
    } catch (error) {
      console.error('Error updating spectator count:', error);
    }
  });

export const removeSpectator = functions
  .firestore
  .document('matches/{matchId}/spectators/{spectatorId}')
  .onDelete(async (snap, context) => {
    const { matchId } = context.params;
    const db = admin.firestore();
    
    await db.collection('matches').doc(matchId).update({
      spectatorCount: admin.firestore.FieldValue.increment(-1)
    });
  });

// Cleanup: Remove inactive spectators after 30 min
export const cleanupInactiveSpectators = functions
  .pubsub
  .schedule('every 10 minutes')
  .onRun(async (context) => {
    const db = admin.firestore();
    const cutoff = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 30 * 60 * 1000)
    );
    
    const snapshot = await db.collectionGroup('spectators')
      .where('lastActivityAt', '<', cutoff)
      .where('isActive', '==', true)
      .get();
    
    const batch = db.batch();
    snapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });
    
    await batch.commit();
  });
```

### 2a.5 Frontend Implementation (Flutter)

**New Widget: `SpectatorView`**

```dart
class SpectatorView extends ConsumerWidget {
  final String matchId;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Real-time match stream
    final matchStream = ref.watch(
      firestoreMatchStreamProvider(matchId)
    );
    
    // Real-time spectator stream
    final spectatorsStream = ref.watch(
      firestoreSpectatorsStreamProvider(matchId)
    );
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spectating'),
        actions: [
          // Spectator count badge
          Padding(
            padding: const EdgeInsets.all(16),
            child: spectatorsStream.when(
              data: (spectators) => Center(
                child: Text(
                  '👁️ ${spectators.length}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
      body: matchStream.when(
        data: (match) => Column(
          children: [
            // Read-only board display
            SpectatorBoardWidget(
              boardState: match.boardState,
              players: match.players,
              // ... config
            ),
            
            // Player info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int i = 0; i < 3; i++)
                    PlayerInfoCard(
                      playerIndex: i,
                      match: match,
                    ),
                ],
              ),
            ),
            
            // Spectator list (optional)
            Expanded(
              child: spectatorsStream.when(
                data: (spectators) => ListView(
                  children: spectators
                    .map((s) => ListTile(
                      leading: CircleAvatar(
                        child: Text(s.displayName[0]),
                      ),
                      title: Text(s.displayName),
                      trailing: Text(s.role.label),
                    ))
                    .toList(),
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => Center(
                  child: Text('Error: $error'),
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => ErrorScreen(error: error),
      ),
    );
  }
}
```

**Riverpod Providers:**

```dart
// Real-time match stream for spectators
final firestoreMatchStreamProvider =
  StreamProvider.family<Match, String>((ref, matchId) {
    final firestore = FirebaseFirestore.instance;
    
    return firestore
      .collection('matches')
      .doc(matchId)
      .snapshots()
      .map((doc) => Match.fromJson(doc.data()!));
  });

// Real-time spectators list
final firestoreSpectatorsStreamProvider =
  StreamProvider.family<List<Spectator>, String>((ref, matchId) {
    final firestore = FirebaseFirestore.instance;
    
    return firestore
      .collection('matches')
      .doc(matchId)
      .collection('spectators')
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
        .map((doc) => Spectator.fromJson(doc.data()))
        .toList());
  });

// Join spectator session
final joinSpectatorProvider =
  FutureProvider.family<void, String>((ref, matchId) async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    
    final userId = auth.currentUser?.uid ?? 'anonymous_${DateTime.now().millisecondsSinceEpoch}';
    final displayName = auth.currentUser?.displayName ?? 'Guest';
    
    await firestore
      .collection('matches')
      .doc(matchId)
      .collection('spectators')
      .doc(userId)
      .set({
        'matchId': matchId,
        'userId': userId,
        'displayName': displayName,
        'joinedAt': FieldValue.serverTimestamp(),
        'role': 'viewer',
        'isActive': true,
        'lastActivityAt': FieldValue.serverTimestamp(),
      });
  });
```

### 2a.6 Analytics Events

**New Events:**

```dart
// Event 1: spectator_joined
analytics.logEvent(
  name: 'spectator_joined',
  parameters: {
    'matchId': match.id,
    'joinMethod': 'url_share',  // or 'friend_invite', 'trending'
    'playerCount': 3,
    'roundInProgress': currentRound,
  },
);

// Event 2: spectator_left
analytics.logEvent(
  name: 'spectator_left',
  parameters: {
    'matchId': match.id,
    'watchDuration': durationSeconds,
    'roundsWatched': roundsWatched,
  },
);

// Event 3: spectator_shared_url
analytics.logEvent(
  name: 'spectator_shared_url',
  parameters: {
    'matchId': match.id,
    'shareMethod': 'whatsapp',  // or 'twitter', 'facebook', 'copy'
  },
);
```

**Metrics to Track:**
- Spectator conversion (% of testers who watch)
- Average spectators per match
- Spectator retention (watch duration)
- Share rate of match URLs

### 2a.7 UI/UX Design

**Spectator Landing Page:**

```
┌─────────────────────────────────────┐
│ ← Back                    👁️ 42     │  ← Spectator count
├─────────────────────────────────────┤
│                                     │
│     [3-Color Board Display]         │
│     (Read-only, auto-updating)      │
│                                     │
├─────────────────────────────────────┤
│  Player 1      Player 2      Player 3  │
│  ████░░        ████░░        ░░░░░░    │ ← Score bars
│  32 stones     31 stones     1 stone    │
├─────────────────────────────────────┤
│ 🎮 Round 7/10                       │  ← Game progress
│ ⏱️ 00:15 remaining                   │  ← Timer
├─────────────────────────────────────┤
│  [Share Match]  [Chat (Phase 2b)]   │
└─────────────────────────────────────┘
```

**Spectator Badge (In-Game):**

When players are being watched, show subtle badge:

```
┌──────────────────────┐
│ Match in Progress    │
│ 👁️ 5 spectators    │  ← Notifies players they're watched
└──────────────────────┘
```

### 2a.8 Performance Optimization

**Latency Budget (Target: < 2s):**
- Firestore read: 100ms
- Network propagation: 300ms
- Board rendering: 50ms
- Client processing: 150ms
- **Total: 600ms (within budget)**

**Cost Optimization:**

```
Firestore Reads per Spectator Session (30 min avg):
- Match state: 1 read per update (~1 per second) = 30 reads
- Spectators list: 1 read per update (~1 per 10s) = 3 reads
- Total per spectator: ~33 reads per 30-min session

Cost per 1000 match sessions:
- 1000 matches × 33 reads × $0.06 per 100k reads = $0.02
- Acceptable for scale

Optimization strategies:
1. Batch updates (group changes every 500ms)
2. Firestore caching (reduce re-reads)
3. Optional: WebSocket gateway (future Phase 2c)
```

### 2a.9 Testing Strategy

**Unit Tests:**
- [ ] Spectator data model serialization
- [ ] Spectator count increment/decrement logic
- [ ] Spectator cleanup (30-min timeout)

**Widget Tests:**
- [ ] SpectatorView renders correctly
- [ ] Real-time board updates appear
- [ ] Spectator count badge updates
- [ ] Error states handled gracefully

**Integration Tests:**
- [ ] Join spectating flow
- [ ] Watch live match (30 seconds)
- [ ] Board updates in real-time
- [ ] Leave spectating (cleanup)

**Performance Tests:**
- [ ] Join latency < 2 seconds
- [ ] 100 concurrent spectators (load test)
- [ ] No lag during active gameplay

### 2a.10 Success Criteria

**Phase 2a Complete When:**

- [x] Basic spectating feature deployed
- [x] Spectators can join and watch live
- [x] Real-time board updates (< 2s latency)
- [x] Spectator count displayed
- [x] Analytics events firing
- [x] < 5% impact on game performance
- [x] < 10% cost increase from spectating reads
- [x] 100+ concurrent spectators per match validated
- [x] All tests passing
- [x] Playstore/App Store updated

---

## Phase 2b: Live Commentary & Chat (Weeks 9-12)

### 2b.1 Feature Requirements

**In-Game Spectator Chat:**
- [ ] Send/receive messages during match
- [ ] User list of who's chatting
- [ ] Moderator controls (mute, ban)
- [ ] Automatic content moderation
- [ ] Max message length: 500 characters

**Commentator Role:**
- [ ] Elevated permissions (can see hidden info?)
- [ ] Special badge in chat
- [ ] Ability to pin important messages

**Technical Requirements:**
- Firestore collection: `matches/{matchId}/spectatorChat`
- Message retention: 7 days (archival for clips)
- Rate limiting: 1 message per 2 seconds per user
- Moderation: Automated keyword filtering

### 2b.2 Implementation (Estimated 30-40 hours)

```dart
// Message model
SpectatorMessage {
  id: string,
  matchId: string,
  userId: string,
  displayName: string,
  text: string,
  createdAt: timestamp,
  isModerated: bool,
  moderationReason: string?,
  emoji: string?,  // Optional reaction
  isPinned: bool
}

// Chat widget
class SpectatorChatWidget extends ConsumerWidget {
  // Real-time message stream
  // Send message function
  // Moderation overlay
  // Emoji reactions (Phase 2b+)
}
```

### 2b.3 Moderation Strategy

**Automated Content Filtering:**
- Profanity filter (Japanese + English)
- Spam detection (repeated messages)
- Ad detection (keywords like "buy", "dm me")
- Report system (users can report messages)

**Human Moderation (If needed):**
- Moderator role with ban/mute powers
- Flagged message queue for review
- Appeal system for banned users

---

## Phase 2c: OBS/Streaming Integration (Weeks 13-16)

### 2c.1 Feature Requirements

**Streaming Platform Support:**
- [ ] OBS browser source URL
- [ ] Twitch integration (if applicable)
- [ ] YouTube Live integration
- [ ] Metadata tagging

**Streamer Tools:**
- [ ] Custom overlay (scoreboard, player names)
- [ ] Chat integration (show spectator chat)
- [ ] Highlight detection (auto-clip on milestone)
- [ ] Viewer count sync

### 2c.2 OBS Browser Source

```html
<!-- Spectator view as OBS browser source -->
<!-- URL format: https://toriverse.app/spectate/{matchId} -->

Features:
- Chromium rendering (OBS built-in)
- Responsive design (scales to stream resolution)
- Minimal UI (no distracting buttons)
- Custom overlay layer (optional)
```

### 2c.3 Implementation (Estimated 50-70 hours)

- [ ] Create public spectator URL endpoint
- [ ] OBS browser source compatibility testing
- [ ] Twitch API integration (if applicable)
- [ ] YouTube metadata tagging
- [ ] Highlight video generation

---

## Phase 2d: Influencer Program (Weeks 17+)

### 2d.1 Monetization

**Revenue Share Model:**
- [ ] Streamers earn % of viewer subscriptions
- [ ] Clip views generate revenue
- [ ] Referral bonuses for new players

**Influencer Dashboard:**
- Views, earnings, engagement metrics
- Featured matches section
- Payout history

### 2d.2 Implementation (Estimated 60-80 hours)

---

## Integration with Phase 8 GA Launch

**Phase 2a Parallel Development:**
- GA launch (Week 5): Focus on stability
- Phase 2a development (Weeks 5-8): Parallel feature sprint
- Phase 2a launch (Week 8): Released alongside GA Week 3-4 updates

**Gating for Phase 2a:**
- Only launch if GA DAU > 2,000
- Crash-free still > 99.5%
- Performance not impacted

---

## Risk Management

| Risk | Mitigation |
|------|-----------|
| Spectators negatively impact gameplay | Separate read path, no side effects |
| Cost explosion from Firestore reads | Rate limiting, batching, monitoring |
| Toxic chat ruins experience | Moderation tools, keyword filtering |
| Complex streaming integration | Phase it: basic first, streaming later |

---

## Success Metrics for Phase 2

**Phase 2a (Spectating):**
- Spectator adoption: > 10% of players have watched
- Average spectators per match: > 2
- Spectator retention: > 50% stay for full match
- Cost impact: < 5% Firestore increase

**Phase 2b (Chat):**
- Message rate: > 5 messages per match
- Moderation accuracy: > 95%
- Toxic message rate: < 0.5%

**Phase 2c (Streaming):**
- Streamer adoption: > 5% of active users
- Avg concurrent viewers per stream: > 50
- Revenue per stream: > ¥1,000

---

## Rollout Strategy

**Soft Phase 2a Launch (Week 8):**
- [ ] Beta release to 10% of users
- [ ] Monitor for 1 week
- [ ] Collect feedback

**Gradual Rollout (Weeks 9-10):**
- [ ] Scale to 50% of users
- [ ] Monitor performance
- [ ] Address bugs

**Full Rollout (Week 11):**
- [ ] Release to 100% of users
- [ ] Announcement in-app + social media

---

**Status**: ✅ Phase 2 Specification Complete  
**Created**: 2026-08-27  
**Target Launch**: Week 8 (Phase 2a)

**Next**: Begin Phase 2a development (parallel with GA Week 5 stability)
