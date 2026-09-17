import 'package:freezed_annotation/freezed_annotation.dart';

/// Limited edition cosmetic stored in cosmetics/limited/{eventId}
class LimitedCosmetic {
  const LimitedCosmetic({
    required String id,
    required String eventId,
    required String name,
    String type, // stone, board, theme
    String? description,
    String? imageUrl,
    List<String> colors,
    String rarity, // common, uncommon, rare, legendary
    String? requiresChallenge,
    int basePrice,
    bool eventExclusive,
    required DateTime createdAt,
  });
}

/// User's event cosmetic stored in users/{uid}/eventCosmetics/{cosmeticId}
class UserEventCosmetic {
  const UserEventCosmetic({
    required String cosmeticId,
    required String eventId,
    required DateTime unlockedAt,
    String method, // challenge, purchase, gift
    bool equipped,
  });
}
