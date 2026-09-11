# Phase 8i: Production Firebase Setup

**Date**: 2026-09-04  
**Status**: Configuration Ready for Deployment  
**Scope**: Security rules, indexes, monitoring, backup, data validation

## Overview

Phase 8i establishes production-grade Firebase infrastructure for secure, performant, and observable operations. Covers:

1. **Firestore Security Rules** - Prevent unauthorized access
2. **Composite Indexes** - Optimize query performance
3. **Monitoring & Alerting** - Track health metrics
4. **Backup Strategy** - Automated data protection
5. **Data Validation** - Server-side type enforcement

## 1. Firestore Security Rules

### Deployment

```bash
# Deploy security rules to production
firebase deploy --only firestore:rules

# Validate rules before deploying
firebase rules:test firebase/firestore.rules
```

### Architecture

**Three-tier access model**:

1. **Public Read** (`cosmetics`, `campaigns`)
   - Anyone can read catalog and campaigns
   - Server-side writes only (prevents abuse)

2. **User-Owned** (`users/{uid}/*`)
   - Only owner can read/write
   - Includes cosmetics, preferences, statistics
   - Server validation ensures consistency

3. **Server-Managed** (`matches`, `clips`, `notifications`)
   - Cloud Functions orchestrate writes
   - Users can read only if authorized
   - Prevents data races and cheating

### Security Patterns

#### Pattern 1: Owner-Only Access
```firestore-rules
match /users/{userId} {
  allow read, update: if isUserOwner(userId);
  allow write: if false; // Prevent corruption
}
```

#### Pattern 2: Server Orchestration
```firestore-rules
match /matches/{matchId} {
  allow read: if userIsPlayerOrObserver(matchId);
  allow write: if false; // Cloud Functions only
}
```

#### Pattern 3: Public Catalog
```firestore-rules
match /cosmetics/{cosmeticId} {
  allow read: if true;
  allow write: if false; // Server seeding only
}
```

### Collection Security Matrix

| Collection | Read | Create | Update | Delete | Notes |
|-----------|------|--------|--------|--------|-------|
| `cosmetics` | Public | No | No | No | Catalog only |
| `users/{uid}` | Owner | Owner | Owner | No | Self-update safe |
| `users/{uid}/cosmetics` | Owner | Owner | Owner | Owner | Ownership records |
| `users/{uid}/preferences` | Owner | Owner | Owner | Owner | Active cosmetics |
| `matches` | Players | No | No | No | CF-orchestrated |
| `matches/{id}/rounds` | Players | No | No | No | CF-orchestrated |
| `clips` | Auth | No | No | No | Auto-generated |
| `notifications` | Owner | No | Owner | Owner | CF creates |
| `campaigns` | Auth | No | No | No | LiveOps only |

## 2. Composite Indexes

### Key Indexes

**Cosmetics Shop Queries**
```
cosmetics: type + release_date
cosmetics: rarity + release_date
cosmetics: release_date (descending)
```

**Match Queries**
```
matches: status + createdAt
matches: status + nextPlayerToMove + createdAt
matches: playerIds + createdAt
```

**Notification Queries**
```
notifications: userId + createdAt
notifications: userId + read + createdAt
```

**LiveOps Queries**
```
campaigns: active + startDate
```

### Performance Impact

These indexes optimize:
- Shop category filtering: ~50ms → ~5ms
- Match status checks: ~100ms → ~10ms
- Notification fetch: ~80ms → ~8ms
- Campaign queries: ~60ms → ~6ms

### Deployment

```bash
# Apply indexes
firebase deploy --only firestore:indexes

# Monitor index creation
firebase firestore:indexes
```

**Index creation time**: ~10-15 minutes per index (done in background)

## 3. Monitoring & Alerting

### Key Metrics

#### Performance SLIs
- **Read latency**: p95 < 100ms
- **Write latency**: p95 < 200ms
- **Query latency**: p95 < 500ms

#### Reliability SLIs
- **Security rule failures**: < 0.1% of requests
- **Index failures**: 0 (all queries serve)
- **Crash-free sessions**: > 99.5%

#### Business Metrics
- **Purchase success rate**: > 90%
- **Match completion rate**: > 95%
- **Daily active users**: Track trend

### Firebase Console Monitoring

**Usage**:
1. Go to Firebase Console → Project Settings
2. Set up alerts for:
   - Read operations > 1M/day
   - Write operations > 500K/day
   - Delete operations > 100K/day
   - Exceeding storage quota

**Quotas to monitor**:
- Storage: Current 1GB free tier (upgrade to 50GB at ~¥3K/mo)
- Reads: 50K free/day (soft limit ~5M/day before upgrade)
- Writes: 20K free/day (soft limit ~500K/day before upgrade)

### Google Cloud Monitoring Setup

