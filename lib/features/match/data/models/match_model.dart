/// Match (対局) document model for Firestore
/// Maps to 'matches' collection with auto-generated document ID
///
/// 3-color Othello board state representation:
/// - boardState: 64-element list (8x8 flattened) with values:
///   0 = black (黒), 1 = white (白), 2 = red (赤), -1 = empty (空き)
/// - players: exactly 3 player UIDs or "AI_<identifier>" for AI substitutes
/// - roundIndex: current round number (0-indexed), increments after simultaneous reveal
/// - status: 'waiting' (filling seats), 'playing' (active round), 'finished' (completed)
class MatchModel {
  final String id;
  final List<String> players; // exactly 3 items (UIDs or "AI_*")
  final List<int> boardState; // 64-element array: 0=black, 1=white, 2=red, -1=empty
  final int roundIndex;
  final String status; // 'waiting', 'playing', 'finished'
  final String currentPhase; // 'submitPhase', 'revealPhase'
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final List<String> readyPlayers; // players who have joined (for partial fills)
  final List<int> finalScores; // [black_count, white_count, red_count] at end

  const MatchModel({
    required this.id,
    required this.players,
    required this.boardState,
    this.roundIndex = 0,
    this.status = 'waiting',
    this.currentPhase = '',
    required this.createdAt,
    this.startedAt,
    this.finishedAt,
    this.readyPlayers = const [],
    this.finalScores = const [],
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] as String,
      players: List<String>.from(json['players'] as List),
      boardState: List<int>.from(json['boardState'] as List),
      roundIndex: json['roundIndex'] as int? ?? 0,
      status: json['status'] as String? ?? 'waiting',
      currentPhase: json['currentPhase'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt'] as String) : null,
      finishedAt: json['finishedAt'] != null ? DateTime.parse(json['finishedAt'] as String) : null,
      readyPlayers: json['readyPlayers'] != null ? List<String>.from(json['readyPlayers'] as List) : [],
      finalScores: json['finalScores'] != null ? List<int>.from(json['finalScores'] as List) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'players': players,
      'boardState': boardState,
      'roundIndex': roundIndex,
      'status': status,
      'currentPhase': currentPhase,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'finishedAt': finishedAt?.toIso8601String(),
      'readyPlayers': readyPlayers,
      'finalScores': finalScores,
    };
  }
}
