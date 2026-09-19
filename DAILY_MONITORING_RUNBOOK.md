# Daily Monitoring & Operations Runbook
## Phase 19 — Active Soft-Launch Execution (Sep 11 - Oct 2, 2026)

**Prepared**: 2026-09-16  
**Active Period**: 24/7 monitoring, Daily standups 09:00 UTC  
**Owner**: Engineering Lead + On-Call Rotation  

---

## 📋 Daily Standup Checklist (09:00 UTC)

### Step 1: Overnight Events Review (15 min)
**Time**: 09:00 - 09:15 UTC

```
1. Check Slack #toriverse-alerts for critical overnight notifications
   ├─ Any crashes >0.5%? → IMMEDIATE investigation
   ├─ Any DAU drops >30%? → Potential outage
   └─ Any revenue anomalies? → Check RevenueCat logs

2. Review Crashlytics dashboard
   ├─ Current crash-free rate (target ≥99.5%)
   ├─ Top crashes since last standup
   ├─ New crash types appeared? → Investigate
   └─ Affected user count (if >100 unique users)

3. Check Firebase Analytics real-time dashboard
   ├─ DAU overnight (compare to yesterday)
   ├─ Session count (normal activity levels?)
   ├─ Match completion rate (should be ≥95%)
   └─ Error events (any spikes?)

Action Items:
├─ If CRITICAL alert: Escalate immediately, hold standup
├─ If HIGH issue: Document + add to priority list
├─ If MEDIUM issue: Schedule for investigation
└─ If all clear: Proceed to daily metrics review
```

### Step 2: Daily Metrics Review (20 min)
**Time**: 09:15 - 09:35 UTC

```
Metric 1: Retention (if applicable)
├─ Previous day's DAU: {count}
├─ Returning users (% from Day N-1): {%}
├─ Expected: >70% returning
└─ Trend: 📈 Healthy / 📉 Concerning

Metric 2: Match Health
├─ Matches started: {count}
├─ Match completion rate: {%} (target ≥95%)
├─ Average match duration: {minutes}
└─ Abandonment rate: {%}

Metric 3: Feature Activation
├─ Weak bonus triggered: {% of matches}
├─ Rescue card used: {% of matches}
├─ AI fill rate: {%} (target <60%)
└─ Collision events: {count}

Metric 4: Crashes (Crashlytics)
├─ Crash-free rate: {%.XX}% (must be ≥99.5%)
├─ Crash spike overnight? YES / NO
├─ Top crash affected users: {count}
└─ Status: 🟢 PASS / 🟡 WATCH / 🔴 ALERT

Metric 5: Monetization (if live)
├─ Daily revenue: ¥{amount}
├─ Rank Pass trials: {count}
├─ Rank Pass conversions: {count}
└─ Cosmetics sales: {count} transactions

Metric 6: Social Engagement
├─ Clip shares: {count}
├─ Friend additions: {count}
├─ Messages sent: {count}
└─ Viral signal: Positive / Neutral / Negative

Status Summary:
🟢 All metrics green (no action)
🟡 Minor issue detected (add to watch list)
🔴 Critical issue (escalate immediately)
```

### Step 3: Problem Investigation (30 min if needed)
**Time**: 09:35 - 10:05 UTC

**If any metric is 🟡 WATCH or 🔴 ALERT**:

```
Investigation Framework:

Question 1: Is it a spike or a trend?
├─ Spike: Single data point outlier
│  └─ Action: Monitor next 1-2 hours, likely recovers
├─ Trend: 3+ consecutive measurements down
│  └─ Action: Investigate root cause, may need fix

Question 2: What changed recently?
├─ Remote Config deployed? Check value + impact
├─ New users introduced? (Cohort 2 started Sep 14)
├─ Time zone effect? (Different regions active)
├─ Known issue? (Check bug tracker)
└─ Unknown? (Requires deeper investigation)

Question 3: Is it user-facing or infrastructure?
├─ User-facing: Players affected directly
│  └─ Action: Prepare communication, possible hot-patch
├─ Infrastructure: Backend degradation
│  └─ Action: Check Firebase/Firestore + service status
└─ Data: Analytics or calculation error
   └─ Action: Verify query, check logs

Decision Matrix:
├─ CRITICAL (crash >1%, revenue broken, matches fail): Escalate immediately
├─ HIGH (feature broken, >10% users affected): 2-hour investigation + fix
├─ MEDIUM (minor issue, workaround exists): Schedule for next batch
└─ LOW (cosmetic, single user): Backlog
```

