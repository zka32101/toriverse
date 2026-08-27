# Security Remediations - Phase 6 Implementation

This document tracks the implementation of security findings from the OWASP MASVS L2 security review (Phase 4.4). All MEDIUM and LOW priority items are addressed during Phase 6.

---

## HIGH Priority (Mitigated by Server-Side Validation)

### Finding #1: Weak Client-Side Move Validation
**Status**: ✅ MITIGATED  
**Mitigation**: All move validation occurs server-side in Cloud Functions (`validateMove()`). Client accepts only valid moves from server response.  
**Evidence**: `functions/index.js` - `validateMove()` function performs authoritative board state check before accepting move.

---

## MEDIUM Priority (Implementation Required)

### Finding #2: Insecure Storage of Authentication Tokens
**Status**: 🔧 IMPLEMENTING  
**Risk**: Firebase Auth tokens stored in plain SharedPreferences (Android) or UserDefaults (iOS)  
**Solution**: Use `flutter_secure_storage` plugin for platform-native secure storage

#### Implementation Steps:
1. Add dependency to `pubspec.yaml`:
   ```yaml
   flutter_secure_storage: ^9.0.0
   ```

2. Create `lib/shared/services/secure_storage_service.dart`:
   - Wrapper around `flutter_secure_storage`
   - Methods: `saveToken()`, `getToken()`, `deleteToken()`, `clearAll()`
   - Platform-specific configuration (Keychain for iOS, Keystore for Android)

3. Update Firebase auth flow in `lib/features/auth/data/repositories/auth_repository.dart`:
   - Store ID token after successful login: `await secureStorage.saveToken(idToken)`
   - Retrieve token on app startup for auto-login
   - Delete token on logout: `await secureStorage.deleteToken()`

4. Keychain Configuration (iOS):
   - Update `ios/Runner/Info.plist`:
   ```xml
   <key>NSFaceIDUsageDescription</key>
   <string>Allow face recognition for secure authentication</string>
   ```

5. Keystore Configuration (Android):
   - No additional configuration required; `flutter_secure_storage` uses AndroidKeyStore by default

#### Files to Create/Update:
- [ ] `lib/shared/services/secure_storage_service.dart` (new)
- [ ] `lib/features/auth/data/repositories/auth_repository.dart` (update)
- [ ] `pubspec.yaml` (add dependency)
- [ ] `ios/Runner/Info.plist` (add permission)

#### Test Coverage:
- Unit test: `test/unit/secure_storage_service_test.dart`
- Mock secure storage for unit tests
- Integration test: Verify token persistence across app restart

---

### Finding #3: Missing Certificate Pinning
**Status**: 🔧 RECOMMENDED  
**Risk**: MEDIUM (Recommended but not blocking MVP)  
**Solution**: Use `flutter_http_client` or native pinning for Firebase

#### Implementation Steps (Optional for Phase 6, Required for Production):
1. Add dependency to `pubspec.yaml`:
   ```yaml
   http: ^1.1.0
   ```

2. Create `lib/shared/services/pinned_http_client.dart`:
   - Configure certificate pinning for Firebase domains
   - Pin Google's root certificates or Firebase-specific certs
   - Android: Use Network Security Configuration
   - iOS: Use `ServerTrustPolicy` from `flutter_http_client`

3. Update Firestore client initialization:
   ```dart
   // Use pinned HTTP client for all Firestore requests
   ```

#### Files to Create/Update (Phase 6+):
- [ ] `lib/shared/services/pinned_http_client.dart` (new)
- [ ] `android/app/src/main/res/xml/network_security_config.xml` (new)

#### Production Deployment:
- This should be implemented before production release
- Test with Certificate Transparency (CT) logs
- Pin 2 certificates (primary + backup) to avoid breakage

---

## LOW Priority (Implementation Required)

### Finding #4: Insufficient Client-Side Input Validation
**Status**: 🔧 IMPLEMENTING  
**Risk**: Low (Server validates all input, but client-side UX improvement)  
**Solution**: Add comprehensive input validation before sending to server

#### Implementation Steps:
1. Create `lib/shared/validators/input_validators.dart`:
   - `validateBoardPosition(int row, int col)` - Ensure 0-63 bounds
   - `validateDisplayName(String name)` - Alphanumeric + underscore, 1-32 chars
   - `validateUid(String uid)` - UUID format validation
   - `validateMoveSubmission(Move move)` - Check move is in valid set

