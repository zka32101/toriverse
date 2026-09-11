import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_messaging_models.freezed.dart';
part 'social_messaging_models.g.dart';

// ============================================================================
// SOCIAL - MESSAGING (1 Model)
// ============================================================================

@freezed
class UserMessage with _$UserMessage {
  const factory UserMessage({
    required String messageId,
    required String senderId,
    required String recipientId,
    required String content,
    required DateTime sentAt,
    required DateTime? readAt,
    required bool isStarred,
    required String? replyToMessageId,
  }) = _UserMessage;

  factory UserMessage.fromJson(Map<String, dynamic> json) =>
      _$UserMessageFromJson(json);
}
