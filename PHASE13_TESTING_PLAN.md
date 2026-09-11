# Phase 13 Testing Plan
## Animation & Firebase Integration

**Target**: Comprehensive end-to-end testing of animations and Firebase synchronization  
**Status**: Test infrastructure setup  
**Completion Estimate**: 2026-09-15  

---

## 1. Animation Widget Tests

### 1.1 WeakBonusAnimationWidget
- [ ] Widget renders with player name
- [ ] Scale animation plays on init
- [ ] Fade animation plays on init
- [ ] Auto-dismissal timer triggers onAnimationComplete
- [ ] Player index determines stone color correctly
- [ ] Icon animation (placeholder) scales up/down
- [ ] Text displays correctly in Japanese

**Test File**: `test/features/match/presentation/widgets/weak_bonus_animation_widget_test.dart`

---

### 1.2 RescueCardAnimationWidget
- [ ] Widget renders with player name
- [ ] Reason text varies based on `reason` parameter
  - `'consecutive_attacks'`: "同一相手から連続攻撃を受けました"
  - `'collision'`: "同マス被りで外れました"
- [ ] Red accent color used for styling
- [ ] Stone color chip displays correctly
- [ ] Auto-dismissal timer triggers callback
- [ ] Card gift icon animates on scale transition
- [ ] Duration parameter respected

**Test File**: `test/features/match/presentation/widgets/rescue_card_animation_widget_test.dart`

---

### 1.3 CollisionResolutionAnimationWidget
- [ ] Winner section displays correctly
- [ ] Loser section displays correctly (if multiple players)
- [ ] Winner indicator (checkmark) shows
- [ ] Board position (row, col) displays in footer
- [ ] Player chips colored by index
- [ ] Winner name/color highlighted in green
- [ ] Loser names highlighted with red
- [ ] Animation sequence matches expected duration
- [ ] onAnimationComplete callback fires

**Test File**: `test/features/match/presentation/widgets/collision_resolution_animation_widget_test.dart`

---

### 1.4 LotteryAnimationWidget
- [ ] Process order cards render in sequence
- [ ] Card 1/2/3 appear staggered (animation timing)
- [ ] Player names and indices match
- [ ] Stone colors correct per player
- [ ] Order badges (1, 2, 3) display correctly
- [ ] Player stat text "XN番目に反転" displays
- [ ] Rotating dice icon animation plays
- [ ] Total duration matches expectation
- [ ] onAnimationComplete fires at end

**Test File**: `test/features/match/presentation/widgets/lottery_animation_widget_test.dart`

---

### 1.5 SimultaneousRevealWidget Integration
- [ ] Empty events list triggers immediate onComplete
- [ ] Events processed in sequence
- [ ] Event type routing (_buildStage) works correctly
- [ ] AnimatedSwitcher transition applies
- [ ] Duration for each event type uses default correctly
- [ ] Supports 'lottery', 'announce_turn', 'flip_animation', 'flip' types

**Test File**: `test/features/match/presentation/widgets/simultaneous_reveal_widget_test.dart`

---

## 2. Animation Orchestration Tests

### 2.1 AnimationOrchestratorNotifier
- [ ] State initializes with empty queue
- [ ] queueAnimation adds to queue
- [ ] queueAnimations adds multiple animations
- [ ] clearQueue resets state
- [ ] Current animation updates when queue is processed
- [ ] isPlaying flag toggles correctly
- [ ] onComplete callbacks fire
- [ ] Queue processes in order (FIFO)
- [ ] Animations wait full duration before next

**Test File**: `test/features/match/application/providers/animation_orchestrator_provider_test.dart`

---

### 2.2 AnimationSequenceBuilder
- [ ] buildWeakBonusAnimation creates correct structure
- [ ] buildRescueCardAnimation sets reason correctly
- [ ] buildCollisionAnimation includes all player data
- [ ] buildLotteryAnimation maps player data correctly
- [ ] buildFlipAnimation includes flipped positions
- [ ] buildRoundSequence generates sequence in correct order:
  1. Lottery
  2. Collisions
  3. Bonuses
  4. Rescue cards
  5. Flips