### Step 4: Daily Actions & Communications (15 min)
**Time**: 10:05 - 10:20 UTC

```
Communication Task 1: Tester Update (if issues found)
├─ Severity CRITICAL/HIGH: Post in TestFlight feedback + email
├─ Severity MEDIUM: Log in GitHub issue
└─ Template: Use bug communication template

Communication Task 2: Remote Config Status
├─ Any patches deployed overnight? Document in log
├─ Any patches scheduled for today? Announce timing
└─ Rollback any patches? Notify stakeholders

Task 3: Escalations & Next Steps
├─ Does issue need investigation? Assign owner + deadline
├─ Does issue need hot-patch? Prepare playbook
├─ Does issue need code fix? Create bug ticket
└─ Document all actions in standup report

Task 4: Prepare Standup Report
├─ Overnight summary (1-2 sentences)
├─ Key metrics (6 values)
├─ Critical issues (if any)
├─ Planned actions (next 24 hours)
└─ Send report email (template below)

End of Standup:
✅ Report sent
✅ Issues escalated
✅ Owners assigned
✅ Next standup scheduled
```

---

## 📧 Daily Standup Report Email Template

```
Subject: Toriverse Soft-Launch Daily Standup — {Date}

📊 OVERNIGHT SUMMARY ({Yesterday 00:00 - Today 09:00 UTC}):
Stable operation. DAU: {count} ({±%}). All core systems operational.

KPI STATUS:
├─ 🟢 DAU: {count} (yesterday: {count}, {±%})
├─ 🟢 Retention: {%} returning (target >70%)
├─ 🟢 Match Completion: {%} (target ≥95%)
├─ 🟢 Crash-Free: {%.XX}% (target ≥99.5%)
├─ 🟢 Aha Moment: {%} reversals (tracking)
├─ 🟢 Revenue: ¥{amount} ({transactions})
└─ 🟢 Clip Shares: {count} (viral signal: POSITIVE)

ISSUES DETECTED:
{None / Issue 1: Description + Severity / Issue 2: ...}

ACTIONS TAKEN OVERNIGHT:
{Remote Config change / Patch deployed / User support}

PLANNED TODAY:
├─ Investigation: {if needed}
├─ Patch deployment: {if scheduled}
├─ Tester communication: {if critical}
└─ Next checkpoint: {date}

CRITICAL METRICS (Soft-Launch Gates):
Gate 1: Day 1 Retention (Sep 19) → Measuring
Gate 2: Crash-Free ≥99.5% → ✅ PASS (current: {%.XX}%)
Gate 3: Aha Moment ≥60% → ✅ TRACKING
Gate 4: 3-Human Matches ≥40% → ✅ TRACKING

Dashboard: [Firebase Analytics URL]
Crashes: [Crashlytics URL]
Next Standup: {Tomorrow 09:00 UTC}

— Operations Team
```

---

## 🚨 Alert Response Procedures

### Alert 1: Crash Rate >0.5% (CRITICAL)

**Trigger**: Crashlytics auto-alert

**Immediate Response (T+0 min)**:
```
1. Open Crashlytics dashboard
2. Identify top crash (should be clear)
3. Review stack trace
4. Estimate affected users
5. Severity assessment:
   ├─ >5% of sessions crashing? → CRITICAL
   ├─ 1-5% of sessions? → HIGH
   ├─ <1% but specific flow? → MEDIUM
```

