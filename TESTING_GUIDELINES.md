# トリバース — Beta Testing Guidelines

**Version**: 0.1.0+2 (TestFlight Build 1)  
**Testing Window**: 21 days (2026-09-11 to 2026-10-02)  
**Target Testers**: 45-75 participants across 3 cohorts  

---

## 🎯 Testing Objectives

This soft-launch phase validates three critical hypotheses:

1. **Product-Market Fit**: Aha moment (simultaneous reveal reversal) drives Day 1 retention ≥25%
2. **Technical Stability**: Crash-free rate ≥99.5% under load; Firestore sync reliable
3. **Growth Channels**: Clip sharing generates Viral Coefficient 0.3-0.5; Rank Pass converts 3-4%

---

## 👥 Tester Cohorts

### Cohort 1: Internal QA (Days 1-7)
**Size**: 5-10 participants  
**Focus**: Edge cases, crash scenarios, data integrity  
**Responsibilities**:
- Play 20+ matches; intentionally trigger weak bonus + rescue card
- Force app crashes (kill process, network pull) during critical moments
- Test all 8 cosmetic items in matches
- Attempt to exceed daily free match quota
- Verify collision resolution randomness (multiple run-throughs)

**Success Criteria**:
- Zero crashes during ~50 matches
- Weak bonus accuracy 100% (matches game rules)
- Rescue card triggers correctly (2 consecutive attacks)
- Process order lottery produces uniform distribution (statistical test)
- Collision resolution shows no bias (run 20+ collisions)

### Cohort 2: Core Content Creators (Days 1-14)
**Size**: 10-15 participants  
**Focus**: Clip generation, social sharing, viral loops  
**Responsibilities**:
- Complete 10+ matches; prioritize reversal scenarios for clip appeal
- Generate and preview clips; share to Instagram/TikTok (public or private)
- Track share count + view count for 24-48 hours
- Invite 2-3 friends to play (document referral friction)
- Provide qualitative feedback on clip aesthetic + share UX

**Success Criteria**:
- Clip generation succeeds 95%+ of matches
- Average clip shares: ≥2 per tester
- Viral Coefficient trend: Watch for 0.3-0.5 signals
- Referral acceptance rate: ≥50% (friends accepting friend invite)
- Social platform optimization insights documented

### Cohort 3: General Beta (Days 1-21)
**Size**: 30-50 participants  
**Focus**: Retention, engagement, monetization signals  
**Responsibilities**:
- Play casually without instruction; observe natural behavior
- Self-select into shop cosmetics (if compelling)
- Complete Rank Pass trial (if offered)
- Provide daily feedback on app
- Enable Crashlytics + Firebase Analytics (telemetry collection)

**Success Criteria**:
- Day 1 Retention: ≥25% (daily login count)
- Day 7 Retention: ≥15% (cohort tracking)
- Day 30 Retention: ≥8% (if extended)
- Paid Conversion: ≥3% (cosmetics + Rank Pass)
- Session Length Stability: 8-12 minutes average
- NPS (Net Promoter Score): ≥40

---

## 🎮 Core Test Scenarios

### Scenario 1: Complete Match Flow (Critical Path)
**Duration**: 20-30 minutes  
**Objective**: Validate end-to-end game loop  

**Steps**:
1. Launch app → Home screen should load within 2 seconds
2. Tap "Matchmaking" → waiting screen appears
3. Within 5-10 seconds, 2 AI players join (or 1-2 human if available)
4. Match starts → board renders correctly (3 colors visible)
5. Round 1:
   - Examine board state (legal moves highlighted)
   - Tap a legal position
   - Confirmation dialog (if enabled) → confirm
   - Move status shows "Submitted" (checkmark or icon)
6. Repeat rounds until all players submit or 30-second timeout
7. Simultaneous reveal:
   - Lottery draw animation (1-2 seconds)
   - Process order announced
   - Flip animations play sequentially
   - Score updates displayed
8. Continue 8+ rounds until match ends
9. Results screen:
   - Final scores correct
   - Rank points delta shown
   - Streak counter incremented
   - Clip preview loads
10. Tap "Share Clip" → share action sheet (Instagram/TikTok/DM)
11. Return home → matchmaking available again

**Pass Criteria**:
- ✅ No crashes at any step
- ✅ Animations smooth (no stuttering)
- ✅ Scores accurate
- ✅ Clip preview functional
- ✅ Return-to-home stable

