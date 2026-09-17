import 'package:freezed_annotation/freezed_annotation.dart';



/// User public profile stored in users/{uid}/profiles/public
class UserPublicProfile {
  const factory UserPublicProfile({
    required String uid,
    required String displayName,
    @Default(0) int rankPoints,
    @Default(0.0) double winRate, // (wins / total_matches)
    @Default(0) int totalMatches,
    @Default([]) List<String> favoriteCosmetics, // Top 3 cosmetics
    String? bio, // Self-description
    @Default(0) int sharedReplays, // Count of public replays
    @Default(0) int followers,
    @Default(0) int following,
    DateTime? lastSeenAt,
    @Default(0) int socialRank, // Leaderboard position (by followers/reach)
  }) = _UserPublicProfile;

  factory UserPublicProfile.fromJson(Map<String, dynamic> json) =>
      _$UserPublicProfileFromJson(json);
}
