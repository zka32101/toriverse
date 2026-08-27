import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/spectating/domain/models/streaming_session.dart';

void main() {
  group('StreamingSession', () {
    test('creates session with correct data', () {
      final now = DateTime.now();
      final session = StreamingSession(
        id: 'session_123',
        matchId: 'match_456',
        userId: 'user_789',
        displayName: 'Streamer Name',
        startedAt: now,
        status: StreamingStatus.live,
        connectedPlatforms: const ['twitch', 'youtube'],
        twitchChannelUrl: 'https://twitch.tv/user',
        youtubeStreamUrl: 'https://youtube.com/live/user',
      );

      expect(session.id, 'session_123');
      expect(session.matchId, 'match_456');
      expect(session.userId, 'user_789');
      expect(session.displayName, 'Streamer Name');
      expect(session.startedAt, now);
      expect(session.status, StreamingStatus.live);
      expect(session.connectedPlatforms, ['twitch', 'youtube']);
    });

    test('serializes session to JSON correctly', () {
      final now = DateTime.now();
      final session = StreamingSession(
        id: 'session_123',
        matchId: 'match_456',
        userId: 'user_789',
        displayName: 'Streamer Name',
        startedAt: now,
        status: StreamingStatus.live,
      );

      final json = session.toJson();

      expect(json['id'], 'session_123');
      expect(json['matchId'], 'match_456');
      expect(json['userId'], 'user_789');
      expect(json['displayName'], 'Streamer Name');
      expect(json['status'], 'live');
    });

    test('deserializes session from JSON correctly', () {
      final now = DateTime.now();
      final json = {
        'id': 'session_123',
        'matchId': 'match_456',
        'userId': 'user_789',
        'displayName': 'Streamer Name',
        'startedAt': now.toIso8601String(),
        'status': 'live',
        'viewerCount': 150,
        'totalViews': 500,
        'connectedPlatforms': ['twitch', 'youtube'],
        'revenueEarned': 1500.0,
      };

      final session = StreamingSession.fromJson(json);

      expect(session.id, 'session_123');
      expect(session.matchId, 'match_456');
      expect(session.displayName, 'Streamer Name');
      expect(session.viewerCount, 150);
      expect(session.totalViews, 500);
    });

    test('handles different streaming statuses', () {
      const statuses = [
        StreamingStatus.offline,
        StreamingStatus.starting,
        StreamingStatus.live,
        StreamingStatus.paused,
        StreamingStatus.ending,
        StreamingStatus.offline_vod,
      ];

      for (final status in statuses) {
        final session = StreamingSession(
          id: 'session_123',
          matchId: 'match_456',
          userId: 'user_789',
          displayName: 'Streamer',
          startedAt: DateTime.now(),
          status: status,
        );

        expect(session.status, status);
      }
    });

    test('streaming status extension returns correct labels', () {
      expect(StreamingStatus.offline.label, 'Offline');
      expect(StreamingStatus.starting.label, 'Starting...');
      expect(StreamingStatus.live.label, 'Live 🔴');
      expect(StreamingStatus.paused.label, 'Paused');
      expect(StreamingStatus.ending.label, 'Ending...');
      expect(StreamingStatus.offline_vod.label, 'VOD Available');
    });

    test('streaming status isActive returns correct values', () {
      expect(StreamingStatus.live.isActive, true);
      expect(StreamingStatus.starting.isActive, true);
      expect(StreamingStatus.offline.isActive, false);
      expect(StreamingStatus.paused.isActive, false);
      expect(StreamingStatus.ending.isActive, false);
      expect(StreamingStatus.offline_vod.isActive, false);
    });
  });

  group('StreamingPlatform', () {
    test('returns correct labels', () {
      expect(StreamingPlatform.twitch.label, 'Twitch');
      expect(StreamingPlatform.youtube.label, 'YouTube Live');
      expect(StreamingPlatform.obs.label, 'OBS Browser Source');
    });

    test('returns correct icons', () {
      expect(StreamingPlatform.twitch.icon, '📺');
      expect(StreamingPlatform.youtube.icon, '📹');
      expect(StreamingPlatform.obs.icon, '🎬');
    });
  });

  group('StreamingMetadata', () {
    test('creates metadata with correct data', () {
      final metadata = StreamingMetadata(
        platform: 'twitch',
        platformUserId: 'twitch_12345',
        streamTitle: 'Epic Match Live!',
        streamDescription: 'Exciting 3-player match',
        tags: const ['gaming', 'ohtani'],
        gameTitleOverride: 'Three Color Othello',
        autoArchive: true,
      );

      expect(metadata.platform, 'twitch');
      expect(metadata.platformUserId, 'twitch_12345');
      expect(metadata.streamTitle, 'Epic Match Live!');
      expect(metadata.tags, ['gaming', 'ohtani']);
      expect(metadata.autoArchive, true);
    });

    test('serializes metadata to JSON correctly', () {
      final metadata = StreamingMetadata(
        platform: 'youtube',
        platformUserId: 'youtube_67890',
        streamTitle: 'Live Stream',
      );

      final json = metadata.toJson();

      expect(json['platform'], 'youtube');
      expect(json['platformUserId'], 'youtube_67890');
      expect(json['streamTitle'], 'Live Stream');
    });

    test('deserializes metadata from JSON correctly', () {
      final json = {
        'platform': 'twitch',
        'platformUserId': 'twitch_12345',
        'streamTitle': 'Test Stream',
        'tags': ['test', 'gaming'],
        'autoArchive': true,
      };

      final metadata = StreamingMetadata.fromJson(json);

      expect(metadata.platform, 'twitch');
      expect(metadata.tags, ['test', 'gaming']);
      expect(metadata.autoArchive, true);
    });
  });

  group('HighlightClip', () {
    test('creates highlight clip with correct data', () {
      final now = DateTime.now();
      final clip = HighlightClip(
        id: 'clip_123',
        streamingSessionId: 'session_456',
        matchId: 'match_789',
        title: 'Epic Reversal!',
        description: 'Amazing comeback in final round',
        startTime: const Duration(seconds: 120),
        endTime: const Duration(seconds: 180),
        type: HighlightType.epic,
        viewCount: 1500,
        shareCount: 50,
        createdAt: now,
      );

      expect(clip.id, 'clip_123');
      expect(clip.title, 'Epic Reversal!');
      expect(clip.type, HighlightType.epic);
      expect(clip.viewCount, 1500);
      expect(clip.shareCount, 50);
    });

    test('highlight type extension returns correct labels', () {
      expect(HighlightType.milestone.label, 'Milestone');
      expect(HighlightType.epic.label, 'Epic Moment');
      expect(HighlightType.turnover.label, 'Turnaround');
      expect(HighlightType.funny.label, 'Funny Moment');
      expect(HighlightType.close_call.label, 'Close Call');
      expect(HighlightType.championship.label, 'Championship');
    });

    test('highlight type extension returns correct emojis', () {
      expect(HighlightType.milestone.emoji, '🏁');
      expect(HighlightType.epic.emoji, '🔥');
      expect(HighlightType.turnover.emoji, '💫');
      expect(HighlightType.funny.emoji, '😂');
      expect(HighlightType.close_call.emoji, '😰');
      expect(HighlightType.championship.emoji, '👑');
    });

    test('serializes highlight clip to JSON correctly', () {
      final clip = HighlightClip(
        id: 'clip_123',
        streamingSessionId: 'session_456',
        matchId: 'match_789',
        title: 'Epic Reversal!',
        description: 'Amazing comeback',
        startTime: const Duration(seconds: 120),
        endTime: const Duration(seconds: 180),
        type: HighlightType.epic,
      );

      final json = clip.toJson();

      expect(json['id'], 'clip_123');
      expect(json['title'], 'Epic Reversal!');
      expect(json['type'], 'epic');
    });

    test('deserializes highlight clip from JSON correctly', () {
      final json = {
        'id': 'clip_123',
        'streamingSessionId': 'session_456',
        'matchId': 'match_789',
        'title': 'Epic Reversal!',
        'description': 'Amazing comeback',
        'startTime': '0:02:00.000000',
        'endTime': '0:03:00.000000',
        'type': 'epic',
        'viewCount': 1500,
        'shareCount': 50,
        'isApproved': false,
      };

      final clip = HighlightClip.fromJson(json);

      expect(clip.id, 'clip_123');
      expect(clip.title, 'Epic Reversal!');
      expect(clip.viewCount, 1500);
    });
  });

  group('OBSSourceConfig', () {
    test('creates OBS config with correct data', () {
      final config = OBSSourceConfig(
        matchId: 'match_123',
        streamKey: 'abc123def456',
        showChat: true,
        showScoreboard: true,
        showPlayerNames: true,
        overlayTheme: 'dark',
      );

      expect(config.matchId, 'match_123');
      expect(config.streamKey, 'abc123def456');
      expect(config.showChat, true);
      expect(config.showScoreboard, true);
      expect(config.showPlayerNames, true);
    });

    test('generates correct OBS source URL', () {
      final config = OBSSourceConfig(
        matchId: 'match_123',
        streamKey: 'abc123def456',
        showChat: true,
        showScoreboard: true,
        showPlayerNames: true,
        overlayTheme: 'dark',
      );

      final url = config.sourceUrl;

      expect(url.contains('matchId=match_123'), true);
      expect(url.contains('streamKey=abc123def456'), true);
      expect(url.contains('showChat=true'), true);
      expect(url.contains('theme=dark'), true);
      expect(url.startsWith('https://toriverse.app/spectate/obs'), true);
    });

    test('exports configuration as JSON', () {
      final config = OBSSourceConfig(
        matchId: 'match_123',
        streamKey: 'abc123def456',
      );

      final json = config.toJson();

      expect(json['matchId'], 'match_123');
      expect(json['streamKey'], 'abc123def456');
      expect(json['showChat'], true);
      expect(json['showScoreboard'], true);
      expect(json['showPlayerNames'], true);
    });
  });

  group('StreamingAnalyticsEvent', () {
    test('creates analytics event with correct data', () {
      final event = StreamingAnalyticsEvent(
        streamingSessionId: 'session_123',
        eventType: 'stream_started',
        parameters: {'platform': 'twitch'},
      );

      expect(event.streamingSessionId, 'session_123');
      expect(event.eventType, 'stream_started');
      expect(event.parameters['platform'], 'twitch');
      expect(event.timestamp.isBefore(DateTime.now().add(const Duration(seconds: 1))), true);
    });

    test('converts analytics event to JSON', () {
      final event = StreamingAnalyticsEvent(
        streamingSessionId: 'session_123',
        eventType: 'stream_started',
        parameters: {'platform': 'twitch', 'viewerCount': 50},
      );

      final json = event.toJson();

      expect(json['streamingSessionId'], 'session_123');
      expect(json['eventType'], 'stream_started');
      expect(json['parameters']['platform'], 'twitch');
      expect(json['parameters']['viewerCount'], 50);
    });
  });

  group('StreamerEarnings', () {
    test('creates earnings summary with correct data', () {
      final now = DateTime.now();
      final earnings = StreamerEarnings(
        userId: 'user_123',
        periodStart: now.subtract(const Duration(days: 7)),
        periodEnd: now,
        totalStreamMinutes: 420,
        totalViewerMinutes: 21000,
        totalClipViews: 5000,
        streamingRevenue: 4200.0,
        clipRevenue: 25000.0,
        totalEarnings: 29200.0,
      );

      expect(earnings.userId, 'user_123');
      expect(earnings.totalStreamMinutes, 420);
      expect(earnings.totalViewerMinutes, 21000);
      expect(earnings.totalClipViews, 5000);
      expect(earnings.streamingRevenue, 4200.0);
      expect(earnings.clipRevenue, 25000.0);
      expect(earnings.totalEarnings, 29200.0);
    });

    test('serializes earnings to JSON correctly', () {
      final now = DateTime.now();
      final earnings = StreamerEarnings(
        userId: 'user_123',
        periodStart: now.subtract(const Duration(days: 7)),
        periodEnd: now,
        totalStreamMinutes: 420,
      );

      final json = earnings.toJson();

      expect(json['userId'], 'user_123');
      expect(json['totalStreamMinutes'], 420);
    });

    test('deserializes earnings from JSON correctly', () {
      final now = DateTime.now();
      final json = {
        'userId': 'user_123',
        'periodStart': now.subtract(const Duration(days: 7)).toIso8601String(),
        'periodEnd': now.toIso8601String(),
        'totalStreamMinutes': 420,
        'totalViewerMinutes': 21000,
        'totalClipViews': 5000,
        'streamingRevenue': 4200.0,
        'clipRevenue': 25000.0,
        'totalEarnings': 29200.0,
      };

      final earnings = StreamerEarnings.fromJson(json);

      expect(earnings.userId, 'user_123');
      expect(earnings.totalStreamMinutes, 420);
      expect(earnings.streamingRevenue, 4200.0);
    });
  });
}
