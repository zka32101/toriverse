# GA Readiness Checklist - Executable Version

**Purpose**: Final verification before General Availability launch  
**Owner**: Launch Team Lead  
**Review Date**: T-1 Day before GA release

---

## Pre-Flight Checks (T-1 Week)

### Code & Build Quality

- [ ] All tests passing (225+ unit/widget/integration tests)
  - Evidence: GitHub Actions CI report
  - Date completed: ___________
  
- [ ] No critical security vulnerabilities
  - Evidence: OWASP review + SECURITY_REMEDIATIONS.md sign-off
  - Date completed: ___________

- [ ] Performance benchmarks met
  - App startup: < 2 seconds ✓
  - Memory: < 150MB startup ✓
  - CPU idle: < 5% ✓
  - Gameplay FPS: 60 FPS ✓
  - Evidence: DevTools profiles + Firebase Performance traces
  - Date completed: ___________

- [ ] Code coverage > 50%
  - Evidence: Coverage report from CI
  - Current: ___%
  - Date completed: ___________

### Firebase Configuration

- [ ] Production Firebase project fully configured
  - [ ] Authentication: Email, Google, Apple enabled
  - [ ] Firestore: Database initialized, rules deployed
  - [ ] Cloud Functions: 6 functions deployed and tested
  - [ ] Remote Config: All 7 parameters published with GA values
  - [ ] Analytics: Event tracking verified (6 key events)
  - [ ] Crashlytics: Alert rules configured
  - [ ] Storage: Permissions set (if Phase 2 clips enabled)
  - Evidence: Firebase Console audit log
  - Date completed: ___________

- [ ] Security rules tested and approved
  - Evidence: Firestore security test results
  - Date completed: ___________

- [ ] Backup & disaster recovery verified
  - [ ] Firestore automated backup enabled
  - [ ] Cloud Functions version history confirmed
  - Evidence: Firebase settings screenshot
  - Date completed: ___________

### Mobile App Signing

**iOS:**

- [ ] App signing certificate valid
  - Expires: ___________
  - [ ] Valid for > 1 year
  
- [ ] Provisioning profile active
  - Team ID: ___________
  - Bundle ID: com.zkaz.toriverse
  - Date completed: ___________

- [ ] App ID registered in Apple Developer
  - [ ] Push notifications capability (if used)
  - [ ] iCloud capability (if used)
  - Evidence: App Store Connect screenshot
  - Date completed: ___________

**Android:**

- [ ] Keystore file secured and backed up
  - Location: (Encrypted vault)
  - Password: (In Secrets Manager)
  - [ ] Keystore password != build password
  
- [ ] App signing key registered with Google Play
  - Key fingerprint: ________________________
  - Date completed: ___________

- [ ] Google Play signing certificate valid
  - [ ] Upload certificate != App signing certificate
  - Evidence: Google Play Console settings
  - Date completed: ___________

### Soft Launch Validation (Prerequisite)

- [ ] **Crash-free rate > 99.5%** ✓
  - Measurement: Crashlytics (7-day rolling)
  - Current: ___%
  - Date measured: ___________

- [ ] **Day 1 retention > 25%** ✓
  - Measurement: Analytics cohorts
  - Current: ___%
  - Date measured: ___________

- [ ] **Full human match rate > 40%** ✓
  - Measurement: Custom analytics event
  - Current: ___%
  - Date measured: ___________

- [ ] **Aha moment reach > 60%** ✓
  - Measurement: First match completion rate
  - Current: ___%
  - Date measured: ___________

- [ ] **Performance < 2s startup** ✓
  - Measurement: Firebase Performance traces
  - Current: ___ ms
  - Date measured: ___________

**All gates signed off**: [ ] YES / [ ] NO → If NO, do not proceed

---

## App Store Submission (T-5 Days)

### iOS App Store Connect

- [ ] TestFlight build uploaded and tested
  - Build version: ___________
  - Test results: PASS / FAIL
  - Date completed: ___________

- [ ] App Store Connect metadata complete
  - [ ] App name: "Toriverse"
  - [ ] Subtitle: "3人で遊ぶ瞬時リバーシ" (3-player instant Othello)
  - [ ] Description: English + Japanese versions
  - [ ] Keywords: "オセロ, リバーシ, 3人対戦"
  - [ ] Category: Games → Puzzle
  - [ ] Content rating: 4+ (Everyone)
  - [ ] Privacy policy: (URL linked)
  - Evidence: App Store Connect screenshot
  - Date completed: ___________

- [ ] Screenshots uploaded (5 images, localized)
  - [ ] Screenshot 1: 3-color board
  - [ ] Screenshot 2: Weak bonus trigger
  - [ ] Screenshot 3: Results screen
  - [ ] Screenshot 4: Subscription offer
  - [ ] Screenshot 5: Clip sharing
  - Size: 1920x1080 or iPhone Xs Max resolution
  - Languages: Japanese + English
  - Evidence: App Store Connect preview
  - Date completed: ___________

