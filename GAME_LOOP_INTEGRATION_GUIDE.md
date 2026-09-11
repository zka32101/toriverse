# Game Loop Integration Guide

This guide shows how to wire the game systems together for the simultaneous reveal MVP.

---

## 1. Round Submission Flow

### Step 1: Initialize Round Submission

```dart
// In MatchScreen or GameManager
final roundSubmissionRef = ref.read(roundSubmissionProvider.notifier);

// Start a new round
roundSubmissionRef.startRound(
  roundIndex: gameState.roundIndex,
  playerIds: gameState.playerIds,
  timeout: Duration(seconds: 30), // Configurable via Remote Config
);
```

### Step 2: Player Submits Move

```dart
// When player taps a position on board
final roundSubmissionRef = ref.read(roundSubmissionProvider.notifier);
roundSubmissionRef.submitMove(playerIds[currentPlayerIndex], position);

// For AI players, generate move automatically
if (playerIds[currentPlayerIndex].startsWith('AI')) {
  final move = AIPlayer.suggestMove(
    gameState.board,
    currentPlayerIndex,
    depth: AIPlayer.getDepthByDifficulty('normal'),
  );
  if (move != null) {
    roundSubmissionRef.submitMove(playerIds[currentPlayerIndex], move);
  }
}
```

### Step 3: Check if All Players Submitted or Timeout

```dart
// Monitor submission state (watch in widget)
ref.watch(roundSubmissionProvider).whenData((submission) {
  if (submission == null) return;

  // Check if all submitted OR timeout
  final allSubmitted = submission.isAllSubmitted(playerState.playerIds);
  final timedOut = submission.isTimedOut();

  if (allSubmitted || timedOut) {
    // Proceed to move resolution
    resolveRound(submission);
  }
});
```

---

## 2. Move Resolution (Core Game Logic)

### Initialize RoundProcessor and RescueCardNotifier

```dart
final roundProcessorRef = RoundProcessor();
final rescueCardRef = ref.read(rescueCardStateProvider(matchId).notifier);

// Initialize rescue cards for match (once at match start)
rescueCardRef.initializeMatch(matchId, playerIds);
```

### Process the Round

```dart
Future<void> resolveRound(RoundSubmissionState submission) async {
  final gameState = ref.read(gameStateProvider);
  if (gameState == null) return;

  try {
    // Step 1: Process submitted moves
    final result = roundProcessorRef.processRound(
      matchId: matchId,
      roundIndex: gameState.roundIndex,
      boardBefore: gameState.board,
      playerIds: gameState.playerIds,
      submittedPositions: submission.submittedPositions
          .cast<String, int>(), // Filter out null values
      previousBonusActivations: gameState.bonusActivationCount,
    );

    // Step 2: Update game state with new board
    ref.read(gameStateProvider.notifier).updateGameState(
      board: result.boardAfter,
      roundIndex: gameState.roundIndex + 1,
      stoneCounts: {
        for (int i = 0; i < gameState.playerIds.length; i++)
          gameState.playerIds[i]: result.finalScores[i] ?? 0
      },
    );

    // Step 3: Track bonus activation
    if (result.bonusTriggered.isNotEmpty) {
      final playerIndex = gameState.playerIds.indexOf(result.bonusTriggered);
      if (playerIndex >= 0) {
        // Update bonus activation count
        gameState.bonusActivationCount[playerIndex]++;
      }
    }

    // Step 4: Handle rescue cards
    for (final looserId in result.rescueCardsGranted) {
      final playerIndex = gameState.playerIds.indexOf(looserId);
      if (playerIndex >= 0) {
        // Optionally track attack patterns here
        // This could trigger automatic rescue card grant
      }
    }

    // Step 5: Store round result in Firestore
    await saveRoundResult(matchId, result);

    // Step 6: Check game over
    if (roundProcessorRef.isGameOver(result.boardAfter)) {
      // Game finished - determine winners and show results
      final winners = roundProcessorRef.determineWinners(
        result.boardAfter,
        gameState.playerIds,
      );
      await handleGameOver(winners);
    } else {
      // Continue to next round
      ref.read(roundPhaseProvider.notifier).setSelection();
      ref.read(roundSubmissionProvider.notifier).reset();
    }
  } catch (e) {
    print('Error resolving round: $e');
    handleGameError(e);
  }
}
```

---

## 3. Board State Representation

### RoundResultModel Structure

The `RoundResultModel` contains everything needed for replay and next-round processing:

```dart
RoundResultModel(
  id: 'match-123_round-0',
  matchId: 'match-123',
  roundIndex: 0,
  submittedMoves: [
    SubmittedMove(playerId: 'player1', position: 18, submittedAt: ...),
    SubmittedMove(playerId: 'player2', position: 26, submittedAt: ...),
    SubmittedMove(playerId: 'player3', position: null, submittedAt: ...), // Didn't submit
  ],
  collisionResolved: [
    // If multiple players picked same spot
    CollisionResolution(
      position: 26,
      winnerPlayerId: 'player2',
      losers: ['player1'], // Gets rescue card
      rescueCardGranted: true,
    ),
  ],
  processOrder: ['player3', 'player1', 'player2'], // Random order
  replayEvents: [
    ReplayEvent(type: 'lottery', data: {...}, delayMs: 500),
    ReplayEvent(type: 'announce_turn', data: {...}, delayMs: 300),
    ReplayEvent(type: 'flip_animation', data: {...}, delayMs: 800),
    ReplayEvent(type: 'weak_bonus_triggered', data: {...}, delayMs: 500),
  ],
  bonusTriggered: 'player3', // Weak bonus activated
  rescueCardsGranted: ['player1'], // Collision losers
  createdAt: DateTime.now(),
  processedAt: DateTime.now(),
)
```

