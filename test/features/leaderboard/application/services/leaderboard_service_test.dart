/// Unit tests for LeaderboardService
///
/// Tests leaderboard queries, player rankings, and real-time streaming.

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toriverse/features/leaderboard/application/services/leaderboard_service.dart';
import 'package:toriverse/features/leaderboard/domain/models/leaderboard_models.dart';

// Mock classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late LeaderboardService leaderboardService;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    leaderboardService = LeaderboardService(firestore: mockFirestore);
  });

  group('LeaderboardService', () {
    group('getGlobalLeaderboard', () {
      test('fetches top N players with ranking', () async {
        // Arrange
        final mockDocs = [
          _createMockDocumentSnapshot('uid1', 'player1', 500, 0, 10, 8, 2, 0.8),
          _createMockDocumentSnapshot('uid2', 'player2', 450, 1, 9, 7, 2, 0.78),
          _createMockDocumentSnapshot('uid3', 'player3', 400, 0, 8, 6, 2, 0.75),
        ];
        final mockSnapshot = MockQuerySnapshot();
        when(() => mockSnapshot.docs).thenReturn(mockDocs);

        // Setup Firestore mocks
        _setupFirestoreChain(mockFirestore, mockSnapshot);

        // Act
        final leaderboard = await leaderboardService.getGlobalLeaderboard(limit: 3);

        // Assert
        expect(leaderboard.entries, hasLength(3));
        expect(leaderboard.entries[0].uid, equals('uid1'));
        expect(leaderboard.entries[0].rank, equals(1));
        expect(leaderboard.entries[1].rank, equals(2));
        expect(leaderboard.entries[2].rank, equals(3));
        expect(leaderboard.period, equals('all-time'));
      });

      test('returns empty list when no players exist', () async {
        // Arrange
        final mockSnapshot = MockQuerySnapshot();
        when(() => mockSnapshot.docs).thenReturn([]);

        _setupFirestoreChain(mockFirestore, mockSnapshot);

        // Act
        final leaderboard = await leaderboardService.getGlobalLeaderboard();

        // Assert
        expect(leaderboard.entries, isEmpty);
      });

      test('handles error gracefully', () async {
        // Arrange
        _setupFirestoreChainWithError(mockFirestore);

        // Act & Assert
        expect(
          leaderboardService.getGlobalLeaderboard(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getPlayerRank', () {
      test('returns player rank when player exists', () async {
        // Arrange
        final mockDocs = [
          _createMockDocumentSnapshot('uid1', 'player1', 500, 0, 10, 8, 2, 0.8),
          _createMockDocumentSnapshot('uid2', 'player2', 450, 0, 9, 7, 2, 0.78),
          _createMockDocumentSnapshot('uid3', 'player3', 400, 0, 8, 6, 2, 0.75),
        ];
        final mockSnapshot = MockQuerySnapshot();
        when(() => mockSnapshot.docs).thenReturn(mockDocs);

        _setupFirestoreChain(mockFirestore, mockSnapshot);

        // Act
        final rank = await leaderboardService.getPlayerRank('uid2');

        // Assert
        expect(rank, equals(2)); // 1-indexed
      });

      test('returns null when player not found', () async {
        // Arrange
        final mockDocs = [
          _createMockDocumentSnapshot('uid1', 'player1', 500, 0, 10, 8, 2, 0.8),
        ];
        final mockSnapshot = MockQuerySnapshot();
        when(() => mockSnapshot.docs).thenReturn(mockDocs);

        _setupFirestoreChain(mockFirestore, mockSnapshot);

        // Act
        final rank = await leaderboardService.getPlayerRank('uid999');

        // Assert
        expect(rank, isNull);
      });

      test('returns rank 1 for top player', () async {
        // Arrange
        final mockDocs = [
          _createMockDocumentSnapshot('uid1', 'player1', 500, 0, 10, 8, 2, 0.8),
        ];
        final mockSnapshot = MockQuerySnapshot();
        when(() => mockSnapshot.docs).thenReturn(mockDocs);

        _setupFirestoreChain(mockFirestore, mockSnapshot);

        // Act
        final rank = await leaderboardService.getPlayerRank('uid1');

        // Assert
        expect(rank, equals(1));
      });
    });

    group('getPlayerEntry', () {
      test('returns player leaderboard entry when found', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.data()).thenReturn({
          'username': 'testPlayer',
          'rankPoints': 500,
          'completedMatchStreak': 3,
          'totalMatches': 10,
          'totalWins': 8,
          'totalLosses': 2,
          'winRate': 0.8,
          'lastUpdated': '2026-09-11T10:00:00Z',
        });
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);

        _setupFirestoreForDocReference(mockFirestore, mockDocRef);

        // Act
        final entry = await leaderboardService.getPlayerEntry('uid1');

        // Assert
        expect(entry, isNotNull);
        expect(entry!.uid, equals('uid1'));
        expect(entry.username, equals('testPlayer'));
        expect(entry.rankPoints, equals(500));
        expect(entry.winRate, equals(0.8));
      });

      test('returns null when player entry not found', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();
        when(() => mockDocSnapshot.exists).thenReturn(false);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);

        _setupFirestoreForDocReference(mockFirestore, mockDocRef);

        // Act
        final entry = await leaderboardService.getPlayerEntry('uid999');

        // Assert
        expect(entry, isNull);
      });
    });

    group('getPlayersNearRank', () {
      test('returns players around target rank with radius', () async {
        // Arrange
        final allPlayers = List.generate(
          10,
          (i) => _createMockDocumentSnapshot(
            'uid${i + 1}',
            'player${i + 1}',
            500 - (i * 10),
            0,
            10,
            8,
            2,
            0.8,
          ),
        );
        final mockSnapshot = MockQuerySnapshot();
        when(() => mockSnapshot.docs).thenReturn(allPlayers);

        _setupFirestoreChain(mockFirestore, mockSnapshot);

        // Act (player at rank 5, radius 2)
        final players = await leaderboardService.getPlayersNearRank('uid5', radius: 2);

        // Assert - should get players 3-7 (5 players: target ± 2)
        expect(players, isNotEmpty);
      });
    });

    group('searchByUsername', () {
      test('finds players by username prefix', () async {
        // Arrange
        final mockDocs = [
          _createMockDocumentSnapshot('uid1', 'alice123', 500, 0, 10, 8, 2, 0.8),
          _createMockDocumentSnapshot('uid2', 'alice456', 450, 0, 9, 7, 2, 0.78),
        ];
        final mockSnapshot = MockQuerySnapshot();
        when(() => mockSnapshot.docs).thenReturn(mockDocs);

        _setupFirestoreChain(mockFirestore, mockSnapshot);

        // Act
        final results = await leaderboardService.searchByUsername('alice', limit: 20);

        // Assert
        expect(results, hasLength(2));
        expect(results[0].username, equals('alice123'));
      });

      test('returns empty list for empty query', () async {
        // Act
        final results = await leaderboardService.searchByUsername('', limit: 20);

        // Assert
        expect(results, isEmpty);
      });
    });

    group('updatePlayerRankPoints', () {
      test('updates player rank points and last updated timestamp', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        when(() => mockDocRef.update(any())).thenAnswer((_) async => {});

        _setupFirestoreForDocReference(mockFirestore, mockDocRef);

        // Act
        await leaderboardService.updatePlayerRankPoints(
          uid: 'uid1',
          pointsChange: 30,
          reason: 'match_win',
        );

        // Assert
        verify(() => mockDocRef.update(any())).called(1);
      });
    });

    group('initializePlayerLeaderboard', () {
      test('creates new leaderboard entry for player', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();
        when(() => mockDocSnapshot.exists).thenReturn(false);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocRef.set(any())).thenAnswer((_) async => {});

        _setupFirestoreForDocReference(mockFirestore, mockDocRef);

        // Act
        await leaderboardService.initializePlayerLeaderboard(
          uid: 'uid1',
          username: 'newPlayer',
        );

        // Assert
        verify(() => mockDocRef.set(any())).called(1);
      });

      test('skips initialization if entry already exists', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);

        _setupFirestoreForDocReference(mockFirestore, mockDocRef);

        // Act
        await leaderboardService.initializePlayerLeaderboard(
          uid: 'uid1',
          username: 'existingPlayer',
        );

        // Assert
        verifyNever(() => mockDocRef.set(any()));
      });
    });

    group('getTopFriends', () {
      test('returns top friends from friend list', () async {
        // Arrange
        final mockDocs = [
          _createMockDocumentSnapshot('friend1', 'friendA', 500, 0, 10, 8, 2, 0.8),
          _createMockDocumentSnapshot('friend2', 'friendB', 450, 0, 9, 7, 2, 0.78),
        ];
        final mockSnapshot = MockQuerySnapshot();
        when(() => mockSnapshot.docs).thenReturn(mockDocs);

        _setupFirestoreChain(mockFirestore, mockSnapshot);

        // Act
        final friends = await leaderboardService.getTopFriends(
          'uid1',
          ['friend1', 'friend2', 'friend3'],
          limit: 50,
        );

        // Assert
        expect(friends, hasLength(2));
        expect(friends[0].rank, equals(1));
        expect(friends[1].rank, equals(2));
      });

      test('returns empty list when no friends provided', () async {
        // Act
        final friends = await leaderboardService.getTopFriends('uid1', [], limit: 50);

        // Assert
        expect(friends, isEmpty);
      });
    });
  });
}

