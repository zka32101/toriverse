import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/organizing/data/repositories/organizer_repository.dart';
import 'package:toriverse/features/organizing/domain/models/organizer.dart';

// ============================================================================
// REPOSITORY PROVIDER
// ============================================================================

/// Dependency injection for organizer repository
final organizerRepositoryProvider = Provider<OrganizerRepository>((ref) {
  return OrganizerRepository();
});

// ============================================================================
// PARAMETER CLASSES
// ============================================================================

class _GetOrganizerProfileParams {
  final String uid;

  const _GetOrganizerProfileParams(this.uid);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _GetOrganizerProfileParams && runtimeType == other.runtimeType && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}

class _CreateTournamentParams {
  final String organizerId;
  final String name;
  final String description;
  final String format;
  final int maxParticipants;
  final PrizePoolConfig prizePool;

  const _CreateTournamentParams({
    required this.organizerId,
    required this.name,
    required this.description,
    required this.format,
    required this.maxParticipants,
    required this.prizePool,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CreateTournamentParams &&
          runtimeType == other.runtimeType &&
          organizerId == other.organizerId &&
          name == other.name &&
          format == other.format;

  @override
  int get hashCode => Object.hash(organizerId, name, format);
}

class _GetRegistrationsParams {
  final String tournamentId;

  const _GetRegistrationsParams(this.tournamentId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _GetRegistrationsParams &&
          runtimeType == other.runtimeType &&
          tournamentId == other.tournamentId;

  @override
  int get hashCode => tournamentId.hashCode;
}

class _GetPayoutsParams {
  final String organizerId;

  const _GetPayoutsParams(this.organizerId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _GetPayoutsParams &&
          runtimeType == other.runtimeType &&
          organizerId == other.organizerId;

  @override
  int get hashCode => organizerId.hashCode;
}

class _GetTournamentsParams {
  final String organizerId;

  const _GetTournamentsParams(this.organizerId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _GetTournamentsParams &&
          runtimeType == other.runtimeType &&
          organizerId == other.organizerId;

  @override
  int get hashCode => organizerId.hashCode;
}

class _GetStatsParams {
  final String organizerId;

  const _GetStatsParams(this.organizerId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _GetStatsParams &&
          runtimeType == other.runtimeType &&
          organizerId == other.organizerId;

  @override
  int get hashCode => organizerId.hashCode;
}

// ============================================================================
// PROFILE PROVIDERS
// ============================================================================

/// Watch organizer profile (real-time)
final organizerProfileProvider =
    FutureProvider.autoDispose.family<OrganizerProfile?, _GetOrganizerProfileParams>(
  (ref, params) async {
    final repo = ref.watch(organizerRepositoryProvider);
    return repo.getOrganizerProfile(params.uid);
  },
);

/// Watch organizer statistics (real-time)
final organizerStatsProvider =
    FutureProvider.autoDispose.family<OrganizerStats?, _GetStatsParams>(
  (ref, params) async {
    final repo = ref.watch(organizerRepositoryProvider);
    return repo.getOrganizerStats(params.organizerId);
  },
);

// ============================================================================
// TOURNAMENT MANAGEMENT PROVIDERS
// ============================================================================

/// Create tournament draft
final createTournamentProvider =
    FutureProvider.autoDispose.family<TournamentDraft, _CreateTournamentParams>(
  (ref, params) async {
    final repo = ref.watch(organizerRepositoryProvider);
    return repo.createTournamentDraft(
      organizerId: params.organizerId,
      name: params.name,
      description: params.description,
      format: params.format,
      prizePool: params.prizePool,
      maxParticipants: params.maxParticipants,
    );
  },
);

/// Get organizer's tournaments (one-time fetch)
final organizerTournamentsProvider =
    FutureProvider.autoDispose.family<List<TournamentDraft>, _GetTournamentsParams>(
  (ref, params) async {
    final repo = ref.watch(organizerRepositoryProvider);
    return repo.getOrganizerTournaments(params.organizerId);
  },
);

/// Watch organizer's tournaments (real-time)
final organizerTournamentsStreamProvider =
    StreamProvider.autoDispose.family<List<TournamentDraft>, _GetTournamentsParams>(
  (ref, params) {
    final repo = ref.watch(organizerRepositoryProvider);
    return repo.watchOrganizerTournaments(params.organizerId);
  },
);

/// Watch draft tournaments only
final draftTournamentsProvider =
    StreamProvider.autoDispose.family<List<TournamentDraft>, _GetTournamentsParams>(
  (ref, params) {
    final repo = ref.watch(organizerRepositoryProvider);
    return repo.watchDraftTournaments(params.organizerId);
  },
);

// ============================================================================
// PARTICIPANT MANAGEMENT PROVIDERS
// ============================================================================

/// Get tournament registrations (one-time fetch)
final registrationsProvider = FutureProvider.autoDispose
    .family<List<TournamentRegistration>, _GetRegistrationsParams>(
  (ref, params) async {
    final repo = ref.watch(organizerRepositoryProvider);
    return repo.getTournamentRegistrations(params.tournamentId);
  },
);

/// Watch tournament participants (real-time)
final participantsStreamProvider =
    StreamProvider.autoDispose.family<List<TournamentRegistration>, _GetRegistrationsParams>(
  (ref, params) {
    final repo = ref.watch(organizerRepositoryProvider);
    return repo.watchTournamentParticipants(params.tournamentId);
  },
);

// ============================================================================
// PAYOUT MANAGEMENT PROVIDERS
// ============================================================================

/// Get organizer's payout requests
final payoutRequestsProvider =
    FutureProvider.autoDispose.family<List<PayoutRequest>, _GetPayoutsParams>(
  (ref, params) async {
    final repo = ref.watch(organizerRepositoryProvider);
    return repo.getPayoutRequests(params.organizerId);
  },
);

// ============================================================================
// TOURNAMENT TEMPLATE PROVIDERS
// ============================================================================

/// Get organizer's tournament templates
final organizerTemplatesProvider =
    FutureProvider.autoDispose.family<List<TournamentTemplate>, _GetTournamentsParams>(
  (ref, params) async {
    final repo = ref.watch(organizerRepositoryProvider);
    return repo.getTournamentTemplates(params.organizerId);
  },
);

// ============================================================================
// MUTATION PROVIDERS (Actions)
// ============================================================================

/// Publish tournament mutation
final publishTournamentProvider = FutureProvider.autoDispose
    .family<void, (String tournamentId, DateTime startDate, DateTime registrationDeadline)>(
  (ref, params) async {
    final repo = ref.watch(organizerRepositoryProvider);
    await repo.publishTournament(
      tournamentId: params.$1,
      startDate: params.$2,
      registrationDeadline: params.$3,
    );
    // Invalidate related providers to refresh UI
    ref.invalidate(organizerTournamentsStreamProvider);
  },
);

/// Start tournament mutation
final startTournamentProvider = FutureProvider.autoDispose.family<void, String>(
  (ref, tournamentId) async {
    final repo = ref.watch(organizerRepositoryProvider);
    await repo.startTournament(tournamentId);
    ref.invalidate(organizerTournamentsStreamProvider);
  },
);

/// Finish tournament mutation
final finishTournamentProvider = FutureProvider.autoDispose.family<void, String>(
  (ref, tournamentId) async {
    final repo = ref.watch(organizerRepositoryProvider);
    await repo.finishTournament(tournamentId);
    ref.invalidate(organizerTournamentsStreamProvider);
  },
);

/// Approve registration mutation
final approveRegistrationProvider = FutureProvider.autoDispose
    .family<void, (String tournamentId, String registrationId)>(
  (ref, params) async {
    final repo = ref.watch(organizerRepositoryProvider);
    await repo.approveRegistration(
      tournamentId: params.$1,
      registrationId: params.$2,
    );
    ref.invalidate(registrationsProvider);
    ref.invalidate(participantsStreamProvider);
  },
);

/// Reject registration mutation
final rejectRegistrationProvider = FutureProvider.autoDispose
    .family<void, (String tournamentId, String registrationId, String reason)>(
  (ref, params) async {
    final repo = ref.watch(organizerRepositoryProvider);
    await repo.rejectRegistration(
      tournamentId: params.$1,
      registrationId: params.$2,
      reason: params.$3,
    );
    ref.invalidate(registrationsProvider);
    ref.invalidate(participantsStreamProvider);
  },
);

/// Create payout request mutation
final createPayoutProvider = FutureProvider.autoDispose
    .family<PayoutRequest, (String tournamentId, String organizerId, Map<String, int> payouts)>(
  (ref, params) async {
    final repo = ref.watch(organizerRepositoryProvider);
    final request = await repo.createPayoutRequest(
      tournamentId: params.$1,
      organizerId: params.$2,
      payouts: params.$3,
    );
    ref.invalidate(payoutRequestsProvider);
    return request;
  },
);

/// Update payout status mutation
final updatePayoutStatusProvider = FutureProvider.autoDispose
    .family<void, (String payoutId, String status, String? notes)>(
  (ref, params) async {
    final repo = ref.watch(organizerRepositoryProvider);
    await repo.updatePayoutStatus(
      payoutId: params.$1,
      status: params.$2,
      notes: params.$3,
    );
    ref.invalidate(payoutRequestsProvider);
  },
);

/// Add organizer review mutation
final addOrganizerReviewProvider = FutureProvider.autoDispose.family<
    TournamentReview,
    (
      String organizerId,
      String tournamentId,
      String reviewerId,
      String reviewerName,
      double rating,
      String comment,
      List<String> categories,
    )>(
  (ref, params) async {
    final repo = ref.watch(organizerRepositoryProvider);
    final review = await repo.addOrganizerReview(
      organizerId: params.$1,
      tournamentId: params.$2,
      reviewerId: params.$3,
      reviewerName: params.$4,
      rating: params.$5,
      comment: params.$6,
      categories: params.$7,
    );
    ref.invalidate(organizerStatsProvider);
    return review;
  },
);

/// Seed players mutation
final seedPlayersProvider = FutureProvider.autoDispose
    .family<void, (String tournamentId, List<String> playerIds)>(
  (ref, params) async {
    final repo = ref.watch(organizerRepositoryProvider);
    await repo.seedPlayers(
      tournamentId: params.$1,
      playerIds: params.$2,
    );
    ref.invalidate(participantsStreamProvider);
  },
);
