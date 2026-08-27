# Firebase Data Layer Implementation - Toriverse

**Date**: 2026-08-27  
**Status**: MVP Phase 1 - Complete Skeleton with 3-Color Othello Logic

---

## Overview

This document describes the complete Firebase data layer implementation for Toriverse, including:
- **Firestore Data Models** (6 models with Freezed + JSON serialization)
- **Firestore Repositories** (4 repository classes for data access)
- **Firestore Security Rules** (Collection-level access control)
- **Cloud Functions** (6 core + 1 scheduled function)

All code follows the project's non-simultaneous reveal, simultaneous submission design with weak bonus and rescue card mechanics.

---

## Data Models (lib/features/match/data/models/)

### 1. UserModel (user_model.dart)

**Firestore Collection**: `users`  
**Document Key**: `uid` (Firebase Auth UID)

```dart
UserModel {
  uid: String,                          // Firebase Auth UID (doc ID)
  displayName: String,                  // User's display name
  rankPoints: int = 1000,               // Competitive ranking points
  completedMatchStreak: int = 0,        // Consecutive finished matches
  freeMatchUsedToday: int = 0,          // Daily free ranked match counter
  subscriptionStatus: String = "trial", // 'trial', 'active', 'cancelled'
  ownedCosmetics: List<String> = [],    // Purchased cosmetic IDs
  createdAt: DateTime,                  // Account creation timestamp
  lastPlayedAt: DateTime?,              // Last login/play timestamp
  lastDailyResetAt: DateTime?,          // Last midnight UTC reset
}
```

**Key Points**:
- Users can only read/write their own document (Firestore rule enforced)
- Subscription status tracked via RevenueCat webhook updates
- Free match quota reset daily via scheduled Cloud Function at 00:00 UTC

---

### 2. MatchModel (match_model.dart)

**Firestore Collection**: `matches`  
**Document Key**: Auto-generated ID

```dart
MatchModel {
  id: String,                        // Auto-generated Firestore doc ID
  players: List<String>,             // Exactly 3 items (UIDs or "AI_*")
  boardState: List<int>,             // 64-element 8x8 board
                                     // 0=black, 1=white, 2=red, -1=empty
  roundIndex: int = 0,               // Current round (0-indexed)
  status: String = "waiting",        // 'waiting', 'playing', 'finished'
  currentPhase: String = "",         // 'submitPhase', 'revealPhase'
  createdAt: DateTime,               // Match creation timestamp
  startedAt: DateTime?,              // When first round started
  finishedAt: DateTime?,             // When last round completed
  readyPlayers: List<String> = [],   // Players who have joined
  finalScores: List<int> = [],       // [black_count, white_count, red_count]
}
```

**Key Points**:
- 3-color Othello: black (0), white (1), red (2), empty (-1)
- Board state is 64-element flattened 8x8 array (row-major)
- Players can be real UIDs or "AI_*" for AI substitutes
- Status transitions: waiting → playing → finished
- Phases: submitPhase (players submitting moves) → revealPhase (processed)

---

### 3. RoundResultModel (round_result_model.dart)

**Firestore Collection**: `matches/{matchId}/roundResults` (subcollection)  
**Document Key**: `round_{roundIndex}`

```dart
SubmittedMove {
  playerId: String,         // UID or "AI_*"
  position: int,            // 0-63 (8x8 flattened)
  submittedAt: DateTime,
}

CollisionResolution {
  position: int,           // Position where collision occurred
  winnerPlayerId: String,  // Player whose move succeeded
  losers: List<String>,    // Players who lost the collision
  rescueCardGranted: bool, // true = losers get rescue card
}

ReplayEvent {
  type: String,            // 'move', 'flip', 'bonus', 'rescueCard'
  data: Map<String, dynamic>, // Event-specific data
  delayMs: int,            // Animation delay from start
}

RoundResultModel {
  id: String,                              // matchId_roundIndex
  matchId: String,
  roundIndex: int,
  submittedMoves: List<SubmittedMove>,     // All 3 players' submissions
  collisionResolved: List<CollisionResolution>, // Empty if no collisions
  processOrder: List<String>,              // [player1, player2, player3] random
  replayEvents: List<ReplayEvent>,         // Animation sequence
  createdAt: DateTime,
  processedAt: DateTime?,                  // When Cloud Function finished
  bonusTriggered: String,                  // playerId or ""
  rescueCardsGranted: List<String>,        // playerIds who got cards
}
```

**Key Points**:
- Written EXCLUSIVELY by Cloud Functions (client read-only)
- Collision resolution uses random selection for tied positions
- Process order is randomized each round for presentation
- Replay events drive UI animation sequencing
- Stored as subcollection under match for better organization

