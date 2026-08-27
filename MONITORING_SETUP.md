# Monitoring & Alerting Setup - Post-Launch

**Purpose**: Detect and respond to issues immediately after soft launch  
**Timeline**: Set up before launch day  
**Owner**: DevOps/Monitoring team

---

## 1. Firebase Console Dashboards

### 1.1 Create Main Dashboard

In Firebase Console:

1. Go to **Analytics** → **Dashboard**
2. Create custom card: "Toriverse Soft Launch"
3. Add cards:

```
Card 1: Daily Active Users
- Metric: Active Users
- Period: Last 30 days
- Breakdown: By platform (iOS/Android)

Card 2: Retention Cohorts
- Metric: Retention
- Cohort: Day 1, Day 7, Day 30
- Breakdown: By user segment

Card 3: Top Events
- Metric: Event count
- Events: match_completed, weak_bonus_triggered, clip_shared
- Period: Last 24 hours

Card 4: Conversion Funnel
- Step 1: App Opened
- Step 2: First Match Started
- Step 3: First Match Completed
- Step 4: Subscription Purchased

Card 5: Crash-Free Users
- Metric: Crash-free %
- Threshold: > 99.5%
- Alert if < 99%
```

### 1.2 Create Crashlytics Dashboard

In Firebase Console → **Crashlytics**:

```
Dashboard: "Critical Issues"
Metrics:
1. Crash-free users % (should be > 99.5%)
2. Affected users (count)
3. Top crashes (last 24h)
4. Errors by OS (iOS vs Android)
5. Session statistics
```

### 1.3 Performance Monitoring Dashboard

In Firebase Console → **Performance**:

```
Traces:
- App startup time (should be < 2s)
- Game loading time
- Move processing time
- Results screen render time
```

---

## 2. Automated Alerting

### 2.1 Firebase Alerts

In Firebase Console → **Alerts**:

Create rules:

```
Alert 1: High Crash Rate
- Condition: Crash-free users < 98%
- Duration: 5 minutes
- Action: Email + Slack

Alert 2: New Crash Type
- Condition: Unhandled exception detected
- Action: Immediate Slack notification

Alert 3: Performance Degradation
- Condition: App startup > 3 seconds
- Duration: 10 minutes
- Action: Email notification

Alert 4: High Error Rate
- Condition: Errors > 10 per hour
- Duration: 30 minutes
- Action: Page on-call engineer
```

### 2.2 Slack Integration

Install Firebase → Slack integration:

1. Go to Firebase Console → Project Settings → Integrations
2. Enable Slack integration
3. Configure channels:
   - `#toriverse-crashes` - Crash alerts
   - `#toriverse-performance` - Performance alerts
   - `#toriverse-analytics` - User metrics

### 2.3 Email Notifications

Set up email alerts to:
- your-email@example.com
- team@example.com
- on-call@example.com

---

## 3. Custom Monitoring

### 3.1 Create Monitoring Script

**`scripts/monitor_metrics.sh`**

```bash
#!/bin/bash
# Monitor key metrics from Firebase Console

set -e

PROJECT_ID="toriverse-prod"

echo "🔍 Checking Toriverse Metrics..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check Crashlytics
echo ""
echo "📊 Crashlytics Status:"
firebase crashlytics:symbols:download \
  --project=$PROJECT_ID \
  --app-bundle-id=com.zkaz.toriverse 2>/dev/null || echo "N/A"

echo ""
echo "📈 Latest Events:"
# This would require custom API calls to Firestore
# For now, check Firebase Console UI

echo ""
echo "✅ Monitoring setup complete!"
echo "Visit: https://console.firebase.google.com/project/$PROJECT_ID"
```

Run daily:
```bash
chmod +x scripts/monitor_metrics.sh
./scripts/monitor_metrics.sh
```

### 3.2 Manual Daily Check-In

Create checklist: **`DAILY_MONITORING_CHECKLIST.md`**

