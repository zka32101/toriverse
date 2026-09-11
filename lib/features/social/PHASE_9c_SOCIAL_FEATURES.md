# Phase 9c: Social Features - Friend Invites & Replay Sharing
**Status**: 🚀 Ready for Implementation  
**Date**: 2026-09-04  
**Goal**: Implement social connectivity features enabling friend invites, replay sharing, and social discovery

---

## Phase 9c Scope

### Core Features

1. **Friend Management System**
   - Add friend by UID/username
   - Accept/decline friend requests
   - Remove/block friends
   - Friend list view with online status
   - Firestore: `users/{uid}/friends/{friendUid}`, `friendRequests/{requestId}`

2. **Replay Sharing**
   - Auto-generate replay clips from matches
   - Share replays via link/QR code
   - View replay in dedicated player
   - Replay analytics (views, shares, favorites)
   - Firestore: `replays/{replayId}`, `users/{uid}/sharedReplays/{replayId}`

3. **Friend Match Invites**
   - Create private match rooms
   - Invite specific friends to play
   - Match room management (accept, decline, start)
   - Firestore: `matchRooms/{roomId}`, `invitations/{invitationId}`

4. **Social Discovery**
   - View friend profiles (statistics, cosmetics collection)
   - Search users by username/UID
   - Recent players list (from recent matches)
   - Follow prominent players/streamers
   - Firestore: `users/{uid}/profiles/public`

5. **Analytics & Social Growth**
   - Track invite sends/accepts
   - Track replay views/shares
   - Track friend match completion rate
   - Social coefficient measurement
   - Firestore Analytics events

---

## Data Models & Firestore Schema

### Friend & Social Collections

```dart
// Friend Request
FriendRequest {
  id: string,                    // Auto-generated document ID
  fromUid: string,               // Requester
  toUid: string,                 // Recipient
  status: enum(pending, accepted, declined, blocked),
  createdAt: timestamp,
  respondedAt: timestamp,        // When recipient acted
}

// Friend Relationship
Friend {
  uid: string,                   // Friend's UID
  addedAt: timestamp,
  lastInteraction: timestamp,    // Last match/message together
  isFavorite: bool,              // Pinned friend
  notes: string,                 // User's personal notes
}

// Match Room (Private Friend Matches)
MatchRoom {
  id: string,                    // Room identifier
  creatorUid: string,            // Who created room
  players: [String],             // UIDs of invited players (0-2 others)
  status: enum(waiting, in_progress, finished),
  createdAt: timestamp,
  startedAt: timestamp,
  finishedAt: timestamp,
  matchId: string,               // Link to actual match once started
  settings: {
    isPrivate: bool,
    inviteExpiry: timestamp,
    maxPlayers: int,
  }
}

// Match Invitation
Invitation {
  id: string,
  roomId: string,
  fromUid: string,               // Who sent invite
  toUid: string,                 // Who received
  status: enum(pending, accepted, declined, expired),
  createdAt: timestamp,
  expiresAt: timestamp,          // 24h from creation
  respondedAt: timestamp,
}

// Replay Asset
Replay {
  id: string,                    // Replay identifier
  matchId: string,               // Source match
  creatorUid: string,            // Player who shared
  videoUrl: string,              // Cloud storage link
  thumbnail: string,             // Preview image
  title: string,                 // Player's title
  description: string,
  isPublic: bool,                // Visibility
  tags: [String],                // #highlights, #clutch, etc.
  duration: int,                 // Video length in seconds
  createdAt: timestamp,
  viewCount: int,
  shareCount: int,
  favoriteCount: int,
}

// Replay View
ReplayView {
  replayId: string,
  viewedByUid: string,
  viewedAt: timestamp,
  duration: int,                 // How long they watched
}

// User Public Profile (Accessible to Friends)
UserPublicProfile {
  uid: string,
  displayName: string,
  rankPoints: int,
  winRate: double,               // (wins / total_matches)
  totalMatches: int,
  favoriteCosmetics: [String],   // Top 3 cosmetics
  bio: string,                   // Self-description
  sharedReplays: int,            // Count of public replays
  followers: int,
  following: int,
  lastSeenAt: timestamp,
  socialRank: int,               // Leaderboard position (by followers/reach)
}
```

### Firestore Structure

