/// Move submission within a round
class SubmittedMove {
  final String playerId;
  final int position; // 0-63 (8x8 flattened)
  final DateTime submittedAt;

  const SubmittedMove({
    required this.playerId,
    required this.position,
    required this.submittedAt,
  });

  factory SubmittedMove.fromJson(Map<String, dynamic> json) {
    return SubmittedMove(
      playerId: json['playerId'] as String,
      position: json['position'] as int,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'position': position,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }
}

/// Collision resolution result (same-square submission)
class CollisionResolution {
  final int position;
  final String winnerPlayerId;
  final List<String> losers;
  final bool rescueCardGranted;

  const CollisionResolution({
    required this.position,
    required this.winnerPlayerId,
    this.losers = const [],
    this.rescueCardGranted = false,
  });

  factory CollisionResolution.fromJson(Map<String, dynamic> json) {
    return CollisionResolution(
      position: json['position'] as int,
      winnerPlayerId: json['winnerPlayerId'] as String,
      losers: json['losers'] != null ? List<String>.from(json['losers'] as List) : [],
      rescueCardGranted: json['rescueCardGranted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'winnerPlayerId': winnerPlayerId,
      'losers': losers,
      'rescueCardGranted': rescueCardGranted,
    };
  }
}

/// Replay event for animation sequencing
class ReplayEvent {
  final String type; // 'move', 'flip', 'bonus', 'rescueCard'
  final Map<String, dynamic> data;
  final int delayMs;

  const ReplayEvent({
    required this.type,
    required this.data,
    this.delayMs = 0,
  });

  factory ReplayEvent.fromJson(Map<String, dynamic> json) {
    return ReplayEvent(
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>,
      delayMs: json['delayMs'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': data,
      'delayMs': delayMs,
    };
  }
}

/// Round result document model for Firestore
/// Maps to 'roundResults' collection with document ID = matchId_roundIndex
class RoundResultModel {
  final String id; // matchId_roundIndex
  final String matchId;
  final int roundIndex;
  final List<SubmittedMove> submittedMoves;
  final List<CollisionResolution> collisionResolved;
  final List<String> processOrder; // [playerId1, playerId2, playerId3] - random order
  final List<ReplayEvent> replayEvents;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String bonusTriggered; // playerId or empty
  final List<String> rescueCardsGranted; // playerIds

  const RoundResultModel({
    required this.id,
    required this.matchId,
    required this.roundIndex,
    this.submittedMoves = const [],
    this.collisionResolved = const [],
    this.processOrder = const [],
    this.replayEvents = const [],
    required this.createdAt,
    this.processedAt,
    this.bonusTriggered = '',
    this.rescueCardsGranted = const [],
  });

  factory RoundResultModel.fromJson(Map<String, dynamic> json) {
    return RoundResultModel(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      roundIndex: json['roundIndex'] as int,
      submittedMoves: json['submittedMoves'] != null
        ? (json['submittedMoves'] as List).map((e) => SubmittedMove.fromJson(e as Map<String, dynamic>)).toList()
        : [],
      collisionResolved: json['collisionResolved'] != null
        ? (json['collisionResolved'] as List).map((e) => CollisionResolution.fromJson(e as Map<String, dynamic>)).toList()
        : [],
      processOrder: json['processOrder'] != null ? List<String>.from(json['processOrder'] as List) : [],
      replayEvents: json['replayEvents'] != null
        ? (json['replayEvents'] as List).map((e) => ReplayEvent.fromJson(e as Map<String, dynamic>)).toList()
        : [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      processedAt: json['processedAt'] != null ? DateTime.parse(json['processedAt'] as String) : null,
      bonusTriggered: json['bonusTriggered'] as String? ?? '',
      rescueCardsGranted: json['rescueCardsGranted'] != null ? List<String>.from(json['rescueCardsGranted'] as List) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matchId': matchId,
      'roundIndex': roundIndex,
      'submittedMoves': submittedMoves.map((e) => e.toJson()).toList(),
      'collisionResolved': collisionResolved.map((e) => e.toJson()).toList(),
      'processOrder': processOrder,
      'replayEvents': replayEvents.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'bonusTriggered': bonusTriggered,
      'rescueCardsGranted': rescueCardsGranted,
    };
  }
}