---

### 4. RescueCardModel (rescue_card_model.dart)

**Firestore Collection**: `matches/{matchId}/rescueCards` (subcollection)  
**Document Key**: `{playerId}_{roundIndex}`

```dart
RescueCardModel {
  id: String,                    // matchId_playerId
  matchId: String,
  playerId: String,              // UID or "AI_*"
  consecutiveAttackedCount: int, // Attack streak counter
  cardAvailable: bool,           // true = 2x move available next turn
  cardActivatedRound: int,       // Round when card was used (0 if unused)
  createdAt: DateTime,
  updatedAt: DateTime?,
}
```

**救済カード (Rescue Card) Rules**:
- **Activation**: Player attacked (surrounded) 2 consecutive rounds by SAME opponent
- **Effect**: Next turn, player executes 2 moves instead of 1
- **Granting**: Automatic when collision loss occurs
- **Per-Match**: Max 1 active card per player at any time
- **Independent from Weak Bonus**: Orthogonal mechanics

**Key Points**:
- Tracks attack streak to detect 2-round pattern
- Awarded automatically to losers in collision resolution
- Can be used across multiple matches (per-match state)

---

### 5. WeakBonusModel (weak_bonus_model.dart)

**Firestore Collection**: `matches/{matchId}/weakBonuses` (subcollection)  
**Document Key**: `state` (singleton per match)

```dart
WeakBonusModel {
  id: String,                    // matchId
  matchId: String,
  activationCounts: List<int>,   // Per player: [black, white, red]
  lastActivatedRounds: List<int>, // Last activation round per player
  createdAt: DateTime,
  updatedAt: DateTime?,
}
```

**弱者ボーナス (Weak Bonus) Rules**:
- **Conditions**: 
  - Remaining hands ≤ 11 (endgame exclusion)
  - Stone count in bottom 20% of players
  - Max 2 activations per match
- **Effect**: Player receives +1 free move (executes 2 instead of 1)
- **Tracking**: Per-player activation counter and last-triggered round
- **Independent from Rescue Card**: Orthogonal mechanics

**Key Points**:
- Singleton document per match (easier state management)
- Activation counts prevent double-trigger in same round
- Endgame exemption (round > 11) prevents abuse
- Checked by Cloud Function before each round reveal

---

### 6. CosmeticItemModel (cosmetic_item_model.dart)

**Firestore Collection**: `cosmetics`  
**Document Key**: Auto-generated ID

```dart
CosmeticItemModel {
  id: String,           // Cosmetic item ID
  type: String,         // 'board' or 'stone'
  name: String,         // Display name (e.g., "Cherry Blossom")
  priceJpy: int,        // Price in JPY (120-300)
  description: String,  // UI description
  imageUrl: String,     // Preview image URL
  category: String,     // 'seasonal', 'premium', 'limited'
  available: bool,      // Soft delete flag
  createdAt: DateTime,
}
```

**Key Points**:
- Global catalog (not per-user)
- Referenced via UserModel.ownedCosmetics array
- Prices typically ¥120-300 for monetization

---

## Repositories (lib/features/match/data/repositories/)

### 1. UserRepository (user_repository.dart)

**Methods**:
- `createUser(uid, createdAt?)` → Future<void>
- `getUserByUid(uid)` → Future<UserModel?>
- `addRankPoints(uid, points)` → Future<void>
- `incrementStreak(uid)` → Future<void>
- `resetStreak(uid)` → Future<void>
- `useFreeMatch(uid)` → Future<void>
- `resetDailyFreeMatch(uid)` → Future<void>
- `updateSubscriptionStatus(uid, status)` → Future<void>
- `addCosmetic(uid, cosmeticId)` → Future<void>
- `logout(uid)` → Future<void> (marker method)

**Usage**:
```dart
final userRepo = UserRepository();
await userRepo.createUser("uid_12345");
final user = await userRepo.getUserByUid("uid_12345");
await userRepo.incrementStreak("uid_12345");
```

---

### 2. MatchRepository (match_repository.dart)

**Methods**:
- `createMatch(match)` → Future<String> (returns matchId)
- `getMatchById(matchId)` → Future<MatchModel?>
- `updateMatchStatus(matchId, status)` → Future<void>
- `updateBoardState(matchId, boardState, roundIndex)` → Future<void>
- `addReadyPlayer(matchId, playerId)` → Future<void>
- `markMatchStarted(matchId)` → Future<void>
- `markMatchFinished(matchId, finalScores)` → Future<void>
- `getMatchesByPlayerId(playerId, limit?)` → Future<List<MatchModel>>
- `streamMatch(matchId)` → Stream<MatchModel?>

