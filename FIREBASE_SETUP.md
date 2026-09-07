# Firebase Setup Guide for トリバース

This document provides step-by-step instructions for setting up Firebase for local development and deployment.

## Prerequisites

- Firebase CLI: `npm install -g firebase-tools`
- Google Cloud Project or Firebase Project
- Firebase Console access (https://console.firebase.google.com)
- Xcode 15+ (for iOS)
- Android Studio 2023.1+ (for Android)

## Step 1: Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click "Add project"
3. Enter project name: `toriverse-project` (or your preferred name)
4. Enable Google Analytics (optional but recommended)
5. Complete project creation

## Step 2: Register Apps

### iOS App
1. In Firebase Console, click "Add app" → Select iOS
2. Bundle ID: `com.example.toriverse` (update in Xcode if different)
3. Download `GoogleService-Info.plist`
4. Open iOS project in Xcode: `open ios/Runner.xcworkspace`
5. Drag `GoogleService-Info.plist` into Xcode (select "Copy items if needed")
6. Ensure it's added to "Runner" target

### Android App
1. In Firebase Console, click "Add app" → Select Android
2. Package name: `com.example.toriverse` (match `android/app/build.gradle`)
3. SHA-1 certificate fingerprint:
   ```bash
   # Get debug SHA-1
   ./gradlew signingReport
   # Look for "SHA1" value under "debugAndroidTest" and "debug"
   ```
4. Download `google-services.json`
5. Place in: `android/app/google-services.json`

## Step 3: Configure Authentication

### Google Sign-In

#### Android
1. In Firebase Console → Authentication → Sign-in method
2. Enable "Google"
3. Note the Web Client ID
4. No additional Android-specific config needed (handled via Firebase)

#### iOS
1. In Firebase Console → Authentication → Sign-in method
2. Enable "Google"
3. Get iOS Client ID from Firebase Console settings
4. In Xcode:
   - Select "Runner" → "Info" tab
   - Add URL Types:
     - Identifier: `com.google.iOS.SignIn`
     - URL Scheme: `com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID`
5. Replace `YOUR_REVERSED_CLIENT_ID` with the reverse of your iOS Client ID from Firebase

### Apple Sign-In

#### iOS Only
1. In Xcode: Select "Runner" → "Signing & Capabilities"
2. Click "+ Capability" → Search "Sign in with Apple"
3. Add capability
4. Select a team with an Apple Developer Program membership
5. In Firebase Console → Authentication → Sign-in method
6. Enable "Apple"
7. Skip Bundle ID configuration (Firebase will handle it)

## Step 4: Configure Firestore

1. Firebase Console → Firestore Database
2. Click "Create database"
3. Select region: `asia-northeast1` (Tokyo, closest to Japan)
4. Start in test mode (we'll secure in Step 5)
5. Wait for database to be ready

## Step 5: Deploy Security Rules

The security rules are in `firestore.rules`. Deploy them:

```bash
# First, initialize Firebase project locally
firebase init firestore

# When prompted, use existing firestore.rules file

# Deploy rules
firebase deploy --only firestore:rules
```

**Important:** Test rules verify all access patterns match your app's intended behavior.

## Step 6: Update firebase_options.dart

Update `lib/config/firebase_options.dart` with your project credentials:

```bash
# Get project credentials
firebase login
firebase init

# Option 1: Use flutterfire CLI (easiest)
flutterfire configure --project=toriverse-project

# Option 2: Manual configuration
# Copy from Firebase Console → Project Settings → Your apps
```

If using `flutterfire configure`:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This will automatically update `firebase_options.dart`.

## Step 7: Enable Required Firebase Services

In Firebase Console, ensure these are enabled:

1. **Authentication** ✓
2. **Firestore Database** ✓
3. **Cloud Storage** (for future features)
4. **Cloud Functions** (for game logic validation)
5. **Analytics** (for KPI tracking)
6. **Crashlytics** (for error tracking)
7. **Remote Config** (for feature toggles)

## Step 8: Local Testing

### iOS
```bash
# Install dependencies
flutter pub get

# Build iOS
flutter build ios --debug

# Run on simulator
open -a Simulator
flutter run
```

### Android
```bash
# Ensure Android emulator is running
flutter emulators launch Pixel_4_API_30

# Run app
flutter run
```

## Step 9: Verify Authentication Works

1. Launch app
2. On auth screen, tap "Googleでログイン" or "Appleでログイン"
3. Complete OAuth flow
4. Verify you're redirected to home screen

## Step 10: Test Firestore Access

Once authenticated:

1. Open Firebase Console → Firestore Database
2. Click "+ Start collection"
3. Create test collection to verify read/write access
4. In app, any user-read operation should work

## Troubleshooting

### "Could not establish connection" / Firebase not initializing
- Verify `firebase_options.dart` has correct credentials
- Check `lib/main.dart` calls `initializeFirebase()` before `runApp()`
- Restart app after credential updates

### Google Sign-In not working
- Verify SHA-1 certificate fingerprint is registered
- Check bundle ID matches Firebase configuration
- On iOS, verify URL Scheme is set correctly

### Apple Sign-In fails
- Ensure Apple Developer Program membership
- Verify signing team is set in Xcode
- Check Apple Sign-In capability is added to target

### Firestore rules rejecting writes
- Check browser console or app logs for specific rule violations
- Compare app's submission structure to rules' expected format
- Test with `firebase emulator:start` locally first

### OAuth redirect loop
- Check auth provider configuration matches Firebase settings
- Verify redirect URIs are registered
- Check for typos in client IDs

## Remote Config Setup (Optional but Recommended)

For feature toggles and A/B testing:

1. Firebase Console → Remote Config
2. Click "Create Configuration"
3. Add parameters for:
   - `submission_timeout_ms`: 30000 (default submission window)
   - `weak_bonus_threshold_pct`: 20 (bottom 20% get bonus)
   - `min_supported_version`: 1.0.0
   - `free_match_daily_limit`: 1

These can be dynamically updated without app release.

## Deployment to Production

Before soft launch:

1. Switch from test mode to production rules
2. Set up proper billing alerts
3. Configure Cloud Functions for game validation
4. Enable Crashlytics monitoring
5. Create Remote Config production parameters
6. Test end-to-end flow with testflight/internal testing

## Next Steps

After Firebase setup is complete:

1. Run full test suite: `flutter test`
2. Complete feature implementation (Cloud Functions, etc.)
3. Prepare TestFlight distribution
4. Set up GitHub Actions CI/CD

## Reference Documentation

- [Firebase Flutter Setup](https://firebase.flutter.dev/)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/start)
- [Firebase Authentication](https://firebase.google.com/docs/auth)

---

**Note:** Keep `google-services.json` and `GoogleService-Info.plist` out of version control. Add to `.gitignore` if not already present.
