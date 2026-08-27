import 'package:freezed_annotation/freezed_annotation.dart';

part 'spectator_message.freezed.dart';
part 'spectator_message.g.dart';

/// Spectator chat message model
///
/// Represents a single message sent in spectator chat during a match.
/// Supports moderation, emoji reactions, and message pinning.
@freezed
class SpectatorMessage with _$SpectatorMessage {
  const factory SpectatorMessage({
    required String id,                  // Unique message ID
    required String matchId,             // Match being watched
    required String userId,              // Who sent the message
    required String displayName,         // Sender's display name
    required String text,                // Message content (max 500 chars)
    required DateTime createdAt,         // When message was sent
    @Default(false) bool isModerated,    // Content flagged by moderation
    String? moderationReason,            // Why message was moderated
    String? emoji,                       // Optional reaction emoji
    @Default(false) bool isPinned,       // Moderator pinned this message
    @Default(SpectatorChatRole.viewer)
      SpectatorChatRole role,            // Sender's role (viewer/commentator/streamer)
  }) = _SpectatorMessage;

  factory SpectatorMessage.fromJson(Map<String, dynamic> json) =>
      _$SpectatorMessageFromJson(json);
}

/// Spectator chat user role with special permissions
enum SpectatorChatRole {
  viewer,        // Basic spectator - can only read and send messages
  commentator,   // Elevated role - can pin messages and see analytics
  streamer,      // Streamer role - all permissions + featured badge
  moderator,     // Moderator - can ban, mute, delete messages
}

/// Extension for SpectatorChatRole display
extension SpectatorChatRoleExt on SpectatorChatRole {
  String get label {
    switch (this) {
      case SpectatorChatRole.viewer:
        return 'Viewer';
      case SpectatorChatRole.commentator:
        return 'Commentator';
      case SpectatorChatRole.streamer:
        return 'Streamer';
      case SpectatorChatRole.moderator:
        return 'Moderator';
    }
  }

  String get emoji {
    switch (this) {
      case SpectatorChatRole.viewer:
        return '👁️';
      case SpectatorChatRole.commentator:
        return '🎤';
      case SpectatorChatRole.streamer:
        return '📺';
      case SpectatorChatRole.moderator:
        return '🛡️';
    }
  }

  bool get canPin {
    return this == SpectatorChatRole.commentator ||
        this == SpectatorChatRole.streamer ||
        this == SpectatorChatRole.moderator;
  }

  bool get canModerate {
    return this == SpectatorChatRole.streamer ||
        this == SpectatorChatRole.moderator;
  }

  bool get canBan {
    return this == SpectatorChatRole.moderator;
  }
}

/// Chat moderation violation types
enum ModerationReason {
  profanity,     // Contains profanity
  spam,          // Spam or repeated content
  advertisement, // Promotional/advertising content
  harassment,    // Targeted harassment
  other,         // Other violation
}

extension ModerationReasonExt on ModerationReason {
  String get displayName {
    switch (this) {
      case ModerationReason.profanity:
        return 'Profanity';
      case ModerationReason.spam:
        return 'Spam';
      case ModerationReason.advertisement:
        return 'Advertisement';
      case ModerationReason.harassment:
        return 'Harassment';
      case ModerationReason.other:
        return 'Violation';
    }
  }
}

/// Chat moderation configuration
class ChatModerationConfig {
  /// Maximum message length
  static const int maxMessageLength = 500;

  /// Minimum characters for a message
  static const int minMessageLength = 1;

  /// Rate limit: messages per user per second
  static const double rateLimitMessagesPerSecond = 0.5; // 1 message per 2 seconds

  /// Message retention period (days)
  static const int messageRetentionDays = 7;

  /// Profanity filter patterns (Japanese + English)
  static const List<String> profanityPatterns = [
    // English profanity patterns (basic examples)
    r'\b(badword|inappropriate)\b',
    // Japanese profanity patterns would go here
  ];

  /// Spam detection patterns
  static const List<String> spamPatterns = [
    r'(.)\1{4,}', // Repeated characters (5+ times)
    r'[A-Z]{5,}', // All caps (5+ letters)
  ];

  /// Advertisement patterns
  static const List<String> adPatterns = [
    r'\b(buy|sell|follow|dm|join|subscribe|link|url|click)\b',
    r'(\.com|\.io|http|www)',
  ];
}

/// Spectator chat event for analytics
class SpectatorChatEvent {
  final String matchId;
  final String userId;
  final String eventType; // 'message_sent', 'message_moderated', 'user_muted', etc.
  final Map<String, dynamic> parameters;

  SpectatorChatEvent({
    required this.matchId,
    required this.userId,
    required this.eventType,
    required this.parameters,
  });

  Map<String, dynamic> toJson() => {
    'matchId': matchId,
    'userId': userId,
    'eventType': eventType,
    'parameters': parameters,
  };
}