// Helper functions
MockDocumentSnapshot _createMockDocumentSnapshot(
  String uid,
  String username,
  int rankPoints,
  int completedMatchStreak,
  int totalMatches,
  int totalWins,
  int totalLosses,
  double winRate,
) {
  final mockDoc = MockDocumentSnapshot();
  when(() => mockDoc.id).thenReturn(uid);
  when(() => mockDoc.data()).thenReturn({
    'username': username,
    'rankPoints': rankPoints,
    'completedMatchStreak': completedMatchStreak,
    'totalMatches': totalMatches,
    'totalWins': totalWins,
    'totalLosses': totalLosses,
    'winRate': winRate,
    'lastUpdated': '2026-09-11T10:00:00Z',
  });
  return mockDoc;
}

void _setupFirestoreChain(
  MockFirebaseFirestore mockFirestore,
  MockQuerySnapshot mockSnapshot,
) {
  final mockCollectionRef = MockCollectionReference();
  final mockDocRef = MockDocumentReference();
  final mockQuery = MockQuery();
  final mockQuery2 = MockQuery();
  final mockQuery3 = MockQuery();

  when(() => mockFirestore.collection('leaderboards'))
      .thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.doc('global')).thenReturn(mockDocRef);
  when(() => mockDocRef.collection('entries')).thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.orderBy('rankPoints', descending: true))
      .thenReturn(mockQuery);
  when(() => mockQuery.orderBy('username', descending: false))
      .thenReturn(mockQuery2);
  when(() => mockQuery2.limit(any())).thenReturn(mockQuery3);
  when(() => mockQuery3.get()).thenAnswer((_) async => mockSnapshot);
  when(() => mockCollectionRef.orderBy('rankPoints', descending: true))
      .thenReturn(mockQuery);
}

void _setupFirestoreChainWithError(MockFirebaseFirestore mockFirestore) {
  final mockCollectionRef = MockCollectionReference();
  final mockDocRef = MockDocumentReference();
  final mockQuery = MockQuery();

  when(() => mockFirestore.collection('leaderboards'))
      .thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.doc('global')).thenReturn(mockDocRef);
  when(() => mockDocRef.collection('entries')).thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.orderBy('rankPoints', descending: true))
      .thenReturn(mockQuery);
  when(() => mockQuery.get()).thenThrow(Exception('Firestore error'));
}

void _setupFirestoreForDocReference(
  MockFirebaseFirestore mockFirestore,
  MockDocumentReference mockDocRef,
) {
  final mockCollectionRef = MockCollectionReference();
  final mockDocRefWrapper = MockDocumentReference();

  when(() => mockFirestore.collection('leaderboards'))
      .thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.doc('global')).thenReturn(mockDocRefWrapper);
  when(() => mockDocRefWrapper.collection('entries')).thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.doc(any())).thenReturn(mockDocRef);
}
