# Post-Soft-Launch Monitoring Dashboards
## Phase 18 — Real-Time Analytics & Infrastructure Observability

**Prepared**: 2026-09-12  
**Monitoring Window**: Sep 11 - Oct 11, 2026 (30 days)  
**Update Frequency**: Real-time + Daily rollups  

---

## 🎯 Monitoring Objectives

1. **Validate Soft-Launch Success Gates**: Track 4 critical KPIs daily
2. **Early Warning System**: Detect anomalies (crashes, performance, retention cliff)
3. **Optimization Signals**: Identify features driving engagement + conversion
4. **Rollback Readiness**: Prepare hot-patches via Remote Config
5. **Data-Driven Iteration**: Weekly analysis → Remote Config adjustments

---

## 📊 Dashboard 1: Daily Active Users & Retention

### Metrics Tracked
```
Daily Active Users (DAU):
├─ Cohort 1 (Internal QA): Sep 11-18
├─ Cohort 2 (Content Creators): Sep 14-25
└─ Cohort 3 (General Beta): Sep 18 - Oct 2

Retention Cohorts:
├─ Day 1 Retention: % of Day 1 users returning Day 2
├─ Day 7 Retention: % of Day 1 users returning Day 7
├─ Day 30 Retention: % of Day 1 users returning Day 30
└─ Rolling: 7-day rolling retention (trailing)

Engagement Frequency:
├─ DAU / MAU ratio (measures stickiness)
├─ Average sessions per user per day
├─ Session length distribution
└─ Churn rate (5+ days inactive)
```

### Firebase Analytics Setup
```
Event: session_start (auto-tracked)
Event: session_end (auto-tracked)
Custom User Property: signup_cohort = ['qa', 'creator', 'general']
Custom User Property: signup_date = YYYY-MM-DD

Daily Query (BigQuery):
SELECT
  event_date,
  signup_cohort,
  COUNT(DISTINCT user_id) as daily_active_users,
  AVG(session_count) as avg_sessions_per_user
FROM events
WHERE event_name IN ('session_start', 'match_completed')
GROUP BY event_date, signup_cohort
ORDER BY event_date DESC
```

### Dashboard Layout
```
┌─ DAU Trend (Sep 11 - Oct 11)
│  ├─ Line chart: DAU over time
│  ├─ Colored by cohort (QA, Creators, General)
│  └─ Annotations: Cohort launch dates
│
├─ Retention Curves
│  ├─ Day 1: Expected 25%+
│  ├─ Day 7: Expected 15%+
│  ├─ Day 30: Expected 8%+ (if data available)
│  └─ Overlay historical games (for context)
│
├─ Session Frequency
│  ├─ Histogram: Sessions per user distribution
│  ├─ KPI: % users with 2+ sessions (target 70%+)
│  └─ KPI: % users with 5+ sessions (target 30%+)
│
└─ Churn Warning
   ├─ 5+ days inactive count (daily)
   ├─ Alert threshold: >30% of DAU (investigate)
   └─ Trend: Should decrease after Day 7
```

### Success Criteria
- ✅ Day 1 Retention ≥25%
- ✅ Day 7 Retention ≥15%
- ✅ DAU stable (no sudden drops >20% day-over-day)
- ✅ <30% churn by Day 7

---

## 🎮 Dashboard 2: Gameplay & Feature Adoption

### Metrics Tracked
```
Match Completion:
├─ Matches started (daily)
├─ Matches completed (daily)
├─ Match completion rate (target 95%+)
├─ Average match duration (target 8-12 min)
└─ Abandonment rate (stop before end)

Gameplay Features:
├─ Weak bonus triggered (event count + % of matches)
├─ Rescue card used (event count + % of matches)
├─ Collision events (same-square contested)
├─ AI fill rate (% matches with AI replacement)
└─ Process order diversity (uniform distribution check)

First Match Experience:
├─ Aha moment (reversal experienced): Target ≥60%
├─ Weak bonus in first match: Signal for engagement
├─ Time to first match: Target <5 minutes
└─ First match completion rate: Target ≥80%
```