**Investigation (T+5 min)**:
```
1. Check when crash started (today? overnight?)
2. Correlation: Any recent changes?
   ├─ App update? (No, same build 0.1.0+2)
   ├─ Remote Config change? (Check change log)
   ├─ User surge? (Check DAU spike)
   └─ Unknown? (Requires diagnosis)
3. Can it be fixed via Remote Config?
   ├─ YES: Prepare hot-patch (feature disable)
   └─ NO: Code fix needed (requires new build)
```

**Deployment Decision (T+15 min)**:
```
Decision Tree:
├─ Can disable via Remote Config?
│  ├─ YES + Critical? → Deploy immediately
│  └─ YES + High? → Deploy within 1 hour
├─ Requires code fix?
│  ├─ YES + Critical? → Engineer hotline, target 2-4 hours
│  └─ YES + High? → Fast-track, target 4-6 hours
└─ Is it a one-time fluke?
   ├─ Likely (isolated crash spike)? → Monitor next 30 min
   └─ Likely persistent? → Deploy fix
```

**Communication (T+20 min)**:
```
Internal Slack #toriverse-alerts:
"🔴 CRASH SPIKE DETECTED
Crash: [Top Crash Name]
Affected: [X] users ([%]% of sessions)
Status: [Investigating / Hot-patch deploying / Code fix in progress]
ETA: [Time estimate]
Will update in 30 min."

If >10 min without fix:
Post in TestFlight feedback:
"We've detected a technical issue affecting some players.
Our team is actively working on a fix. Expect update within [X] minutes.
Thank you for your patience!"
```

**Resolution Verification (T+1 hour)**:
```
1. Check Crashlytics: Crash rate trending down?
2. Verify: If >90% reduction, issue resolved
3. If not resolved: Escalate to next level
4. Document: Root cause + permanent fix plan
```

---

### Alert 2: DAU Drop >30% (HIGH)

**Trigger**: Manual detection or analytics alert

**Immediate Response (T+0 min)**:
```
1. Check Firebase Analytics real-time
2. Verify: Is it a real DAU drop or analytics delay?
   ├─ Refresh dashboard (data lag 5-10 min)
   └─ Check compare to 7-day average
3. If confirmed drop:
   ├─ Time when it started?
   ├─ Is it a single cohort or all users?
   └─ Correlation: Time zone? (East Asia morning? Europe night?)
```

**Investigation (T+10 min)**:
```
Potential Causes:
├─ Network outage? Check Firestore status
├─ App crash? Check Crashlytics
├─ Maintenance? Check Firebase/Google Cloud status
├─ Geographic event? (Time zone usage patterns)
├─ Feature broken? Check match start/completion rate
└─ User flow issue? Check analytics funnel

Verification:
├─ Match creation rate down? → Game not playable
├─ Session rate down? → Users not opening app
├─ Login rate down? → Authentication broken
└─ All down uniformly? → Infrastructure issue
```

**Decision (T+20 min)**:
```
Is it a real issue?
├─ YES (confirmed >20% drop + infrastructure problem)
│  └─ Action: Alert stakeholders, investigate root cause
├─ YES but explained (geographic/time zone pattern)
│  └─ Action: Monitor only, document pattern
├─ NO (data lag, analytics delay, artifact)
│  └─ Action: Continue monitoring, false alarm
```

**Communication (T+30 min)**:
```
If confirmed real issue:

Internal:
"🟠 DAU ANOMALY DETECTED: {drop}% decrease
Detected: {time UTC}
Likely Cause: [diagnosis]
Impact: {X} users affected
Status: [Investigating]
ETA: {time to fix}"

If major outage:
TestFlight feedback:
"We've detected an issue affecting access to the game.
Technical team is investigating. More details in 15 minutes."
```

---

### Alert 3: Retention Below Expected (Sep 19+ check)

**Trigger**: Day 1 Retention <25% (gate failure)

**Timeline**: Sep 19 morning (24-hour data available)

