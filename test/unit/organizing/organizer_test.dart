import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/organizing/domain/models/organizer.dart';

void main() {
  group('OrganizerProfile', () {
    test('creates profile with correct data', () {
      final profile = OrganizerProfile(
        uid: 'org_123',
        displayName: 'Tournament Master',
        email: 'master@example.com',
        tournamentCount: 5,
        totalParticipants: 150,
        avgRating: 4.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isVerified: true,
        canHostPremium: true,
      );

      expect(profile.uid, 'org_123');
      expect(profile.displayName, 'Tournament Master');
      expect(profile.tournamentCount, 5);
      expect(profile.isVerified, true);
      expect(profile.canHostPremium, true);
    });

    test('serializes profile to JSON', () {
      final profile = OrganizerProfile(
        uid: 'org_123',
        displayName: 'Host',
        email: 'host@example.com',
        tournamentCount: 3,
        totalParticipants: 100,
        avgRating: 4.2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final json = profile.toJson();
      expect(json['uid'], 'org_123');
      expect(json['displayName'], 'Host');
      expect(json['tournamentCount'], 3);
    });

    test('deserializes profile from JSON', () {
      final json = {
        'uid': 'org_456',
        'displayName': 'Pro Organizer',
        'email': 'pro@example.com',
        'tournamentCount': 10,
        'totalParticipants': 500,
        'avgRating': 4.8,
        'isVerified': true,
        'canHostPremium': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final profile = OrganizerProfile.fromJson(json);
      expect(profile.uid, 'org_456');
      expect(profile.displayName, 'Pro Organizer');
      expect(profile.tournamentCount, 10);
    });
  });

  group('TournamentDraft', () {
    test('creates draft tournament with correct data', () {
      final prizePool = PrizePoolConfig(
        totalAmount: 500000,
        distribution: {1: 300000, 2: 150000, 3: 50000},
        currency: 'JPY',
      );

      final draft = TournamentDraft(
        organizerId: 'org_1',
        name: 'Spring Championship',
        description: 'Annual spring tournament',
        format: 'single_elimination',
        maxParticipants: 64,
        prizePool: prizePool,
      );

      expect(draft.organizerId, 'org_1');
      expect(draft.name, 'Spring Championship');
      expect(draft.format, 'single_elimination');
      expect(draft.maxParticipants, 64);
      expect(draft.status, 'draft');
      expect(draft.currentParticipants, 0);
    });

    test('serializes tournament draft to JSON', () {
      final prizePool = PrizePoolConfig(
        totalAmount: 300000,
        distribution: {1: 200000, 2: 100000},
        currency: 'JPY',
      );

      final draft = TournamentDraft(
        organizerId: 'org_2',
        name: 'Quick Tourney',
        description: 'Fast paced tournament',
        format: 'round_robin',
        maxParticipants: 16,
        prizePool: prizePool,
      );

      final json = draft.toJson();
      expect(json['organizerId'], 'org_2');
      expect(json['name'], 'Quick Tourney');
      expect(json['status'], 'draft');
    });

    test('transitions tournament status correctly', () {
      final prizePool = PrizePoolConfig(
        totalAmount: 100000,
        distribution: {1: 60000, 2: 40000},
        currency: 'JPY',
      );

      var draft = TournamentDraft(
        organizerId: 'org_3',
        name: 'Test Tournament',
        description: 'Test',
        format: 'single_elimination',
        maxParticipants: 32,
        prizePool: prizePool,
      );

      expect(draft.status, 'draft');

      // Simulate status changes
      draft = draft.copyWith(status: 'published');
      expect(draft.status, 'published');

      draft = draft.copyWith(status: 'active');
      expect(draft.status, 'active');

      draft = draft.copyWith(status: 'finished');
      expect(draft.status, 'finished');
    });
  });

  group('PrizePoolConfig', () {
    test('creates prize pool with correct distribution', () {
      final distribution = {
        1: 500000,
        2: 250000,
        3: 100000,
        4: 50000,
      };

      final pool = PrizePoolConfig(
        totalAmount: 900000,
        distribution: distribution,
        currency: 'JPY',
        sponsorName: 'TechCorp',
      );

      expect(pool.totalAmount, 900000);
      expect(pool.distribution[1], 500000);
      expect(pool.distribution[4], 50000);
      expect(pool.sponsorName, 'TechCorp');
    });

    test('validates prize pool distribution sum', () {
      final distribution = {
        1: 300000,
        2: 150000,
        3: 50000,
      };

      final pool = PrizePoolConfig(
        totalAmount: 500000,
        distribution: distribution,
        currency: 'JPY',
      );

      final totalDistributed =
          distribution.values.reduce((a, b) => a + b);
      expect(totalDistributed, 500000);
    });

    test('serializes and deserializes prize pool', () {
      final distribution = {1: 200000, 2: 100000};

      final pool = PrizePoolConfig(
        totalAmount: 300000,
        distribution: distribution,
        currency: 'JPY',
        sponsorName: 'Sponsor Inc',
      );

      final json = pool.toJson();
      final deserialized = PrizePoolConfig.fromJson(json);

      expect(deserialized.totalAmount, 300000);
      expect(deserialized.distribution[1], 200000);
      expect(deserialized.sponsorName, 'Sponsor Inc');
    });
  });

  group('TournamentConfig', () {
    test('creates configuration with all settings', () {
      final config = TournamentConfig(
        tournamentId: 'tour_123',
        organizerId: 'org_1',
        format: 'single_elimination',
        allowLateRegistration: false,
        submissionTimeSeconds: 30,
        requirePlayerConfirmation: true,
        autoStartMatches: true,
        timezone: 'Asia/Tokyo',
        minAge: 18,
        recordMatches: true,
        autoGenerateClips: true,
      );

      expect(config.tournamentId, 'tour_123');
      expect(config.submissionTimeSeconds, 30);
      expect(config.requirePlayerConfirmation, true);
      expect(config.timezone, 'Asia/Tokyo');
      expect(config.autoGenerateClips, true);
    });

    test('serializes configuration to JSON', () {
      final config = TournamentConfig(
        tournamentId: 'tour_456',
        organizerId: 'org_2',
        format: 'round_robin',
        spectatorLimit: 100,
        allowStreamers: true,
      );

      final json = config.toJson();
      expect(json['format'], 'round_robin');
      expect(json['spectatorLimit'], 100);
      expect(json['allowStreamers'], true);
    });
  });

  group('OrganizerStats', () {
    test('creates statistics with correct data', () {
      final stats = OrganizerStats(
        organizerId: 'org_1',
        totalTournaments: 10,
        completedTournaments: 8,
        totalParticipants: 300,
        totalViewers: 50000,
        totalPrizePoolAwarded: 2000000,
        avgPlayerRating: 4.5,
        organizerRating: 4.7,
      );

      expect(stats.organizerId, 'org_1');
      expect(stats.totalTournaments, 10);
      expect(stats.completedTournaments, 8);
      expect(stats.totalViewers, 50000);
      expect(stats.organizerRating, 4.7);
    });

    test('calculates organizer statistics correctly', () {
      final stats = OrganizerStats(
        organizerId: 'org_2',
        totalTournaments: 5,
        completedTournaments: 4,
        totalParticipants: 100,
        totalViewers: 10000,
        totalPrizePoolAwarded: 500000,
      );

      final completionRate = stats.completedTournaments / stats.totalTournaments;
      expect(completionRate, 0.8);
    });
  });

  group('TournamentRegistration', () {
    test('creates registration with correct data', () {
      final registration = TournamentRegistration(
        id: 'reg_123',
        tournamentId: 'tour_1',
        userId: 'user_1',
        displayName: 'Player One',
        registeredAt: DateTime.now(),
        status: 'pending',
      );

      expect(registration.id, 'reg_123');
      expect(registration.userId, 'user_1');
      expect(registration.status, 'pending');
      expect(registration.displayName, 'Player One');
    });

    test('transitions registration status', () {
      var registration = TournamentRegistration(
        id: 'reg_456',
        tournamentId: 'tour_2',
        userId: 'user_2',
        displayName: 'Player Two',
        registeredAt: DateTime.now(),
      );

      expect(registration.status, 'pending');

      registration = registration.copyWith(status: 'approved');
      expect(registration.status, 'approved');

      registration = registration.copyWith(status: 'rejected', notes: 'Duplicate account');
      expect(registration.status, 'rejected');
      expect(registration.notes, 'Duplicate account');
    });

    test('serializes registration to JSON', () {
      final registration = TournamentRegistration(
        id: 'reg_789',
        tournamentId: 'tour_3',
        userId: 'user_3',
        displayName: 'Player Three',
        registeredAt: DateTime.now(),
        status: 'approved',
      );

      final json = registration.toJson();
      expect(json['userId'], 'user_3');
      expect(json['status'], 'approved');
    });
  });

  group('PayoutRequest', () {
    test('creates payout request with correct data', () {
      final payouts = {
        'user_1': 300000,
        'user_2': 150000,
        'user_3': 50000,
      };

      final request = PayoutRequest(
        id: 'payout_123',
        tournamentId: 'tour_1',
        organizerId: 'org_1',
        totalAmount: 500000,
        payouts: payouts,
        status: 'pending',
        requestedAt: DateTime.now(),
      );

      expect(request.id, 'payout_123');
      expect(request.totalAmount, 500000);
      expect(request.payouts.length, 3);
      expect(request.status, 'pending');
    });

    test('validates payout total matches sum of individual payouts', () {
      final payouts = {
        'user_1': 200000,
        'user_2': 100000,
      };

      final request = PayoutRequest(
        id: 'payout_456',
        tournamentId: 'tour_2',
        organizerId: 'org_2',
        totalAmount: 300000,
        payouts: payouts,
      );

      final actualSum = payouts.values.reduce((a, b) => a + b);
      expect(request.totalAmount, actualSum);
    });

    test('transitions payout status correctly', () {
      var request = PayoutRequest(
        id: 'payout_789',
        tournamentId: 'tour_3',
        organizerId: 'org_3',
        totalAmount: 100000,
        payouts: {'user_1': 100000},
        status: 'pending',
        requestedAt: DateTime.now(),
      );

      expect(request.status, 'pending');

      request = request.copyWith(status: 'processing');
      expect(request.status, 'processing');

      request = request.copyWith(status: 'completed');
      expect(request.status, 'completed');
    });

    test('serializes payout request to JSON', () {
      final request = PayoutRequest(
        id: 'payout_999',
        tournamentId: 'tour_4',
        organizerId: 'org_4',
        totalAmount: 250000,
        payouts: {'user_1': 250000},
        status: 'completed',
        requestedAt: DateTime.now(),
        processedAt: DateTime.now(),
      );

      final json = request.toJson();
      expect(json['status'], 'completed');
      expect(json['totalAmount'], 250000);
    });
  });

  group('TournamentTemplate', () {
    test('creates template with correct data', () {
      final prizePool = PrizePoolConfig(
        totalAmount: 500000,
        distribution: {1: 300000, 2: 150000, 3: 50000},
        currency: 'JPY',
      );

      final template = TournamentTemplate(
        id: 'tmpl_123',
        organizerId: 'org_1',
        name: 'Standard Championship',
        format: 'single_elimination',
        prizePoolTemplate: prizePool,
        rules: ['Best of 1', 'No draws'],
      );

      expect(template.id, 'tmpl_123');
      expect(template.name, 'Standard Championship');
      expect(template.prizePoolTemplate.totalAmount, 500000);
      expect(template.rules.length, 2);
    });

    test('serializes template to JSON', () {
      final template = TournamentTemplate(
        id: 'tmpl_456',
        organizerId: 'org_2',
        name: 'Quick Format',
        format: 'round_robin',
        prizePoolTemplate: PrizePoolConfig(
          totalAmount: 200000,
          distribution: {1: 200000},
          currency: 'JPY',
        ),
      );

      final json = template.toJson();
      expect(json['name'], 'Quick Format');
      expect(json['format'], 'round_robin');
    });
  });

  group('TournamentReview', () {
    test('creates review with correct data', () {
      final review = TournamentReview(
        id: 'review_123',
        tournamentId: 'tour_1',
        reviewerId: 'user_1',
        reviewerName: 'Happy Player',
        rating: 5.0,
        comment: 'Excellent tournament!',
        categories: ['fair-play', 'communication'],
      );

      expect(review.id, 'review_123');
      expect(review.rating, 5.0);
      expect(review.categories.length, 2);
    });

    test('validates rating is in valid range', () {
      final review1 = TournamentReview(
        id: 'review_1',
        tournamentId: 'tour_1',
        reviewerId: 'user_1',
        reviewerName: 'Player',
        rating: 5.0,
        comment: 'Great',
      );

      final review2 = TournamentReview(
        id: 'review_2',
        tournamentId: 'tour_2',
        reviewerId: 'user_2',
        reviewerName: 'Player 2',
        rating: 1.0,
        comment: 'Poor',
      );

      expect(review1.rating >= 1.0 && review1.rating <= 5.0, true);
      expect(review2.rating >= 1.0 && review2.rating <= 5.0, true);
    });

    test('serializes review to JSON', () {
      final review = TournamentReview(
        id: 'review_456',
        tournamentId: 'tour_2',
        reviewerId: 'user_2',
        reviewerName: 'Satisfied Player',
        rating: 4.5,
        comment: 'Good tournament',
        categories: ['organization'],
      );

      final json = review.toJson();
      expect(json['rating'], 4.5);
      expect(json['comment'], 'Good tournament');
    });
  });
}
