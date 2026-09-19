
/// Replay asset stored in replays/{replayId}
class Replay {
  const Replay({
    required String id, // Replay identifier
    required String matchId, // Source match
    required String creatorUid, // Player who shared
    required String videoUrl, // Cloud storage link
    String? thumbnail, // Preview image
    String? title, // Player's title
    String? description,
    bool isPublic, // Visibility
    List<String> tags, // #highlights, #clutch, etc.
    int? duration, // Video length in seconds
    required DateTime createdAt,
    int viewCount,
    int shareCount,
    int favoriteCount,
  });
}

/// Replay view log stored in replays/{replayId}/views/{viewId}
class ReplayView {
  const ReplayView({
    required String replayId,
    required String viewedByUid,
    required DateTime viewedAt,
    int? duration, // How long they watched
  });
}
