# Implementation Checklist - トリバース MVP

Status: **Phase 10 - UI Integration & Firebase Setup** (Sept 7, 2026)

## 🎯 Core Systems Implementation

### Phase 1: Data Models ✅
- [x] User model (MatchModel, RoundResultModel, etc.)
- [x] Freezed code generation setup
- [x] JSON serialization for Firestore

### Phase 2: Authentication System ✅
- [x] Firebase Authentication initialization
- [x] AuthRepository with Google/Apple/Email sign-in
- [x] AuthProvider (Riverpod) for auth state
- [x] AuthWrapper screen routing
- [x] Sign-out functionality
- [x] Error handling & user feedback

### Phase 3: Match Initialization ✅
- [x] MatchInitializationState & Notifier
- [x] AI player fallback logic (auto-fill to 3 players)
- [x] Firestore match document creation
- [x] Match provider (family) for user-specific matches
- [x] Board initialization (8x8 with center 4 stones)

### Phase 4: Move Submission System ✅
- [x] MoveSubmissionState & Notifier
- [x] 30-second submission window tracking
- [x] Collision detection (multiple players same position)
- [x] Random move processing order generation
- [x] Simultaneous reveal triggering
- [x] RoundResult document creation

### Phase 5: Firestore Security Rules ✅
- [x] Helper functions (isAuthenticated, isOwner, isMatchParticipant)
- [x] Users collection rules
- [x] Matches collection rules
- [x] Subcollection rules (submissions, roundResults, etc.)
- [x] Cosmetics & shop rules
- [x] Transactions & leaderboards rules
- [x] Default deny-all fallback

### Phase 6: Firebase Configuration ✅
- [x] Firebase initialization function
- [x] Platform-specific Firebase options (iOS, Android, Web, macOS)
- [x] Environment-based configuration structure
- [x] Automatic code-gen via flutterfire CLI support

### Phase 7: UI Screen Integration ✅
- [x] AuthWrapper updated with auth provider
- [x] HomeScreen connected to match initialization
- [x] MatchScreen integrated with auth context
- [x] Match screen gets current user ID from auth
- [x] Error handling & loading states
- [x] Navigation flow: Auth → Home → Match → Results

### Phase 8: Routing ✅
- [x] GoRouter configuration
- [x] Routes: /, /home, /match/:matchId, /results/:matchId, /shop
- [x] Error handling for unknown routes
- [x] Deep linking structure ready

### Phase 9: Game Logic Providers ✅
- [x] GameState (board, round, status tracking)
- [x] RoundPhase provider
- [x] TimeRemaining provider
- [x] RivalryState tracking
- [x] AITakeover state management

### Phase 10: UI Wiring & Integration ✅ (Current)
- [x] Connect auth to all screens
- [x] Wire match initialization to HomeScreen
- [x] Link move submission to MatchScreen
- [x] Add loading & error states
- [x] Test navigation flows

---

## 📋 Feature Implementation Status

### Must-Have Features (8 total)

#### 1. 3色オセロ本体 ⏳
- [x] Board data structure (8x8, 0/1/2 for colors)
- [x] Stone placement logic
- [x] Move validation & legality checking
- [x] Flip detection (8 directions)
- [ ] End-game handling (no valid moves)
- [ ] Score calculation
**Status**: Core logic 80%, integration pending

#### 2. 弱者ボーナス ⏳
- [ ] Activation condition check (bottom 20%)
- [ ] Round tracking for final 11 moves
- [ ] Maximum 2 activations per match
- [ ] State machine integration
- [ ] UI display & animation
**Status**: Logic stubbed, activation pending

#### 3. 連続被弾救済カード ⏳
- [ ] Attack tracking (consecutive rounds)
- [ ] Card grant logic (2-hand execution)
- [ ] State persistence in Firestore
- [ ] Usage tracking
- [ ] UI display & animation
**Status**: Logic defined, implementation pending

#### 4. AI自動引き継ぎ ✅
- [x] AI player placeholder substitution
- [x] AI identified by ID prefix "AI_"
- [ ] AI move selection (greedy strategy)
- [ ] AI timeout handling
- [ ] Inactivity detection (Cloud Functions)
**Status**: 60% - placeholder ready, strategy pending

#### 5. 同マス被り処理 ⏳
- [ ] Collision detection (same position submission)
- [ ] Random winner selection
- [ ] Rescue card grant to losers
- [ ] Animation & feedback
- [ ] Firestore logging
**Status**: Detection ready, resolution pending

