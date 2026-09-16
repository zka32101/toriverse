# Week 1 Checkpoint Execution Script
## September 18, 2026 — Soft-Launch Gate Assessment

**Prepared**: 2026-09-16  
**Execution Date**: 2026-09-18  
**Duration**: 2-3 hours  
**Participants**: PM, Engineering Lead, QA Lead, Analytics Lead  
**Timezone**: UTC  

---

## 🎯 Objectives

1. **Assess Cohort 1 (QA) Results** — 5-10 internal testers (Sep 11-18)
2. **Evaluate Gate 1: Day 1 Retention ≥25%** — Firebase Analytics cohort analysis
3. **Evaluate Gate 4: 3-Human Match Rate ≥40%** — Match funnel tracking
4. **Prepare Cohort 3 Activation** — General Beta ramp (Sep 18+)
5. **Identify High-Priority Bugs** — Triage for hot-patch or code fix
6. **Brief Leadership** — Status update, risks, recommendations

---

## 📊 Pre-Checkpoint Prep (Sep 17, 09:00-17:00 UTC)

### Step 1: Firebase Analytics Snapshot (30 min)
**Owner**: Analytics Lead  
**Tool**: Firebase Console → Analytics  

```
1. Go to Firebase Console > Toriverse Project > Analytics
2. Set date range: Sep 11 - Sep 17, 2026 (7 days)
3. Cohort: Filter by [User Cohort] = "QA" (internal testers)
4. Export Dashboard:
   - Active Users by Day (DAU trend)
   - Retention (Day 1, Day 3, Day 7)
   - Session Duration
   - Session Frequency
   - Geographic distribution
5. Screenshot each dashboard → Save as `week1_analytics_qa_cohort.png`
```

**Expected Metrics** (Cohort 1 baseline):
- DAU: 5-10 users (internal)
- D1 Retention: Target ≥25%
- Avg Session: 8-15 min
- Match Completion Rate: Visible in funnel

### Step 2: Crashlytics Stability Review (20 min)
**Owner**: Engineering Lead  
**Tool**: Firebase Console > Crashlytics  

```
1. Go to Crashlytics > Crash-Free Rate
2. Set date range: Sep 11 - Sep 17
3. Record:
   - Overall Crash-Free Rate (Target: ≥99.5%)
   - Fatal Crashes (Count & Impact)
   - Non-Fatal Issues (Count & Impact)
   - Top 5 Crashes (by affected users)
4. If >0.5% crashes detected:
   - Identify pattern (device OS, feature, scenario)
   - Check if related to known Phase 16 issues
   - Prepare escalation if needed
```

### Step 3: Match Funnel Analysis (30 min)
**Owner**: Analytics Lead  
**Tool**: Firebase Analytics > Custom Events  

```
1. Go to Analytics > Events
2. Create/view "Match Funnel":
   - Event: match_started (should see 5-10 events)
   - Event: match_completed (should see >80% completion)
   - Event: player_abandoned_match (identify drop-off)
3. Calculate: 3-Human Match Rate = (full_human_matches / total_matches) * 100
4. Target: ≥40% (Cohort 1 goal)
5. If <40%: Likely AI fill-in is working as designed
```

### Step 4: Bug Triage Review (20 min)
**Owner**: QA Lead  
**Tool**: GitHub Issues  

```
1. Go to GitHub Issues (toriverse repo)
2. Filter: is:open label:testflight-cohort-1 label:critical
3. Count open CRITICAL bugs:
   - Each = immediate action needed (hot-patch or code fix)
   - Target: 0 blocking bugs before Cohort 3 ramp
4. Filter: label:testflight-cohort-1 label:high
5. Estimate fix time for top 3 HIGH bugs
```

---

## 📋 Checkpoint Day Procedure (Sep 18, 09:00-12:00 UTC)

### Meeting 1: Data Review (09:00-09:30 UTC)
**Attendees**: PM, Analytics Lead, Engineering Lead  
**Agenda**: Review pre-collected metrics  

**Talking Points**:
- "Day 1 Retention is at **X%** (Target: ≥25%)"
- "Crash-free rate: **X%** (Target: ≥99.5%)"
- "3-human match rate: **X%** (Target: ≥40%)"
- "Critical bugs blocking launch: **X** (Target: 0)"

