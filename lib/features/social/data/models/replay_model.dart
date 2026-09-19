
/// Replay asset stored in replays/{replayId}
class Replay {
  final String id; // Replay identifier
  final String matchId; // Source match
  final String creatorUid; // Player who shared
  final String videoUrl; // Cloud storage link
  final String? thumbnail; // Preview image
  final String? title; // Player's title
  final String? description;
  final bool isPublic; // Visibility
  final List<String> tags; // #highlights, #clutch, etc.
  final int? duration; // Video length in seconds
  final DateTime createdAt;
  final int viewCount;
  final int shareCount;
  final int favoriteCount;

  const Replay({
    required this.id,
    required this.matchId,
    required this.creatorUid,
    required this.videoUrl,
    this.thumbnail,
    this.title,
    this.description,
    this.isPublic = true,
    this.tags = const [],
    this.duration,
    required this.createdAt,
    this.viewCount = 0,
    this.shareCount = 0,
    this.favoriteCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'matchId': matchId,
    'creatorUid': creatorUid,
    'videoUrl': videoUrl,
    'thumbnail': thumbnail,
    'title': title,
    'description': description,
    'isPublic': isPublic,
    'tags': tags,
    'duration': duration,
    'createdAt': createdAt.toIso8601String(),
    'viewCount': viewCount,
    'shareCount': shareCount,
    'favoriteCount': favoriteCount,
  };

  factory Replay.fromJson(Map<String, dynamic> json) => Replay(
    id: json['id'] as String,
    matchId: json['matchId'] as String,
    creatorUid: json['creatorUid'] as String,
    videoUrl: json['videoUrl'] as String,
    thumbnail: json['thumbnail'] as String?,
    title: json['title'] as String?,
    description: json['description'] as String?,
    isPublic: json['isPublic'] as bool? ?? true,
    tags: json['tags'] != null
        ? List<String>.from(json['tags'] as List)
        : const [],
    duration: json['duration'] as int?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    viewCount: json['viewCount'] as int? ?? 0,
    shareCount: json['shareCount'] as int? ?? 0,
    favoriteCount: json['favoriteCount'] as int? ?? 0,
  );
}

/// Replay view log stored in replays/{replayId}/views/{viewId}
class ReplayView {
  final String replayId;
  final String viewedByUid;
  final DateTime viewedAt;
  final int? duration; // How long they watched

  const ReplayView({
    required this.replayId,
    required this.viewedByUid,
    required this.viewedAt,
    this.duration,
  });

  Map<String, dynamic> toJson() => {
    'replayId': replayId,
    'viewedByUid': viewedByUid,
    'viewedAt': viewedAt.toIso8601String(),
    'duration': duration,
  };

  factory ReplayView.fromJson(Map<String, dynamic> json) => ReplayView(
    replayId: json['replayId'] as String,
    viewedByUid: json['viewedByUid'] as String,
    viewedAt: DateTime.parse(json['viewedAt'] as String),
    duration: json['duration'] as int?,
  );
}
