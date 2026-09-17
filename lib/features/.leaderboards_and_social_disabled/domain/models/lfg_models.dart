import 'package:freezed_annotation/freezed_annotation.dart';

part 'lfg_models.freezed.dart';
part 'lfg_models.g.dart';

// ============================================================================
// COMMUNITY - LFG (LOOKING FOR GROUP) (1 Model)
// ============================================================================

enum SkillLevel { beginner, intermediate, advanced }

enum LFGFillStatus { open, closed }

@freezed
class LFGPost with _$LFGPost {
  const factory LFGPost({
    required String postId,
    required String creatorId,
    required String title,
    required String description,
    required SkillLevel skillLevel,
    required String matchType,
    required List<String> preferredPlatforms,
    required DateTime createdAt,
    required LFGFillStatus fillStatus,
    required List<String> applicantIds,
    required int maxParticipants,
  }) = _LFGPost;

  factory LFGPost.fromJson(Map<String, dynamic> json) =>
      _$LFGPostFromJson(json);
}
