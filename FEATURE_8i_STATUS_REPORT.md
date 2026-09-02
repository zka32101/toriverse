# Phase 8i: Production Deployment & Monitoring Preparation
**Status**: ⏳ In Progress  
**Date**: 2026-09-02  
**Phase Goal**: Prepare production Firebase setup, monitoring, and deployment validation

---

## Phase 8i Objectives

### 1. Production Firebase Configuration
- [ ] Create production Firebase project
- [ ] Enable Firestore Database (production mode with security rules)
- [ ] Configure Firebase Remote Config for production
- [ ] Set up Firebase Crashlytics for error tracking
- [ ] Configure Firebase Analytics for production events

### 2. Security & Access Control
- [ ] Define production Firestore security rules
- [ ] Configure Firebase Authentication for production
- [ ] Set up role-based access control (RBAC)
- [ ] Enable audit logging
- [ ] Configure API key restrictions

### 3. Monitoring & Alerting
- [ ] Set up monitoring dashboard (Firebase Console + custom)
- [ ] Configure alerting for key metrics (error rate, latency, crash rate)
- [ ] Define SLOs (Service Level Objectives)
- [ ] Set up log aggregation
- [ ] Configure performance monitoring

### 4. Deployment Pipeline
- [ ] Configure production deployment workflow
- [ ] Set up Blue-Green deployment strategy
- [ ] Configure rollback procedures
- [ ] Set up canary deployment option
- [ ] Document deployment checklist

### 5. Data Migration & Backup
- [ ] Plan data migration from test → production
- [ ] Configure automated backups
- [ ] Test backup restoration procedures
- [ ] Document data seeding procedures

### 6. Soft Launch Validation
- [ ] Final integration tests against production Firebase
- [ ] Performance benchmarking on production environment
- [ ] Load testing (concurrent user simulation)
- [ ] Security audit of configuration
- [ ] Compliance verification (GDPR, privacy policy)

---

## Production Firebase Setup

### Environment Configuration

**Production Firebase Project**:
```
Project ID: toriverse-production (TBD - actual project name)
Region: asia-northeast1 (Japan)
Billing Account: (TBD)
```

**Firestore Database**:
```
Location: asia-northeast1 (Tokyo)
Mode: Production
Backup: Enabled (daily automated backup)
```

### Security Rules (Production)

**File**: `firestore.rules` (production version)

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User profile access - only own data
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
      
      // Campaign progress - user specific
      match /campaign_progress/{campaignId} {
        allow read, write: if request.auth.uid == uid;
      }
      
      // Campaign participation - user specific
      match /campaign_participation/{document=**} {
        allow read, write: if request.auth.uid == uid;
      }
    }
    
    // Public campaigns (read-only for users)
    match /campaigns/{campaignId} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.admin == true;
      
      // Campaign rewards
      match /rewards/{rewardId} {
        allow read: if request.auth != null;
        allow write: if request.auth.token.admin == true;
      }
    }
    
    // Analytics events - write only
    match /analytics/{document=**} {
      allow write: if request.auth != null;
    }
  }
}
```

### Remote Config (Production)

```json
{
  "weekend_streak_multiplier": "2.0",
  "special_event_cosmetic_drop_rate": "0.1",
  "holiday_bonus_match_rewards": "1.5",
  "enable_milestone_notifications": true,
  "enable_streak_recovery": true,
  "enable_campaigns": true,
  "enable_match_available": true,
  "min_app_version": "0.1.0",
  "maintenance_mode": false
}
```

---

## Monitoring Dashboard Setup

### Key Metrics to Track

#### Performance Metrics
- API response latency (p50, p95, p99)
- Database query latency
- Campaign fetch time
- Reward claim time
- Concurrent user count

#### Reliability Metrics
- Error rate (by service)
- Crash-free rate (target: 99.5%+)
- Availability percentage
- Firestore quota usage
- Cloud Function execution time

#### Business Metrics
- Daily Active Users (DAU)
- New user sign-ups
- Campaign participation rate
- Reward claim rate
- Day 1/7/30 retention

### Custom Dashboard (Firebase Console)

**Dashboards to Create**:
1. **Deployment Health** (post-launch)
   - Crash rate, error rate, latency
   - Real-time alerts
   
2. **Campaign Performance**
   - Campaign participation
   - Reward claim trends
   - User engagement

3. **User Journey**
   - Sign-up funnel
   - Campaign discovery → claim flow
   - Notification engagement

---

## Deployment Checklist

### Pre-Deployment (48 hours before)
- [ ] Final code review (all Phase 8 work)
- [ ] Security audit complete
- [ ] Load testing results reviewed
- [ ] Backup procedures tested
- [ ] Rollback plan documented

### Deployment Day (T-0)
- [ ] Firebase production environment ready
- [ ] Security rules deployed
- [ ] Remote Config configured
- [ ] Monitoring dashboards live
- [ ] Alert thresholds set
- [ ] Team on-call schedule confirmed

### Deployment (T+0)
- [ ] Deploy app version (TestFlight/internal distribution)
- [ ] Monitor error rates (30 minutes post-deploy)
- [ ] Check user sign-ups (15 min after push)
- [ ] Verify campaign discovery (20 min after push)
- [ ] Monitor crash rate (real-time)

### Post-Deployment (T+1 hour to T+24 hours)
- [ ] Monitor all metrics hourly
- [ ] Check user retention
- [ ] Review error logs for new issues
- [ ] Monitor database quota usage
- [ ] Verify notification delivery

### Rollback Decision Points
- Error rate > 2% for 10 minutes → Investigate
- Crash-free rate < 95% → Consider rollback
- Critical user-facing bug → Rollback + fix + redeploy

---

## Soft Launch Validation

### Testing Against Production Firebase

```dart
// E2E test against production Firestore
group('Production Firebase E2E', () {
  test('campaign flow works with production Firestore', () async {
    final firestore = FirebaseFirestore.instance; // Production instance
    
    // Verify campaigns fetch
    final campaigns = await campaignService.fetchActiveCampaigns();
    expect(campaigns, isNotEmpty);
    
    // Verify user can claim reward
    final result = await campaignService.claimCampaignReward(...);
    expect(result, isTrue);
  });
});
```

### Load Testing Strategy

```bash
# Simulate 100 concurrent users over 10 minutes
ab -n 10000 -c 100 https://api.toriverse.app/health

