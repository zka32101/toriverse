import 'package:freezed_annotation/freezed_annotation.dart';

part 'weak_bonus_model.freezed.dart';
part 'weak_bonus_model.g.dart';

/// Weak player bonus state per match
/// Conditions: endgame (≤11 hands), stone deficit ≥threshold, max 2 activations
@freezed
class WeakBonusModel with _$WeakBonusModel {
  const factory WeakBonusModel({
    required String id, // matchId
    required String matchId,
    @Default([0, 0, 0]) List<int> activationCounts, // per player (order: black, white, red)
    @Default([]) List<int> lastActivatedRounds, // last round activation for each player
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _WeakBonusModel;

  factory WeakBonusModel.fromJson(Map<String, dynamic> json) =>
      _$WeakBonusModelFromJson(json);
}