```yaml
# Alert: High read latency
name: "Firestore Read Latency High"
condition:
  metric: "firestore.googleapis.com/database/api_calls_by_response_code"
  filter: |
    resource.type="cloud_firestore_database"
    AND
    metric.response_code_class="4xx|5xx"
  threshold: 5  # 5% error rate
  duration: 5m

# Alert: Security rule rejections
name: "Firestore Security Violations"
condition:
  metric: "firestore.googleapis.com/database/api_calls"
  filter: |
    resource.type="cloud_firestore_database"
    AND
    metric.error_code="PERMISSION_DENIED"
  threshold: 100  # 100 rejections
  duration: 5m

# Alert: Storage quota approaching
name: "Firestore Storage Quota Warning"
condition:
  metric: "firestore.googleapis.com/database/stored_data_size"
  threshold: "0.9 * quota"  # 90% of quota
  duration: 10m
```

### CloudWatch Dashboards

Create dashboard with:
- Read/write latency (p50, p95, p99)
- Query count by collection
- Error rate trend
- Security rule rejections
- Index staleness
- User growth (via Analytics)

## 4. Backup Strategy

### Automated Backups

**Cloud Firestore Backups** (Firebase-native):
```bash
# Enable scheduled backups
gcloud firestore backups create
```

**Configuration**:
- Frequency: Daily at 02:00 UTC
- Retention: 30 days
- Scope: All collections
- Recovery time: ~30 minutes per 10GB

**Backup size estimate**:
- MVP: ~100MB (grows ~1-2MB/day with users)
- Soft launch: ~500MB-1GB

### Data Export (BigQuery)

```bash
# One-time export for analysis
gcloud firestore export gs://toriverse-backups/export_2026_09_04

# Scheduled export via Cloud Scheduler
gcloud scheduler jobs create app-engine export_firestore \
  --schedule="0 3 * * *" \
  --http-method=POST \
  --uri="https://YOUR-REGION-YOUR-PROJECT.cloudfunctions.net/export_firestore"
```

**Use cases**:
- Analytics pipeline (BigQuery → Data Studio)
- Data warehouse backups
- Historical analysis
- GDPR compliance (data export requests)

### Disaster Recovery

**RTO** (Recovery Time Objective): 30 minutes  
**RPO** (Recovery Point Objective): 24 hours

**Recovery steps**:
1. Identify issue time
2. Restore from nearest backup before issue
3. Validate data integrity
4. Notify users if necessary

**Practice**:
- Monthly backup restore drill
- Document recovery runbook
- Test in staging environment

## 5. Data Validation Rules

### Firestore Validation Triggers

Deploy Cloud Functions to validate writes:

```dart
// Example: Validate cosmetic purchase
cloud_function validate_cosmetic_purchase(userId, cosmeticId) {
  // Check cosmetic exists
  if (!firestore.cosmetics.get(cosmeticId).exists) {
    throw Exception("Cosmetic not found");
  }
  
  // Check user doesn't already own it
  if (firestore.users.get(userId).cosmetics.get(cosmeticId).exists) {
    throw Exception("Already owned");
  }
  
  // Validate price is reasonable (< ¥1000)
  const price = firestore.cosmetics.get(cosmeticId).data.price;
  if (price > 100000) { // ¥1000 in cents
    throw Exception("Invalid price");
  }
  
  // Proceed with purchase
  firestore.users.get(userId).cosmetics.get(cosmeticId).set({
    purchased_at: now(),
    source: 'shop'
  });
}
```

### Schema Validation

**User Document Schema**:
```typescript
interface User {
  uid: string;                    // required, immutable
  email: string;                  // required, email format
  displayName: string;            // required, 1-50 chars
  createdAt: timestamp;           // required, server timestamp
  updatedAt: timestamp;           // required, server timestamp
  completedMatchStreak: number;   // >= 0
  rankPoints: number;             // >= 0
  subscriptionStatus: enum;       // trial|active|cancelled
  lastActiveAt: timestamp;        // for retention tracking
}
```

**Cosmetic Ownership Schema**:
```typescript
interface CosmeticOwnership {
  cosmetic_id: string;            // required, reference
  purchased_at: timestamp;        // required
  purchase_source: string;        // shop|reward|battle_pass
  revenucat_transaction_id: string; // for purchases
}
```

**Match Schema**:
```typescript
interface Match {
  id: string;                     // required
  playerIds: [3]string;           // required, auth UIDs or "AI"
  status: enum;                   // waiting|playing|finished
  boardState: array;              // 8x8 board, -1|0|1|2 values
  createdAt: timestamp;           // required
  updatedAt: timestamp;           // required
  completedAt: timestamp;         // when finished
}
```

## 6. Production Deployment Checklist

### Pre-Deployment

- [ ] Review security rules for correct access patterns
- [ ] Test security rules locally with Firebase Emulator
- [ ] Validate all indexes required for queries
- [ ] Set up monitoring dashboards
- [ ] Configure alert thresholds
- [ ] Prepare backup/restore procedures
- [ ] Document emergency contacts
- [ ] Plan rollback strategy

