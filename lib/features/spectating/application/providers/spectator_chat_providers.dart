import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/spectating/data/repositories/spectator_chat_repository.dart';
import 'package:toriverse/features/spectating/domain/models/spectator_message.dart';

/// Chat repository provider for dependency injection
final spectatorChatRepositoryProvider = Provider((ref) {
  return SpectatorChatRepository(
    analytics: FirebaseAnalytics.instance,
  );
});

/// Watch real-time chat messages for a match
///
/// Returns a stream of all non-moderated messages for the match,
/// ordered chronologically.
final matchChatMessagesProvider =
    StreamProvider.family<List<SpectatorMessage>, String>((ref, matchId) {
  final repo = ref.watch(spectatorChatRepositoryProvider);
  return repo.watchMatchMessages(matchId);
});

/// Watch pinned messages for a match (commentators/moderators view)
///
/// Only shows messages that have been pinned by moderators/commentators.
final matchPinnedMessagesProvider =
    StreamProvider.family<List<SpectatorMessage>, String>((ref, matchId) {
  final repo = ref.watch(spectatorChatRepositoryProvider);
  return repo.watchPinnedMessages(matchId);
});

/// Send a new chat message
///
/// Validates message content and applies automatic moderation.
/// Returns the message ID on success.
final sendChatMessageProvider = FutureProvider.autoDispose
    .family<String, _SendMessageParams>((ref, params) async {
  final repo = ref.watch(spectatorChatRepositoryProvider);

  return repo.sendMessage(
    matchId: params.matchId,
    userId: params.userId,
    displayName: params.displayName,
    text: params.text,
    role: params.role,
  );
});

/// Pin a message (commentators/moderators only)
final pinChatMessageProvider = FutureProvider.autoDispose
    .family<void, _PinMessageParams>((ref, params) async {
  final repo = ref.watch(spectatorChatRepositoryProvider);

  return repo.pinMessage(
    matchId: params.matchId,
    messageId: params.messageId,
    userRole: params.userRole,
  );
});

/// Unpin a message
final unpinChatMessageProvider = FutureProvider.autoDispose
    .family<void, _PinMessageParams>((ref, params) async {
  final repo = ref.watch(spectatorChatRepositoryProvider);

  return repo.unpinMessage(
    matchId: params.matchId,
    messageId: params.messageId,
    userRole: params.userRole,
  );
});

/// Delete a message (moderators only)
final deleteChatMessageProvider = FutureProvider.autoDispose
    .family<void, _DeleteMessageParams>((ref, params) async {
  final repo = ref.watch(spectatorChatRepositoryProvider);

  return repo.deleteMessage(
    matchId: params.matchId,
    messageId: params.messageId,
    userRole: params.userRole,
  );
});

/// Report a message as inappropriate
final reportChatMessageProvider = FutureProvider.autoDispose
    .family<void, _ReportMessageParams>((ref, params) async {
  final repo = ref.watch(spectatorChatRepositoryProvider);

  return repo.reportMessage(
    matchId: params.matchId,
    messageId: params.messageId,
    reportedBy: params.reportedBy,
    reason: params.reason,
  );
});

/// Mute a user from chat (moderators only)
final muteUserProvider = FutureProvider.autoDispose
    .family<void, _MuteUserParams>((ref, params) async {
  final repo = ref.watch(spectatorChatRepositoryProvider);

  return repo.muteUser(
    matchId: params.matchId,
    userId: params.userId,
    duration: params.duration,
    userRole: params.userRole,
  );
});

/// Unmute a user (moderators only)
final unmuteUserProvider = FutureProvider.autoDispose
    .family<void, _UnmuteUserParams>((ref, params) async {
  final repo = ref.watch(spectatorChatRepositoryProvider);

  return repo.unmuteUser(
    matchId: params.matchId,
    userId: params.userId,
    userRole: params.userRole,
  );
});

/// Check if a user is currently muted
final isUserMutedProvider =
    FutureProvider.autoDispose.family<bool, _CheckMuteParams>((ref, params) {
  final repo = ref.watch(spectatorChatRepositoryProvider);
  return repo.isUserMuted(params.matchId, params.userId);
});

