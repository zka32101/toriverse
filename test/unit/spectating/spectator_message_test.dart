import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/spectating/domain/models/spectator_message.dart';

void main() {
  group('SpectatorMessage', () {
    test('creates message with correct data', () {
      final now = DateTime.now();
      final message = SpectatorMessage(
        id: 'msg123',
        matchId: 'match456',
        userId: 'user789',
        displayName: 'John Commenter',
        text: 'Great move!',
        createdAt: now,
        role: SpectatorChatRole.viewer,
      );

      expect(message.id, 'msg123');
      expect(message.matchId, 'match456');
      expect(message.userId, 'user789');
      expect(message.displayName, 'John Commenter');
      expect(message.text, 'Great move!');
      expect(message.role, SpectatorChatRole.viewer);
      expect(message.isModerated, false);
      expect(message.isPinned, false);
    });

    test('serializes message to JSON correctly', () {
      final now = DateTime.now();
      final message = SpectatorMessage(
        id: 'msg123',
        matchId: 'match456',
        userId: 'user789',
        displayName: 'Jane Spectator',
        text: 'Amazing play!',
        createdAt: now,
        role: SpectatorChatRole.commentator,
        isPinned: true,
      );

      final json = message.toJson();

      expect(json['id'], 'msg123');
      expect(json['matchId'], 'match456');
      expect(json['displayName'], 'Jane Spectator');
      expect(json['text'], 'Amazing play!');
      expect(json['isPinned'], true);
      expect(json['role'], 'commentator');
    });

    test('deserializes message from JSON correctly', () {
      final json = {
        'id': 'msg999',
        'matchId': 'match888',
        'userId': 'user777',
        'displayName': 'Bob Watcher',
        'text': 'Nice!',
        'createdAt': DateTime.now(),
        'isModerated': false,
        'isPinned': false,
        'role': 'viewer',
      };

      final message = SpectatorMessage.fromJson(json);

      expect(message.id, 'msg999');
      expect(message.matchId, 'match888');
      expect(message.displayName, 'Bob Watcher');
      expect(message.text, 'Nice!');
      expect(message.role, SpectatorChatRole.viewer);
    });

    test('handles different chat roles', () {
      final roles = [
        SpectatorChatRole.viewer,
        SpectatorChatRole.commentator,
        SpectatorChatRole.streamer,
        SpectatorChatRole.moderator,
      ];

      for (final role in roles) {
        final message = SpectatorMessage(
          id: 'msg_$role',
          matchId: 'match123',
          userId: 'user_$role',
          displayName: 'Test User',
          text: 'Test message',
          createdAt: DateTime.now(),
          role: role,
        );

        expect(message.role, role);
      }
    });

    test('moderates message with content flag', () {
      final message = SpectatorMessage(
        id: 'msg123',
        matchId: 'match456',
        userId: 'user789',
        displayName: 'Flagged User',
        text: 'Some text',
        createdAt: DateTime.now(),
        isModerated: true,
        moderationReason: 'Profanity',
      );

      expect(message.isModerated, true);
      expect(message.moderationReason, 'Profanity');
    });

    test('pins message with moderator control', () {
      final message = SpectatorMessage(
        id: 'msg123',
        matchId: 'match456',
        userId: 'user789',
        displayName: 'Important Message',
        text: 'Match result announced',
        createdAt: DateTime.now(),
        isPinned: true,
      );

      expect(message.isPinned, true);
    });

    test('tracks emoji reactions', () {
      final message = SpectatorMessage(
        id: 'msg123',
        matchId: 'match456',
        userId: 'user789',
        displayName: 'Happy Spectator',
        text: 'Amazing play!',
        createdAt: DateTime.now(),
        emoji: '🔥',
      );

      expect(message.emoji, '🔥');
    });
  });

  group('SpectatorChatRole', () {
    test('viewer role has correct properties', () {
      final role = SpectatorChatRole.viewer;
      expect(role.label, 'Viewer');
      expect(role.emoji, '👁️');
      expect(role.canPin, false);
      expect(role.canModerate, false);
      expect(role.canBan, false);
    });

    test('commentator role has correct permissions', () {
      final role = SpectatorChatRole.commentator;
      expect(role.label, 'Commentator');
      expect(role.emoji, '🎤');
      expect(role.canPin, true);
      expect(role.canModerate, false);
      expect(role.canBan, false);
    });

    test('streamer role has all permissions', () {
      final role = SpectatorChatRole.streamer;
      expect(role.label, 'Streamer');
      expect(role.emoji, '📺');
      expect(role.canPin, true);
      expect(role.canModerate, true);
      expect(role.canBan, false);
    });

    test('moderator role can ban users', () {
      final role = SpectatorChatRole.moderator;
      expect(role.label, 'Moderator');
      expect(role.emoji, '🛡️');
      expect(role.canPin, true);
      expect(role.canModerate, true);
      expect(role.canBan, true);
    });
  });

  group('ChatModerationConfig', () {
    test('has correct moderation settings', () {
      expect(ChatModerationConfig.maxMessageLength, 500);
      expect(ChatModerationConfig.minMessageLength, 1);
      expect(ChatModerationConfig.messageRetentionDays, 7);
      expect(ChatModerationConfig.rateLimitMessagesPerSecond, 0.5);
    });

    test('has profanity patterns', () {
      expect(ChatModerationConfig.profanityPatterns, isNotEmpty);
    });

    test('has spam patterns', () {
      expect(ChatModerationConfig.spamPatterns, isNotEmpty);
    });

    test('has advertisement patterns', () {
      expect(ChatModerationConfig.adPatterns, isNotEmpty);
    });
  });

  group('ModerationReason', () {
    test('profanity has display name', () {
      expect(ModerationReason.profanity.displayName, 'Profanity');
    });

    test('spam has display name', () {
      expect(ModerationReason.spam.displayName, 'Spam');
    });

    test('advertisement has display name', () {
      expect(ModerationReason.advertisement.displayName, 'Advertisement');
    });

    test('harassment has display name', () {
      expect(ModerationReason.harassment.displayName, 'Harassment');
    });

    test('other has display name', () {
      expect(ModerationReason.other.displayName, 'Violation');
    });
  });

  group('SpectatorChatEvent', () {
    test('creates analytics event with correct data', () {
      final event = SpectatorChatEvent(
        matchId: 'match123',
        userId: 'user456',
        eventType: 'message_sent',
        parameters: {'messageLength': 50},
      );

      expect(event.matchId, 'match123');
      expect(event.userId, 'user456');
      expect(event.eventType, 'message_sent');
      expect(event.parameters['messageLength'], 50);
    });

    test('converts event to JSON', () {
      final event = SpectatorChatEvent(
        matchId: 'match123',
        userId: 'user456',
        eventType: 'message_moderated',
        parameters: {'reason': 'profanity'},
      );

      final json = event.toJson();

      expect(json['matchId'], 'match123');
      expect(json['userId'], 'user456');
      expect(json['eventType'], 'message_moderated');
      expect(json['parameters']['reason'], 'profanity');
    });
  });
}
