# トリバース MVP v0.1.0+2
## TestFlight Build 1 — Soft-Launch Edition

**Build Date**: 2026-09-11  
**Target Platforms**: iOS 13.0+ / Android 8.0+  
**Status**: 🎯 Ready for Beta Testing

---

## 🎮 What's New in MVP

### Core Game Features ✅ Complete
- **3-Color Asynchronous Othello**: Classic Othello reimagined with 3 colors (Black/White/Red) for strategic depth
- **Simultaneous Reveal Mechanic**: All players submit moves independently → Full board reveal at once → Sequential flip animations
- **Weak Bonus System**: Underdog protection active through round 11; max 2 triggers per match; activates when stone count ≤20th percentile
- **Consecutive Attack Rescue Card**: Auto-grants 2-move execution window when attacked 2 consecutive rounds
- **AI Auto-Fill on Disconnect**: Maintains match integrity; departing player retains no penalty; others see "seat change" notification
- **Same-Square Collision Resolution**: Random draw when multiple players submit to identical position; losers receive rescue card
- **Process Order Lottery Draw**: Lottery draw → reveal phase → sequential animation playback for dramatic effect
- **Match Completion Streak**: Persistent cosmetic counter; resource for retention hooks

### UI/Experience Enhancements
- Onboarding: 3-screen tutorial (3-color rules, rescue cards, weak bonus) — 30-45 second optimal path
- Home Screen: 3-tap maximum path to game start (Home → Matchmaking → Waiting → Match)
- Notification Pre-Prompts: Value proposition before OS permission request (Aha moment + "Results Ready" dual-stage)
- Replay Clips: Auto-generated clip preview with share action (Instagram/TikTok ready)

### Leaderboards & Social Features ✅ Complete
- **Global Rankings**: Tier-based progression (Bronze → Silver → Gold → Platinum)
- **Seasonal Leaderboards**: Monthly reset with accumulated season points
- **User Profiles**: Public profile viewing + engagement metrics display
- **Friend Management**: Add/remove/block with friend request workflow
- **User Messaging**: Direct DMs + chat conversation history
- **Activity Feeds**: Match results, friend activity, milestone notifications
- **Clan System Foundation**: Scaffolding complete; team features launching Phase 15.4
- **Social Profiles**: Customizable user profiles with stats and cosmetics showcase

### Monetization Features ✅ Complete
- **Cosmetics Shop**: 
  - Stone Designs: 5 variants (Classic, Minimalist, Cyber, Retro, Neon) — ¥120-180 each
  - Board Themes: 4 variants (Light, Dark, Gradient, Marble) — ¥150-220 each
  - Bundle discounts: 10% off 3+ items
- **Rank Pass (¥300/month)**:
  - Unlimited ranked matches (vs. 1 daily free match)
  - Exclusive cosmetics (Rank Pass-only stone/board variant)
  - 1.5x rank point multiplier
  - Bonus login streak counter
- **Free Tier**:
  - 1 ranked match per day (resets 05:00 JST)
  - Unlimited casual matches with AI
  - Reward video option for +1 bonus ranked attempt
- **RevenueCat Integration**: Unified billing for iOS/Android; subscription management; recovery flow

### Analytics & Infrastructure ✅ Complete
- **Firebase Analytics**: 5 core KPI events + cohort tracking
- **Crash Reporting**: Crashlytics auto-reporting; alert threshold 0.5% crash-free
- **Remote Config**: Hot-patch capability for bonus tuning, ad frequency, min version enforcement
- **Cloud Functions**: Server-side move validation; bonus logic; AI agent
- **Firestore Real-Time Listeners**: Match state, round results, notifications
- **Offline Capability**: Local cache; auto-sync on reconnect

---

## 🚀 Soft-Launch Strategy

### Beta Tester Cohorts
| Group | Size | Focus | Duration |
|-------|------|-------|----------|
| **Internal QA** | 5-10 | Edge cases, stability, crash testing | Day 1-7 |
| **Core Content Creators** | 10-15 | Clip generation, social sharing, UX flow | Day 1-14 |
| **General Beta** | 30-50 | Retention signals, engagement patterns, viral coefficient | Day 1-21 |

### Success Criteria (Soft-Launch Gate)
```
✅ Day 1 Retention: ≥25% (target: 15-20% minimum)
✅ Day 7 Retention: ≥15% (target: 15-20% range)
✅ Day 30 Retention: ≥8% (target: 8-10% range)
✅ Paid Conversion: 3-4% (cosmetics + Rank Pass)
✅ Crash-Free Rate: ≥99.5%
✅ Initial Reversal Experience Rate: ≥60% (Aha moment achieved)
✅ Full 3-Human Match Success Rate: ≥40% (致命的リスク対策)
```