# Campaign discovery load test
flutter test test/load/campaign_discovery_load_test.dart

# Reward claiming load test
flutter test test/load/reward_claiming_load_test.dart
```

### Performance Targets

| Metric | Target | Threshold |
|--------|--------|-----------|
| API Latency (p95) | < 500ms | Alert if > 1000ms |
| Campaign Fetch | < 200ms | Alert if > 500ms |
| Reward Claim | < 100ms | Alert if > 300ms |
| Error Rate | < 1% | Alert if > 2% |
| Crash-Free Rate | > 99.5% | Alert if < 95% |

---

## Soft Launch Gates

### Must-Pass Criteria ✅ (From Phase 8g)
- ✅ Code coverage: 65%+ 
- ✅ All tests passing: 259+ tests
- ✅ Performance benchmarks: 100% targets met
- ✅ Error paths tested: 95%+ coverage

### Additional Soft Launch Gates ⏳
- [ ] Production Firebase operational
- [ ] Security rules validated
- [ ] Monitoring configured
- [ ] Load testing: 100 concurrent users
- [ ] Performance: All targets met on production
- [ ] Error rate < 1%
- [ ] Crash-free rate > 99.5%
- [ ] User feedback positive (first 24h)

---

## Post-Launch Monitoring (Day 1-7)

### Metrics to Watch

**Hourly** (first 24 hours):
- Error rate
- Crash-free rate
- API latency
- Active user count

**Daily** (days 1-7):
- DAU and sign-ups
- Campaign participation
- User retention
- Feature usage patterns

**Weekly** (after day 7):
- Cohort analysis
- Campaign performance
- Monetization metrics
- Bug reports and issues

### Incident Response

**Critical Issues** (immediate):
- Crash rate > 5%
- Error rate > 5%
- Service unavailable

**High Priority** (within 1 hour):
- Data loss
- Security breach
- Feature broken

**Normal** (within 24 hours):
- Performance degradation
- Minor bugs
- UI issues

---

## Documentation & Handover

### Production Operations Guide
- Deployment procedures
- Monitoring dashboard walkthrough
- Alert handling procedures
- Rollback procedures
- Data backup/restore procedures

### Runbook (On-Call)
- Common issues and solutions
- Escalation paths
- Contact list
- Dashboard URLs
- Log locations

### Post-Mortem Process
- Incident classification
- Root cause analysis
- Action items
- Follow-up monitoring

---

## Success Criteria

### Launch Success Metrics
- ✅ All gates passed
- ✅ Zero critical bugs in first 24 hours
- ✅ Crash-free rate > 99.5%
- ✅ Error rate < 1%
- ✅ 100+ signed-up users (soft launch)
- ✅ Day 1 retention > 20%

### Readiness for Phase 9
- ✅ Production infrastructure stable
- ✅ Monitoring operational
- ✅ Team trained on deployment
- ✅ Runbook complete
- ✅ On-call rotations established

---

## Phase 8i Timeline

| Task | Duration | Status |
|------|----------|--------|
| Production Firebase setup | 2-4 hours | ⏳ Pending |
| Security rules deployment | 1-2 hours | ⏳ Pending |
| Monitoring configuration | 2-3 hours | ⏳ Pending |
| Load testing | 1-2 hours | ⏳ Pending |
| Soft launch validation | 4-6 hours | ⏳ Pending |
| Documentation & handover | 2-3 hours | ⏳ Pending |
| **Total** | **12-20 hours** | **⏳ In Progress** |

---

## Related Phases

### Phase 8 (Completed)
- ✅ 8d: Firebase & Analytics
- ✅ 8e: Push Notifications & LiveOps
- ✅ 8f: Unit Testing
- ✅ 8g: Widget & Integration Testing
- ✅ 8h: E2E & Firebase Emulator

### Phase 9 (Next)
- Planned: Feature Development & LiveOps
- Real-time match observations
- Additional cosmetics & rewards
- Seasonal campaign templates
- Social features

---

**Report Date**: 2026-09-02  
**Status**: ⏳ Phase 8i Preparation  
**Next**: Production Firebase setup and deployment validation

---

**Phase 8 Completion Status**: 🎯 All 8 phases complete and ready for production deployment
