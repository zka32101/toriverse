# Phase 2c: OBS/Streaming Integration

**Status**: 🚧 In Development  
**Timeline**: Weeks 13-16 (40-50 hour sprint)  
**Target**: Multi-platform streaming with earnings tracking and highlight auto-generation  
**Success Criterion**: Live streaming on Twitch/YouTube, OBS browser source working, 95%+ uptime, earnings accuracy

---

## Overview

Phase 2c adds comprehensive streaming support, transforming Toriverse into a broadcast platform. Streamers can simultaneously broadcast to Twitch, YouTube, and local OBS setups while spectators watch and engage. Auto-generated highlight clips with SNS-friendly durations keep content fresh and shareable.

**Key Goals:**
- Simultaneous Twitch/YouTube/OBS streaming
- Real-time viewer count synchronization
- Auto-generated highlight clips from milestone events
- Accurate earnings calculation and tracking
- OBS browser source overlay integration
- Streamer earnings dashboard
- Highlight clip management and approval workflow

---

## Architecture

### Directory Structure

```
lib/features/spectating/
├── domain/
│   └── models/
│       ├── spectator_session.dart      # Phase 2a
│       ├── spectator_message.dart      # Phase 2b
│       └── streaming_session.dart      # Phase 2c - Streaming models
├── application/
│   └── providers/
│       ├── spectator_providers.dart       # Phase 2a
│       ├── spectator_chat_providers.dart  # Phase 2b
│       └── streaming_providers.dart       # Phase 2c - Streaming state
├── data/
│   └── repositories/
│       ├── spectator_repository.dart        # Phase 2a
│       ├── spectator_chat_repository.dart   # Phase 2b
│       └── streaming_repository.dart        # Phase 2c - Platform integration
└── presentation/
    ├── screens/
    │   ├── spectator_view_screen.dart       # Phase 2a
    │   └── streaming_setup_screen.dart      # Phase 2c (TODO)
    └── widgets/
        ├── spectator_info_card.dart         # Phase 2a
        ├── spectator_list_widget.dart       # Phase 2a
        ├── spectator_chat_widget.dart       # Phase 2b
        ├── streamer_dashboard_widget.dart   # Phase 2c - Dashboard
        ├── obs_config_widget.dart           # Phase 2c - OBS setup
        └── highlight_manager_widget.dart    # Phase 2c - Clip manager

test/
├── unit/spectating/
│   ├── spectator_session_test.dart
│   ├── spectator_message_test.dart
│   └── streaming_session_test.dart          # Phase 2c
└── widget/spectating/
    ├── spectator_view_screen_test.dart
    ├── spectator_chat_widget_test.dart
    ├── streamer_dashboard_widget_test.dart  # Phase 2c
    ├── obs_config_widget_test.dart          # Phase 2c
    └── highlight_manager_widget_test.dart   # Phase 2c
```

### Data Models

**StreamingSession** (Domain Layer)
```dart
StreamingSession {
  id: String,                        // Unique session ID
  matchId: String,                   // Match being streamed
  userId: String,                    // Streamer's user ID
  displayName: String,               // Streamer's display name
  startedAt: DateTime,               // When stream started
  endedAt: DateTime?,                // When stream ended
  status: StreamingStatus,           // live, offline, paused, etc.
  viewerCount: int,                  // Current concurrent viewers
  totalViews: int,                   // Total cumulative views
  connectedPlatforms: List<String>,  // ['twitch', 'youtube', 'obs']
  twitchChannelUrl: String?,         // Twitch stream URL
  youtubeStreamUrl: String?,         // YouTube Live URL
  obsSourceUrl: String?,             // OBS browser source URL
  revenueEarned: double,             // Revenue from this stream (JPY)
  generatedHighlights: List<HighlightClip>,  // Auto-generated clips
}

enum StreamingStatus {
  offline,      // Not streaming
  starting,     // Initialization
  live,         // Broadcasting
  paused,       // Temporarily paused
  ending,       // Shutdown in progress
  offline_vod,  // Ended, saved as VOD
}
```

