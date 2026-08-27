# Launch Day Execution Checklist

**Event**: Toriverse Soft Launch  
**Date**: TBD (After Phase 7 prep complete)  
**Owner**: Launch Team Lead  
**Team**: Dev, QA, DevOps, Product, Marketing

---

## Pre-Launch Week (7 Days Before)

### Day -7: Final Preparation

- [ ] **Code Freeze**: No new features, only hotfixes
- [ ] **Branch Lock**: Prevent merges to main
- [ ] **Communication**: Brief all stakeholders
- [ ] **Build Verification**: Test final builds locally
- [ ] **Tester List**: Finalize list of 50-100 testers
- [ ] **Release Notes**: Write launch notes in English/Japanese
- [ ] **Marketing**: Prepare launch announcement
- [ ] **Monitoring**: Verify all dashboards working
- [ ] **Documentation**: Review all launch guides
- [ ] **Contact List**: Ensure on-call engineers can be reached

### Day -5: Final Testing

- [ ] **Regression Test Suite**: Run all 225+ tests ✅
- [ ] **Performance Testing**: App startup < 2s ✅
- [ ] **Firebase Integration**: Firestore rules tested ✅
- [ ] **Analytics Events**: Sample events fire correctly ✅
- [ ] **Crashlytics**: Crash reporting working ✅
- [ ] **RevenueCat**: Subscription flow works ✅
- [ ] **Push Notifications**: Setup verified (if applicable)
- [ ] **Device Testing**: Test on real iOS and Android devices
- [ ] **Network Testing**: Tested on 4G and WiFi
- [ ] **Battery Testing**: Drain rate acceptable

### Day -3: Build Preparation

- [ ] **Version Bump**: Update pubspec.yaml version to 1.0.0
- [ ] **Build Number**: Set Android build number, iOS build version
- [ ] **Release Build**: Create final APK and IPA
- [ ] **Build Signing**: Verify signing certificates
- [ ] **Artifact Storage**: Store builds securely
- [ ] **Build Verification**: Test APK/IPA installations
- [ ] **Changelog**: Document all changes since v0.1.0
- [ ] **Symbols Upload**: Upload debug symbols to Firebase
- [ ] **Screenshot Refresh**: Update App Store screenshots
- [ ] **Icon Verification**: Verify app icons on all devices

### Day -1: Final Validation

- [ ] **Firebase Config**: Verify production credentials are active
- [ ] **Remote Config**: Publish final values (free match = 1, etc.)
- [ ] **Analytics**: Verify event tracking is live
- [ ] **Alerts**: Test alert channels (Slack, email)
- [ ] **Monitoring Dashboards**: Verify all metrics visible
- [ ] **Incident Playbook**: Team reviews incident response plan
- [ ] **Rollback Plan**: Verify rollback procedure
- [ ] **Tester Notification**: Send pre-launch email to testers
- [ ] **Status Page**: Create status.page entry
- [ ] **Team Standby**: Confirm all team members available
- [ ] **Comms Channel**: Set up Slack channel for launch coordination

---

## Launch Day (T-Day)

### T-4 Hours (Before Launch)

**Team Standup** (30 min)
- [ ] Launch lead reviews plan
- [ ] Each team confirms readiness:
  - [ ] Dev: Latest code frozen ✅
  - [ ] QA: Test results passed ✅
  - [ ] DevOps: Monitoring ready ✅
  - [ ] Product: Success metrics defined ✅
- [ ] Final questions answered
- [ ] Team confirms: GREEN LIGHT

**Final Checks** (30 min)
- [ ] Firebase Console: All systems operational
- [ ] Firestore: No issues in recent logs
- [ ] Cloud Functions: All functions active
- [ ] Monitoring: Dashboard loading without errors
- [ ] Build Artifacts: APK/IPA ready to upload
- [ ] Release Notes: Finalized in English/Japanese
- [ ] Tester List: CSV file ready (emails/phone numbers)
- [ ] Notification Templates: Pre-written and ready
- [ ] Rollback Checklist: Printed and accessible

### T-2 Hours (Preparation)

**TestFlight Setup** (45 min)
- [ ] [ ] Login to App Store Connect
- [ ] [ ] Upload final iOS IPA to TestFlight
- [ ] [ ] Wait for processing (usually 5-10 min)
- [ ] [ ] Review metadata one more time
- [ ] [ ] Set minimum iOS version to 13.0
- [ ] [ ] Add release notes (Japanese + English)
- [ ] [ ] Mark as "Ready to Test"

