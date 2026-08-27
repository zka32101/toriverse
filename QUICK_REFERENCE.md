# Toriverse Presentation Layer - Quick Reference

## File Locations

### Entry Point
```
lib/main.dart ........................... App initialization with Riverpod + GoRouter
```

### Configuration
```
lib/config/theme.dart .................. Material 3 theme, colors (black/white/red)
lib/config/router.dart ................. GoRouter: /, /home, /match/:id, /results/:id
```

### Screens (5 total)
```
lib/features/auth/presentation/screens/auth_wrapper.dart
    → Guest login gate → Auto-redirect to /home

lib/features/home/presentation/screens/home_screen.dart
    → User profile, stats, "マッチング開始" button
    → Matching dialog with player count

lib/features/match/presentation/screens/matching_screen.dart
    → Queue status, waiting for 3rd player
    → Auto-fill with AI if timeout

lib/features/match/presentation/screens/match_screen.dart
    → Game board (8×8), valid move highlights
    → Player turn info, pause button
    → Auto-navigate to results when game ends

lib/features/results/presentation/screens/results_screen.dart
    → Ranking with medals, stone counts
    → Streak animation, clip preview
    → "ホームに戻る" button
```

### Widgets (5 total)
```
lib/features/match/presentation/widgets/board_widget.dart
    → 8×8 GridView, green background, tappable cells

lib/features/match/presentation/widgets/stone_widget.dart
    → Renders 0=black, 1=white, 2=red, 3=empty
    → Valid move highlight (green ring + dot)

lib/features/match/presentation/widgets/move_submission_panel.dart
    → Current player name, valid move count
    → 30-second countdown timer (green→orange→red)

lib/features/match/presentation/widgets/bonus_indicator.dart
    → Weak bonus: Yellow card, star icon, auto-dismiss 3s
    → Rescue card: Red card, gift icon, scale+fade animation

lib/features/match/presentation/widgets/rescue_card_badge.dart
    → PlayerStatCard: Color dot, name, stone count, card badge
    → RescueCardBadge: Small indicator chip
```

### Providers (9 main)
```
lib/features/auth/application/providers/auth_state.dart
    → authStateProvider (bool: logged in?)
    → Methods: loginGuest(), logout()

lib/features/home/application/providers/home_state.dart
    → homeStateProvider (notifications, daily streak)

lib/features/match/application/providers/user_state.dart
    → userStateProvider, rankPointsProvider, streakProvider
    → hasFreeMatchProvider, isSubscribedProvider, isLoggedInProvider

lib/features/match/application/providers/game_state.dart
    → gameStateProvider (board, players, turns, status)
    → boardProvider, validMovesProvider, stoneCountsProvider
    → isGameOverProvider, roundIndexProvider
    → Methods: startGame(), placeStone(), executeAIMove(), pauseGame()

lib/features/match/application/providers/matching_state.dart
    → matchingStateProvider (queue status, player count)
    → isMatchedProvider, isSearchingProvider, matchedPlayersProvider
    → Methods: startMatching(userId), completeWithAI(), cancelMatching()
```

---

## Key Data Flows

### 1. Login Flow
```
[App starts]
  ↓
main.dart → MaterialApp.router(routerConfig: goRouterProvider)
  ↓
GoRouter initialLocation = '/'
  ↓
AuthWrapper watches isLoggedInProvider
  ├─ FALSE: Show login button
  │   └─ Click → ref.read(authStateProvider.notifier).loginGuest()
  │       └─ Sets isLoggedIn = true
  └─ TRUE: context.go('/home') [auto-redirect]
```

### 2. Game Startup
```
HomeScreen [Click "マッチング開始"]
  ↓
ref.read(matchingStateProvider.notifier).startMatching(userId)
  ├─ Sets status = SEARCHING
  ├─ Polls for players (5s intervals, max 30s)
  ├─ No players? → completeWithAI() [add 2 AIs]
  └─ 3 players? → status = MATCHED
       ↓
MatchingScreen [Auto-navigate to /match/:id]
  ↓
MatchScreen
  ├─ ref.read(gameStateProvider.notifier).startGame(playerIds)
  ├─ Watches validMovesProvider for move highlights
  └─ Watches boardProvider for board rendering
```