**HighlightClip** (Domain Layer)
```dart
HighlightClip {
  id: String,                    // Unique clip ID
  streamingSessionId: String,    // Parent session
  matchId: String,               // Associated match
  title: String,                 // Clip title
  description: String,           // What happened
  startTime: Duration,           // Time in stream
  endTime: Duration,             // Clip duration
  type: HighlightType,           // milestone, epic, turnover, etc.
  viewCount: int,                // Total views
  shareCount: int,               // Times shared
  videoUrl: String?,             // Processed video URL
  isApproved: bool,              // Streamer approved for public
  createdAt: DateTime,           // When generated
  tags: List<String>,            // Searchable tags
}

enum HighlightType {
  milestone,     // Match milestone (e.g., match end)
  epic,          // Epic/impressive moment
  turnover,      // Dramatic reversal
  funny,         // Humorous moment
  close_call,    // Nearly-lost moment
  championship,  // Tournament moment
}
```

**OBSSourceConfig** (Domain Layer)
```dart
OBSSourceConfig {
  matchId: String,                // Match ID for verification
  streamKey: String,              // One-time key (SHA256 hash)
  expiresAt: Duration?,           // Key expiration (default: 24h)
  showChat: bool,                 // Include chat overlay
  showScoreboard: bool,           // Include board overlay
  showPlayerNames: bool,          // Include name overlays
  overlayTheme: String?,          // dark, light, custom
  
  // Generated property
  sourceUrl: String {             // Full browser source URL
    // Returns: https://toriverse.app/spectate/obs?matchId=...&streamKey=...
  }
}
```

**StreamerEarnings** (Domain Layer)
```dart
StreamerEarnings {
  userId: String,                // Streamer ID
  periodStart: DateTime,         // Earnings period start
  periodEnd: DateTime,           // Earnings period end
  totalStreamMinutes: int,       // Total minutes streamed
  totalViewerMinutes: int,       // Total viewer-minutes
  totalClipViews: int,           // Total highlight clip views
  streamingRevenue: double,      // From stream subscriptions (JPY)
  clipRevenue: double,           // From clip views (JPY)
  referralRevenue: double,       // From referrals (JPY)
  totalEarnings: double,         // Total earnings this period (JPY)
}
```

### Firestore Schema

**Collection Paths**: `streamingSessions/`, `matches/{matchId}/streamingConfig/`

**StreamingSession Document**:
```
streamingSessions/
  ├─ {sessionId}/
  │  ├─ matchId: string
  │  ├─ userId: string
  │  ├─ displayName: string
  │  ├─ startedAt: timestamp
  │  ├─ endedAt: timestamp (null if active)
  │  ├─ status: string (live|offline|paused|offline_vod)
  │  ├─ viewerCount: int (real-time)
  │  ├─ totalViews: int (cumulative)
  │  ├─ connectedPlatforms: array ['twitch', 'youtube', 'obs']
  │  ├─ twitchChannelUrl: string
  │  ├─ youtubeStreamUrl: string
  │  ├─ obsSourceUrl: string
  │  ├─ revenueEarned: number (JPY)
  │  ├─ metadata: object (platform-specific)
  │  └─ highlightClips/ (subcollection)
  │     └─ {clipId}/
  │        ├─ title: string
  │        ├─ description: string
  │        ├─ startTime: string (ISO8601 Duration)
  │        ├─ endTime: string
  │        ├─ type: string (milestone|epic|turnover|funny|close_call|championship)
  │        ├─ viewCount: int
  │        ├─ shareCount: int
  │        ├─ videoUrl: string (nullable)
  │        ├─ isApproved: boolean
  │        ├─ createdAt: timestamp
  │        └─ tags: array
```

### Firestore Security Rules

