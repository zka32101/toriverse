/// Unit tests for SocialMatchService
///
/// Tests ranked/casual matches, rank point integration, and friend challenges.

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toriverse/features/social/application/services/social_match_service.dart';
import 'package:toriverse/features/leaderboard/application/services/rank_calculation_service.dart';
import 'package:toriverse/features/leaderboard/domain/models/leaderboard_models.dart';

// Mock classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class MockWriteBatch extends Mock implements WriteBatch {}

class MockRankCalculationService extends Mock
    implements RankCalculationService {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockRankCalculationService mockRankService;
  late SocialMatchService socialMatchService;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockRankService = MockRankCalculationService();
    socialMatchService = SocialMatchService(
      firestore: mockFirestore,
      rankCalculationService: mockRankService,
    );
  });

  group('SocialMatchService', () {
    group('createMatch', () {
      test('creates new ranked match with 3 players', () async {
        // Arrange
        _setupCreateMatch(mockFirestore);

        when(() => mockRankService.calculateMatchPoints(
              placements: any(named: 'placements'),
              matchType: any(named: 'matchType'),
            )).thenReturn({'uid1': 0, 'uid2': 0, 'uid3': 0});

        // Act
        final matchId = await socialMatchService.createMatch(
          matchType: MatchType.ranked,
          playerUids: ['uid1', 'uid2', 'uid3'],
        );

        // Assert
        expect(matchId, isNotEmpty);
      });

      test('throws error for non-3-player match', () async {
        // Act & Assert
        expect(
          socialMatchService.createMatch(
            matchType: MatchType.ranked,
            playerUids: ['uid1', 'uid2'],
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('creates casual match without rank impact', () async {
        // Arrange
        _setupCreateMatch(mockFirestore);

        // Act
        final matchId = await socialMatchService.createMatch(
          matchType: MatchType.casual,
          playerUids: ['uid1', 'uid2', 'uid3'],
        );

        // Assert
        expect(matchId, isNotEmpty);
      });
    });

    group('completeMatch', () {
      test('completes match and calculates rank points', () async {
        // Arrange
        final placement = ['uid1', 'uid2', 'uid3'];
        _setupCompleteMatch(mockFirestore);

        when(() => mockRankService.calculateMatchPoints(
              placements: placement,
              matchType: 'ranked',
            )).thenReturn({'uid1': 30, 'uid2': 10, 'uid3': -5});

        when(() => mockRankService.validateMatchPoints(
              placement,
              any(),
            )).thenReturn(true);

        // Act
        await socialMatchService.completeMatch(
          matchId: 'match1',
          finalPlacement: placement,
          matchType: MatchType.ranked,
        );

        // Assert
        verify(() => mockRankService.calculateMatchPoints(
              placements: placement,
              matchType: 'ranked',
            )).called(1);
      });

      test('throws error for invalid placement', () async {
        // Act & Assert
        expect(
          socialMatchService.completeMatch(
            matchId: 'match1',
            finalPlacement: ['uid1', 'uid2'],
            matchType: MatchType.ranked,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('applyRankPoints', () {
      test('updates player rank points in leaderboard', () async {
        // Arrange
        final mockBatch = MockWriteBatch();
        when(() => mockFirestore.batch()).thenReturn(mockBatch);
        when(() => mockBatch.update(any(), any())).thenReturn(() {});
        when(() => mockBatch.commit()).thenAnswer((_) async => []);

        _setupBatchUpdate(mockFirestore, mockBatch);

        // Act
        await socialMatchService.applyRankPoints(
          matchId: 'match1',
          rankPointsAwarded: {'uid1': 30, 'uid2': 10, 'uid3': -5},
        );

        // Assert
        verify(() => mockBatch.update(any(), any())).called(3);
        verify(() => mockBatch.commit()).called(1);
      });

      test('skips players with zero points', () async {
        // Arrange
        final mockBatch = MockWriteBatch();
        when(() => mockFirestore.batch()).thenReturn(mockBatch);
        when(() => mockBatch.update(any(), any())).thenReturn(() {});
        when(() => mockBatch.commit()).thenAnswer((_) async => []);

        _setupBatchUpdate(mockFirestore, mockBatch);

        // Act
        await socialMatchService.applyRankPoints(
          matchId: 'match1',
          rankPointsAwarded: {'uid1': 30, 'uid2': 0, 'uid3': -5},
        );

        // Assert - Should only update uid1 and uid3 (skip uid2 with 0)
        verify(() => mockBatch.update(any(), any())).called(2);
      });
    });

    group('getMatch', () {
      test('retrieves match details', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();
        when(() => mockSnapshot.exists).thenReturn(true);
        when(() => mockSnapshot.data()).thenReturn({
          'matchType': 'MatchType.ranked',
          'players': ['uid1', 'uid2', 'uid3'],
          'finalPlacement': [0, 1, 2],
          'rankPointsAwarded': {'uid1': 30, 'uid2': 10, 'uid3': -5},
          'rankChangeApplied': true,
          'createdAt': DateTime.now().toIso8601String(),
          'completedAt': DateTime.now().toIso8601String(),
        });
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);

        _setupGetMatch(mockFirestore, mockDocRef);

        // Act
        final match = await socialMatchService.getMatch('match1');

        // Assert
        expect(match, isNotNull);
        expect(match!.id, equals('match1'));
        expect(match.players, hasLength(3));
      });

      test('returns null when match not found', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();
        when(() => mockSnapshot.exists).thenReturn(false);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);

        _setupGetMatch(mockFirestore, mockDocRef);

        // Act
        final match = await socialMatchService.getMatch('match999');

        // Assert
        expect(match, isNull);
      });
    });

    group('SocialMatch', () {
      test('getUserPlacement returns correct placement', () async {
        // Arrange
        final match = SocialMatch(
          id: 'match1',
          matchType: MatchType.ranked,
          players: ['uid1', 'uid2', 'uid3'],
          finalPlacement: [0, 2, 1], // uid1 1st, uid3 2nd, uid2 3rd
          rankPointsAwarded: {'uid1': 30, 'uid2': -5, 'uid3': 10},
          createdAt: DateTime.now(),
        );

        // Act & Assert
        expect(match.getUserPlacement('uid1'), equals(1));
        expect(match.getUserPlacement('uid3'), equals(2));
        expect(match.getUserPlacement('uid2'), equals(3));
        expect(match.getUserPlacement('uid999'), isNull);
      });

      test('getPointsForUid returns correct points', () async {
        // Arrange
        final match = SocialMatch(
          id: 'match1',
          matchType: MatchType.ranked,
          players: ['uid1', 'uid2', 'uid3'],
          finalPlacement: [0, 1, 2],
          rankPointsAwarded: {'uid1': 30, 'uid2': 10, 'uid3': -5},
          createdAt: DateTime.now(),
        );

        // Act & Assert
        expect(match.getPointsForUid('uid1'), equals(30));
        expect(match.getPointsForUid('uid2'), equals(10));
        expect(match.getPointsForUid('uid3'), equals(-5));
        expect(match.getPointsForUid('uid999'), equals(0));
      });

      test('didUserParticipate checks participation', () async {
        // Arrange
        final match = SocialMatch(
          id: 'match1',
          matchType: MatchType.ranked,
          players: ['uid1', 'uid2', 'uid3'],
          finalPlacement: [0, 1, 2],
          rankPointsAwarded: {'uid1': 30, 'uid2': 10, 'uid3': -5},
          createdAt: DateTime.now(),
        );

        // Act & Assert
        expect(match.didUserParticipate('uid1'), isTrue);
        expect(match.didUserParticipate('uid2'), isTrue);
        expect(match.didUserParticipate('uid3'), isTrue);
        expect(match.didUserParticipate('uid999'), isFalse);
      });

      test('matches with AI player', () async {
        // Arrange
        final match = SocialMatch(
          id: 'match1',
          matchType: MatchType.casual,
          players: ['uid1', 'uid2', 'AI'],
          finalPlacement: [0, 1, 2],
          rankPointsAwarded: {'uid1': 0, 'uid2': 0, 'AI': 0},
          createdAt: DateTime.now(),
        );

        // Act & Assert
        expect(match.didUserParticipate('uid1'), isTrue);
        expect(match.didUserParticipate('AI'), isTrue);
      });
    });

    group('createFriendChallenge', () {
      test('creates friend challenge with custom third player', () async {
        // Arrange
        _setupCreateMatch(mockFirestore);

        // Act
        final matchId = await socialMatchService.createFriendChallenge(
          creatorUid: 'uid1',
          friendUid: 'uid2',
          thirdPlayerUid: 'uid3',
        );

        // Assert
        expect(matchId, isNotEmpty);
      });

      test('creates friend challenge with AI as third player', () async {
        // Arrange
        _setupCreateMatch(mockFirestore);

        // Act
        final matchId = await socialMatchService.createFriendChallenge(
          creatorUid: 'uid1',
          friendUid: 'uid2',
        );

        // Assert
        expect(matchId, isNotEmpty);
      });
    });

    group('getUserMatchHistory', () {
      test('returns user match history in reverse chronological order', () async {
        // Arrange
        final mockQuery = MockQuery();
        final mockSnapshot = MockQuerySnapshot();

        when(() => mockSnapshot.docs).thenReturn([
          _createMockMatchDoc('match1'),
          _createMockMatchDoc('match2'),
        ]);
        when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);

        _setupGetMatchHistory(mockFirestore, mockQuery);

        // Act
        final matches = await socialMatchService.getUserMatchHistory('uid1');

        // Assert
        expect(matches, isNotEmpty);
      });
    });

    group('getUserMatchStats', () {
      test('calculates match statistics correctly', () async {
        // Arrange
        final mockQuery = MockQuery();
        final mockSnapshot = MockQuerySnapshot();

        when(() => mockSnapshot.docs).thenReturn([]);
        when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);

        _setupGetMatchHistory(mockFirestore, mockQuery);

        // Act
        final stats = await socialMatchService.getUserMatchStats('uid1');

        // Assert
        expect(stats.containsKey('totalMatches'), isTrue);
        expect(stats.containsKey('winRate'), isTrue);
      });
    });
  });
}

// Helper functions
void _setupCreateMatch(MockFirebaseFirestore mockFirestore) {
  final mockCollectionRef = MockCollectionReference();
  final mockDocRef = MockDocumentReference();

  when(() => mockFirestore.collection('matches')).thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.doc()).thenReturn(mockDocRef);
  when(() => mockDocRef.id).thenReturn('match123');
  when(() => mockDocRef.set(any())).thenAnswer((_) async => {});

  when(() => mockFirestore.collection('users')).thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.doc(any())).thenReturn(mockDocRef);
  when(() => mockDocRef.collection('matchHistory'))
      .thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.doc(any())).thenReturn(mockDocRef);
  when(() => mockDocRef.set(any())).thenAnswer((_) async => {});
}

