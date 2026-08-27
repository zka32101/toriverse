import 'package:freezed_annotation/freezed_annotation.dart';

part 'round_result_model.freezed.dart';
part 'round_result_model.g.dart';

/// Move submission within a round
@freezed
class SubmittedMove with _$SubmittedMove {
  const factory SubmittedMove({
    required String playerId,
    required int position, // 0-63 (8x8 flattened)
    required DateTime submittedAt,
  }) = _SubmittedMove;

  factory SubmittedMove.fromJson(Map<String, dynamic> json) =>
      _$SubmittedMoveFromJson(json);
}

/// Collision resolution result (same-square submission)
@freezed
class CollisionResolution with _$CollisionResolution {
  const factory CollisionResolution({
    required int position,
    required String winnerPlayerId,
    @Default([]) List<String> losers,
    @Default(false) bool rescueCardGranted,
  }) = _CollisionResolution;

  factory CollisionResolution.fromJson(Map<String, dynamic> json) =>
      _$CollisionResolutionFromJson(json);
}

/// Replay event for animation sequencing
@freezed
class ReplayEvent with _$ReplayEvent {
  const factory ReplayEvent({
    required String type, // 'move', 'flip', 'bonus', 'rescueCard'
    required Map<String, dynamic> data,
    @Default(0) int delayMs,
  }) = _ReplayEvent;

  factory ReplayEvent.fromJson(Map<String, dynamic> json) =>
      _$ReplayEventFromJson(json);
}

/// Round result document model for Firestore
/// Maps to 'roundResults' collection with document ID = matchId_roundIndex
@freezed
class RoundResultModel with _$RoundResultModel {
  const factory RoundResultModel({
    required String id, // matchId_roundIndex
    required String matchId,
    required int roundIndex,
    @Default([]) List<SubmittedMove> submittedMoves,
    @Default([]) List<CollisionResolution> collisionResolved,
    @Default([]) List<String> processOrder, // [playerId1, playerId2, playerId3] - random order
    @Default([]) List<ReplayEvent> replayEvents,
    required DateTime createdAt,
    DateTime? processedAt,
    @Default('') String bonusTriggered, // playerId or empty
    @Default([]) List<String> rescueCardsGranted, // playerIds
  }) = _RoundResultModel;

  factory RoundResultModel.fromJson(Map<String, dynamic> json) =>
      _$RoundResultModelFromJson(json);
}
