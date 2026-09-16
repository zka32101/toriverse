# Bug Triage & Issue Response Procedures
## Phase 18 — Quality Assurance During Soft-Launch

**Prepared**: 2026-09-12  
**Effective**: Sep 11 - Oct 2, 2026  
**Process Owner**: QA Lead + Engineering Lead  

---

## 🎯 Triage Goals

1. **Rapid Response**: Acknowledge bugs within 1-2 hours
2. **Severity Classification**: Prioritize by user impact
3. **Root Cause**: Identify whether code, Remote Config, or data
4. **Resolution Path**: Hot-patch vs. code fix vs. workaround
5. **Communication**: Keep testers informed (transparency builds trust)

---

## 📊 Severity Levels

### 🔴 CRITICAL (Immediate Action, <1 hour)
**Definition**: Game unplayable, data corruption, or multiple users blocked

**Examples**:
- App crashes on match start for >1% of sessions
- Cannot complete any matches (all fail at round 1)
- Money charged without granting cosmetics (data integrity)
- Login broken (can't access app)
- Server completely down (Firestore unavailable)

**Response**:
- Immediate investigation (on-call engineer)
- Hot-patch via Remote Config if possible (disable feature)
- Code fix + app update if necessary
- Notify all testers (priority communication)
- Target: Resolved within 1-2 hours

**Escalation**: Engineering Lead + Product Lead + On-Call

---

### 🟠 HIGH (Urgent Action, <4 hours)
**Definition**: Major feature broken, but workaround exists or limited users affected

**Examples**:
- Weak bonus always triggers incorrectly (but game still playable)
- Cosmetics don't render (use default)
- Leaderboard not updating (but ranking still visible)
- Push notifications not sending (still can play)
- Rank Pass UI broken (can purchase via RevenueCat popup)

**Response**:
- Investigation within 30 min
- Determine if hot-patchable or needs code fix
- Deploy hot-patch if applicable
- Communicate status + ETA to affected testers
- Target: Resolved or workaround documented within 4 hours

**Escalation**: Engineering Lead + Product Lead

---

### 🟡 MEDIUM (Standard Action, <24 hours)
**Definition**: Feature not working correctly, workaround available, limited impact

**Examples**:
- Collision resolution occasionally fails (but game continues)
- Rare crash on match end (player can replay match)
- Typo in UI text (message still understood)
- Performance slow on old devices (still playable)
- Cosmetic preview misaligned (can still equip)

**Response**:
- Investigation within 1-2 hours
- Communicate root cause + workaround to tester
- Plan fix for next build
- Target: Resolved in code fix, deployed within 24-48 hours

**Escalation**: Engineering Lead (no immediate executive need)

---

### 🟢 LOW (Backlog Action, <1 week)
**Definition**: Polish issue, visual bug, or edge case

**Examples**:
- Button animation stutters on specific device
- Friend profile picture sometimes loads slow
- Typo in "Congratulations!" screen
- Stats calculation off by 1 point (edge case)
- Cosmetic color slightly wrong shade

**Response**:
- Log in bug tracker for next sprint
- No urgent fix needed
- Can batch with other cosmetic improvements
- Target: Fixed in next build (week or later)

**Escalation**: Engineering Lead only (no escalation needed)

---

## 📋 Triage Process

### Step 1: Bug Report Reception (5 min)

**Sources**:
- TestFlight in-app feedback form
- Email to support
- Slack #toriverse-bugs channel
- Crashlytics auto-report (crashes)

**Immediate Action**:
```
1. Log bug in tracker (GitHub Issues or Jira)
2. Tag with cohort (QA / Creator / General)
3. Assign severity (use scale above)
4. Note environment: Device, OS, Network
5. Link to Crashlytics if crash-related
```

**Example Ticket**:
```
Title: [🔴 CRITICAL] App crashes when submitting move during round 3

Environment:
- Device: iPhone 12
- OS: iOS 15.2
- Tester: QA Team Member
- Reproducibility: Always (100%)
- Network: WiFi (good signal)

Description:
Every match crashes at round 3 when I submit my move.
Stack trace: [Crashlytics link]

Expected: Move accepted, board reveals
Actual: App force-closes
Error: NullPointerException at BoardState.resolveCollision()

Steps to Reproduce:
1. Start match
2. Play to round 3
3. Submit any move
4. CRASH

Workaround: None (match unplayable)
```

---

### Step 2: Severity Assignment (10 min)

**Decision Tree**:
```
┌─ Does it crash the app?
│  ├─ YES (or "unrecoverable error")
│  │  ├─ Affects >1% of sessions? → 🔴 CRITICAL
│  │  └─ Affects <1%, isolated case? → 🟠 HIGH
│  └─ NO (visual bug, feature not working)
│     └─ Continue to next question
│
├─ Does it block core gameplay (match completion)?
│  ├─ YES (can't complete matches)
│  │  ├─ >5% of players affected? → 🔴 CRITICAL
│  │  └─ <5% affected? → 🟠 HIGH
│  └─ NO (feature works but buggy)
│     └─ Continue to next question
│
├─ Does it affect multiple users or is it clearly a data loss bug?
│  ├─ YES (multiple users, money charged incorrectly, data corruption)
│  │  └─ → 🟠 HIGH
│  └─ NO (single user, edge case)
│     └─ Continue to next question
│
├─ Is there a workaround?
│  ├─ NO (player stuck)
│  │  └─ → 🟠 HIGH
│  └─ YES (player can continue with limitation)
│     └─ → 🟡 MEDIUM or 🟢 LOW based on impact
│
└─ Impact Assessment
   ├─ User happiness heavily affected? → 🟠 HIGH
   ├─ User happiness somewhat affected? → 🟡 MEDIUM
   └─ User barely notices? → 🟢 LOW
```

---

### Step 3: Root Cause Analysis (30-60 min)

**Process**:

**For Crashes**:
```
1. Check Crashlytics dashboard
2. Identify stack trace
3. Determine:
   ├─ Is crash in game logic (collision, bonus)?
   ├─ Is crash in Firebase (Firestore, Auth)?
   ├─ Is crash in RevenueCat (purchase)?
   ├─ Is crash in UI rendering (memory, Flutter)?
   └─ Is crash in external library?

4. Reproduce locally (if device available)
5. Identify code location
6. Determine if:
   ├─ Bug introduced in build 0.1.0+2? (regression)
   ├─ Bug from earlier build? (latent)
   └─ Bug from specific user action? (edge case)
```

**For Feature Bugs**:
```
1. Reproduce the bug (if possible)
2. Determine exact symptom:
   ├─ Wrong output (logic error)
   ├─ No output (missing feature)
   ├─ Delayed output (performance)
   └─ Inconsistent output (randomness issue)

3. Check code:
   ├─ Review related game logic
   ├─ Check Firestore rules (permissions)
   ├─ Check Remote Config values (feature flags)
   └─ Check API responses (error messages)

4. Determine root cause:
   ├─ Code logic error (requires code fix)
   ├─ Remote Config misconfiguration (requires config change)
   ├─ Data issue (requires manual fix or correction)
   ├─ UI issue (requires frontend fix)
   └─ Environmental (network, device, cache)
```

---

### Step 4: Resolution Path Decision (15 min)

**Decision Matrix**:
```
┌─ Can it be fixed via Remote Config?
│  ├─ YES (disable feature flag)
│  │  ├─ Severity CRITICAL/HIGH? → Deploy hot-patch immediately
│  │  └─ Severity MEDIUM/LOW? → Schedule for next batch
│  └─ NO (code change required)
│     └─ Continue to next question
│
├─ Is it a one-time data fix?
│  ├─ YES (e.g., reset user's cosmetic state)
│  │  ├─ Severity HIGH? → Manual fix + verification
│  │  └─ Severity MEDIUM/LOW? → Log for later
│  └─ NO
│     └─ Continue to next question
│
├─ Is the fix small and low-risk? (<50 lines code change)
│  ├─ YES + CRITICAL/HIGH severity?
│  │  └─ → Fast-track code fix: commit → test → merge → build
│  │     Target: New build 0.1.0+3 within 2-4 hours
│  └─ Otherwise (medium/large fix OR low severity)
│     └─ → Schedule fix for planned next build
```

---

### Step 5: Response to Tester (30 min)

**Communication Template**:

For CRITICAL issues:
```
Subject: 🔴 CRITICAL BUG ACKNOWLEDGED: [Bug Name]

Hi [Tester Name],

We've received your report about [bug description].
This is impacting your ability to play, and we're treating it as top priority.

STATUS: Under investigation (ETA: next 30-60 min for update)

CURRENT: [What we know about the issue]
ROOT CAUSE: [Initial hypothesis or confirmed cause]
FIX APPROACH: [We'll hot-patch / we're fixing in code / we're looking into it]

WORKAROUND: [If exists: Try restarting the app / Use this alternative / None available]

We'll update you within 1 hour with progress.
Thank you for your patience!

— Toriverse Team
```

For HIGH severity:
```
STATUS: Confirmed bug, investigating fix

We're prioritizing this. Expect update within 4 hours.
WORKAROUND: [If exists]
```

For MEDIUM severity:
```
STATUS: Logged and prioritized for fix

This will be resolved in the next build (24-48 hours).
WORKAROUND: [If exists]
```

For LOW severity:
```
STATUS: Noted for cosmetic improvement

This will be fixed in a future update.
No action needed now.
```

---

### Step 6: Implementation & Verification (Time varies)

**For Hot-Patches (CRITICAL/HIGH crashes)**:
```
Timeline: 30 min to 2 hours
1. Deploy Remote Config change (disable feature)
2. Verify crash rate drops >80% within 15 min
3. Communicate to tester: Bug mitigated, permanent fix incoming
4. Plan code fix for next build
5. Monitor for side effects
```

**For Code Fixes (CRITICAL logic bugs)**:
```
Timeline: 2-4 hours for urgent, 24-48 hours for standard
1. Reproduce bug locally
2. Write fix
3. Add test case (prevent regression)
4. Code review (30 min)
5. Merge to main
6. Build new version 0.1.0+3
7. Upload to TestFlight (30 min)
8. Notify testers: New build available
9. Verify in new build (1-2 hours)
```

**For Data Fixes (User reported money loss, progress reset)**:
```
Timeline: <1 hour
1. Identify affected user(s)
2. Verify data corruption
3. Manual fix: Update Firestore document
4. Verify user sees correct data
5. Communicate apology + explanation
```

---

## 📞 Escalation Chart

| Severity | Response Time | Escalation | Action |
|----------|---|---|---|
| 🔴 CRITICAL | <30 min | Lead + On-Call | Hot-patch + code fix |
| 🟠 HIGH | <2 hours | Lead | Hot-patch or fast-track |
| 🟡 MEDIUM | <24 hours | Engineer | Schedule fix |
| 🟢 LOW | <1 week | — | Backlog |

---

## 🐛 Common Bug Patterns & Quick Fixes

### Pattern 1: "Crash on [specific screen]"
```
Root Cause: Usually memory pressure or null pointer on that screen
Investigation:
  1. Check Crashlytics for exact line
  2. Look for unhandled exception
  3. Device memory usage
Fast Fix: Hot-patch to disable feature on that screen (if possible)
Permanent Fix: Code fix to handle null/memory better
```

### Pattern 2: "Feature always fails"
```
Root Cause: Logic error or API misconfiguration
Investigation:
  1. Is API returning correct data? (Check logs)
  2. Is logic handling response? (Trace code)
  3. Is data format correct? (Dump sample response)
Fast Fix: Hot-patch to disable feature if blocking gameplay
Permanent Fix: Code fix to handle edge case
```

### Pattern 3: "Wrong number / incorrect calculation"
```
Root Cause: Arithmetic error or off-by-one bug
Investigation:
  1. Identify exact calculation step
  2. Compare expected vs. actual
  3. Check variable types (int vs. double)
Fast Fix: None (calculation must be correct)
Permanent Fix: Code fix to calculation logic
```

### Pattern 4: "UI looks weird / wrong color"
```
Root Cause: Render bug, device-specific issue, or missing asset
Investigation:
  1. Reproduce on multiple devices
  2. Check theme (light/dark mode)
  3. Check device OS version
Fast Fix: None (cosmetic issue, acceptable short-term)
Permanent Fix: Code fix for rendering
```

### Pattern 5: "Network timeout / can't connect"
```
Root Cause: Transient network error, server overload, or real connectivity issue
Investigation:
  1. Check device network (WiFi/4G)
  2. Check server status (Firestore, Cloud Functions)
  3. Check user's internet speed
Fast Fix: Retry logic (already in app)
Permanent Fix: Better error messaging, retry UX
```

---

## 📊 Daily Triage Report (Template)

```
Date: 2026-09-{DD}

📥 NEW BUGS TODAY: {count}
├─ 🔴 CRITICAL: {count}
├─ 🟠 HIGH: {count}
├─ 🟡 MEDIUM: {count}
└─ 🟢 LOW: {count}

🔴 CRITICAL (In Progress):
├─ [Bug Name] — Assigned: {engineer}, ETA: {time}
├─ [Bug Name] — Status: Hot-patch deployed, verifying
└─ None if empty

🟠 HIGH (In Progress):
├─ [Bug Name] — Assigned: {engineer}, Status: Investigating
└─ [Bug Name] — Status: Scheduled for next build

✅ RESOLVED TODAY:
├─ [Bug Name] — Resolution: Hot-patch deployed
├─ [Bug Name] — Resolution: Code fix merged
└─ [Bug Name] — Resolution: User error / Not a bug

📋 BACKLOG (MEDIUM/LOW):
├─ {count} bugs waiting in queue
├─ Next batch scheduled: {date}
└─ Estimated fix time: {date}

📊 METRICS:
├─ Average response time: {hours}
├─ Average resolution time (CRITICAL/HIGH): {hours}
├─ User satisfaction: {% happy with communication}
└─ Repeat issues: {any patterns?}

🎯 FOCUS AREAS:
├─ Crashes on [specific feature]
├─ [Specific feature] not working
└─ Performance degradation on [device type]

Next Standup: Tomorrow 09:00 UTC
```

---

## 📋 Bug Tracking System Setup

**Recommended Tool**: GitHub Issues (simple) or Jira (advanced)

**GitHub Issues Setup**:
```
Labels:
├─ 🔴 critical (crashes, unplayable)
├─ 🟠 high (major feature broken)
├─ 🟡 medium (workaround exists)
├─ 🟢 low (polish)
├─ bug (software defect)
├─ feature (feature request)
├─ question (clarification)
├─ testflight-cohort-1 (QA)
├─ testflight-cohort-2 (Creators)
├─ testflight-cohort-3 (General)
└─ platform-ios, platform-android (device-specific)

Milestones:
├─ Soft-Launch (Sep 11 - Oct 2)
├─ Build 0.1.0+3 (fast-track fixes)
└─ Build 0.1.0+4 (standard fixes)

Automated Workflows:
├─ When labeled "critical" → Notify #toriverse-alerts
├─ When issue created → Tag with triage-needed
├─ When issue closed → Move to Resolved
└─ When crash reported → Auto-link Crashlytics
```

---

## ✅ Quality Gates

```
Soft-Launch Phase Success Conditions:
├─ Average response time: <2 hours for HIGH severity
├─ Average resolution time (CRITICAL): <4 hours
├─ 100% of user-reported bugs acknowledged within 1 hour
├─ Crash rate stays ≥99.5% (no critical crash escapes to >1%)
├─ User satisfaction: >80% rate support as "responsive"
└─ No data loss incidents (cosmetics, progress, money)
```

---

**Triage System Ready**: Sep 12, 2026  
**Active Period**: Sep 11 - Oct 2, 2026 (24/7 monitoring)  
**Post-Soft-Launch**: Continue with standard DevOps cycle