**Assessment (T+0)**:
```
1. Pull Firebase cohort analysis
2. Calculate: (Users logged in Sep 19) / (Users logged in Sep 18)
3. Target: ≥25%
4. If <25%: GATE AT RISK

Root Cause Analysis:
├─ Was aha moment low? Check reversal_experienced rate
│  └─ If <50%: Weak bonus not triggering enough
├─ Was crash rate high? Check crash-free %
│  └─ If <99%: Technical issues drove churn
├─ Was onboarding confusing? Check time_to_first_match
│  └─ If >5 min: Players dropping during tutorial
├─ Was daily match gate frustrating? Check matched limit reached
│  └─ If >30%: Free tier too restrictive
```

**Hot-Patch Decision (T+30 min)**:
```
If aha moment is the issue (<60%):
└─ Deploy: Lower weak_bonus_threshold (0.20 → 0.25)
   Target: Improve reversal rate by Sep 20 morning

If gate pressure is the issue (>30% reached limit):
└─ Deploy: Increase daily_free_matches (1 → 2)
   Target: Reduce friction, improve Day 2 return

If crash/technical:
└─ Fix: Disable crashing feature + deploy
   Target: Reduce churn from crashes

If onboarding:
└─ Code fix needed (requires new build 0.1.0+3)
```

**Communication (T+1 hour)**:
```
Internal Standup:
"🟡 RETENTION AT RISK
Day 1 Retention: {%}% (target ≥25%)
Likely cause: [aha moment / gate pressure / crashes]
Action: [Hot-patch deployed / Code fix in progress]
ETA resolution: [Sep 20 morning / next build]"

Leadership:
"Day 1 retention preliminary: {%}%
Within acceptable range / At risk / Below target
Investigating root cause. Update at 15:00 UTC."
```

---

## 📅 Weekly Checkpoint Procedures

### Checkpoint 1: Week 1 (Sep 18, 2026)
**Date**: Sep 18, 15:00 UTC (end of Cohort 1 + Day 1 of Cohort 3)

```
Assessment Tasks:

1. Cohort 1 (Internal QA) - Wrap Up
   ├─ Did they complete their testing? (target: 20+ matches each)
   ├─ Any blockers found? (assess severity)
   ├─ Overall stability score: {pass/fail}
   └─ Go/No-Go for Cohort 2/3: [PROCEED / HOLD FOR FIXES]

2. Crash Rate Assessment
   ├─ Week average crash-free: {%.XX}%
   ├─ Gate status: ✅ PASS (≥99.5%) / ⚠️ WATCH (95-99.5%) / ❌ FAIL (<95%)
   └─ Action: [No action / Monitor / Deploy hot-patch]

3. Prepare for Cohort 3 (starting today)
   ├─ Bug tracker clean? (no blockers for general users)
   ├─ Communication ready? (welcome message, testing guide)
   └─ Monitoring dashboards updated? (ready for 30-50 users)

4. Documentation Update
   ├─ Update PROJECT_STATUS.md with Week 1 findings
   ├─ Document any issues found + resolutions
   └─ Lessons learned from QA cohort
```

### Checkpoint 2: Week 2 (Sep 25, 2026)
**Date**: Sep 25, 15:00 UTC (Day 7 + Cohort 2/3 running)

