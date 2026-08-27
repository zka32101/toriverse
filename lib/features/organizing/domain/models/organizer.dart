import 'package:freezed_annotation/freezed_annotation.dart';

part 'organizer.freezed.dart';
part 'organizer.g.dart';

/// User's organizer profile and capabilities
@freezed
class OrganizerProfile with _$OrganizerProfile {
  const factory OrganizerProfile({
    required String uid,
    required String displayName,
    required String email,
    required int tournamentCount,
    required int totalParticipants,
    required double avgRating,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isVerified,
    @Default(false) bool canHostPremium,
    @Default([]) List<String> tournamentIds,
    @Default('') String bio,
    @Default('') String avatarUrl,
  }) = _OrganizerProfile;

  factory OrganizerProfile.fromJson(Map<String, dynamic> json) =>
      _$OrganizerProfileFromJson(json);
}

/// Tournament being created/drafted
@freezed
class TournamentDraft with _$TournamentDraft {
  const factory TournamentDraft({
    required String organizerId,
    required String name,
    required String description,
    required String format,
    @Default(null) DateTime? startDate,
    @Default(null) DateTime? registrationDeadline,
    @Default(64) int maxParticipants,
    @Default(0) int currentParticipants,
    required PrizePoolConfig prizePool,
    @Default([]) List<String> rules,
    @Default('draft') String status, // draft, published, active, finished
    @Default(false) bool isFeatured,
    @Default(false) bool isPremium,
    @Default('') String bannerUrl,
    @Default('') String rulesetId,
    @Default({}) Map<String, dynamic> bracketSettings,
  }) = _TournamentDraft;

  factory TournamentDraft.fromJson(Map<String, dynamic> json) =>
      _$TournamentDraftFromJson(json);
}

/// Prize pool configuration for tournaments
@freezed
class PrizePoolConfig with _$PrizePoolConfig {
  const factory PrizePoolConfig({
    required int totalAmount,
    required Map<int, int> distribution, // rank -> amount (JPY)
    @Default('JPY') String currency,
    @Default('') String sponsorName,
    @Default(false) bool isPaidOut,
    @Default(null) DateTime? paidOutAt,
  }) = _PrizePoolConfig;

  factory PrizePoolConfig.fromJson(Map<String, dynamic> json) =>
      _$PrizePoolConfigFromJson(json);
}

/// Tournament configuration details
@freezed
class TournamentConfig with _$TournamentConfig {
  const factory TournamentConfig({
    required String tournamentId,
    required String organizerId,
    required String format,
    @Default(false) bool allowLateRegistration,
    @Default(30) int submissionTimeSeconds,
    @Default(false) bool requirePlayerConfirmation,
    @Default(false) bool autoStartMatches,
    @Default('') String timezone,
    @Default([]) List<String> allowedCountries,
    @Default(18) int minAge,
    @Default(0) int spectatorLimit,
    @Default(false) bool allowStreamers,
    @Default(false) bool recordMatches,
    @Default(false) bool autoGenerateClips,
    @Default(null) DateTime? createdAt,
    @Default(null) DateTime? updatedAt,
  }) = _TournamentConfig;

  factory TournamentConfig.fromJson(Map<String, dynamic> json) =>
      _$TournamentConfigFromJson(json);
}

/// Organizer tournament statistics
@freezed
class OrganizerStats with _$OrganizerStats {
  const factory OrganizerStats({
    required String organizerId,
    @Default(0) int totalTournaments,
    @Default(0) int completedTournaments,
    @Default(0) int totalParticipants,
    @Default(0) int totalViewers,
    @Default(0) int totalPrizePoolAwarded,
    @Default(0.0) double avgPlayerRating,
    @Default(0.0) double organizerRating,
    @Default([]) List<TournamentReview> reviews,
    @Default(null) DateTime? createdAt,
    @Default(null) DateTime? updatedAt,
  }) = _OrganizerStats;

  factory OrganizerStats.fromJson(Map<String, dynamic> json) =>
      _$OrganizerStatsFromJson(json);
}

/// Review/rating for tournament organizer
@freezed
class TournamentReview with _$TournamentReview {
  const factory TournamentReview({
    required String id,
    required String tournamentId,
    required String reviewerId,
    required String reviewerName,
    required double rating, // 1-5 stars
    required String comment,
    @Default([]) List<String> categories, // 'fair-play', 'communication', 'fairness', etc
    @Default(null) DateTime? createdAt,
  }) = _TournamentReview;

  factory TournamentReview.fromJson(Map<String, dynamic> json) =>
      _$TournamentReviewFromJson(json);
}

/// Tournament participation request from player
@freezed
class TournamentRegistration with _$TournamentRegistration {
  const factory TournamentRegistration({
    required String id,
    required String tournamentId,
    required String userId,
    required String displayName,
    @Default(null) DateTime? registeredAt,
    @Default('pending') String status, // pending, approved, rejected, withdrawn
    @Default(null) DateTime? approvedAt,
    @Default('') String notes, // organizer notes about player
  }) = _TournamentRegistration;

  factory TournamentRegistration.fromJson(Map<String, dynamic> json) =>
      _$TournamentRegistrationFromJson(json);
}

/// Payout request for tournament prizes
@freezed
class PayoutRequest with _$PayoutRequest {
  const factory PayoutRequest({
    required String id,
    required String tournamentId,
    required String organizerId,
    required int totalAmount,
    required Map<String, int> payouts, // userId -> amount (JPY)
    @Default('pending') String status, // pending, approved, processing, completed, failed
    @Default('') String bankAccount,
    @Default(null) DateTime? requestedAt,
    @Default(null) DateTime? processedAt,
    @Default('') String notes,
  }) = _PayoutRequest;

  factory PayoutRequest.fromJson(Map<String, dynamic> json) =>
      _$PayoutRequestFromJson(json);
}

/// Template for organizing recurring tournament series
@freezed
class TournamentTemplate with _$TournamentTemplate {
  const factory TournamentTemplate({
    required String id,
    required String organizerId,
    required String name,
    required String format,
    required PrizePoolConfig prizePoolTemplate,
    @Default([]) List<String> rules,
    @Default(null) DateTime? createdAt,
    @Default(null) DateTime? updatedAt,
  }) = _TournamentTemplate;

  factory TournamentTemplate.fromJson(Map<String, dynamic> json) =>
      _$TournamentTemplateFromJson(json);
}
