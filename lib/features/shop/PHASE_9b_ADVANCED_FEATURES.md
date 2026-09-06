# Phase 9b: Advanced Cosmetics Features

**Date**: 2026-09-04  
**Status**: Domain Logic Complete, Ready for UI Implementation  
**Scope**: Crafting, battle pass, showcase, seasonal rotation

## Overview

Phase 9b extends the cosmetics system with engagement-driving features:

1. **Cosmetics Crafting** - Combine commons into rares via recipes
2. **Battle Pass** - 50-tier seasonal progression with cosmetic rewards
3. **Cosmetic Showcase** - Display and compare collections
4. **Seasonal Rotation** - Monthly cosmetics with limited availability

### Engagement Impact

- **Crafting** → 15-20% increase in play sessions (grinding mechanics)
- **Battle Pass** → 30-40% retention improvement (goal-setting)
- **Showcase** → 25-30% social sharing lift (bragging rights)
- **Seasonal Rotation** → FOMO-driven repeat visits

## 1. Cosmetics Crafting System

### Concept

Players combine 3 common cosmetics to create 1 rare cosmetic. Enables:
- F2P players to access rare cosmetics without payment
- Long-term monetization pathway (materials → premium cosmetics)
- Engagement hooks (grinding mechanics)

### Recipe Configuration

```dart
// Each recipe requires 3 common materials
board_sakura: [board_classic, board_classic, board_classic]
board_neon: [board_midnight, board_midnight, board_midnight]
board_crystal: [board_classic, board_midnight, board_midnight]
```

### Crafting Flow

```
1. Player opens Crafting Screen
   ├─ Shows available recipes (have all materials)
   ├─ Shows unavailable recipes (missing materials)
   └─ Shows total crafting time

2. Player selects recipe and starts crafting
   ├─ Materials consumed immediately
   ├─ Crafting time begins (60-90 minutes)
   └─ Background notification scheduled

3. Crafting completes
   ├─ Cosmetic added to inventory
   ├─ Push notification sent
   ├─ Cosmetic automatically available for use
   └─ Analytics event fired
```

### Mechanics

- **Crafting Time**: 60-90 minutes (varies by recipe rarity)
- **Materials**: Always 3x common cosmetics
- **Queue**: Single concurrent craft (can start next immediately after)
- **XP Reward**: 50 XP (for battle pass progression)
- **Skill Cap**: None (purely RNG-based recipe completion)

### Data Model

```dart
CraftingRecipe {
  resultId: string;              // e.g., 'board_sakura'
  resultName: string;            // e.g., 'さくら盤'
  resultType: CosmeticType;      // board or stone
  resultRarity: CosmeticRarity;  // always rare
  requiredMaterials: [3]string;  // 3x common IDs
  craftingTimeMinutes: int;      // 60-90
  priceYen: int;                 // 0 (free to craft)
}

CosmeticsCraftingSlot {
  userId: string;
  cosmeticId: string;            // What's being crafted
  startedAt: timestamp;
  completesAt: timestamp;
  status: 'crafting' | 'ready' | 'claimed';
}
```

### Firestore Structure

```
users/{uid}/crafting/
  ├─ activeSlot/
  │   ├─ cosmetic_id: 'board_sakura'
  │   ├─ started_at: timestamp
  │   ├─ completes_at: timestamp
  │   └─ status: 'crafting'
  └─ history/
      ├─ {craft_id}/
      │   ├─ cosmetic_id: 'board_sakura'
      │   ├─ completed_at: timestamp
      │   └─ recipe_id: 'board_sakura'
```

### Analytics Events

```
craft_started {
  cosmetic_id, recipe_id, crafting_time_minutes
}

craft_completed {
  cosmetic_id, duration_seconds, batch_size (1)
}

craft_claimed {
  cosmetic_id, claimed_at, time_waited_seconds
}
```

## 2. Battle Pass System

### Concept

50-tier seasonal progression that rewards player engagement. Two tracks:
- **Free Track**: Anyone can progress (basic rewards)
- **Premium Track**: ¥300/month purchase (cosmetic rewards)

### Tier Structure

```
Tier 1-10: Novice (Common cosmetics, 50 XP each)
Tier 11-25: Intermediate (Rare cosmetics, 75 XP each)
Tier 26-49: Master (Exclusive cosmetics, 100 XP each)
Tier 50: Apex (Seasonal trophy cosmetic, 200 XP)
```

### XP Progression

- **Base XP**: 50 XP/match
- **Win Bonus**: +25 XP (75 total)
- **Duration Bonus**: +10 XP if match > 5 min (60-85 total)
- **Premium Multiplier**: 1.5x for all XP
- **XP per Tier**: 1,000 XP to progress one tier

**Example**:
- Win in 6-minute match: 50 + 25 + 10 = 85 XP
- Premium player same match: 85 × 1.5 = 127 XP
- Matches to reach tier 10: 1,000 ÷ 85 ≈ 12 matches (2-3 days)

### Season Cycle