```
Assessment Tasks:

1. Day 1 Retention Analysis (from Sep 18 data)
   ├─ Gate 1 status: Day 1 Retention {%}% (≥25%?)
   │  ├─ ✅ PASS: Aha moment validated, proceed confident
   │  ├─ ⚠️ WATCH: 20-25%, investigate
   │  └─ ❌ FAIL: <20%, deploy hot-patch immediately
   └─ Action: [No action / Optimize / Emergency fix]

2. Day 7 Retention Preliminary (Sep 11-17 cohort)
   ├─ Returning users Day 7: {%}% (target ≥15%)
   ├─ Trend: Increasing / Flat / Declining
   └─ Action: [Monitor / Optimize / Investigate]

3. Aha Moment Assessment
   ├─ Reversal experience rate: {%}% (target ≥60%)
   ├─ If <60%: Deploy weak bonus adjustment
   └─ Verify post-deployment: Monitor next 2-4 hours

4. 3-Human Match Success
   ├─ Full human match rate: {%}% (target ≥40%)
   ├─ If <40%: Extend matchmaking wait or incentivize
   └─ Verify: Monitor next day

5. Monetization Check (if live)
   ├─ Rank Pass conversion: {%}% (target >50% trial→paid)
   ├─ Cosmetics adoption: {%}% of users purchased
   ├─ ARPU: ¥{amount} (target >¥50)
   └─ Action: [On track / Adjust strategy]

6. Cohort 2 (Content Creators) Performance
   ├─ Clips shared: {count} (target 2+ per creator)
   ├─ Viral coefficient signal: {estimate}
   ├─ High performer: [highlight top clip]
   └─ Action: [Feature in announcement / Optimize UX]

7. Decision Point
   Gate Assessment:
   ├─ Gate 1: Day 1 Retention ≥25%? [PASS / FAIL]
   ├─ Gate 2: Crash-Free ≥99.5%? [PASS / FAIL]
   ├─ Gate 3: Aha Moment ≥60%? [PASS / PARTIAL / FAIL]
   ├─ Gate 4: 3-Human Matches ≥40%? [PASS / PARTIAL / FAIL]
   └─ Overall: [ON TRACK / OPTIMIZE NEEDED / CRITICAL ISSUE]
```

### Checkpoint 3: Week 3 (Oct 2, 2026)
**Date**: Oct 2, 15:00 UTC (Soft-Launch Wrap)

```
Final Assessment Tasks:

1. Final Gate Status
   ├─ Gate 1: Day 1 Retention = {%}% [PASS ✅ / FAIL ❌]
   ├─ Gate 2: Crash-Free = {%.XX}% [PASS ✅ / FAIL ❌]
   ├─ Gate 3: Aha Moment = {%}% [PASS ✅ / PARTIAL ⚠️ / FAIL ❌]
   └─ Gate 4: 3-Human Matches = {%}% [PASS ✅ / PARTIAL ⚠️ / FAIL ❌]

2. Final Retention Curve
   ├─ Day 1: {%}%
   ├─ Day 7: {%}%
   ├─ Day 14: {%}% (preliminary)
   ├─ Day 30: {%}% (if enough data)
   └─ Trend: Healthy / Concerning / Strong

3. Monetization Final
   ├─ Rank Pass: {%}% conversion (trial → paid)
   ├─ Cosmetics: ¥{revenue} total
   ├─ ARPU: ¥{amount}
   └─ Paid users: {count} / {total users}

4. Social & Viral
   ├─ Clips shared: {count} total
   ├─ Viral coefficient: {estimate} (0.3-0.5 target)
   ├─ Friend additions: {count}
   └─ Leaderboard engagement: {metric}

5. Stability & Quality
   ├─ Crash-free rate (full period): {%.XX}%
   ├─ Bugs filed: {count}
   ├─ Critical bugs: {count} (resolved: {count})
   └─ User satisfaction: {%} responsive to support

6. GO/NO-GO Decision
   ├─ All gates passing? → GO to public launch
   ├─ Most gates passing? → SOFT GO (with caveats)
   ├─ Critical gates failing? → NO GO (iterate before launch)
   └─ Decision Owner: Product Lead + Engineering Lead

7. Transition Plan
   ├─ If GO: Prepare App Store submission
   ├─ If NO GO: Plan iteration + retest timeline
   ├─ Post-Soft-Launch: Begin Phase 15.4 (analytics)
   └─ Documentation: Compile soft-launch report
```

---

## 🔄 Shift Handoff Procedures

**When**: Daily at shift change (08:00 UTC incoming, 20:00 UTC outgoing)