**Usage**:
```dart
final matchRepo = MatchRepository();
final matchId = await matchRepo.createMatch(matchModel);
final match = await matchRepo.getMatchById(matchId);
matchRepo.streamMatch(matchId).listen((match) {
  // Real-time updates
});
```

---

### 3. RoundResultRepository (round_result_repository.dart)

**Methods**:
- `getRoundResult(matchId, roundIndex)` → Future<RoundResultModel?>
- `watchRoundResult(matchId, roundIndex)` → Stream<RoundResultModel?>
- `getMatchRoundResults(matchId)` → Future<List<RoundResultModel>>
- `isRoundProcessed(matchId, roundIndex)` → Future<bool>
- `pollRoundResult(matchId, roundIndex, timeoutSeconds?, pollIntervalMs?)` → Future<RoundResultModel>
- `watchMatchRoundResults(matchId)` → Stream<List<RoundResultModel>>

**Usage**:
```dart
final roundRepo = RoundResultRepository();
final result = await roundRepo.getRoundResult(matchId, 0);
roundRepo.watchRoundResult(matchId, 0).listen((result) {
  // Animate reveal when result arrives
});
```

---

### 4. SubscriptionRepository (subscription_repository.dart)

**Methods**:
- `initialize(revenueCatApiKey)` → Future<void>
- `hasActiveRankPass(userId)` → Future<bool>
- `getActiveEntitlements(userId)` → Future<List<String>>
- `getRankPassInfo()` → Future<EntitlementInfo?>
- `purchaseRankPass(productId)` → Future<bool>
- `getAvailablePackages()` → Future<List<Package>>
- `restorePurchases()` → Future<bool>
- `watchActiveEntitlements()` → Stream<List<String>>

**Usage**:
```dart
final subRepo = SubscriptionRepository();
await subRepo.initialize(revenueCatApiKey);
final hasPass = await subRepo.hasActiveRankPass(uid);
final success = await subRepo.purchaseRankPass('rank_pass_monthly');
```

---

## Firestore Security Rules (firestore.rules)

**Collection Access Model**:

| Collection | Read | Write | Notes |
|-----------|------|-------|-------|
| users/{uid} | User (owner only) | User (owner only) | Personal data |
| matches/{matchId} | Players in match | Cloud Functions only | Game state |
| matches/{matchId}/submissions | Match players | Match players | Round move submissions |
| matches/{matchId}/roundResults | Match players | Cloud Functions only | Processed round results |
| rescueCards/{cardId} | Owning player | Cloud Functions only | Card state |
| weakBonuses/{bonusId} | Match players | Cloud Functions only | Bonus state |
| cosmetics/{itemId} | Authenticated users | Admin SDK only | Global catalog |
| clips/{clipId} | Match players | Cloud Functions only | Generated clips |

**Key Security Principles**:
1. Users cannot modify game state (read-only for most collections)
2. Cloud Functions exclusively handle game logic (atomic writes)
3. Collision detection, bonus logic, board updates all server-side
4. No client-side cheating possible (all validation server-side)

---

## Cloud Functions (functions/index.js)

### Architecture

All game logic runs in **Cloud Functions to prevent client-side manipulation**:
- Move validation (legality check)
- Collision resolution (random winner selection)
- Weak bonus activation
- Board state updates
- Atomic writes to Firestore

### Core Functions

#### 1. submitMove

**Type**: HTTPS Callable  
**Caller**: Flutter client  
**Input**: `{ matchId, roundIndex, playerId, position }`  
**Output**: `{ success: true }`

**Logic**:
- Verify user authentication
- Validate position (0-63)
- Write submission to `matches/{matchId}/submissions/{roundIndex}_{playerId}`
- Server processes when all 3 players submit or timeout

```javascript
exports.submitMove = functions.https.onCall(async (data, context) => {
  // 1. Check auth
  // 2. Validate bounds
  // 3. Write to submissions subcollection
  // 4. Server polls for completion
});
```

---

#### 2. validateMove

**Type**: HTTPS Callable  
**Caller**: Cloud Functions (server-to-server)  
**Input**: `{ boardState, playerColor, position }`  
**Output**: `{ isValid: boolean, flipped: [positions] }`

**Logic**:
- Check if position is empty
- Test all 8 directions (N, NE, E, SE, S, SW, W, NW)
- Count flippable opponent stones in each direction
- Return list of flipped positions