### Firebase Analytics Setup
```
Events:
├─ match_started { match_id, duration_seconds }
├─ match_completed { player_rank, duration_seconds, reversal_experienced, ai_filled_count }
├─ weak_bonus_triggered { round_when_triggered, player_position_before, final_position }
├─ rescue_card_used { trigger_type, match_outcome }
├─ collision_resolved { players_involved, winner_selected }
└─ full_human_match_started { player_count }

Query (BigQuery):
SELECT
  event_date,
  COUNT(*) as matches_started,
  COUNT(IF(event_name = 'match_completed', 1, NULL)) as matches_completed,
  COUNT(IF(event_name = 'match_completed' AND reversal_experienced, 1, NULL)) as reversal_count,
  ROUND(COUNT(IF(reversal_experienced, 1, NULL)) / COUNT(*), 2) as reversal_rate
FROM events
WHERE event_name IN ('match_started', 'match_completed')
GROUP BY event_date
ORDER BY event_date DESC
```

### Dashboard Layout
```
┌─ Match Flow Funnel
│  ├─ Matches Started
│  ├─ Moves Submitted (by round)
│  ├─ Matches Completed
│  └─ KPI: Completion rate (target ≥95%)
│
├─ Feature Activation
│  ├─ Weak Bonus: % of matches with ≥1 trigger
│  ├─ Rescue Card: % of matches with ≥1 use
│  ├─ Collision: # events per day
│  └─ AI Fill: % matches with AI replacement
│
├─ Aha Moment Tracking
│  ├─ Reversal experienced: % of players
│  ├─ Breakdown by cohort
│  ├─ Reversal in first match: ≥60% target
│  └─ Timeline: When reversal occurs (which round)
│
└─ Match Duration
   ├─ Histogram: Distribution (target 8-12 min)
   ├─ Percentiles: p50, p75, p95
   └─ Alert: >20 min matches (investigate hang)
```

### Success Criteria
- ✅ Match completion rate ≥95%
- ✅ Aha moment (reversal) ≥60%
- ✅ Average match duration 8-12 minutes
- ✅ AI fill rate <60% (at least 40% full human matches)
- ✅ Weak bonus & rescue card activating regularly

---

## 💰 Dashboard 3: Monetization & Conversion

### Metrics Tracked
```
Rank Pass Conversion:
├─ Trial starts (daily)
├─ Trial-to-paid conversion
├─ Active subscriptions (cumulative)
├─ Conversion rate by day (Day 1, 2, 3, 7)
└─ Cohort comparison (QA vs. Creators vs. General)

Cosmetics Sales:
├─ Total transactions (daily)
├─ Revenue by cosmetic (stone vs. board)
├─ Revenue by price tier (¥120 vs. ¥300)
├─ Bundle effectiveness (3+ items)
└─ Repeat purchase rate (% who buy 2+)

ARPU & LTV Signals:
├─ Average Revenue Per User (ARPU)
├─ Lifetime Value estimate (LTV)
├─ % paying users (target 3-4%)
└─ Revenue per paying user
```

### RevenueCat Setup
```
Tracked Purchases:
├─ rank_pass_monthly (subscription)
├─ cosmetic_stone_* (5 variants, non-consumable)
├─ cosmetic_board_* (4 variants, non-consumable)

Event: purchase_completed
├─ Entitlement: rank_pass_monthly or cosmetic_*
├─ Price: ¥120-¥300
├─ Cohort: user signup_cohort
└─ Day: user DAU

Firebase Analytics:
├─ rankpass_converted { conversion_day, trial_to_paid }
├─ cosmetic_purchased { cosmetic_id, price, bundle_purchase }
└─ daily_arpu { daily_revenue, daily_active_users }
```

### Dashboard Layout
```
┌─ Revenue Trend
│  ├─ Daily revenue (line chart)
│  ├─ Cumulative revenue (area chart)
│  ├─ 7-day rolling average (trend line)
│  └─ Annotations: Cohort launches, promotions
│
├─ Conversion Funnel
│  ├─ Users who viewed Rank Pass: X%
│  ├─ Users who started trial: Y%
│  ├─ Trial-to-paid conversion: Z% (target ≥50%)
│  └─ Repeat subscription (renewal rate)
│
├─ Cosmetics Performance
│  ├─ Sales by item (bar chart, rank)
│  ├─ Revenue by price tier (¥120 vs. ¥300)
│  ├─ Bundle vs. single-item purchases
│  └─ Top performer highlight
│
└─ ARPU & Paying User %
   ├─ ARPU trend (should increase over time)
   ├─ Paying user %: Target 3-4%
   ├─ Revenue per paying user
   └─ Breakdown by cohort (who converts most)
```

