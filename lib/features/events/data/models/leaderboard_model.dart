
/// Leaderboard entry stored in events/{eventId}/leaderboard/{entryId}
class LeaderboardEntry {
  final String id;
  final String eventId;
  final String uid;
  final String displayName;
  final int score;
  final int rank;
  final int completedChallenges;
  final int unlockedCosmetics;
  final DateTime lastUpdated;

  const LeaderboardEntry({
    required this.id,
    required this.eventId,
    required this.uid,
    required this.displayName,
    this.score = 0,
    this.rank = 0,
    this.completedChallenges = 0,
    this.unlockedCosmetics = 0,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventId': eventId,
        'uid': uid,
        'displayName': displayName,
        'score': score,
        'rank': rank,
        'completedChallenges': completedChallenges,
        'unlockedCosmetics': unlockedCosmetics,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      score: json['score'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
      completedChallenges: json['completedChallenges'] as int? ?? 0,
      unlockedCosmetics: json['unlockedCosmetics'] as int? ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}
