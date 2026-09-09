# Phase 12 Implementation Guide - Game Loop Integration

**Objective**: Wire game logic systems into MatchScreen and implement animations

---

## 1. Enhanced Move Resolution in MatchScreen

### Current State (Phase 11)
MatchScreen already calls `MoveApplicator.applyRoundMoves()` directly. Phase 12 enhances this to:
1. Use `RoundProcessor` via `RoundResolutionService`
2. Track bonus activations per match
3. Track consecutive attacks for rescue cards
4. Select AI moves with difficulty levels

### Step 1: Import New Providers

```dart
import 'package:toriverse/features/match/application/providers/round_resolution_provider.dart';
import 'package:toriverse/features/match/application/providers/rescue_card_state.dart';
import 'package:toriverse/features/match/application/providers/ai_difficulty_provider.dart';
```

### Step 2: Initialize State in MatchScreen.initState()

```dart
@override
void initState() {
  super.initState();
  _currentPlayerId = '';

  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Initialize bonus tracking for this match
    ref.read(bonusActivationProvider(widget.matchId));
    
    // Initialize rescue card tracking
    final roundSubmission = ref.read(roundSubmissionProvider);
    if (roundSubmission != null) {
      ref.read(rescueCardStateProvider(widget.matchId).notifier)
          .initializeMatch(widget.matchId, ['player1', 'player2', 'player3']);
    }
    
    _startNewRoundAndSchedule();
  });
}
```

### Step 3: Enhanced AI Move Selection

Replace the simple greedy selection in `_scheduleAIMoves()`:

**Before:**
```dart
final validMoves = gameState.board.getValidMoves(i);
if (validMoves.isNotEmpty) {
  final move = validMoves.first; // Simple greedy
  final position = move[0] * 8 + move[1];
  ...
}
```

**After:**
```dart
final difficulty = ref.read(aiDifficultyProvider);
final aiSelector = ref.read(aiMoveSelectorProvider);
final move = await getAIMove(gameState.board, i, difficulty);

if (move != null) {
  final position = move[0] * 8 + move[1];
  ...
}
```

### Step 4: Enhanced Move Resolution

Replace `_generateRoundResult()` method:

```dart
Future<void> _generateRoundResult() async {
  final gameState = ref.read(gameStateProvider);
  final roundSubmission = ref.read(roundSubmissionProvider);
  final bonusState = ref.read(bonusActivationProvider(widget.matchId));
  
  if (gameState == null || roundSubmission == null || bonusState == null) return;

  try {
    // Get resolution service
    final resolutionService = ref.read(roundResolutionServiceProvider);
    
    // Convert bonus state to list format
    final bonusActivations = [
      bonusState.getActivationCount(gameState.playerIds[0]),
      bonusState.getActivationCount(gameState.playerIds[1]),
      bonusState.getActivationCount(gameState.playerIds[2]),
    ];

    // Filter submitted positions
    final validPositions = <String, int>{};
    for (final (playerId, pos) in roundSubmission.submittedPositions.entries) {
      if (pos != null) {
        validPositions[playerId] = pos;
      }
    }

    // Resolve the round using RoundResolutionService
    final resolution = await resolutionService.resolveRound(
      matchId: widget.matchId,
      roundIndex: roundSubmission.roundIndex,
      boardBefore: gameState.board,
      playerIds: gameState.playerIds,
      submittedPositions: validPositions,
      bonusActivationCounts: bonusActivations,
    );

    // Store result for animation
    ref.read(roundResultProvider.notifier).setResult(resolution.result);

    // Update bonus tracking if bonus was triggered
    if (resolution.result.bonusTriggered.isNotEmpty) {
      ref.read(bonusActivationProvider(widget.matchId).notifier)
          .recordActivation(resolution.result.bonusTriggered, roundSubmission.roundIndex);
    }

    // Track rescue cards granted
    for (final playerId in resolution.result.rescueCardsGranted) {
      ref.read(rescueCardStateProvider(widget.matchId).notifier)
          .recordAttack(widget.matchId, playerId);
    }

    // Store resolution for next phase
    _currentResolution = resolution;
    
    ref.read(roundPhaseProvider.notifier).setRevealing();

  } catch (e) {
    print('Error resolving round: $e');
    _handleGameError(e);
  }
}
```

---