**Decision Gate 1**: Do we proceed with Cohort 3 activation (Sep 18)?
```
✅ PROCEED if:
   - No critical crashes (or mitigated via hot-patch)
   - No data integrity issues
   - Cohort 1 stability acceptable
   
⚠️ HOLD if:
   - Crash rate >0.5%
   - Critical bugs blocking core gameplay
   - Data loss incidents reported
   
❌ ABORT if:
   - >2 data loss incidents
   - Unrecoverable crash pattern
   - Security breach discovered
```

### Meeting 2: Bug Triage & Fix Planning (09:30-10:30 UTC)
**Attendees**: Engineering Lead, QA Lead, PM  
**Agenda**: Prioritize fixes for next week  

**Triage Matrix**:
```
CRITICAL bugs:
  - Must fix before Cohort 3 ramp (TODAY if possible via hot-patch)
  - If hot-patchable: Apply Remote Config change, verify in <30 min
  - If code fix needed: Add to build 0.1.0+3 (due Sep 21)

HIGH bugs:
  - Fix in next 2 days (for Cohort 3 monitoring)
  - Add to build 0.1.0+3 if low-risk (<50 lines changed)

MEDIUM/LOW bugs:
  - Schedule for next sprint
  - OK to leave open during Cohort 3 expansion
```

**Action Items**:
```
□ Hot-patch deployments (if needed)
□ Code fixes for build 0.1.0+3
□ Assign engineers by EOD
```

### Meeting 3: Stakeholder Briefing (10:30-11:30 UTC)
**Attendees**: PM, Leadership, Analytics  
**Agenda**: Executive summary & go/no-go decision  

**Talking Points**:
1. "Cohort 1 soft-launch: 7 days, 5-10 testers"
2. "Key metrics: Day 1 Ret **X%**, Crash **X%**, 3-Human **X%**"
3. "Bugs identified: **X** critical, **Y** high"
4. "Fixes deployed: **Z** hot-patches, **W** code fixes pending"
5. "Recommendation: **PROCEED / HOLD / ABORT** Cohort 3 ramp"
6. "Timeline: Cohort 3 activation Sep 18 (today) if green"

**Decision**: Formal go/no-go on Cohort 3 activation

### Meeting 4: Cohort 3 Prep (11:30-12:00 UTC)
**Attendees**: PM, DevOps, QA  
**Agenda**: Launch Cohort 3 (General Beta, 30-50 testers)  

**Checklist**:
```
□ Verify TestFlight build is live (0.1.0+2)
□ Add Cohort 3 testers to TestFlight group
□ Verify Firebase Remote Config active for Cohort 3
□ Enable push notifications for Cohort 3
□ Brief QA on Cohort 3 monitoring procedures
□ Post announcement in Slack #toriverse-beta
```

**Announcement Template**:
```
🎉 Cohort 3 General Beta Activation - Sep 18, 2026

Cohort 1 (QA) soft-launch completed successfully.
30-50 general testers now activated on TestFlight.

Key expectations:
- Match formation may be slower (more users needed)
- AI fill-in compensates for low matchmaking
- Report bugs via in-app feedback
- ETA for Week 2 checkpoint: Sep 25

Thank you for testing! 🙏
```

---

## 📊 Success Criteria

| Gate | Target | Cohort 1 Result | Status |
|------|--------|-----------------|--------|
| Day 1 Retention | ≥25% | __ % | ☐ PASS / ☐ HOLD / ☐ FAIL |
| Crash-Free Rate | ≥99.5% | __ % | ☐ PASS / ☐ HOLD / ☐ FAIL |
| Aha Moment* | N/A (Week 2) | N/A | ☐ N/A |
| 3-Human Match* | N/A (Week 2) | N/A | ☐ N/A |

*Gates 2 & 3 evaluated at Week 2 checkpoint (Sep 25)

---

## 🚨 Contingency Procedures

### Scenario A: Crash Rate >0.5%
```
Timeline: Immediate (<30 min)

Actions:
1. Identify crashing feature via Crashlytics
2. Check if recent code change introduced regression
3. Options:
   a) Hot-patch: Disable feature via Remote Config
   b) Revert: Roll back to previous build
   c) Fast-fix: Code fix + new build in <2 hours
4. Re-deploy and verify crash rate drops
5. Document root cause
6. Proceed with Cohort 3 once stabilized (if same day)
   OR delay Cohort 3 to Sep 19 (if fix takes >4 hours)
```