#### 6. 処理順ランダム抽選 ✅
- [x] Random order generation
- [x] Fair randomization (no bias)
- [x] Animation sequence creation
- [x] Replay event generation
- [ ] Visual "lottery drawing" animation
**Status**: 90% - core logic done, animation pending

#### 7. 同時公開リプレイ演出 ⏳
- [x] RoundResultModel structure
- [ ] Reverse-turn animation
- [ ] Stone flip sequences
- [ ] Score update animation
- [ ] Reversal highlight (emotional UX)
- [ ] Automatic clip generation
**Status**: Structure ready, animation pending

#### 8. 完走ストリーク・盤面コレクション ⏳
- [x] Streak counter in User model
- [ ] Streak UI display
- [ ] Board state snapshots
- [ ] Collection gallery
- [ ] Achievement badges
**Status**: 50% - data model ready, UI pending

---

## 🔧 Infrastructure & DevOps

### Firebase Setup Checklist ⏳
- [ ] Firebase project created (toriverse-project)
- [ ] iOS app registered (GoogleService-Info.plist)
- [ ] Android app registered (google-services.json)
- [ ] Firestore database created (asia-northeast1)
- [ ] Security rules deployed
- [ ] Google OAuth configured
- [ ] Apple Sign-In enabled
- [ ] Analytics enabled
- [ ] Crashlytics enabled
- [ ] Remote Config created
**Status**: Documentation ready, manual setup required

### Build & Code Generation
- [x] build_runner configured
- [x] Freezed for immutable data classes
- [x] json_serializable for serialization
- [x] Provider generator for Riverpod
- [x] build.yaml optimized (glob pattern fixes)
**Status**: Ready - requires `flutter pub run build_runner build`

### Testing Infrastructure ⏳
- [x] Unit test structure
- [x] Widget test framework
- [ ] Board logic test suite (flip detection)
- [ ] Provider state tests
- [ ] End-to-end integration tests
- [ ] Bonus system tests
- [ ] Collision detection tests
**Status**: Framework ready, test implementation pending

### CI/CD Pipeline ⏳
- [ ] GitHub Actions workflow
- [ ] Build step (analyze, get deps)
- [ ] Test step (flutter test)
- [ ] Lint step (analyze)
- [ ] Coverage reporting
- [ ] TestFlight deployment
- [ ] Firebase App Distribution
**Status**: Not implemented - template needed

---

## 📱 Screen Implementation Status

| Screen | Status | Notes |
|--------|--------|-------|
| AuthWrapper | ✅ 90% | Google/Apple sign-in wired |
| HomeScreen | ✅ 90% | Match initialization button connected |
| MatchScreen | ✅ 80% | Board UI & move submission ready |
| ResultsScreen | ✅ 70% | Rankings display, replay pending |
| CosmeticsShopScreen | ⏳ 30% | Shop structure exists, purchase logic pending |
| ProfileScreen | ⏳ 0% | Not yet implemented |
| LeaderboardScreen | ⏳ 0% | Phase 2 feature |

---

## 🐛 Known Issues & Blockers

### Blocking Issues 🚨
1. **Firebase Credentials Not Set** - Requires manual Firebase project creation
   - Impact: App cannot initialize
   - Fix: Follow FIREBASE_SETUP.md steps
   - ETA: Manual action required

### High Priority ⚠️
1. **AI Move Selection** - Currently uses first valid move (no strategy)
   - Impact: Game feels too easy vs. AI
   - Fix: Implement minimax or greedy heuristic
   - ETA: 1-2 hours

2. **Weak Bonus Activation** - Logic defined but not integrated
   - Impact: Missing core comeback mechanic
   - Fix: Integrate with MoveApplicator
   - ETA: 2-3 hours

3. **End-Game Detection** - No valid moves → end match flow
   - Impact: Matches don't complete properly
   - Fix: Check all players after each round
   - ETA: 1 hour

### Medium Priority 🟡
1. **Animation Sequences** - Placeholder only, no actual animations
   - Impact: UX feels flat
   - Fix: Add Lottie or custom animations
   - ETA: 4-6 hours

2. **Error Messages** - Generic error text, no user guidance
   - Impact: Poor error experience
   - Fix: Add specific error messages & recovery steps
   - ETA: 2 hours

3. **Network Resilience** - No offline support or auto-retry
   - Impact: Network hiccups cause failures
   - Fix: Implement Firestore offline persistence
   - ETA: 3-4 hours