**3-Color Othello Move Validation**:
```
Colors:   0=BLACK, 1=WHITE, 2=RED
Directions: 8 compass directions
Flip Rule: Opponent stones between placed stone and own stone flip
```

---

#### 3. resolveCollision

**Type**: HTTPS Callable  
**Caller**: Cloud Functions (from processRound)  
**Input**: `{ matchId, position, playerIds, roundIndex }`  
**Output**: `{ winner, losers, rescueCardGranted }`

**Logic**:
- When 2+ players submit same position
- Random winner selection: `winners = playerIds[random(0, len)]`
- Losers receive rescue card
- Atomic batch write

---

#### 4. processBonusLogic

**Type**: HTTPS Callable  
**Caller**: Cloud Functions (from processRound)  
**Input**: `{ matchId, roundIndex, playerMoves, boardState }`  
**Output**: `{ bonusActivated: [playerIds], remainingActivations }`

**Logic**:
- For each player:
  1. Check if in endgame (roundIndex ≤ 11)
  2. Check remaining activations > 0
  3. Check not already activated this round
  4. Compare stone count to bottom 20%
- Award bonus to eligible players
- Decrement remaining activations

---

#### 5. processRound (Pub/Sub)

**Type**: Pub/Sub Topic `process_round`  
**Trigger**: Manual or scheduled  
**Input**: `{ matchId, roundIndex }`

**Logic**:
1. Get all 3 submissions for this round
2. Group submissions by position (detect collisions)
3. Randomize process order
4. For each position:
   - If collision: resolve randomly, grant rescue card to losers
   - Validate winning move
   - Apply move to board
   - Generate flip list
5. Process bonus logic
6. Generate replay animation events
7. Write RoundResult document
8. Update Match boardState + roundIndex
9. Cleanup submissions

**Replay Events** (for UI animation):
```javascript
{
  step: 0,
  type: "move",        // place stone
  playerId: "uid_...",
  position: 15,        // board position
  delayMs: 300,        // time from round start
}
{
  step: 1,
  type: "flip",
  position: 7,
  delayMs: 400,
}
```

---

#### 6. generateClip

**Type**: HTTPS Callable  
**Caller**: Flutter client (after match finish)  
**Input**: `{ matchId }`  
**Output**: `{ clipUrl, success }`

**Logic**:
- Verify user is match player
- Get all round results for match
- Call video generation service (placeholder)
- Store clip metadata
- Return shareable URL

**Placeholder**: Currently returns stub URL  
**Future Integration**: ffmpeg, Mux, or similar video service

---

#### 7. finishMatch

**Type**: HTTPS Callable  
**Caller**: Flutter client (or scheduled check)  
**Input**: `{ matchId }`  
**Output**: `{ success }`

**Logic**:
- Mark match status = "finished"
- Calculate final scores (stone counts)
- Increment completedMatchStreak for all players
- Update finalScores in match document

---

#### 8. resetDailyFreeMatches (Scheduled)

**Type**: Cloud Scheduler (Pub/Sub)  
**Trigger**: Daily at 00:00 UTC  
**Logic**:
- Find all users with `freeMatchUsedToday > 0`
- Set `freeMatchUsedToday = 0`
- Update `lastDailyResetAt` timestamp

---

## Helper Functions (in functions/index.js)

```javascript
// Board position conversion
posToRowCol(pos)      // 15 -> [1, 7]
rowColToPos(row, col) // [1, 7] -> 15

// Direction-based flipping
getAdjacentInDirection(pos, direction)
getFlippedInDirection(boardState, playerColor, pos, direction)

// Board manipulation
applyMove(boardState, playerColor, position, flipped)
countStones(boardState)

// Bonus logic
shouldActivateWeakBonus(playerStoneCount, allCounts, roundIndex, bonusState)

// Animation
generateReplayEvents(processOrder, moveResults)
```

---

## Data Flow Example: Complete Round

### 1. Player Submits Move (Client)

```
Client → submitMove() HTTPS Callable
  matchId: "match_abc123"
  roundIndex: 3
  playerId: "uid_player1"
  position: 28
→ Firestore: matches/match_abc123/submissions/3_uid_player1 = { position: 28, submittedAt: now }
```

### 2. Server Polls & Processes (Cloud Function: processRound)

