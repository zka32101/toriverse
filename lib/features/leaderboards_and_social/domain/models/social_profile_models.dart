import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_profile_models.freezed.dart';
part 'social_profile_models.g.dart';

// ============================================================================
// SOCIAL - USER PROFILE (1 Model)
// ============================================================================

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String userId,
    required String displayName,
    required String bio,
    required String avatarUrl,
    required bool creatorBadge,
    required bool isVerified,
    required bool isMuted,
    required bool isBlocked,
    required String preferredColorScheme,
    required int totalMatches,
    required int totalWins,
    required int totalClipsCreated,
    required DateTime joinedAt,
    required DateTime lastUpdatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