**Outgoing Engineer (20:00 UTC)**:
```
Prepare Handoff Report (10 minutes before shift end):
1. Current status (all systems operational? any ongoing issues?)
2. Critical metrics (DAU, crash rate, any anomalies?)
3. Overnight expectations (quiet? volume? known events?)
4. Escalations (any issues requiring attention next shift?)
5. Context (any alerts to watch for? known flakiness?)

Example:
"All systems stable. DAU trending well. Cohort 3 starting tomorrow (Sep 18).
Monitoring playbook deployed. No known issues. Crash rate: 0.2% (good).
Watch for initial Cohort 3 surge tomorrow morning. Otherwise routine."
```

**Incoming Engineer (08:00 UTC)**:
```
1. Read handoff report (2 min)
2. Check Crashlytics overnight (2 min)
3. Review dashboards (3 min)
4. If any issues: Start investigation immediately
5. If all clear: Begin daily standup checklist

First Action: Check overnight alerts in #toriverse-alerts
```

---

## 🎯 Contingency Procedures

### Scenario 1: Crash Rate Spike >1% Overnight
```
Probability: LOW (mature codebase)
Severity: 🔴 CRITICAL
Response Time: <30 minutes

Action Flow:
1. Wake on-call engineer (if not already)
2. Identify crash via Crashlytics
3. Prepare disable patch (15 min)
4. Deploy (5 min)
5. Verify crash rate drops (5 min)
6. Assess permanent fix (parallel work)
7. Monitor 1 hour, then proceed to morning standup
```

### Scenario 2: Firestore Connection Errors
```
Probability: LOW (Firebase is reliable)
Severity: 🟠 HIGH (users can't play)
Response Time: <30 minutes

Action Flow:
1. Check Firebase Status Dashboard
2. If Google issue: Wait + communicate (no action needed)
3. If security rules issue: Verify rules + fix
4. If quota issue: Increase quota + monitor
5. Communicate to testers: "Brief connectivity issue, please retry"
6. Monitor recovery
```

### Scenario 3: Day 1 Retention <25% (Gate Failure)
```
Probability: MODERATE (depends on aha moment)
Severity: 🔴 CRITICAL (gate failure)
Response Time: Immediate upon detection (Sep 19 morning)

Action Flow:
1. Confirm data: Pull 24-hour cohort analysis
2. Root cause: Analyze aha moment rate + crash rate
3. Deploy hot-patch: Lower weak_bonus_threshold OR increase daily_free_matches
4. Communicate: "Identified area for improvement, deploying optimization"
5. Verify: Monitor reversal rate + retention for next 24 hours
6. Escalate: Update leadership on gate status + recovery plan
```

### Scenario 4: Revenue/Payment System Broken
```
Probability: VERY LOW (RevenueCat is mature)
Severity: 🔴 CRITICAL (money loss)
Response Time: <15 minutes

Action Flow:
1. Check RevenueCat status
2. If RevenueCat down: Communicate "shop temporarily unavailable"
3. If billing issue: Contact RevenueCat support immediately
4. Disable shop via Remote Config if needed (stop charge failures)
5. Escalate to leadership + legal (if money lost)
6. Communicate: "Rank Pass temporarily unavailable, will be restored shortly"
```

---

## 📞 On-Call Rotation

**Week 1 (Sep 11-18)**: [Name 1] primary, [Name 2] backup
**Week 2 (Sep 19-25)**: [Name 3] primary, [Name 1] backup
**Week 3 (Sep 26-Oct 2)**: [Name 2] primary, [Name 3] backup

**On-Call Responsibilities**:
- Respond to alerts within 15 min
- Deploy emergency hot-patches within 30 min
- Wake team if >0.5 crash rate detected
- Daily standup attendance (even if no alerts)
- Escalate to leads if uncertain

**On-Call Support Number**: [Slack emergency channel #toriverse-oncall]

---

**Runbook Live**: Sep 11, 2026  
**Daily Standup**: 09:00 UTC (45 min)  
**Weekly Checkpoint**: 15:00 UTC Thursday  
**Review Cycle**: Every 24 hours