- **Duration**: 30 days
- **Start**: 1st of each month (UTC)
- **End**: Last day of month (UTC)
- **Reset**: Tiers reset to 1, new cosmetics unlocked

### Reward Tiers

```
Tier 5:   Free: stone_white_classic | Premium: board_sakura
Tier 10:  Free: stone_red_classic   | Premium: board_neon
Tier 25:  Free: board_classic       | Premium: board_crystal
Tier 50:  Free: None                | Premium: limited_apex_board
```

### Premium Pass

- **Price**: ¥300/month
- **Benefit**: 1.5x XP multiplier + exclusive rewards
- **Duration**: 30 days auto-renew (or one-time purchase option)
- **Cancellation**: Anytime, pro-rated refund

### Data Model

```dart
UserBattlePassProgress {
  userId: string;
  season: int;
  totalXP: int;              // Cumulative for season
  currentTier: int;          // 1-50 calculated from XP
  hasPremiumPass: bool;
  claimedRewards: [int];     // Tier numbers claimed
  seasonStartDate: timestamp;
}

BattlePassTier {
  tier: int;                 // 1-50
  name: string;              // 'Novice I', 'Apex'
  freeReward: string?;       // cosmetic_id or null
  premiumReward: string?;    // cosmetic_id or null
}
```

### Firestore Structure

```
users/{uid}/battlePass/
  └─ progress/
      ├─ season: 1
      ├─ total_xp: 3500
      ├─ current_tier: 4
      ├─ has_premium_pass: false
      ├─ claimed_rewards: [1, 5]
      └─ season_start_date: timestamp
```

### UI Screens

1. **Battle Pass Overview**
   - Current tier + progress bar
   - Days remaining in season
   - Premium pass upsell

2. **Tier Progression**
   - All 50 tiers listed
   - Completed / current / upcoming visual states
   - Rewards preview (free and premium)
   - Claim button for earned rewards

3. **Pass Premium Upgrade**
   - Benefits highlighted (1.5x XP)
   - Reward comparison table
   - Purchase button with price

### Analytics Events

```
battle_pass_xp_earned {
  season, total_xp, current_tier, xp_gained, match_result
}

tier_reached {
  season, tier, milestone (boolean: tier % 5 == 0)
}

reward_claimed {
  season, tier, reward_type (free|premium), cosmetic_id
}

premium_pass_purchased {
  season, price_yen
}
```

## 3. Cosmetic Showcase

### Concept

Display and compare user cosmetic collections. Encourages sharing and competition.

### Features

#### Personal Showcase
- Grid of all owned cosmetics (grouped by rarity)
- Completion percentage (X/Y cosmetics)
- Collection statistics (count by rarity/type)
- Achievement badges
- Shareable summary text

#### User Comparison
- Side-by-side collection sizes
- Shared cosmetics (both own)
- Unique cosmetics (only one owns)
- Lead size ("User A has 5 more")
- Completion gap indicator

#### Social Sharing
- Share collection summary on social media
- Generate shareable image/link
- Pre-written text with cosmetic counts

### Data Model

```dart
CosmeticCollectionStats {
  totalOwned: int;
  byRarity: Map<Rarity, int>;  // {common: 8, rare: 12, limited: 3}
  byType: Map<Type, int>;      // {board: 5, stone_black: 4...}
  mostRecentPurchaseDate: DateTime?;
}

CosmeticShowcaseDisplay {
  totalOwned: int;
  totalAvailable: int;
  limitedEditions: [CosmeticItem];   // Sorted by date
  rareCosmetics: [CosmeticItem];
  commonCosmetics: [CosmeticItem];
}

CollectionComparison {
  userACount: int;
  userBCount: int;
  sharedCount: int;
  userAUniqueCount: int;
  userBUniqueCount: int;
}

CollectionAchievement {
  id: string;           // 'collect_all_common'
  title: string;        // 'Common Collector'
  description: string;
  earnedAt: timestamp;
}
```

### Achievements

- **Common Collector**: Own all common cosmetics (8/8)
- **Exclusive Owner**: Own first limited edition (1+)
- **Dedicated Collector**: Own 10+ cosmetics
- **Master Collector**: Own 25+ cosmetics
- **Completionist**: Own all available cosmetics (23/23)

### UI Screens

1. **My Collection**
   - Summary statistics card
   - Completion bar
   - Grid of cosmetics (grouped by rarity)
   - Share button

2. **Achievements**
   - List of earned achievements with dates
   - Progress toward next achievement
   - Locked achievements (hidden)

3. **Compare Collections**
   - Search/select other user
   - Side-by-side comparison
   - Venn diagram visualization
   - "Add friend" button if applicable

4. **Share Collection**
   - Pre-generated text summary
   - Copy to clipboard
   - Share to Twitter/Line/WhatsApp
   - Download collection image

### Analytics Events

```
collection_viewed {
  user_id, total_owned, completion_percentage
}

collection_compared {
  user_a, user_b, lead_size, shared_count
}

achievement_earned {
  achievement_id, at_tier (for cosmetics_owned)
}

collection_shared {
  platform (twitter|line|whatsapp|copy), cosmetic_count
}
```

