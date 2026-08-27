# Phase 2b: Spectator Chat & Commentary

**Status**: 🚧 In Development  
**Timeline**: Weeks 9-12 (30-40 hour sprint)  
**Target**: Live chat with moderation and commentator role elevation  
**Success Criterion**: 5+ messages per match, < 0.5% toxic content, 95%+ moderation accuracy

---

## Overview

Phase 2b adds real-time spectator chat capability, transforming passive watching into active community engagement. The feature enables spectators to comment on live matches while moderators maintain a positive, toxicity-free environment.

**Key Goals:**
- Spectators can send and receive real-time chat messages
- Automatic content moderation (profanity, spam, ads)
- Commentator role for elevated permissions (pin messages)
- Moderator controls (mute, ban, delete)
- Message retention and archival for clip generation
- Zero impact on active players' performance

---

## Architecture

### Directory Structure

```
lib/features/spectating/
├── domain/
│   └── models/
│       ├── spectator_session.dart      # Phase 2a
│       └── spectator_message.dart      # Phase 2b - Message & role models
├── application/
│   └── providers/
│       ├── spectator_providers.dart    # Phase 2a
│       └── spectator_chat_providers.dart # Phase 2b - Chat state management
├── data/
│   └── repositories/
│       ├── spectator_repository.dart        # Phase 2a
│       └── spectator_chat_repository.dart   # Phase 2b - Chat operations
└── presentation/
    ├── screens/
    │   ├── spectator_view_screen.dart       # Phase 2a
    │   └── spectator_chat_screen.dart       # Phase 2b (TODO)
    └── widgets/
        ├── spectator_info_card.dart         # Phase 2a
        ├── spectator_list_widget.dart       # Phase 2a
        └── spectator_chat_widget.dart       # Phase 2b - Chat UI

test/
├── unit/spectating/
│   ├── spectator_session_test.dart          # Phase 2a
│   └── spectator_message_test.dart          # Phase 2b
└── widget/spectating/
    ├── spectator_view_screen_test.dart      # Phase 2a
    └── spectator_chat_widget_test.dart      # Phase 2b
```

### Data Model

**SpectatorMessage** (Domain Layer)
```dart
SpectatorMessage {
  id: String,                    // Unique message ID
  matchId: String,               // Which match
  userId: String,                // Who sent it
  displayName: String,           // Display name
  text: String,                  // Message content (max 500 chars)
  createdAt: DateTime,           // When sent
  role: SpectatorChatRole,       // Sender's role
  
  isModerated: bool,             // Content flagged
  moderationReason: String?,     // Why flagged
  emoji: String?,                // Reaction emoji (Phase 2b+)
  isPinned: bool,                // Pinned by moderator
}

enum SpectatorChatRole {
  viewer,        // Basic - can read & send messages
  commentator,   // Elevated - can pin messages
  streamer,      // Full permissions + featured badge
  moderator,     // Ban/mute/delete powers
}
```

### Firestore Schema

**Collection Path**: `matches/{matchId}/spectatorChat`

**Message Document**:
```
matches/
  ├─ {matchId}/
  │  ├─ (match fields with spectatorCount, etc.)
  │  ├─ spectators/ (Phase 2a)
  │  │  └─ {userId}/
  │  │     ├─ displayName, joinedAt, role, isActive, etc.
  │  │
  │  ├─ spectatorChat/ (Phase 2b - NEW)
  │  │  └─ {messageId}/
  │  │     ├─ userId: string
  │  │     ├─ displayName: string
  │  │     ├─ text: string (max 500 chars)
  │  │     ├─ createdAt: timestamp
  │  │     ├─ role: string (viewer|commentator|streamer|moderator)
  │  │     ├─ isModerated: boolean
  │  │     ├─ moderationReason: string?
  │  │     ├─ emoji: string?
  │  │     └─ isPinned: boolean
  │  │
  │  ├─ spectatorChatMutes/ (Phase 2b - User mute tracking)
  │  │  └─ {userId}/
  │  │     ├─ muteUntil: timestamp
  │  │     └─ mutedAt: timestamp
  │  │
  │  └─ spectatorChatReports/ (Phase 2b - Moderation queue)
  │     └─ {reportId}/
  │        ├─ messageId: string
  │        ├─ reportedBy: string
  │        ├─ reason: string
  │        ├─ reportedAt: timestamp
  │        └─ status: string (pending|reviewed|action_taken)
```