### Success Criteria
- ✅ Paid conversion rate 3-4%
- ✅ Rank Pass trial-to-paid ≥50%
- ✅ Revenue per paying user ¥300+ (first pass purchase)
- ✅ Repeat purchase rate >20% (cosmetics)
- ✅ ARPU >¥50 by Day 30

---

## 🔴 Dashboard 4: Stability & Crashes

### Metrics Tracked
```
Crash Rate:
├─ Daily crashes (count)
├─ Crash-free rate %: Target ≥99.5%
├─ Critical crash threshold: 0.5%
├─ Affected users (unique)
└─ Session loss (matches interrupted)

Error Categories:
├─ Firestore connection errors (network)
├─ Firebase Auth failures (login)
├─ RevenueCat errors (purchase flow)
├─ Game logic errors (collision, bonus)
├─ UI/rendering crashes
└─ Memory/resource exhaustion

Performance Metrics:
├─ App startup time (target <2 sec)
├─ Home screen load (target <2 sec)
├─ Match board render (target <1 sec)
├─ Move submission latency (target <1 sec)
└─ Firestore sync latency p95 (target <500ms)
```

### Crashlytics Setup
```
Automatic Collection:
├─ Crash exception + stack trace
├─ Device: OS version, model, RAM
├─ Network: Connectivity state, latency
├─ User: signup_cohort, match_count
└─ Timestamp: Exact crash time

Custom Crash Tracking:
├─ Analytics.logEvent('game_logic_error', details)
├─ Analytics.logEvent('network_timeout', details)
├─ Analytics.logEvent('purchase_error', details)
└─ Severity levels: Critical, High, Medium, Low

Alert Configuration:
├─ Threshold: 0.5% crash-free (auto-alert)
├─ Frequency: Immediate on critical crash
├─ Channel: Slack #toriverse-alerts
└─ Escalation: Team leads if >1% crash rate
```

### Dashboard Layout
```
┌─ Crash-Free Rate (Primary KPI)
│  ├─ Large metric: X.XX% (target ≥99.5%)
│  ├─ Trend: 7-day rolling average
│  ├─ Color coding: 🟢 ≥99.5%, 🟡 95-99.5%, 🔴 <95%
│  └─ Alert: Auto-fires if <99.5%
│
├─ Crash Distribution
│  ├─ Top 10 crashes (by frequency)
│  ├─ Affected users (unique count)
│  ├─ Crash rate by OS (iOS vs. Android)
│  └─ Crash rate by device (check older devices)
│
├─ Error Categories
│  ├─ Pie chart: % by error type
│  ├─ Network errors: Firestore, FCM, RevenueCat
│  ├─ Game logic errors: Bonus, collision
│  └─ UI/Rendering crashes
│
└─ Performance Metrics
   ├─ Startup latency: p50, p75, p95
   ├─ Sync latency: p50, p75, p95 (should <500ms)
   ├─ Trend: Degradation warning if >10% slower
   └─ Device comparison: Flagship vs. budget
```

### Success Criteria
- ✅ Crash-free rate ≥99.5%
- ✅ No single crash >5% of total crashes (indicates spike)
- ✅ No new crash types appearing after Day 3
- ✅ Performance stable (no degradation trend)

---

## 📲 Dashboard 5: Social Features & Viral Coefficient

### Metrics Tracked
```
Clip Generation & Sharing:
├─ Clips generated (daily)
├─ Clip generation success rate (target 95%+)
├─ Clips shared (daily)
├─ Share rate (% of matches that generate clip)
└─ Average shares per clip (target 2+)

Viral Coefficient Signals:
├─ Friend invites sent (daily)
├─ Friend requests accepted (daily)
├─ Acceptance rate (target ≥50%)
├─ Returning players via friend invite
└─ Viral coefficient estimate: 0.3-0.5 range

Social Engagement:
├─ Leaderboard views (daily)
├─ Friend profile visits
├─ Direct messages sent
├─ Activity feed views
└─ % users with ≥1 friend
```