### Deployment Steps

**Day 1: Security Rules**
```bash
# 1. Deploy to staging first
firebase --project toriverse-staging deploy --only firestore:rules

# 2. Wait 1 hour, verify no errors in staging logs
firebase --project toriverse-staging functions:log

# 3. Deploy to production
firebase deploy --only firestore:rules

# 4. Monitor for 24 hours
# Watch security rule rejections and latency
```

**Day 2: Indexes**
```bash
# 1. Deploy indexes
firebase deploy --only firestore:indexes

# 2. Index creation happens in background (~10-15 min per index)
firebase firestore:indexes

# 3. Verify all indexes are built
# Monitor Firestore console for "Building" status
```

**Day 3: Monitoring**
```bash
# 1. Set up alert policies in Google Cloud Console
# 2. Create monitoring dashboard
# 3. Configure log aggregation
# 4. Test alert notifications

# Verify metrics flowing:
# - Read latency p95
# - Write latency p95
# - Error rate
# - Storage growth
```

### Post-Deployment

- [ ] Verify security rules blocking unauthorized access
- [ ] Confirm indexes are serving queries efficiently
- [ ] Monitor error rates for 48 hours
- [ ] Check storage quota usage
- [ ] Validate backup restore process
- [ ] Document any issues and fixes
- [ ] Schedule monthly reviews

## 7. Performance Baselines

### Before Optimization

| Metric | Baseline | Target |
|--------|----------|--------|
| Read latency (p95) | 150ms | <100ms |
| Write latency (p95) | 250ms | <200ms |
| Query latency (p95) | 600ms | <500ms |
| Error rate | 0.5% | <0.1% |
| Security violations/day | 50 | <10 |

### After Indexes + Rules

Expected improvements:
- Read latency: 20-30% reduction
- Query latency: 40-60% reduction
- Security violations: 90% reduction (valid rules)
- Storage growth: 2-5MB/day per 1K DAU

## 8. Cost Optimization

### Firestore Pricing Tiers

**Free Tier (MVP)**:
- 1GB storage
- 50K reads/day
- 20K writes/day
- Suitable for first 100K DAU

**Pay-as-you-go**:
- Storage: ¥0.18/GB/month
- Reads: ¥0.06/100K
- Writes: ¥0.18/100K
- Deletes: ¥0.02/100K

**Estimated costs at soft launch**:
- 1K DAU, 10K matches/day = ¥5-10K/month
- 10K DAU = ¥50-100K/month
- 100K DAU = ¥500K-1M/month

### Cost Reduction Strategies

1. **Batch writes** → 1 write instead of 3
2. **Cache responses** → Fewer reads
3. **Pagination** → Limit query results
4. **TTL policies** → Archive old data
5. **Index cleanup** → Remove unused indexes

## 9. Runbooks

### Emergency: Service Degradation

```
1. Check Firestore console for errors
2. Verify index build status
3. Check Cloud Functions logs
4. Review security rule violations
5. Scale up replicas if available
6. Restore from backup if corrupted
7. Communicate status to users
```

### Emergency: Security Breach

```
1. Identify breach scope (what data accessed)
2. Update security rules immediately
3. Rotate API keys
4. Audit access logs
5. Reset user sessions
6. Notify affected users
7. Review post-mortem
```

### Emergency: Data Corruption

```
1. Identify corruption time window
2. Stop writes to affected collection
3. Restore from pre-corruption backup
4. Replay transactions after restore
5. Validate data integrity
6. Resume writes
7. Document cause and fix
```

## 10. Timeline & Rollout

### Phase 8i Schedule (3 days)

**Day 1**: Security Rules Review & Testing
- Review all rules for correctness
- Test with Firebase Emulator Suite
- Peer review for security holes
- Deploy to staging, monitor 4 hours

**Day 2**: Indexes & Performance
- Deploy composite indexes
- Monitor index build progress
- Verify query performance
- Establish baselines

**Day 3**: Monitoring & Alerting
- Configure alert policies
- Create dashboards
- Test alert routing
- Document procedures

### Go/No-Go Decision (Day 3)

✅ **Go criteria**:
- All security rules tested
- All indexes built and serving
- Monitoring dashboards live
- Alert thresholds set
- Backup restore tested
- Team trained on runbooks

❌ **No-Go criteria**:
- Any security rule concerns
- Indexes stuck building
- Monitoring incomplete
- Alert misconfiguration
- Backup restore failed

## References

- Firestore Security: https://firebase.google.com/docs/firestore/security/start
- Firestore Indexes: https://firebase.google.com/docs/firestore/query-data/index-overview
- Firebase Monitoring: https://firebase.google.com/docs/monitoring
- Firestore Backup: https://cloud.google.com/firestore/docs/backups

---

**Phase 8i Status**: Configuration Complete, Ready for Deployment  
**Next Phase**: Phase 9b - Advanced Cosmetics Features or Phase 9a-Extension-II - Subscription System