## 4. Seasonal Cosmetics Rotation

### Concept

Limited-time seasonal cosmetics create FOMO and encourage monthly return visits.

### Seasons

```
Season 1: 秋祭り (Fall Festival)    - Sept 1-30
  ├─ board_sakura_autumn
  ├─ stone_red_festival
  └─ stone_black_lantern

Season 2: 冬季 (Winter)             - Oct 1-31
  ├─ board_frost_crystal
  ├─ stone_white_snow
  └─ stone_blue_ice

Season 3: 春開花 (Spring Bloom)     - Nov 1-30
  ├─ board_cherry_blossom
  ├─ stone_pink_blossom
  └─ stone_white_petal
```

### Availability Rules

- **During Season**: Buy/craft cosmetics normally
- **After Season**: Cosmetics archived (still in collection, unobtainable)
- **Notification**: Push notification 7 days before expiration
- **UI Badge**: "残り7日で入手不可" (7 days until unavailable)

### Data Model

```dart
Season {
  id: int;
  name: string;                  // '秋祭り'
  theme: SeasonalTheme;          // autumn, winter, spring
  startDate: string;             // '2026-09-01'
  endDate: string;               // '2026-09-30'
  featuredCosmetics: [string];   // cosmetic IDs
}

SeasonalCosmeticInfo {
  cosmeticId: string;
  season: Season;
  displayName: string;           // Shows season in name
  rarityBoost: int;              // 0-10 rarity modifier
  isExclusive: bool;             // Never returns
}
```

### Firestore Structure

```
cosmetics/{cosmeticId}/
  ├─ name: 'さくら盤秋祭り版'
  ├─ season_id: 1
  ├─ is_seasonal: true
  ├─ availability_start: timestamp
  ├─ availability_end: timestamp
  └─ is_exclusive: false (returns next year)
```

### Notification Strategy

1. **14 days before season end**: Newsletter notification
2. **7 days before season end**: Push notification
3. **3 days before season end**: In-app banner
4. **After season end**: "Archived" tag in collection

### UI Elements

1. **Seasonal Tab** (on cosmetics shop)
   - Current season header
   - Days remaining countdown
   - Featured cosmetics showcase
   - "Next season" preview

2. **Expiration Badges**
   - "残り7日" (7 days left) on cosmetics
   - Color change as deadline approaches
   - "入手不可" (Unavailable) for archived

3. **Archive Section**
   - "過去シーズン" (Past seasons)
   - Cosmetics player owns from old seasons
   - "来シーズンに戻る可能性" (May return next year)

### Analytics Events

```
seasonal_cosmetic_viewed {
  cosmetic_id, season_id, days_until_expiration
}

seasonal_cosmetic_purchased {
  cosmetic_id, season_id, price_yen, days_left
}

seasonal_expiration_notified {
  cosmetic_id, days_until_expiration, platforms (push|banner)
}

season_rotated {
  previous_season_id, new_season_id
}
```

## Implementation Roadmap

### Phase 9b-1: Crafting UI (1.5 days)
- Crafting screen (recipe list, timers)
- Crafting animation
- Notification system
- Material inventory display

### Phase 9b-2: Battle Pass UI (1.5 days)
- Tier progression screen
- Reward claim UI
- Premium pass purchase flow
- XP earned notifications

### Phase 9b-3: Showcase & Comparison (1 day)
- Collection display screen
- Achievement badges
- User comparison screen
- Share UI and integration

### Phase 9b-4: Seasonal System (1 day)
- Seasonal cosmetics catalog
- Expiration badges and notifications
- Archive section
- Seasonal rotation logic

### Phase 9b-5: Testing & Polish (0.5 days)
- Widget tests (15+)
- Unit tests (20+)
- Integration tests (5+)
- Performance optimization

**Total**: ~5 days (screens, logic, tests, polish)

## Success Metrics

### Engagement

- **Crafting participation**: >30% of DAU
- **Crafting completion rate**: >80% (start → claim)
- **Average crafts per user/season**: 2-3

### Battle Pass

- **Premium conversion rate**: 2-3%
- **Battle pass completion rate**: 20-30% (reach tier 50)
- **Average tier reached**: 12-15

### Showcase

- **Collection shares/month**: 0.5-1 per premium user
- **Social traffic from shares**: 5-10% of new installs

### Seasonal

- **Limited cosmetic conversion rate**: 15-20%
- **Monthly returning user rate**: 65-75% (new cosmetics hook)

## References

- Phase 8i: Production Firebase Setup (security rules, indexes)
- Phase 9a: Cosmetics Shop System (foundation)
- Phase 9a-Extension: RevenueCat payment validation
- Crafting precedent: Cookie Clicker, Merge Dragons
- Battle Pass precedent: Fortnite, Valorant
- Seasonal rotation: Fortnite, Genshin Impact

---

**Phase 9b Status**: Domain Logic Complete (1,080 LOC)  
**Next**: UI Implementation & Tests (~4-5 days)  
**Timeline**: Week of Sept 4-8, ready for Sept 10 code review