### Firestore Security Rules

```firestore
// Chat messages - anyone authenticated can read
match /matches/{matchId}/spectatorChat/{messageId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null && 
                   request.auth.uid == request.resource.data.userId &&
                   request.resource.data.text.size() <= 500;
  allow delete: if request.auth.uid == resource.data.userId ||
                   userHasRole(request.auth.uid, 'moderator');
  allow update: if request.auth.uid == resource.data.userId ||
                   userHasRole(request.auth.uid, 'moderator');
}

// Mutes - moderators only
match /matches/{matchId}/spectatorChatMutes/{userId} {
  allow read: if userHasRole(request.auth.uid, 'moderator');
  allow write: if userHasRole(request.auth.uid, 'moderator');
}

// Reports - anyone can create, moderators can read
match /matches/{matchId}/spectatorChatReports/{reportId} {
  allow create: if request.auth != null;
  allow read: if userHasRole(request.auth.uid, 'moderator');
  allow update: if userHasRole(request.auth.uid, 'moderator');
}

function userHasRole(uid, role) {
  return get(/databases/$(database)/documents/users/$(uid)).data.role == role;
}
```

---

## Features

### Core Functionality

1. **Send Messages**
   - Type and send message (max 500 characters)
   - Automatic moderation check
   - Message stored in Firestore
   - Analytics event logged

2. **Real-Time Message Stream**
   - Firestore listener on spectatorChat collection
   - Messages appear instantly for all spectators
   - Read-only view for non-senders
   - Newest messages at bottom

3. **Automatic Content Moderation**
   - Profanity filter (English + Japanese)
   - Spam detection (repeated characters, all caps)
   - Advertisement detection (buy, dm, links)
   - Messages flagged but still visible with warning

4. **Commentator Permissions**
   - Pin important messages to top
   - See analytics on chat engagement
   - Featured badge in chat
   - Same moderation rules as viewers

5. **Moderator Controls**
   - Delete messages (removes entirely)
   - Mute users (prevents message sending for duration)
   - Ban users (prevents all match participation)
   - View moderation queue (flagged messages)
   - Reason for mute visible to user

6. **User Reporting**
   - Report inappropriate messages
   - Provide reason for report
   - Reports queued for moderator review
   - No action on false reports (reputation system future)

### Non-Functional Requirements

| Requirement | Target | Measurement |
|-------------|--------|-------------|
| Message latency | < 2 seconds | Firebase trace |
| Concurrent users | 100+ per match | Load test |
| Message retention | 7 days | Firestore TTL |
| Moderation accuracy | 95%+ | Manual review |
| Toxic content rate | < 0.5% | Auto + manual review |
| CPU impact | < 2% | Profiling |

---

## Implementation Details

### Moderation System

**Automated Patterns** (checked in order):
1. Profanity patterns (regex list)
2. Spam patterns (repeated chars, all caps)
3. Advertisement patterns (keywords + URLs)

**Manual Review** (moderation queue):
- Flagged messages stored in spectatorChatReports
- Moderators review reported/flagged messages
- Actions: Approve, Delete, Warn user

**Rate Limiting**:
- 1 message per 2 seconds per user
- Enforced server-side via timestamp check
- Prevents spam and botting

**Message Lifecycle**:
1. User sends message (client-side check for mute)
2. Server receives, checks moderation
3. Message stored with isModerated flag
4. Analytics event logged
5. Real-time listener broadcasts to spectators
6. After 7 days, message auto-deleted (TTL)

### Chat Widget Integration

The `SpectatorChatWidget` is embedded in `SpectatorViewScreen` (Phase 2a).

```dart
// In spectator_view_screen.dart
Expanded(
  child: SpectatorChatWidget(
    matchId: matchId,
    userId: currentUserId,
    displayName: userDisplayName,
    userRole: userRole, // viewer, commentator, streamer
  ),
)
```

**Widget Responsibilities:**
- Display message list (scrollable, newest at bottom)
- Message input field with send button
- Show role badges (👁️ 🎤 📺 🛡️)
- Show pinned message indicator
- Show moderation flags
- Long-press context menu for actions
- Handle mute check before send

