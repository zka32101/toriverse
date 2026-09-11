/// Unit tests for FriendService
///
/// Tests friend requests, friend list management, and blocking.

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toriverse/features/social/application/services/friend_service.dart';
import 'package:toriverse/features/social/domain/models/friend_models.dart';

// Mock classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockWriteBatch extends Mock implements WriteBatch {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late FriendService friendService;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    friendService = FriendService(firestore: mockFirestore);
  });

  group('FriendService', () {
    group('sendFriendRequest', () {
      test('sends friend request from one user to another', () async {
        // Arrange
        final mockBatch = MockWriteBatch();
        when(() => mockFirestore.batch()).thenReturn(mockBatch);
        when(() => mockBatch.update(any(), any())).thenReturn(() {});
        when(() => mockBatch.commit()).thenAnswer((_) async => []);

        _setupCollectionRef(mockFirestore, mockBatch);

        // Act
        await friendService.sendFriendRequest(
          fromUid: 'uid1',
          toUid: 'uid2',
        );

        // Assert
        verify(() => mockBatch.update(any(), any())).called(2); // Both users
        verify(() => mockBatch.commit()).called(1);
      });

      test('throws error when sending request to self', () async {
        // Act & Assert
        expect(
          friendService.sendFriendRequest(
            fromUid: 'uid1',
            toUid: 'uid1',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('acceptFriendRequest', () {
      test('accepts friend request and adds to both friend lists', () async {
        // Arrange
        final mockBatch = MockWriteBatch();
        when(() => mockFirestore.batch()).thenReturn(mockBatch);
        when(() => mockBatch.update(any(), any())).thenReturn(() {});
        when(() => mockBatch.commit()).thenAnswer((_) async => []);

        _setupCollectionRef(mockFirestore, mockBatch);

        // Act
        await friendService.acceptFriendRequest(
          userId: 'uid1',
          fromUid: 'uid2',
        );

        // Assert
        verify(() => mockBatch.update(any(), any())).called(2);
        verify(() => mockBatch.commit()).called(1);
      });
    });

    group('rejectFriendRequest', () {
      test('rejects friend request and removes from both request lists', () async {
        // Arrange
        final mockBatch = MockWriteBatch();
        when(() => mockFirestore.batch()).thenReturn(mockBatch);
        when(() => mockBatch.update(any(), any())).thenReturn(() {});
        when(() => mockBatch.commit()).thenAnswer((_) async => []);

        _setupCollectionRef(mockFirestore, mockBatch);

        // Act
        await friendService.rejectFriendRequest(
          userId: 'uid1',
          fromUid: 'uid2',
        );

        // Assert
        verify(() => mockBatch.update(any(), any())).called(2);
        verify(() => mockBatch.commit()).called(1);
      });
    });

    group('removeFriend', () {
      test('removes friend from both users\' friend lists', () async {
        // Arrange
        final mockBatch = MockWriteBatch();
        when(() => mockFirestore.batch()).thenReturn(mockBatch);
        when(() => mockBatch.update(any(), any())).thenReturn(() {});
        when(() => mockBatch.commit()).thenAnswer((_) async => []);

        _setupCollectionRef(mockFirestore, mockBatch);

        // Act
        await friendService.removeFriend(
          userId: 'uid1',
          friendUid: 'uid2',
        );

        // Assert
        verify(() => mockBatch.update(any(), any())).called(2);
        verify(() => mockBatch.commit()).called(1);
      });
    });

    group('blockUser', () {
      test('blocks user and removes from friends', () async {
        // Arrange
        final mockBatch = MockWriteBatch();
        when(() => mockFirestore.batch()).thenReturn(mockBatch);
        when(() => mockBatch.update(any(), any())).thenReturn(() {});
        when(() => mockBatch.commit()).thenAnswer((_) async => []);

        _setupCollectionRef(mockFirestore, mockBatch);

        // Act
        await friendService.blockUser(
          userId: 'uid1',
          blockedUid: 'uid2',
        );

        // Assert
        verify(() => mockBatch.update(any(), any())).called(1);
        verify(() => mockBatch.commit()).called(1);
      });
    });

    group('unblockUser', () {
      test('unblocks user', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        when(() => mockDocRef.update(any())).thenAnswer((_) async => {});

        _setupDocumentRef(mockFirestore, mockDocRef);

        // Act
        await friendService.unblockUser(
          userId: 'uid1',
          blockedUid: 'uid2',
        );

        // Assert
        verify(() => mockDocRef.update(any())).called(1);
      });
    });

    group('getFriendList', () {
      test('returns list of friend UIDs', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();
        when(() => mockSnapshot.exists).thenReturn(true);
        when(() => mockSnapshot.data()).thenReturn({
          'uid': 'uid1',
          'friends': ['uid2', 'uid3', 'uid4'],
          'friendRequests': {'incoming': [], 'outgoing': []},
          'blockedUsers': [],
          'lastUpdated': '2026-09-11T10:00:00Z',
        });
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);

        _setupDocumentRef(mockFirestore, mockDocRef);

        // Act
        final friends = await friendService.getFriendList('uid1');

        // Assert
        expect(friends, hasLength(3));
        expect(friends, contains('uid2'));
      });

      test('returns empty list when user not found', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();
        when(() => mockSnapshot.exists).thenReturn(false);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);

        _setupDocumentRef(mockFirestore, mockDocRef);

        // Act
        final friends = await friendService.getFriendList('uid999');

        // Assert
        expect(friends, isEmpty);
      });
    });

    group('getIncomingRequests', () {
      test('returns list of incoming friend request UIDs', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();
        when(() => mockSnapshot.exists).thenReturn(true);
        when(() => mockSnapshot.data()).thenReturn({
          'uid': 'uid1',
          'friends': [],
          'friendRequests': {
            'incoming': ['uid2', 'uid3'],
            'outgoing': [],
          },
          'blockedUsers': [],
          'lastUpdated': '2026-09-11T10:00:00Z',
        });
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);

        _setupDocumentRef(mockFirestore, mockDocRef);

        // Act
        final requests = await friendService.getIncomingRequests('uid1');

        // Assert
        expect(requests, hasLength(2));
        expect(requests, contains('uid2'));
      });
    });

    group('getOutgoingRequests', () {
      test('returns list of outgoing friend request UIDs', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();
        when(() => mockSnapshot.exists).thenReturn(true);
        when(() => mockSnapshot.data()).thenReturn({
          'uid': 'uid1',
          'friends': [],
          'friendRequests': {
            'incoming': [],
            'outgoing': ['uid2', 'uid3'],
          },
          'blockedUsers': [],
          'lastUpdated': '2026-09-11T10:00:00Z',
        });
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);

        _setupDocumentRef(mockFirestore, mockDocRef);

        // Act
        final requests = await friendService.getOutgoingRequests('uid1');

        // Assert
        expect(requests, hasLength(2));
        expect(requests, contains('uid2'));
      });
    });

    group('getFriendship', () {
      test('returns complete friendship object', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();
        when(() => mockSnapshot.exists).thenReturn(true);
        when(() => mockSnapshot.data()).thenReturn({
          'friends': ['uid2', 'uid3'],
          'friendRequests': {
            'incoming': ['uid4'],
            'outgoing': ['uid5'],
          },
          'blockedUsers': ['uid6'],
          'lastUpdated': '2026-09-11T10:00:00Z',
        });
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);

        _setupDocumentRef(mockFirestore, mockDocRef);

        // Act
        final friendship = await friendService.getFriendship('uid1');

        // Assert
        expect(friendship, isNotNull);
        expect(friendship!.userId, equals('uid1'));
        expect(friendship.friends, hasLength(2));
        expect(friendship.friendRequests.incoming, hasLength(1));
      });

      test('returns null when user not found', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();
        when(() => mockSnapshot.exists).thenReturn(false);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);

        _setupDocumentRef(mockFirestore, mockDocRef);

        // Act
        final friendship = await friendService.getFriendship('uid999');

        // Assert
        expect(friendship, isNull);
      });
    });

    group('areFriends', () {
      test('returns true when users are friends', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();
        when(() => mockSnapshot.exists).thenReturn(true);
        when(() => mockSnapshot.data()).thenReturn({
          'friends': ['uid2', 'uid3'],
          'friendRequests': {'incoming': [], 'outgoing': []},
          'blockedUsers': [],
          'lastUpdated': '2026-09-11T10:00:00Z',
        });
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);

        _setupDocumentRef(mockFirestore, mockDocRef);

        // Act
        final isFriend = await friendService.areFriends(
          userId: 'uid1',
          otherUid: 'uid2',
        );

        // Assert
        expect(isFriend, isTrue);
      });

      test('returns false when users are not friends', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();
        when(() => mockSnapshot.exists).thenReturn(true);
        when(() => mockSnapshot.data()).thenReturn({
          'friends': ['uid2', 'uid3'],
          'friendRequests': {'incoming': [], 'outgoing': []},
          'blockedUsers': [],
          'lastUpdated': '2026-09-11T10:00:00Z',
        });
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);

        _setupDocumentRef(mockFirestore, mockDocRef);

        // Act
        final isFriend = await friendService.areFriends(
          userId: 'uid1',
          otherUid: 'uid999',
        );

        // Assert
        expect(isFriend, isFalse);
      });
    });

    group('isUserBlocked', () {
      test('returns true when user is blocked', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();
        when(() => mockSnapshot.exists).thenReturn(true);
        when(() => mockSnapshot.data()).thenReturn({
          'uid': 'uid1',
          'friends': [],
          'friendRequests': {'incoming': [], 'outgoing': []},
          'blockedUsers': ['uid2', 'uid3'],
          'lastUpdated': '2026-09-11T10:00:00Z',
        });
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);

        _setupDocumentRef(mockFirestore, mockDocRef);

        // Act
        final isBlocked = await friendService.isUserBlocked(
          userId: 'uid1',
          otherUid: 'uid2',
        );

        // Assert
        expect(isBlocked, isTrue);
      });

      test('returns false when user is not blocked', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();
        when(() => mockSnapshot.exists).thenReturn(true);
        when(() => mockSnapshot.data()).thenReturn({
          'uid': 'uid1',
          'friends': [],
          'friendRequests': {'incoming': [], 'outgoing': []},
          'blockedUsers': [],
          'lastUpdated': '2026-09-11T10:00:00Z',
        });
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);

        _setupDocumentRef(mockFirestore, mockDocRef);

        // Act
        final isBlocked = await friendService.isUserBlocked(
          userId: 'uid1',
          otherUid: 'uid2',
        );

        // Assert
        expect(isBlocked, isFalse);
      });
    });

    group('initializeFriendship', () {
      test('creates friendship document for new user', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();
        when(() => mockSnapshot.exists).thenReturn(false);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
        when(() => mockDocRef.set(any())).thenAnswer((_) async => {});

        _setupDocumentRef(mockFirestore, mockDocRef);

        // Act
        await friendService.initializeFriendship('uid1');

        // Assert
        verify(() => mockDocRef.set(any())).called(1);
      });

      test('skips initialization if friendship already exists', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();
        when(() => mockSnapshot.exists).thenReturn(true);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);

        _setupDocumentRef(mockFirestore, mockDocRef);

        // Act
        await friendService.initializeFriendship('uid1');

        // Assert
        verifyNever(() => mockDocRef.set(any()));
      });
    });
  });
}

// Helper functions
void _setupCollectionRef(
  MockFirebaseFirestore mockFirestore,
  MockWriteBatch mockBatch,
) {
  final mockCollectionRef = MockCollectionReference();
  final mockDocRef = MockDocumentReference();

  when(() => mockFirestore.collection('friendships'))
      .thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.doc(any())).thenReturn(mockDocRef);
}

void _setupDocumentRef(
  MockFirebaseFirestore mockFirestore,
  MockDocumentReference mockDocRef,
) {
  final mockCollectionRef = MockCollectionReference();

  when(() => mockFirestore.collection('friendships'))
      .thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.doc(any())).thenReturn(mockDocRef);
}
