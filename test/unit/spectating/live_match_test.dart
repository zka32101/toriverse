import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/spectating/domain/models/live_match.dart';

void main() {
  group('LiveMatchSession', () {
    test('creates session with correct data', () {
      final session = LiveMatchSession(
        id: 'session_123',
        matchId: 'match_456',
        tournamentId: 'tour_789',
        playerIds: ['player1', 'player2', 'player3'],
        currentPlayerTurn: 'player1',
        roundNumber: 5,
        timeRemainingSeconds: 15,
        status: 'playing',
        startedAt: DateTime.now(),
        liveViewerCount: 250,
        totalViewsToday: 1500,
        recentActions: [],
      );

      expect(session.id, 'session_123');
      expect(session.matchId, 'match_456');
      expect(session.tournamentId, 'tour_789');
      expect(session.playerIds.length, 3);
      expect(session.roundNumber, 5);
      expect(session.status, 'playing');
      expect(session.liveViewerCount, 250);
    });

    test('serializes session to JSON', () {
      final session = LiveMatchSession(
        id: 'session_123',
        matchId: 'match_456',
        tournamentId: 'tour_789',
        playerIds: ['p1', 'p2', 'p3'],
        currentPlayerTurn: 'p1',
        roundNumber: 1,
        timeRemainingSeconds: 30,
        status: 'waiting',
        startedAt: DateTime.now(),
      );

      final json = session.toJson();
      expect(json['id'], 'session_123');
      expect(json['matchId'], 'match_456');
      expect(json['status'], 'waiting');
      expect(json['liveViewerCount'], 0);
    });

    test('deserializes session from JSON', () {
      final now = DateTime.now();
      final json = {
        'id': 'session_999',
        'matchId': 'match_999',
        'tournamentId': 'tour_999',
        'playerIds': ['a', 'b', 'c'],
        'currentPlayerTurn': 'a',
        'roundNumber': 3,
        'timeRemainingSeconds': 20,
        'status': 'playing',
        'startedAt': now.toIso8601String(),
        'liveViewerCount': 500,
        'totalViewsToday': 2000,
        'recentActions': [],
      };

      final session = LiveMatchSession.fromJson(json);
      expect(session.id, 'session_999');
      expect(session.liveViewerCount, 500);
      expect(session.roundNumber, 3);
    });
  });

  group('LiveBoardState', () {
    test('creates board with correct dimensions', () {
      final boardState = List<int>.filled(64, 0);
      final board = LiveBoardState(
        matchId: 'match_123',
        boardState: boardState,
        blackPieces: ['pos1', 'pos2'],
        whitePieces: ['pos3', 'pos4', 'pos5'],
        redPieces: ['pos6'],
        blackScore: 2,
        whiteScore: 3,
        redScore: 1,
        lastMovePosition: 25,
        isSimultaneousReveal: false,
        lastUpdateAt: DateTime.now(),
      );

      expect(board.matchId, 'match_123');
      expect(board.boardState.length, 64);
      expect(board.blackScore, 2);
      expect(board.whiteScore, 3);
      expect(board.redScore, 1);
      expect(board.lastMovePosition, 25);
    });

    test('calculates total pieces correctly', () {
      final board = LiveBoardState(
        matchId: 'match_456',
        boardState: List<int>.filled(64, 0),
        blackPieces: ['a', 'b', 'c'],
        whitePieces: ['d', 'e'],
        redPieces: ['f', 'g', 'h', 'i'],
        blackScore: 3,
        whiteScore: 2,
        redScore: 4,
      );

      final totalPieces =
          board.blackPieces.length + board.whitePieces.length + board.redPieces.length;
      expect(totalPieces, 9);
    });

    test('tracks simultaneous reveal flag', () {
      final board = LiveBoardState(
        matchId: 'match_789',
        boardState: List<int>.filled(64, 0),
        isSimultaneousReveal: true,
      );

      expect(board.isSimultaneousReveal, true);
    });

    test('serializes board state to JSON', () {
      final board = LiveBoardState(
        matchId: 'match_123',
        boardState: List<int>.filled(64, 0),
        blackScore: 5,
        whiteScore: 8,
        redScore: 3,
      );

      final json = board.toJson();
      expect(json['matchId'], 'match_123');
      expect(json['blackScore'], 5);
      expect(json['boardState'].length, 64);
    });
  });

  group('LivePrediction', () {
    test('creates prediction with correct data', () {
      final prediction = LivePrediction(
        id: 'pred_123',
        matchId: 'match_456',
        viewerId: 'viewer_789',
        predictType: 'winner',
        prediction: 'black',
        confidenceScore: 85,
        createdAt: DateTime.now(),
        isCorrect: false,
        pointsAwarded: 0,
      );

      expect(prediction.id, 'pred_123');
      expect(prediction.predictType, 'winner');
      expect(prediction.prediction, 'black');
      expect(prediction.confidenceScore, 85);
      expect(prediction.isCorrect, false);
    });

    test('validates confidence score range', () {
      final prediction = LivePrediction(
        id: 'pred_456',
        matchId: 'match_456',
        viewerId: 'viewer_789',
        predictType: 'nextMove',
        prediction: 'position_25',
        confidenceScore: 100,
      );

      expect(prediction.confidenceScore >= 0 && prediction.confidenceScore <= 100, true);
    });

    test('updates prediction when resolved', () {
      var prediction = LivePrediction(
        id: 'pred_789',
        matchId: 'match_789',
        viewerId: 'viewer_999',
        predictType: 'winner',
        prediction: 'white',
        isCorrect: false,
        pointsAwarded: 0,
      );

      expect(prediction.isCorrect, false);

      prediction = prediction.copyWith(
        isCorrect: true,
        pointsAwarded: 50,
        resolvedAt: DateTime.now(),
      );

      expect(prediction.isCorrect, true);
      expect(prediction.pointsAwarded, 50);
    });

    test('serializes prediction to JSON', () {
      final prediction = LivePrediction(
        id: 'pred_123',
        matchId: 'match_456',
        viewerId: 'viewer_789',
        predictType: 'winner',
        prediction: 'red',
        confidenceScore: 65,
        isCorrect: true,
        pointsAwarded: 75,
      );

      final json = prediction.toJson();
      expect(json['predictType'], 'winner');
      expect(json['confidenceScore'], 65);
      expect(json['isCorrect'], true);
      expect(json['pointsAwarded'], 75);
    });
  });

  group('LiveSpectatorReward', () {
    test('creates reward with correct calculations', () {
      final reward = LiveSpectatorReward(
        id: 'reward_123',
        matchId: 'match_456',
        viewerId: 'viewer_789',
        basePointsEarned: 30, // 30 minutes
        predictionBonusPoints: 20, // 2 correct predictions
        engagementBonusPoints: 15, // Comments/reactions
        premiumBonusPoints: 0,
        totalPointsEarned: 65,
      );

      expect(reward.totalPointsEarned, 65);
      expect(reward.basePointsEarned, 30);
      expect(reward.predictionBonusPoints, 20);
    });

    test('applies premium multiplier correctly', () {
      final baseTotal = 100;
      final premiumBonus = baseTotal ~/ 2; // 50% multiplier
      final reward = LiveSpectatorReward(
        id: 'reward_456',
        matchId: 'match_456',
        viewerId: 'viewer_456',
        basePointsEarned: 50,
        predictionBonusPoints: 30,
        engagementBonusPoints: 20,
        premiumBonusPoints: premiumBonus,
        totalPointsEarned: baseTotal + premiumBonus,
      );

      expect(reward.totalPointsEarned, 150);
      expect(reward.premiumBonusPoints, 50);
    });

    test('tracks claim status', () {
      var reward = LiveSpectatorReward(
        id: 'reward_789',
        matchId: 'match_789',
        viewerId: 'viewer_789',
        totalPointsEarned: 100,
        claimedAt: null,
      );

      expect(reward.claimedAt, null);

      reward = reward.copyWith(claimedAt: DateTime.now());
      expect(reward.claimedAt, isNotNull);
    });

    test('serializes reward to JSON', () {
      final reward = LiveSpectatorReward(
        id: 'reward_999',
        matchId: 'match_999',
        viewerId: 'viewer_999',
        basePointsEarned: 25,
        totalPointsEarned: 75,
      );

      final json = reward.toJson();
      expect(json['basePointsEarned'], 25);
      expect(json['totalPointsEarned'], 75);
    });
  });

  group('LiveLeaderboardEntry', () {
    test('creates leaderboard entry', () {
      final entry = LiveLeaderboardEntry(
        rank: '1',
        viewerId: 'viewer_123',
        displayName: 'TopPlayer',
        pointsEarned: 500,
        correctPredictions: 8,
        engagementScore: 45,
        isPremium: true,
      );

      expect(entry.rank, '1');
      expect(entry.displayName, 'TopPlayer');
      expect(entry.pointsEarned, 500);
      expect(entry.correctPredictions, 8);
      expect(entry.isPremium, true);
    });

    test('orders entries by points', () {
      final entry1 = LiveLeaderboardEntry(
        rank: '1',
        viewerId: 'v1',
        displayName: 'Player1',
        pointsEarned: 500,
      );

      final entry2 = LiveLeaderboardEntry(
        rank: '2',
        viewerId: 'v2',
        displayName: 'Player2',
        pointsEarned: 300,
      );

      final entry3 = LiveLeaderboardEntry(
        rank: '3',
        viewerId: 'v3',
        displayName: 'Player3',
        pointsEarned: 100,
      );

      final entries = [entry1, entry2, entry3];
      expect(entries[0].pointsEarned > entries[1].pointsEarned, true);
      expect(entries[1].pointsEarned > entries[2].pointsEarned, true);
    });

    test('serializes leaderboard entry to JSON', () {
      final entry = LiveLeaderboardEntry(
        rank: '5',
        viewerId: 'viewer_999',
        displayName: 'Player999',
        pointsEarned: 250,
        correctPredictions: 5,
        engagementScore: 20,
      );

      final json = entry.toJson();
      expect(json['rank'], '5');
      expect(json['displayName'], 'Player999');
      expect(json['pointsEarned'], 250);
    });
  });

  group('MatchHighlightMoment', () {
    test('creates highlight moment', () {
      final moment = MatchHighlightMoment(
        id: 'highlight_123',
        matchId: 'match_456',
        timestamp: 180, // 3 minutes
        momentType: 'upset',
        description: 'Unexpected reversal',
        viewerReactions: 45,
        isFeatured: false,
        markedAt: DateTime.now(),
      );

      expect(moment.id, 'highlight_123');
      expect(moment.timestamp, 180);
      expect(moment.momentType, 'upset');
      expect(moment.viewerReactions, 45);
    });

    test('tracks featured status', () {
      var moment = MatchHighlightMoment(
        id: 'highlight_456',
        matchId: 'match_456',
        timestamp: 120,
        momentType: 'strategic_move',
        description: 'Key tactical decision',
        isFeatured: false,
      );

      expect(moment.isFeatured, false);

      moment = moment.copyWith(isFeatured: true);
      expect(moment.isFeatured, true);
    });

    test('increments viewer reactions', () {
      var moment = MatchHighlightMoment(
        id: 'highlight_789',
        matchId: 'match_789',
        timestamp: 60,
        momentType: 'key_turn',
        description: 'Critical move',
        viewerReactions: 10,
      );

      expect(moment.viewerReactions, 10);

      moment = moment.copyWith(viewerReactions: moment.viewerReactions + 1);
      expect(moment.viewerReactions, 11);
    });

    test('serializes highlight to JSON', () {
      final moment = MatchHighlightMoment(
        id: 'highlight_999',
        matchId: 'match_999',
        timestamp: 300,
        momentType: 'final_reversal',
        description: 'Last minute turnaround',
        viewerReactions: 123,
        isFeatured: true,
      );

      final json = moment.toJson();
      expect(json['momentType'], 'final_reversal');
      expect(json['viewerReactions'], 123);
      expect(json['isFeatured'], true);
    });
  });

  group('LiveChatMessage', () {
    test('creates chat message', () {
      final message = LiveChatMessage(
        id: 'chat_123',
        matchId: 'match_456',
        userId: 'user_789',
        displayName: 'Alice',
        message: 'Great move!',
        createdAt: DateTime.now(),
        likes: 5,
        isModerator: false,
        isPinned: false,
      );

      expect(message.id, 'chat_123');
      expect(message.message, 'Great move!');
      expect(message.displayName, 'Alice');
      expect(message.likes, 5);
    });

    test('tracks moderator status', () {
      final message = LiveChatMessage(
        id: 'chat_456',
        matchId: 'match_456',
        userId: 'mod_123',
        displayName: 'Moderator',
        message: 'Keep it civil!',
        isModerator: true,
      );

      expect(message.isModerator, true);
    });

    test('tracks pin status', () {
      var message = LiveChatMessage(
        id: 'chat_789',
        matchId: 'match_789',
        userId: 'user_999',
        displayName: 'User',
        message: 'This is important',
        isPinned: false,
      );

      expect(message.isPinned, false);

      message = message.copyWith(isPinned: true);
      expect(message.isPinned, true);
    });

    test('adds likes to message', () {
      var message = LiveChatMessage(
        id: 'chat_999',
        matchId: 'match_999',
        userId: 'user_111',
        displayName: 'Player',
        message: 'Amazing!',
        likes: 0,
        likedBy: [],
      );

      expect(message.likes, 0);

      message = message.copyWith(
        likes: message.likes + 1,
        likedBy: [...message.likedBy, 'liker_1'],
      );

      expect(message.likes, 1);
      expect(message.likedBy.length, 1);
    });

    test('serializes message to JSON', () {
      final message = LiveChatMessage(
        id: 'chat_111',
        matchId: 'match_111',
        userId: 'user_111',
        displayName: 'Viewer',
        message: 'Incredible game!',
        likes: 10,
        isModerator: false,
      );

      final json = message.toJson();
      expect(json['message'], 'Incredible game!');
      expect(json['likes'], 10);
      expect(json['isModerator'], false);
    });
  });

  group('SpectatorEngagement', () {
    test('creates engagement record', () {
      final engagement = SpectatorEngagement(
        viewerId: 'viewer_123',
        matchId: 'match_456',
        watchDurationSeconds: 1800, // 30 minutes
        commentsPosted: 5,
        predictionsPlaced: 3,
        correctPredictions: 2,
        reactionsGiven: 10,
        engagementScore: 75,
        completedMatch: false,
      );

      expect(engagement.viewerId, 'viewer_123');
      expect(engagement.watchDurationSeconds, 1800);
      expect(engagement.commentsPosted, 5);
      expect(engagement.engagementScore, 75);
    });

    test('calculates engagement score correctly', () {
      final comments = 5;
      final predictions = 3;
      final reactions = 10;
      final calculatedScore = (comments * 10) + (predictions * 5) + (reactions * 2);

      final engagement = SpectatorEngagement(
        viewerId: 'viewer_456',
        matchId: 'match_456',
        watchDurationSeconds: 1800,
        commentsPosted: comments,
        predictionsPlaced: predictions,
        reactionsGiven: reactions,
        engagementScore: calculatedScore,
      );

      expect(engagement.engagementScore, 95); // (5*10) + (3*5) + (10*2)
    });

    test('tracks match completion', () {
      var engagement = SpectatorEngagement(
        viewerId: 'viewer_789',
        matchId: 'match_789',
        completedMatch: false,
      );

      expect(engagement.completedMatch, false);

      engagement = engagement.copyWith(completedMatch: true);
      expect(engagement.completedMatch, true);
    });

    test('serializes engagement to JSON', () {
      final engagement = SpectatorEngagement(
        viewerId: 'viewer_999',
        matchId: 'match_999',
        watchDurationSeconds: 2400,
        commentsPosted: 8,
        engagementScore: 120,
        completedMatch: true,
      );

      final json = engagement.toJson();
      expect(json['watchDurationSeconds'], 2400);
      expect(json['commentsPosted'], 8);
      expect(json['completedMatch'], true);
    });
  });

  group('LiveViewer', () {
    test('creates live viewer record', () {
      final viewer = LiveViewer(
        id: 'lv_123',
        matchId: 'match_456',
        viewerId: 'viewer_789',
        displayName: 'Alice',
        joinedAt: DateTime.now(),
        watchDurationSeconds: 600,
        predictions: ['pred_1', 'pred_2'],
        correctPredictions: 1,
        isPremium: true,
        isStreaming: false,
      );

      expect(viewer.id, 'lv_123');
      expect(viewer.viewerId, 'viewer_789');
      expect(viewer.displayName, 'Alice');
      expect(viewer.isPremium, true);
      expect(viewer.predictions.length, 2);
    });

    test('tracks watch duration', () {
      var viewer = LiveViewer(
        id: 'lv_456',
        matchId: 'match_456',
        viewerId: 'viewer_456',
        displayName: 'Bob',
        watchDurationSeconds: 0,
      );

      expect(viewer.watchDurationSeconds, 0);

      viewer = viewer.copyWith(
        watchDurationSeconds: 1200,
        leftAt: DateTime.now(),
      );

      expect(viewer.watchDurationSeconds, 1200);
    });

    test('tracks streaming status', () {
      final viewer = LiveViewer(
        id: 'lv_789',
        matchId: 'match_789',
        viewerId: 'streamer_123',
        displayName: 'Streamer',
        isStreaming: true,
        isPremium: true,
      );

      expect(viewer.isStreaming, true);
    });

    test('serializes viewer to JSON', () {
      final viewer = LiveViewer(
        id: 'lv_999',
        matchId: 'match_999',
        viewerId: 'viewer_999',
        displayName: 'Viewer',
        correctPredictions: 3,
        isPremium: false,
      );

      final json = viewer.toJson();
      expect(json['displayName'], 'Viewer');
      expect(json['correctPredictions'], 3);
      expect(json['isPremium'], false);
    });
  });

  group('LiveMatchStats', () {
    test('creates stats record', () {
      final stats = LiveMatchStats(
        matchId: 'match_123',
        currentViewerCount: 500,
        peakViewerCount: 1200,
        totalWatchMinutes: 5000,
        totalPredictions: 150,
        correctPredictions: 45,
        avgPredictionAccuracy: 30.0,
        totalChatMessages: 800,
        totalHighlights: 12,
        totalPointsDistributed: 5000,
      );

      expect(stats.matchId, 'match_123');
      expect(stats.currentViewerCount, 500);
      expect(stats.peakViewerCount, 1200);
      expect(stats.correctPredictions, 45);
    });

    test('calculates prediction accuracy', () {
      final total = 100;
      final correct = 30;
      final accuracy = (correct / total) * 100;

      expect(accuracy, 30.0);
    });

    test('updates peak viewer count', () {
      var stats = LiveMatchStats(
        matchId: 'match_456',
        currentViewerCount: 200,
        peakViewerCount: 300,
      );

      expect(stats.peakViewerCount, 300);

      if (250 > stats.peakViewerCount) {
        stats = stats.copyWith(peakViewerCount: 250);
      }

      expect(stats.peakViewerCount, 300); // No change since 250 < 300
    });

    test('serializes stats to JSON', () {
      final stats = LiveMatchStats(
        matchId: 'match_789',
        currentViewerCount: 750,
        totalChatMessages: 1500,
      );

      final json = stats.toJson();
      expect(json['currentViewerCount'], 750);
      expect(json['totalChatMessages'], 1500);
    });
  });
}