**Firebase App Distribution Setup** (45 min)
- [ ] [ ] Login to Firebase Console
- [ ] [ ] Navigate to App Distribution
- [ ] [ ] Upload final Android APK
- [ ] [ ] Add release notes (Japanese + English)
- [ ] [ ] Review app permissions
- [ ] [ ] Verify download link format

**Remote Config Final Check** (15 min)
- [ ] [ ] Verify config values are live
- [ ] [ ] min_supported_version: "0.1.0"
- [ ] [ ] free_match_daily_limit: 1
- [ ] [ ] weak_bonus_threshold: 20
- [ ] [ ] rescue_card_activation: 2
- [ ] [ ] All values accessible from app

### T-1 Hour (System Ready)

**Monitoring Activation** (30 min)
- [ ] [ ] Open Firebase Console in browser
- [ ] [ ] Pull up Analytics dashboard (real-time view)
- [ ] [ ] Pull up Crashlytics dashboard
- [ ] [ ] Pull up Performance monitoring
- [ ] [ ] Open Slack #toriverse-launch channel
- [ ] [ ] Have email on screen for alerts
- [ ] [ ] Verify database connection
- [ ] [ ] Test alert system one final time

**Team Assembly** (30 min)
- [ ] [ ] All team members logged in to war room (Zoom/in-person)
- [ ] [ ] Slack channel open
- [ ] [ ] Everyone has latest runbooks
- [ ] [ ] Phone numbers/contact info shared
- [ ] [ ] Network connections tested (no WiFi failures)
- [ ] [ ] Screen sharing ready
- [ ] [ ] Recording enabled (for post-mortem if needed)

### T-0 (LAUNCH!)

**Release** (Executed exactly at scheduled time)

```
T-00:00 → LAUNCH INITIATED
└─ Notify testers: "Soft launch begins now"
└─ Post Slack: "🚀 TORIVERSE LAUNCH - GO"
└─ Start timer (for checks below)
```

**T+00:00 - T+05:00 (First 5 Minutes)**
- [ ] [ ] Refresh Analytics real-time: Users should start appearing
- [ ] [ ] Check Crashlytics: Should show 0 crashes
- [ ] [ ] Check Firebase Functions logs: No errors
- [ ] [ ] Check iOS TestFlight: Downloads should start
- [ ] [ ] Check Android App Distribution: Downloads should start
- [ ] [ ] Slack: First tester feedback coming in

**T+05:00 - T+30:00 (First 30 Minutes)**
- [ ] [ ] Analytics: 10-20 active users
- [ ] [ ] Crash rate: < 0.5% (should be ~0%)
- [ ] [ ] Event tracking: match_completed events appearing
- [ ] [ ] No error spikes in Functions
- [ ] [ ] Slack: Tester feedback positive/neutral
- [ ] [ ] Status page: All systems operational

**T+30:00 - T+60:00 (First Hour)**
- [ ] [ ] Analytics: 50-100 active users
- [ ] [ ] Retention: Testers staying in app
- [ ] [ ] Crashes: Still < 0.5%
- [ ] [ ] Performance: App startup < 2s, no jank reports
- [ ] [ ] Monetization: RevenueCat events firing
- [ ] [ ] No critical alerts triggered
- [ ] [ ] Team morale: High! 🎉

**T+60:00 - T+180:00 (First 3 Hours)**
- [ ] [ ] Continue monitoring every 15 min
- [ ] [ ] DAU: 100-300 (expected for soft launch)
- [ ] [ ] Match completion rate: > 80%
- [ ] [ ] Crash-free rate: > 99%
- [ ] [ ] Check for any patterns in crashes
- [ ] [ ] Note tester feedback themes
- [ ] [ ] Prepare optional patch if issue found

---

## Post-Launch Day (T+Day 1)

### Morning Standup (T+24 Hours)

**Metrics Review** (30 min)
- [ ] [ ] Crash-free users: ___% (Target: > 99.5%) ✓/✗
- [ ] [ ] DAU: _____ (Baseline for growth comparison)
- [ ] [ ] Match completion: ___% (Target: > 80%) ✓/✗
- [ ] [ ] Weak bonus triggers: ___% (Target: > 25%) ✓/✗
- [ ] [ ] Clip shares: _____ (Trend indicator)
- [ ] [ ] Any critical bugs: ✓ No / ✗ Yes
- [ ] [ ] Tester sentiment: Positive / Mixed / Negative

**Issue Triage** (15 min)
- [ ] [ ] List all reported issues
- [ ] [ ] Categorize by severity (Critical/High/Medium/Low)
- [ ] [ ] Assign ownership
- [ ] [ ] Estimate fix time
- [ ] [ ] Decide: Fix now / Fix in next build / Defer

