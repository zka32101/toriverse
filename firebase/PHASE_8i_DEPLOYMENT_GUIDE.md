# Phase 8i Deployment Guide

**Status**: Ready for Production Deployment  
**Timeline**: 3 days  
**Scope**: Security rules, indexes, monitoring, validators

## Quick Start

```bash
# 1. Prerequisites
gcloud auth login
firebase login
firebase use toriverse  # or toriverse-prod

# 2. Test locally
firebase emulators:start

# 3. Deploy security rules
firebase deploy --only firestore:rules

# 4. Deploy indexes
firebase deploy --only firestore:indexes

# 5. Monitor
firebase firestore:indexes
```

## Detailed Deployment Steps

### Day 1: Security Rules

#### Step 1.1: Review Rules Locally
```bash
# Start Firestore emulator
firebase emulators:start --only firestore

# In another terminal, run rule tests
firebase rules:test firebase/firestore.rules
```

#### Step 1.2: Deploy to Staging
```bash
firebase --project toriverse-staging deploy --only firestore:rules

# Wait 5 minutes for rules to propagate
sleep 300

# Verify rules in staging
firebase --project toriverse-staging functions:log
```

#### Step 1.3: Monitor Staging
```bash
# Watch for security rule violations
watch -n 5 'firebase --project toriverse-staging firestore:indexes'

# Check error logs
firebase --project toriverse-staging functions:log --limit=50
```

**Success criteria**:
- No PERMISSION_DENIED errors from legitimate requests
- No rule evaluation errors
- Query latency < 100ms p95

#### Step 1.4: Deploy to Production
```bash
# Deploy security rules
firebase deploy --only firestore:rules

# Verify deployment
firebase firestore:indexes

# Monitor production for 1 hour
watch -n 5 'firebase functions:log | grep -E "PERMISSION|ERROR"'
```

**Go/No-Go Checkpoint 1**:
- All rules deployed successfully? ✅
- No security violations? ✅
- All authorized reads working? ✅

### Day 2: Composite Indexes

#### Step 2.1: Deploy Indexes
```bash
# Deploy all indexes
firebase deploy --only firestore:indexes

# Check index status
firebase firestore:indexes
```

**Output**:
```
Name                                          Status
projects/toriverse/databases/(default)/collectionGroups/cosmetics/indexes/...
  Creating (12 min remaining)
```

#### Step 2.2: Monitor Index Creation
```bash
# Poll index status every 30 seconds
while true; do
  echo "=== $(date) ==="
  firebase firestore:indexes | grep -E "Status|Creating|Built"
  sleep 30
done
```

**Typical timeline**:
- 12 indexes × 2-3 minutes each = 30-40 minutes total
- Monitor for 1 hour to ensure all complete

#### Step 2.3: Verify Performance
```bash
# Query performance baseline
# In production app, measure latency for common queries:
# - Shop category filter (cosmetics:type+release_date)
# - Match status check (matches:status+createdAt)
# - Notification fetch (notifications:userId+createdAt)

# Expected improvements:
# - Type filter: 150ms → 20ms (7x faster)
# - Match query: 200ms → 50ms (4x faster)
# - Notifications: 100ms → 15ms (6x faster)
```

#### Step 2.4: Remove Unused Indexes
```bash
# Clean up any failed or unused indexes
firebase firestore:indexes --delete-all-failed

# Verify only wanted indexes remain
firebase firestore:indexes
```

**Go/No-Go Checkpoint 2**:
- All indexes created? ✅
- Query latency improved? ✅
- No index errors? ✅

### Day 3: Monitoring & Alerting

#### Step 3.1: Set Up Google Cloud Monitoring
```bash
# Create alert policy for high error rate
gcloud alpha monitoring policies create \
  --notification-channels=YOUR_CHANNEL_ID \
  --display-name="Firestore Security Violations" \
  --condition-display-name="Rule Rejections" \
  --condition-threshold-value=5 \
  --condition-threshold-duration=300s \
  --condition-threshold-filter='
    resource.type="cloud_firestore_database" AND
    metric.type="firestore.googleapis.com/database/api_calls" AND
    metric.response_code_class="4xx"
  '
```

#### Step 3.2: Create Monitoring Dashboard
```bash
# Create dashboard using Cloud Console
# Add panels for:
# 1. Read latency (p50, p95, p99)
# 2. Write latency (p50, p95, p99)
# 3. Error rate (%)
# 4. Security violations
# 5. Storage size
# 6. Quota usage
```

#### Step 3.3: Configure Log Aggregation
```bash
# Enable Cloud Logging export to BigQuery
gcloud logging sinks create firestore-logs \
  bigquery.googleapis.com/projects/toriverse/datasets/firestore_logs \
  --log-filter='resource.type="cloud_firestore_database"'

# Query logs for analysis
bq query --use_legacy_sql=false '
  SELECT
    timestamp,
    severity,
    jsonPayload.error as error,
    COUNT(*) as count
  FROM `toriverse.firestore_logs.cloudaudit_googleapis_com_activity`
  WHERE DATE(timestamp) = CURRENT_DATE()
  GROUP BY timestamp, severity, error
  ORDER BY timestamp DESC
  LIMIT 100
'
```

