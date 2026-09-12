# Remote Config Hot-Patch Playbooks
## Phase 18 — Data-Driven Optimization & Issue Response

**Prepared**: 2026-09-12  
**Playbooks Ready**: Sep 11, 2026  
**Implementation Window**: Sep 11 - Oct 2, 2026  

---

## 🎯 Hot-Patch Philosophy

**Goal**: Deploy game tuning changes instantly without app rebuild, measured by Remote Config values.

**Process**:
1. Monitor dashboards → Identify signal
2. Root cause analysis → Hypothesis formation
3. Remote Config value change → Deploy instantly
4. Measure impact → Verify 2-4 hours
5. Iterate or rollback → Refine based on data

**Advantage**: No app update needed, fast feedback loops, user doesn't need to reinstall.

**Constraint**: Only values in Remote Config are patchable; code logic requires app update.

---

## 📋 Playbook 1: Low Day 1 Retention (<25%)

### Symptoms
```
Alert: Day 1 Retention <25% (target ≥25%)
├─ Measurement: (Users who opened Day 2) / (Users who opened Day 1)
├─ Detected: Sep 19 morning (24 hours of Cohort 3 data)
├─ Impact: Suggests Aha moment not compelling or engagement not sustained
└─ Severity: 🔴 CRITICAL (go/no-go gate at risk)
```

### Root Cause Analysis (4 hours)
```
Hypothesis 1: Weak Bonus Not Triggering Often Enough
├─ Signal to check: weak_bonus_triggered event rate (target ≥20%)
├─ If <20%: Weak bonus threshold too strict
└─ Fix: Lower weak_bonus_threshold from 0.20 → 0.25

Hypothesis 2: Aha Moment (Reversal) Not Achieved
├─ Signal to check: reversal_experienced rate in first match (target ≥60%)
├─ If <60%: Players not experiencing turnaround
└─ Fix: Lower weak_bonus_threshold + increase weak_bonus_magnitude

Hypothesis 3: Daily Match Gate Frustrating Users
├─ Signal to check: users_reaching_daily_limit event (count)
├─ If >10%: Free tier gate pressure too high
└─ Fix: Increase daily_free_matches from 1 → 2

Hypothesis 4: Notification Timing Wrong
├─ Signal to check: push_notification_open_rate
├─ If <30%: Users ignoring "Results Ready" notifications
└─ Fix: Change notification_delay_seconds or message text (code change)

Hypothesis 5: Onboarding Too Long
├─ Signal to check: time_to_first_match (target <5 min)
├─ If >5 min: Tutorial overwhelming
└─ Fix: Shorten onboarding steps (code change, requires app update)
```

### Patch Implementation (30 min)

**Option A: Weak Bonus Threshold**
```
Remote Config Value: weak_bonus_threshold

Current: 0.20 (bottom 20% by stone count)
Proposed: 0.25 (bottom 25% by stone count — easier to trigger)

Firebase Console:
1. Navigate to Remote Config
2. Find parameter: weak_bonus_threshold
3. Edit → Value: 0.25
4. Add description: "Lower threshold to increase Aha moment rate (Sep 19 retention low)"
5. Create new version
6. Deployment:
   ├─ Audience: All (app_version = "0.1.0+2")
   ├─ Rollout: 100% (immediate)
   └─ Validation: Monitor weak_bonus_triggered rate next 2 hours

Expected Impact:
├─ weak_bonus_triggered rate: 20% → 30%+ of matches
├─ reversal_experienced rate: Should increase
├─ Session length: May increase (longer gameplay)
└─ Measurement: Check daily standup Sep 20
```

**Option B: Daily Free Matches (if gate pressure)**
```
Remote Config Value: daily_free_matches

Current: 1 (one ranked match per day)
Proposed: 2 (two ranked matches per day, more generous)

Impact:
├─ Removes frustration for engaged users
├─ May reduce Rank Pass conversion short-term
├─ Likely improves Day 1 retention (more engagement)
└─ Trade-off: Accept lower ARPU for higher retention

Deployment: Same process as Option A
Timeline: Deploy if weak bonus patch doesn't improve retention
```

### Measurement (2-4 hours post-patch)