### Firebase Analytics Setup
```
Events:
├─ clip_generated { match_id, reversal_experienced }
├─ clip_shared { platform, clip_id }
├─ friend_invite_sent { invited_user_email_domain }
├─ friend_request_accepted { friendship_duration }
├─ leaderboard_viewed { time_spent_seconds }
└─ direct_message_sent { recipient_is_friend }

Query (BigQuery):
SELECT
  event_date,
  COUNT(IF(event_name = 'match_completed', 1, NULL)) as matches,
  COUNT(IF(event_name = 'clip_shared', 1, NULL)) as clips_shared,
  ROUND(COUNT(IF(event_name = 'clip_shared', 1, NULL)) / 
        COUNT(IF(event_name = 'match_completed', 1, NULL)), 2) as share_rate,
  COUNT(IF(event_name = 'friend_invite_sent', 1, NULL)) as invites_sent,
  COUNT(IF(event_name = 'friend_request_accepted', 1, NULL)) as friends_accepted
FROM events
WHERE event_date >= '2026-09-11'
GROUP BY event_date
ORDER BY event_date DESC
```

### Dashboard Layout
```
┌─ Clip Sharing Funnel
│  ├─ Matches completed: X
│  ├─ Clips generated: Y (target ≥95%)
│  ├─ Clips shared: Z (track platform breakdown)
│  └─ Share rate: Z/X (higher = better viral potential)
│
├─ Viral Coefficient Estimate
│  ├─ Friend invites per tester (calculate from events)
│  ├─ Acceptance rate (target ≥50%)
│  ├─ Viral loop: Invite → Accept → Play → Invite
│  └─ Coefficient trend (watch for growth signal)
│
├─ Social Engagement
│  ├─ % users with ≥1 friend (target 20%+ by Day 7)
│  ├─ Friend addition rate (new friends per day)
│  ├─ Direct messages per day
│  ├─ Leaderboard engagement (views, time spent)
│  └─ Activity feed: # views (passive social)
│
└─ Content Creator Signals (Cohort 2)
   ├─ Clips shared by creator (individual highlights)
   ├─ Clip with highest views (benchmark)
   ├─ Social media traffic (if trackable)
   └─ Influencer effect on Cohort 3 signups
```

### Success Criteria
- ✅ Clip share rate ≥15% (1 share per 6-7 matches)
- ✅ Friend acceptance rate ≥50%
- ✅ Viral coefficient 0.3-0.5 (each user invites 0.3-0.5 new users)
- ✅ % users with friends ≥20% by Day 7

---

## 📋 Dashboard 6: Soft-Launch Gates (Master KPI)

### The 4 Critical Gates
```
Gate 1: Day 1 Retention ≥25%
├─ Measurement: Cohort 3 analysis (Sep 19 data)
├─ Formula: (Users who open Day 2) / (Users who opened Day 1)
├─ Target: ≥25% (buffer above 15-20% baseline)
├─ Decision: PASS = Proceed to extended testing
└─ Decision: FAIL = Analyze + optimize weak bonus

Gate 2: Crash-Free Rate ≥99.5%
├─ Measurement: Crashlytics continuous monitoring
├─ Formula: (Non-crashing sessions) / (Total sessions)
├─ Target: ≥99.5% (allow <0.5% crash rate)
├─ Decision: PASS = Infrastructure stable
└─ Decision: FAIL = Hot-patch via Remote Config

Gate 3: Aha Moment (Reversal) ≥60%
├─ Measurement: Firebase Analytics reversal_experienced count
├─ Formula: (Matches with reversal) / (Total matches)
├─ Target: ≥60% (players experience dramatic turnaround)
├─ Decision: PASS = Simultaneous reveal mechanic validates
└─ Decision: FAIL = Increase weak bonus frequency

Gate 4: 3-Human Match Success ≥40%
├─ Measurement: AI fill count tracking
├─ Formula: (Matches with 0 AI fills) / (Total matches)
├─ Target: ≥40% (validates async architecture)
├─ Decision: PASS = Cold-start problem solved
└─ Decision: FAIL = Improve matchmaking time window
```