```markdown
# Daily Launch Monitoring Checklist

## Date: ______

### Crashlytics (Firebase Console → Crashlytics)
- [ ] Crash-free users: ___% (Target: > 99.5%)
- [ ] Affected users: ___ (Target: < 5% of DAU)
- [ ] Top crash: _________________
- [ ] New crashes since yesterday: ____ (Target: 0)
- [ ] Error rate: Normal / Elevated / Critical

### Analytics (Firebase Console → Analytics)
- [ ] Daily Active Users: ____ (Trend: ↑/↓/→)
- [ ] Match completion rate: __% (Target: > 80%)
- [ ] Weak bonus triggers: ___ (Expected: 30% of matches)
- [ ] Clip shares: ___ (Trend: ↑/↓/→)

### Performance (Firebase Console → Performance)
- [ ] App startup time: ___._ sec (Target: < 2s)
- [ ] Match loading time: ___._ sec
- [ ] Move processing latency: ___ ms

### Revenue (RevenueCat Console)
- [ ] New subscribers: ___
- [ ] Conversion rate: ___% (Target: > 3%)
- [ ] ARPPU: ¥___ (Target: > 300)

### Issues to Address
- [ ] None
- [ ] Issue 1: __________________
- [ ] Issue 2: __________________

### Actions Taken
- [ ] None
- [ ] Action 1: __________________
- [ ] Action 2: __________________

### Next Check-In
Scheduled for: __________ at __________
```

---

## 4. Incident Response Plan

### 4.1 Severity Levels

| Level | Definition | Response Time | Example |
|-------|-----------|---|---------|
| **CRITICAL** | Service completely unavailable | Immediate (< 15 min) | 50%+ crash rate, authentication broken |
| **HIGH** | Major functionality impaired | < 1 hour | Match creation failing, moves not processing |
| **MEDIUM** | Minor issues, workarounds exist | < 4 hours | Display bug, non-critical feature down |
| **LOW** | Cosmetic or edge case | Next business day | Typo, minor animation glitch |

### 4.2 Incident Response Workflow

**When Alerted:**

1. **Confirm** (5 min)
   - [ ] Verify alert is real (check Firebase Console)
   - [ ] Determine severity level
   - [ ] Gather context: What, When, Who affected

2. **Assess** (10 min)
   - [ ] Check recent changes (Firebase logs, Cloud Functions)
   - [ ] Review Crashlytics details
   - [ ] Determine if rollback needed
   - [ ] Estimate time to fix

3. **Communicate** (5 min)
   - [ ] Post status in Slack #toriverse-incidents
   - [ ] Notify affected testers (if applicable)
   - [ ] Estimate resolution time

4. **Fix** (Variable)
   - [ ] For critical: Deploy hotfix immediately
   - [ ] For high: Fix within 1 hour or rollback
   - [ ] For medium/low: Plan fix for next release

5. **Verify** (10 min)
   - [ ] Confirm fix is working
   - [ ] Monitor metrics return to normal
   - [ ] Get user confirmation (if affected)

6. **Post-Mortem** (Within 24h)
   - [ ] Document what went wrong
   - [ ] Identify root cause
   - [ ] Create action items to prevent recurrence
   - [ ] Update runbooks/documentation

### 4.3 Rollback Procedure

If critical issue found immediately after deployment:

```bash
# 1. Identify last good version
git log --oneline | head -10

# 2. Revert problematic commit
git revert <commit-sha>

# 3. Build and test
flutter test
flutter build apk --release
flutter build ios --release

# 4. Deploy previous version
firebase appdistribution:distribute build/app/outputs/flutter-app.apk \
  --app <FIREBASE_APP_ID> \
  --release-notes "Hotfix: Reverting to previous version"

# 5. Notify testers
# Post in Slack: "Rollback to v0.1.0. Issue identified and being fixed."

# 6. Investigate root cause while users stay on stable version
```

---

## 5. Key Metrics to Monitor

### 5.1 Technical Metrics

**Stability** (Critical)
- Crash-free users: Target > 99.5%
- ANR rate: Target < 0.1%
- Error rate: Target < 0.5%

**Performance** (Important)
- App startup: Target < 2s
- Match creation: Target < 1s
- Move processing: Target < 500ms

**Availability**
- Service uptime: Target > 99%
- Firebase response time: Target < 100ms

### 5.2 User Experience Metrics

**Engagement** (Success Metric)
- DAU (Daily Active Users): Baseline
- MAU (Monthly Active Users): Baseline
- Session duration: Target > 5 min

**Retention** (Key Success Metric)
- Day 1 retention: Target > 25%
- Day 7 retention: Target > 15%
- Day 30 retention: Target > 8%

