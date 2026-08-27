# Phase 6: Firebase Integration & Testing - Deployment Guide

This guide covers all steps needed to complete Phase 6, from Firebase setup through testing and final verification before soft launch.

---

## 1. Firebase Project Setup

### Prerequisites
- Google Cloud Console access
- Firebase CLI installed: `npm install -g firebase-tools`
- Project owner or editor access

### Step 1.1: Create Firebase Project (if not already done)

```bash
firebase login
firebase projects:list
```

If project doesn't exist, create via console:
1. Go to https://console.firebase.google.com
2. Create new project: "toriverse"
3. Select region: Tokyo (asia-northeast1)
4. Enable Firestore, Auth, Analytics, Crashlytics, Remote Config

### Step 1.2: Get Firebase Configuration Files

#### For Android:
1. Go to Firebase Console → Project Settings
2. Download `google-services.json`
3. Place in `android/app/google-services.json`
4. Verify path: `cat android/app/google-services.json`

#### For iOS:
1. Go to Firebase Console → Project Settings
2. Download `GoogleService-Info.plist`
3. Place in `ios/Runner/GoogleService-Info.plist`
4. Add to Xcode: Right-click Runner → Add Files → Select GoogleService-Info.plist
5. Verify "Copy items if needed" is checked

### Step 1.3: Verify Configuration in Code

Ensure `lib/config/firebase_config.dart` references the correct project:

```dart
Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
```

---

## 2. Firestore Security Rules Deployment

### Step 2.1: Review Rules

Check current rules at `/firestore.rules`:

```bash
cat firestore.rules
```

Key rules included:
- ✅ Users: Read/write own documents only
- ✅ Matches: Read by participating players only
- ✅ RoundResults: Write-restricted to Cloud Functions
- ✅ Public leaderboard: Read-only access

### Step 2.2: Deploy Rules to Firebase

```bash
firebase deploy --only firestore:rules
```

**Expected output:**
```
✔  Firestore Rules have been successfully published.
Visit https://console.firebase.google.com/project/toriverse-xxx/firestore/rules to view your rules in the Firebase Console.
```

### Step 2.3: Test Rules (Optional - Firebase Emulator)

```bash
firebase emulators:start
# In another terminal:
firebase emulators:exec "flutter test test/integration/game_flow_test.dart"
```

---

## 3. Cloud Functions Deployment

### Step 3.1: Review Functions

Check current implementation at `/functions/index.js`:

```bash
ls -la functions/
cat functions/index.js | head -50
```

Key functions included:
- `submitMove()` - Server-side move validation
- `validateMove()` - Authoritative board check
- `processBonusLogic()` - Weak bonus & rescue card
- `resolveCollision()` - Same-square random selection
- `generateClip()` - Auto-clip creation
- `scheduledReset()` - Daily free match reset

### Step 3.2: Deploy Cloud Functions

```bash
cd functions
npm install  # Update dependencies if needed
cd ..
firebase deploy --only functions
```

**Expected output:**
```
✔  functions[submitMove]: Successful update operation.
✔  functions[validateMove]: Successful update operation.
✔  functions[processBonusLogic]: Successful update operation.
✔  functions[resolveCollision]: Successful update operation.
✔  functions[generateClip]: Successful update operation.
✔  functions[scheduledReset]: Successful update operation.
```

### Step 3.3: Verify Functions (Optional)

```bash
firebase functions:list
# Should show all 6 functions in active state
```

---

## 4. Freezed Model Code Generation

### Step 4.1: Run Build Runner

```bash
# From project root
flutter pub run build_runner build --delete-conflicting-outputs
```

**Expected output:**
```
[INFO] Building new asset graph completed, took XXXms
[INFO] Running build completed, took XXXms
[INFO] Caching finalized dependency graph completed, took XXXms
[INFO] Succeeded after XXXms with X outputs
```

### Step 4.2: Verify Generated Files

```bash
# Check generated Freezed files
ls -la lib/features/match/data/models/*.freezed.dart
ls -la lib/features/match/data/models/*.g.dart

# Expected files:
# - user_model.freezed.dart
# - user_model.g.dart
# - match_model.freezed.dart
# - match_model.g.dart
# - round_result_model.freezed.dart
# - round_result_model.g.dart
# - rescue_card_model.freezed.dart
# - rescue_card_model.g.dart
# - weak_bonus_model.freezed.dart
# - weak_bonus_model.g.dart
```

### Step 4.3: Verify No Build Errors

```bash
flutter pub get
flutter analyze
# Should show 0 errors
```

---

## 5. Run Tests

### Step 5.1: Unit Tests

```bash
# Run all unit tests
flutter test test/unit/

# Run specific test files
flutter test test/unit/board_test.dart
flutter test test/unit/game_state_test.dart
flutter test test/unit/user_state_test.dart
flutter test test/unit/input_validators_test.dart

# Expected: All tests pass (50%+ coverage)
```

### Step 5.2: Widget Tests