```firestore
// Streaming sessions - anyone can read, streamer can write
match /streamingSessions/{sessionId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null &&
                   request.auth.uid == request.resource.data.userId;
  allow update: if request.auth.uid == resource.data.userId ||
                   userHasRole(request.auth.uid, 'admin');
  allow delete: if request.auth.uid == resource.data.userId ||
                   userHasRole(request.auth.uid, 'admin');
}

// Highlight clips - anyone can read, streamer can manage
match /streamingSessions/{sessionId}/highlightClips/{clipId} {
  allow read: if request.auth != null;
  allow create: if sessionBelongsToUser(sessionId, request.auth.uid);
  allow update: if sessionBelongsToUser(sessionId, request.auth.uid);
  allow delete: if sessionBelongsToUser(sessionId, request.auth.uid) ||
                   userHasRole(request.auth.uid, 'admin');
}

function userHasRole(uid, role) {
  return get(/databases/$(database)/documents/users/$(uid)).data.role == role;
}

function sessionBelongsToUser(sessionId, uid) {
  return get(/databases/$(database)/documents/streamingSessions/$(sessionId)).data.userId == uid;
}
```

---

## Features

### Core Functionality

1. **Start Streaming Session**
   - Initialize stream with target platforms (Twitch, YouTube, OBS)
   - Generate unique stream keys and URLs
   - Create session document in Firestore
   - Log analytics event

2. **Multi-Platform Broadcasting**
   - Simultaneous Twitch and YouTube streaming
   - Local OBS browser source for live overlays
   - Platform-specific metadata (titles, descriptions, tags)
   - Automatic platform failover on error

3. **Real-Time Viewer Count**
   - Firestore listener on viewerCount field
   - Updates from backend at 5-second intervals
   - Display live viewer count in streamer dashboard
   - Historical viewer data for analytics

4. **Auto-Generated Highlight Clips**
   - Milestone events trigger automatic clip creation
   - Types: milestone, epic, turnover, funny, close_call, championship
   - Streamer approval workflow before public display
   - Automatic clip storage with metadata

5. **OBS Browser Source Configuration**
   - Generate unique overlay URLs with stream keys
   - Configurable overlay elements (chat, scoreboard, player names)
   - Theme selection (dark, light, custom)
   - 24-hour key expiration for security
   - One-click URL copy for OBS setup

6. **Earnings Tracking**
   - ¥10 per minute streamed
   - ¥5 per highlight clip view
   - Referral revenue from friend invites
   - Period-based earnings summaries
   - Real-time earnings display in dashboard

7. **Streamer Dashboard**
   - Live viewer count with status indicator
   - Current stream earnings estimate
   - Connected platform status display
   - Quick action to end stream
   - Platform-specific analytics (TBD Phase 2d)

### Non-Functional Requirements

| Requirement | Target | Measurement |
|-------------|--------|-------------|
| Viewer count latency | < 5 seconds | Firestore listener |
| Streaming uptime | 95%+ | Crash analytics |
| Concurrent streams | 100+ | Load test |
| Platform failover | < 30s recovery | E2E test |
| Earnings accuracy | 99.9%+ | Transaction audit |
| OBS source availability | 99%+ | CDN uptime |

---

## Implementation Details

### Streaming Session Lifecycle

```
1. User initiates stream
   ↓
2. StreamingRepository.startStreamingSession()
   - Generates platform URLs
   - Creates Firestore session document
   - Logs analytics event "stream_started"
   ↓
3. Real-time listener on streamingSessions/{sessionId}
   - Watches status, viewerCount, totalViews
   ↓
4. Viewer count updates (backend sends every 5s)
   - Updates streamingSessions/{sessionId}.viewerCount
   - Triggers UI update via StreamProvider
   ↓
5. Milestone events trigger highlight generation
   - Match milestone (end, round score, etc.)
   - Creates HighlightClip document
   - Logs "highlight_generated" event
   ↓
6. User ends stream
   - StreamingRepository.endStreamingSession()
   - Calculates earnings
   - Updates user document
   - Creates VOD record
   - Logs "stream_ended" event
   ↓
7. Cleanup after 7 days (Cloud Functions TTL)
```