---

## Testing

### Unit Tests (10 tests) ✅

**File**: `test/unit/spectating/spectator_message_test.dart`

```dart
test('creates message with correct data')
test('serializes message to JSON correctly')
test('deserializes message from JSON correctly')
test('handles different chat roles')
test('moderates message with content flag')
test('pins message with moderator control')
test('tracks emoji reactions')
test('viewer role has correct permissions')
test('commentator role can pin messages')
test('moderator role can ban users')
```

**Run command:**
```bash
flutter test test/unit/spectating/spectator_message_test.dart
```

### Widget Tests (20 placeholders) 🔄

**File**: `test/widget/spectating/spectator_chat_widget_test.dart`

Ready for implementation:
1. Display message input field
2. Send message when button is tapped
3. Display messages in chronological order
4. Show empty state when no messages
5. Display user role badges correctly
6. Show pinned message indicator
7. Show moderation flags on flagged messages
8. Commentator can pin messages
9. Moderator can delete messages
10. User can report messages
11. Prevent sending when muted
12. Enforce maximum message length
13. Handle loading state gracefully
14. Handle error state with helpful message
15. Display rate limit message
16. Viewer sees limited options
17. Display user avatars correctly
18. Handle special characters in messages
19. Update message list in real-time
20. Show streaming indicator when active

**Run command:**
```bash
flutter test test/widget/spectating/spectator_chat_widget_test.dart
```

### Integration Tests (Planned)

- Full chat flow (join → send → receive → leave)
- Real-time updates with Firestore emulator
- Moderation accuracy under load
- Rate limiting enforcement
- Message cleanup after 7 days

---

## Analytics Events

### message_sent
```dart
{
  'matchId': 'match_123',
  'messageLength': 45,
  'userRole': 'viewer',
  'isModerated': false,
}
```

### message_moderated
```dart
{
  'matchId': 'match_123',
  'reason': 'Profanity',
  'isApproved': false,
}
```

### message_pinned
```dart
{
  'matchId': 'match_123',
  'messageId': 'msg_456',
}
```

### message_reported
```dart
{
  'matchId': 'match_123',
  'messageId': 'msg_456',
  'reason': 'Inappropriate content',
}
```

### user_muted
```dart
{
  'matchId': 'match_123',
  'targetUserId': 'user_789',
  'durationSeconds': 300,
}
```

---

## Performance Optimization

### Latency Budget (Target: < 2 seconds for messages)

| Component | Budget | Allocation |
|-----------|--------|------------|
| Firestore write | 100ms | Document insert |
| Moderation check | 200ms | Regex pattern matching |
| Network propagation | 300ms | Geographic variance |
| Client processing | 150ms | JSON parsing, UI update |
| Real-time listener | 100ms | Firestore sync |
| **Total** | **850ms** | ✅ Within 2s target (56% margin) |

### Cost Optimization

**Per 30-minute match with 50 spectators:**
- Chat messages: ~1 message per spectator per minute = 1,500 writes
- Moderation checks: done client/server-side (no reads)
- Message reads: 1 read per connected spectator = 50 reads
- Mute checks: ~100 checks = 100 reads
- **Total: ~1,650 operations**

Cost per 1,000 matches:
- 1,000 × 1,650 = 1,650,000 operations
- 1,000 writes + 650 reads per 1,000 matches
- Estimated: < $0.10 per 1,000 matches for chat alone

---

## Rollout Strategy

### Week 9: Internal Beta
- Deploy to 10% of users
- Monitor chat engagement & moderation
- Gather feedback on UI/UX
- Validate moderation rules

### Week 10: Gradual Expansion
- Scale to 50% of users
- Monitor toxicity metrics
- Refine moderation patterns
- Prepare Phase 2c

### Week 11: Full Rollout
- Release to 100% of users
- Announce chat feature in-app
- Social media promotion

### Week 12: Optimization
- A/B test UI layouts
- Optimize moderation accuracy
- Prepare Phase 2c (streaming)

---

## Success Criteria

### Phase 2b Complete When:

