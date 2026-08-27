import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/spectating/domain/models/tournament.dart';

/// Repository for tournament operations
class TournamentRepository {
  final FirebaseFirestore _firestore;

  TournamentRepository(this._firestore);

  /// Create new tournament
  Future<String> createTournament({
    required String name,
    required String description,
    required TournamentFormat format,
    required DateTime startDate,
    required DateTime registrationDeadline,
    required int maxParticipants,
    required PrizePool prizePool,
    required String organizerId,
    required String organizerName,
    required List<String> rules,
    bool isFeatured = false,
    String? bannerUrl,
    String? logoUrl,
  }) async {
    final tournamentRef = _firestore.collection('tournaments').doc();
    final now = DateTime.now();

    final tournament = Tournament(
      id: tournamentRef.id,
      name: name,
      description: description,
      format: format,
      status: TournamentStatus.draft,
      startDate: startDate,
      endDate: null,
      registrationDeadline: registrationDeadline,
      maxParticipants: maxParticipants,
      currentParticipants: 0,
      prizePool: prizePool,
      organizerId: organizerId,
      organizerName: organizerName,
      rules: rules,
      isFeatured: isFeatured,
      viewerCount: 0,
      totalMatches: 0,
      completedMatches: 0,
      createdAt: now,
      updatedAt: now,
      bannerUrl: bannerUrl,
      logoUrl: logoUrl,
    );

    await tournamentRef.set(tournament.toJson());
    _logTournamentEvent(
      tournament.id,
      'tournament_created',
      {'name': name, 'format': format.label},
    );

    return tournament.id;
  }

  /// Open tournament for registration
  Future<void> openRegistration(String tournamentId) async {
    await _firestore.collection('tournaments').doc(tournamentId).update({
      'status': TournamentStatus.registration.name,
      'updatedAt': DateTime.now().toIso8601String(),
    });
    _logTournamentEvent(tournamentId, 'registration_opened', {});
  }

  /// Register player in tournament
  Future<void> registerPlayer(
    String tournamentId,
    String userId,
    String displayName,
    int seedRank,
  ) async {
    final participantRef = _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('participants')
        .doc(userId);

    final participant = TournamentParticipant(
      id: participantRef.id,
      tournamentId: tournamentId,
      userId: userId,
      displayName: displayName,
      seedRank: seedRank,
      wins: 0,
      losses: 0,
      winRate: 0.0,
      points: 0,
      isActive: true,
      joinedAt: DateTime.now(),
    );

    await participantRef.set(participant.toJson());
    await _firestore.collection('tournaments').doc(tournamentId).update({
      'currentParticipants': FieldValue.increment(1),
    });

    _logTournamentEvent(
      tournamentId,
      'player_registered',
      {'userId': userId, 'displayName': displayName},
    );
  }