### Low Priority 💚
1. **Accessibility** - No WCAG AA testing
   - Fix: Add semantic labels, color contrast check
   - ETA: After MVP launch

2. **Localization** - Japanese only (no i18n structure)
   - Fix: Set up intl package for Phase 2
   - ETA: Post-launch

3. **Performance** - No profiling done
   - Fix: Run Dart DevTools, optimize hot spots
   - ETA: Post-launch if needed

---

## 📊 Coverage & Testing Status

### Code Coverage Target: 50%+

| Module | Coverage | Target |
|--------|----------|--------|
| Domain Logic | 0% | 80% |
| Data Repositories | 0% | 60% |
| Game State Providers | 0% | 70% |
| UI Widgets | 0% | 30% |
| **Overall** | **0%** | **50%** |

### Test Categories
- [ ] Unit Tests (game rules, calculations)
- [ ] Widget Tests (screen interactions)
- [ ] Integration Tests (end-to-end flows)
- [ ] Performance Tests (frame rate, memory)

---

## 🎬 Rollout Plan

### Soft Launch Criteria (2026 Q4)
- [ ] Day 1 retention: 25%+
- [ ] Crash-free rate: 99.5%+
- [ ] Initial reversal experience rate: 60%+
- [ ] 3-human match success rate: 40%+
- [ ] All 8 must-have features functional
- [ ] Core game loop stable

### Beta Channels
1. **Internal Testing** (Developers) - Current
2. **TestFlight** (iOS) - Ready for setup
3. **Firebase App Distribution** (Android) - Ready for setup
4. **Limited Release** (5K users) - After beta validation
5. **Soft Launch** (100K users) - If metrics pass gates
6. **Full Launch** - After 2 weeks monitoring

---

## 🗂️ File Organization

### Key Files by Feature

**Authentication**
- `lib/features/auth/presentation/screens/auth_wrapper.dart`
- `lib/features/auth/application/providers/auth_provider.dart`
- `lib/features/auth/data/repositories/auth_repository.dart`

**Match Initialization**
- `lib/features/match/application/providers/match_initialization_state.dart`

**Move Submission**
- `lib/features/match/application/providers/move_submission_state.dart`

**Game State**
- `lib/features/match/application/providers/game_state.dart`

**Board Logic**
- `lib/features/match/domain/entities/board.dart`

**Firebase**
- `lib/config/firebase_config.dart`
- `lib/config/firebase_options.dart`
- `firestore.rules`

**Routing**
- `lib/config/router.dart`

---

## 📝 Documentation

- ✅ [CLAUDE.md](./CLAUDE.md) - Full spec (Japanese)
- ✅ [FIREBASE_SETUP.md](./FIREBASE_SETUP.md) - Firebase guide (English)
- ✅ [README.md](./README.md) - Project overview (Japanese/English)
- ✅ [CODE_HANDOVER.md](./CODE_HANDOVER.md) - Previous work notes
- ✅ [firestore.rules](./firestore.rules) - Security rules with comments

---

## 🚀 Next Steps (Priority Order)

### Immediate (Today)
1. [ ] Manually create Firebase project
2. [ ] Register iOS & Android apps
3. [ ] Download & configure credentials
4. [ ] Deploy Firestore rules
5. [ ] Test authentication flow

### This Week
1. [ ] Implement AI move selection (minimax or greedy)
2. [ ] Implement weak bonus activation
3. [ ] Add end-game detection
4. [ ] Fix board logic edge cases (corner stones, etc.)
5. [ ] Write unit tests for core game logic

### Next Week  
1. [ ] Add animation sequences (Lottie or custom)
2. [ ] Improve error messages & UX
3. [ ] Set up CI/CD pipeline
4. [ ] Add network resilience & offline support
5. [ ] Begin TestFlight setup

### Before Soft Launch
1. [ ] Complete all 8 must-have features
2. [ ] Achieve 50% test coverage
3. [ ] Performance profiling & optimization
4. [ ] Accessibility audit
5. [ ] Analytics event tracking
6. [ ] Remote Config setup for feature toggles

---

## 📞 Contact & Questions

**Project Owner**: zka32101  
**Current Phase**: 10 - UI Integration  
**Last Updated**: 2026-09-07

For questions on specific systems, see inline code comments and CLAUDE.md.

---

**Remember**: This is an MVP. Perfection is the enemy of shipping. Focus on the core game loop and validated mechanics, not edge cases or polish (for now).