- [ ] Preview video (optional)
  - [ ] 15-30 seconds gameplay
  - [ ] Aha moment highlighted
  - Format: H.264, 1920x1080, 30 fps
  - Evidence: Upload confirmation
  - Date completed: ___________

- [ ] Release notes prepared
  - Version: 1.0.0
  - Text: English + Japanese
  - Content: Feature list, no marketing language
  - Evidence: Text saved to file
  - Date completed: ___________

- [ ] Version & build number bumped
  - Version: 1.0.0
  - Build: 1 (for v1.0.0)
  - In: pubspec.yaml
  - Evidence: Git commit SHA
  - Date completed: ___________

- [ ] Minimum iOS version set
  - [ ] iOS 13.0 or higher (should already be set)
  - Evidence: App Store Connect settings
  - Date completed: ___________

- [ ] Rating & review questionnaire completed
  - [ ] Alcohol, tobacco: No
  - [ ] Violence: No
  - [ ] Mature content: No
  - [ ] Gambling: No (no real money)
  - Evidence: App Store Connect section
  - Date completed: ___________

### Google Play Store

- [ ] Release APK built and signed
  - Build version: ___________
  - Signing: Keystore verified
  - Size: ___ MB
  - Evidence: Build output + file hash
  - Date completed: ___________

- [ ] Google Play Console metadata complete
  - [ ] App title: "Toriverse"
  - [ ] Short description: "3人で瞬時にリバーシ対戦"
  - [ ] Full description: Features + screenshots
  - [ ] Category: Games → Puzzle
  - [ ] Content rating: Everyone
  - [ ] Privacy policy: (URL linked)
  - [ ] Permissions justified: (Network, Storage, Contacts)
  - Evidence: Google Play Console screenshot
  - Date completed: ___________

- [ ] Graphics assets uploaded
  - [ ] Feature graphic: 1024x500 PNG
  - [ ] App icon: 512x512 PNG
  - [ ] Screenshots: 1080x1920 (5 images)
  - Languages: Japanese + English
  - Evidence: Play Console assets preview
  - Date completed: ___________

- [ ] Preview video uploaded (optional)
  - 15-30 seconds gameplay
  - Format: MP4, max 500MB
  - Evidence: Upload confirmation
  - Date completed: ___________

- [ ] Release notes prepared
  - Version: 1.0.0
  - Text: English + Japanese
  - Character limit: 500 characters
  - Evidence: Text saved to file
  - Date completed: ___________

- [ ] Minimum Android version set
  - [ ] Android 8.0 (API 26) or higher
  - Evidence: pubspec.yaml screenshot
  - Date completed: ___________

- [ ] Content rating questionnaire completed
  - Submitted to Google Play
  - Rating: Everyone (or appropriate tier)
  - Evidence: Confirmation email
  - Date completed: ___________

- [ ] Beta testing (optional)
  - [ ] Internal testing group invited
  - [ ] 14-day testing completed
  - [ ] Results reviewed and approved
  - Evidence: Testing report
  - Date completed: ___________

---

## Launch Day (T-0) Execution

### T-6 Hours: Final Systems Check

**Infrastructure & Services:**

- [ ] Firebase Console: All services operational
  - [ ] No quota warnings
  - [ ] No recent errors in logs
  - Evidence: Screenshot timestamp
  - Time checked: ___________

- [ ] Cloud Functions: All functions responding
  ```bash
  curl https://region-project.cloudfunctions.net/submitMove
  # Expected: 401 (auth required) or 200
  ```
  - [ ] submitMove
  - [ ] validateMove
  - [ ] processBonusLogic
  - [ ] resolveCollision
  - [ ] generateClip
  - [ ] scheduledReset
  - Evidence: Function logs
  - Time checked: ___________

- [ ] Firestore: Query performance baseline
  - [ ] p99 latency < 100ms
  - [ ] Error rate < 0.1%
  - Evidence: Firebase console metrics
  - Time checked: ___________

- [ ] Authentication: All providers working
  - [ ] Email sign-up (test account)
  - [ ] Google sign-in
  - [ ] Apple sign-in
  - Evidence: Test account login log
  - Time checked: ___________

- [ ] Analytics: Event tracking active
  - [ ] Test event fires and reaches Firebase
  - [ ] Real-time event log shows new events
  - Evidence: Analytics console
  - Time checked: ___________

- [ ] Crashlytics: Receiving crash reports
  - [ ] Alert rules active
  - [ ] Test crash sent and logged
  - Evidence: Crashlytics dashboard
  - Time checked: ___________

**App Builds:**