```
Metrics to Monitor (Real-time):
├─ weak_bonus_triggered event rate (should increase)
├─ reversal_experienced rate (should increase)
├─ Match completion rate (should stay ≥95%)
├─ Session length (may increase)
├─ DAU stability (should not drop)
└─ Crash rate (should stay ≥99.5%)

Query (Firebase Analytics):
SELECT
  event_date,
  event_time_millis,
  COUNT(IF(event_name = 'weak_bonus_triggered', 1, NULL)) as bonuses,
  COUNT(IF(event_name = 'match_completed', 1, NULL)) as matches,
  ROUND(COUNT(IF(event_name = 'weak_bonus_triggered', 1, NULL)) / 
        COUNT(IF(event_name = 'match_completed', 1, NULL)), 2) as bonus_rate
FROM events
WHERE event_date >= '2026-09-19' AND event_time_millis >= TIMESTAMP('2026-09-19 12:00:00')
GROUP BY event_date, HOUR(event_time_millis)
ORDER BY event_time_millis DESC

Decision Tree:
├─ Bonus rate ↑ 30%+: GOOD, continue monitoring
├─ Bonus rate ↑ 10-30%: PARTIAL, prepare secondary patch
├─ Bonus rate unchanged: INEFFECTIVE, try Option B or code change
└─ Reversal rate ↑ 50%+: EXCELLENT, weak bonus now driving Aha moment
```

### Rollback Procedure (if negative)

```
Trigger: Session length decreased >10% OR reversal rate decreased

Rollback in Firebase Console:
1. Navigate to Remote Config versions
2. View change: weak_bonus_threshold 0.20 → 0.25
3. Select "Revert to previous version" (or manually revert)
4. Confirm rollback
5. Deployment: 100% immediate

Expected: weak_bonus_triggered rate returns to baseline within 5 min
Post-mortem: Was threshold not the issue; investigate other hypotheses
```

---

## 📋 Playbook 2: High Crash Rate (>0.5%)

### Symptoms
```
Alert: Crash-Free Rate <99.5%
├─ Measurement: Crashlytics auto-alert
├─ Detected: Immediate (real-time alert)
├─ Impact: User experience severely degraded
└─ Severity: 🔴 CRITICAL (go/no-go gate failure)
```

### Root Cause Analysis (15 min)

```
Crashlytics Dashboard Investigation:
1. Check "Top Crashes" list
2. Identify most common crash:
   ├─ Stack trace shows specific error
   ├─ Affected users: Count
   ├─ Percentage of total crashes: %
   └─ Introduced when: (compare to recent changes)

Likely Candidates:
├─ Collision resolution crash (if collision logic error)
├─ Weak bonus crash (if bonus calculation overflow)
├─ AI move generation crash (if AI hangs/errors)
├─ Firestore read crash (if network timeout unhandled)
├─ RevenueCat crash (if purchase flow broken)
└─ UI render crash (if memory pressure)

Quick Fix via Remote Config:
├─ disable_collision_resolution = true (if collision crashing)
├─ disable_weak_bonus = true (if bonus crashing)
├─ disable_ai_fill = false (can't disable, fallback to human wait)
├─ disable_revenuecat = false (breaks monetization, not viable)
└─ {feature}_disabled = true (generic feature flag)
```

### Patch Implementation (30 min)

```
Scenario: Collision Resolution Crashes (Top Crash #1)

Root Cause: When 3 players submit to same square, collision logic has null pointer
Solution: Disable collision feature until fix is deployed in next app build

Remote Config Values:
├─ enable_collision_resolution: true → false
├─ collision_fallback_behavior: "random_draw" (no change)

Firebase Console:
1. Create new parameter: enable_collision_resolution (boolean)
2. Set value: false
3. Description: "Disabled Sep 19 due to NullPointerException in collision logic"
4. Deployment:
   ├─ Audience: app_version = "0.1.0+2"
   ├─ Rollout: 100% immediate
   └─ Validation: Monitor crash rate next 15 min

Expected Impact:
├─ Crash rate: 2% → <0.5% (if collision was primary crash)
├─ Collision events: Stop occurring
├─ Gameplay: No same-square submission allowed (prevents collision)
└─ User experience: "Position already taken" error shown instead of crash
```