**Fail Criteria**:
- ❌ App crash or force close
- ❌ Board state mismatch (wrong stone positions)
- ❌ Scores incorrect after round
- ❌ Clip fails to generate
- ❌ Cannot return to home

---

### Scenario 2: Weak Bonus Activation
**Duration**: 15-20 minutes  
**Objective**: Validate weak bonus system accuracy  

**Prerequisites**:
- Weak bonus active rounds: 1-11 (not rounds 12-16)
- Weak bonus threshold: Stone count ≤20th percentile below highest

**Steps**:
1. Play matches and observe stone counts each round
2. Identify scenarios where a player has significantly fewer stones (lower 20%)
3. When weak bonus triggers:
   - Visual effect displays (sparkle/glow animation)
   - Bonus stone awarded (appears on board)
   - Score delta +1 or +2 depending on board impact
4. Record:
   - Round when bonus triggered
   - Player's stone count vs. leader's
   - Bonus impact on final match outcome

**Data to Collect** (spread across 10+ matches):
- [ ] Weak bonus triggered in round 5-7 (underdog scenario)
- [ ] Weak bonus triggered in round 9-11 (late-game desperation)
- [ ] Weak bonus NOT triggered in round 12-16 (correctly disabled)
- [ ] Weak bonus NOT triggered when not meeting %ile threshold (correctly gated)
- [ ] Weak bonus activation count never exceeds 2 per match (cap enforced)

**Pass Criteria**:
- ✅ Weak bonus triggers only rounds 1-11
- ✅ Weak bonus only when stone count ≤20th percentile
- ✅ Weak bonus max 2 per match (cap works)
- ✅ Visual feedback clear and consistent
- ✅ Bonus stone placement valid

**Fail Criteria**:
- ❌ Weak bonus triggers in rounds 12-16 (timing wrong)
- ❌ Weak bonus triggers when player NOT in bottom 20% (threshold wrong)
- ❌ More than 2 bonuses awarded in single match
- ❌ Bonus stone placed in invalid position (occupied or illegal)

---

### Scenario 3: Consecutive Attack Rescue Card
**Duration**: 15-20 minutes  
**Objective**: Validate rescue card auto-grant on 2-consecutive attacks  

**Prerequisites**:
- 2-consecutive rounds where same player is "attacked" (stones flipped by same opponent)
- Attack definition: At least 1 stone of player X flipped by opponent Y in a round

**Steps**:
1. Observe match progression
2. Identify when Player A is attacked (loses stones) by Player B in Round N
3. Note if Player A is again attacked by Player B in Round N+1
4. If yes:
   - Rescue card indicator displays (card icon + glow)
   - Player A gets "2-move execution" bonus
   - Next submitted move by Player A executes twice (2 consecutive moves)
5. Verify 2-move execution:
   - First move: Board updates, stones flip
   - Second move: Board updates again, additional stones flip
   - No additional move submission required

**Data to Collect** (across 5-10 intentional scenarios):
- [ ] Consecutive attack detected correctly
- [ ] Rescue card awarded automatically (no user action needed)
- [ ] Rescue card UI feedback present
- [ ] 2-move execution triggers on next move submission
- [ ] 2-move execution completes without error

**Pass Criteria**:
- ✅ Rescue card auto-grants after 2-consecutive attacks
- ✅ Card visual indicator clear
- ✅ 2-move execution behaves correctly
- ✅ No duplicate move submissions required
- ✅ Rescue card persists until used

**Fail Criteria**:
- ❌ Rescue card fails to grant (attack counted correctly, no card)
- ❌ Rescue card granted on only 1 attack (threshold wrong)
- ❌ 2-move execution not triggered on next move
- ❌ Move submitted twice required to trigger 2-execution
- ❌ Rescue card resets without being used

---

### Scenario 4: Same-Square Collision Resolution
**Duration**: 20-30 minutes  
**Objective**: Validate random draw + rescue card compensation  

**Prerequisites**:
- Multiple players submit moves to identical board position
- Collision only occurs when 2+ players pick same square in same round

