import 'package:freezed_annotation/freezed_annotation.dart';

part 'replay_model.freezed.dart';
part 'replay_model.g.dart';

/// Replay asset stored in replays/{replayId}
@freezed
class Replay with _$Replay {
  const factory Replay({
    required String id, // Replay identifier
    required String matchId, // Source match
    required String creatorUid, // Player who shared
    required String videoUrl, // Cloud storage link
    String? thumbnail, // Preview image
    String? title, // Player's title
    String? description,
    @Default(true) bool isPublic, // Visibility
    @Default([]) List<String> tags, // #highlights, #clutch, etc.
    int? duration, // Video length in seconds
    required DateTime createdAt,
    @Default(0) int viewCount,
    @Default(0) int shareCount,
    @Default(0) int favoriteCount,
  }) = _Replay;

  factory Replay.fromJson(Map<String, dynamic> json) =>
      _$ReplayFromJson(json);
}

/// Replay view log stored in replays/{replayId}/views/{viewId}
@freezed
class ReplayView with _$ReplayView {
  const factory ReplayView({
    required String replayId,
    required String viewedByUid,
    required DateTime viewedAt,
    int? duration, // How long they watched
  }) = _ReplayView;

  factory ReplayView.fromJson(Map<String, dynamic> json) =>
      _$ReplayViewFromJson(json);
}