### Known Limitations (Phase 15.4+)
- **Analytics Dashboards**: Granular creator revenue, cohort retention analysis, churn prediction launching post-soft-launch
- **Real-Time Observation** (Phase 2): Spectator mode, streamer integration deferred to Q4 2026
- **Offline Play**: Asynchronous multiplayer only; local-only 3-player mode post-launch
- **AI Difficulty Levels**: Currently simplified minimax; advanced difficulty tuning in Phase 15.5

### Critical Risk Mitigations
| Risk | Mitigation | Status |
|------|-----------|--------|
| 3-Player Cold-Start | Asynchronous architecture + AI auto-fill | ✅ Implemented |
| Real-Time Sync Complexity | Firestore listeners only on match/roundResult | ✅ Implemented |
| Same-Square Collision | Random draw + rescue card compensation | ✅ Implemented |
| Weak Bonus Exploitation | Round 11 hard cutoff, max 2 activations, percentile-based threshold | ✅ Implemented |
| Player Retention Cliff | Aha moment (reversal experience) + notification strategy | ✅ Implemented |
| 3-Human Match Formation Failure | Async structure reduces pressure; still tracking as critical signal | ✅ Monitored |

---

## 📊 Key Metrics to Track

### Primary KPIs
```
match_completed
├─ with_reversal_experienced (Aha moment signal)
├─ player_1_score
├─ player_2_score  
├─ player_3_score
└─ ai_filled_count

weak_bonus_triggered
├─ round_when_triggered
└─ outcome_impact

rescue_card_used
├─ trigger_collision
├─ trigger_consecutive
└─ impact_on_win_rate

clip_shared
├─ platform (Instagram/TikTok/DM)
└─ view_count_24h

rankpass_converted
├─ conversion_day (DAU 1-7-14-30)
├─ cosmetic_purchase_in_session
└─ retention_day_7_upgrade
```

### Engagement Signals
- Average session length: **Target 8-12 minutes**
- Matches per user per day: **Target 2-3**
- Daily active user churn rate: **Target <5% daily**
- Viral coefficient (clip shares): **Target 0.3-0.5**

### Infrastructure Health
- Firestore latency: **Target <500ms p95**
- Cloud Functions success rate: **Target >99.5%**
- Remote Config sync lag: **Target <30s**
- Push notification delivery: **Target >95%**

---

## 🐛 Known Issues & Workarounds

### Build System
- **Code Generation Timeout (Non-Blocking)**:
  - Description: `build_runner` timeout on CI during code generation (freezed/json_serializable)
  - Impact: Affects development iteration; not present in release builds
  - Workaround: Split model files; disable generators as needed for local development
  - Resolution Timeline: Post-soft-launch infrastructure investigation
  - Status: Isolated to CI environment; production builds unaffected

### Game Logic
- **AI Difficulty**: Currently simplified minimax (3-ply lookahead); advanced difficulty launching Phase 15.5
- **Cosmetic Desync**: Rare race condition when equipping cosmetic during match start; recovers on match refresh
- **Network Transient**: Connection drop during move submission → automatic resume on reconnect with Firestore sync

### UI/UX
- **Keyboard Overlap** (Android): Num-pad may overlap input fields on older devices; workaround: scroll before input
- **Haptic Feedback**: Disabled on devices with < 1GB RAM to prevent stutter
- **Dark Mode**: WCAG AA compliant; rare rendering issue on iPad 6th gen (affects <1% of users)

---

## 📱 Platform-Specific Notes

### iOS
- **Minimum Version**: iOS 13.0
- **Device Support**: iPhone 6S+, iPad (5th gen)+
- **TestFlight Expiry**: 30 days from build date (expires 2026-10-11)
- **Sign-In Methods**: Apple ID, Google Account
- **App Privacy Policy**: Included in app; hosted at https://toriverse.example.com/privacy

### Android
- **Minimum Version**: Android 8.0 (API 26)
- **Device Support**: Most devices from 2017+
- **Play Store Link**: Not yet available (soft-launch only)
- **Sign-In Methods**: Google Account, email/password
- **Permissions**: Camera (cosmetics preview), Microphone (future live features), Storage (clip export)

---

## 🔧 Testing Environment Setup

### Firebase Configuration
```
Project ID: toriverse-beta-9a4c
Firestore Region: asia-northeast1 (Tokyo)
Analytics: Enabled (events tracked to bigquery-export-dataset)
Remote Config: 15-minute cache TTL
Crashlytics: Auto-collection enabled
```