  /// Start tournament (generate bracket and begin matches)
  Future<void> startTournament(String tournamentId) async {
    final tournamentDoc =
        await _firestore.collection('tournaments').doc(tournamentId).get();
    final tournament = Tournament.fromJson(tournamentDoc.data()!);

    final participantsSnap = await _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('participants')
        .where('isActive', isEqualTo: true)
        .orderBy('seedRank')
        .get();

    final participants = participantsSnap.docs
        .map((doc) => TournamentParticipant.fromJson(doc.data()))
        .toList();

    // Generate bracket based on format
    final roundMatches = _generateBracket(
      tournament.format,
      participants,
      tournamentId,
    );

    final bracketRef =
        _firestore.collection('tournaments').doc(tournamentId).collection('bracket').doc('main');
    final bracket = TournamentBracket(
      id: 'main',
      tournamentId: tournamentId,
      roundMatches: roundMatches,
      standings: participants,
      currentRound: 1,
      nextRoundTime: null,
    );

    await bracketRef.set(bracket.toJson());
    await _firestore.collection('tournaments').doc(tournamentId).update({
      'status': TournamentStatus.inProgress.name,
      'totalMatches': roundMatches.values.fold<int>(0, (sum, matches) => sum + matches.length),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    _logTournamentEvent(tournamentId, 'tournament_started', {
      'participants': participants.length,
      'rounds': roundMatches.length,
    });
  }

  /// Get tournament details
  Future<Tournament?> getTournament(String tournamentId) async {
    final doc = await _firestore.collection('tournaments').doc(tournamentId).get();
    return doc.exists ? Tournament.fromJson(doc.data()!) : null;
  }

  /// Watch tournament for real-time updates
  Stream<Tournament?> watchTournament(String tournamentId) {
    return _firestore.collection('tournaments').doc(tournamentId).snapshots().map(
          (doc) => doc.exists ? Tournament.fromJson(doc.data()!) : null,
        );
  }

  /// Get tournament matches
  Future<List<TournamentMatch>> getMatches(String tournamentId, {int? round}) async {
    var query = _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('matches')
        .orderBy('scheduledTime');

    if (round != null) {
      query = query.where('round', isEqualTo: round);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => TournamentMatch.fromJson(doc.data())).toList();
  }

  /// Watch live matches
  Stream<List<TournamentMatch>> watchLiveMatches(String tournamentId) {
    return _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('matches')
        .where('status', isEqualTo: MatchStatus.live.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => TournamentMatch.fromJson(doc.data())).toList());
  }

  /// Create tournament match
  Future<String> createMatch(
    String tournamentId,
    int round,
    int matchNumber,
    List<String> playerIds,
    DateTime scheduledTime,
  ) async {
    final matchRef = _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('matches')
        .doc();

    final match = TournamentMatch(
      id: matchRef.id,
      tournamentId: tournamentId,
      round: round,
      matchNumber: matchNumber,
      playerIds: playerIds,
      status: MatchStatus.scheduled,
      scheduledTime: scheduledTime,
      isFeatured: false,
      viewerCount: 0,
    );

    await matchRef.set(match.toJson());
    return match.id;
  }

  /// Update match status
  Future<void> updateMatchStatus(
    String tournamentId,
    String matchId,
    MatchStatus status,
  ) async {
    final matchRef = _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('matches')
        .doc(matchId);

    final updates = {'status': status.name, 'updatedAt': DateTime.now().toIso8601String()};

    if (status == MatchStatus.live) {
      updates['liveStartedAt'] = DateTime.now().toIso8601String();
    } else if (status == MatchStatus.completed) {
      updates['completedTime'] = DateTime.now().toIso8601String();
    }

    await matchRef.update(updates);
    _logTournamentEvent(tournamentId, 'match_status_updated', {
      'matchId': matchId,
      'status': status.label,
    });
  }

  /// Complete match with winner
  Future<void> completeMatch(
    String tournamentId,
    String matchId,
    String winnerId,
    Map<String, int> finalScores,
  ) async {
    final matchRef = _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('matches')
        .doc(matchId);

    await matchRef.update({
      'status': MatchStatus.completed.name,
      'winnerId': winnerId,
      'finalScores': finalScores,
      'completedTime': DateTime.now().toIso8601String(),
    });

    // Update participant stats
    final matchDoc = await matchRef.get();
    final match = TournamentMatch.fromJson(matchDoc.data()!);

    for (final playerId in match.playerIds) {
      final participantRef = _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('participants')
          .doc(playerId);

      if (playerId == winnerId) {
        await participantRef.update({
          'wins': FieldValue.increment(1),
          'consecutiveWins': FieldValue.increment(1),
        });
      } else {
        await participantRef.update({
          'losses': FieldValue.increment(1),
          'consecutiveWins': 0,
        });
      }
    }

    // Update tournament stats
    await _firestore.collection('tournaments').doc(tournamentId).update({
      'completedMatches': FieldValue.increment(1),
    });

    _logTournamentEvent(tournamentId, 'match_completed', {
      'matchId': matchId,
      'winner': winnerId,
    });
  }

  /// Feature a match (for home screen display)
  Future<void> featureMatch(
    String tournamentId,
    String matchId,
    String title,
    String description,
  ) async {
    final featuredRef = _firestore.collection('featured_matches').doc();
    final matchDoc = await _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('matches')
        .doc(matchId)
        .get();
    final match = TournamentMatch.fromJson(matchDoc.data()!);

    final featured = FeaturedMatch(
      id: featuredRef.id,
      matchId: matchId,
      tournamentId: tournamentId,
      title: title,
      description: description,
      startTime: match.scheduledTime,
      expectedViewers: 1000,
      currentViewers: 0,
      importance: 0.8,
      featuredStartTime: DateTime.now(),
      featuredEndTime: DateTime.now().add(const Duration(hours: 24)),
    );

    await featuredRef.set(featured.toJson());
    await _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('matches')
        .doc(matchId)
        .update({'isFeatured': true});

    _logTournamentEvent(tournamentId, 'match_featured', {'matchId': matchId});
  }

  /// Get tournament standings
  Future<List<TournamentParticipant>> getStandings(String tournamentId) async {
    final snapshot = await _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('participants')
        .where('isActive', isEqualTo: true)
        .orderBy('wins', descending: true)
        .orderBy('pointDiff', descending: true)
        .get();

    return snapshot.docs.map((doc) => TournamentParticipant.fromJson(doc.data())).toList();
  }

  /// Watch tournament standings for real-time updates
  Stream<List<TournamentParticipant>> watchStandings(String tournamentId) {
    return _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('participants')
        .where('isActive', isEqualTo: true)
        .orderBy('wins', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => TournamentParticipant.fromJson(doc.data())).toList());
  }

