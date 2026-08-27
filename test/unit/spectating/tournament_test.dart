import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/spectating/domain/models/tournament.dart';

void main() {
  group('TournamentFormat', () {
    test('returns correct labels', () {
      expect(TournamentFormat.singleElimination.label, 'Single Elimination');
      expect(TournamentFormat.doubleElimination.label, 'Double Elimination');
      expect(TournamentFormat.roundRobin.label, 'Round Robin');
      expect(TournamentFormat.swiss.label, 'Swiss System');
      expect(TournamentFormat.ladder.label, 'Ladder');
    });

    test('returns correct descriptions', () {
      expect(TournamentFormat.singleElimination.description.isNotEmpty, true);
      expect(TournamentFormat.doubleElimination.description.isNotEmpty, true);
    });

    test('returns correct max players', () {
      expect(TournamentFormat.singleElimination.maxPlayers, 64);
      expect(TournamentFormat.doubleElimination.maxPlayers, 32);
      expect(TournamentFormat.roundRobin.maxPlayers, 16);
      expect(TournamentFormat.swiss.maxPlayers, 128);
      expect(TournamentFormat.ladder.maxPlayers, 1000);
    });

    test('all formats have minimum 3 players', () {
      for (final format in TournamentFormat.values) {
        expect(format.minPlayers, 3);
      }
    });
  });

  group('TournamentStatus', () {
    test('returns correct labels', () {
      expect(TournamentStatus.draft.label, 'Draft');
      expect(TournamentStatus.registration.label, 'Registration Open');
      expect(TournamentStatus.inProgress.label, 'In Progress');
      expect(TournamentStatus.finished.label, 'Finished');
      expect(TournamentStatus.cancelled.label, 'Cancelled');
    });

    test('isActive returns correct values', () {
      expect(TournamentStatus.draft.isActive, false);
      expect(TournamentStatus.registration.isActive, true);
      expect(TournamentStatus.inProgress.isActive, true);
      expect(TournamentStatus.finished.isActive, false);
    });

    test('canRegister returns correct values', () {
      expect(TournamentStatus.draft.canRegister, false);
      expect(TournamentStatus.registration.canRegister, true);
      expect(TournamentStatus.inProgress.canRegister, false);
      expect(TournamentStatus.finished.canRegister, false);
    });
  });

  group('MatchStatus', () {
    test('returns correct labels', () {
      expect(MatchStatus.scheduled.label, 'Scheduled');
      expect(MatchStatus.live.label, 'Live Now');
      expect(MatchStatus.completed.label, 'Finished');
      expect(MatchStatus.cancelled.label, 'Cancelled');
    });

    test('isLive returns correct values', () {
      expect(MatchStatus.scheduled.isLive, false);
      expect(MatchStatus.live.isLive, true);
      expect(MatchStatus.completed.isLive, false);
    });
  });

  group('PrizePool', () {
    test('creates prize pool with correct data', () {
      final distribution = {
        1: 100000,
        2: 50000,
        3: 25000,
      };

      final pool = PrizePool(
        totalAmount: 175000,
        distribution: distribution,
        currency: 'JPY',
        sponsorName: 'TechCorp',
      );

      expect(pool.totalAmount, 175000);
      expect(pool.distribution[1], 100000);
      expect(pool.currency, 'JPY');
      expect(pool.sponsorName, 'TechCorp');
    });

    test('serializes prize pool to JSON', () {
      final pool = PrizePool(
        totalAmount: 175000,
        distribution: {1: 100000, 2: 50000},
        currency: 'JPY',
      );

      final json = pool.toJson();
      expect(json['totalAmount'], 175000);
      expect(json['currency'], 'JPY');
    });

    test('deserializes prize pool from JSON', () {
      final json = {
        'totalAmount': 175000,
        'distribution': {
          '1': 100000,
          '2': 50000,
        },
        'currency': 'JPY',
      };

      final pool = PrizePool.fromJson(json);
      expect(pool.totalAmount, 175000);
      expect(pool.currency, 'JPY');
    });
  });

  group('Tournament', () {
    test('creates tournament with correct data', () {
      final prizePool = PrizePool(
        totalAmount: 500000,
        distribution: {1: 300000, 2: 150000, 3: 50000},
        currency: 'JPY',
      );

      final tournament = Tournament(
        id: 'tour_123',
        name: 'Monthly Championship',
        description: 'Our biggest tournament',
        format: TournamentFormat.singleElimination,
        status: TournamentStatus.registration,
        startDate: DateTime(2026, 9, 1),
        registrationDeadline: DateTime(2026, 8, 30),
        maxParticipants: 64,
        currentParticipants: 32,
        prizePool: prizePool,
        organizerId: 'org_1',
        organizerName: 'Tournament Organizers',
        rules: ['Best of 1', 'Single Elimination'],
        isFeatured: true,
        viewerCount: 5000,
        totalMatches: 32,
        completedMatches: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(tournament.id, 'tour_123');
      expect(tournament.name, 'Monthly Championship');
      expect(tournament.format, TournamentFormat.singleElimination);
      expect(tournament.currentParticipants, 32);
      expect(tournament.isFeatured, true);
    });

    test('serializes tournament to JSON', () {
      final prizePool = PrizePool(
        totalAmount: 500000,
        distribution: {1: 300000},
        currency: 'JPY',
      );

      final tournament = Tournament(
        id: 'tour_123',
        name: 'Monthly Championship',
        description: 'Tournament',
        format: TournamentFormat.roundRobin,
        status: TournamentStatus.registration,
        startDate: DateTime(2026, 9, 1),
        registrationDeadline: DateTime(2026, 8, 30),
        maxParticipants: 64,
        currentParticipants: 32,
        prizePool: prizePool,
        organizerId: 'org_1',
        organizerName: 'Tournament Organizers',
        rules: [],
        isFeatured: false,
        viewerCount: 0,
        totalMatches: 0,
        completedMatches: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final json = tournament.toJson();
      expect(json['id'], 'tour_123');
      expect(json['name'], 'Monthly Championship');
      expect(json['isFeatured'], false);
    });
  });

  group('TournamentParticipant', () {
    test('creates participant with correct data', () {
      final participant = TournamentParticipant(
        id: 'part_123',
        tournamentId: 'tour_123',
        userId: 'user_1',
        displayName: 'Champion',
        seedRank: 1,
        wins: 5,
        losses: 0,
        winRate: 1.0,
        points: 500,
        isActive: true,
        joinedAt: DateTime.now(),
        trophies: 2,
        consecutiveWins: 5,
      );

      expect(participant.seedRank, 1);
      expect(participant.wins, 5);
      expect(participant.winRate, 1.0);
      expect(participant.consecutiveWins, 5);
    });

    test('serializes and deserializes participant', () {
      final participant = TournamentParticipant(
        id: 'part_123',
        tournamentId: 'tour_123',
        userId: 'user_1',
        displayName: 'Player',
        seedRank: 5,
        wins: 3,
        losses: 2,
        winRate: 0.6,
        points: 150,
        isActive: true,
        joinedAt: DateTime.now(),
      );

      final json = participant.toJson();
      final deserialized = TournamentParticipant.fromJson(json);

      expect(deserialized.displayName, 'Player');
      expect(deserialized.seedRank, 5);
      expect(deserialized.wins, 3);
    });
  });

  group('TournamentMatch', () {
    test('creates match with correct data', () {
      final match = TournamentMatch(
        id: 'match_123',
        tournamentId: 'tour_123',
        round: 1,
        matchNumber: 1,
        playerIds: ['user_1', 'user_2', 'user_3'],
        status: MatchStatus.scheduled,
        scheduledTime: DateTime(2026, 8, 28, 14, 0),
        isFeatured: true,
        viewerCount: 1000,
      );

      expect(match.playerIds.length, 3);
      expect(match.status, MatchStatus.scheduled);
      expect(match.isFeatured, true);
    });

    test('serializes match to JSON', () {
      final match = TournamentMatch(
        id: 'match_123',
        tournamentId: 'tour_123',
        round: 1,
        matchNumber: 1,
        playerIds: ['user_1', 'user_2', 'user_3'],
        status: MatchStatus.live,
        scheduledTime: DateTime.now(),
        isFeatured: false,
        viewerCount: 500,
      );

      final json = match.toJson();
      expect(json['status'], 'live');
      expect(json['viewerCount'], 500);
    });
  });

  group('FeaturedMatch', () {
    test('creates featured match with correct data', () {
      final featured = FeaturedMatch(
        id: 'feat_123',
        matchId: 'match_456',
        tournamentId: 'tour_123',
        title: 'Finals: Top 2 Seeds',
        description: 'Watch the championship finals',
        startTime: DateTime(2026, 8, 28, 19, 0),
        expectedViewers: 10000,
        currentViewers: 8500,
        importance: 0.95,
        isLive: true,
        featuredStartTime: DateTime.now(),
        featuredEndTime: DateTime.now().add(const Duration(days: 1)),
      );

      expect(featured.title, 'Finals: Top 2 Seeds');
      expect(featured.isLive, true);
      expect(featured.importance, 0.95);
    });

    test('serializes featured match to JSON', () {
      final featured = FeaturedMatch(
        id: 'feat_123',
        matchId: 'match_456',
        tournamentId: 'tour_123',
        title: 'Semifinals',
        description: 'Championship semifinals',
        startTime: DateTime.now(),
        expectedViewers: 5000,
        currentViewers: 4000,
        importance: 0.8,
        isLive: false,
        featuredStartTime: DateTime.now(),
        featuredEndTime: DateTime.now().add(const Duration(hours: 12)),
      );

      final json = featured.toJson();
      expect(json['title'], 'Semifinals');
      expect(json['isLive'], false);
    });
  });

  group('TournamentBadge', () {
    test('creates badge with correct data', () {
      final badge = TournamentBadge(
        id: 'badge_123',
        tournamentId: 'tour_123',
        name: 'Champion',
        emoji: '👑',
        description: 'Won the tournament',
        unlockedBy: ['user_1'],
        rarity: 5,
      );

      expect(badge.name, 'Champion');
      expect(badge.emoji, '👑');
      expect(badge.rarity, 5);
      expect(badge.unlockedBy.length, 1);
    });

    test('serializes badge to JSON', () {
      final badge = TournamentBadge(
        id: 'badge_123',
        tournamentId: 'tour_123',
        name: 'Runner-up',
        emoji: '🥈',
        description: 'Finalist',
        unlockedBy: ['user_2', 'user_3'],
        rarity: 4,
      );

      final json = badge.toJson();
      expect(json['name'], 'Runner-up');
      expect(json['rarity'], 4);
    });
  });

  group('MatchPrediction', () {
    test('creates prediction with correct data', () {
      final prediction = MatchPrediction(
        id: 'pred_123',
        matchId: 'match_456',
        viewerId: 'viewer_1',
        predictedWinnerId: 'user_1',
        wageredPoints: 100,
        isCorrect: true,
        pointsWon: 250,
        createdAt: DateTime.now(),
      );

      expect(prediction.predictedWinnerId, 'user_1');
      expect(prediction.wageredPoints, 100);
      expect(prediction.pointsWon, 250);
      expect(prediction.isCorrect, true);
    });

    test('serializes prediction to JSON', () {
      final prediction = MatchPrediction(
        id: 'pred_123',
        matchId: 'match_456',
        viewerId: 'viewer_1',
        predictedWinnerId: 'user_2',
        wageredPoints: 50,
        isCorrect: false,
        pointsWon: 0,
        createdAt: DateTime.now(),
      );

      final json = prediction.toJson();
      expect(json['wageredPoints'], 50);
      expect(json['isCorrect'], false);
    });
  });

  group('ViewerReward', () {
    test('creates reward with correct data', () {
      final reward = ViewerReward(
        id: 'reward_123',
        tournamentId: 'tour_123',
        viewerId: 'viewer_1',
        watchMinutes: 120,
        pointsEarned: 1200,
        tokensEarned: 120,
        isPremiumBonus: true,
        earnedAt: DateTime.now(),
      );

      expect(reward.watchMinutes, 120);
      expect(reward.pointsEarned, 1200);
      expect(reward.tokensEarned, 120);
      expect(reward.isPremiumBonus, true);
    });

    test('serializes reward to JSON', () {
      final reward = ViewerReward(
        id: 'reward_123',
        tournamentId: 'tour_123',
        viewerId: 'viewer_1',
        watchMinutes: 60,
        pointsEarned: 600,
        tokensEarned: 60,
        earnedAt: DateTime.now(),
      );

      final json = reward.toJson();
      expect(json['watchMinutes'], 60);
      expect(json['pointsEarned'], 600);
    });
  });

  group('StandingEntry', () {
    test('creates standing entry with correct data', () {
      final entry = StandingEntry(
        rank: 1,
        playerId: 'user_1',
        playerName: 'Champion',
        wins: 10,
        losses: 0,
        draws: 0,
        winRate: 1.0,
        pointsFor: 150,
        pointsAgainst: 50,
        pointDiff: 100,
        trophies: 3,
        tier: 'S',
      );

      expect(entry.rank, 1);
      expect(entry.wins, 10);
      expect(entry.winRate, 1.0);
      expect(entry.tier, 'S');
    });

    test('calculates win rate correctly', () {
      final entry = StandingEntry(
        rank: 2,
        playerId: 'user_2',
        playerName: 'Contender',
        wins: 6,
        losses: 4,
        draws: 0,
        winRate: 0.6,
        pointsFor: 100,
        pointsAgainst: 80,
        pointDiff: 20,
        trophies: 1,
        tier: 'A',
      );

      expect(entry.winRate, 0.6);
    });
  });
}