**Test File**: `test/features/match/application/services/animation_sequence_builder_test.dart`

---

## 3. Firebase Integration Tests

### 3.1 FirestoreMatchProvider
- [ ] firestoreProvider returns FirebaseFirestore instance
- [ ] matchDocumentProvider streams match updates
- [ ] matchRoundResultsProvider streams ordered results
- [ ] roundResultProvider fetches single result correctly

**Test File**: `test/features/match/application/providers/firestore_match_provider_test.dart`

---

### 3.2 FirestoreMatchRepository
- [ ] saveRoundResult writes to Firestore
- [ ] updateMatchState updates existing match
- [ ] getUserMatches queries by player
- [ ] createMatch creates new document with ID
- [ ] endMatch sets status=finished and results

**Test File**: `test/features/match/application/services/firestore_repository_test.dart`

---

### 3.3 FirebaseErrorHandler
- [ ] handleFirestoreError maps error codes to messages
- [ ] withRetry retries transient errors
- [ ] withRetry fails fast on permission errors
- [ ] isPermissionError detects auth failures
- [ ] isValidationError detects invalid data
- [ ] Error messages are in Japanese

**Test File**: `test/features/match/application/services/firebase_error_handler_test.dart`

---

### 3.4 MatchProgressProvider
- [ ] Initial state sets totalRounds correctly
- [ ] recordRoundCompletion increments count
- [ ] progressPercentage calculates correctly
- [ ] finishMatch sets winners and scores
- [ ] reset clears progress

**Test File**: `test/features/match/application/providers/match_progress_provider_test.dart`

---

## 4. End-to-End Integration Tests

### 4.1 Full Match Sequence
**Scenario**: Complete 3-round match with bonus activations

Steps:
1. Initialize match via Firestore
2. Submit moves for Round 1
3. Trigger weak bonus animation (if applicable)
4. Process collisions (if any)
5. Display lottery animation
6. Display flip animations
7. Record round result to Firestore
8. Repeat for Round 2-3
9. Calculate winners
10. Mark match finished in Firestore

**Verification**:
- [ ] All Firestore documents created correctly
- [ ] Animation sequences fire in order
- [ ] onComplete callbacks advance game state
- [ ] Match marked finished with results
- [ ] Round results visible in Firestore queries

**Test File**: `test/features/match/presentation/screens/match_screen_phase13_e2e_test.dart`

---

### 4.2 Collision + Rescue Card Sequence
**Scenario**: Same square placement → random winner → loser gets rescue card

Steps:
1. Create collision scenario (2+ players on same square)
2. Resolve collision (random winner)
3. Display collision animation
4. Award rescue card to losers
5. Display rescue card animation
6. Verify Firestore state

**Verification**:
- [ ] Collision animation displays winner/losers
- [ ] Rescue card animation fires after collision
- [ ] RescueCardState updated in Firestore
- [ ] Losers shown with rescue card badge

**Test File**: `test/features/match/presentation/screens/match_screen_phase13_collision_e2e_test.dart`

---

### 4.3 Weak Bonus Sequence
**Scenario**: Bottom 20% player in endgame activates weak bonus

Steps:
1. Verify bonus activation conditions met
2. Trigger weak bonus animation
3. Grant extra move to player
4. Update BonusActivationState in Firestore
5. Verify activation count incremented

**Verification**:
- [ ] Bonus animation fires
- [ ] Extra move applied to player moves
- [ ] Activation count incremented (max 2)
- [ ] Firestore BonusActivationState updated

**Test File**: `test/features/match/presentation/screens/match_screen_phase13_bonus_e2e_test.dart`

---

## 5. Performance Tests

### 5.1 Animation Performance
- [ ] Animation frames render at 60 FPS
- [ ] No frame drops during queue processing
- [ ] Memory usage stable (no leaks)
- [ ] CPU usage < 30% during animations

**Tool**: Flutter DevTools Performance
**Test File**: `test/features/match/presentation/widgets/animation_performance_test.dart`

---

### 5.2 Firestore Performance
- [ ] Round result save < 1000ms
- [ ] Match update < 500ms
- [ ] Stream listeners subscribe < 200ms
- [ ] Query for match rounds < 800ms