### RevenueCat Sandbox Configuration
```
Environment: SANDBOX
API Key: [configured in code]
Entitlements:
  - rank_pass_monthly (primary subscription)
  - cosmetics (non-consumable purchases)
Test User IDs: Available in TestFlight settings
```

### Notification Configuration
```
FCM Topic Subscriptions:
  - toriverse-announcements
  - toriverse-beta-testers
Push Notification Types:
  - Match Result Ready (2-stage strategy)
  - Friend Request Accepted
  - Leaderboard Rank Changed
  - New Cosmetics Available
  - Rank Pass Renewal Reminder
```

---

## 🎯 Phase 15.4 (Post-Soft-Launch) Priorities

1. **Analytics Dashboards**:
   - Creator revenue breakdown (cosmetics vs. Rank Pass)
   - Cohort retention analysis by acquisition source
   - Churn risk prediction (user engagement scoring)
   - Real-time admin dashboard (active users, matches/hour, error rates)

2. **Live Operations**:
   - Seasonal cosmetic rotation (e.g., Halloween board, Christmas stone)
   - Weekend bonus events (2x Rank Points via Remote Config)
   - Dynamic difficulty adjustment based on cohort retention

3. **Infrastructure Hardening**:
   - CI/CD performance investigation (build_runner timeout root cause)
   - Firestore indexing optimization (round result queries)
   - Cloud Functions cold-start latency reduction

4. **Phase 2 Design Finalization**:
   - Real-time spectator protocol design
   - OBS/YouTube Live plugin specification
   - Streamer incentive mechanics

---

## 📋 Checklist for Beta Testers

### Before First Match
- [ ] Onboarding screens understood (3-color rules, rescue card, weak bonus)
- [ ] Notification prompt accepted or declined intentionally
- [ ] Home screen loads within 2 seconds
- [ ] 3-tap path to match working (Home → Matchmaking → Match)

### During Gameplay
- [ ] Move submission responds within 1 second
- [ ] Weak bonus activation displays correctly (if triggered)
- [ ] Rescue card visual effects render smoothly
- [ ] Simultaneous reveal countdown accurate
- [ ] Process order lottery draw plays without stutter

### After Match
- [ ] Results screen displays correct scores
- [ ] Streak counter increments
- [ ] Clip preview loads and plays
- [ ] Share action works (Instagram/TikTok/DM)
- [ ] Return to home screen functional

### Shop & Cosmetics
- [ ] Cosmetics load without delay
- [ ] Purchase flow completes (RevenueCat)
- [ ] Equipped cosmetic renders in match
- [ ] Rank Pass details clear and visible

### Social Features
- [ ] Friend add/remove works
- [ ] User profiles load within 1 second
- [ ] Messages send and receive in real-time
- [ ] Leaderboard updates reflect completed matches

### Crash & Stability
- [ ] Force-close during move → resume with AI fill
- [ ] Network disconnect → reconnect syncs state
- [ ] App backgrounded for 5+ minutes → returns without crash
- [ ] Memory usage stable after 10+ matches

---

## 🚨 Issue Reporting

**Feedback Channel**: TestFlight in-app feedback form  
**Crash Reports**: Automatic via Crashlytics (no action required)  
**Feature Requests**: Comments section in TestFlight  
**Critical Bugs**: Contact team lead (priority escalation)  

**Response SLA**: 24 hours for critical issues; 48-72 hours for feature feedback

---

## 📞 Support & FAQ

**Q: Why are moves asynchronous?**  
A: Eliminates 3-player cold-start problem; enables AI fill; increases match success rate.

**Q: Can I play offline?**  
A: No. Online multiplayer only. Casual matches with AI available once Rank Pass daily limit reached.

**Q: Will there be real-time spectator mode?**  
A: Yes, launching Phase 2 (estimated Q4 2026). MVP prioritized asynchronous gameplay for stability.

**Q: How often do leaderboards reset?**  
A: Global ranking is persistent. Seasonal ranking resets monthly on 1st at 00:00 JST.

**Q: What happens if someone disconnects?**  
A: AI immediately takes their seat. No penalty to disconnected player. Others see "seat change" notification.

---

## 🙏 Thanks for Testing!

We're grateful for your participation in Toriverse's soft-launch. Your feedback directly shapes the game's future.

**Toriverse Team**  
🎮 じっくり読み合い、同時公開の瞬間にドキドキする3色オセロ

---

**Version**: 0.1.0+2  
**Build Date**: 2026-09-11  
**TestFlight Expiry**: 2026-10-11  
**Next Phase**: Phase 15.4 (Post-Soft-Launch Analytics)
