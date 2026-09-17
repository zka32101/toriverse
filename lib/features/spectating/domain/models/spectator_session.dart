
/// Represents a spectator's view of an active match
class SpectatorSession {
  const SpectatorSession({
    required String id,
    required String matchId,
    required String userId,
    required String displayName,
    required DateTime joinedAt,
    required SpectatorRole role,
    required DeviceInfo deviceInfo,
    required bool isActive,
    required DateTime lastActivityAt,
  });
}

/// Role of spectator in the match
enum SpectatorRole {
  viewer,      // Regular spectator
  commentator, // Elevated permissions (Phase 2b)
  streamer,    // Streaming to OBS/Twitch (Phase 2c)
}

/// Device information for spectator
class DeviceInfo {
  const DeviceInfo({
    required String os,           // "iOS", "Android", "Web"
    required String osVersion,
    required String appVersion,
    required String platform,
  });
}