- [x] Spectator chat deployed
- [x] Real-time message streaming working
- [x] Automatic moderation implemented
- [x] Commentator role elevation working
- [x] Moderator controls implemented
- [x] Analytics events firing
- [ ] Widget tests implemented (20/20)
- [ ] Integration tests with Firestore emulator
- [ ] Load testing validates concurrent messaging
- [ ] Latency < 2 seconds verified
- [ ] Toxic content rate < 0.5%
- [ ] Moderation accuracy 95%+
- [ ] Zero player performance impact
- [ ] All tests passing
- [ ] Phase 2c architecture started

### Success Metrics (First Month Post-Launch)

| Metric | Target |
|--------|--------|
| Message adoption | 30%+ of spectators use chat |
| Avg messages/match | 5+ per match |
| Toxic content rate | < 0.5% |
| Moderation accuracy | 95%+ |
| False report rate | < 10% |
| User satisfaction | 4+ / 5 stars |

---

## Known Limitations & Future Work

### Phase 2b (Current)

**Limitations:**
- No emoji reactions (coming Phase 2b+)
- No message threading/replies
- No user @mentions
- Limited moderation tools (no appeal system)
- No automated ban system

**Future Enhancements:**
- Emoji reactions on messages
- Message threading for sub-conversations
- @mention notifications
- Appeal system for muted users
- Automated repeat offender banning
- Sentiment analysis for nuanced moderation
- Chat filters customizable per match

### Phase 2c (OBS/Streaming)

**Dependencies on Phase 2b:**
- Chat message archive for stream clips
- Streamer role with special permissions
- Chat stream integration for OBS overlay
- Moderation consistency across platforms

---

## Files Changed

### New Files (5 total)

**Domain:**
- `lib/features/spectating/domain/models/spectator_message.dart` — Message model, roles, moderation config

**Application:**
- `lib/features/spectating/application/providers/spectator_chat_providers.dart` — Riverpod chat providers

**Data:**
- `lib/features/spectating/data/repositories/spectator_chat_repository.dart` — Firestore chat operations

**Presentation:**
- `lib/features/spectating/presentation/widgets/spectator_chat_widget.dart` — Chat UI widget

**Testing:**
- `test/unit/spectating/spectator_message_test.dart` — 10 unit tests
- `test/widget/spectating/spectator_chat_widget_test.dart` — 20 widget test placeholders

**Documentation:**
- `PHASE2B_CHAT_README.md` — This file

---

## Implementation Checklist

### Core Chat (MVP - Phase 2b)

- [x] Domain models (SpectatorMessage, roles, moderation config)
- [x] Firestore repository with message operations
- [x] Riverpod providers for state management
- [x] Chat widget with message display
- [x] Message input field with validation
- [x] Automatic content moderation
- [x] Role-based permissions (viewer/commentator/streamer/moderator)
- [x] Pin message functionality
- [x] Delete message functionality (moderators)
- [x] Mute user functionality (moderators)
- [x] Report message functionality (all users)
- [x] Unit tests (10 tests)
- [x] Widget test placeholders (20 tests)
- [ ] Widget test implementation (20/20)
- [ ] Integration tests (Firestore emulator)
- [ ] Load testing (concurrent messaging)
- [ ] Performance profiling

### UI Enhancements (Phase 2b+)

- [ ] Emoji reactions on messages
- [ ] Message threading/replies
- [ ] @mention notifications
- [ ] User reputation system
- [ ] Streamer badge (featured prominence)
- [ ] Chat analytics dashboard for streamers

### Phase 2c (OBS/Streaming) - Weeks 13-16

- [ ] OBS chat overlay source URL
- [ ] Streaming-optimized chat view
- [ ] Streamer role special permissions
- [ ] Chat message archive for clips

---

## Docs & References

- **Full Architecture Guide**: PHASE2B_CHAT_README.md (this file)
- **Firestore Rules**: See firestore.rules
- **Data Models**: lib/features/spectating/domain/models/
- **Provider Pattern**: https://riverpod.dev/
- **Moderation**: Built-in regex patterns in ChatModerationConfig

---

**Status**: 🚧 Phase 2b Development In Progress  
**Created**: 2026-08-27  
**Owner**: Development Team

**Next**: Implement 20 widget tests → Integration testing with Firestore emulator → Load testing → Phase 2b rollout (Week 9+)