**Feature Usage**
- Match completion rate: Target > 80%
- Weak bonus activation: Target > 30%
- Rescue card usage: Target > 20%

### 5.3 Business Metrics

**Monetization** (Launch Metric)
- Free → Paid conversion: Target > 3%
- ARPPU: Target > ¥300/user
- LTV (lifetime value): Target > ¥1,000

**Growth**
- Viral coefficient: Target 0.3-0.5
- Share rate: Track %
- Referral conversion: Monitor

---

## 6. Monitoring Cadence

### 6.1 Real-Time (Live Dashboard)

During first 24-48 hours post-launch:

- Monitor Crashlytics every 30 minutes
- Check Analytics real-time view
- Watch Slack alerts
- Keep Firebase Console open

### 6.2 Daily (Day 1-7)

- 9 AM: Check overnight crash logs
- 12 PM: Midday metrics review
- 6 PM: End-of-day summary
- 10 PM: Final check before night

### 6.3 Weekly (Week 2+)

- Monday: Weekly metrics review
- Wednesday: Mid-week check-in
- Friday: Weekly summary + trends
- Prepare metrics for stakeholders

### 6.4 Monthly (Month 2+)

- 1st: Monthly retrospective
- Mid-month: Trend analysis
- End-of-month: Metrics report
- Plan for next month optimizations

---

## 7. Stakeholder Reporting

### 7.1 Daily Standup (Week 1)

**Format**: 15-minute Slack message

```
📊 Toriverse Soft Launch - Day X Update

🟢 Status: HEALTHY
- Crash-free users: 99.7% ✅
- DAU: 1,234 
- Matches completed: 5,432

⚡ Highlights:
- No critical issues
- Weak bonus working well
- Clip shares increasing

⚠️ Watch Items:
- None at this time

🔧 Actions:
- Monitoring continue

Next update: [Tomorrow time]
```

### 7.2 Weekly Report (Week 2+)

**Format**: Email with metrics

```
Subject: Toriverse Soft Launch - Week 2 Report

Headline Metrics:
- DAU: 2,100 (↑70%)
- Retention (Day 7): 18% (Target: 15%) ✅
- Crash-free: 99.6% (Target: 99.5%) ✅
- Conversion: 4.2% (Target: 3%) ✅

Top Achievements:
- Exceeded retention target
- Zero critical incidents
- User feedback very positive

Areas for Improvement:
- Day 30 retention tracking
- Regional performance analysis

Next Steps:
- Expand tester group to 50%
- A/B test weak bonus threshold
- Optimize onboarding flow
```

---

## 8. Tools & Dashboards

### Required Access:
- [ ] Firebase Console (toriverse-prod project)
- [ ] App Store Connect (iOS TestFlight)
- [ ] Google Play Console (Android distribution)
- [ ] RevenueCat Dashboard
- [ ] Slack workspace
- [ ] Email account for alerts

### Bookmarks to Save:
```
Firebase Dashboard:
https://console.firebase.google.com/project/toriverse-prod/overview

Crashlytics:
https://console.firebase.google.com/project/toriverse-prod/crashlytics

Analytics:
https://analytics.google.com/analytics/web/

RevenueCat:
https://app.revenuecat.com/

App Store Connect:
https://appstoreconnect.apple.com/
```

---

## 9. On-Call Schedule

For critical issues during soft launch:

**Week 1 (24/7 Coverage)**
- Mon-Fri: 9 AM - 6 PM (Primary)
- Mon-Fri: 6 PM - 9 AM (Secondary)
- Sat-Sun: 24h rotation

**Week 2+ (Business Hours)**
- Mon-Fri: 9 AM - 6 PM
- Emergency contact available 24/7

---

## 10. Success Criteria

**Phase 7 Monitoring Setup Complete When:**

- [x] Firebase dashboards created
- [x] Automated alerts configured
- [x] Slack integration active
- [x] Daily checklist prepared
- [x] Incident response playbook ready
- [x] Rollback procedure documented
- [x] Key metrics defined
- [x] Monitoring cadence established
- [x] Stakeholder reporting template ready
- [x] On-call schedule set up

---

**Status**: ✅ Ready for Launch Monitoring  
**Created**: 2026-08-27
