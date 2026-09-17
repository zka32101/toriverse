/// Weak player bonus state per match
/// Conditions: endgame (≤11 hands), stone deficit ≥threshold, max 2 activations
class WeakBonusModel {
  final String id; // matchId
  final String matchId;
  final List<int> activationCounts; // per player (order: black, white, red)
  final List<int> lastActivatedRounds; // last round activation for each player
  final DateTime createdAt;
  final DateTime? updatedAt;

  const WeakBonusModel({
    required this.id,
    required this.matchId,
    this.activationCounts = const [0, 0, 0],
    this.lastActivatedRounds = const [],
    required this.createdAt,
    this.updatedAt,
  });

  factory WeakBonusModel.fromJson(Map<String, dynamic> json) {
    return WeakBonusModel(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      activationCounts: json['activationCounts'] != null
        ? List<int>.from(json['activationCounts'] as List)
        : [0, 0, 0],
      lastActivatedRounds: json['lastActivatedRounds'] != null
        ? List<int>.from(json['lastActivatedRounds'] as List)
        : [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matchId': matchId,
      'activationCounts': activationCounts,
      'lastActivatedRounds': lastActivatedRounds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