### Gate Assessment Dashboard
```
┌─ Gate 1: Day 1 Retention
│  ├─ Current: X% (updated Sep 19)
│  ├─ Status: 🟢 PASS / 🟡 WATCH / 🔴 FAIL
│  ├─ Trend: Improving / Stable / Declining
│  └─ Action: None / Monitor / Investigate
│
├─ Gate 2: Crash-Free Rate
│  ├─ Current: X.XX% (real-time)
│  ├─ Status: 🟢 PASS / 🟡 WATCH / 🔴 FAIL
│  ├─ Trend: Stable / Improving / Degrading
│  └─ Action: None / Monitor for spike / Hot-patch
│
├─ Gate 3: Aha Moment (Reversal)
│  ├─ Current: X% (daily updated)
│  ├─ Status: 🟢 PASS / 🟡 WATCH / 🔴 FAIL
│  ├─ Trend: Strong / Stable / Weak
│  └─ Action: None / Monitor / Tune weak bonus
│
└─ Gate 4: 3-Human Match Success
   ├─ Current: X% (AI fill analysis)
   ├─ Status: 🟢 PASS / 🟡 WATCH / 🔴 FAIL
   ├─ Trend: Improving / Stable / Declining
   └─ Action: None / Monitor / Extend matchmaking window
```

### Weekly Gate Assessment (Sep 18, 25, Oct 2)
```
Week 1 (Sep 18):
├─ Cohort 1 (QA): All tests passed
├─ Day 1 retention: Measuring (Cohort 3 launching)
├─ Crashes: Monitor for spikes
└─ Decision: Continue to Week 2

Week 2 (Sep 25):
├─ Day 7 retention: Analyze (if sufficient data)
├─ Aha moment: Evaluate reversal rate
├─ Viral coefficient: Assess clip sharing + friends
└─ Decision: Continue, optimize, or pivot

Week 3 (Oct 2):
├─ Full retention analysis (Day 7-14)
├─ All gates assessed
├─ Cumulative metrics: Are we on track?
└─ Decision: Proceed to public launch or iterate
```

---

## 🔧 Infrastructure Setup

### Firebase Console Configuration

**Analytics Dashboard**:
```
1. Create custom dashboard: "Toriverse Soft-Launch"
2. Add cards:
   - DAU chart (cohort breakdown)
   - Retention curve (Day 1, 7, 30)
   - Aha moment rate (reversal event)
   - Match completion rate
   - Revenue (if monetization live)
3. Set date range: Sep 11 - Oct 11
4. Auto-refresh: 1 hour
```

**Crashlytics Console**:
```
1. Enable email alerts: #toriverse-alerts Slack
2. Set alert threshold: 0.5% crash-free rate
3. Create alert rule: "Crash spike" (2x increase in 1 hour)
4. Enable Jira integration (if available)
5. Set filter: Show crashes by cohort (signup_cohort custom user property)
```

**Remote Config Console**:
```
1. Create targeting conditions:
   - app_version = "0.1.0+2"
   - signup_cohort IN ["qa", "creator", "general"]
2. Deploy default config:
   - weak_bonus_threshold: 0.20
   - rescue_card_consecutive: 2
   - move_window_seconds: 30
   - daily_free_matches: 1
3. Create variants (ready for hot-patch):
   - weak_bonus_threshold_v2: 0.25 (if aha <60%)
   - daily_free_matches_v2: 2 (if retention <15%)
```

**BigQuery for Advanced Analysis**:
```
1. Create dataset: toriverse_analytics
2. Link Firebase export: games.events → toriverse_analytics.firebase_events
3. Create views:
   - daily_retention (cohort analysis)
   - match_funnel (completion rate)
   - revenue_breakdown (by cosmetic/pass)
4. Schedule queries (daily 02:00 UTC):
   - Retention update
   - Feature adoption report
   - Crash analysis
```

---

## 📞 On-Call Procedures