2. Update UI widgets to validate before submission:
   - `board_widget.dart`: Validate position before calling `placeStone()`
   - `move_submission_panel.dart`: Validate move count > 0 before enable button
   - `home_screen.dart`: Validate display name length in settings

3. Add error feedback UI:
   - Show toast/snackbar for invalid input
   - Disable buttons when input invalid
   - Clear errors when user corrects input

#### Files to Create/Update:
- [ ] `lib/shared/validators/input_validators.dart` (new)
- [ ] `lib/features/match/presentation/widgets/board_widget.dart` (update)
- [ ] `lib/features/match/presentation/widgets/move_submission_panel.dart` (update)
- [ ] `lib/features/home/presentation/screens/home_screen.dart` (update)

#### Test Coverage:
- Unit tests: `test/unit/input_validators_test.dart` (boundary cases)
- Widget tests: Verify invalid inputs are rejected by UI
- Integration test: Verify validation across entire game flow

---

### Finding #5: No Request Rate Limiting (Client-Side)
**Status**: ⚠️ DOCUMENTED  
**Risk**: Low (Server enforces limits, but client-side throttling improves UX)  
**Solution**: Implement debouncing for rapid move submissions

#### Implementation:
- Use `flutter_riverpod`'s built-in debounce mechanism in `gameStateProvider`
- Throttle move submission to 1 per second (server allows 30s window anyway)
- Visual feedback: Disable submit button for 1s after successful submission

#### Files to Update:
- [ ] `lib/features/match/application/providers/game_state.dart` (add debouncing)
- [ ] `lib/features/match/presentation/widgets/move_submission_panel.dart` (disable button)

---

### Finding #6: Minimal Error Messaging (Security Through Obscurity)
**Status**: ✅ ACCEPTABLE  
**Risk**: Low  
**Status**: Currently, error messages are generic ("Move validation failed")  
**Decision**: Keep generic messages in production; detailed logs only in debug mode

#### Implementation:
- Firestore security rules return minimal error info to client
- Cloud Functions catch exceptions and return sanitized error codes
- Client log detailed errors only in debug mode: `assert(print(error))`

---

### Finding #7: Missing Rate Limit Headers Validation
**Status**: ✅ DOCUMENTED  
**Risk**: Low  
**Decision**: Firebase handles rate limiting; no client-side action needed

---

## Summary of Phase 6 Security Work

| Finding | Priority | Status | Effort | Owner |
|---------|----------|--------|--------|-------|
| Secure Token Storage | MEDIUM | 🔧 IMPLEMENTING | 4h | Dev |
| Certificate Pinning | MEDIUM | 📋 RECOMMENDED | 6h | Dev (Phase 6+) |
| Input Validation | LOW | 🔧 IMPLEMENTING | 3h | Dev |
| Rate Limiting | LOW | ⚠️ DOCUMENTED | 1h | Dev |
| Error Messaging | LOW | ✅ ACCEPTABLE | 0h | N/A |
| Limit Headers | LOW | ✅ DOCUMENTED | 0h | N/A |

---

## Deployment Checklist (Before Soft Launch)

- [ ] Secure storage service implemented and tested
- [ ] Auth tokens stored securely (no plain SharedPreferences)
- [ ] Input validation implemented across UI
- [ ] Error messages sanitized (no sensitive info)
- [ ] Firestore security rules deployed (row-level access control)
- [ ] Cloud Functions deployed with server-side validation
- [ ] Firebase configuration files (google-services.json, GoogleService-Info.plist) deployed
- [ ] Crashlytics and Analytics enabled for production monitoring
- [ ] Security headers verified (HTTPS, CORS, X-Frame-Options)
- [ ] Certificate pinning (optional but recommended before public release)

---

## References

- OWASP MASVS L2 Standard: https://mobile-security.gitbook.io/mobile-security-testing-guide/
- Flutter Security Best Practices: https://docs.flutter.dev/security/
- Firebase Security Rules: https://firebase.google.com/docs/rules
- flutter_secure_storage: https://pub.dev/packages/flutter_secure_storage