**Decision Point**
- [ ] **Green**: Continue as planned ✅
- [ ] **Yellow**: Monitor closely, prepare hotfix
- [ ] **Red**: Execute rollback, investigate

### Day 2-7 Monitoring

**Daily Cadence:**
- 9 AM: Overnight crash review
- 12 PM: Midday metrics check
- 6 PM: Tester feedback review
- 10 PM: End-of-day summary

**Key Metrics to Track:**
- [ ] Crash-free rate trend
- [ ] DAU growth
- [ ] Retention cohorts
- [ ] Feature adoption
- [ ] Tester feedback

---

## Critical Paths & Quick Decisions

### Decision Tree: First Issues

**If Crash Rate > 2%**
→ STOP, investigate immediately
→ Publish hotfix if identified
→ If unfixable: ROLLBACK

**If Authentication Fails**
→ CRITICAL, all users affected
→ Immediately notify team
→ Prepare rollback
→ Investigate Firebase Auth config

**If Matching Fails**
→ HIGH priority (core feature)
→ Check Firestore/Cloud Functions
→ Disable feature if broken
→ Publish workaround

**If Monetization Broken**
→ MEDIUM priority (affects $)
→ Disable subscription if broken
→ Document impact
→ Fix in next build

**If Analytics Not Tracking**
→ LOW priority (debug info)
→ Doesn't affect user experience
→ Fix in next build
→ Continue monitoring

### Escalation Contacts

```
🔴 CRITICAL (Page immediately):
- Launch Lead: +81-90-XXXX-XXXX
- CTO: +81-90-XXXX-XXXX

🟠 HIGH (Within 30 min):
- On-Call Engineer: Slack DM
- DevOps: Slack DM

🟡 MEDIUM (Within 4 hours):
- Product Manager: Slack
- QA Lead: Slack
```

---

## Success Criteria

**Launch is Successful When:**

✅ **First 1 Hour**
- [ ] Testers can download and install
- [ ] App launches without crashes
- [ ] Authentication works
- [ ] Can start matching
- [ ] Zero critical issues reported

✅ **First 24 Hours**
- [ ] Crash-free rate > 99%
- [ ] DAU > 50
- [ ] Match completion rate > 80%
- [ ] Positive/neutral tester feedback
- [ ] No revenue-breaking issues
- [ ] Analytics tracking works

✅ **First 7 Days**
- [ ] Crash-free rate > 99.5% (steady)
- [ ] DAU > 200-300
- [ ] Day 1 retention > 20% (preliminary)
- [ ] Weak bonus working as designed
- [ ] No "gamebreaker" bugs
- [ ] Conversion rate > 1% (preliminary)

---

## Post-Launch Retrospective

**Schedule**: T+7 days

**Agenda** (1 hour meeting)
1. **What Went Well** (10 min)
   - Team highlights successes
   - Share positive feedback

2. **What Could Be Better** (15 min)
   - Issues encountered
   - Root causes
   - Prevention strategies

3. **Metrics Review** (15 min)
   - Compare to targets
   - Identify trends
   - Plan next steps

4. **Action Items** (15 min)
   - Assign owners
   - Set deadlines
   - Update playbooks

5. **Celebration** (5 min)
   - Thank team
   - Plan team activity

---

## Artifact Preservation

After launch, archive:
- [ ] Launch logs (Crashlytics, Performance)
- [ ] Analytics data (day 1-7 baseline)
- [ ] Tester feedback (forum, email)
- [ ] Team chat logs (#toriverse-launch)
- [ ] Performance metrics (startup time, FPS)
- [ ] Incident reports (any issues)
- [ ] Post-mortem notes
- [ ] Build artifacts (APK/IPA hashes)

For: Learning, compliance, future reference.

---

## Final Confidence Check

**Before clicking "publish":**

| Item | Status | Owner |
|------|--------|-------|
| Firebase production ready | ✓/✗ | DevOps |
| All tests passing | ✓/✗ | QA |
| Performance verified | ✓/✗ | Dev |
| Monitoring active | ✓/✗ | DevOps |
| Tester list final | ✓/✗ | Product |
| Release notes approved | ✓/✗ | Product |
| Rollback plan ready | ✓/✗ | DevOps |
| Team assembled | ✓/✗ | Launch Lead |
| Communication ready | ✓/✗ | Marketing |

**Team Consensus**: Everyone ready? 
- [ ] Yes, GO! 🚀
- [ ] No, need 1 more day

---

**Status**: ✅ Launch Day Execution Ready  
**Created**: 2026-08-27  
**Last Updated**: —

---

**Good luck! You've got this! 🚀**
