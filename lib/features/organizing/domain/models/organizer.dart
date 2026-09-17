import 'package:freezed_annotation/freezed_annotation.dart';

/// User's organizer profile and capabilities
class OrganizerProfile {
  const OrganizerProfile({
    required String uid,
    required String displayName,
    required String email,
    required int tournamentCount,
    required int totalParticipants,
    required double avgRating,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool isVerified,
    bool canHostPremium,
    List<String> tournamentIds,
    String bio,
    String avatarUrl,
  });
}

/// Tournament being created/drafted
class TournamentDraft {
  const TournamentDraft({
    required String organizerId,
    required String name,
    required String description,
    required String format,
    DateTime? startDate,
    DateTime? registrationDeadline,
    int maxParticipants,
    int currentParticipants,
    required PrizePoolConfig prizePool,
    List<String> rules,
    String status, // draft, published, active, finished
    bool isFeatured,
    bool isPremium,
    String bannerUrl,
    String rulesetId,
    Map<String, dynamic> bracketSettings,
  });
}

/// Prize pool configuration for tournaments
class PrizePoolConfig {
  const PrizePoolConfig({
    required int totalAmount,
    required Map<int, int> distribution, // rank -> amount (JPY)
    String currency,
    String sponsorName,
    bool isPaidOut,
    DateTime? paidOutAt,
  });
}

/// Tournament configuration details
class TournamentConfig {
  const TournamentConfig({
    required String tournamentId,
    required String organizerId,
    required String format,
    bool allowLateRegistration,
    int submissionTimeSeconds,
    bool requirePlayerConfirmation,
    bool autoStartMatches,
    String timezone,
    List<String> allowedCountries,
    int minAge,
    int spectatorLimit,
    bool allowStreamers,
    bool recordMatches,
    bool autoGenerateClips,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// Organizer tournament statistics
class OrganizerStats {
  const OrganizerStats({
    required String organizerId,
    int totalTournaments,
    int completedTournaments,
    int totalParticipants,
    int totalViewers,
    int totalPrizePoolAwarded,
    double avgPlayerRating,
    double organizerRating,
    List<TournamentReview> reviews,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// Review/rating for tournament organizer
class TournamentReview {
  const TournamentReview({
    required String id,
    required String tournamentId,
    required String reviewerId,
    required String reviewerName,
    required double rating, // 1-5 stars
    required String comment,
    List<String> categories, // 'fair-play', 'communication', 'fairness', etc
    DateTime? createdAt,
  });
}

/// Tournament participation request from player
class TournamentRegistration {
  const TournamentRegistration({
    required String id,
    required String tournamentId,
    required String userId,
    required String displayName,
    DateTime? registeredAt,
    String status, // pending, approved, rejected, withdrawn
    DateTime? approvedAt,
    String notes, // organizer notes about player
  });
}

/// Payout request for tournament prizes
class PayoutRequest {
  const PayoutRequest({
    required String id,
    required String tournamentId,
    required String organizerId,
    required int totalAmount,
    required Map<String, int> payouts, // userId -> amount (JPY)
    String status, // pending, approved, processing, completed, failed
    String bankAccount,
    DateTime? requestedAt,
    DateTime? processedAt,
    String notes,
  });
}

/// Template for organizing recurring tournament series
class TournamentTemplate {
  const TournamentTemplate({
    required String id,
    required String organizerId,
    required String name,
    required String format,
    required PrizePoolConfig prizePoolTemplate,
    List<String> rules,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}