- [ ] iOS IPA ready for App Store
  - [ ] Build verified locally (flutter build ios --release)
  - [ ] Signatures valid
  - [ ] No code-sign warnings
  - Evidence: Build output log
  - Time checked: ___________

- [ ] Android APK ready for Play Store
  - [ ] Build verified locally (flutter build apk --release)
  - [ ] Signed with production key
  - [ ] Size reasonable (< 100MB)
  - Evidence: Build output log
  - Time checked: ___________

**Team Coordination:**

- [ ] All team members online and in war room
  - [ ] Engineering: __________ (✓ present)
  - [ ] Product: __________ (✓ present)
  - [ ] Growth: __________ (✓ present)
  - [ ] DevOps: __________ (✓ present)
  - [ ] QA: __________ (✓ present)
  - Evidence: Zoom/Meeting room attendance
  - Time: ___________

- [ ] Slack war room channel open (#toriverse-ga-launch)
  - [ ] Channel topic: "GA Launch Coordination"
  - [ ] All team members joined
  - [ ] Notifications enabled
  - Evidence: Slack screenshot
  - Time: ___________

- [ ] Communication backup confirmed
  - [ ] Phone numbers shared
  - [ ] Emergency contacts list
  - [ ] Backup internet connections confirmed
  - Evidence: Contact list in shared doc
  - Time: ___________

### T-2 Hours: Release Preparation

**App Store Release:**

- [ ] iOS App Store Connect ready
  - [ ] Version ready for review
  - [ ] Auto-release date set (or manual release plan)
  - [ ] All metadata approved
  - Evidence: App Store Connect screenshot
  - Time checked: ___________

- [ ] Review status confirmed
  - [ ] [ ] In Review, or
  - [ ] [ ] Ready to submit, or
  - [ ] [ ] Already approved (ready to release)
  - Evidence: Status screenshot
  - Time checked: ___________

**Google Play Release:**

- [ ] Release APK uploaded to Google Play Console
  - [ ] Bundle signed
  - [ ] No warnings
  - Evidence: Play Console screenshot
  - Time checked: ___________

- [ ] Release ready status
  - [ ] [ ] In internal testing, or
  - [ ] [ ] In beta testing, or
  - [ ] [ ] Ready for production release
  - Evidence: Status screenshot
  - Time checked: ___________

**Remote Config Finalization:**

- [ ] GA launch values confirmed
  ```json
  {
    "min_supported_version": "1.0.0",
    "free_match_daily_limit": 1,
    "weak_bonus_threshold": 20,
    "rescue_card_activation": 2,
    "move_submission_timeout_seconds": 30,
    "ai_difficulty": 2,
    "enable_analytics": true
  }
  ```
  - Evidence: Remote Config screenshot
  - Time checked: ___________

- [ ] Config values published (not just saved)
  - Evidence: "Last modified" timestamp
  - Time published: ___________

**Monitoring Setup:**

- [ ] Firebase dashboards open and visible
  - [ ] Analytics (DAU, events, retention)
  - [ ] Crashlytics (crash-free %)
  - [ ] Performance (startup time, latency)
  - Monitor tabs: 3+ browser tabs open
  - Evidence: Screenshot of tabs
  - Time: ___________

- [ ] Alert channels verified
  - [ ] Slack #toriverse-crashes connected
  - [ ] Slack #toriverse-performance connected
  - [ ] Email alerts configured
  - Test alert sent: ___________

- [ ] On-call engineer confirmed
  - [ ] Primary: __________ (phone: _________)
  - [ ] Secondary: __________ (phone: _________)
  - [ ] Both have runbooks printed
  - Evidence: Contact confirmation
  - Time: ___________

### T-1 Hour: GO/NO-GO Decision

**Final Confidence Check:**

| Item | Owner | Status | Notes |
|------|-------|--------|-------|
| Soft launch gates met | QA | ✓/✗ | |
| All 225+ tests passing | Eng | ✓/✗ | |
| iOS build ready | Eng | ✓/✗ | |
| Android build ready | Eng | ✓/✗ | |
| Firebase operational | DevOps | ✓/✗ | |
| Monitoring active | DevOps | ✓/✗ | |
| Team assembled | Product | ✓/✗ | |
| Marketing ready | Growth | ✓/✗ | |

**Launch Lead Decision:**

```
Final GO/NO-GO Vote:

Engineering Lead:    [ ] GO / [ ] NO-GO
Product Lead:        [ ] GO / [ ] NO-GO
Growth Lead:         [ ] GO / [ ] NO-GO
DevOps Lead:         [ ] GO / [ ] NO-GO

Consensus:           [ ] LAUNCH / [ ] DELAY

If DELAY:
  Reason: ________________________________
  New launch time: ________________________
  Owner: ________________
```

**Signed by:**
- Launch Lead: _________________ Time: _______
- Engineering Lead: ____________ Time: _______
- Product Lead: _______________ Time: _______

### T-0 (LAUNCH!)

**T-00:00 - Release Execution:**

- [ ] iOS app released to App Store
  - Method: [ ] Auto-release / [ ] Manual release
  - Time: ___________
  - Evidence: App Store Connect timestamp
  
- [ ] Android app released to Google Play
  - Method: [ ] Immediate release / [ ] Staged rollout (%)
  - Time: ___________
  - Evidence: Google Play Console timestamp

- [ ] Launch announcement posted
  - [ ] Twitter/X: "#トリバース、本日よりAppStore/PlayStoreで配信開始！"
  - [ ] Discord: Launch notification pinned
  - [ ] Email: Testers notified
  - Time: ___________

- [ ] Press release distributed
  - Channels: TechCrunch, App Store news, gaming press
  - Time: ___________
  - Evidence: Email confirmations

**T+00:05 - First Check:**

- [ ] App downloads starting
  - Evidence: App Store & Play Store install graphs
  - Expected: Downloads visible within 5 min
  - Time checked: ___________

- [ ] Analytics dashboard shows new users
  - Expected: > 0 new users in real-time view
  - Time checked: ___________

- [ ] No critical crash reports
  - Crashlytics: 0 new crash groups
  - Time checked: ___________

**T+00:15 - Early Metrics:**

- [ ] Authentication working
  - Test users can sign up/sign in
  - Evidence: Firebase auth log
  - Time checked: ___________

- [ ] Matching operational
  - Test match creation successful
  - Time checked: ___________

- [ ] Tester feedback positive
  - Slack #toriverse-launch: Early downloads confirmed
  - Time checked: ___________

**T+00:30 - First Hour Status:**

- [ ] DAU reporting
  - Active users: _____ (Expected: 10-50)
  - Evidence: Analytics real-time view
  - Time: ___________

- [ ] Crash rate acceptable
  - Crash-free %: ____% (Target: > 99%)
  - Time: ___________

- [ ] No P0/P1 incidents
  - [ ] All systems operational
  - Time: ___________

- [ ] First app review visible
  - App Store / Play Store: _____ stars
  - Time: ___________

**T+01:00 - First Hour Retrospective:**

- [ ] Achieved targets
  - [ ] Downloads: _____ (Expected: 100+)
  - [ ] DAU: _____ (Expected: 50+)
  - [ ] Crash-free: ____% (Target: > 99%)
  - [ ] Conversion: ___% (Expected: 3-5% of downloaders)

- [ ] Any issues encountered
  - [ ] None
  - [ ] Issue 1: ______________ → Action: ______________
  - [ ] Issue 2: ______________ → Action: ______________

- [ ] Team sentiment
  - [ ] 🎉 Celebrating success
  - [ ] 😅 Cautious optimism (minor issues)
  - [ ] 😰 Critical issues, but manageable

- [ ] Decision: Continue monitoring
  - [ ] Continue 24/7 (Week 1)
  - [ ] Scale to business hours (if stable)

---

## Post-Launch Verification (T+24 Hours)

- [ ] Crash-free rate > 99%
  - Measurement: Crashlytics
  - Current: ____% ✓/✗
  - Time checked: ___________

- [ ] DAU sustained
  - Expected: 1,000-5,000 DAU
  - Actual: _____ ✓/✗
  - Time checked: ___________

- [ ] Conversion rate 3-4%
  - Expected: 3-4% of downloaders
  - Actual: ___% ✓/✗
  - Time checked: ___________

- [ ] Match completion rate > 80%
  - Expected: > 80%
  - Actual: __% ✓/✗
  - Time checked: ___________

- [ ] Retention metrics collected
  - Day 1: __% (baseline collected)
  - Expected: > 25%
  - Time checked: ___________

- [ ] User feedback positive
  - App Store average: _____ stars
  - Sentiment: Positive / Mixed / Negative
  - Time checked: ___________

- [ ] Zero P0 incidents since launch
  - [ ] All issues resolved or mitigated
  - Evidence: Incident log
  - Time checked: ___________

---

## Phase 8 Complete Criteria

**Launch is successful when:**

- [x] Soft launch gates all passed (prerequisite)
- [x] App live on App Store & Play Store
- [x] T+1h: All systems operational
- [x] T+24h: Crash-free > 99%
- [x] T+24h: DAU > 1,000
- [x] T+7d: Retention measured
- [x] Zero P0 incidents

**Sign-Off:**

- Launch Lead: _____________ Date: _______
- Product Lead: ____________ Date: _______
- Engineering Lead: ________ Date: _______

---

**Status**: ✅ Ready for GA Launch  
**Created**: 2026-08-27  
**Last Updated**: ___________
