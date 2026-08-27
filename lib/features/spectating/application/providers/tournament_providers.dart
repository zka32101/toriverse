import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/spectating/data/repositories/tournament_repository.dart';
import 'package:toriverse/features/spectating/domain/models/tournament.dart';

// Repository provider
final tournamentRepositoryProvider = Provider((ref) {
  return TournamentRepository(FirebaseFirestore.instance);
});

// Tournament creation parameters
class _CreateTournamentParams {
  final String name;
  final String description;
  final TournamentFormat format;
  final DateTime startDate;
  final DateTime registrationDeadline;
  final int maxParticipants;
  final PrizePool prizePool;
  final String organizerId;
  final String organizerName;
  final List<String> rules;
  final bool isFeatured;
  final String? bannerUrl;
  final String? logoUrl;

  _CreateTournamentParams({
    required this.name,
    required this.description,
    required this.format,
    required this.startDate,
    required this.registrationDeadline,
    required this.maxParticipants,
    required this.prizePool,
    required this.organizerId,
    required this.organizerName,
    required this.rules,
    this.isFeatured = false,
    this.bannerUrl,
    this.logoUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CreateTournamentParams &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          format == other.format;

  @override
  int get hashCode => name.hashCode ^ format.hashCode;
}

/// Create new tournament
final createTournamentProvider = FutureProvider.autoDispose.family<String, _CreateTournamentParams>(
  (ref, params) async {
    final repository = ref.watch(tournamentRepositoryProvider);
    return repository.createTournament(
      name: params.name,
      description: params.description,
      format: params.format,
      startDate: params.startDate,
      registrationDeadline: params.registrationDeadline,
      maxParticipants: params.maxParticipants,
      prizePool: params.prizePool,
      organizerId: params.organizerId,
      organizerName: params.organizerName,
      rules: params.rules,
      isFeatured: params.isFeatured,
      bannerUrl: params.bannerUrl,
      logoUrl: params.logoUrl,
    );
  },
);

// Get tournament parameters
class _GetTournamentParams {
  final String tournamentId;

  _GetTournamentParams(this.tournamentId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _GetTournamentParams &&
          runtimeType == other.runtimeType &&
          tournamentId == other.tournamentId;

  @override
  int get hashCode => tournamentId.hashCode;
}

/// Get tournament details
final tournamentProvider = FutureProvider.family<Tournament?, _GetTournamentParams>(
  (ref, params) async {
    final repository = ref.watch(tournamentRepositoryProvider);
    return repository.getTournament(params.tournamentId);
  },
);

/// Watch tournament for real-time updates
final tournamentStreamProvider = StreamProvider.family<Tournament?, _GetTournamentParams>(
  (ref, params) {
    final repository = ref.watch(tournamentRepositoryProvider);
    return repository.watchTournament(params.tournamentId);
  },
);

// Register player parameters
class _RegisterPlayerParams {
  final String tournamentId;
  final String userId;
  final String displayName;
  final int seedRank;

  _RegisterPlayerParams({
    required this.tournamentId,
    required this.userId,
    required this.displayName,
    required this.seedRank,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _RegisterPlayerParams &&
          runtimeType == other.runtimeType &&
          tournamentId == other.tournamentId &&
          userId == other.userId;

  @override
  int get hashCode => tournamentId.hashCode ^ userId.hashCode;
}

/// Register player in tournament
final registerPlayerProvider = FutureProvider.autoDispose.family<void, _RegisterPlayerParams>(
  (ref, params) async {
    final repository = ref.watch(tournamentRepositoryProvider);
    return repository.registerPlayer(
      params.tournamentId,
      params.userId,
      params.displayName,
      params.seedRank,
    );
  },
);

// Open registration parameters
class _OpenRegistrationParams {
  final String tournamentId;

  _OpenRegistrationParams(this.tournamentId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _OpenRegistrationParams &&
          runtimeType == other.runtimeType &&
          tournamentId == other.tournamentId;

  @override
  int get hashCode => tournamentId.hashCode;
}

/// Open tournament for registration
final openRegistrationProvider = FutureProvider.autoDispose.family<void, _OpenRegistrationParams>(
  (ref, params) async {
    final repository = ref.watch(tournamentRepositoryProvider);
    return repository.openRegistration(params.tournamentId);
  },
);

/// Start tournament
final startTournamentProvider = FutureProvider.autoDispose.family<void, _OpenRegistrationParams>(
  (ref, params) async {
    final repository = ref.watch(tournamentRepositoryProvider);
    return repository.startTournament(params.tournamentId);
  },
);

// Get matches parameters
class _GetMatchesParams {
  final String tournamentId;
  final int? round;

  _GetMatchesParams({required this.tournamentId, this.round});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _GetMatchesParams &&
          runtimeType == other.runtimeType &&
          tournamentId == other.tournamentId &&
          round == other.round;

  @override
  int get hashCode => tournamentId.hashCode ^ (round?.hashCode ?? 0);
}

/// Get tournament matches
final tournamentMatchesProvider = FutureProvider.family<List<TournamentMatch>, _GetMatchesParams>(
  (ref, params) async {
    final repository = ref.watch(tournamentRepositoryProvider);
    return repository.getMatches(params.tournamentId, round: params.round);
  },
);

/// Watch live matches
final liveMatchesProvider = StreamProvider.family<List<TournamentMatch>, _GetTournamentParams>(
  (ref, params) {
    final repository = ref.watch(tournamentRepositoryProvider);
    return repository.watchLiveMatches(params.tournamentId);
  },
);

// Create match parameters
class _CreateMatchParams {
  final String tournamentId;
  final int round;
  final int matchNumber;
  final List<String> playerIds;
  final DateTime scheduledTime;

  _CreateMatchParams({
    required this.tournamentId,
    required this.round,
    required this.matchNumber,
    required this.playerIds,
    required this.scheduledTime,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CreateMatchParams &&
          runtimeType == other.runtimeType &&
          tournamentId == other.tournamentId &&
          round == other.round;

  @override
  int get hashCode => tournamentId.hashCode ^ round.hashCode;
}

/// Create tournament match
final createMatchProvider = FutureProvider.autoDispose.family<String, _CreateMatchParams>(
  (ref, params) async {
    final repository = ref.watch(tournamentRepositoryProvider);
    return repository.createMatch(
      params.tournamentId,
      params.round,
      params.matchNumber,
      params.playerIds,
      params.scheduledTime,
    );
  },
);

// Complete match parameters
class _CompleteMatchParams {
  final String tournamentId;
  final String matchId;
  final String winnerId;
  final Map<String, int> finalScores;

  _CompleteMatchParams({
    required this.tournamentId,
    required this.matchId,
    required this.winnerId,
    required this.finalScores,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CompleteMatchParams &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId;

  @override
  int get hashCode => matchId.hashCode;
}

/// Complete match with winner
final completeMatchProvider = FutureProvider.autoDispose.family<void, _CompleteMatchParams>(
  (ref, params) async {
    final repository = ref.watch(tournamentRepositoryProvider);
    return repository.completeMatch(
      params.tournamentId,
      params.matchId,
      params.winnerId,
      params.finalScores,
    );
  },
);

/// Get tournament standings
final standingsProvider = FutureProvider.family<List<TournamentParticipant>, _GetTournamentParams>(
  (ref, params) async {
    final repository = ref.watch(tournamentRepositoryProvider);
    return repository.getStandings(params.tournamentId);
  },
);

/// Watch tournament standings for real-time updates
final standingsStreamProvider = StreamProvider.family<List<TournamentParticipant>, _GetTournamentParams>(
  (ref, params) {
    final repository = ref.watch(tournamentRepositoryProvider);
    return repository.watchStandings(params.tournamentId);
  },
);

// Feature match parameters
class _FeatureMatchParams {
  final String tournamentId;
  final String matchId;
  final String title;
  final String description;

  _FeatureMatchParams({
    required this.tournamentId,
    required this.matchId,
    required this.title,
    required this.description,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _FeatureMatchParams &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId;

  @override
  int get hashCode => matchId.hashCode;
}

/// Feature match for home screen
final featureMatchProvider = FutureProvider.autoDispose.family<void, _FeatureMatchParams>(
  (ref, params) async {
    final repository = ref.watch(tournamentRepositoryProvider);
    return repository.featureMatch(
      params.tournamentId,
      params.matchId,
      params.title,
      params.description,
    );
  },
);

// Prediction parameters
class _AddPredictionParams {
  final String matchId;
  final String viewerId;
  final String predictedWinnerId;
  final int wageredPoints;

  _AddPredictionParams({
    required this.matchId,
    required this.viewerId,
    required this.predictedWinnerId,
    required this.wageredPoints,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _AddPredictionParams &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId &&
          viewerId == other.viewerId;

  @override
  int get hashCode => matchId.hashCode ^ viewerId.hashCode;
}

/// Add viewer prediction
final addPredictionProvider = FutureProvider.autoDispose.family<void, _AddPredictionParams>(
  (ref, params) async {
    final repository = ref.watch(tournamentRepositoryProvider);
    return repository.addPrediction(
      params.matchId,
      params.viewerId,
      params.predictedWinnerId,
      params.wageredPoints,
    );
  },
);

// Award viewer parameters
class _AwardViewerParams {
  final String tournamentId;
  final String viewerId;
  final int watchMinutes;
  final int pointsEarned;

  _AwardViewerParams({
    required this.tournamentId,
    required this.viewerId,
    required this.watchMinutes,
    required this.pointsEarned,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _AwardViewerParams &&
          runtimeType == other.runtimeType &&
          viewerId == other.viewerId;

  @override
  int get hashCode => viewerId.hashCode;
}

/// Award viewer for watching
final awardViewerProvider = FutureProvider.autoDispose.family<void, _AwardViewerParams>(
  (ref, params) async {
    final repository = ref.watch(tournamentRepositoryProvider);
    return repository.awardViewer(
      params.tournamentId,
      params.viewerId,
      params.watchMinutes,
      params.pointsEarned,
    );
  },
);

/// Get featured matches for home screen
final featuredMatchesProvider = FutureProvider<List<FeaturedMatch>>((ref) async {
  final repository = ref.watch(tournamentRepositoryProvider);
  return repository.getFeaturedMatches();
});

/// Watch featured matches for real-time updates
final featuredMatchesStreamProvider = StreamProvider<List<FeaturedMatch>>((ref) {
  final repository = ref.watch(tournamentRepositoryProvider);
  return repository.watchFeaturedMatches();
});

/// Get tournament highlights
final highlightsProvider = FutureProvider.family<List<TournamentHighlight>, _GetTournamentParams>(
  (ref, params) async {
    final repository = ref.watch(tournamentRepositoryProvider);
    return repository.getHighlights(params.tournamentId);
  },
);
