# Phase 9a: Enhanced Cosmetics Shop System
**Status**: ⏳ Planning  
**Date**: 2026-09-02  
**Goal**: Implement cosmetics marketplace supporting buy-once monetization model (¥120-300 per item)

---

## Phase 9a Scope

### Features to Implement

1. **Cosmetics Shop UI**
   - Grid layout: 2 columns, scrollable cosmetics list
   - Item preview: 3D board/stone visualization
   - Price display: ¥120, ¥300, etc.
   - "Owned" badge for purchased items
   - Filter tabs: All, Boards, Stones, Limited Edition

2. **Cosmetics Inventory System**
   - User cosmetics collection (Firestore: `users/{uid}/cosmetics/{cosmeticId}`)
   - Purchase history tracking
   - Limited edition tracking (availability dates)
   - Seasonal cosmetics (auto-available in season window)

3. **Cosmetics Application**
   - Select active board design
   - Select active stone design (per color: black/white/red)
   - Preview before confirming
   - Apply during match setup

4. **RevenueCat Integration**
   - Product definitions: `cosmetic_board_1`, `cosmetic_stones_1`, etc.
   - Purchase validation via RevenueCat
   - Receipt verification via Firebase Cloud Function
   - Entitlement verification (prevent piracy)

5. **Analytics & Monetization**
   - Track cosmetics shop views
   - Track purchase attempts
   - Track purchase completions
   - Track cosmetics usage in matches
   - Revenue metrics: ARPU, Conversion Rate, LTV

---

## Implementation Plan

### 1. Firestore Schema Updates

```dart
// Cosmetic Item Definition
CosmeticItem {
  id: string,                    // "board_cherry_blossom"
  type: enum(board, stone),
  name: string,                  // "Cherry Blossom Board"
  description: string,
  price: int,                    // 300 (JPY)
  rarityLevel: enum(common, rare, limited),
  colorScheme: string,           // "pink_white"
  previewImageUrl: string,
  releaseDate: timestamp,
  limitedEditionEndDate: timestamp,  // null if permanent
  requiresMinVersion: string,    // "0.1.0"
}

// User Cosmetics Collection
UserCosmetics {
  cosmeticId: string,            // Reference to CosmeticItem.id
  purchasedAt: timestamp,
  purchaseSource: enum(shop, seasonal_reward, event_gift),
  revenuekatProductId: string,   // For validation
  isActive: bool,                // Currently using this cosmetic
}

// Cosmetics Preferences (Match Setup)
UserCosmeticsPrefs {
  activeBoard: string,           // cosmeticId or "default"
  activeStoneBlack: string,      // cosmeticId or "default"
  activeStoneWhite: string,
  activeStoneRed: string,
}
```

### 2. Service Layer

**File**: `lib/features/shop/application/services/cosmetics_shop_service.dart` (400 LOC)

```dart
class CosmeticsShopService {
  final FirebaseFirestore _firestore;
  final RevenueCatService _revenueCat;

  // Fetch all available cosmetics (including limited edition)
  Future<List<CosmeticItem>> fetchAvailableCosmetics() async {
    final now = DateTime.now();
    final snap = await _firestore
      .collection('cosmetics')
      .where('releaseDate', isLessThanOrEqualTo: now)
      .orderBy('releaseDate', descending: true)
      .get();
    
    return snap.docs
      .map((doc) => CosmeticItem.fromMap(doc.data()))
      .where((item) {
        // Filter out expired limited editions
        if (item.limitedEditionEndDate != null) {
          return item.limitedEditionEndDate!.isAfter(now);
        }
        return true;
      })
      .toList();
  }

  // Get user's owned cosmetics
  Future<List<CosmeticItem>> getUserCosmetics(String userId) async {
    final snap = await _firestore
      .collection('users')
      .doc(userId)
      .collection('cosmetics')
      .get();
    
    // Fetch full cosmetic details
    return Future.wait(
      snap.docs.map((doc) async {
        final cosmeticId = doc['cosmeticId'] as String;
        final cosmeticSnap = await _firestore
          .collection('cosmetics')
          .doc(cosmeticId)
          .get();
        return CosmeticItem.fromMap(cosmeticSnap.data()!);
      }),
    );
  }

  // Purchase cosmetic via RevenueCat
  Future<bool> purchaseCosmetic(
    String userId,
    CosmeticItem cosmetic,
  ) async {
    try {
      // RevenueCat purchase
      final result = await _revenueCat.purchaseProduct(
        productId: cosmetic.revenuekatProductId,
      );

      if (!result.success) {
        return false;
      }

      // Record purchase in Firestore
      await _firestore
        .collection('users')
        .doc(userId)
        .collection('cosmetics')
        .doc(cosmetic.id)
        .set({
          'cosmeticId': cosmetic.id,
          'purchasedAt': FieldValue.serverTimestamp(),
          'purchaseSource': 'shop',
          'revenuekatProductId': cosmetic.revenuekatProductId,
        });

      // Track analytics
      await _analytics.logEvent(
        name: 'cosmetics_purchased',
        parameters: {
          'cosmetic_id': cosmetic.id,
          'price': cosmetic.price,
          'rarity': cosmetic.rarityLevel,
        },
      );

      return true;
    } catch (e) {
      print('Purchase failed: $e');
      return false;
    }
  }

  // Apply cosmetic to active preferences
  Future<void> setActiveCosmetic(
    String userId,
    String cosmeticId,
    CosmeticType type,
  ) async {
    final prefsRef = _firestore
      .collection('users')
      .doc(userId)
      .collection('preferences')
      .doc('cosmetics');

    final typeKey = type == CosmeticType.board
      ? 'activeBoard'
      : 'activeStone${type.colorName}';

    await prefsRef.update({typeKey: cosmeticId});
  }
}
```