void _setupCompleteMatch(MockFirebaseFirestore mockFirestore) {
  final mockCollectionRef = MockCollectionReference();
  final mockDocRef = MockDocumentReference();

  when(() => mockFirestore.collection('matches')).thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.doc(any())).thenReturn(mockDocRef);
  when(() => mockDocRef.update(any())).thenAnswer((_) async => {});

  when(() => mockFirestore.collection('users')).thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.doc(any())).thenReturn(mockDocRef);
  when(() => mockDocRef.collection('matchHistory'))
      .thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.doc(any())).thenReturn(mockDocRef);
  when(() => mockDocRef.update(any())).thenAnswer((_) async => {});
}

void _setupBatchUpdate(
  MockFirebaseFirestore mockFirestore,
  MockWriteBatch mockBatch,
) {
  final mockCollectionRef = MockCollectionReference();
  final mockDocRef = MockDocumentReference();

  when(() => mockFirestore.collection('leaderboards'))
      .thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.doc('global')).thenReturn(mockDocRef);
  when(() => mockDocRef.collection('entries')).thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.doc(any())).thenReturn(mockDocRef);

  when(() => mockFirestore.collection('matches')).thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.doc(any())).thenReturn(mockDocRef);
}

void _setupGetMatch(
  MockFirebaseFirestore mockFirestore,
  MockDocumentReference mockDocRef,
) {
  final mockCollectionRef = MockCollectionReference();

  when(() => mockFirestore.collection('matches')).thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.doc(any())).thenReturn(mockDocRef);
}