### Measurement (15 min post-patch)

```
Immediate Metrics:
├─ Crash-free rate (should jump to >99.5% within 15 min)
├─ Affected crash count (should drop to near-zero)
├─ Stability alert (should clear)
└─ Session loss (should stop increasing)

Crashlytics Dashboard:
1. View "Crash-Free Rate" card
2. Confirm >99.5% after 15 min window
3. Verify collision crash no longer in top 10 crashes

Decision:
├─ Crash rate fixed: Prepare code fix for next build
├─ Crash rate not fixed: Investigate next top crash
└─ If collision was secondary crash: Disable it anyway (preventive)

Parallel Work:
├─ Assign engineer to fix collision NullPointerException
├─ Code fix tested + merged (before next build)
├─ Target: Fix in next build 0.1.0+3 (if needed)
```

### Rollback Procedure (if fix breaks gameplay)

```
Trigger: Player reports "can't play" after collision disabled

Rollback Steps:
1. Firebase Console → Remote Config
2. Set enable_collision_resolution: true
3. Deployment: 100% immediate

Rationale: If collision is always crashing, disabling helps crash-free
User Experience: Collision still crashes, but let users submit to same square
           → Fallback: First to submit wins, losers see "Position taken"
           → No crash, seamless experience

Better Solution: Code fix + new build (not a hot-patch situation)
```

---

## 📋 Playbook 3: Low Aha Moment Rate (<60%)

### Symptoms
```
Alert: Reversal Experience Rate <60%
├─ Measurement: reversal_experienced event count (target ≥60%)
├─ Detected: Daily analysis (Sep 12-19)
├─ Impact: Core game mechanic not delivering emotional moment
└─ Severity: 🟡 HIGH (Aha moment is retention driver)
```

### Root Cause Analysis (2 hours)

```
Question 1: Is Weak Bonus Triggering?
├─ Check: weak_bonus_triggered event rate
├─ If ≥20% of matches: Bonus is working
├─ If <20%: Weak bonus threshold too strict, OR
│  └─ Players not reaching score disparity condition

Question 2: When Weak Bonus Triggers, Does It Cause Reversal?
├─ Check: weak_bonus_triggered → final_position data
├─ If player finishes 1st after bonus: Bonus is effectively creating reversal
├─ If player still finishes 3rd: Bonus bonus too weak to impact outcome

Question 3: Do Non-Bonus Matches Have Reversals?
├─ Check: Match completed with reversal_experienced but no weak_bonus
├─ If high %: Reversals happening naturally (good game design)
├─ If low %: Reversals depend entirely on weak bonus
```

### Patch Implementation Options

**Option A: Lower Weak Bonus Threshold (easier to qualify)**
```
Parameter: weak_bonus_threshold
Current: 0.20 (bottom 20% by stone differential)
Proposed: 0.25 (bottom 25%)

Rationale: Players in bottom 25% more likely to get bonus, more chances for reversal
Timeline: Deploy immediately, measure 4 hours
Risk: May be perceived as too generous (gameplay balance)
```

**Option B: Increase Weak Bonus Effect (bigger impact)**
```
Parameter: weak_bonus_magnitude (new parameter)
Current: +1 stone per trigger (or inherent in game logic)
Proposed: +2 stones per trigger (stronger effect)

Rationale: Bonus has bigger impact on final outcome, more likely to cause reversal
Timeline: Deploy immediately, measure 4 hours
Risk: May feel like heavy-handed catch-up; skilled players may feel cheated

Note: This may require code change if magnitude is hard-coded. If so, requires app update.
```

**Option C: Increase Bonus Frequency (more opportunities)**
```
Parameter: weak_bonus_max_activations (per match)
Current: 2 (max 2 activations per match)
Proposed: 3 (max 3 activations per match)

Rationale: Underdog gets more chances to flip board
Timeline: Deploy immediately, measure 4 hours
Risk: May go too far toward catch-up mechanics; skilled gameplay devalued
```

