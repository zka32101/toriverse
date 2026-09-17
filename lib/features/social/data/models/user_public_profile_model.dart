
/// User public profile stored in users/{uid}/profiles/public
class UserPublicProfile {
  const UserPublicProfile({
    required String uid,
    required String displayName,
    int rankPoints,
    double winRate, // (wins / total_matches)
    int totalMatches,
    List<String> favoriteCosmetics, // Top 3 cosmetics
    String? bio, // Self-description
    int sharedReplays, // Count of public replays
    int followers,
    int following,
    DateTime? lastSeenAt,
    int socialRank, // Leaderboard position (by followers/reach)
  });
}
