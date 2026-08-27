import 'package:freezed_annotation/freezed_annotation.dart';

part 'spectator_session.freezed.dart';
part 'spectator_session.g.dart';

/// Represents a spectator's view of an active match
@freezed
class SpectatorSession with _$SpectatorSession {
  const factory SpectatorSession({
    required String id,
    required String matchId,
    required String userId,
    required String displayName,
    required DateTime joinedAt,
    required SpectatorRole role,
    required DeviceInfo deviceInfo,
    required bool isActive,
    required DateTime lastActivityAt,
  }) = _SpectatorSession;

  factory SpectatorSession.fromJson(Map<String, dynamic> json) =>
      _$SpectatorSessionFromJson(json);
}

/// Role of spectator in the match
enum SpectatorRole {
  viewer,      // Regular spectator
  commentator, // Elevated permissions (Phase 2b)
  streamer,    // Streaming to OBS/Twitch (Phase 2c)
}

/// Device information for spectator
@freezed
class DeviceInfo with _$DeviceInfo {
  const factory DeviceInfo({
    required String os,           // "iOS", "Android", "Web"
    required String osVersion,
    required String appVersion,
    required String platform,
  }) = _DeviceInfo;

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);
}