```
Firestore Listener detects 3 submissions received
→ pubsub.topic("process_round").publish({ matchId, roundIndex })

processRound Trigger:
  1. Get all 3 submissions
  2. Group by position { 28: [uid1], 42: [uid2, uid3] }
  3. Randomize process order [uid3, uid1, uid2]
  4. For position 28 (uid1 only):
     - validateMove(boardState, color=0, pos=28) → { valid: true, flipped: [7,8,9] }
     - applyMove() → new boardState
  5. For position 42 (uid2, uid3 collision):
     - resolveCollision() → winner=uid2, loser=uid3
     - uid3 gets rescue card
     - validateMove(boardState, color=1, pos=42) → { valid: true, flipped: [11,12] }
     - applyMove() → new boardState
  6. processBonusLogic() → uid1 is 20% behind, activates weak bonus
  7. generateReplayEvents() → [
       { step: 0, type: "move", playerId: uid3, position: 42, delayMs: 300 },
       { step: 1, type: "flip", position: 11, delayMs: 400 },
       { step: 2, type: "flip", position: 12, delayMs: 500 },
       { step: 3, type: "move", playerId: uid1, position: 28, delayMs: 600 },
       { step: 4, type: "flip", position: 7, delayMs: 700 },
       ...
     ]
  8. Write RoundResult document
  9. Update Match boardState + roundIndex
  10. Delete submissions
```

### 3. Client Receives Update (Listener)

```
Firestore Listener on roundResult/round_3:
  → RoundResultModel received
  → UI calls animateReplay(replayEvents)
  → Loop through events, animate with delayMs
  → Update board UI after each move
  → Show bonus/rescue card triggers
```

### 4. Match Completion

```
After last round:
  → finishMatch() called
  → status = "finished"
  → finalScores = [23, 21, 20]  // stone counts
  → generateClip() auto-creates shareable video
  → User can share clip to SNS
```

---

## Integration with State Management (Riverpod)

### Providers (to be implemented in application/)

```dart
// User provider
final userProvider = StreamProvider<UserModel?> ((ref) async* {
  final repo = ref.watch(userRepositoryProvider);
  final uid = ref.watch(firebaseAuthProvider).currentUser!.uid;
  yield* repo.watchUser(uid);
});

// Match provider
final matchProvider = StreamProvider<MatchModel?> ((ref, matchId) async* {
  final repo = ref.watch(matchRepositoryProvider);
  yield* repo.watchMatch(matchId);
});

// Round result provider
final roundResultProvider = StreamProvider<RoundResultModel?> (
  (ref, matchId, roundIndex) async* {
    final repo = ref.watch(roundResultRepositoryProvider);
    yield* repo.watchRoundResult(matchId, roundIndex);
  }
);
```

---

## Testing Strategy

### Unit Tests (test/unit/)

- **Board Logic**: Flip detection in all 8 directions
- **Bonus Logic**: Activation conditions (endgame, threshold, max activations)
- **Collision**: Random selection fairness
- **Move Validation**: Legal move detection

### Integration Tests

- **Full Round**: submitMove → processRound → RoundResult
- **Collision Handling**: Same-position submissions
- **Bonus Activation**: Weak bonus + rescue cards

### Cloud Functions Testing

- Local emulator: `firebase emulators:start`
- Test with Firestore rules enforcer
- Validate atomic writes

---

## Deployment Checklist

### Firestore

- [ ] Deploy rules: `firebase deploy --only firestore:rules`
- [ ] Create indexes for queries (auto-created on first run)
- [ ] Set retention policies for analytics

### Cloud Functions

- [ ] Deploy: `firebase deploy --only functions`
- [ ] Set memory allocation: 256MB (default fine for logic)
- [ ] Set timeout: 60s (adequate for round processing)
- [ ] Configure Pub/Sub topic: `process_round`

### Security

- [ ] Enable Firestore rules (deny by default)
- [ ] Restrict Cloud Functions service account
- [ ] Enable audit logging
- [ ] Set up rate limiting (via Cloud Armor, if needed)

---

## Future Enhancements

### Phase 2

1. **Clip Generation**: Integrate ffmpeg or Mux for video rendering
2. **Live Observation**: Add real-time spectator mode
3. **Analytics**: Detailed KPI tracking via Firebase Analytics
4. **AI Difficulty**: Adjust minimax depth based on player rating

### Phase 3

1. **Leaderboards**: Global ranking with caching
2. **Tournament Mode**: Bracket-style competitions
3. **Social Features**: Friend matches, chat

---

## References

- **Firestore Data Model**: CLAUDE.md Section 6
- **3-Color Othello Rules**: CLAUDE.md Section 1-4
- **Bonus Mechanics**: CLAUDE.md Section 5
- **Project Timeline**: CLAUDE.md Section 1

---

**Maintained by**: Claude / zka32101  
**Last Updated**: 2026-08-27