  /// Add viewer prediction
  Future<void> addPrediction(
    String matchId,
    String viewerId,
    String predictedWinnerId,
    int wageredPoints,
  ) async {
    final predictionRef = _firestore.collection('predictions').doc();
    final prediction = MatchPrediction(
      id: predictionRef.id,
      matchId: matchId,
      viewerId: viewerId,
      predictedWinnerId: predictedWinnerId,
      wageredPoints: wageredPoints,
      isCorrect: false,
      pointsWon: 0,
      createdAt: DateTime.now(),
    );

    await predictionRef.set(prediction.toJson());
  }

  /// Award viewer for watching
  Future<void> awardViewer(
    String tournamentId,
    String viewerId,
    int watchMinutes,
    int pointsEarned,
  ) async {
    final rewardRef = _firestore.collection('viewer_rewards').doc();
    final reward = ViewerReward(
      id: rewardRef.id,
      tournamentId: tournamentId,
      viewerId: viewerId,
      watchMinutes: watchMinutes,
      pointsEarned: pointsEarned,
      tokensEarned: (pointsEarned / 10).toInt(), // 10 points = ¥1
      earnedAt: DateTime.now(),
    );

    await rewardRef.set(reward.toJson());
  }

  /// Get featured matches
  Future<List<FeaturedMatch>> getFeaturedMatches({int limit = 5}) async {
    final snapshot = await _firestore
        .collection('featured_matches')
        .where('featuredEndTime', isGreaterThan: DateTime.now())
        .orderBy('featuredEndTime')
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => FeaturedMatch.fromJson(doc.data())).toList();
  }

  /// Watch featured matches for home screen
  Stream<List<FeaturedMatch>> watchFeaturedMatches() {
    return _firestore
        .collection('featured_matches')
        .where('featuredEndTime', isGreaterThan: DateTime.now())
        .orderBy('importance', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => FeaturedMatch.fromJson(doc.data())).toList());
  }

  /// Update viewer count for match
  Future<void> updateViewerCount(
    String tournamentId,
    String matchId,
    int viewerCount,
  ) async {
    await _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('matches')
        .doc(matchId)
        .update({'viewerCount': viewerCount});
  }

  /// Get tournament highlights
  Future<List<TournamentHighlight>> getHighlights(String tournamentId) async {
    final snapshot = await _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('highlights')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();

    return snapshot.docs.map((doc) => TournamentHighlight.fromJson(doc.data())).toList();
  }

  /// Award tournament badge
  Future<void> awardBadge(
    String tournamentId,
    String playerId,
    String badgeName,
    String emoji,
    String description,
    int rarity,
  ) async {
    final badgeRef = _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('badges')
        .doc('${badgeName}_$playerId');

    final badge = TournamentBadge(
      id: badgeRef.id,
      tournamentId: tournamentId,
      name: badgeName,
      emoji: emoji,
      description: description,
      unlockedBy: [playerId],
      rarity: rarity,
    );

    await badgeRef.set(badge.toJson());
  }

  /// Generate bracket matches based on format
  Map<int, List<TournamentMatch>> _generateBracket(
    TournamentFormat format,
    List<TournamentParticipant> participants,
    String tournamentId,
  ) {
    final matches = <int, List<TournamentMatch>>{};

    switch (format) {
      case TournamentFormat.singleElimination:
        matches.addAll(_generateSingleElimination(participants, tournamentId));
      case TournamentFormat.doubleElimination:
        matches.addAll(_generateDoubleElimination(participants, tournamentId));
      case TournamentFormat.roundRobin:
        matches.addAll(_generateRoundRobin(participants, tournamentId));
      case TournamentFormat.swiss:
        matches.addAll(_generateSwiss(participants, tournamentId));
      case TournamentFormat.ladder:
        matches.addAll(_generateLadder(participants, tournamentId));
    }

    return matches;
  }

  Map<int, List<TournamentMatch>> _generateSingleElimination(
    List<TournamentParticipant> participants,
    String tournamentId,
  ) {
    // Simplified: generate first round 3-person matches
    final matches = <int, List<TournamentMatch>>{};
    final firstRound = <TournamentMatch>[];

    for (int i = 0; i < participants.length; i += 3) {
      final group = participants.skip(i).take(3).toList();
      if (group.length == 3) {
        firstRound.add(TournamentMatch(
          id: '${tournamentId}_r1_m${i ~/ 3}',
          tournamentId: tournamentId,
          round: 1,
          matchNumber: i ~/ 3,
          playerIds: group.map((p) => p.userId).toList(),
          playerNames: group.map((p) => p.displayName).toList(),
          playerSeeds: group.map((p) => p.seedRank).toList(),
          status: MatchStatus.scheduled,
          scheduledTime: DateTime.now().add(Duration(hours: i ~/ 3)),
          isFeatured: i == 0,
          viewerCount: 0,
        ));
      }
    }

    matches[1] = firstRound;
    return matches;
  }

  Map<int, List<TournamentMatch>> _generateDoubleElimination(
    List<TournamentParticipant> participants,
    String tournamentId,
  ) {
    // TODO: Implement double elimination bracket
    return {};
  }

  Map<int, List<TournamentMatch>> _generateRoundRobin(
    List<TournamentParticipant> participants,
    String tournamentId,
  ) {
    // TODO: Implement round-robin bracket
    return {};
  }

  Map<int, List<TournamentMatch>> _generateSwiss(
    List<TournamentParticipant> participants,
    String tournamentId,
  ) {
    // TODO: Implement Swiss system bracket
    return {};
  }

  Map<int, List<TournamentMatch>> _generateLadder(
    List<TournamentParticipant> participants,
    String tournamentId,
  ) {
    // TODO: Implement ladder bracket
    return {};
  }

  /// Log tournament event for analytics
  void _logTournamentEvent(
    String tournamentId,
    String eventType,
    Map<String, dynamic> parameters,
  ) {
    // TODO: Implement analytics logging
  }
}
