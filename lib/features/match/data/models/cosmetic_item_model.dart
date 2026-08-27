import 'package:freezed_annotation/freezed_annotation.dart';

part 'cosmetic_item_model.freezed.dart';
part 'cosmetic_item_model.g.dart';

/// Cosmetic Item model for Firestore
/// Maps to 'cosmetics' collection (global catalog)
/// Each user owns cosmetics via reference in UserModel.premiumCosmetics
///
/// Used for seasonal board designs and stone appearance customization
@freezed
class CosmeticItemModel with _$CosmeticItemModel {
  const factory CosmeticItemModel({
    required String id,
    @Default('board') String type, // 'board' or 'stone'
    required String name, // display name (e.g., "Cherry Blossom Board")
    required int priceJpy, // price in JPY (120-300)
    @Default('') String description,
    @Default('') String imageUrl,
    @Default('') String category, // 'seasonal', 'premium', 'limited'
    @Default(true) bool available, // soft delete
    required DateTime createdAt,
  }) = _CosmeticItemModel;

  factory CosmeticItemModel.fromJson(Map<String, dynamic> json) =>
      _$CosmeticItemModelFromJson(json);
}
