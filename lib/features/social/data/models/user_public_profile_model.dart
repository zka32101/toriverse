
/// User public profile stored in users/{uid}/profiles/public
class UserPublicProfile {
  final String uid;
  final String displayName;
  final int rankPoints;
  final double winRate; // (wins / total_matches)
  final int totalMatches;
  final List<String> favoriteCosmetics; // Top 3 cosmetics
  final String? bio; // Self-description
  final int sharedReplays; // Count of public replays
  final int followers;
  final int following;
  final DateTime? lastSeenAt;
  final int socialRank; // Leaderboard position (by followers/reach)

  const UserPublicProfile({
    required this.uid,
    required this.displayName,
    this.rankPoints = 0,
    this.winRate = 0.0,
    this.totalMatches = 0,
    this.favoriteCosmetics = const [],
    this.bio,
    this.sharedReplays = 0,
    this.followers = 0,
    this.following = 0,
    this.lastSeenAt,
    this.socialRank = 0,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'displayName': displayName,
    'rankPoints': rankPoints,
    'winRate': winRate,
    'totalMatches': totalMatches,
    'favoriteCosmetics': favoriteCosmetics,
    'bio': bio,
    'sharedReplays': sharedReplays,
    'followers': followers,
    'following': following,
    'lastSeenAt': lastSeenAt?.toIso8601String(),
    'socialRank': socialRank,
  };

  factory UserPublicProfile.fromJson(Map<String, dynamic> json) =>
      UserPublicProfile(
        uid: json['uid'] as String,
        displayName: json['displayName'] as String,
        rankPoints: json['rankPoints'] as int? ?? 0,
        winRate: (json['winRate'] as num?)?.toDouble() ?? 0.0,
        totalMatches: json['totalMatches'] as int? ?? 0,
        favoriteCosmetics: json['favoriteCosmetics'] != null
            ? List<String>.from(json['favoriteCosmetics'] as List)
            : const [],
        bio: json['bio'] as String?,
        sharedReplays: json['sharedReplays'] as int? ?? 0,
        followers: json['followers'] as int? ?? 0,
        following: json['following'] as int? ?? 0,
        lastSeenAt: json['lastSeenAt'] != null
            ? DateTime.parse(json['lastSeenAt'] as String)
            : null,
        socialRank: json['socialRank'] as int? ?? 0,
      );
}