```
firestore/
├── friendRequests/
│   └── {requestId}
│       ├── fromUid
│       ├── toUid
│       ├── status
│       └── timestamps
│
├── users/{uid}/
│   ├── friends/
│   │   └── {friendUid}
│   │       ├── addedAt
│   │       ├── lastInteraction
│   │       └── isFavorite
│   │
│   ├── matchRooms/
│   │   └── {roomId}
│   │       ├── status
│   │       ├── players
│   │       └── settings
│   │
│   ├── sentInvitations/
│   │   └── {invitationId}
│   │
│   ├── receivedInvitations/
│   │   └── {invitationId}
│   │
│   ├── sharedReplays/
│   │   └── {replayId}
│   │
│   └── profiles/
│       └── public
│           ├── displayName
│           ├── rankPoints
│           ├── winRate
│           └── bio
│
├── matchRooms/
│   └── {roomId}
│       ├── creatorUid
│       ├── players
│       ├── status
│       └── matchId
│
├── invitations/
│   └── {invitationId}
│       ├── roomId
│       ├── fromUid
│       ├── toUid
│       └── status
│
└── replays/
    └── {replayId}
        ├── matchId
        ├── creatorUid
        ├── videoUrl
        ├── title
        ├── viewCount
        └── favorites
```

---

## Implementation Layers

### 1. Domain Services (lib/features/social/domain/services)

**FriendService** (300 LOC)
- `sendFriendRequest(fromUid, toUid)` → creates pending request
- `acceptFriendRequest(requestId)` → moves to accepted, updates both friend lists
- `declineFriendRequest(requestId)` → marks declined
- `removeFriend(uid, friendUid)` → removes from friend list
- `blockUser(uid, blockedUid)` → prevents future interactions
- `getFriendsList(uid)` → returns active friends
- `getPendingRequests(uid)` → returns incoming requests
- Error handling with silent degradation

**MatchRoomService** (350 LOC)
- `createMatchRoom(creatorUid, settings)` → private room
- `inviteFriendToRoom(roomId, toUid)` → sends invite
- `acceptInvitation(invitationId)` → joins room
- `startMatchFromRoom(roomId)` → creates actual match
- `getRoomStatus(roomId)` → current state
- Invite expiry handling (24h TTL)

**ReplayService** (400 LOC)
- `saveReplayMetadata(matchId, creatorUid, videoUrl)` → stores replay
- `shareReplay(replayId, isPublic)` → toggles visibility
- `getPublicReplays()` → discovery list
- `viewReplay(replayId, viewerUid)` → increments views + logs
- `favoriteReplay(replayId, userUid)` → bookmark toggle
- `deleteReplay(replayId, ownerUid)` → cleanup
- Tag-based search support

**SocialDiscoveryService** (250 LOC)
- `searchUsers(query)` → by username/UID
- `getUserPublicProfile(uid)` → social profile
- `getRecentPlayers(uid, limit=10)` → from recent matches
- `getLeaderboard(limit=100, sortBy)` → by rank/followers/reach
- `followUser(fromUid, toUid)` → one-way social connection
- `getFollowerCount(uid)` → metric

---

### 2. Riverpod Providers (lib/features/social/application/providers)

**FriendProviders** (250 LOC)
```dart
// Read-only
final friendsListProvider = StreamProvider<List<Friend>>
final pendingRequestsProvider = StreamProvider<List<FriendRequest>>
final friendStatusProvider = FutureProvider.family<FriendStatus, String>

// State management
final friendNotifierProvider = StateNotifierProvider<FriendNotifier, AsyncValue>
```

**MatchRoomProviders** (200 LOC)
```dart
final activeRoomsProvider = StreamProvider<List<MatchRoom>>
final roomDetailsProvider = FutureProvider.family<MatchRoom, String>
final myInvitationsProvider = StreamProvider<List<Invitation>>
final matchRoomNotifierProvider = StateNotifierProvider<MatchRoomNotifier, AsyncValue>
```

**ReplayProviders** (200 LOC)
```dart
final myReplaysProvider = StreamProvider<List<Replay>>
final publicReplaysProvider = StreamProvider<List<Replay>>
final replayDetailsProvider = FutureProvider.family<Replay, String>
final replayStatsProvider = FutureProvider.family<ReplayStats, String>
final replayNotifierProvider = StateNotifierProvider<ReplayNotifier, AsyncValue>
```

**SocialDiscoveryProviders** (150 LOC)
```dart
final userSearchProvider = FutureProvider.family<List<UserPublicProfile>, String>
final publicProfileProvider = FutureProvider.family<UserPublicProfile, String>
final recentPlayersProvider = FutureProvider<List<UserPublicProfile>>
final leaderboardProvider = FutureProvider<List<UserPublicProfile>>
```

---

### 3. UI Layer (lib/features/social/presentation)

**Screens** (1,600 LOC total)

1. **FriendsScreen** (400 LOC)
   - Friends list with online status
   - Pending requests section (expandable)
   - Add friend button → search dialog
   - Friend actions menu (message, invite to room, remove, block)
   - Empty state: "No friends yet, add someone!"
   - Analytics: `social_friends_screen_opened`