void _setupGetMatchHistory(
  MockFirebaseFirestore mockFirestore,
  MockQuery mockQuery,
) {
  final mockCollectionRef = MockCollectionReference();
  final mockDocRef = MockDocumentReference();
  final mockSubCollectionRef = MockCollectionReference();

  when(() => mockFirestore.collection('users')).thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.doc(any())).thenReturn(mockDocRef);
  when(() => mockDocRef.collection('matchHistory'))
      .thenReturn(mockSubCollectionRef);
  when(() => mockSubCollectionRef.orderBy('joinedAt', descending: true))
      .thenReturn(mockQuery);
  when(() => mockQuery.limit(any())).thenReturn(mockQuery);
  when(() => mockQuery.where(any(), isGreaterThan: any())).thenReturn(mockQuery);
}

MockDocumentSnapshot _createMockMatchDoc(String matchId) {
  final mockDoc = MockDocumentSnapshot();
  when(() => mockDoc['matchId']).thenReturn(matchId);
  when(() => mockDoc['matchType']).thenReturn('MatchType.ranked');
  when(() => mockDoc['participants']).thenReturn(['uid1', 'uid2', 'uid3']);
  when(() => mockDoc['joinedAt']).thenReturn(DateTime.now().toIso8601String());
  return mockDoc;
}
