import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_moderation_models.freezed.dart';
part 'social_moderation_models.g.dart';

// ============================================================================
// COMMUNITY - BLOCKING & MUTING (2 Models)
// ============================================================================

@freezed
class UserBlock with _$UserBlock {
  const factory UserBlock({
    required String blockId,
    required String userId,
    required String blockedUserId,
    required String reason,
    required DateTime blockedAt,
  }) = _UserBlock;

  factory UserBlock.fromJson(Map<String, dynamic> json) =>
      _$UserBlockFromJson(json);
}

@freezed
class UserMute with _$UserMute {
  const factory UserMute({
    required String muteId,
    required String userId,
    required String mutedUserId,
    required DateTime mutedAt,
  }) = _UserMute;

  factory UserMute.fromJson(Map<String, dynamic> json) =>
      _$UserMuteFromJson(json);
}
