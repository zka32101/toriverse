/// User document model for Firestore
/// Maps to 'users' collection with document ID = uid
class UserModel {
  final String uid;
  final String displayName;
  final int rankPoints;
  final int completedMatchStreak;
  final int freeMatchUsedToday;
  final String subscriptionStatus; // 'trial', 'active', 'cancelled'
  final DateTime createdAt;
  final DateTime? lastPlayedAt;
  final DateTime? lastDailyResetAt;
  final List<String> ownedCosmetics; // cosmetic item IDs

  const UserModel({
    required this.uid,
    required this.displayName,
    this.rankPoints = 0,
    this.completedMatchStreak = 0,
    this.freeMatchUsedToday = 0,
    this.subscriptionStatus = 'trial',
    required this.createdAt,
    this.lastPlayedAt,
    this.lastDailyResetAt,
    this.ownedCosmetics = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      rankPoints: json['rankPoints'] as int? ?? 0,
      completedMatchStreak: json['completedMatchStreak'] as int? ?? 0,
      freeMatchUsedToday: json['freeMatchUsedToday'] as int? ?? 0,
      subscriptionStatus: json['subscriptionStatus'] as String? ?? 'trial',
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastPlayedAt: json['lastPlayedAt'] != null ? DateTime.parse(json['lastPlayedAt'] as String) : null,
      lastDailyResetAt: json['lastDailyResetAt'] != null ? DateTime.parse(json['lastDailyResetAt'] as String) : null,
      ownedCosmetics: json['ownedCosmetics'] != null ? List<String>.from(json['ownedCosmetics'] as List) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'rankPoints': rankPoints,
      'completedMatchStreak': completedMatchStreak,
      'freeMatchUsedToday': freeMatchUsedToday,
      'subscriptionStatus': subscriptionStatus,
      'createdAt': createdAt.toIso8601String(),
      'lastPlayedAt': lastPlayedAt?.toIso8601String(),
      'lastDailyResetAt': lastDailyResetAt?.toIso8601String(),
      'ownedCosmetics': ownedCosmetics,
    };
  }
}
