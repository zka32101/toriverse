# Flutter Presentation Layer for Toriverse

## Overview
This document describes the complete presentation (UI) layer implementation for the Toriverse 3-color Othello mobile game.

---

## Project Structure

```
lib/
├── main.dart                                    # App entry point with Riverpod & router
├── config/
│   ├── theme.dart                              # Material 3 theme & design tokens (NEW)
│   └── router.dart                             # GoRouter configuration (NEW)
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   │   └── screens/
│   │   │       └── auth_wrapper.dart           # Login/auth wrapper (NEW)
│   │   └── application/
│   │       └── providers/
│   │           └── auth_state.dart             # Auth state management (NEW)
│   ├── home/
│   │   ├── presentation/
│   │   │   └── screens/
│   │   │       └── home_screen.dart            # Main menu & profile (EXISTING)
│   │   └── application/
│   │       └── providers/
│   │           └── home_state.dart             # Home state (NEW)
│   ├── match/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── match_screen.dart           # Game board UI (EXISTING)
│   │   │   └── widgets/
│   │   │       ├── board_widget.dart           # 8x8 board with GridView (EXISTING)
│   │   │       ├── stone_widget.dart           # Individual stone rendering (EXISTING)
│   │   │       ├── move_submission_panel.dart  # Player info & timer (EXISTING)
│   │   │       ├── bonus_indicator.dart        # Bonus animation (EXISTING)
│   │   │       └── rescue_card_badge.dart      # Rescue card display (EXISTING)
│   │   ├── application/
│   │   │   └── providers/
│   │   │       ├── game_state.dart             # Game state (EXISTING)
│   │   │       ├── user_state.dart             # User profile state (EXISTING)
│   │   │       └── matching_state.dart         # Matching logic (EXISTING)
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── board.dart                  # Othello board logic (EXISTING)
│   │   │   └── services/
│   │   │       ├── ai_player.dart              # AI minmax (EXISTING)
│   │   │       └── bonus_calculator.dart       # Bonus logic (EXISTING)
│   │   └── data/
│   │       └── models/
│   │           ├── match_model.dart
│   │           ├── user_model.dart
│   │           ├── round_result_model.dart
│   │           ├── rescue_card_model.dart
│   │           └── weak_bonus_model.dart
│   └── results/
│       ├── presentation/
│       │   ├── screens/
│       │   │   └── results_screen.dart          # Match results & replay (EXISTING)
│       │   └── widgets/
│       └── application/
│           └── providers/
└── shared/
    ├── models/
    ├── services/
    ├── widgets/
    └── utils/
```

---

## Core Presentation Layers

### 1. Theme & Design System (`lib/config/theme.dart`) NEW

**Purpose**: Centralized design tokens and Material 3 theme configuration