#### Step 3.4: Test Alert Routing
```bash
# Trigger test alert
# Perform invalid Firestore write from app
# Verify alert fires to Slack/email

# Confirm notifications arrive within 5 minutes
# Document escalation path:
# - Alert → On-call engineer
# - Engineering → CTO
# - CTO → Product (if user-facing)
```

**Go/No-Go Checkpoint 3**:
- Monitoring dashboards live? ✅
- Alerts configured and tested? ✅
- Log aggregation working? ✅

## Deployment Risks & Mitigations

### Risk 1: Security Rules Block Legitimate Reads

**Symptom**: Sudden spike in PERMISSION_DENIED errors  
**Mitigation**:
```bash
# Immediately rollback rules
firebase deploy --only firestore:rules

# Check logs for affected collections
firebase functions:log --limit=100 | grep PERMISSION_DENIED

# Fix rule and re-deploy
```

### Risk 2: Indexes Fail to Build

**Symptom**: Index stuck in "Creating" state for >30 minutes  
**Mitigation**:
```bash
# Check for other operations
firebase firestore:indexes

# Delete problematic index
firebase firestore:indexes --delete INDEX_ID

# Investigate size: may need collection size reduction
# If collection >1GB, split into subcollections
```

### Risk 3: Performance Regression

**Symptom**: Queries slower after indexes  
**Mitigation**:
```bash
# Index creation can cause brief slowdown
# This usually resolves in 5-10 minutes
# Monitor error rates, not just latency

# If sustained, check for:
# - Index build in progress (normal)
# - Security rule evaluation overhead
# - Unexpected query patterns

# Verify rule complexity
firebase emulators:start --only firestore
firebase rules:test firebase/firestore.rules --verbose
```

## Post-Deployment Validation

### Checklist

- [ ] All security rules deployed
- [ ] All indexes created successfully
- [ ] Monitoring dashboards live
- [ ] Alerts tested and routing correctly
- [ ] Backup/restore tested
- [ ] Performance baselines established
- [ ] Team trained on runbooks
- [ ] Escalation contacts updated

### Metrics to Track (48 hours)

| Metric | Target | Action if miss |
|--------|--------|---|
| Read latency p95 | <100ms | Check indexes |
| Write latency p95 | <200ms | Check rule complexity |
| Error rate | <0.1% | Review logs for pattern |
| Security violations | <10/day | Audit rules |
| Index build progress | 100% | Wait or investigate |

## Rollback Plan

### If Serious Issue Discovered

**Within 5 minutes**:
```bash
# Rollback security rules to previous version
# Firebase keeps 30-day history
firebase deploy --only firestore:rules  # Uses last deployed version
```

**Within 30 minutes**:
```bash
# Rollback indexes
# This disables indexes, queries still work but slower
firebase firestore:indexes --delete-all-failed
```

**Recovery**:
```bash
# Restore from backup if data corrupted
# Timeline: ~30 minutes for 1GB database

gsutil cp -r gs://toriverse-backups/export_2026_09_03 .
# Restore to Firestore (manual process in console)
```

## Success Criteria

✅ **Phase 8i is successful when**:
1. All 12 security rules deployed and tested
2. All 12 composite indexes created
3. Query performance improved 3-6x
4. Monitoring dashboards live
5. Alert policies testing successfully
6. Zero data corruption
7. Team comfortable with production processes

## Timeline Summary

| Day | Task | Time | Success Criteria |
|-----|------|------|---|
| 1 | Security Rules | 6-8 hrs | Rules deployed, no violations |
| 2 | Indexes | 4-6 hrs | All 12 indexes created |
| 3 | Monitoring | 4-6 hrs | Dashboards live, alerts tested |

**Total Phase 8i**: ~15-20 hours over 3 days

## Post-Launch (Week 1-2)

### Daily Checks
```bash
# Automated daily monitoring script
#!/bin/bash
firebase firestore:indexes
firebase functions:log --limit=20 | grep ERROR
# Report to #engineering Slack channel
```

### Weekly Review
- Monitor error trends
- Review slow query logs
- Validate backup integrity
- Check quota usage
- Document any issues

### Monthly Review
- Analyze cost breakdown
- Verify security rule coverage
- Review and update alert thresholds
- Plan index optimization

## Support & Escalation

**On-call rotation**:
- Engineering (weekdays 9-18): firebase-support@toriverse.dev
- On-call (nights/weekends): escalate-to-cto@toriverse.dev

**SLA for critical issues**:
- Detection: 5 minutes (via alerts)
- Investigation: 15 minutes
- Mitigation: 30 minutes
- Resolution: 4 hours (or restore from backup)

---

**Phase 8i Deployment Status**: Ready  
**Next: Phase 9b or 9a-Extension-II**
