import 'package:freezed_annotation/freezed_annotation.dart';

part 'leaderboard_model.freezed.dart';
part 'leaderboard_model.g.dart';

/// Leaderboard entry stored in events/{eventId}/leaderboard/{entryId}
@freezed
class LeaderboardEntry with _$LeaderboardEntry {
  const factory LeaderboardEntry({
    required String id,
    required String eventId,
    required String uid,
    required String displayName,
    @Default(0) int score,
    @Default(0) int rank,
    @Default(0) int completedChallenges,
    @Default(0) int unlockedCosmetics,
    required DateTime lastUpdated,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);
}