/// Get chat statistics for a match
final matchChatStatsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, matchId) {
  final repo = ref.watch(spectatorChatRepositoryProvider);
  return repo.getChatStats(matchId);
});

/// Record spectator chat analytics event
final recordChatEventProvider = FutureProvider.autoDispose
    .family<void, SpectatorChatEvent>((ref, event) async {
  final repo = ref.watch(spectatorChatRepositoryProvider);
  // The repository already logs events internally
  // This provider is for explicit event tracking if needed
});

// ============================================================================
// Parameter classes for provider inputs
// ============================================================================

/// Parameters for sending a chat message
class _SendMessageParams {
  final String matchId;
  final String userId;
  final String displayName;
  final String text;
  final SpectatorChatRole role;

  _SendMessageParams({
    required this.matchId,
    required this.userId,
    required this.displayName,
    required this.text,
    required this.role,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SendMessageParams &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId &&
          userId == other.userId &&
          displayName == other.displayName &&
          text == other.text &&
          role == other.role;

  @override
  int get hashCode =>
      matchId.hashCode ^
      userId.hashCode ^
      displayName.hashCode ^
      text.hashCode ^
      role.hashCode;
}

/// Parameters for pinning/unpinning a message
class _PinMessageParams {
  final String matchId;
  final String messageId;
  final SpectatorChatRole userRole;

  _PinMessageParams({
    required this.matchId,
    required this.messageId,
    required this.userRole,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _PinMessageParams &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId &&
          messageId == other.messageId &&
          userRole == other.userRole;

  @override
  int get hashCode =>
      matchId.hashCode ^ messageId.hashCode ^ userRole.hashCode;
}

/// Parameters for deleting a message
class _DeleteMessageParams {
  final String matchId;
  final String messageId;
  final SpectatorChatRole userRole;

  _DeleteMessageParams({
    required this.matchId,
    required this.messageId,
    required this.userRole,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _DeleteMessageParams &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId &&
          messageId == other.messageId &&
          userRole == other.userRole;

  @override
  int get hashCode =>
      matchId.hashCode ^ messageId.hashCode ^ userRole.hashCode;
}

/// Parameters for reporting a message
class _ReportMessageParams {
  final String matchId;
  final String messageId;
  final String reportedBy;
  final String reason;

  _ReportMessageParams({
    required this.matchId,
    required this.messageId,
    required this.reportedBy,
    required this.reason,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ReportMessageParams &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId &&
          messageId == other.messageId &&
          reportedBy == other.reportedBy &&
          reason == other.reason;

  @override
  int get hashCode =>
      matchId.hashCode ^
      messageId.hashCode ^
      reportedBy.hashCode ^
      reason.hashCode;
}

/// Parameters for muting a user
class _MuteUserParams {
  final String matchId;
  final String userId;
  final Duration duration;
  final SpectatorChatRole userRole;

  _MuteUserParams({
    required this.matchId,
    required this.userId,
    required this.duration,
    required this.userRole,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _MuteUserParams &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId &&
          userId == other.userId &&
          duration == other.duration &&
          userRole == other.userRole;

  @override
  int get hashCode =>
      matchId.hashCode ^
      userId.hashCode ^
      duration.hashCode ^
      userRole.hashCode;
}

/// Parameters for unmuting a user
class _UnmuteUserParams {
  final String matchId;
  final String userId;
  final SpectatorChatRole userRole;

  _UnmuteUserParams({
    required this.matchId,
    required this.userId,
    required this.userRole,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _UnmuteUserParams &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId &&
          userId == other.userId &&
          userRole == other.userRole;

  @override
  int get hashCode =>
      matchId.hashCode ^ userId.hashCode ^ userRole.hashCode;
}

/// Parameters for checking if user is muted
class _CheckMuteParams {
  final String matchId;
  final String userId;

  _CheckMuteParams({
    required this.matchId,
    required this.userId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CheckMuteParams &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId &&
          userId == other.userId;

  @override
  int get hashCode => matchId.hashCode ^ userId.hashCode;
}
