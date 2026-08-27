# Phase 7: Soft Launch Preparation - Complete Guide

**Status**: 🚀 SOFT LAUNCH PHASE  
**Date**: 2026-08-27  
**Target**: TestFlight (iOS) + Firebase App Distribution (Android)  
**Timeline**: 2-3 weeks to launch

---

## 1. Firebase Project Configuration

### 1.1 Create/Configure Firebase Project

```bash
# Initialize Firebase (if not done)
firebase init

# Or use existing project
firebase projects:list
firebase use toriverse-prod  # Set active project
```

### 1.2 Enable Required Services

In Firebase Console (https://console.firebase.google.com):

1. **Authentication**
   - [ ] Enable Email/Password
   - [ ] Enable Google Sign-In
   - [ ] Enable Apple Sign-In (iOS)

2. **Firestore Database**
   - [ ] Create database (asia-northeast1)
   - [ ] Start in production mode
   - [ ] Deploy security rules (see below)

3. **Analytics**
   - [ ] Enable Google Analytics
   - [ ] Link to BigQuery (optional, for data export)

4. **Crashlytics**
   - [ ] Enable Crash Reporting
   - [ ] Set notification email (your-email@example.com)

5. **Remote Config**
   - [ ] Create default config values
   - [ ] Define A/B test parameters (if using)

6. **Cloud Functions**
   - [ ] Deploy functions (see below)
   - [ ] Set up error alerting

7. **Cloud Storage**
   - [ ] Create bucket for clip/video storage
   - [ ] Configure CORS for clip sharing

### 1.3 Download Firebase Configuration Files

**Android:**
```bash
# In Firebase Console → Project Settings → General
# Download google-services.json and place in:
# android/app/google-services.json

# Verify
ls -la android/app/google-services.json
cat android/app/google-services.json | jq .
```

**iOS:**
```bash
# In Firebase Console → Project Settings → General
# Download GoogleService-Info.plist and place in:
# ios/Runner/GoogleService-Info.plist

# Add to Xcode:
# 1. Right-click Runner → Add Files
# 2. Select GoogleService-Info.plist
# 3. Check "Copy items if needed"
# 4. Verify in Xcode Build Phases

# Verify file exists
ls -la ios/Runner/GoogleService-Info.plist
```

### 1.4 Configure Environment Variables

```bash
# Create .env file (excluded from git)
cat > .env << EOF
FIREBASE_PROJECT_ID=toriverse-prod
FIREBASE_API_KEY=AIzaSy...  # From Firebase Console
REVENUCAT_API_KEY=appl_...   # From RevenueCat Console
GOOGLE_MOBILE_ADS_APP_ID=ca-app-pub-... # From Google AdMob
EOF

# Verify .env is in .gitignore
grep "^\.env$" .gitignore
```

---

## 2. Firestore Security Rules Deployment

### 2.1 Review & Validate Rules

```bash
# Check current rules
cat firestore.rules | head -50

# Key rules to verify:
# - Users: Read/write own only
# - Matches: Read by participants
# - RoundResults: Write-restricted to Cloud Functions
# - Leaderboard: Public read-only
```

### 2.2 Deploy Rules to Production

```bash
# Deploy to production
firebase deploy --only firestore:rules --project toriverse-prod

# Verify deployment
firebase firestore:inspect --project toriverse-prod
```

### 2.3 Test Rules (Firebase Emulator)

```bash
# Start emulator
firebase emulators:start --only firestore

# In another terminal, run tests
flutter test test/unit/ --dart-define=USE_EMULATOR=true

# Verify:
# - User cannot read other user's data
# - Match participants can read match
# - Non-participants cannot read match
```

---

## 3. Cloud Functions Deployment

### 3.1 Review Functions Code

```bash
# Check functions
ls -la functions/
cat functions/index.js | grep "exports\." 

# Expected functions:
# - submitMove
# - validateMove
# - processBonusLogic
# - resolveCollision
# - generateClip
# - scheduledReset
```

### 3.2 Install Dependencies

```bash
cd functions
npm install
npm audit fix  # Fix security issues
cd ..
```

### 3.3 Deploy Functions

```bash
firebase deploy --only functions --project toriverse-prod

# Expected output:
# ✔  functions[submitMove]: Successful update operation.
# ✔  functions[validateMove]: Successful update operation.
# ✔  functions[processBonusLogic]: Successful update operation.
# ✔  functions[resolveCollision]: Successful update operation.
# ✔  functions[generateClip]: Successful update operation.
# ✔  functions[scheduledReset]: Successful update operation.
```

### 3.4 Monitor Function Logs

```bash
# View logs
firebase functions:log --limit 50 --project toriverse-prod

# Watch real-time logs
firebase functions:log --follow --project toriverse-prod
```

---

## 4. Remote Config Setup

### 4.1 Define Config Values

In Firebase Console → Remote Config, create:

```json
{
  "min_supported_version": {
    "defaultValue": "0.1.0",
    "description": "Minimum app version to use"
  },
  "weak_bonus_threshold": {
    "defaultValue": 20,
    "description": "Stone deficit threshold for weak bonus (%)"
  },
  "rescue_card_activation": {
    "defaultValue": 2,
    "description": "Consecutive attacks to trigger rescue card"
  },
  "free_match_daily_limit": {
    "defaultValue": 1,
    "description": "Daily free matches per user"
  },
  "move_submission_timeout_seconds": {
    "defaultValue": 30,
    "description": "Time window for move submission (seconds)"
  },
  "ai_difficulty": {
    "defaultValue": "normal",
    "description": "AI difficulty level (easy, normal, hard)"
  },
  "enable_analytics": {
    "defaultValue": true,
    "description": "Enable analytics tracking"
  }
}
```

### 4.2 Publish Config

```bash
firebase remoteconfig:publish --project toriverse-prod
```

### 4.3 Integrate in Code

In `lib/config/remote_config_manager.dart`:

```dart
class RemoteConfigManager {
  static final _instance = RemoteConfigManager._internal();
  late RemoteConfig _remoteConfig;

  RemoteConfigManager._internal();

  factory RemoteConfigManager() => _instance;

  Future<void> initialize() async {
    _remoteConfig = RemoteConfig.instance;
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await _remoteConfig.fetchAndActivate();
  }

  int get weakBonusThreshold => 
    _remoteConfig.getInt('weak_bonus_threshold');
  
  int get rescueCardActivation => 
    _remoteConfig.getInt('rescue_card_activation');
  
  int get moveSubmissionTimeout => 
    _remoteConfig.getInt('move_submission_timeout_seconds');
}
```

---

## 5. Analytics & Tracking Setup

### 5.1 Define Key Events

In Firebase Console → Analytics:

1. **match_completed**
   ```
   Event: match_completed
   Parameters:
   - match_duration (seconds)
   - player_count (int)
   - had_weak_bonus (bool)
   - had_rescue_card (bool)
   - player_placement (1, 2, or 3)
   ```

2. **full_human_match_started**
   ```
   Event: full_human_match_started
   Parameters:
   - timestamp (datetime)
   ```

3. **weak_bonus_triggered**
   ```
   Event: weak_bonus_triggered
   Parameters:
   - stone_deficit (int)
   - round_number (int)
   ```

4. **rescue_card_used**
   ```
   Event: rescue_card_used
   Parameters:
   - consecutive_attacks (int)
   ```

5. **clip_shared**
   ```
   Event: clip_shared
   Parameters:
   - platform (string: twitter, instagram, tiktok)
   - match_id (string)
   ```

6. **rankpass_converted**
   ```
   Event: rankpass_converted
   Parameters:
   - conversion_day (int)
   - user_cohort (string: day1, day7, day30)
   ```

### 5.2 Implement Event Tracking

```dart
class AnalyticsManager {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> trackMatchCompleted({
    required int duration,
    required int playerCount,
    required bool hadWeakBonus,
    required bool hadRescueCard,
    required int placement,
  }) async {
    await _analytics.logEvent(
      name: 'match_completed',
      parameters: {
        'match_duration': duration,
        'player_count': playerCount,
        'had_weak_bonus': hadWeakBonus,
        'had_rescue_card': hadRescueCard,
        'player_placement': placement,
      },
    );
  }

  Future<void> trackClipShared({
    required String platform,
    required String matchId,
  }) async {
    await _analytics.logEvent(
      name: 'clip_shared',
      parameters: {
        'platform': platform,
        'match_id': matchId,
      },
    );
  }
}
```

### 5.3 Set Up Cohort Analysis

In Firebase Console → Analytics → Cohorts:

1. **Day 1 Retention** - Users active on day 2
2. **Day 7 Retention** - Users active on day 8
3. **Day 30 Retention** - Users active on day 31
4. **Free → Paid Converters** - Users who purchased subscription
5. **Weak Bonus Users** - Users who triggered weak bonus

---

## 6. Crashlytics Setup

### 6.1 Enable Crash Reporting

```bash
# Already configured in pubspec.yaml
grep firebase_crashlytics pubspec.yaml
```

### 6.2 Configure Crash Notifications

In Firebase Console → Crashlytics:

1. Create new alert rule:
   - Condition: New crashes
   - Notification: Email to team
   - Test: Force a crash to verify

2. Create severity threshold:
   - Condition: Crash count > 10 in 1 hour
   - Notification: Urgent Slack notification

### 6.3 Test Crash Reporting

```dart
// In debug build, test crash reporting
FirebaseCrashlytics.instance.crash();
```

---

## 7. Freezed Code Generation

### 7.1 Generate Model Code

```bash
# From project root
flutter pub run build_runner build --delete-conflicting-outputs

# Expected output:
# [INFO] Building new asset graph...
# [INFO] Running build completed, took XXXms
# [INFO] Succeeded after XXXms with X outputs
```

### 7.2 Verify Generated Files

```bash
# Check all generated files exist
ls -la lib/features/match/data/models/*.freezed.dart
ls -la lib/features/match/data/models/*.g.dart

# Should have:
# - user_model.freezed.dart / .g.dart
# - match_model.freezed.dart / .g.dart
# - round_result_model.freezed.dart / .g.dart
# - rescue_card_model.freezed.dart / .g.dart
# - weak_bonus_model.freezed.dart / .g.dart
```

### 7.3 Verify No Build Errors

```bash
flutter pub get
flutter analyze

# Should show 0 errors, 0 warnings (ideally)
```

---

## 8. Complete Test Execution

### 8.1 Unit Tests

```bash
flutter test test/unit/ -v

# Expected: All 165+ tests pass
# Coverage: Each test category has >80% coverage
```

### 8.2 Widget Tests

```bash
flutter test test/widget/ -v

# Expected: All 40+ tests pass
# Coverage: All screens and widgets tested
```

### 8.3 Integration Tests

```bash
flutter test test/integration/game_flow_test.dart -v

# Expected: Complete game flow works end-to-end
# Scenarios: Login → Matching → Playing → Results
```

### 8.4 Generate Coverage Report

```bash
flutter test --coverage

# Verify coverage ≥ 50%
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
# or
xdg-open coverage/html/index.html  # Linux
```

---

## 9. Pre-Launch Build & Testing

### 9.1 Build Android APK/AAB

```bash
# Clean build
flutter clean

# Build APK for testing
flutter build apk --release

# Build AAB for Play Store
flutter build appbundle --release

# Verify artifacts
ls -lh build/app/outputs/flutter-app.apk
ls -lh build/app/outputs/bundle/release/app-release.aab
```

### 9.2 Build iOS IPA

```bash
# Clean and build
flutter clean
flutter build ios --release

# Build IPA for TestFlight
cd ios
fastlane build_ipa
cd ..

# Verify
ls -lh build/ios/ipa/
```

### 9.3 Manual Testing Checklist

**On Device/Emulator:**

- [ ] App launches without crashes
- [ ] Firebase initialization succeeds
- [ ] User can sign up with email
- [ ] User can login
- [ ] User profile displays correctly
- [ ] Free match quota shows
- [ ] Can start matching
- [ ] Board displays correctly
- [ ] Can make moves
- [ ] Move validation works
- [ ] Results screen displays
- [ ] Streak increments
- [ ] Analytics events fire (check Logcat/Console)
- [ ] Crashlytics initialized (check logs)

---

## 10. TestFlight Setup (iOS)

### 10.1 Configure App Store Connect

```bash
# Create bundle ID if not exists
# App ID: com.zkaz.toriverse

# In App Store Connect:
1. Create new app
2. Set bundle ID: com.zkaz.toriverse
3. Set iOS minimum version: 13.0+
4. Add app icon (1024x1024)
5. Add screenshots (device sizes)
6. Add app description (日本語)
```

### 10.2 Set Up Signing Certificates

```bash
# Use Xcode to manage signing
# In Xcode → Runner → Build Settings:
1. Team ID: Set to your Apple Developer Team
2. Bundle Identifier: com.zkaz.toriverse
3. Signing Certificate: Development & Distribution

# Or use fastlane
fastlane match development
fastlane match appstore
```

### 10.3 Deploy to TestFlight

```bash
cd ios
fastlane beta

# fastlane will:
# 1. Build IPA
# 2. Upload to App Store Connect
# 3. Submit to TestFlight
# 4. Notify testers

cd ..
```

### 10.4 Invite Testers

In App Store Connect → TestFlight:
1. Add internal testers (yourself)
2. Add external testers (up to 10,000)
3. Send invitations
4. Testers install via TestFlight app

---

## 11. Firebase App Distribution (Android)

### 11.1 Configure Distribution

```bash
# In Firebase Console → App Distribution:
1. Create distribution group
2. Add tester email addresses
3. Download service account JSON
```

### 11.2 Deploy APK

```bash
# Build release APK
flutter build apk --release

# Upload to Firebase App Distribution
firebase appdistribution:distribute build/app/outputs/flutter-app.apk \
  --app <FIREBASE_APP_ID> \
  --release-notes "Phase 7 Soft Launch" \
  --testers-file testers.txt

# testers.txt format:
# tester1@example.com
# tester2@example.com
```

### 11.3 Tester Installation

Testers will:
1. Receive email invitation
2. Click link → Accept invitation
3. Download & install via Firebase App Distribution link
4. Test on device

---

## 12. Soft Launch Gates Verification

### 12.1 Gate Checklist

Before promoting to wider audience, verify:

- [ ] **App Stability**: Crash-free rate > 99.5%
- [ ] **Aha Moment**: 60%+ users reach first match with reverse
- [ ] **3-Player Matches**: 40%+ of matches have 3 human players (or AI backup)
- [ ] **Day 1 Retention**: Measure after 24-48 hours
- [ ] **Performance**: App load time < 2 seconds
- [ ] **Analytics**: Events firing correctly
- [ ] **No Critical Bugs**: No show-stoppers from tester feedback
- [ ] **Monetization**: RevenueCat integration working
- [ ] **Offline Mode**: Works without connectivity (if implemented)

### 12.2 Monitoring Dashboard

In Firebase Console:

1. **Crashlytics** → Dashboard
   - Crash-free users: Should be 99.5%+
   - Top crashes: Should be zero or minor

2. **Analytics** → Real-time
   - Active users
   - Event tracking
   - User cohorts

3. **Performance** → Traces
   - App startup time
   - Custom traces (game loading, move processing)

---

## 13. Post-Launch Monitoring

### 13.1 Daily Check-In Schedule

**Day 1 (Launch)**
- [ ] Check Crashlytics every 1 hour
- [ ] Monitor top crashes
- [ ] Check analytics events firing
- [ ] Review user feedback (if available)
- [ ] Check server logs for errors

**Days 2-7**
- [ ] Daily check Crashlytics
- [ ] Review analytics metrics
- [ ] Monitor retention cohorts
- [ ] Check RevenueCat conversions
- [ ] Address any critical bugs

**Ongoing (Week 2+)**
- [ ] Weekly Crashlytics review
- [ ] Bi-weekly analytics analysis
- [ ] Monthly performance review
- [ ] Remote Config adjustments based on data

### 13.2 Alerting Rules

Set up automated alerts in Firebase:

1. **Crash Rate Alert**: > 0.5% → Immediate notification
2. **New Crash Type**: Any unhandled exception → Slack notification
3. **High Error Rate**: > 10 errors/hour → Page on-call
4. **Performance Degradation**: Startup time > 3s → Investigation

### 13.3 Analytics Dashboard Setup

Create custom dashboard in Firebase Analytics:

```
Dashboard: "Toriverse Soft Launch"
Cards:
1. Daily Active Users (DAU)
2. Day 1/7/30 Retention
3. Match Completion Rate
4. Weak Bonus Activation Rate
5. Rescue Card Usage
6. Clip Share Rate
7. Free → Paid Conversion
8. Average Session Duration
9. Top Crashes
10. Crash-Free Users %
```

---

## 14. Iterative Improvement Plan

### 14.1 A/B Testing (Optional, Phase 7+)

If metrics are below target, use Remote Config for A/B tests:

```
Test 1: Weak Bonus Threshold
- Control: 20%
- Variant A: 25%
- Variant B: 15%
→ Measure: Retention impact
```

### 14.2 Remote Config Adjustments

Based on metrics:
- Adjust weak bonus threshold if skewed
- Adjust rescue card activation frequency
- Adjust AI difficulty
- Adjust free match limit (if retention is low)

### 14.3 Bug Fix Deployment

For critical bugs:
1. Fix code
2. Run full test suite
3. Build new APK/IPA
4. Deploy to Firebase App Distribution / TestFlight
5. Increment version in `pubspec.yaml`
6. Update release notes
7. Monitor crash rate after deployment

---

## 15. Soft Launch Success Criteria

### 15.1 Technical Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Crash-free rate | > 99.5% | Crashlytics |
| App startup time | < 2s | Performance traces |
| Average session duration | > 5 min | Analytics |
| Match completion rate | > 80% | Custom events |

### 15.2 User Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Day 1 Retention | > 25% | Analytics cohorts |
| Day 7 Retention | > 15% | Analytics cohorts |
| Day 30 Retention | > 8% | Analytics cohorts |
| Full human match rate | > 40% | Custom events |
| Weak bonus activation | > 30% | Custom events |

### 15.3 Revenue Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Free → Paid conversion | > 3% | RevenueCat |
| ARPPU (avg revenue per paying user) | > ¥300 | RevenueCat |
| Free match usage | > 80% | Custom events |

---

## 16. Soft Launch to General Availability Plan

### 16.1 Success Scenario (Metrics ✅)

If soft launch metrics exceed targets:

1. **Week 2**: Expand to 10% of target users
2. **Week 3**: Expand to 50% of target users
3. **Week 4**: Full launch (ASO optimization, press release)

### 16.2 Moderate Scenario (Some Concerns)

If some metrics below target but critical path works:

1. **Week 2**: Maintain tester group, iterate on weak points
2. **Week 3**: Release Remote Config changes
3. **Week 4**: Soft launch to broader group

### 16.3 Failed Scenario (Critical Issues)

If crash rate > 2% or core feature broken:

1. **Immediate**: Rollback to previous version
2. **Within 24h**: Publish fix to TestFlight/Firebase Distribution
3. **Re-test**: Verify fix before re-launching
4. **Post-mortem**: Document what went wrong

---

## 17. Launch Day Checklist

**24 Hours Before:**
- [ ] Run all tests one final time
- [ ] Verify Firebase configuration
- [ ] Check Remote Config values
- [ ] Prepare release notes
- [ ] Brief team on monitoring plan

**1 Hour Before:**
- [ ] Final APK/IPA build
- [ ] Verify build artifacts
- [ ] Test download links
- [ ] Prepare status page
- [ ] Notify testers

**Launch Time:**
- [ ] Upload APK to Firebase App Distribution
- [ ] Upload IPA to TestFlight
- [ ] Send invitations to testers
- [ ] Start monitoring dashboard
- [ ] Begin check-in schedule

**After Launch:**
- [ ] Check Crashlytics every 30 minutes
- [ ] Monitor analytics real-time
- [ ] Respond to tester feedback
- [ ] Prepare quick-fix if needed

---

## 18. Completion Checklist

**Phase 7 Complete When:**

- [x] Firebase project fully configured
- [x] Firestore rules deployed and tested
- [x] Cloud Functions deployed and tested
- [x] Remote Config published
- [x] Analytics events implemented
- [x] Crashlytics configured and monitored
- [x] Freezed code generated (no placeholders)
- [x] All tests passing (225+)
- [x] Manual testing checklist complete
- [x] TestFlight setup complete
- [x] Firebase App Distribution setup complete
- [x] Soft launch gates verified
- [x] Monitoring dashboard configured
- [x] Alerting rules set up
- [x] Team briefed on launch plan
- [x] Release notes prepared
- [x] First builds uploaded to platforms
- [x] Testers invited and ready

---

**Next Phase**: **General Availability (GA) & Phase 2 Planning**

**Estimated Time**: 2-3 weeks  
**Created**: 2026-08-27  
**Status**: 🚀 Ready to Launch