```bash
# Run all widget tests
flutter test test/widget/

# Run specific tests
flutter test test/widget/board_widget_test.dart
flutter test test/widget/home_screen_test.dart
flutter test test/widget/match_screen_test.dart
flutter test test/widget/results_screen_test.dart

# Expected: All tests pass
```

### Step 5.3: Integration Tests

```bash
# Run integration tests
flutter test test/integration/game_flow_test.dart

# Run with verbose output
flutter test -v test/integration/game_flow_test.dart

# Expected: Complete game flow from login to results
```

### Step 5.4: Full Test Coverage Report

```bash
# Run tests with coverage
flutter test --coverage

# Generate HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Verify minimum 50% coverage
grep -oP 'line-rate="\K[0-9.]+' coverage/coverage.xml
# Should show value ≥ 0.50
```

---

## 6. Security Remediations Verification

### Step 6.1: Verify Secure Storage Implementation

```bash
# Check SecureStorageService exists
test -f lib/shared/services/secure_storage_service.dart && echo "✓ Service exists"

# Verify Riverpod provider
grep -q "secureStorageProvider" lib/shared/services/secure_storage_service.dart && echo "✓ Provider exists"
```

### Step 6.2: Verify Input Validators Implementation

```bash
# Check validators exist
test -f lib/shared/validators/input_validators.dart && echo "✓ Validators exist"

# Run validator tests
flutter test test/unit/input_validators_test.dart -v

# Expected: All 50+ validator tests pass
```

### Step 6.3: Verify Firestore Security Rules

```bash
# Test rules in emulator
firebase emulators:start --only firestore &
sleep 5
flutter test test/unit/  # Should respect rules
kill %1
```

### Step 6.4: Verify Cloud Functions Validation

```bash
# Check function implementations
grep -q "function submitMove" functions/index.js && echo "✓ submitMove exists"
grep -q "function validateMove" functions/index.js && echo "✓ validateMove exists"
grep -q "function processBonusLogic" functions/index.js && echo "✓ processBonusLogic exists"
```

---

## 7. Configuration Verification

### Step 7.1: Environment Variables

```bash
# Verify .env exists with Firebase project ID
test -f .env && echo "✓ .env exists"
grep "FIREBASE_PROJECT_ID" .env && echo "✓ FIREBASE_PROJECT_ID set"
grep "REVENUCAT_API_KEY" .env && echo "✓ REVENUCAT_API_KEY set"
```

### Step 7.2: Build Configuration

```bash
# Verify Android build.gradle includes google-services
grep -q "apply plugin: 'com.google.gms.google-services'" android/app/build.gradle && echo "✓ Android configured"

# Verify iOS Podfile includes Firebase
grep -q "firebase" ios/Podfile && echo "✓ iOS configured"
```

### Step 7.3: App Configuration

```bash
# Verify Firebase initialization
grep -q "Firebase.initializeApp" lib/main.dart && echo "✓ Firebase init in main"

# Verify theme configuration
test -f lib/config/theme.dart && echo "✓ Theme configured"

# Verify route configuration  
test -f lib/config/router.dart && echo "✓ Routes configured"
```

---

## 8. Local Testing (Pre-Deployment)

### Step 8.1: Firebase Emulator Suite (Recommended)

```bash
# Start emulator suite
firebase emulators:start

# In another terminal, run tests
flutter test --dart-define=USE_EMULATOR=true test/integration/game_flow_test.dart

# Verify operations (Firestore should show new documents):
# Open http://localhost:4000 in browser
```

### Step 8.2: Build APK/IPA (Local)

```bash
# Android
flutter build apk --debug

# iOS (requires macOS)
flutter build ios --debug --simulator

# Expected: No errors, APK/app bundle builds successfully
```

### Step 8.3: Manual Testing Checklist

- [ ] App launches without crashes
- [ ] User can login
- [ ] User profile displays correctly
- [ ] Free match status shows correctly
- [ ] Can start matching
- [ ] Can make moves on board
- [ ] Move validation works
- [ ] Results screen shows correctly
- [ ] Streak increments
- [ ] Offline mode doesn't crash (if offline cache implemented)

---

## 9. CI/CD Verification

### Step 9.1: Check GitHub Actions Workflow

```bash
# Verify workflow file exists
test -f .github/workflows/analyze_test_build.yml && echo "✓ Workflow configured"

# Check workflow syntax
cat .github/workflows/analyze_test_build.yml | grep "flutter pub get"

# Expected: Should show analyze → test → build jobs
```

### Step 9.2: Trigger Workflow

```bash
# Push to trigger workflow
git add .
git commit -m "Phase 6: Firebase Integration & Testing"
git push origin claude/triverse-development-r2e05a

# Check GitHub Actions tab for:
# ✓ Analyze job: PASS
# ✓ Test job: PASS (50%+ coverage)
# ✓ Build Android: PASS
# ✓ Build iOS: PASS
```

---

## 10. Soft Launch Preparation

### Step 10.1: TestFlight Setup (iOS)

```bash
# Build for TestFlight
flutter build ios --release

# Upload via Xcode or fastlane
cd ios
fastlane beta
cd ..

# Expected: Build uploaded to TestFlight
# Then: Review in App Store Connect → TestFlight → Your App
```

