import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/spectating/domain/models/spectator_session.dart';

void main() {
  group('SpectatorSession', () {
    test('creates spectator session with correct data', () {
      final now = DateTime.now();
      final deviceInfo = const DeviceInfo(
        os: 'iOS',
        osVersion: '17.0',
        appVersion: '1.0.0',
        platform: 'mobile',
      );

      final session = SpectatorSession(
        id: 'user123',
        matchId: 'match456',
        userId: 'user123',
        displayName: 'John Spectator',
        joinedAt: now,
        role: SpectatorRole.viewer,
        deviceInfo: deviceInfo,
        isActive: true,
        lastActivityAt: now,
      );

      expect(session.id, 'user123');
      expect(session.matchId, 'match456');
      expect(session.userId, 'user123');
      expect(session.displayName, 'John Spectator');
      expect(session.role, SpectatorRole.viewer);
      expect(session.isActive, true);
    });

    test('serializes to JSON correctly', () {
      final now = DateTime.now();
      final deviceInfo = const DeviceInfo(
        os: 'Android',
        osVersion: '14',
        appVersion: '1.0.0',
        platform: 'mobile',
      );

      final session = SpectatorSession(
        id: 'user789',
        matchId: 'match001',
        userId: 'user789',
        displayName: 'Jane Watcher',
        joinedAt: now,
        role: SpectatorRole.commentator,
        deviceInfo: deviceInfo,
        isActive: true,
        lastActivityAt: now,
      );

      final json = session.toJson();

      expect(json['id'], 'user789');
      expect(json['matchId'], 'match001');
      expect(json['displayName'], 'Jane Watcher');
      expect(json['role'], 'commentator');
      expect(json['isActive'], true);
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'id': 'user999',
        'matchId': 'match888',
        'userId': 'user999',
        'displayName': 'Bob Spectator',
        'joinedAt': Timestamp.now(),
        'role': 'viewer',
        'deviceInfo': {
          'os': 'iOS',
          'osVersion': '16.0',
          'appVersion': '1.0.0',
          'platform': 'mobile',
        },
        'isActive': true,
        'lastActivityAt': Timestamp.now(),
      };

      final session = SpectatorSession.fromJson(json);

      expect(session.id, 'user999');
      expect(session.matchId, 'match888');
      expect(session.displayName, 'Bob Spectator');
      expect(session.role, SpectatorRole.viewer);
    });

    test('handles different spectator roles', () {
      final now = DateTime.now();
      final deviceInfo = const DeviceInfo(
        os: 'iOS',
        osVersion: '17.0',
        appVersion: '1.0.0',
        platform: 'mobile',
      );

      final roles = [
        SpectatorRole.viewer,
        SpectatorRole.commentator,
        SpectatorRole.streamer,
      ];

      for (final role in roles) {
        final session = SpectatorSession(
          id: 'user_$role',
          matchId: 'match123',
          userId: 'user_$role',
          displayName: 'Test User',
          joinedAt: now,
          role: role,
          deviceInfo: deviceInfo,
          isActive: true,
          lastActivityAt: now,
        );

        expect(session.role, role);
      }
    });

    test('validates device info fields', () {
      const deviceInfo = DeviceInfo(
        os: 'Android',
        osVersion: '14',
        appVersion: '1.0.0',
        platform: 'mobile',
      );

      expect(deviceInfo.os, 'Android');
      expect(deviceInfo.osVersion, '14');
      expect(deviceInfo.appVersion, '1.0.0');
      expect(deviceInfo.platform, 'mobile');
    });

    test('tracks join and last activity times', () {
      final joinTime = DateTime(2026, 8, 27, 10, 0, 0);
      final lastActivityTime = DateTime(2026, 8, 27, 10, 15, 30);
      final deviceInfo = const DeviceInfo(
        os: 'iOS',
        osVersion: '17.0',
        appVersion: '1.0.0',
        platform: 'mobile',
      );

      final session = SpectatorSession(
        id: 'user123',
        matchId: 'match456',
        userId: 'user123',
        displayName: 'Test User',
        joinedAt: joinTime,
        role: SpectatorRole.viewer,
        deviceInfo: deviceInfo,
        isActive: true,
        lastActivityAt: lastActivityTime,
      );

      expect(session.joinedAt, joinTime);
      expect(session.lastActivityAt, lastActivityTime);

      final watchDuration = session.lastActivityAt.difference(session.joinedAt);
      expect(watchDuration.inMinutes, 15);
    });
  });
}

// Mock Timestamp class for testing
class Timestamp {
  static Timestamp now() => Timestamp();
}