### Scenario B: Day 1 Retention <25%
```
Timeline: 1 hour assessment

Actions:
1. Analyze retention curve (Day 1 is critical)
2. Identify drop-off point:
   - During onboarding? → UX issue
   - During first match? → Gameplay issue
   - After first match? → Aha moment not hit
3. Check if related to Aha Moment KPI (<60% reached reversal)
4. Decision:
   - If UX issue: Quick fix + Cohort 3 delayed
   - If Aha issue: Rebalance via Remote Config
   - If expected (small Cohort 1): Proceed with Cohort 3
5. Proceed or delay Cohort 3 activation
```

### Scenario C: 3-Human Match Rate <40%
```
Timeline: 30 min assessment

Actions:
1. Analyze match funnel:
   - How many matches have 3 humans without AI?
   - How many AI fill-ins needed?
2. Expected for Cohort 1 (only 5-10 testers):
   - Matchmaking with <10 users will need AI fills
   - <40% 3-human rate is EXPECTED and OK
3. Decision:
   - Cohort 1 is too small to judge; proceed
   - Cohort 3 (30-50 users) will have better rate
   - Proceed with Cohort 3 activation
```

### Scenario D: Critical Bug Blocking Gameplay
```
Timeline: Immediate (2 hours max decision)

Actions:
1. Verify bug severity (can user complete a match?)
2. If YES (workaround exists): Proceed with Cohort 3
   - Document workaround
   - Brief Cohort 3 testers
   - Add to hot-patch queue
3. If NO (unplayable): Delay Cohort 3
   - Apply hot-patch or code fix
   - Re-test
   - Activate Cohort 3 once unblocked (Sep 18-19)
```

---

## 📧 Post-Checkpoint Communications

### To QA Lead:
```
Subject: Week 1 Checkpoint Complete — Cohort 1 Wrap

Cohort 1 soft-launch: COMPLETE
- 7 days: Sep 11-18
- Testers: 5-10 internal
- Stability: [Metric]
- Go/no-go: [Decision]

Cohort 3 (General Beta) activated Sep 18.
Monitor for new user issues over next week.
Week 2 checkpoint: Sep 25 (all gates assessed).

Next: Daily standup continues at 09:00 UTC.
```

### To Leadership:
```
Subject: Soft-Launch Status — Week 1 Complete

Toriverse MVP (v0.1.0+2) soft-launch progressing on schedule.

✅ Cohort 1 (QA) Assessment Complete:
  - Day 1 Retention: X%
  - Crash-Free Rate: X%
  - 3-Human Match Rate: X%
  - Status: [PROCEED / HOLD / ABORT]

📅 Cohort 3 (General Beta) Activation: Sep 18
  - 30-50 testers onboarded
  - Timeline: Week 1 (Sep 18-25) → Week 2 (Sep 25-Oct 2)

🎯 Full Success Gate Assessment: Sep 25 (Week 2)
  - Day 1 Retention ≥25%
  - Crash-Free ≥99.5%
  - Aha Moment ≥60%
  - 3-Human Matches ≥40%

Next Checkpoint: Sep 25, 2026 (7 days)
```

### To Testers (Cohort 1):
```
Subject: Thank You — Cohort 1 Soft-Launch Complete

We've completed the first week of soft-launch testing.
Your feedback has been invaluable in identifying issues
and improving the experience.

📊 What We Learned:
  - [Key finding 1]
  - [Key finding 2]
  - [Key finding 3]

🚀 Next Phase:
  - General Beta (Cohort 3) launches today
  - You'll continue as internal testers
  - Continue reporting via in-app feedback

Thank you for helping shape Toriverse! 🎮
```

---

## ✅ Checkpoint Completion Checklist

**Pre-Checkpoint (Sep 17)**:
- ☐ Firebase Analytics data collected
- ☐ Crashlytics report pulled
- ☐ Match funnel analyzed
- ☐ Bug triage completed
- ☐ All dashboards exported

**Checkpoint Day (Sep 18)**:
- ☐ Data review meeting (09:00)
- ☐ Bug triage & fix planning (09:30)
- ☐ Leadership briefing (10:30)
- ☐ Cohort 3 activation decision made
- ☐ Cohort 3 testers onboarded
- ☐ Post-checkpoint comms sent

**After Checkpoint**:
- ☐ Daily standup resumes (Sep 19+)
- ☐ Hot-patches deployed (if needed)
- ☐ Build 0.1.0+3 development started (if code fixes needed)
- ☐ Week 2 monitoring intensified (Sep 25 checkpoint prep)

---

**Checkpoint Status**: 🔄 SCHEDULED for Sep 18, 2026 09:00 UTC  
**Next Phase**: Week 2 Monitoring (Sep 19-25) → Week 2 Checkpoint (Sep 25)