**Option D: No Remote Config Needed — It's a Balance Issue**
```
Scenario: Weak bonus is working fine, but players just have high variance
Explanation: In 3-player game, leader changes frequently naturally
Solution: This may NOT need a fix. Analyze further:
  ├─ reversal_experienced definition: Did they come from 3rd to 1st?
  ├─ OR just go from last to any other position?
  ├─ If first definition: Rare and acceptable for a game mechanic
  ├─ If second definition: Should be higher, check calculation

Action: Verify event definition before patching
```

### Measurement (4 hours post-patch)

```
Target Metric:
├─ reversal_experienced rate: 60% → 75%+ (15% improvement)
├─ weak_bonus_triggered rate: Should align with reversal rate
├─ Match completion: Should stay ≥95%
└─ Player enjoyment signals: Session length, match replays

Query:
SELECT
  event_date,
  COUNT(IF(event_name = 'match_completed' AND reversal_experienced, 1, NULL)) as reversals,
  COUNT(IF(event_name = 'match_completed', 1, NULL)) as total_matches,
  ROUND(COUNT(IF(reversal_experienced, 1, NULL)) / COUNT(*), 2) as reversal_rate
FROM events
WHERE event_date >= '2026-09-12'
GROUP BY event_date
ORDER BY event_date DESC
```

---

## 📋 Playbook 4: Low 3-Human Match Success (<40%)

### Symptoms
```
Alert: AI Fill Rate >60%
├─ Measurement: (Matches with ≥1 AI player) / (Total matches)
├─ Detected: Daily analysis (Sep 11+)
├─ Impact: Suggests players disconnecting OR matchmaking too fast (filling with AI)
└─ Severity: 🟡 HIGH (critical risk #1 mitigation)
```

### Root Cause Analysis (2 hours)

```
Question 1: Are Players Disconnecting?
├─ Check: user_disconnected event count
├─ If high: Network issues OR app crashes
├─ If low: Intentional quit (not engaging with wait)

Question 2: Are Players Timing Out During Matchmaking?
├─ Check: time_to_match_start metric (how long waiting)
├─ If >30 sec average: Too slow, impatient users quit
├─ If <10 sec average: Very fast matchmaking (good signal)

Question 3: Is AI Fill Happening Too Quickly?
├─ Check: AI_auto_fill_delay (internal parameter, may not be trackable)
├─ If filled <5 sec: May be too aggressive (don't wait for real players)
├─ If filled >15 sec: Wait too long, matchmaking feels slow
```

### Patch Implementation

**Option A: Extend Matchmaking Wait Time (give real players more time)**
```
Parameter: matchmaking_wait_seconds_before_ai_fill

Current: 10 seconds (AI fills after 10 sec wait)
Proposed: 15-20 seconds (give more time for real players to join)

Rationale: More time = higher chance of finding 3rd human player
Timeline: Deploy immediately, measure 4-6 hours
Risk: Longer wait frustrates some users; increased abandonment before match start

Measurement:
├─ Time to match start: Should increase (expected)
├─ AI fill rate: Should decrease (expected)
├─ User abandonment during matchmaking: Monitor for increase
└─ Decision: If abandonment >10%, revert to 10 sec
```

**Option B: Adjust Matchmaking Pools (geographic/skill-based)**
```
Note: This may require code change if not already dynamic

Parameter: matchmaking_pool_size (how many queues to search)

Current: 1 pool (anyone)
Proposed: Expand search to 2 pools (if different matchmaking groups exist)

Rationale: Broader search = more human players to match
Timeline: Depends on implementation complexity
```

**Option C: Incentivize Staying (Reward for 3-Human Matches)**
```
Parameter: full_human_match_reward (bonus for 3-human match)

Current: 0 (no bonus)
Proposed: +10 rank points bonus if match has 3 humans

Rationale: Users know reward for playing with humans; incentivizes waiting
Timeline: Deploy immediately, measure 4 hours
Measurement: Track full_human_match_rate (should increase)
```

### Measurement (4-6 hours post-patch)

