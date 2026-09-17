
/// Leaderboard entry stored in events/{eventId}/leaderboard/{entryId}
class LeaderboardEntry {
  const LeaderboardEntry({
    required String id,
    required String eventId,
    required String uid,
    required String displayName,
    int score,
    int rank,
    int completedChallenges,
    int unlockedCosmetics,
    required DateTime lastUpdated,
  });
}
