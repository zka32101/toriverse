# Phase 13: Integration Guide
## Wiring Animations & Firebase into MatchScreen

**Purpose**: Step-by-step guide to complete Phase 13 integration  
**Target Session**: Next Claude Code session  
**Estimated Duration**: 3-4 hours  

---

## 1. Current State (Before Integration)

✅ **Completed**:
- Animation widgets (4 types) with placeholder icon animations
- AnimationOrchestratorNotifier (queue management)
- AnimationSequenceBuilder (event→animation conversion)
- Firestore providers (Firestore, error handler, progress tracker)
- Asset registration in pubspec.yaml
- Comprehensive test plan and documentation

🔴 **Missing**:
- Integration into MatchScreen game flow
- Actual Lottie JSON animation files
- Unit & integration test implementations
- Animation display in UI (overlay system)

---

## 2. Integration Steps

### Step 1: Examine MatchScreen Current Structure
**File**: `lib/features/match/presentation/screens/match_screen.dart`

**Current Hook Point**: `_applyRoundMoves()` method
```dart
void _applyRoundMoves() {
  // Current: Directly applies round moves to board
  // TODO: Add animation orchestration here
}
```

**Action Required**:
1. Read the full MatchScreen file
2. Understand the current game loop
3. Identify where animations should trigger

---

### Step 2: Create Animation Overlay System
**File to Create**: `lib/features/match/presentation/widgets/animation_overlay.dart`

**Purpose**: Display animations full-screen on top of board

**Structure**:
```dart
class AnimationOverlay extends StatefulWidget {
  final AnimationOrchestratorState state;
  final VoidCallback onAnimationComplete;
  
  @override
  Widget build(BuildContext context) {
    if (state.currentAnimation == null) {
      return const SizedBox.shrink();
    }
    
    return _buildAnimationForType(state.currentAnimation!.type);
  }
}
```

**Implementation**:
- Watch `animationOrchestratorProvider(matchId)`
- Switch on `currentAnimation.type`
- Render appropriate widget (WeakBonus, RescueCard, etc.)
- Pass animation data from `currentAnimation.data`

---

### Step 3: Modify MatchScreen Build Method
**File**: `lib/features/match/presentation/screens/match_screen.dart`

**Changes**:

#### 3a. Add imports
```dart
import '../widgets/animations/animations_barrel.dart';
import '../../application/providers/animation_orchestrator_provider.dart';
import '../../application/services/animation_sequence_builder.dart';
```

#### 3b. Add Riverpod watchers in build
```dart
@override
Widget build(BuildContext context) {
  final animationState = ref.watch(
    animationOrchestratorProvider(_matchId),
  );
  
  // ... rest of widget
}
```

#### 3c. Add animation overlay to Stack
```dart
Stack(
  children: [
    // Existing board and UI widgets
    board,
    playerStats,
    
    // NEW: Animation overlay on top
    if (animationState.currentAnimation != null)
      AnimationOverlay(
        state: animationState,
        onAnimationComplete: () {
          // Animation finished, proceed
        },
      ),
  ],
)
```

---

### Step 4: Wire AnimationOrchestratorNotifier into Round Processing
**File**: `lib/features/match/presentation/screens/match_screen.dart`

**Modification**: Update `_applyRoundMoves()` method

**Current**:
```dart
void _applyRoundMoves() {
  // Applies moves immediately
}
```

**Updated**:
```dart
void _applyRoundMoves() {
  final orchestrator = ref.read(
    animationOrchestratorProvider(_matchId).notifier,
  );
  
  // Build animation sequence from round result
  final animations = AnimationSequenceBuilder.buildRoundSequence(
    result: _currentResolution.result,
    playerNames: _playerNames,
    playerIndices: [0, 1, 2],
  );
  
  // Queue all animations
  orchestrator.queueAnimations(animations);
}
```

---

### Step 5: Handle Animation Completion Callbacks
**File**: `lib/features/match/presentation/screens/match_screen.dart`

**Purpose**: Advance game state after each animation