### Step 10.2: Firebase App Distribution Setup (Android)

```bash
# Build AAB for Play Store or APK for Firebase Distribution
flutter build apk --release

# Upload via Firebase CLI
firebase appdistribution:distribute build/app/outputs/flutter-app.apk \
  --app <APP_ID> \
  --release-notes "Development build - Phase 6 complete" \
  --testers-file testers.txt

# Expected: Testers receive notification and can install
```

### Step 10.3: Remote Config Setup

```bash
# Define remote config values in Firebase Console:
# - min_supported_version: "0.1.0"
# - weak_bonus_threshold: 20
# - rescue_card_activation: 2
# - free_match_daily_limit: 1
# - move_submission_timeout_seconds: 30

# Verify in code:
# lib/config/remote_config.dart loads these values
```

### Step 10.4: Analytics & Monitoring

```bash
# Verify Firebase Analytics is enabled
grep -q "firebase_analytics" pubspec.yaml && echo "✓ Analytics enabled"

# Verify key events are defined
grep -q "match_completed" lib/features/match/data/ -r && echo "✓ Events defined"

# Verify Crashlytics is enabled
grep -q "firebase_crashlytics" pubspec.yaml && echo "✓ Crashlytics enabled"
```

---

## 11. Soft Launch Gates (Verification Checklist)

Before soft launch, verify all gates pass:

- [ ] **Day 1 Retention**: Setup complete (measured after launch)
- [ ] **Crash-Free Rate**: 99.5%+ (verify no unhandled exceptions)
- [ ] **Initial Aha**: Can reach first match and reverse in 3 taps
- [ ] **Full Human Match**: 40%+ of matches have 3 human players or AI supplements within 30s
- [ ] **Test Coverage**: 50%+ code coverage achieved
- [ ] **Security Review**: All MEDIUM findings mitigated
- [ ] **Performance**: App load time < 2s on 4G
- [ ] **No Crashes**: Zero uncaught exceptions in manual testing
- [ ] **Analytics**: Events fire without errors
- [ ] **Firebase**: All rules, functions deployed and tested

---

## 12. Deployment Steps (Final)

### Step 12.1: Code Review & Merge

```bash
# Create/update PR
# Get approval from code reviewer
# Merge to main or development branch

# Verify branch is clean
git status
# Should show: "nothing to commit, working tree clean"
```

### Step 12.2: Deploy to Production

```bash
# Deploy Firestore rules to production
firebase deploy --only firestore:rules --project toriverse-prod

# Deploy Cloud Functions to production
firebase deploy --only functions --project toriverse-prod

# Deploy Remote Config
firebase remoteconfig:publish --project toriverse-prod

# Verify deployment
firebase functions:list --project toriverse-prod
```

### Step 12.3: Monitor After Deployment

```bash
# Check Firestore realtime database in console
# Check Cloud Functions error logs:
firebase functions:log --limit 100 --project toriverse-prod

# Check Analytics
# Check Crashlytics for any new errors
# Check Remote Config versions deployed

# Expected: No errors, all functions working
```

---

## 13. Troubleshooting

### Issue: "Flutter version not found"
**Solution**: Remove version pinning from GitHub Actions workflow
```bash
# Change from:
# flutter-version: '3.4.x'
# To:
# Just use: channel: stable
```

### Issue: "google-services.json not found"
**Solution**: Download from Firebase Console and place in android/app/
```bash
ls android/app/google-services.json
# Should exist
```

### Issue: "GoogleService-Info.plist not found"
**Solution**: Download from Firebase Console and add to Xcode
```bash
ls ios/Runner/GoogleService-Info.plist
# Should exist
```

### Issue: "Firestore security rules reject request"
**Solution**: Check rules allow authenticated users
```bash
firebase emulators:start --only firestore
# Test with valid UID in debug console
```

### Issue: "Cloud Function timeout"
**Solution**: Increase timeout in functions/index.js
```bash
functions.runWith({
  timeoutSeconds: 540,  // Increase from default 60s
}).https.onCall(...)
```

### Issue: "Test coverage < 50%"
**Solution**: Add tests for uncovered code paths
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # View uncovered lines
```

---

## 14. Completion Checklist

**Phase 6 is complete when:**

- [x] Firebase configuration files in place (google-services.json, GoogleService-Info.plist)
- [x] Firestore security rules deployed and tested
- [x] Cloud Functions deployed and tested
- [x] Freezed model code generated (no placeholder files)
- [x] Unit tests pass (50%+ coverage)
- [x] Widget tests pass
- [x] Integration tests pass
- [x] Input validators implemented and tested
- [x] Secure storage service implemented
- [x] Security review findings mitigated
- [x] GitHub Actions CI/CD passing
- [x] App builds successfully (APK/IPA)
- [x] Manual testing complete (all major flows work)
- [x] Soft launch gates verified
- [x] PR merged and deployed

---

**Next Phase**: Phase 7 - Soft Launch (TestFlight/Firebase App Distribution)

**Estimated Time**: 6-8 hours  
**Created**: 2026-08-27  
**Last Updated**: —
