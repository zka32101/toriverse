
/// Parses a DateTime from JSON. Tolerates ISO-8601 strings (our own
/// [toJson] output), raw [DateTime] instances, and duck-typed Firestore
/// `Timestamp` objects (which expose a `toDate()` method) since some
/// fields are written server-side via `FieldValue.serverTimestamp()` and
/// read back without going through [toJson].
DateTime _parseDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.parse(value);
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  try {
    return (value as dynamic).toDate() as DateTime;
  } catch (_) {
    return DateTime.now();
  }
}

/// Represents a spectator's view of an active match
class SpectatorSession {
  final String id;
  final String matchId;
  final String userId;
  final String displayName;
  final DateTime joinedAt;
  final SpectatorRole role;
  final DeviceInfo deviceInfo;
  final bool isActive;
  final DateTime lastActivityAt;

  const SpectatorSession({
    required this.id,
    required this.matchId,
    required this.userId,
    required this.displayName,
    required this.joinedAt,
    required this.role,
    required this.deviceInfo,
    required this.isActive,
    required this.lastActivityAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'matchId': matchId,
        'userId': userId,
        'displayName': displayName,
        'joinedAt': joinedAt.toIso8601String(),
        'role': role.name,
        'deviceInfo': deviceInfo.toJson(),
        'isActive': isActive,
        'lastActivityAt': lastActivityAt.toIso8601String(),
      };

  factory SpectatorSession.fromJson(Map<String, dynamic> json) {
    return SpectatorSession(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      joinedAt: _parseDateTime(json['joinedAt']),
      role: SpectatorRole.values.byName(json['role'] as String),
      deviceInfo:
          DeviceInfo.fromJson(json['deviceInfo'] as Map<String, dynamic>),
      isActive: json['isActive'] as bool,
      lastActivityAt: _parseDateTime(json['lastActivityAt']),
    );
  }
}

/// Role of spectator in the match
enum SpectatorRole {
  viewer,      // Regular spectator
  commentator, // Elevated permissions (Phase 2b)
  streamer,    // Streaming to OBS/Twitch (Phase 2c)
}

/// Device information for spectator
class DeviceInfo {
  final String os;
  final String osVersion;
  final String appVersion;
  final String platform;

  const DeviceInfo({
    required this.os,           // "iOS", "Android", "Web"
    required this.osVersion,
    required this.appVersion,
    required this.platform,
  });

  Map<String, dynamic> toJson() => {
        'os': os,
        'osVersion': osVersion,
        'appVersion': appVersion,
        'platform': platform,
      };

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      os: json['os'] as String,
      osVersion: json['osVersion'] as String,
      appVersion: json['appVersion'] as String,
      platform: json['platform'] as String,
    );
  }
}