**Tool**: Firestore emulator with latency injection
**Test File**: `test/features/match/application/services/firestore_performance_test.dart`

---

## 6. Manual Testing Checklist

### 6.1 Visual Verification
- [ ] WeakBonusAnimationWidget renders cleanly (yellow theme)
- [ ] RescueCardAnimationWidget renders cleanly (red theme)
- [ ] CollisionResolutionAnimationWidget renders cleanly (purple theme)
- [ ] LotteryAnimationWidget process order cards visible
- [ ] All text is legible and properly colored
- [ ] Icons animate smoothly
- [ ] No UI glitches during transitions

### 6.2 Interaction Testing
- [ ] Animations auto-dismiss after duration
- [ ] onComplete callbacks fire at right time
- [ ] SimultaneousRevealWidget processes all events
- [ ] Back button doesn't break animation state
- [ ] Screen rotation doesn't crash animations

### 6.3 Firebase Testing
- [ ] Can create match and store to Firestore
- [ ] Can save round results
- [ ] Can query round results
- [ ] Match updates reflect in listeners
- [ ] Error handling displays user message
- [ ] Offline mode gracefully degrades

### 6.4 Integration Testing
- [ ] Full match: init → round 1-3 → finish
- [ ] Animations play in correct order
- [ ] Firestore reflects all game state
- [ ] UI stays responsive during Firestore ops
- [ ] Network lag doesn't break game flow

---

## 7. Known Limitations & TODOs

### 7.1 Phase 13 Limitations
- [ ] Lottie JSON files: Using placeholder Flutter icons
  - TODO: Provide actual Lottie animation files
  - Location: `assets/animations/*.json`
  - Each: < 50 KB
- [ ] Animation integration into MatchScreen: Basic structure only
  - TODO: Wire AnimationOrchestratorNotifier into round processing
  - Hook point: `_applyRoundMoves()` method

### 7.2 Phase 2 Enhancements
- [ ] Sound effects synchronized with animations
- [ ] Haptic feedback on Android/iOS
- [ ] Animation quality settings (high/medium/low)
- [ ] Custom animation curve tuning

---

## 8. Success Criteria

### 8.1 Animation Subsystem
- [ ] All 4 animation widgets tested (100% coverage)
- [ ] Animation orchestrator manages queue correctly
- [ ] No memory leaks during long animation sequences
- [ ] Performance: 60 FPS, no jank

### 8.2 Firebase Subsystem
- [ ] All Firestore operations tested
- [ ] Error handling verified
- [ ] Retry logic works correctly
- [ ] Stream listeners active and updating

### 8.3 End-to-End Integration
- [ ] Complete 3-round match creates Firestore documents
- [ ] Animations fire in correct order
- [ ] Match completion marks in Firestore
- [ ] All edge cases handled (collision, bonuses, etc.)

### 8.4 Code Quality
- [ ] Test coverage > 70%
- [ ] No analyzer warnings
- [ ] Linter passes all checks
- [ ] Documentation complete

---

## 9. Test Execution Schedule

| Phase | Date | Duration | Tests |
|-------|------|----------|-------|
| Setup | 2026-09-11 | 2h | Infrastructure |
| Widget | 2026-09-12 | 4h | Animation widgets |
| Orchestration | 2026-09-12 | 2h | Orchestrator, builder |
| Firebase | 2026-09-13 | 3h | Firestore, errors, progress |
| E2E | 2026-09-14 | 4h | Full match scenarios |
| Performance | 2026-09-14 | 2h | Frame rate, timing |
| Manual | 2026-09-15 | 3h | UI/UX verification |

---

## 10. Regression Testing

### Before Phase 14
- [ ] All Phase 12 tests still pass
- [ ] Analyzer: 0 errors, 0 warnings
- [ ] Linter: 0 errors
- [ ] Build: iOS & Android successful
- [ ] No new memory leaks

---

**Phase 13 Testing Owner**: Claude / Testing Task  
**Last Updated**: 2026-09-11  
**Status**: Planning Phase