### Earnings Calculation Formula

**Per Stream:**
```
streamingRevenue = totalStreamMinutes × ¥10
clipRevenue = totalClipViews × ¥5
totalRevenue = streamingRevenue + clipRevenue
```

**Example (30-min stream, 50 viewers avg, 10 approved clips):**
```
Stream: 30 min × ¥10 = ¥300
Clips: (avg 150 views/clip × 10) × ¥5 = ¥7,500
Total: ¥7,800
```

### OBS Setup Flow

1. Streamer clicks "Configure OBS"
2. OBSConfigWidget displays:
   - Checkbox toggles for overlay elements
   - Theme selector (dark/light/custom)
   - Generated browser source URL
   - Copy button
   - Step-by-step setup instructions
3. Streamer copies URL
4. Paste into OBS browser source
5. Configure dimensions (1920×1080 recommended)
6. Position overlay in scene
7. Click "Apply Settings" to confirm

### Highlight Auto-Generation Triggers

**Milestone Events** (automatic detection):
- Match milestone: Match end
- Epic moment: Reversal of 20+ stones
- Turnaround: Score swing from last to first
- Funny moment: Absurd/unexpected move
- Close call: Match decided by 1-3 stones
- Championship: Tournament/ranked milestone

**Criteria:**
- Minimum 5 seconds, maximum 90 seconds
- Clear start/end points in match timeline
- Unique to avoid duplicates
- Marked for streamer approval before public

---

## Testing

### Unit Tests (15 tests) ✅

**File**: `test/unit/spectating/streaming_session_test.dart`

```dart
test('creates streaming session with correct data')
test('serializes streaming session to JSON')
test('deserializes streaming session from JSON')
test('handles different streaming statuses')
test('streaming status extension returns labels')
test('streaming status isActive returns correct values')
test('streaming platform extension returns labels and icons')
test('creates streaming metadata with correct data')
test('creates highlight clip with correct data')
test('highlight type extension returns labels and emojis')
test('serializes highlight clip to JSON')
test('deserializes highlight clip from JSON')
test('creates OBS config with correct data')
test('generates correct OBS source URL')
test('exports OBS config as JSON')
test('creates earnings summary with correct calculations')
```

**Run command:**
```bash
flutter test test/unit/spectating/streaming_session_test.dart
```

### Widget Tests (30 placeholders) 🔄

**Streamer Dashboard** (10 tests):
1. Display live viewer count
2. Display stream status card
3. Display estimated earnings
4. Display connected platform status
5. End stream button appears
6. Updates viewer count in real-time
7. Handle loading state
8. Handle error state
9. Scroll when content exceeds viewport
10. Display correct color scheme

**OBS Config** (13 tests):
1. Display configuration title
2. Display overlay element checkboxes
3. Toggle chat overlay option
4. Display theme selection buttons
5. Change theme selection
6. Display browser source URL
7. Copy URL button works
8. Display setup instructions
9. Display apply settings button
10. Scroll when content exceeds viewport
11. URL includes selected settings
12. Display instruction step numbers
13. Handle long URLs gracefully

**Highlight Manager** (20 tests):
1. Display app bar with title
2. Display empty state when no clips
3. Display list of clips
4. Display clip card with title
5. Display clip type badge with emoji
6. Display duration and view count
7. Display approval status badge
8. Tap clip opens details dialog
9. Details dialog shows full information
10. Clip actions menu appears
11. Approve action works
12. Share action shows success
13. Delete action shows confirmation
14. Delete confirmation removes clip
15. Handle loading state
16. Handle error state
17. Scroll list when clips exceed viewport
18. Display correct color for each type
19. Handle special characters
20. Display video thumbnail placeholder

**Run commands:**
```bash
flutter test test/widget/spectating/streamer_dashboard_widget_test.dart
flutter test test/widget/spectating/obs_config_widget_test.dart
flutter test test/widget/spectating/highlight_manager_widget_test.dart
```