### 3. Move Placement
```
User taps valid cell on board
  ↓
BoardWidget.onStonePlace(row, col)
  ↓
ref.read(gameStateProvider.notifier).placeStone(row, col)
  ├─ Validate move legal
  ├─ Place stone, flip captured stones
  ├─ Update stone counts
  ├─ Switch to next player
  ├─ Recalculate valid moves
  └─ Update state [triggers rebuild]
       ├─ BoardWidget re-renders new board
       ├─ MoveSubmissionPanel updates current player
       ├─ PlayerStatCard updates stone counts
       └─ If AI player: executeAIMove() [1s delay]
```

### 4. Game End
```
All players skip turn [no valid moves]
  ↓
gameStateProvider.status = FINISHED
  ↓
MatchScreen watches isGameOverProvider
  ├─ isGameOver = true
  └─ context.go('/results/:matchId') [auto-navigate]
       ↓
ResultsScreen
  ├─ Calculates ranking from stone counts
  ├─ Shows medals (🥇🥈🥉)
  ├─ Increments user streak
  ├─ Shows clip preview
  └─ Click "ホームに戻る" → context.go('/home')
       ↓
HomeScreen [Ready for next game]
```

---

## State Watch Examples

### Home Screen
```dart
final user = ref.watch(userStateProvider);        // Profile data
final isMatching = ref.watch(isSearchingProvider); // Matching status
final freematch = ref.watch(hasFreeMatchProvider); // Free match left?
```

### Match Screen
```dart
final gameState = ref.watch(gameStateProvider);   // Entire game state
final board = ref.watch(boardProvider);           // Board only
final moves = ref.watch(validMovesProvider);      // Valid moves
final counts = ref.watch(stoneCountsProvider);    // Stone counts
final isOver = ref.watch(isGameOverProvider);     // Game finished?
```

### Results Screen
```dart
final gameState = ref.watch(gameStateProvider);   // Final board
final streak = ref.watch(streakProvider);         // Streak counter
```

---

## Theme Constants

```dart
// Colors
ToriverseTheme.stoneBlack    // #2E2E2E
ToriverseTheme.stoneWhite    // #FFFFFF
ToriverseTheme.stoneRed      // #E63946
ToriverseTheme.boardGreen    // #1B5E20
ToriverseTheme.validMoveHighlight // #4CAF50
ToriverseTheme.accentRed     // #E63946

// Spacing (use consistently)
ToriverseTheme.spacing4      // 4px
ToriverseTheme.spacing8      // 8px
ToriverseTheme.spacing12     // 12px
ToriverseTheme.spacing16     // 16px
ToriverseTheme.spacing24     // 24px
ToriverseTheme.spacing32     // 32px

// Typography sizes
ToriverseTheme.headingFontSize   // 28pt
ToriverseTheme.bodyFontSize      // 16pt
ToriverseTheme.buttonFontSize    // 16pt

// Min tap target
ToriverseTheme.minTapSize    // 44pt

// Helper functions
ToriverseTheme.getStoneColor(int value)    // Returns Color
ToriverseTheme.getPlayerName(int index)    // Returns "黒"/"白"/"赤"
```

---

## Navigation Routes

```
/ → AuthWrapper
/home → HomeScreen
/match/:matchId → MatchScreen
/results/:matchId → ResultsScreen

Usage:
context.go('/home')
context.go('/match/match_abc123')
context.push('/results/match_abc123')
```

---

## Common Tasks

### Check if user is logged in
```dart
final isLoggedIn = ref.watch(isLoggedInProvider);
if (!isLoggedIn) {
  context.go('/');
}
```

### Place a stone
```dart
ref.read(gameStateProvider.notifier).placeStone(row, col);
```

### Get valid moves
```dart
final validMoves = ref.watch(validMovesProvider);
```

### Start matching
```dart
final userId = ref.read(userStateProvider)!.uid;
ref.read(matchingStateProvider.notifier).startMatching(userId);
```