### Escalation Path
```
Level 1 (Monitoring Alert):
├─ Time: Immediate (automated alert)
├─ Trigger: Crash-free <99.5% OR DAU drop >20%
├─ Response: Check dashboards, assess severity
└─ Owner: On-call engineer

Level 2 (Severe Issue):
├─ Time: <1 hour
├─ Trigger: Critical crash (>2% rate), revenue broken, matches not completing
├─ Action: Prepare hot-patch, notify leads
└─ Owner: Lead engineer + Product

Level 3 (Business Decision):
├─ Time: <4 hours
├─ Trigger: Soft-launch gate at risk (Day 1 retention <25%, crash >1%)
├─ Action: Assess rollback, communicate with testers
└─ Owner: Product manager + Leadership
```

### Hot-Patch Procedures (Remote Config)
```
Scenario 1: Aha Moment <60% (reversal not common)
├─ Root cause: Weak bonus threshold too high
├─ Fix: Deploy remote_config weak_bonus_threshold = 0.25 (lower bar)
├─ Verification: Monitor reversal event rate
├─ Rollback: Restore to 0.20 if negative effect
└─ Timeline: 30 min to deploy, 2 hours to verify

Scenario 2: Day 1 Retention <25%
├─ Root cause: Unclear (investigate)
├─ Fix A: Increase daily_free_matches = 2 (if gate pressure)
├─ Fix B: Adjust notification timing (if engagement)
├─ Fix C: Tune weak bonus (if aha not compelling)
├─ Timeline: Analysis 4 hours, deploy 30 min, verify 24 hours

Scenario 3: Crash Rate >1%
├─ Root cause: Specific crash spike (identify via Crashlytics)
├─ Fix: Disable problematic feature via Remote Config
├─ Example: disable_collision_resolution = true (if collision crashes)
├─ Timeline: 15 min diagnosis, 30 min deploy, immediate verification
└─ Parallel: Begin code fix for next build
```

---

## 📅 Daily Standup Report

### Template (Email Every 09:00 UTC)
```
Subject: Toriverse Soft-Launch Daily Standup — {Date}

📊 KPI Status (24-hour snapshot):
├─ DAU: {count} ({±% change from yesterday})
├─ Day 1 Retention (rolling): {%}
├─ Crash-Free Rate: {%.02f}% (🟢 PASS / 🟡 WATCH / 🔴 ALERT)
├─ Aha Moment Rate: {%} (reversal_experienced)
├─ Matches Completed: {count} (completion rate: {%})
├─ Revenue (if live): ¥{total} ({customer count})
└─ Critical Issues: {0 / count}

🎮 Gameplay Insights:
├─ Weak Bonus Activation: {% of matches}
├─ Rescue Card Usage: {% of matches}
├─ AI Fill Rate: {%} (target <60%)
├─ Full 3-Human Matches: {% of total}
└─ Average Match Duration: {MM:SS}

💬 Social & Growth:
├─ Friend Invites Sent: {count}
├─ Friend Acceptance Rate: {%}
├─ Clips Shared: {count} (share rate: {%})
├─ Leaderboard Engagement: {activity metric}
└─ Viral Coefficient Estimate: {0.XX}

🔴 Alerts & Issues:
├─ [CRITICAL] {description} — Action: {owner}
├─ [HIGH] {description} — Action: {owner}
├─ [MEDIUM] {description} — Action: {owner}
└─ Crash spikes, performance degradation, feature not working

📅 Schedule:
├─ Next Gate Assessment: {date}
├─ Planned Remote Config Adjustments: {if any}
└─ Next Standup: Tomorrow 09:00 UTC

Prepared by: {name}
Dashboard: [Firebase Analytics Link]
Crashlytics: [Crashlytics Dashboard Link]
```

---

## 🎯 Success Tracking

### Phase 18 Completion Criteria
- [x] All monitoring dashboards configured in Firebase
- [x] Alerting thresholds set (crash-free, DAU, retention)
- [x] Remote Config hot-patch templates prepared
- [x] On-call procedures documented
- [x] Daily standup automation ready
- [x] BigQuery queries for advanced analysis
- [x] Gate assessment framework documented

### Next Phase (Phase 19)
**Monitor & Iterate** (Sep 11 - Oct 2):
- Daily dashboard reviews
- Weekly gate assessments
- Hot-patch deployment as needed
- Tester feedback collection
- Feature optimization based on signals

---

**Dashboard Ready**: Sep 12, 2026  
**Monitoring Live**: Sep 11 - Oct 11, 2026  
**Next Review**: Daily 09:00 UTC
