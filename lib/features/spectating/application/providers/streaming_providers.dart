import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/spectating/data/repositories/streaming_repository.dart';
import 'package:toriverse/features/spectating/domain/models/streaming_session.dart';

/// Streaming repository provider for dependency injection
final streamingRepositoryProvider = Provider((ref) {
  return StreamingRepository();
});

/// Start a new streaming session
///
/// Creates streaming session and connects to Twitch/YouTube/OBS.
final startStreamingSessionProvider = FutureProvider.autoDispose
    .family<StreamingSession, _StartStreamingParams>((ref, params) async {
  final repo = ref.watch(streamingRepositoryProvider);

  return repo.startStreamingSession(
    matchId: params.matchId,
    userId: params.userId,
    displayName: params.displayName,
    targetPlatforms: params.targetPlatforms,
    streamTitle: params.streamTitle,
    streamDescription: params.streamDescription,
  );
});

/// End active streaming session
final endStreamingSessionProvider = FutureProvider.autoDispose
    .family<void, _EndStreamingParams>((ref, params) async {
  final repo = ref.watch(streamingRepositoryProvider);

  return repo.endStreamingSession(
    sessionId: params.sessionId,
    matchId: params.matchId,
  );
});

/// Watch real-time viewer count for active stream
final viewerCountProvider =
    StreamProvider.family<int, String>((ref, sessionId) {
  final repo = ref.watch(streamingRepositoryProvider);
  return repo.watchViewerCount(sessionId);
});

/// Update viewer count (called from backend)
final updateViewerCountProvider = FutureProvider.autoDispose
    .family<void, _UpdateViewerCountParams>((ref, params) async {
  final repo = ref.watch(streamingRepositoryProvider);

  return repo.updateViewerCount(params.sessionId, params.viewerCount);
});

/// Watch highlight clips generated during stream
final highlightClipsProvider =
    StreamProvider.family<List<HighlightClip>, String>((ref, sessionId) {
  final repo = ref.watch(streamingRepositoryProvider);
  return repo.watchHighlightClips(sessionId);
});

/// Generate new highlight clip
final generateHighlightClipProvider = FutureProvider.autoDispose
    .family<HighlightClip, _GenerateHighlightParams>((ref, params) async {
  final repo = ref.watch(streamingRepositoryProvider);

  return repo.generateHighlightClip(
    sessionId: params.sessionId,
    matchId: params.matchId,
    title: params.title,
    description: params.description,
    startTime: params.startTime,
    endTime: params.endTime,
    type: params.type,
  );
});

/// Get streamer earnings summary
final streamerEarningsProvider = FutureProvider.family<StreamerEarnings,
    _GetEarningsParams>((ref, params) {
  final repo = ref.watch(streamingRepositoryProvider);

  return repo.getStreamerEarnings(
    userId: params.userId,
    periodStart: params.periodStart,
    periodEnd: params.periodEnd,
  );
});

/// Get OBS browser source configuration
final obsConfigProvider =
    FutureProvider.family<OBSSourceConfig, String>((ref, sessionId) {
  final repo = ref.watch(streamingRepositoryProvider);
  return repo.getOBSConfig(sessionId);
});

/// Get public stream status (for display on home screen)
final publicStreamStatusProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) {
  final repo = ref.watch(streamingRepositoryProvider);
  return repo.getPublicStreamStatus(userId);
});

/// Record streaming analytics event
final recordStreamingEventProvider = FutureProvider.autoDispose
    .family<void, StreamingAnalyticsEvent>((ref, event) async {
  // Analytics logging handled internally by repository
});

// ============================================================================
// Parameter classes
// ============================================================================

/// Parameters for starting a streaming session
class _StartStreamingParams {
  final String matchId;
  final String userId;
  final String displayName;
  final List<StreamingPlatform> targetPlatforms;
  final String? streamTitle;
  final String? streamDescription;

  _StartStreamingParams({
    required this.matchId,
    required this.userId,
    required this.displayName,
    required this.targetPlatforms,
    this.streamTitle,
    this.streamDescription,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _StartStreamingParams &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId &&
          userId == other.userId &&
          displayName == other.displayName &&
          targetPlatforms == other.targetPlatforms &&
          streamTitle == other.streamTitle &&
          streamDescription == other.streamDescription;

  @override
  int get hashCode =>
      matchId.hashCode ^
      userId.hashCode ^
      displayName.hashCode ^
      targetPlatforms.hashCode ^
      streamTitle.hashCode ^
      streamDescription.hashCode;
}

/// Parameters for ending a streaming session
class _EndStreamingParams {
  final String sessionId;
  final String matchId;

  _EndStreamingParams({
    required this.sessionId,
    required this.matchId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _EndStreamingParams &&
          runtimeType == other.runtimeType &&
          sessionId == other.sessionId &&
          matchId == other.matchId;

  @override
  int get hashCode => sessionId.hashCode ^ matchId.hashCode;
}

/// Parameters for updating viewer count
class _UpdateViewerCountParams {
  final String sessionId;
  final int viewerCount;

  _UpdateViewerCountParams({
    required this.sessionId,
    required this.viewerCount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _UpdateViewerCountParams &&
          runtimeType == other.runtimeType &&
          sessionId == other.sessionId &&
          viewerCount == other.viewerCount;

  @override
  int get hashCode => sessionId.hashCode ^ viewerCount.hashCode;
}

/// Parameters for generating a highlight clip
class _GenerateHighlightParams {
  final String sessionId;
  final String matchId;
  final String title;
  final String description;
  final Duration startTime;
  final Duration endTime;
  final HighlightType type;

  _GenerateHighlightParams({
    required this.sessionId,
    required this.matchId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.type,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _GenerateHighlightParams &&
          runtimeType == other.runtimeType &&
          sessionId == other.sessionId &&
          matchId == other.matchId &&
          title == other.title &&
          description == other.description &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          type == other.type;

  @override
  int get hashCode =>
      sessionId.hashCode ^
      matchId.hashCode ^
      title.hashCode ^
      description.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      type.hashCode;
}

/// Parameters for getting streamer earnings
class _GetEarningsParams {
  final String userId;
  final DateTime periodStart;
  final DateTime periodEnd;

  _GetEarningsParams({
    required this.userId,
    required this.periodStart,
    required this.periodEnd,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _GetEarningsParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          periodStart == other.periodStart &&
          periodEnd == other.periodEnd;

  @override
  int get hashCode =>
      userId.hashCode ^ periodStart.hashCode ^ periodEnd.hashCode;
}
