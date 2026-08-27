import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:toriverse/features/spectating/domain/models/spectator_message.dart';

/// Repository for spectator chat operations
///
/// Handles all Firestore operations for spectator chat messages,
/// including sending, retrieving, moderation, and analytics.
class SpectatorChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAnalytics _analytics;

  SpectatorChatRepository({
    FirebaseFirestore? firestore,
    FirebaseAnalytics? analytics,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _analytics = analytics ?? FirebaseAnalytics.instance;

  /// Watch real-time chat messages for a match
  ///
  /// Returns a stream of messages for the match, ordered by creation time.
  /// Only includes non-deleted messages.
  Stream<List<SpectatorMessage>> watchMatchMessages(String matchId) {
    return _firestore
        .collection('matches')
        .doc(matchId)
        .collection('spectatorChat')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SpectatorMessage.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .where((msg) => !msg.isModerated) // Hide moderated messages in feed
          .toList();
    });
  }

  /// Watch pinned messages (commentators and moderators only)
  Stream<List<SpectatorMessage>> watchPinnedMessages(String matchId) {
    return _firestore
        .collection('matches')
        .doc(matchId)
        .collection('spectatorChat')
        .where('isPinned', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(5) // Show max 5 pinned messages
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SpectatorMessage.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    });
  }

  /// Send a new chat message
  ///
  /// Creates a message document and applies automatic moderation.
  /// Returns the created message ID.
  Future<String> sendMessage({
    required String matchId,
    required String userId,
    required String displayName,
    required String text,
    required SpectatorChatRole role,
  }) async {
    // Validate message
    if (text.isEmpty) {
      throw ArgumentError('Message cannot be empty');
    }
    if (text.length > ChatModerationConfig.maxMessageLength) {
      throw ArgumentError(
        'Message exceeds maximum length of ${ChatModerationConfig.maxMessageLength}',
      );
    }

    // Check moderation
    final moderationResult = _checkMessageModeration(text);

    // Create message document
    final messageRef = _firestore
        .collection('matches')
        .doc(matchId)
        .collection('spectatorChat')
        .doc();

    final message = SpectatorMessage(
      id: messageRef.id,
      matchId: matchId,
      userId: userId,
      displayName: displayName,
      text: text,
      createdAt: DateTime.now(),
      isModerated: moderationResult['isFlagged'] as bool,
      moderationReason: moderationResult['reason'] as String?,
      role: role,
    );

    await messageRef.set(message.toJson());

    // Log analytics event
    await _logChatEvent(
      matchId: matchId,
      userId: userId,
      eventType: 'message_sent',
      parameters: {
        'messageLength': text.length,
        'userRole': role.label,
        'isModerated': message.isModerated,
      },
    );

    return messageRef.id;
  }

  /// Apply automatic moderation to message
  ///
  /// Returns a map with 'isFlagged' (bool) and 'reason' (String?).
  Map<String, dynamic> _checkMessageModeration(String text) {
    final lowerText = text.toLowerCase();

    // Check profanity
    for (final pattern in ChatModerationConfig.profanityPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(text)) {
        return {
          'isFlagged': true,
          'reason': ModerationReason.profanity.displayName,
        };
      }
    }

    // Check spam patterns
    for (final pattern in ChatModerationConfig.spamPatterns) {
      if (RegExp(pattern).hasMatch(text)) {
        return {
          'isFlagged': true,
          'reason': ModerationReason.spam.displayName,
        };
      }
    }

    // Check advertisements
    for (final pattern in ChatModerationConfig.adPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(text)) {
        return {
          'isFlagged': true,
          'reason': ModerationReason.advertisement.displayName,
        };
      }
    }

    return {
      'isFlagged': false,
      'reason': null,
    };
  }

  /// Pin a message (commentators and moderators only)
  ///
  /// Allows commentators and moderators to pin important messages to the top.
  Future<void> pinMessage({
    required String matchId,
    required String messageId,
    required SpectatorChatRole userRole,
  }) async {
    if (!userRole.canPin) {
      throw ArgumentError('User role cannot pin messages');
    }

    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('spectatorChat')
        .doc(messageId)
        .update({'isPinned': true});

    await _logChatEvent(
      matchId: matchId,
      userId: '', // Moderator action
      eventType: 'message_pinned',
      parameters: {'messageId': messageId},
    );
  }

  /// Unpin a message
  Future<void> unpinMessage({
    required String matchId,
    required String messageId,
    required SpectatorChatRole userRole,
  }) async {
    if (!userRole.canPin) {
      throw ArgumentError('User role cannot unpin messages');
    }

    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('spectatorChat')
        .doc(messageId)
        .update({'isPinned': false});
  }

  /// Delete a message (moderators only)
  ///
  /// Removes a message entirely from the database.
  Future<void> deleteMessage({
    required String matchId,
    required String messageId,
    required SpectatorChatRole userRole,
  }) async {
    if (!userRole.canModerate) {
      throw ArgumentError('User role cannot delete messages');
    }

    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('spectatorChat')
        .doc(messageId)
        .delete();

    await _logChatEvent(
      matchId: matchId,
      userId: '', // Moderator action
      eventType: 'message_deleted',
      parameters: {'messageId': messageId},
    );
  }

  /// Report a message as inappropriate
  ///
  /// Users can report messages for human review and action.
  Future<void> reportMessage({
    required String matchId,
    required String messageId,
    required String reportedBy,
    required String reason,
  }) async {
    // Store report for human review
    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('spectatorChatReports')
        .add({
      'messageId': messageId,
      'reportedBy': reportedBy,
      'reason': reason,
      'reportedAt': FieldValue.serverTimestamp(),
      'status': 'pending', // pending, reviewed, action_taken
    });

    await _logChatEvent(
      matchId: matchId,
      userId: reportedBy,
      eventType: 'message_reported',
      parameters: {
        'messageId': messageId,
        'reason': reason,
      },
    );
  }

  /// Mute a user from chat (moderators only)
  ///
  /// Prevents a user from sending messages for the specified duration.
  Future<void> muteUser({
    required String matchId,
    required String userId,
    required Duration duration,
    required SpectatorChatRole userRole,
  }) async {
    if (!userRole.canModerate) {
      throw ArgumentError('User role cannot mute users');
    }

    final muteUntil = DateTime.now().add(duration);

    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('spectatorChatMutes')
        .doc(userId)
        .set({
      'userId': userId,
      'muteUntil': muteUntil,
      'mutedAt': FieldValue.serverTimestamp(),
    });

    await _logChatEvent(
      matchId: matchId,
      userId: '', // Moderator action
      eventType: 'user_muted',
      parameters: {
        'targetUserId': userId,
        'durationSeconds': duration.inSeconds,
      },
    );
  }

  /// Check if a user is currently muted
  Future<bool> isUserMuted(String matchId, String userId) async {
    final doc = await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('spectatorChatMutes')
        .doc(userId)
        .get();

    if (!doc.exists) return false;

    final muteUntil = (doc.data()?['muteUntil'] as Timestamp).toDate();
    return muteUntil.isAfter(DateTime.now());
  }

  /// Unmute a user
  Future<void> unmuteUser({
    required String matchId,
    required String userId,
    required SpectatorChatRole userRole,
  }) async {
    if (!userRole.canModerate) {
      throw ArgumentError('User role cannot unmute users');
    }

    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('spectatorChatMutes')
        .doc(userId)
        .delete();
  }

  /// Get chat statistics for a match
  ///
  /// Returns metrics like message count, unique users, etc.
  Future<Map<String, dynamic>> getChatStats(String matchId) async {
    final snapshot = await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('spectatorChat')
        .get();

    final messages = snapshot.docs;
    final userIds = <String>{};
    var flaggedCount = 0;

    for (final doc in messages) {
      userIds.add(doc['userId'] as String);
      if (doc['isModerated'] == true) flaggedCount++;
    }

    return {
      'totalMessages': messages.length,
      'uniqueUsers': userIds.length,
      'flaggedMessages': flaggedCount,
      'lastMessageAt': messages.isNotEmpty
          ? (messages.last['createdAt'] as Timestamp).toDate()
          : null,
    };
  }

  /// Clean up old messages (7 day retention)
  ///
  /// Should be called via Cloud Functions scheduled task.
  Future<void> cleanupOldMessages(String matchId) async {
    final sevenDaysAgo =
        DateTime.now().subtract(Duration(days: ChatModerationConfig.messageRetentionDays));

    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('spectatorChat')
        .where('createdAt', isLessThan: sevenDaysAgo)
        .get()
        .then((snapshot) async {
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    });
  }

  /// Log chat analytics event
  Future<void> _logChatEvent({
    required String matchId,
    required String userId,
    required String eventType,
    required Map<String, dynamic> parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: eventType,
        parameters: {
          'matchId': matchId,
          'userId': userId,
          ...parameters,
        },
      );
    } catch (e) {
      // Analytics failures should not block chat operations
      print('Analytics logging failed: $e');
    }
  }
}
