import 'package:freezed_annotation/freezed_annotation.dart';

part 'cosmetic_model.freezed.dart';
part 'cosmetic_model.g.dart';

/// Limited edition cosmetic stored in cosmetics/limited/{eventId}
@freezed
class LimitedCosmetic with _$LimitedCosmetic {
  const factory LimitedCosmetic({
    required String id,
    required String eventId,
    required String name,
    @Default('stone') String type, // stone, board, theme
    String? description,
    String? imageUrl,
    @Default([]) List<String> colors,
    @Default('common') String rarity, // common, uncommon, rare, legendary
    String? requiresChallenge,
    @Default(0) int basePrice,
    @Default(false) bool eventExclusive,
    required DateTime createdAt,
  }) = _LimitedCosmetic;

  factory LimitedCosmetic.fromJson(Map<String, dynamic> json) =>
      _$LimitedCosmeticFromJson(json);
}

/// User's event cosmetic stored in users/{uid}/eventCosmetics/{cosmeticId}
@freezed
class UserEventCosmetic with _$UserEventCosmetic {
  const factory UserEventCosmetic({
    required String cosmeticId,
    required String eventId,
    required DateTime unlockedAt,
    @Default('challenge') String method, // challenge, purchase, gift
    @Default(false) bool equipped,
  }) = _UserEventCosmetic;

  factory UserEventCosmetic.fromJson(Map<String, dynamic> json) =>
      _$UserEventCosmeticFromJson(json);
}