```
Primary Metric:
├─ AI fill rate: >60% → 40%+ (at least 40% full 3-human matches)
├─ Matchmaking wait time: Should increase slightly
├─ User abandonment during queue: Monitor for spikes

Query:
SELECT
  event_date,
  COUNT(IF(event_name = 'match_completed' AND ai_filled_count = 0, 1, NULL)) as full_human,
  COUNT(IF(event_name = 'match_completed', 1, NULL)) as total_matches,
  ROUND(COUNT(IF(ai_filled_count = 0, 1, NULL)) / COUNT(*), 2) as full_human_rate
FROM events
WHERE event_date >= '2026-09-11'
GROUP BY event_date
ORDER BY event_date DESC

Decision:
├─ full_human_rate ≥40%: SUCCESS, gate passed
├─ full_human_rate 30-40%: MARGINAL, may still pass if other gates strong
├─ full_human_rate <30%: FAIL, consider multiplayer redesign
```

---

## 📋 Playbook 5: Low Paid Conversion (<3%)

### Symptoms
```
Alert: Paid Conversion Rate <3%
├─ Measurement: (Users who purchased anything) / (Active users)
├─ Detected: Daily analysis (Sep 11+)
├─ Impact: Monetization not compelling
└─ Severity: 🟡 HIGH (business impact, but not blocking launch)
```

### Root Cause Analysis (2 hours)

```
Question 1: Are Users Even Seeing the Shop?
├─ Check: shop_viewed event count
├─ If low <5%: Shop not discoverable from home screen
├─ If high >30%: Shop visible but not compelling

Question 2: Are Users Reaching Daily Match Limit?
├─ Check: users_reached_daily_limit event count
├─ If high >20%: Free tier gate is pressure, creating Rank Pass interest
├─ If low <5%: Users not playing enough to encounter limit

Question 3: Do Rank Pass Trials Convert?
├─ Check: rankpass_trial_started vs. rankpass_converted
├─ If conversion >50%: Trial → Paid working well
├─ If conversion <30%: Trial not convincing

Question 4: Are Cosmetics Appealing?
├─ Check: cosmetic_purchased count + feedback
├─ If near-zero: Cosmetics not desirable (aesthetic issue?)
├─ If healthy: Cosmetics selling but low base (small user pool)
```

### Patch Implementation (Focus on Rank Pass Since It's Higher Value)

**Option A: Make Daily Limit Trigger Earlier (Or More Obviously)**
```
Parameter: daily_free_matches

Current: 1 (one ranked match per day)
Proposed: Trial with 1 or keep as-is, but enhance gate message

Rationale: Earlier gate pressure → more Rank Pass trials → conversions
Timeline: Deploy immediately if changing the value
Cost: May reduce organic rank pass engagement
```

**Option B: Improve Rank Pass Value Perception (Copy Change)**
```
Note: This may require code change if message is hard-coded

Current: "Unlimited ranked matches + 1.5x multiplier"
Proposed: Add more value perception: "Unlimited ranked + 1.5x multiplier + exclusive cosmetics + special badge"

Timeline: Code change required (requires app update)
```

**Option C: Strategic Pricing / Trial Length**
```
Parameter: rankpass_trial_duration_days

Current: 3 days free (typical)
Proposed: 7 days free (longer hook to conversion)

Rationale: Users have more time to feel value
Timeline: Deploy immediately, measure 7 days
Risk: Fewer conversions if users don't feel pressure to convert
```

### Measurement (7 days post-patch)

```
Metrics:
├─ rankpass_trial_started: Count of trials
├─ rankpass_converted: Count of trial→paid
├─ Conversion rate: Should be ≥50% target
├─ Revenue per user: Track ARPU trend

Query:
SELECT
  event_date,
  COUNT(IF(event_name = 'rankpass_trial_started', 1, NULL)) as trials,
  COUNT(IF(event_name = 'rankpass_converted', 1, NULL)) as converts,
  ROUND(COUNT(IF(event_name = 'rankpass_converted', 1, NULL)) / 
        COUNT(IF(event_name = 'rankpass_trial_started', 1, NULL)), 2) as conversion_rate
FROM events
WHERE event_date >= '2026-09-11'
GROUP BY event_date
ORDER BY event_date DESC

Decision:
├─ Conversion >50%: GOOD, Rank Pass positioning working
├─ Conversion 30-50%: MODERATE, consider copy/UX changes
├─ Conversion <30%: POOR, investigate further or adjust terms
```