### 3. UI Layer

**Screens**:
1. **CosmeticsShopScreen** (Riverpod provider for listing)
   - Grid of cosmetics with price badges
   - Filter tabs (All/Board/Stones)
   - Owned indicator overlay
   - Purchase button (or "Owned" badge)

2. **CosmeticPreviewScreen**
   - Large preview of cosmetic
   - Description, rarity, price
   - "Purchase" or "Already Owned" button
   - Back button

3. **MatchSetupCosmeticsPanel**
   - Select active board design
   - Select stone designs for each color
   - Preview panel showing selections
   - Confirm button

**Widgets**:
- `CosmeticItemCard` (displays single cosmetic with badge)
- `CosmeticPreview3D` (3D visualization of cosmetic)
- `PriceDisplay` (¥XXX with localization)
- `RarityBadge` (Common/Rare/Limited Edition)

### 4. RevenueCat Integration

**Products to Define** (in RevenueCat dashboard):

```
cosmetic_board_cherry_blossom - ¥300
cosmetic_board_midnight_stars - ¥300
cosmetic_stones_sakura - ¥120
cosmetic_stones_ocean - ¥120
cosmetic_board_limited_new_year_2027 - ¥500 (limited edition)
```

**Entitlement**:
- Create `cosmetics_access` entitlement
- Each product grants access to specific cosmetic

**Cloud Function** for receipt verification:
```dart
// Verify RevenueCat purchase + grant Firestore access
Future<void> verifyPurchaseAndGrant(
  String userId,
  String cosmeticId,
  String revenueCatReceiptId,
) async {
  // 1. Verify with RevenueCat
  // 2. Check entitlement active
  // 3. Grant access in Firestore
  // 4. Track in analytics
}
```

### 5. Testing Strategy

**Unit Tests** (60+ tests):
- CosmeticItem serialization
- Shop filtering logic
- Price calculation
- RevenueCat integration mocks

**Widget Tests** (20+ tests):
- CosmeticsShopScreen rendering
- Purchase button states
- Filter functionality
- Preview modal

**Integration Tests** (15+ tests):
- Full purchase flow with mock RevenueCat
- Cosmetics application to match
- Limited edition availability
- User inventory persistence

---

## Cosmetics Catalog (Initial Launch)

### Board Designs (¥300 each)
1. **Cherry Blossom** (Spring theme)
2. **Midnight Stars** (Night theme)
3. **Ocean Wave** (Summer theme)
4. **Autumn Leaves** (Fall theme)
5. **Snow Crystal** (Winter theme)

### Stone Designs (¥120 each)
1. **Sakura** (Pink/white stones)
2. **Ocean** (Blue/cyan stones)
3. **Forest** (Green/dark stones)
4. **Gold** (Gold/bronze stones)
5. **Neon** (Neon glow effect)

### Limited Edition (¥500)
1. **New Year 2027** (Available Jan 1-31)
2. **Golden Week** (Available May 1-5)
3. **Summer Festival** (Available Aug 1-31)

---

## Analytics & Monetization Metrics

### Events to Track

```dart
// Shop views
'cosmetics_shop_opened'
'cosmetics_shop_filtered_by_type'  // params: type (board|stones)

// Item interactions
'cosmetic_item_previewed'  // params: cosmetic_id, type, price
'cosmetic_item_purchased'  // params: cosmetic_id, price, rarity
'cosmetic_purchased_failed' // params: reason, cosmetic_id

// Usage
'cosmetic_applied_to_match'  // params: cosmetic_id, type
'match_completed_with_cosmetic'  // params: cosmetic_id, match_result
```

### KPIs to Monitor

| Metric | Target | Soft Launch |
|--------|--------|-------------|
| Shop View Rate | 60%+ of DAU | Track |
| Cosmetics Purchase Rate | 5-10% of DAU | Track |
| Average Revenue Per User (ARPU) | ¥50-100/month | Track |
| Most Popular Cosmetic | — | Top 3 |
| Limited Edition Sell Rate | 20%+ | Monitor |

---

## Development Timeline

| Task | LOC | Duration |
|------|-----|----------|
| Firestore schema + migration | 100 | 2h |
| CosmeticsShopService | 400 | 4h |
| UI screens & widgets | 600 | 6h |
| RevenueCat integration | 200 | 3h |
| Testing (95+ tests) | 800 | 6h |
| Analytics & tracking | 150 | 2h |
| Documentation | 200 | 2h |
| **Total** | **2,450** | **25h** |

---

## Success Criteria

✅ **Launch Criteria**:
- Shop UI fully functional
- Purchase flow end-to-end working
- RevenueCat integration tested
- Analytics tracking complete
- 5+ cosmetics available at launch
- 95+ tests passing

✅ **Business Criteria**:
- 5%+ of soft launch users purchase cosmetics
- Average order value: ¥200+
- Purchase completion rate: 80%+
- Limited edition tracking active

---

## Next Phases (Phase 9b, 9c...)

**Phase 9b**: Leaderboard System (rank progression, rankings UI)  
**Phase 9c**: Social Features (friend invites, replay sharing)  
**Phase 9d**: Seasonal Events (campaign enhancements, limited cosmetics)  
**Phase 10**: Real-time Observations (Phase 2 vision feature)

---

**Status**: Ready for implementation  
**Blocked By**: None (can start immediately post-Phase 8 deployment)  
**Estimated Completion**: 25 hours of focused development