### Integration Tests (Planned)

- Full streaming lifecycle (start → broadcast → end)
- Multi-platform failover
- OBS browser source functionality
- Highlight clip generation on triggers
- Earnings calculation accuracy
- Real-time viewer synchronization

---

## Analytics Events

### stream_started
```dart
{
  'sessionId': 'session_123',
  'matchId': 'match_456',
  'platforms': ['twitch', 'youtube', 'obs'],
  'userId': 'user_789',
  'displayName': 'Streamer Name',
}
```

### stream_ended
```dart
{
  'sessionId': 'session_123',
  'durationMinutes': 45,
  'totalViewers': 250,
  'peakViewers': 350,
  'revenue': 450.0,
}
```

### highlight_generated
```dart
{
  'clipId': 'clip_456',
  'sessionId': 'session_123',
  'type': 'epic',
  'durationSeconds': 30,
}
```

### highlight_approved
```dart
{
  'clipId': 'clip_456',
  'sessionId': 'session_123',
  'approvedAt': '2026-09-10T15:30:00Z',
}
```

### viewer_count_updated
```dart
{
  'sessionId': 'session_123',
  'viewerCount': 250,
  'totalViews': 5000,
}
```

---

## Performance Optimization

### Latency Budget (Target: < 5 seconds for viewer updates)

| Component | Budget | Allocation |
|-----------|--------|------------|
| Firestore write | 500ms | Viewer count update |
| Network propagation | 1000ms | Geographic variance |
| Firestore listener | 1500ms | Real-time sync |
| Client processing | 1000ms | JSON parsing, UI update |
| Display refresh | 500ms | Flutter frame rendering |
| **Total** | **4.5s** | ✅ Within 5s target |

### Cost Optimization

**Per 30-minute stream with 50 avg viewers:**
- Session creation: 1 write
- Viewer count updates: 6 writes (every 5s)
- Highlight creation: ~2-5 writes (auto-generated)
- Session reads: 50 (spectators watching status)
- **Total: ~60 operations**

Cost per 1,000 streams:
- 1,000 × 60 = 60,000 operations
- Estimated: < $0.03 per 1,000 streams for streaming alone

---

## Rollout Strategy

### Week 13: Foundation
- Deploy domain models and repository
- Implement streaming_providers
- Test with Firebase emulator
- Set up OBS browser source URL generation

### Week 14: Streamer Dashboard
- Implement StreamerDashboardWidget
- Add real-time viewer count
- Add earnings display
- Test dashboard UI/UX

### Week 15: OBS & Highlights
- Implement OBSConfigWidget
- Add highlight auto-generation
- Implement HighlightManagerWidget
- Approval workflow

### Week 16: Testing & Optimization
- Complete widget tests (30/30)
- Integration tests with real Firebase
- Load testing with concurrent streams
- Performance profiling
- Rollout to 10% of users

---

## Success Criteria

### Phase 2c Complete When:

- [x] Streaming models and serialization working
- [x] Streaming repository implemented
- [x] Streaming providers set up
- [x] Presenter widgets built (3 widgets)
- [ ] Unit tests passing (15/15)
- [ ] Widget tests implemented (30/30)
- [ ] Integration tests with Firebase emulator
- [ ] Load testing validates concurrent streams
- [ ] OBS browser source working end-to-end
- [ ] Earnings calculation verified accurate
- [ ] Viewer count sync < 5 seconds
- [ ] Streaming uptime 95%+ verified
- [ ] All tests passing
- [ ] Phase 2d architecture started

### Success Metrics (First Month Post-Launch)

| Metric | Target |
|--------|--------|
| Stream adoption | 20%+ of users start stream |
| Avg stream duration | 30+ minutes |
| Avg concurrent viewers | 50+ |
| Highlight approval rate | 80%+ |
| Earnings accuracy | 99.9%+ |
| Platform uptime | 95%+ |
| User satisfaction | 4+ / 5 stars |