**Key Features**:
- 3-color stone definitions (black=#2E2E2E, white=#FFFFFF, red=#E63946)
- Material 3 light/dark themes with `ColorScheme.fromSeed`
- Typography hierarchy (heading 28pt, body 16pt)
- Spacing constants (4, 8, 12, 16, 24, 32)
- Minimum tap target size (44pt WCAG compliance)
- Helper functions: `getStoneColor()`, `getPlayerName()`

**Usage**:
```dart
import 'config/theme.dart';

// Get color for stone value
Color stoneColor = ToriverseTheme.getStoneColor(0); // Black

// Access spacing
SizedBox(height: ToriverseTheme.spacing16)

// Apply theme to app
MaterialApp(
  theme: ToriverseTheme.lightTheme(),
  darkTheme: ToriverseTheme.darkTheme(),
)
```

---

### 2. Router Configuration (`lib/config/router.dart`) NEW

**Purpose**: Navigation structure with GoRouter

**Routes**:
- `/` → AuthWrapper (login check)
- `/home` → HomeScreen (main menu)
- `/match/:matchId` → MatchScreen (gameplay)
- `/results/:matchId` → ResultsScreen (results)

**Key Features**:
- Parameter extraction from paths
- Error page fallback
- Deep linking ready

**Usage**:
```dart
// Navigate with path parameters
context.go('/match/${matchId}');

// Access router in app
final router = ref.watch(goRouterProvider);
```

---

### 3. Authentication Wrapper (`lib/features/auth/presentation/screens/auth_wrapper.dart`) NEW

**Purpose**: Routing logic based on login state

**Features**:
- Watches `isLoggedInProvider` 
- Auto-redirects to home if logged in
- Guest login button with mock implementation
- Loading spinner during redirect

**State Management**:
```dart
final isLoggedIn = ref.watch(isLoggedInProvider);

// Auto-login as guest
ref.read(authStateProvider.notifier).loginGuest();
```

---

### 4. Auth State Provider (`lib/features/auth/application/providers/auth_state.dart`) NEW

**Purpose**: Authentication state management with Riverpod

**Key Methods**:
- `loginGuest()` — Generate guest UID and initialize user
- `logout()` — Clear user state

**Providers**:
- `authStateProvider` — Boolean (logged in/out)
- `isLoggedInProvider` — Derived provider for quick access

---

### 5. Home Screen (`lib/features/home/presentation/screens/home_screen.dart`) EXISTING

**Purpose**: Main menu with user profile and action buttons

**UI Components**:
- User profile card (avatar, displayName, UID)
- Player stats (rankPoints, completedMatchStreak, level)
- Free match status indicator (1/day or subscription)
- 3 main buttons: "マッチング開始" (start), "フレンド対戦" (friend), "ショップ" (shop)
- Matching dialog with player count animation

**State Watched**:
```dart
ref.watch(userStateProvider);        // Profile data
ref.watch(isSearchingProvider);      // Matching status
ref.watch(matchingStateProvider);    // Players waiting
ref.watch(hasFreeMatchProvider);     // Free match availability
```

**Key Features**:
- Responsive layout with `SingleChildScrollView`
- WillPopScope prevents back navigation
- Auto-navigates to match screen when matching completes
- 44pt minimum tap targets

---

### 6. Home State Provider (`lib/features/home/application/providers/home_state.dart`) NEW

**Purpose**: Home-specific state (notifications, daily streak)

**State Fields**:
- `showNotificationPrompt` — Show OS permission prompt
- `dailyLoginStreak` — Daily login tracking

---

### 7. Stone Widget (`lib/features/match/presentation/widgets/stone_widget.dart`) EXISTING

**Purpose**: Individual stone rendering with 3-color support

**Features**:
- Renders stones (0=black, 1=white, 2=red, 3=empty)
- Valid move highlighting (green ring + dot)
- Shadow effects for depth
- White stone border styling
- Tap callbacks for move placement

**Parameters**:
```dart
StoneWidget(
  stoneValue: 0,           // 0-3 (black, white, red, empty)
  size: 32,                // Stone diameter
  isValidMove: true,       // Highlight as valid?
  onTap: () {},            // Placement callback
  isAnimating: false,      // Flash effect?
)
```

---

### 8. Board Widget (`lib/features/match/presentation/widgets/board_widget.dart`) EXISTING

**Purpose**: 8x8 Othello board with GridView

**Features**:
- AspectRatio 1:1 for square board
- Green background (#1B5E20)
- Brown border styling
- Tappable cells for move placement
- Listens to `boardProvider` and `validMovesProvider`

**State Watched**:
```dart
ref.watch(boardProvider);       // Board state
ref.watch(validMovesProvider);  // Valid moves for highlighting
```

**Usage**:
```dart
BoardWidget(
  size: 300,
  onStonePlace: (row, col) {
    ref.read(gameStateProvider.notifier).placeStone(row, col);
  },
)
```

---

### 9. Move Submission Panel (`lib/features/match/presentation/widgets/move_submission_panel.dart`) EXISTING

**Purpose**: Player info, valid move count, and 30-second countdown timer

**Features**:
- Current player name (黒/白/赤)
- Valid move count display
- Animated countdown timer (30s)
- Color transitions: green → yellow → red
- AI indicator with loading spinner
- Round counter

**Animation**:
- Uses `AnimationController` with `ValueListenable`
- Timer bar with `LinearProgressIndicator`

**State Watched**:
```dart
ref.watch(gameStateProvider);      // Current player
ref.watch(validMovesProvider);     // Move count
ref.watch(userStateProvider);      // Player names
```

---

### 10. Bonus Indicator Widget (`lib/features/match/presentation/widgets/bonus_indicator.dart`) EXISTING

**Purpose**: Animated overlay for bonus triggers

**Features**:
- Scale + fade animation (500ms, elastic curve)
- Two bonus types:
  1. **Weak Bonus** — Yellow card with star icon
  2. **Rescue Card** — Red card with gift icon
- Auto-dismisses after 3 seconds
- Japanese labels

**Usage**:
```dart
BonusIndicator(
  bonusType: 'weak_bonus',
  playerName: '黒',
  displayDuration: Duration(seconds: 3),
  onDismiss: () {},
)
```

---

### 11. Rescue Card Badge (`lib/features/match/presentation/widgets/rescue_card_badge.dart`) EXISTING

**Purpose**: Display rescue card availability for a player

**Components**:
1. **RescueCardBadge** — Small badge with icon
2. **PlayerStatCard** — Full stat card showing:
   - Stone color indicator
   - Player name
   - Stone count
   - Rescue card icon (if available)
   - Current turn indicator

**Usage**:
```dart
PlayerStatCard(
  playerName: '黒',
  stoneCount: 16,
  hasRescueCard: true,
  isCurrentPlayer: true,
  playerIndex: 0,
)
```

---

### 12. Match Screen (`lib/features/match/presentation/screens/match_screen.dart`) EXISTING

**Purpose**: Main gameplay screen with board and controls

**Layout**:
1. AppBar with pause button
2. Player stats row (scrollable)
3. 8x8 board centered
4. Move submission panel
5. Game info card

**Features**:
- Pause/resume game state
- Auto-navigate to results when game ends
- WillPopScope confirms quit
- Tappable board cells for move placement
- AI move auto-execution (1s delay)

**State Watched**:
```dart
ref.watch(gameStateProvider);       // Board & turn info
ref.watch(stoneCountsProvider);     // Stone counts
ref.watch(isGameOverProvider);      // Auto-redirect
ref.watch(validMovesProvider);      // Valid cell highlighting
```

**Key Callbacks**:
```dart
// Place stone on board
ref.read(gameStateProvider.notifier).placeStone(row, col);

// Check for AI move
ref.read(gameStateProvider.notifier).executeAIMove();

// Pause game
ref.read(gameStateProvider.notifier).pauseGame();
```

---

### 13. Results Screen (`lib/features/results/presentation/screens/results_screen.dart`) EXISTING

**Purpose**: Display match results and update player profile

**Features**:
- Streak display with animation
- 3-place ranking with medals (🥇🥈🥉)
- Stone counts per player
- Clip preview placeholder
- Share button (stub)
- "Return to Home" button

**State Watched**:
```dart
ref.watch(gameStateProvider);       // Final board state
ref.watch(streakProvider);          // Streak counter
```

**Flow**:
1. Calculate ranking from stone counts
2. Animate streak increment
3. Show clip preview
4. Update user state on "Next Match"

---

## App Entry Point (`lib/main.dart`) NEW

```dart
void main() {
  runApp(
    const ProviderScope(
      child: ToriverseApp(),
    ),
  );
}

class ToriverseApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'トリバース',
      theme: ToriverseTheme.lightTheme(),
      darkTheme: ToriverseTheme.darkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
```

---

## State Management Providers

### User State (`lib/features/match/application/providers/user_state.dart`)

```dart
// Providers
userStateProvider          // Main user state (UserState?)
userUidProvider           // UID only
userDisplayNameProvider   // Display name only
rankPointsProvider        // Rank points only
streakProvider            // Streak counter
hasFreeMatchProvider      // Free match available?
isSubscribedProvider      // Subscription active?
isLoggedInProvider        // User logged in?

// Methods
initializeUser()          // Create new user
addRankPoints()           // Add points
incrementStreak()         // +1 to streak
logout()                  // Clear user
```

### Game State (`lib/features/match/application/providers/game_state.dart`)

```dart
// Providers
gameStateProvider         // Main game state
boardProvider            // Board only
currentPlayerProvider    // Current player UID
validMovesProvider       // Valid moves [[row,col],...]
stoneCountsProvider      // {uid: count}
isGameOverProvider       // Game finished?
roundIndexProvider       // Current round

// Methods
startGame(playerIds)     // Initialize with 3 players
placeStone(row, col)     // Place stone and flip
executeAIMove()          // AI turn
pauseGame()              // Pause gameplay
resumeGame()             // Resume gameplay
resetGame()              // Clear state
```

### Matching State (`lib/features/match/application/providers/matching_state.dart`)

```dart
// Providers
matchingStateProvider     // Main matching state
isMatchedProvider        // 3 players found?
isSearchingProvider      // Currently searching?
matchedPlayersProvider   // [uid1, uid2, uid3]

// Methods
startMatching(userId)    // Begin search (30s timeout)
completeWithAI()         // Fill slots with AI
cancelMatching()         // Cancel search
reset()                  // Clear state
```

---

## Riverpod Providers Watched in UI

| Screen | Providers Watched | Purpose |
|--------|------------------|---------|
| **AuthWrapper** | `isLoggedInProvider` | Redirect to home if logged in |
| **HomeScreen** | `userStateProvider`, `isSearchingProvider`, `matchingStateProvider`, `hasFreeMatchProvider` | Profile display, matching UI |
| **MatchScreen** | `gameStateProvider`, `stoneCountsProvider`, `isGameOverProvider`, `boardProvider`, `validMovesProvider`, `matchedPlayersProvider` | Board rendering, move validation, turn management |
| **ResultsScreen** | `gameStateProvider`, `streakProvider` | Results display, streak animation |

---

## Key Riverpod Patterns

### 1. Watching Nested State
```dart
// Good: Watch parent, access child
final gameState = ref.watch(gameStateProvider);
final board = gameState?.board;

// Alternative: Watch derived provider
final board = ref.watch(boardProvider);
```

### 2. Notifier Patterns
```dart
// Read for single operations
ref.read(gameStateProvider.notifier).placeStone(row, col);

// Watch for reactive updates
final gameState = ref.watch(gameStateProvider);
```

### 3. Derived Providers
```dart
final isGameOverProvider = Provider<bool>((ref) {
  return ref.watch(gameStateProvider)?.isGameOver ?? false;
});
```

---

## Styling & Layout Principles

### Responsive Design
- Use `SingleChildScrollView` for scrollable content
- `GridView` for board (AspectRatio 1:1)
- `Row`/`Column` with `Expanded` for flex layouts
- Media query for sizing: `MediaQuery.of(context).size.width`

### Accessibility (WCAG AA)
- Minimum tap target: 44pt × 44pt
- Color contrast: Black/white/red with backgrounds
- Text scaling: `Theme.of(context).textTheme`
- Icon sizes: 18pt (small), 24pt (medium), 48pt (large)

### Animation
- `AnimationController` for custom animations
- `Lottie` for bonus/special effects (list placeholders)
- Curve options: `Curves.elasticOut`, `Curves.easeIn`
- Duration recommendations:
  - Bonus trigger: 500-800ms
  - Dismiss: 1-3s auto-hide
  - Board animations: 300-500ms per cell

### Dark Mode
- `Theme.of(context).textTheme` for colors
- `Colors.white` / `Colors.grey.shade800` for backgrounds
- Use semantic color tokens from `ColorScheme`
- Avoid hardcoded colors (except brand: black, white, red)

---

## Animation Patterns

### Bonus Indicator
```dart
// Scale + Fade in (500ms elastic)
// Hold for 3s
// Fade out (reverse)
ScaleTransition(scale: _scaleAnimation, child: ...)
FadeTransition(opacity: _fadeAnimation, child: ...)
```

### Move Submission Timer
```dart
// LinearProgressIndicator with color transitions
// Green → Yellow → Red as time expires
// Update every frame with AnimationController
_timerController.addListener(() {
  _remainingTime = Duration(...);
})
```

### Stone Placement (Ready for Lottie)
```dart
// Import: import 'package:lottie/lottie.dart';
// Placeholder JSON paths:
// - assets/animations/weak_bonus.json
// - assets/animations/rescue_card.json
// - assets/animations/stone_flip.json (reverse animation)

// Example usage:
Lottie.asset(
  'assets/animations/weak_bonus.json',
  repeat: false,
)
```

---

## Lottie Animation Placeholders

The following animations are referenced in the codebase but need implementation:

1. **Weak Bonus Trigger**
   - Path: `assets/animations/weak_bonus.json`
   - Used in: `BonusIndicator` (weak_bonus)
   - Duration: 500-800ms
   - Content: Star particle burst, yellow glow

2. **Rescue Card Trigger**
   - Path: `assets/animations/rescue_card.json`
   - Used in: `BonusIndicator` (rescue_card)
   - Duration: 500-800ms
   - Content: Gift box open, red confetti

3. **Stone Flip (Optional)**
   - Path: `assets/animations/stone_flip.json`
   - Used in: `BoardWidget` (cell flip animation)
   - Duration: 300-500ms
   - Content: Stone 3D flip reverse

4. **Streak Increment (Optional)**
   - Path: `assets/animations/streak_increment.json`
   - Used in: `ResultsScreen` (streak +1)
   - Duration: 800-1200ms
   - Content: Number counter, fireworks

**To Add Animations**:
1. Create Lottie JSON files or export from Figma/LottieFiles
2. Add to: `assets/animations/`
3. Update `pubspec.yaml`:
   ```yaml
   assets:
     - assets/animations/
   ```
4. Uncomment `Lottie.asset()` calls in widgets

---

## Testing Presentation Layer

### Unit Tests (Providers)
```dart
test('isGameOverProvider returns true when game finished', () {
  final container = ProviderContainer();
  final notifier = container.read(gameStateProvider.notifier);
  notifier.startGame(playerIds: ['p1', 'p2', 'AI']);
  // ... play game ...
  final isOver = container.read(isGameOverProvider);
  expect(isOver, true);
});
```

### Widget Tests (UI Components)
```dart
testWidgets('StoneWidget renders black stone', (tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: StoneWidget(stoneValue: 0, size: 32),
      ),
    ),
  );
  
  expect(find.byType(Container), findsOneWidget);
});
```

### Integration Tests (Full Flow)
```dart
testWidgets('End-to-end game flow', (tester) async {
  await tester.pumpWidget(const ProviderScope(child: ToriverseApp()));
  
  // Login
  await tester.tap(find.text('ゲストでログイン'));
  await tester.pumpAndSettle();
  
  // Start matching
  await tester.tap(find.text('マッチング開始'));
  await tester.pumpAndSettle();
  
  // Verify match screen appears
  expect(find.byType(MatchScreen), findsOneWidget);
});
```

---

## Performance Considerations

1. **Board Rendering**: GridView with 64 cells
   - Use `physics: NeverScrollableScrollPhysics()` to prevent scroll
   - Cache valid moves in a Set for O(1) lookup
   - Repaint only affected stones (not implemented, but noted)

2. **Animation Overhead**:
   - AnimationController disposal in `dispose()`
   - Avoid AnimationController per stone (use single controller)
   - Lottie files: Optimize JSON < 100KB

3. **Provider Optimization**:
   - Use `.select()` to watch specific fields instead of whole object
   - Example: `ref.watch(stoneCountsProvider.select((c) => c?[playerId]))`

4. **State Updates**:
   - `GameStateNotifier.placeStone()` triggers rebuild of entire board
   - Consider selector pattern for granular updates

---

## Common Issues & Solutions

### Issue: Board doesn't update after placing stone
**Solution**: Ensure `GameStateNotifier` returns new Board instance, not mutation
```dart
final newBoard = currentState.board.clone();
newBoard.placeStone(row, col, playerIndex);
state = currentState.copyWith(board: newBoard);
```

### Issue: Match doesn't auto-navigate to results
**Solution**: Watch `isGameOverProvider` in `MatchScreen.build()`
```dart
if (isGameOver) {
  Future.microtask(() => context.go('/results/$matchId'));
}
```

### Issue: Timer doesn't update in real-time
**Solution**: Add listener to `AnimationController`
```dart
_timerController.addListener(() {
  setState(() { _remainingTime = ...; });
});
```

### Issue: Back button closes app instead of showing pause dialog
**Solution**: Use `WillPopScope` with custom logic
```dart
WillPopScope(
  onWillPop: () async {
    ref.read(gameStateProvider.notifier).pauseGame();
    return false; // Don't allow back
  },
  child: ...
)
```

---

## Dependencies

Add to `pubspec.yaml` (already included):
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.0
  riverpod: ^2.4.0
  go_router: ^12.1.0
  lottie: ^2.6.0  # For animations

dev_dependencies:
  flutter_test:
    sdk: flutter
```

---

## Next Steps

1. **Implement Lottie Animations** (3-4 priority)
   - Create/export weak bonus animation
   - Create/export rescue card animation
   - Add to assets and uncomment in widgets

2. **Add Analytics Events** (2-3 priority)
   - Track screen views
   - Track button taps
   - Track game outcomes

3. **Polish Dark Mode** (2 priority)
   - Test all screens in dark theme
   - Adjust contrast if needed

4. **Add Haptics** (1 priority)
   - Vibration on stone placement
   - Haptic feedback on bonus triggers

5. **Localization (i18n)** (1 priority)
   - Extract strings to `lib/l10n/app_en.arb`, `app_ja.arb`
   - Wrap strings with `AppLocalizations.of(context)?.label`

---

## File Summary

| File | Lines | Type | Status |
|------|-------|------|--------|
| `lib/main.dart` | 30 | App Entry | NEW |
| `lib/config/theme.dart` | 135 | Theme | NEW |
| `lib/config/router.dart` | 45 | Navigation | NEW |
| `lib/features/auth/application/providers/auth_state.dart` | 55 | Provider | NEW |
| `lib/features/auth/presentation/screens/auth_wrapper.dart` | 50 | Screen | NEW |
| `lib/features/home/application/providers/home_state.dart` | 40 | Provider | NEW |
| `lib/features/home/presentation/screens/home_screen.dart` | 200+ | Screen | EXISTING |
| `lib/features/match/presentation/screens/match_screen.dart` | 168 | Screen | EXISTING |
| `lib/features/match/presentation/widgets/board_widget.dart` | 115 | Widget | EXISTING |
| `lib/features/match/presentation/widgets/stone_widget.dart` | 115 | Widget | EXISTING |
| `lib/features/match/presentation/widgets/move_submission_panel.dart` | 90 | Widget | EXISTING |
| `lib/features/match/presentation/widgets/bonus_indicator.dart` | 130+ | Widget | EXISTING |
| `lib/features/match/presentation/widgets/rescue_card_badge.dart` | 150+ | Widget | EXISTING |
| `lib/features/results/presentation/screens/results_screen.dart` | 202 | Screen | EXISTING |

**Total**: 13 files, ~1,400+ lines of presentation code

---

## Questions & Support

Refer to:
- CLAUDE.md for project vision & data models
- CODE_HANDOVER.md for development workflow
- PRESENTATION_LAYER_GUIDE.md (this file) for UI implementation