2. **FriendProfileScreen** (300 LOC)
   - Friend's public profile card
   - Win rate, rank, total matches
   - Favorite cosmetics showcase (3 items)
   - Recent shared replays (grid)
   - Add friend / Message / Invite to match buttons
   - Shared replays feed below
   - Analytics: `social_friend_profile_viewed`

3. **MatchRoomScreen** (350 LOC)
   - Room details: creator, invited players, settings
   - Invite more friends button (up to 2 others)
   - Countdown to auto-start (if all 3 joined)
   - Start now button (creator only)
   - Status: "Waiting for {names}" → "All joined, starting!"
   - Cancel room button
   - Analytics: `social_matchroom_viewed`, `matchroom_started`

4. **ReplaysScreen** (350 LOC)
   - My Replays tab: list of user's shared replays
   - Discover tab: trending/public replays
   - Search/filter by tag (#clutch, #highlights, etc.)
   - Replay card: thumbnail, title, view count, share button
   - Empty state: "No replays yet"
   - Analytics: `social_replays_screen_opened`, `replay_searched`

5. **ReplayPlayerScreen** (200 LOC)
   - Video player (full screen)
   - Replay metadata: creator, match date, result
   - Creator's profile link
   - Share/favorite buttons
   - View count display
   - Comments section (phase 9d+)
   - Analytics: `replay_viewed`, `replay_shared`

**Widgets** (800 LOC total)

1. **FriendListTile** (80 LOC)
   - Friend avatar/name
   - Online status indicator
   - Last match date
   - Tap to profile, long-press for actions menu

2. **FriendRequestCard** (100 LOC)
   - Requester info card
   - Accept/Decline buttons
   - User's display name + rank
   - Expandable details

3. **MatchRoomCard** (120 LOC)
   - Room creator name
   - Player slots (filled/empty circles)
   - Room status badge (waiting/in progress)
   - Join button (if invited)
   - Details button → modal

4. **ReplayCard** (150 LOC)
   - Thumbnail image
   - Title + creator name
   - View count + favorite count + share count
   - Tap to player, long-press for share menu
   - Tags display (hashtags)

5. **UserPublicProfileCard** (200 LOC)
   - User avatar, name, rank
   - Win rate chart
   - Favorite cosmetics preview (3 icons)
   - "Add Friend" / "Message" / "View Replays" buttons
   - Bio text (3 lines max)

6. **FollowButton** (80 LOC)
   - Toggle follow state
   - Follower count badge
   - Loading state during async operation

7. **ShareReplayModal** (70 LOC)
   - Copy share link button
   - Generate QR code button
   - Direct share options (if available)
   - Copy to clipboard feedback

---

### 4. Routing Integration (lib/config/router.dart)

New routes to add:
```dart
GoRoute(path: '/social/friends', builder: ..., FriendsScreen()),
GoRoute(path: '/social/friend/:uid', builder: ..., FriendProfileScreen()),
GoRoute(path: '/social/room/:roomId', builder: ..., MatchRoomScreen()),
GoRoute(path: '/social/replays', builder: ..., ReplaysScreen()),
GoRoute(path: '/social/replay/:replayId', builder: ..., ReplayPlayerScreen()),
GoRoute(path: '/social/profile/:uid', builder: ..., UserPublicProfileScreen()),
GoRoute(path: '/social/leaderboard', builder: ..., LeaderboardScreen()),
```

---

### 5. Analytics Integration

**New Events** (12 events)
```dart
'social_friends_screen_opened'          // params: none
'social_friend_added'                   // params: friend_uid
'social_friend_removed'                 // params: friend_uid
'social_friend_request_sent'            // params: to_uid
'social_friend_request_accepted'        // params: from_uid
'social_matchroom_created'              // params: room_id, player_count
'social_matchroom_started'              // params: room_id
'social_friend_invited_to_room'         // params: friend_uid, room_id
'social_replay_shared'                  // params: replay_id, match_id
'replay_viewed'                         // params: replay_id, creator_uid, duration_watched
'social_user_searched'                  // params: query_length, result_count
'social_profile_viewed'                 // params: profile_uid, is_friend
```

---

## Testing Strategy (300+ tests)

### Unit Tests (150 tests)

**FriendService** (40 tests)
- Friend request creation/acceptance/decline
- Friend list management
- Block/unblock logic
- Duplicate request prevention
- Error cases (self-request, invalid UID)

**MatchRoomService** (40 tests)
- Room creation with valid settings
- Invite expiry (24h TTL)
- Player limit enforcement (3 max)
- Room state transitions
- Cleanup on expire/cancel

**ReplayService** (40 tests)
- Metadata storage
- View count increment
- Favorite toggle idempotence
- Tag parsing and search
- Public/private toggle

**SocialDiscoveryService** (30 tests)
- User search by name/UID
- Leaderboard sorting
- Public profile aggregation
- Recent players filtering
- Follower count accuracy

### Widget Tests (80 tests)

**FriendsScreen** (12 tests)
- Render friends list
- Expand pending requests
- Add friend button interaction
- Empty state display
- Loading state

**MatchRoomScreen** (12 tests)
- Display room details
- Show player slots
- Invite button functional
- Start button visibility (creator only)
- Join flow

**ReplaysScreen** (12 tests)
- Tab switching (My Replays / Discover)
- Grid layout render
- Card interactions
- Search functionality
- Empty state

**ReplayPlayerScreen** (12 tests)
- Video player setup
- Metadata display
- Share button interaction
- Like/favorite toggle
- Profile link navigation

**Shared Widgets** (20 tests)
- FriendListTile rendering
- MatchRoomCard states
- ReplayCard interactions
- UserProfileCard data binding
- FollowButton toggle

### Integration Tests (70 tests)

**Social Flow Tests** (20 tests)
- Send friend request → accept → verify friend list
- Create match room → invite friend → start match
- Share replay → view as friend → verify stats
- Search user → view profile → add friend

**Data Persistence Tests** (20 tests)
- Friend list survives app restart
- Pending requests persist
- Replay metadata cached locally
- Room invitations stored correctly

**Error Scenarios** (15 tests)
- Network timeout during invite
- Expired invitation handling
- Deleted friend recovery
- Invalid replay data
- Firestore rule violations

**Real-time Updates** (15 tests)
- Friend online status change
- New invitation arrival
- Room status updates
- Replay view count increment
- Follower count changes

---

## Success Criteria

✅ **Feature Completion**:
- Friend management fully functional (request → accept → friend)
- Replay sharing with public/private toggle
- Match room invites with 24h expiry
- User search and public profiles
- 300+ tests passing

✅ **User Experience**:
- Add friend flow < 3 taps
- Share replay accessible from results screen
- Friend list loads in < 2 seconds
- No silent failures (all errors shown to user)

✅ **Metrics**:
- Friend invitation acceptance rate: 40%+
- Replay share rate: 25%+ of matches
- Match room completion rate: 60%+
- Average friends per user: 3+

✅ **Technical**:
- All Firestore queries indexed
- No N+1 queries on friend list load
- Replay metadata cached
- Proper cleanup on room expiry
- Analytics events firing correctly

---

## Development Timeline

| Task | LOC | Duration |
|------|-----|----------|
| Firestore schema + migrations | 150 | 2h |
| Domain Services (Friend/Room/Replay/Discovery) | 1,300 | 12h |
| Riverpod Providers | 800 | 6h |
| UI Screens (5 screens) | 1,600 | 14h |
| UI Widgets (7 widgets) | 800 | 8h |
| Router Integration | 100 | 1h |
| Analytics Integration | 200 | 2h |
| Testing (300+ tests) | 1,500 | 16h |
| Documentation | 200 | 2h |
| **Total** | **8,050** | **63h** |

---

## Deliverables Summary

### Code Files (30+ new files)

**Domain Services** (4 files, 1,300 LOC)
- friend_service.dart
- match_room_service.dart
- replay_service.dart
- social_discovery_service.dart

**Riverpod Providers** (4 files, 800 LOC)
- friend_providers.dart
- match_room_providers.dart
- replay_providers.dart
- social_discovery_providers.dart

**Presentation Screens** (5 files, 1,600 LOC)
- friends_screen.dart
- friend_profile_screen.dart
- match_room_screen.dart
- replays_screen.dart
- replay_player_screen.dart

**Presentation Widgets** (7 files, 800 LOC)
- friend_list_tile.dart
- friend_request_card.dart
- match_room_card.dart
- replay_card.dart
- user_profile_card.dart
- follow_button.dart
- share_replay_modal.dart

**Tests** (8 files, 1,500 LOC)
- friend_service_test.dart (40 tests)
- match_room_service_test.dart (40 tests)
- replay_service_test.dart (40 tests)
- social_discovery_service_test.dart (30 tests)
- friends_screen_test.dart (12 tests)
- match_room_screen_test.dart (12 tests)
- replays_screen_test.dart (12 tests)
- replay_player_screen_test.dart (12 tests)

**Documentation**
- This file (PHASE_9c_SOCIAL_FEATURES.md)

---

## Next Phase (Phase 9d)

**Phase 9d: Seasonal Events**
- Campaign/event system with time-limited cosmetics
- Event-specific match modes (bonus point multipliers)
- Limited edition cosmetic drops during events
- Event leaderboards and rewards
- Estimated: 40h implementation

---

**Status**: ✅ Ready for implementation  
**Blocked By**: Phase 9b CI resolution (doesn't affect Phase 9c)  
**Can Start**: Immediately (independent of previous phases)  
**Estimated Completion**: 63 hours of focused development