## 2. Animation Implementation

### Replay Event Types (From Phase 11)

```dart
enum ReplayEventType {
  lottery,              // Process order reveal animation
  announceTurn,         // Turn announcement
  flipAnimation,        // Stone flip
  weakBonusTriggered,   // Weak bonus effect
  rescueCardGranted,    // Rescue card effect
  collisionResolution,  // Collision result
}
```

### Animation Sequence in SimultaneousRevealWidget

```dart
Future<void> playReplaySequence(List<ReplayEvent> events) async {
  for (final event in events) {
    switch (event.type) {
      case 'lottery':
        await _playLotteryAnimation(event.delayMs);
        
      case 'announce_turn':
        await _playAnnounceAnimation(event.data['playerId'], event.delayMs);
        
      case 'flip_animation':
        await _playFlipAnimation(event.data, event.delayMs);
        
      case 'weak_bonus_triggered':
        await _playBonusAnimation(event.data['playerId'], event.delayMs);
        
      case 'rescue_card_granted':
        await _playRescueCardAnimation(event.data['playerId'], event.delayMs);
    }
  }

  // After all animations complete
  _proceedToNextRound();
}
```

### Lottie Animation Integration

```dart
// pubspec.yaml
dependencies:
  lottie: ^2.4.0

// animation_widget.dart
Widget buildLotteryAnimation() {
  return Lottie.asset(
    'assets/animations/lottery.json',
    height: 200,
    repeat: false,
  );
}

Widget buildBonusAnimation(String playerId) {
  return Lottie.asset(
    'assets/animations/weak_bonus.json',
    height: 150,
    repeat: false,
  );
}
```

---

## 3. Game-Over Handling

### Enhanced Completion Check

```dart
void _checkGameCompletion(RoundResolution resolution) {
  if (resolution.isGameOver) {
    // Navigate to results with winners
    if (mounted) {
      context.pushNamed(
        'results',
        pathParameters: {'matchId': widget.matchId},
        extra: resolution.winners,
      );
    }
  } else {
    // Prepare for next round
    _prepareNextRound(resolution.boardAfter);
  }
}
```

### Update Game State

```dart
void _updateGameState(RoundResolution resolution, GameState gameState) {
  final newCounts = resolution.processor.calculateScores(
    resolution.boardAfter,
    gameState.playerIds,
  );

  ref.read(gameStateProvider.notifier).updateGameState(
    board: resolution.boardAfter,
    roundIndex: gameState.roundIndex + 1,
    stoneCounts: {
      for (int i = 0; i < gameState.playerIds.length; i++)
        gameState.playerIds[i]: newCounts[gameState.playerIds[i]] ?? 0
    },
    status: resolution.isGameOver ? GameStatus.finished : GameStatus.playing,
  );
}
```

---

## 4. Rescue Card Usage

### Track Consecutive Attacks

```dart
void _updateAttackTracking(RoundResolution resolution, GameState gameState) {
  final rescueCardNotifier = ref.read(
    rescueCardStateProvider(widget.matchId).notifier
  );

  // For each player, check if they were attacked
  // This requires analyzing the round result
  // Simplified example:
  
  for (final playerId in gameState.playerIds) {
    // Check if this player's stones were captured this round
    // If same attacker as last round, record attack
    // If different attacker, reset count
    
    // This logic depends on rivalry tracking
    // See RivalryTracker in existing code
  }
}
```

### Use Rescue Card

```dart
bool _tryUseRescueCard(String playerId) {
  final rescueCardNotifier = ref.read(
    rescueCardStateProvider(widget.matchId).notifier
  );

  return rescueCardNotifier.activateCard(
    widget.matchId,
    playerId,
    gameState.roundIndex,
  );
}
```

---

## 5. Complete Round Flow

```dart
Future<void> _processCompleteRound() async {
  try {
    // Step 1: Get all submissions or timeout
    final gameState = ref.read(gameStateProvider)!;
    final roundSubmission = ref.read(roundSubmissionProvider)!;
    
    // Step 2: Resolve round with bonus and collision logic
    final resolution = await _generateRoundResult();
    
    // Step 3: Play animations
    await _playReplayAnimations(resolution.result.replayEvents);
    
    // Step 4: Update game state
    _updateGameState(resolution, gameState);
    
    // Step 5: Update tracking state
    _updateAttackTracking(resolution, gameState);
    
    // Step 6: Check end condition
    _checkGameCompletion(resolution);
    
  } catch (e) {
    _handleGameError(e);
  }
}
```

