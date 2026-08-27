import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toriverse/features/organizing/domain/models/organizer.dart';

/// Repository for tournament organization and management
///
/// Handles organizer profile, tournament creation, configuration,
/// participant management, and payout processing.
class OrganizerRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  OrganizerRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // ============================================================================
  // ORGANIZER PROFILE OPERATIONS
  // ============================================================================

  /// Get organizer profile
  Future<OrganizerProfile?> getOrganizerProfile(String uid) async {
    try {
      final doc = await _firestore.collection('organizers').doc(uid).get();
      if (!doc.exists) return null;
      return OrganizerProfile.fromJson(doc.data()!);
    } catch (e) {
      rethrow;
    }
  }

  /// Create organizer profile
  Future<OrganizerProfile> createOrganizerProfile({
    required String uid,
    required String displayName,
    required String email,
  }) async {
    try {
      final profile = OrganizerProfile(
        uid: uid,
        displayName: displayName,
        email: email,
        tournamentCount: 0,
        totalParticipants: 0,
        avgRating: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('organizers')
          .doc(uid)
          .set(profile.toJson());

      return profile;
    } catch (e) {
      rethrow;
    }
  }

  /// Update organizer profile
  Future<OrganizerProfile> updateOrganizerProfile({
    required String uid,
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final profile = await getOrganizerProfile(uid);
      if (profile == null) throw Exception('Organizer profile not found');

      final updated = profile.copyWith(
        displayName: displayName ?? profile.displayName,
        bio: bio ?? profile.bio,
        avatarUrl: avatarUrl ?? profile.avatarUrl,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('organizers')
          .doc(uid)
          .update(updated.toJson());

      return updated;
    } catch (e) {
      rethrow;
    }
  }

  /// Get organizer statistics
  Future<OrganizerStats?> getOrganizerStats(String uid) async {
    try {
      final doc = await _firestore
          .collection('organizers')
          .doc(uid)
          .collection('stats')
          .doc('summary')
          .get();
      if (!doc.exists) return null;
      return OrganizerStats.fromJson(doc.data()!);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================================
  // TOURNAMENT CREATION & MANAGEMENT
  // ============================================================================

  /// Create tournament draft
  Future<TournamentDraft> createTournamentDraft({
    required String organizerId,
    required String name,
    required String description,
    required String format,
    required PrizePoolConfig prizePool,
    int maxParticipants = 64,
  }) async {
    try {
      final draft = TournamentDraft(
        organizerId: organizerId,
        name: name,
        description: description,
        format: format,
        maxParticipants: maxParticipants,
        prizePool: prizePool,
      );

      final docRef = await _firestore.collection('tournaments').add(draft.toJson());

      return draft.copyWith(); // Add ID if needed
    } catch (e) {
      rethrow;
    }
  }

  /// Publish tournament (move from draft to registration open)
  Future<void> publishTournament({
    required String tournamentId,
    required DateTime startDate,
    required DateTime registrationDeadline,
  }) async {
    try {
      await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .update({
        'status': 'published',
        'startDate': Timestamp.fromDate(startDate),
        'registrationDeadline': Timestamp.fromDate(registrationDeadline),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _logTournamentEvent(
        tournamentId,
        'tournament_published',
        {'startDate': startDate.toString()},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Update tournament configuration
  Future<void> updateTournamentConfig({
    required String tournamentId,
    required TournamentConfig config,
  }) async {
    try {
      await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('config')
          .doc('settings')
          .set(config.toJson());

      _logTournamentEvent(
        tournamentId,
        'config_updated',
        {'format': config.format},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Start tournament (transition from registration to active)
  Future<void> startTournament(String tournamentId) async {
    try {
      // Get all approved registrations
      final registrations = await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('registrations')
          .where('status', isEqualTo: 'approved')
          .get();

      // Generate bracket based on tournament format
      final tournament = await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .get();

      final format = tournament['format'] as String;
      await _generateBracket(tournamentId, format, registrations.docs.length);

      // Update tournament status
      await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .update({
        'status': 'active',
        'startedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _logTournamentEvent(
        tournamentId,
        'tournament_started',
        {'participantCount': registrations.docs.length},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Finish tournament (transition to finished, calculate standings)
  Future<void> finishTournament(String tournamentId) async {
    try {
      await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .update({
        'status': 'finished',
        'finishedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Calculate final standings and award prizes
      await _calculateFinalStandings(tournamentId);

      _logTournamentEvent(tournamentId, 'tournament_finished', {});
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================================
  // PARTICIPANT MANAGEMENT
  // ============================================================================

  /// Get tournament registrations
  Future<List<TournamentRegistration>> getTournamentRegistrations(
    String tournamentId,
  ) async {
    try {
      final snap = await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('registrations')
          .orderBy('registeredAt', descending: true)
          .get();

      return snap.docs
          .map((doc) => TournamentRegistration.fromJson(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Approve player registration
  Future<void> approveRegistration({
    required String tournamentId,
    required String registrationId,
  }) async {
    try {
      await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('registrations')
          .doc(registrationId)
          .update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
      });

      _logTournamentEvent(
        tournamentId,
        'registration_approved',
        {'registrationId': registrationId},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Reject player registration
  Future<void> rejectRegistration({
    required String tournamentId,
    required String registrationId,
    required String reason,
  }) async {
    try {
      await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('registrations')
          .doc(registrationId)
          .update({
        'status': 'rejected',
        'notes': reason,
      });

      _logTournamentEvent(
        tournamentId,
        'registration_rejected',
        {'reason': reason},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get participating players
  Stream<List<TournamentRegistration>> watchTournamentParticipants(
    String tournamentId,
  ) {
    return _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('registrations')
        .where('status', isEqualTo: 'approved')
        .orderBy('registeredAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => TournamentRegistration.fromJson(doc.data()))
            .toList());
  }

  // ============================================================================
  // BRACKET CONFIGURATION
  // ============================================================================

  /// Configure bracket settings
  Future<void> configureBracketFormat({
    required String tournamentId,
    required String format,
    required Map<String, dynamic> settings,
  }) async {
    try {
      await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .update({
        'bracketSettings': settings,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _logTournamentEvent(
        tournamentId,
        'bracket_configured',
        {'format': format},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Seed players manually (organizer override)
  Future<void> seedPlayers({
    required String tournamentId,
    required List<String> playerIds,
  }) async {
    try {
      for (var i = 0; i < playerIds.length; i++) {
        await _firestore
            .collection('tournaments')
            .doc(tournamentId)
            .collection('participants')
            .doc(playerIds[i])
            .update({
          'seedRank': i + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      _logTournamentEvent(
        tournamentId,
        'players_seeded',
        {'count': playerIds.length},
      );
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================================
  // PAYOUT MANAGEMENT
  // ============================================================================

  /// Create payout request
  Future<PayoutRequest> createPayoutRequest({
    required String tournamentId,
    required String organizerId,
    required Map<String, int> payouts,
  }) async {
    try {
      final totalAmount = payouts.values.reduce((a, b) => a + b);

      final request = PayoutRequest(
        id: _firestore.collection('payouts').doc().id,
        tournamentId: tournamentId,
        organizerId: organizerId,
        totalAmount: totalAmount,
        payouts: payouts,
        requestedAt: DateTime.now(),
      );

      await _firestore.collection('payouts').doc(request.id).set(request.toJson());

      _logTournamentEvent(
        tournamentId,
        'payout_requested',
        {'amount': totalAmount, 'count': payouts.length},
      );

      return request;
    } catch (e) {
      rethrow;
    }
  }

  /// Get payout requests for organizer
  Future<List<PayoutRequest>> getPayoutRequests(String organizerId) async {
    try {
      final snap = await _firestore
          .collection('payouts')
          .where('organizerId', isEqualTo: organizerId)
          .orderBy('requestedAt', descending: true)
          .get();

      return snap.docs
          .map((doc) => PayoutRequest.fromJson(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Update payout status
  Future<void> updatePayoutStatus({
    required String payoutId,
    required String status,
    String? notes,
  }) async {
    try {
      await _firestore
          .collection('payouts')
          .doc(payoutId)
          .update({
        'status': status,
        if (notes != null) 'notes': notes,
        if (status == 'completed') 'processedAt': FieldValue.serverTimestamp(),
      });

      _logAnalyticsEvent('payout_status_updated', {'status': status});
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================================
  // ORGANIZER DASHBOARD
  // ============================================================================

  /// Get organizer's tournaments
  Future<List<TournamentDraft>> getOrganizerTournaments(String organizerId) async {
    try {
      final snap = await _firestore
          .collection('tournaments')
          .where('organizerId', isEqualTo: organizerId)
          .orderBy('updatedAt', descending: true)
          .get();

      return snap.docs
          .map((doc) => TournamentDraft.fromJson(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Watch organizer's tournaments (real-time)
  Stream<List<TournamentDraft>> watchOrganizerTournaments(String organizerId) {
    return _firestore
        .collection('tournaments')
        .where('organizerId', isEqualTo: organizerId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => TournamentDraft.fromJson(doc.data()))
            .toList());
  }

  /// Get draft tournaments
  Stream<List<TournamentDraft>> watchDraftTournaments(String organizerId) {
    return _firestore
        .collection('tournaments')
        .where('organizerId', isEqualTo: organizerId)
        .where('status', isEqualTo: 'draft')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => TournamentDraft.fromJson(doc.data()))
            .toList());
  }

  // ============================================================================
  // TOURNAMENT TEMPLATES
  // ============================================================================

  /// Get tournament templates for organizer
  Future<List<TournamentTemplate>> getTournamentTemplates(
    String organizerId,
  ) async {
    try {
      final snap = await _firestore
          .collection('organizers')
          .doc(organizerId)
          .collection('templates')
          .get();

      return snap.docs
          .map((doc) => TournamentTemplate.fromJson(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create tournament template
  Future<TournamentTemplate> createTemplate({
    required String organizerId,
    required String name,
    required String format,
    required PrizePoolConfig prizePool,
    List<String> rules = const [],
  }) async {
    try {
      final template = TournamentTemplate(
        id: _firestore.collection('templates').doc().id,
        organizerId: organizerId,
        name: name,
        format: format,
        prizePoolTemplate: prizePool,
        rules: rules,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('organizers')
          .doc(organizerId)
          .collection('templates')
          .doc(template.id)
          .set(template.toJson());

      return template;
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================================
  // REVIEWS & RATINGS
  // ============================================================================

  /// Add review for organizer
  Future<TournamentReview> addOrganizerReview({
    required String organizerId,
    required String tournamentId,
    required String reviewerId,
    required String reviewerName,
    required double rating,
    required String comment,
    List<String> categories = const [],
  }) async {
    try {
      final review = TournamentReview(
        id: _firestore.collection('reviews').doc().id,
        tournamentId: tournamentId,
        reviewerId: reviewerId,
        reviewerName: reviewerName,
        rating: rating,
        comment: comment,
        categories: categories,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('organizers')
          .doc(organizerId)
          .collection('reviews')
          .doc(review.id)
          .set(review.toJson());

      // Update organizer rating
      await _updateOrganizerRating(organizerId);

      return review;
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  Future<void> _generateBracket(
    String tournamentId,
    String format,
    int participantCount,
  ) async {
    // Bracket generation logic (simplified)
    // In Phase 2e, this was stubbed for different formats
    // For now, create basic bracket structure
    try {
      await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('bracket')
          .doc('data')
          .set({
        'format': format,
        'participantCount': participantCount,
        'rounds': _calculateRounds(format, participantCount),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  int _calculateRounds(String format, int count) {
    switch (format) {
      case 'single_elimination':
        return (count - 1).bitLength; // Log2(count) rounded up
      case 'double_elimination':
        return ((count - 1).bitLength * 2) - 1;
      case 'round_robin':
        return count - 1;
      case 'swiss':
        return ((count - 1).bitLength * 1.5).ceil();
      case 'ladder':
        return 1; // Continuous
      default:
        return 1;
    }
  }

  Future<void> _calculateFinalStandings(String tournamentId) async {
    try {
      // Get all completed matches
      final matches = await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('matches')
          .where('status', isEqualTo: 'completed')
          .get();

      // Calculate standings from match results
      // Store in tournament.standings collection
      await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('standings')
          .doc('final')
          .set({
        'matchCount': matches.docs.length,
        'calculatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _updateOrganizerRating(String organizerId) async {
    try {
      final reviews = await _firestore
          .collection('organizers')
          .doc(organizerId)
          .collection('reviews')
          .get();

      if (reviews.docs.isEmpty) return;

      final avgRating =
          reviews.docs.map((doc) => doc['rating'] as double).reduce((a, b) => a + b) /
              reviews.docs.length;

      await _firestore
          .collection('organizers')
          .doc(organizerId)
          .update({'avgRating': avgRating});
    } catch (e) {
      rethrow;
    }
  }

  void _logTournamentEvent(
    String tournamentId,
    String eventName,
    Map<String, dynamic> params,
  ) {
    // Log to Firebase Analytics or similar
    _logAnalyticsEvent(eventName, {
      'tournament_id': tournamentId,
      ...params,
    });
  }

  void _logAnalyticsEvent(String name, Map<String, dynamic> params) {
    // Firebase Analytics integration (to be implemented)
  }
}