**Steps**:
1. Observe round where multiple players submit to same position
2. Collision resolution UI appears:
   - "Position Contested" or similar notification
   - Lottery draw animation (1-2 seconds)
   - Winner announced (1 player's move executed)
   - Losers' moves rejected
3. Verify losers receive rescue card:
   - Rescue card UI indicator appears
   - Card persists for next round usage
4. Repeat observation across 5+ collision scenarios
5. Track randomness:
   - Does each player win ~equally (uniform distribution)?
   - Are outcomes consistent with random draw?

**Data to Collect** (across 5+ collisions):
- [ ] Collision detected and UI displayed
- [ ] Lottery draw appears random (not favoring one player)
- [ ] Winner's move executed on correct position
- [ ] Losers' rescue cards granted
- [ ] Losers' cards usable next round

**Pass Criteria**:
- ✅ Collision detection works 100% (all same-square instances caught)
- ✅ Lottery draw uniform (statistical test: chi-squared >0.05)
- ✅ Rescue cards distributed to all losers
- ✅ Rescue cards functional for 2-move execution
- ✅ No game state corruption after collision

**Fail Criteria**:
- ❌ Collision not detected (both moves execute)
- ❌ Winner selection shows bias (Player A wins >50%)
- ❌ Rescue card not granted to losers
- ❌ Rescue card granted to winner (should be loser only)
- ❌ Board state corruption after collision

---

### Scenario 5: Process Order Random Drawing (Lottery)
**Duration**: 10-15 minutes  
**Objective**: Validate process order randomness + animation  

**Prerequisites**:
- After simultaneous reveal, process order drawn randomly
- All 6 possible orders (ABC, ACB, BAC, BCA, CAB, CBA) equally likely

**Steps**:
1. Complete move submission phase (all players submit)
2. Observe lottery draw animation:
   - Visual spinning/draw effect (1-2 seconds)
   - Process order announced (e.g., "Player 2 → Player 1 → Player 3")
3. Verify execution order matches announcement:
   - First move executes; flip animations play
   - Second move executes; flip animations play
   - Third move executes; flip animations play
4. Collect process order data across 10+ matches
5. Analyze randomness:
   - Should see variety of orders (not all same)
   - Should see each player in ~equal positions (1st, 2nd, 3rd)

**Data to Collect** (10+ matches):
```
Match 1: Order = [P1, P2, P3], Sequence observed correctly
Match 2: Order = [P3, P1, P2], Sequence observed correctly
... (continue 8+ more)
```

**Pass Criteria**:
- ✅ Process order drawn each round (not repeating)
- ✅ Animation smooth and visually clear
- ✅ Execution sequence matches announced order
- ✅ Distribution roughly uniform across 6 possible orders
- ✅ Each player appears in 1st/2nd/3rd ~equally

**Fail Criteria**:
- ❌ Process order always same (e.g., always P1→P2→P3)
- ❌ Animation stutters or skips
- ❌ Execution order doesn't match announcement
- ❌ One player favored for earlier position (>50%)
- ❌ Animation crashes app

---

### Scenario 6: AI Auto-Fill on Disconnect
**Duration**: 10-15 minutes  
**Objective**: Validate seamless AI transition  

**Prerequisites**:
- 3 players in match (2 human, 1 can be AI)
- Network disconnect or force app close simulation

**Steps**:
1. Start match with 2 human players + 1 AI
2. One human player force-closes app (kill process):
   - Other players observe: "Seat Changed" notification
   - AI immediately takes disconnected player's position
   - Match continues uninterrupted
3. Disconnected player re-opens app:
   - Auto-resumes match (push notification)
   - Sees "Seat Change" message
   - Match continues with their AI replacement
   - Can observe remaining rounds as spectator (if feature enabled)
4. Verify game state consistency:
   - AI moves valid and strategically sound
   - Board state matches across all players
   - Scores calculated correctly despite AI turnover

**Data to Collect** (3-5 tests):
- [ ] Disconnect detected within 5 seconds
- [ ] AI seat-fill completes within 2 seconds
- [ ] Other players see "Seat Changed" notification
- [ ] Disconnected player sees notification on re-open
- [ ] AI moves are valid
- [ ] Match completes successfully
- [ ] Final scores correct

**Pass Criteria**:
- ✅ Disconnect handled gracefully (no other players blocked)
- ✅ AI fills seat immediately (< 2 second)
- ✅ Disconnected player no penalty
- ✅ Match continues to completion
- ✅ Final score accurate

**Fail Criteria**:
- ❌ Match hangs on disconnect
- ❌ AI fails to join (other 2 players stuck)
- ❌ Disconnected player penalized (rank loss, suspension)
- ❌ Board state mismatch on reconnect
- ❌ AI makes illegal moves

---

### Scenario 7: Cosmetics Shop & Equipping
**Duration**: 10-15 minutes  
**Objective**: Validate shop UX, purchase flow, cosmetic rendering  

**Prerequisites**:
- Cosmetics available: 5 stone designs, 4 board themes
- Prices: ¥120-180 (stone), ¥150-220 (board)
- Purchase via RevenueCat (sandbox mode)

**Steps**:
1. Navigate to Shop screen from Home
2. Browse stone designs:
   - All 5 variants visible and loadable
   - Preview displays correct color/design
   - Price clearly shown
3. Tap "Purchase" on one stone design:
   - RevenueCat popup appears (sandbox billing)
   - Confirm purchase
   - "Purchased" state shows (checkmark or "Equipped" button)
4. Equip purchased stone:
   - Tap "Equip"
   - Return to Home
   - Start new match
   - Stone design renders correctly in match (black/white/red colors visible)
5. Repeat for board theme:
   - Purchase board theme
   - Equip in match
   - Verify board background renders correctly (not obscuring game)

**Data to Collect**:
- [ ] Shop UI loads within 2 seconds
- [ ] All 8 cosmetics display (5 stones, 4 boards)
- [ ] Cosmetic previews load correctly
- [ ] Purchase flow completes (RevenueCat)
- [ ] Equipped cosmetic persists after close
- [ ] Cosmetic renders correctly in match
- [ ] Board theme doesn't obscure playability

**Pass Criteria**:
- ✅ Shop fully functional and responsive
- ✅ All cosmetics purchasable
- ✅ Equipped cosmetic saves and persists
- ✅ Cosmetic renders visually correctly in match
- ✅ Board theme maintains readability

**Fail Criteria**:
- ❌ Shop fails to load
- ❌ Purchase fails (RevenueCat error)
- ❌ Cosmetic doesn't equip after purchase
- ❌ Equipped cosmetic resets after app restart
- ❌ Cosmetic renders incorrectly in match (color wrong, misaligned)
- ❌ Board theme obscures game board

---

### Scenario 8: Leaderboard Rank Updates
**Duration**: 5-10 minutes  
**Objective**: Validate rank point accumulation + tier progression  

**Prerequisites**:
- Leaderboard calculates rank points per match (based on placement + rank pass multiplier)
- Tiers: Bronze → Silver → Gold → Platinum (based on accumulated points)

**Steps**:
1. View Leaderboard before playing
2. Note your current rank and points
3. Complete a match
4. Return to Leaderboard
5. Verify rank point delta:
   - 1st place: +50 points (1.5x with Rank Pass)
   - 2nd place: +25 points (1.5x with Rank Pass)
   - 3rd place: +10 points (1.5x with Rank Pass)
6. After multiple matches, verify tier progression:
   - Tier name updates when threshold crossed
   - Tier visual (badge/color) updates
   - Tier-specific rewards/cosmetics available

**Data to Collect** (5-10 matches):
- [ ] Rank points appear immediately after match
- [ ] Points delta matches expected formula
- [ ] Tier updates automatically
- [ ] Tier persists after app restart
- [ ] Global leaderboard reflects points (personal ranking visible)

**Pass Criteria**:
- ✅ Rank point calculation accurate
- ✅ Tier progression logic correct
- ✅ Leaderboard displays updated position within 2 seconds
- ✅ Tier visual updates immediately
- ✅ No rank point rollbacks (dupes, exploits)

**Fail Criteria**:
- ❌ Rank points not awarded after match
- ❌ Point calculation incorrect (formula mismatch)
- ❌ Tier doesn't progress despite crossing threshold
- ❌ Leaderboard doesn't update
- ❌ Rank points reset or rollback inexplicably

---

### Scenario 9: Social Features (Friends, Messaging, Profiles)
**Duration**: 15-20 minutes  
**Objective**: Validate friend management, chat, profile viewing  

**Prerequisites**:
- 2+ testers available for simultaneous testing
- Friend request workflow enabled

**Steps**:
1. **Friend Management**:
   - Find tester's friend by username/user ID
   - Tap "Add Friend"
   - Other tester receives friend request notification
   - Approve/deny in notification or Friends panel
   - Verify friend now listed in Friends screen
   - Both testers see "Connected" status

2. **Direct Messaging**:
   - From Friends list, tap friend
   - Tap "Message"
   - Chat screen opens
   - Send test message
   - Verify message appears on both ends (real-time <1 second)
   - Send 5-10 messages back-and-forth
   - Close and reopen chat; verify message history persists

3. **Profile Viewing**:
   - Tap friend's name or avatar
   - Profile screen shows:
     - User avatar + name
     - Stat summary (matches played, win rate, streak)
     - Equipped cosmetics preview
     - Recent activity (last match date/time)
   - All data loads within 1 second

4. **Activity Feed**:
   - Return to Home
   - Check Activity Feed (if visible)
   - Should show:
     - Recent matches by followed users
     - Friend join/disconnect events
     - Leaderboard rank changes
   - Activity refreshes on pull-to-refresh

**Data to Collect**:
- [ ] Friend request sent and received
- [ ] Friend approval notification sent/received
- [ ] Friend added appears in both friend lists
- [ ] Messages send in real-time (<1 second)
- [ ] Message history persists after close
- [ ] Profile loads within 1 second
- [ ] Activity feed updates

**Pass Criteria**:
- ✅ Friend request workflow 100% functional
- ✅ Messaging real-time and persistent
- ✅ Profiles load quickly with correct data
- ✅ Activity feed reflects user actions
- ✅ Social features don't crash app

**Fail Criteria**:
- ❌ Friend request fails to send/receive
- ❌ Messages delayed >2 seconds or not delivered
- ❌ Message history lost after close
- ❌ Profile shows stale data or fails to load
- ❌ Activity feed not updating

---

### Scenario 10: Rank Pass Trial & Conversion
**Duration**: 10-15 minutes  
**Objective**: Validate Rank Pass purchase flow and feature gates  

**Prerequisites**:
- Rank Pass: ¥300/month subscription
- Free tier: 1 ranked match/day + unlimited casual
- Rank Pass perks: Unlimited ranked + 1.5x rank point multiplier + exclusive cosmetics

**Steps**:
1. Exhaust daily free ranked match (play 1 match on free tier)
2. Tap "Ranked" button again:
   - "Daily Limit Reached" message appears
   - Options: "Try Rank Pass" or "Watch Ad for Bonus"
3. Tap "Try Rank Pass":
   - Rank Pass details screen shows:
     - Price (¥300/month)
     - Features listed (unlimited ranked, 1.5x multiplier, exclusive cosmetics)
     - "Start Free Trial" button (if applicable)
4. Tap "Start Free Trial" (or "Subscribe"):
   - RevenueCat subscription flow
   - Confirmation prompt
   - Confirm purchase
5. Return to Ranked:
   - "Daily Limit" message gone
   - Can play unlimited ranked matches
   - Rank point multiplier shows 1.5x in results
6. Verify exclusive cosmetics:
   - Shop shows "Rank Pass Exclusive" badge
   - Cosmetics only purchasable with active pass

**Data to Collect**:
- [ ] Free tier gate triggers at 1 match/day
- [ ] Rank Pass upsell prompt appears
- [ ] Subscription flow completes (RevenueCat)
- [ ] Unlimited ranked access granted immediately
- [ ] 1.5x multiplier applies to next match
- [ ] Exclusive cosmetics visible/accessible
- [ ] Subscription persists after app restart

**Pass Criteria**:
- ✅ Free tier gate enforces 1 match/day
- ✅ Rank Pass upsell flows smoothly
- ✅ Subscription activates immediately
- ✅ 1.5x multiplier visible and calculated correctly
- ✅ Exclusive cosmetics restricted to pass holders
- ✅ Pass cancellation handled (revert to free tier)

**Fail Criteria**:
- ❌ Free tier gate doesn't trigger
- ❌ Rank Pass purchase fails (RevenueCat error)
- ❌ Unlimited access not granted after subscription
- ❌ Multiplier not applied (stays 1x)
- ❌ Non-subscribers can access exclusive cosmetics
- ❌ Subscription doesn't persist

---

## 📊 Telemetry & Metrics Tracking

### Required Telemetry Collection
All testers must enable:
- Firebase Analytics (opt-in via notification on Day 1)
- Crashlytics (auto-enabled)
- Push Notifications (for "Results Ready" alerts)

### Key Events to Monitor (Firebase Analytics)
```
match_completed
├─ player_rank: [1, 2, 3]
├─ match_duration_seconds: int
├─ reversal_experienced: bool (Aha moment signal)
└─ ai_filled_count: 0-3

weak_bonus_triggered
├─ round_when_triggered: 1-11
├─ player_position_before: [1, 2, 3]
└─ final_position: [1, 2, 3]

rescue_card_used
├─ trigger_type: ['collision', 'consecutive_attack']
└─ match_outcome: ['won', 'lost']

clip_shared
├─ platform: ['instagram', 'tiktok', 'dm', 'email']
└─ share_time_after_match_minutes: int

rankpass_converted
├─ conversion_day: 1-30
└─ trial_to_paid: bool
```

### Crash & Stability Signals
**Watch For** (Critical):
- Crash rate >0.5% (target: <0.5%)
- Repeated crashes in same flow (indicates bug, not random flake)
- Crashes increasing over testing period (indicates regression)

**Expected Flakes** (Non-Critical):
- Network timeouts (recoverable)
- Rare render misalignments on specific devices
- Temporary Firestore delays during peak hours

---

## 🐛 Bug Reporting Template

**Use this format when reporting issues**:

```
## Summary
[One-sentence description of bug]

## Environment
- Device: iPhone 14 Pro / Samsung Galaxy S23 / etc.
- OS Version: iOS 17.1 / Android 14 / etc.
- App Version: 0.1.0+2
- Connection: WiFi / 4G / etc.

## Steps to Reproduce
1. [First step]
2. [Second step]
3. [Observed unexpected behavior]

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happened]

## Screenshots/Video
[Attach if possible]

## Severity
- 🔴 Critical (game unplayable, crash)
- 🟡 High (feature broken)
- 🟠 Medium (cosmetic glitch, delayed action)
- 🟢 Low (minor UX polish)

## Additional Context
[Any other relevant info]
```

---

## 📞 Feedback Channels

| Type | Channel | SLA |
|------|---------|-----|
| **In-App Crash** | Automatic → Crashlytics | Real-time |
| **General Bug** | TestFlight Feedback | 24 hours |
| **Feature Request** | TestFlight Feedback | 48-72 hours |
| **Critical Issue** | Direct message (link in app) | 4-6 hours |
| **Retention/Churn** | Firebase Analytics + survey | Batch analysis |

---

## 🏆 Tester Recognition

**Leaderboard Stats** (visible in app):
- Most matches played (competitive testers)
- Highest rank achieved (skill mastery)
- Streak record (engagement signal)
- Clips shared (viral loop participation)

**Post-Launch Recognition** (after Day 21):
- Exclusive "Beta Tester" badge in profile
- Permanent cosmetic reward (rare stone/board variant)
- Early access to Phase 2 features
- Mention in Release Notes (opt-in)

---

## ⏰ Testing Timeline

| Date | Milestone | Actions |
|------|-----------|---------|
| **Sep 11** | **Cohort 1 Launch** | Internal QA begins edge case testing |
| **Sep 14** | **Cohort 2 Launch** | Content creators join; begin clip/viral testing |
| **Sep 18** | **Cohort 3 Launch** | General beta testers onboard; broad engagement monitoring |
| **Sep 25** | **Day 14 Checkpoint** | Analyze retention data; Cohort 2 assessment; decide Phase 2 prep |
| **Oct 2** | **Soft-Launch Wrap** | Freeze bug fixes; prepare production release; thank testers |
| **Oct 11** | **TestFlight Expiry** | Build 0.1.0+2 expires; all testers transitioned to App Store (if approved) |

---

## 🙏 Final Notes

Thank you for helping shape Toriverse!

Your participation in this soft-launch is critical to validating the game's potential. Every match, every crash report, every piece of feedback accelerates our path to public launch.

**Expected Engagement**: 30-60 minutes/day over 21 days  
**No Pressure**: Casual gameplay encouraged; simulate real player behavior  
**Honesty Valued**: Negative feedback and bugs more valuable than praise  

🎮 **じっくり読み合い、同時公開の瞬間にドキドキする3色オセロ**

---

**Questions?** Refer to [RELEASE_NOTES.md](./RELEASE_NOTES.md) FAQ section or contact via TestFlight feedback.