**Implementation in AnimationSequenceBuilder**:
```dart
// Each queued animation includes a callback:
QueuedAnimation buildFlipAnimation({
  required String playerId,
  // ...
  VoidCallback onComplete = () {
    // Update board with flipped stones
    updateBoardState();
  },
})
```

**In AnimationOverlay**:
```dart
onAnimationComplete() {
  // Call the animation's onComplete callback
  state.currentAnimation?.onComplete?.call();
  
  // Orchestrator handles next animation in queue
}
```

---

### Step 6: Integrate Firestore Round Result Saving
**File**: `lib/features/match/presentation/screens/match_screen.dart`

**Purpose**: Save round results to Firestore after animations complete

**Implementation**:

```dart
void _onRoundAnimationsComplete() {
  final repository = ref.read(firestoreRepositoryProvider);
  
  // Create round result model from game state
  final result = RoundResultModel(
    id: '${_matchId}_${roundIndex}',
    matchId: _matchId,
    roundIndex: roundIndex,
    submittedMoves: _getSubmittedMoves(),
    collisionResolved: _getCollisions(),
    processOrder: _processOrder,
    replayEvents: [], // Generated by orchestrator
  );
  
  // Save to Firestore
  repository.saveRoundResult(result);
  
  // Update progress
  ref.read(
    matchProgressProvider((matchId: _matchId, totalRounds: 26)).notifier,
  ).recordRoundCompletion();
}
```

---

### Step 7: Handle Match Completion
**File**: `lib/features/match/presentation/screens/match_screen.dart`

**Purpose**: Mark match finished in Firestore and show results

**Implementation**:

```dart
void _onMatchComplete() {
  final repository = ref.read(firestoreRepositoryProvider);
  final winners = _calculateWinners(_finalScores);
  
  // End match in Firestore
  repository.endMatch(
    _matchId,
    winners: winners,
    finalScores: _finalScores,
  );
  
  // Navigate to results screen
  context.push('/results/${_matchId}');
}
```

---

## 3. Testing During Integration

### 3.1 Local Testing
- [ ] Run app and start a match
- [ ] Verify animations appear (placeholder icons)
- [ ] Check animation duration and sequencing
- [ ] Verify onComplete callbacks fire

### 3.2 Firestore Testing
- [ ] Start match and play 1 round
- [ ] Check Firestore emulator for roundResults collection
- [ ] Verify round result structure
- [ ] Check timestamp and data accuracy

### 3.3 Error Testing
- [ ] Disconnect network and verify error message
- [ ] Check retry logic kicks in
- [ ] Verify game doesn't crash

---

## 4. Lottie JSON File Integration

**When** Lottie JSON files are available from designer:

### 4.1 Placement
- Move JSON files to `assets/animations/`
  - `weak_bonus.json`
  - `rescue_card.json`
  - `collision_resolution.json`
  - `lottery.json`

### 4.2 Update Widget Animation Methods
Replace placeholder implementations:

**Before**:
```dart
Widget _buildLottieAnimation() {
  return Icon(Icons.stars, size: 80);  // Placeholder
}
```

**After**:
```dart
Widget _buildLottieAnimation() {
  return Lottie.asset(
    'assets/animations/weak_bonus.json',
    width: 160,
    height: 160,
    fit: BoxFit.contain,
  );
}
```

### 4.3 Test Verification
- [ ] Animation plays smoothly
- [ ] No frame drops (60 FPS)
- [ ] Colors match theme
- [ ] Duration matches expectation

---

## 5. Unit Test Implementation

### 5.1 Animation Widget Tests
**Location**: `test/features/match/presentation/widgets/`

**Test Structure**:
```dart
testWidgets('WeakBonusAnimationWidget renders with player name',
  (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WeakBonusAnimationWidget(
          playerName: 'TestPlayer',
          playerIndex: 0,
          onAnimationComplete: () {},
        ),
      ),
    );
    
    expect(find.text('弱者ボーナス発動!'), findsOneWidget);
    expect(find.text('TestPlayer'), findsOneWidget);
  },
);
```

**Test Cases per Widget**:
- Rendering (text, icons, colors)
- Animation timing
- Callback firing
- Auto-dismissal