---

## 4. Rescue Card Tracking

### Track Consecutive Attacks

```dart
// After each round, check attack patterns
void updateConsecutiveAttacks() {
  // This logic needs to check:
  // 1. Who attacked whom
  // 2. Are they the same attacker as last round?
  // 3. Have they hit 2 consecutive rounds?

  // Example:
  for (final playerId in playerIds) {
    // Check if this player was attacked this round
    // If same attacker as last round, increment count
    // If different attacker, reset count
    
    final wasAttacked = checkIfPlayerWasAttacked(playerId, lastRound);
    if (wasAttacked) {
      rescueCardRef.recordAttack(matchId, playerId);
    } else {
      rescueCardRef.resetConsecutiveAttacks(matchId, playerId);
    }
  }
}

// Using rescue card in next round
bool useRescueCard(String playerId) {
  return rescueCardRef.activateCard(
    matchId,
    playerId,
    gameState.roundIndex,
  );
}
```

---

## 5. Weak Bonus Activation

### Conditions (Auto-checked by RoundProcessor)

1. **Endgame Window**: Remaining rounds ≤ 11 (configurable)
2. **Stone Deficit**: Player in bottom 20% of scores
3. **Activation Limit**: Max 2 per match

### Integration

```dart
// Already handled by RoundProcessor.processRound()
// Just track the results:

if (result.bonusTriggered.isNotEmpty) {
  // Bonus was activated
  // Add animation event if needed
  // Update UI to show bonus indicator
  
  print('Weak bonus activated for ${result.bonusTriggered}');
}
```

---

## 6. Animation Sequence (UI Layer)

### Replay Event Types

```dart
// In SimultaneousRevealWidget
void playReplaySequence(List<ReplayEvent> events) {
  for (final event in events) {
    switch (event.type) {
      case 'lottery':
        // Show spinning wheel or dice animation (Lottie)
        playLottieAnimation('assets/animations/lottery.json');
        await Future.delayed(Duration(milliseconds: event.delayMs));
        
      case 'announce_turn':
        // Show "Player X goes first!" banner
        final playerId = event.data['playerId'] as String;
        showTurnAnnouncement(playerId);
        await Future.delayed(Duration(milliseconds: event.delayMs));
        
      case 'flip_animation':
        // Animate stones flipping on board
        final result = event.data['result'] as Map;
        animateStoneFlips(result);
        await Future.delayed(Duration(milliseconds: event.delayMs));
        
      case 'weak_bonus_triggered':
        // Show bonus effect
        final playerId = event.data['playerId'] as String;
        playWeakBonusAnimation(playerId);
        await Future.delayed(Duration(milliseconds: event.delayMs));
    }
  }
}
```

---

## 7. Complete Round Example

```dart
// Full flow for one round
Future<void> playOneRound() async {
  final gameState = ref.read(gameStateProvider);
  final submission = ref.read(roundSubmissionProvider);
  
  if (gameState == null || submission == null) return;

  try {
    // 1. Wait for all submissions or timeout
    await waitForAllSubmissions(submission);
    
    // 2. Process the round
    final result = roundProcessorRef.processRound(
      matchId: matchId,
      roundIndex: gameState.roundIndex,
      boardBefore: gameState.board,
      playerIds: gameState.playerIds,
      submittedPositions: submission.submittedPositions.cast(),
      previousBonusActivations: gameState.bonusActivationCount,
    );
    
    // 3. Update game state
    ref.read(gameStateProvider.notifier).updateGameState(
      board: result.boardAfter,
      roundIndex: gameState.roundIndex + 1,
      stoneCounts: calculateNewCounts(result.boardAfter),
    );
    
    // 4. Play animations
    await playReplaySequence(result.replayEvents);
    
    // 5. Save to database
    await firebaseRef.collection('matches')
        .doc(matchId)
        .collection('roundResults')
        .doc('${matchId}_${gameState.roundIndex}')
        .set(result.toJson());
    
    // 6. Check end condition
    if (roundProcessorRef.isGameOver(result.boardAfter)) {
      handleGameFinished(result.boardAfter);
    } else {
      // Prepare next round
      startNextRound();
    }
    
  } catch (e) {
    handleError(e);
  }
}
```

---

## 8. Testing the Integration

### Unit Test Example

```dart
test('full round with bonus and collision', () {
  final processor = RoundProcessor();
  final board = Board.standard();
  
  // Simulate moves
  final moves = {
    'player1': 18, // Position 18
    'player2': 26, // Position 26
    'player3': 26, // Collision with player2!
  };
  
  final result = processor.processRound(
    matchId: 'test',
    roundIndex: 10,
    boardBefore: board,
    playerIds: ['player1', 'player2', 'player3'],
    submittedPositions: moves,
    previousBonusActivations: [0, 0, 1],
  );
  
  expect(result.collisionResolved, isNotEmpty);
  expect(result.rescueCardsGranted, isNotEmpty);
  expect(result.processOrder, isNotEmpty);
});
```

---

## Quick Checklist for Integration

- [ ] Wire RoundProcessor into MatchScreen
- [ ] Connect RoundSubmissionProvider to submission tracking
- [ ] Implement AI auto-submission in game loop
- [ ] Integrate RescueCardNotifier initialization
- [ ] Create attack pattern tracking logic
- [ ] Implement replay animation playback
- [ ] Connect Firestore storage for round results
- [ ] Test full 3-player game with all systems
- [ ] Add error handling and recovery
- [ ] Performance testing with extended games

---

**Document**: Game Loop Integration Guide  
**Created**: 2026-09-07  
**Last Updated**: —  
**Target Audience**: Next developer implementing Phase 12