---

## Known Limitations & Future Work

### Phase 2c (Current)

**Limitations:**
- Twitch/YouTube APIs use placeholder implementations
- No platform failover (yet)
- No clip processing/transcoding
- No custom overlay themes
- No replay chat archive

**Future Enhancements:**
- Full Twitch API integration (requires OAuth)
- Full YouTube API integration (requires OAuth)
- Video clip transcoding pipeline
- Custom overlay theme editor
- Replay mode with chat archive
- Multi-bitrate adaptive streaming
- DVR (time-shift playback)

### Phase 2d (Influencer Program)

**Dependencies on Phase 2c:**
- Streaming platform integration
- Earnings tracking accuracy
- Highlight clip management
- Viewer analytics

---

## Files Changed

### New Files (8 total)

**Domain:**
- `lib/features/spectating/domain/models/streaming_session.dart` — Streaming models, highlight clips, OBS config

**Application:**
- `lib/features/spectating/application/providers/streaming_providers.dart` — Riverpod streaming providers

**Data:**
- `lib/features/spectating/data/repositories/streaming_repository.dart` — Firestore streaming operations

**Presentation:**
- `lib/features/spectating/presentation/widgets/streamer_dashboard_widget.dart` — Dashboard UI
- `lib/features/spectating/presentation/widgets/obs_config_widget.dart` — OBS setup UI
- `lib/features/spectating/presentation/widgets/highlight_manager_widget.dart` — Clip manager UI

**Testing:**
- `test/unit/spectating/streaming_session_test.dart` — 15 unit tests
- `test/widget/spectating/streamer_dashboard_widget_test.dart` — 10 widget test placeholders
- `test/widget/spectating/obs_config_widget_test.dart` — 13 widget test placeholders
- `test/widget/spectating/highlight_manager_widget_test.dart` — 20 widget test placeholders

**Documentation:**
- `PHASE2C_STREAMING_README.md` — This file

---

## Implementation Checklist

### Core Streaming (MVP - Phase 2c)

- [x] Domain models (StreamingSession, HighlightClip, OBSSourceConfig)
- [x] Firestore repository with streaming operations
- [x] Riverpod providers for state management
- [x] Streamer dashboard widget
- [x] OBS configuration widget
- [x] Highlight manager widget
- [x] Unit tests (15 tests)
- [x] Widget test placeholders (43 tests)
- [ ] Widget test implementation (43/43)
- [ ] Integration tests (Firebase emulator)
- [ ] Load testing (concurrent streams)
- [ ] Performance profiling
- [ ] Twitch API integration (optional Phase 2c+)
- [ ] YouTube API integration (optional Phase 2c+)

### Platform Integrations (Phase 2c+)

- [ ] Twitch OAuth token management
- [ ] Twitch Create Stream API
- [ ] YouTube OAuth token management
- [ ] YouTube Create Live Event API
- [ ] Platform-specific metadata sync
- [ ] Failover routing on platform error

### Phase 2d (Influencer Program) - Weeks 17-20

- [ ] Streamer verification system
- [ ] Monetization tier system (affiliate, partner, premium)
- [ ] Referral revenue tracking
- [ ] Streamer analytics dashboard
- [ ] Viewer subscription integration

---

## Docs & References

- **Full Architecture Guide**: PHASE2C_STREAMING_README.md (this file)
- **Phase 2b (Chat)**: PHASE2B_CHAT_README.md
- **Firestore Rules**: See firestore.rules
- **Data Models**: lib/features/spectating/domain/models/
- **Provider Pattern**: https://riverpod.dev/
- **Streaming Concepts**: OBS, Twitch API, YouTube Live API docs

---

**Status**: 🚧 Phase 2c Development In Progress  
**Created**: 2026-08-27  
**Owner**: Development Team

**Next**: Implement 43 widget tests → Integration testing with Firestore emulator → Load testing → Phase 2c rollout (Week 16+)
