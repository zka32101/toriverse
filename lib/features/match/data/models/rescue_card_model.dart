/// Rescue card state per player per match
/// 2 consecutive attacks -> grants next-round double-move
class RescueCardModel {
  final String id; // matchId_playerId
  final String matchId;
  final String playerId;
  final int consecutiveAttackedCount;
  final bool cardAvailable;
  final int cardActivatedRound; // which round the card was used
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RescueCardModel({
    required this.id,
    required this.matchId,
    required this.playerId,
    this.consecutiveAttackedCount = 0,
    this.cardAvailable = false,
    this.cardActivatedRound = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory RescueCardModel.fromJson(Map<String, dynamic> json) {
    return RescueCardModel(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      playerId: json['playerId'] as String,
      consecutiveAttackedCount: json['consecutiveAttackedCount'] as int? ?? 0,
      cardAvailable: json['cardAvailable'] as bool? ?? false,
      cardActivatedRound: json['cardActivatedRound'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matchId': matchId,
      'playerId': playerId,
      'consecutiveAttackedCount': consecutiveAttackedCount,
      'cardAvailable': cardAvailable,
      'cardActivatedRound': cardActivatedRound,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  RescueCardModel copyWith({
    String? id,
    String? matchId,
    String? playerId,
    int? consecutiveAttackedCount,
    bool? cardAvailable,
    int? cardActivatedRound,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RescueCardModel(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      playerId: playerId ?? this.playerId,
      consecutiveAttackedCount:
          consecutiveAttackedCount ?? this.consecutiveAttackedCount,
      cardAvailable: cardAvailable ?? this.cardAvailable,
      cardActivatedRound: cardActivatedRound ?? this.cardActivatedRound,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