---

## 6. Testing Checklist

### Unit Tests (Add to existing test files)

- [ ] `test_ai_difficulty_selection.dart` - Test AI move selection with different difficulties
- [ ] `test_bonus_activation_per_match.dart` - Verify bonus state tracking per match
- [ ] `test_rescue_card_integration.dart` - Verify card granting and usage
- [ ] `test_round_resolution_service.dart` - Full round resolution pipeline

### Integration Tests

- [ ] Start match with 3 human players
- [ ] Each player submits move
- [ ] Bonus activates correctly (if conditions met)
- [ ] Collision handled with rescue card grant
- [ ] Game detects end condition
- [ ] Results screen shows correct winners

### Manual Testing

- [ ] Play full 3-player game to completion
- [ ] Verify weak bonus triggers in late game
- [ ] Verify rescue cards grant on consecutive attacks
- [ ] Verify collision resolution works
- [ ] Verify AI difficulty levels produce different moves
- [ ] Verify animations play smoothly

---

## 7. Migration Checklist

### Files to Modify

- [ ] `match_screen.dart` - Wire new providers and services
- [ ] `simultaneous_reveal_widget.dart` - Add animation playback
- [ ] `board_widget.dart` - Highlight bonus/rescue card effects
- [ ] `results_screen.dart` - Display winners and stats

### New Files Created (Phase 12)

- [ ] `round_resolution_provider.dart` ✅
- [ ] `ai_difficulty_provider.dart` ✅
- [ ] `lottie_animations.dart` (for animation widgets)
- [ ] Tests for all new providers

### Provider Integration

```dart
// In match_screen.dart build()
final bonusState = ref.watch(bonusActivationProvider(widget.matchId));
final rescueCardState = ref.watch(rescueCardStateProvider(widget.matchId));
final aiDifficulty = ref.watch(aiDifficultyProvider);
final resolutionService = ref.watch(roundResolutionServiceProvider);
```

---

## 8. Firebase Setup (Manual Steps)

1. **Create Firebase Project**
   - Go to console.firebase.google.com
   - Create new project: "toriverse"
   - Region: asia-northeast1 (Japan)

2. **Register Apps**
   - iOS: Bundle ID = com.toriverse.app
   - Android: Package = com.toriverse.app
   - Download GoogleService-Info.plist (iOS)
   - Download google-services.json (Android)

3. **Create Firestore Database**
   - Start in test mode (for development)
   - Set region: asia-northeast1

4. **Deploy Security Rules**
   ```bash
   # (From firebase-cli)
   firebase deploy --only firestore:rules
   ```

---

## 9. Performance Considerations

### AI Move Generation
- Depth 1 (easy): ~10-50ms
- Depth 3 (normal): ~100-300ms
- Depth 4 (hard): ~300-800ms
- Depth 5 (expert): ~1-3s

**Optimization**: Run AI moves in background isolates for depths 4+

### Board Cloning
- Full board clone: O(64) - acceptable
- Consider caching valid moves if performance becomes issue

### Animation Frame Rate
- Target 60 FPS during animations
- Use RepaintBoundary for expensive widgets
- Avoid rebuilding entire board during flip animations

---

## 10. Error Handling

### Network Errors (Firestore)
```dart
try {
  await saveRoundResult(matchId, resolution.result);
} catch (e) {
  // Store locally and retry on reconnection
  await _storeRoundLocally(resolution.result);
  _showOfflineNotice();
}
```

### Invalid Moves
```dart
if (!boardAfter.getValidMoves(playerIndex).contains([row, col])) {
  _showInvalidMoveError();
  return;
}
```

### Game Logic Errors
```dart
final validationResult = GameStateValidator.validateGameState(...);
if (!validationResult.isValid) {
  _showValidationError(validationResult.errors);
  return;
}
```

---

**Expected Timeline**: 15-20 hours  
**Estimated Completion**: End of Sprint 3  
**Next Phase**: Phase 2 - Leaderboard, Cosmetics, Streaming

---

Document Version: 1.0  
Created: 2026-09-09  
By: Claude Haiku 4.5
