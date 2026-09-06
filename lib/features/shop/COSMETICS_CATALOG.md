# Cosmetics Catalog System

## Overview

The cosmetics catalog system provides a structured approach to cosmetic items (boards and stones) in Toriverse. It includes seed data for default cosmetics, seeding utilities, and management tools.

## Cosmetics Categories

### Board Designs (¥300)
- **クラシック盤** (board_classic): Traditional wooden board design
- **ミッドナイト盤** (board_midnight): Deep navy blue board
- **さくら盤** (board_sakura): Cherry blossom themed board (rare)
- **ネオン盤** (board_neon): Modern neon color board (rare)
- **クリスタル盤** (board_crystal): Crystal inspired transparent board (rare)

### Stone Colors (¥120 each)

#### Black Stones (5 designs)
- **クラシック黒石** (stone_black_classic): Simple black stone
- **マーブル黒石** (stone_black_marble): Marble texture black stone
- **ミッドナイト黒石** (stone_black_midnight): Deep indigo black stone (rare)
- **黒曜石** (stone_black_obsidian): Glossy obsidian black stone (rare)
- **シャドウ黒石** (stone_black_shadow): Gradient shadow black stone (rare)

#### White Stones (5 designs)
- **クラシック白石** (stone_white_classic): Simple white stone
- **パール白石** (stone_white_pearl): Pearl luster white stone
- **雪色石** (stone_white_snow): Pure white snow themed stone (rare)
- **フロスト白石** (stone_white_frost): Frosted ice themed stone (rare)
- **クラウド白石** (stone_white_cloud): Cloud themed fluffy stone (rare)

#### Red Stones (5 designs)
- **クラシック赤石** (stone_red_classic): Simple red stone
- **桜石** (stone_red_cherry): Cherry blossom light red stone
- **クリムゾン赤石** (stone_red_crimson): Deep crimson red stone (rare)
- **ファイア赤石** (stone_red_fire): Energetic fire red stone (rare)
- **ルビー赤石** (stone_red_ruby): Ruby sparkling red stone (rare)

### Limited Editions (¥500)
- **ゴールデンセット** (limited_golden_set): Exclusive golden board (Sept 1-30)
- **プラチナストーン3色セット** (limited_platinum_stones): Exclusive platinum 3-stone set (Sept 1-30)
- **アニバーサリーボード** (limited_anniversary_board): 1st anniversary special board (Sept 15-30)

## Catalog Statistics

| Category | Count | Price | Rarity Mix |
|----------|-------|-------|-----------|
| Boards | 5 | ¥300 | 1 common + 4 rare |
| Black Stones | 5 | ¥120 | 2 common + 3 rare |
| White Stones | 5 | ¥120 | 2 common + 3 rare |
| Red Stones | 5 | ¥120 | 2 common + 3 rare |
| Limited Editions | 3 | ¥500 | 3 limited |
| **Total** | **23** | Mixed | Mixed |

## Seeding Data to Firestore

### Development Setup

```dart
import 'package:toriverse/features/shop/data/repositories/cosmetics_seeding_repository.dart';

// Create seeding repository
final seedingRepo = CosmeticsSeediingRepository();

// Seed all cosmetics to Firestore
final seededCount = await seedingRepo.seedAllCosmetics();
print('Seeded $seededCount cosmetics');

// Verify seed data
final result = await seedingRepo.verifySeedData();
print('Found ${result.found}/${result.expected} cosmetics');
```

### Firebase Console Method

1. Go to Firebase Console → Firestore Database
2. Create collection: `cosmetics`
3. Add documents for each cosmetic from `CosmeticsSeedData`
4. Use cosmetic ID as document ID (e.g., "board_classic")

### Firestore Document Structure

```json
{
  "id": "board_classic",
  "name": "クラシック盤",
  "typeString": "board",
  "priceJpy": 300,
  "description": "伝統的な木目調のオセロ盤。タイムレスな美しさ。",
  "rarity": "common",
  "availableFrom": null,
  "availableUntil": null
}
```

## Adding New Cosmetics

1. Add entry to appropriate list in `cosmetics_seed_data.dart`
   - boardCosmetics
   - stoneBlackCosmetics
   - stoneWhiteCosmetics
   - stoneRedCosmetics
   - limitedEditionCosmetics

2. Use unique ID format: `{type}_{theme}` (e.g., "board_sakura")

3. Set appropriate rarity:
   - "common": Standard designs (2 per stone color)
   - "rare": Special designs (3+ per category)
   - "limited": Time-limited exclusive (special price ¥500)

4. For time-limited editions:
   - Set `availableFrom` and `availableUntil` as ISO 8601 timestamps
   - Use format: "2026-09-01T00:00:00Z"

5. Reseed to Firestore:
   ```dart
   final seedingRepo = CosmeticsSeediingRepository();
   await seedingRepo.seedAllCosmetics();
   ```

## Availability Windows

Limited editions use `availableFrom` and `availableUntil` fields:
- `null` values indicate permanently available items
- ISO 8601 format for timed availability
- Check in `CosmeticItem.isCurrentlyAvailable` property

## Pricing Strategy

| Rarity | Type | Price |
|--------|------|-------|
| Common | Board | ¥300 |
| Common | Stone | ¥120 |
| Rare | Board | ¥300 |
| Rare | Stone | ¥120 |
| Limited | Any | ¥500 |

## Analytics Events

Cosmetics shop integration logs these events:
- `cosmetics_shop_opened`: User navigates to shop
- `cosmetics_shop_filtered_by_type`: User filters by type
- `cosmetic_item_previewed`: User opens detail dialog
- `cosmetic_purchased`: Successful purchase
- `cosmetic_purchased_failed`: Purchase failure
- `cosmetic_applied_to_match`: User sets as active
- `match_completed_with_cosmetic`: Match played with active cosmetic

## User Cosmetics Collection

User ownership is tracked in Firestore:
```
users/{uid}/cosmetics/{cosmeticId} → UserCosmetic
users/{uid}/preferences/cosmetics → UserCosmeticsPreference
```

See `lib/shared/models/cosmetic_item.dart` for model definitions.

## Future Enhancements

- Seasonal cosmetics rotation
- Cosmetic crafting/combining system
- Battle pass cosmetic rewards
- Social cosmetic showcase
- Cosmetic trading between players
- Custom cosmetic design submissions

## Troubleshooting

### Cosmetics not showing in shop
1. Verify Firestore collection exists: `cosmetics`
2. Check document IDs match model expectations
3. Verify `typeString` field values (board, stoneBlack, stoneWhite, stoneRed)
4. Check `CosmeticRepository.fetchCosmeticCatalog()` error handling

### Seed data failures
1. Ensure Firestore write permissions in security rules
2. Check Firebase project is correctly initialized
3. Verify `CosmeticsSeedData` constants have valid data
4. Review `CosmeticsSeediingRepository` error logs

### Limited editions not appearing
1. Check `availableFrom` and `availableUntil` timestamps
2. Verify system time is correct on device
3. Check `CosmeticItem.isCurrentlyAvailable` logic
