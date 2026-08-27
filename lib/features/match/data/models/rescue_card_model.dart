import 'package:freezed_annotation/freezed_annotation.dart';

part 'rescue_card_model.freezed.dart';
part 'rescue_card_model.g.dart';

/// Rescue card state per player per match
/// 2 consecutive attacks -> grants next-round double-move
@freezed
class RescueCardModel with _$RescueCardModel {
  const factory RescueCardModel({
    required String id, // matchId_playerId
    required String matchId,
    required String playerId,
    @Default(0) int consecutiveAttackedCount,
    @Default(false) bool cardAvailable,
    @Default(0) int cardActivatedRound, // which round the card was used
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _RescueCardModel;

  factory RescueCardModel.fromJson(Map<String, dynamic> json) =>
      _$RescueCardModelFromJson(json);
}