---

## 🎬 Implementation Workflow

### Step-by-Step Deployment

```
1. Identify Signal (1-2 hours)
   ├─ Dashboard shows metric below target
   ├─ Root cause analysis
   └─ Hypothesis formed

2. Prepare Patch (30 min)
   ├─ Determine which Remote Config parameter to change
   ├─ Calculate new value (small adjustment, 10-20% change)
   ├─ Write change justification

3. Deploy (15 min)
   ├─ Firebase Console → Remote Config
   ├─ Edit parameter → New value
   ├─ Add description + date + reason
   ├─ Create version
   ├─ Set rollout: 100%, immediate
   └─ Save

4. Verify (15 min - 4 hours)
   ├─ Monitor dashboard for change
   ├─ Check event rate within 15 min
   ├─ Confirm no negative side effects
   └─ Log result in standup

5. Analyze (1-2 hours post-patch)
   ├─ Query events for impact
   ├─ Calculate success metrics
   ├─ Compare to hypothesis
   ├─ Decide: keep, adjust further, or rollback

6. Iterate or Rollback (30 min if needed)
   ├─ If successful: Continue monitoring
   ├─ If partial: Deploy follow-up patch
   ├─ If failed: Rollback + investigate alternative
```

---

## 📞 Escalation Matrix

```
Playbook 1: Low Retention (<25%)
├─ Response Time: 4 hours from detection
├─ Urgency: 🔴 CRITICAL (go/no-go gate)
└─ Escalation: Product lead + Engineering lead

Playbook 2: High Crashes (>0.5%)
├─ Response Time: 30 min from detection
├─ Urgency: 🔴 CRITICAL (blocks all gameplay)
└─ Escalation: Engineering lead + On-call

Playbook 3: Low Aha Moment (<60%)
├─ Response Time: 2-4 hours from detection
├─ Urgency: 🟡 HIGH (retention risk)
└─ Escalation: Product lead

Playbook 4: Low 3-Human Matches (<40%)
├─ Response Time: 4-6 hours from detection
├─ Urgency: 🟡 HIGH (go/no-go gate)
└─ Escalation: Product lead + Engineering lead

Playbook 5: Low Conversion (<3%)
├─ Response Time: 24 hours from detection
├─ Urgency: 🟡 MEDIUM (business impact, not blocking)
└─ Escalation: Product lead
```

---

## 📋 Patch Deployment Log Template

```
Date: 2026-09-{DD}
Time: {HH}:{MM} UTC
Deployer: {Name}

Patch Description:
├─ Parameter: {remote_config_parameter_name}
├─ Change: {old_value} → {new_value}
├─ Reason: {Playbook #}: {description}
└─ Expected Impact: {metric} should increase/decrease by X%

Pre-Deployment Verification:
├─ Root cause analysis complete: ✅
├─ Hypothesis documented: ✅
├─ Rollback plan ready: ✅
└─ Team notified: ✅

Deployment Details:
├─ Audience: app_version = "0.1.0+2"
├─ Rollout: 100% immediate
├─ Start Time: {UTC timestamp}
└─ Deployed By: Firebase Console URL: [link]

Immediate Results (T+15 min):
├─ Metric 1: {value} (expected: {target})
├─ Metric 2: {value} (expected: {target})
├─ Side Effect 1: {observation}
└─ Status: 🟢 ON TRACK / 🟡 PARTIAL / 🔴 ROLLBACK

Analysis (T+2-4 hours):
├─ Success: YES / NO / PARTIAL
├─ Quantified Impact: {metric} improved {X}%
├─ Next Action: Monitor / Iterate / Rollback
└─ Decision: KEEP / ADJUST / REVERT

Outcome (Next Standup):
├─ Final Status: SUCCESS / FAILURE / NEUTRAL
├─ Lessons Learned: {insights}
└─ Follow-up Actions: {next steps if needed}
```

---

**Playbooks Ready**: Sep 12, 2026  
**Ready to Deploy**: Anytime during Sep 11 - Oct 2  
**Maximum Deploy Time**: 30 min (dashboard detection to live)