### Get current player
```dart
final gameState = ref.watch(gameStateProvider);
final playerName = gameState?.currentPlayerId ?? 'Unknown';
```

### Check game status
```dart
final isGameOver = ref.watch(isGameOverProvider);
if (isGameOver) {
  context.go('/results/${matchId}');
}
```

---

## Testing Snippets

### Unit Test: Provider
```dart
test('gameStateProvider initializes board', () {
  final container = ProviderContainer();
  final notifier = container.read(gameStateProvider.notifier);
  
  notifier.startGame(playerIds: ['p1', 'p2', 'AI']);
  final gameState = container.read(gameStateProvider);
  
  expect(gameState?.board, isNotNull);
  expect(gameState?.playerIds.length, 3);
});
```

### Widget Test: Stone
```dart
testWidgets('StoneWidget renders black stone', (tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: StoneWidget(stoneValue: 0, size: 32),
      ),
    ),
  );
  
  expect(find.byType(Container), findsWidgets);
});
```

### Integration Test: Full Flow
```dart
testWidgets('Login and start game', (tester) async {
  await tester.pumpWidget(const ProviderScope(child: ToriverseApp()));
  
  await tester.tap(find.text('ゲストでログイン'));
  await tester.pumpAndSettle();
  
  expect(find.byType(HomeScreen), findsOneWidget);
  
  await tester.tap(find.text('マッチング開始'));
  await tester.pumpAndSettle();
  
  expect(find.byType(MatchingScreen), findsOneWidget);
});
```

---

## Debugging Tips

### Print current game state
```dart
final gameState = ref.read(gameStateProvider);
debugPrint('Board:\n${gameState?.board.toDebugString()}');
debugPrint('Current player: ${gameState?.currentPlayerId}');
debugPrint('Valid moves: ${gameState?.validMoves}');
```

### Check provider values
```dart
debugPrint('Is game over? ${ref.read(isGameOverProvider)}');
debugPrint('Valid moves: ${ref.read(validMovesProvider)}');
debugPrint('Stone counts: ${ref.read(stoneCountsProvider)}');
```

### Enable Riverpod logging
```dart
// In main.dart
final observer = ProviderObserver();  // Custom logging
```

### Debug navigation
```dart
debugPrint('Navigating to: /match/$matchId');
context.go('/match/$matchId');
```

---

## Performance Tips

1. **Avoid full state watch** - Use derived providers instead
   ```dart
   // Bad
   final gameState = ref.watch(gameStateProvider);
   final board = gameState?.board;
   
   // Good
   final board = ref.watch(boardProvider);
   ```

2. **Cache valid moves as Set** - O(1) lookup instead of O(n)
   ```dart
   final validMoveSet = validMoves
       .map((move) => '${move[0]},${move[1]}')
       .toSet();
   ```

3. **Use const widgets** - Prevent unnecessary rebuilds
   ```dart
   const SizedBox(height: ToriverseTheme.spacing16)
   ```

4. **Limit animation frame rate** - 60fps is enough for mobile
   ```dart
   // AnimationController default is fine
   ```

---

## Documentation Files

- **CLAUDE.md** - Project overview, tech stack, OKRs, data models
- **CODE_HANDOVER.md** - Development workflow, CI/CD
- **PRESENTATION_LAYER_GUIDE.md** - Detailed UI implementation
- **IMPLEMENTATION_SUMMARY.md** - This implementation's overview
- **QUICK_REFERENCE.md** - This file

---

## Resources

- [Flutter Docs](https://flutter.dev/docs)
- [Riverpod Guide](https://riverpod.dev)
- [GoRouter Guide](https://pub.dev/packages/go_router)
- [Material 3 Design](https://m3.material.io)
- [Lottie Flutter](https://pub.dev/packages/lottie)

---

**Quick Start**: Read PRESENTATION_LAYER_GUIDE.md for detailed explanations  
**Want to Debug?**: Check Provider values with `ref.read()` in console  
**Need to Add Feature?**: Follow feature-based structure (auth, home, match, results)  
**Lost?**: Check this quick reference or search IMPLEMENTATION_SUMMARY.md
