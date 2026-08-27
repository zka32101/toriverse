import 'package:freezed_annotation/freezed_annotation.dart';

part 'match_model.freezed.dart';
part 'match_model.g.dart';

/// Match (対局) document model for Firestore
/// Maps to 'matches' collection with auto-generated document ID
/// 
/// 3-color Othello board state representation:
/// - boardState: 64-element list (8x8 flattened) with values:
///   0 = black (黒), 1 = white (白), 2 = red (赤), -1 = empty (空き)
/// - players: exactly 3 player UIDs or "AI_<identifier>" for AI substitutes
/// - roundIndex: current round number (0-indexed), increments after simultaneous reveal
/// - status: 'waiting' (filling seats), 'playing' (active round), 'finished' (completed)
@freezed
class MatchModel with _$MatchModel {
  const factory MatchModel({
    required String id,
    required List<String> players, // exactly 3 items (UIDs or "AI_*")
    required List<int> boardState, // 64-element array: 0=black, 1=white, 2=red, -1=empty
    @Default(0) int roundIndex,
    @Default('waiting') String status, // 'waiting', 'playing', 'finished'
    @Default('') String currentPhase, // 'submitPhase', 'revealPhase'
    required DateTime createdAt,
    DateTime? startedAt,
    DateTime? finishedAt,
    @Default([]) List<String> readyPlayers, // players who have joined (for partial fills)
    @Default([]) List<int> finalScores, // [black_count, white_count, red_count] at end
  }) = _MatchModel;

  factory MatchModel.fromJson(Map<String, dynamic> json) =>
      _$MatchModelFromJson(json);
}