### 5.2 Orchestrator Tests
**Location**: `test/features/match/application/providers/`

**Test Cases**:
- Queue initialization
- Animation sequencing (FIFO)
- Callback execution
- State transitions (isPlaying flag)

### 5.3 Firebase Tests
**Location**: `test/features/match/application/services/`

**Test Cases**:
- Firestore CRUD operations
- Error handling and retry logic
- Stream listener subscriptions

---

## 6. Common Integration Issues & Solutions

### Issue 1: Animations not triggering
**Cause**: `_applyRoundMoves()` not calling orchestrator  
**Solution**: Add debugPrint statements to verify method is called
```dart
debugPrint('_applyRoundMoves called, queuing animations');
orchestrator.queueAnimations(animations);
```

### Issue 2: Callback not firing
**Cause**: onComplete not set on animation  
**Solution**: Ensure all QueuedAnimation objects have callbacks
```dart
QueuedAnimation(
  // ... fields ...
  onComplete: _onAnimationComplete,  // Must be non-null
)
```

### Issue 3: Firestore connection fails
**Cause**: Firebase not initialized or network issues  
**Solution**: Check Firebase initialization in main.dart
```dart
await initializeFirebase();  // Call before runApp()
```

### Issue 4: Memory leak in animations
**Cause**: AnimationControllers not disposed  
**Solution**: Ensure dispose() is called in all StatefulWidgets
```dart
@override
void dispose() {
  _fadeOutController.dispose();  // Must call parent last
  super.dispose();
}
```

---

## 7. Deployment Checklist

Before creating PR for Phase 13:

### Code Quality
- [ ] Zero analyzer warnings
- [ ] Zero linter issues
- [ ] All imports resolved
- [ ] No dead code

### Functionality
- [ ] Animations display correctly
- [ ] Firestore round results saved
- [ ] Match completion works
- [ ] Error handling works

### Testing
- [ ] 70%+ test coverage
- [ ] All widget tests pass
- [ ] Firebase tests pass
- [ ] No test regressions from Phase 12

### Documentation
- [ ] Comments on complex logic
- [ ] README updated if needed
- [ ] Phase 13 summary documents complete

### Performance
- [ ] 60 FPS animation frame rate
- [ ] Firestore operations < 1000ms
- [ ] No memory leaks
- [ ] No jank during sequences

---

## 8. File Checklist

### Existing Files (Modified)
- [ ] `lib/features/match/presentation/widgets/simultaneous_reveal_widget.dart` (import added)
- [ ] `pubspec.yaml` (assets registered)

### New Files (Created)
- [ ] `lib/features/match/presentation/widgets/animations/weak_bonus_animation_widget.dart`
- [ ] `lib/features/match/presentation/widgets/animations/rescue_card_animation_widget.dart`
- [ ] `lib/features/match/presentation/widgets/animations/collision_resolution_animation_widget.dart`
- [ ] `lib/features/match/presentation/widgets/animations/lottery_animation_widget.dart`
- [ ] `lib/features/match/presentation/widgets/animations/animations_barrel.dart`
- [ ] `lib/features/match/application/providers/animation_orchestrator_provider.dart`
- [ ] `lib/features/match/application/services/animation_sequence_builder.dart`
- [ ] `lib/features/match/application/providers/firestore_match_provider.dart`
- [ ] `lib/features/match/application/providers/match_progress_provider.dart`
- [ ] `lib/features/match/application/services/firebase_error_handler.dart`
- [ ] `assets/animations/README.md`

### Files to Create (Integration)
- [ ] `lib/features/match/presentation/widgets/animation_overlay.dart` (NEW)
- [ ] Test files (TBD based on testing plan)

---

## 9. Next Phase (Phase 14)

After Phase 13 completion:

- **Lottie Animation Files**: Provide to designer for creation
- **Performance Optimization**: Profile and optimize if needed
- **Live Viewing (Phase 2)**: Extend for spectator mode
- **Sound & Haptics (Phase 2)**: Add audio/tactile feedback

---

**Guide Version**: 1.0  
**Updated**: 2026-09-11  
**For Use By**: Next Claude Code Session
