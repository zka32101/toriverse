/// Unit tests for PresenceService
///
/// Tests online/offline status tracking and heartbeat functionality.

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toriverse/features/social/application/services/presence_service.dart';

// Mock classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late PresenceService presenceService;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    presenceService = PresenceService(firestore: mockFirestore);
  });

  group('PresenceService', () {
    group('setUserOnline', () {
      test('sets user online with current timestamp', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        when(() => mockDocRef.set(any()))
            .thenAnswer((_) async => {});

        _setupDocumentRef(mockFirestore, mockDocRef);

        // Act
        await presenceService.setUserOnline('uid1');

        // Assert
        verify(() => mockDocRef.set(any())).called(1);
      });
    });

    group('setUserOffline', () {
      test('sets user offline with current timestamp', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        when(() => mockDocRef.set(any()))
            .thenAnswer((_) async => {});

        _setupDocumentRef(mockFirestore, mockDocRef);

        // Act
        await presenceService.setUserOffline('uid1');

        // Assert
        verify(() => mockDocRef.set(any())).called(1);
      });
    });

    group('isUserOnline', () {
      test('returns true when user is online and recently active', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();
        final now = DateTime.now();

        when(() => mockSnapshot.exists).thenReturn(true);
        when(() => mockSnapshot.data()).thenReturn({
          'uid': 'uid1',
          'isOnline': true,
          'lastSeenAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        });
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);

        _setupDocumentRef(mockFirestore, mockDocRef);

        // Act
        final isOnline = await presenceService.isUserOnline('uid1');

        // Assert
        expect(isOnline, isTrue);
      });

      test('returns false when user is offline', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();

        when(() => mockSnapshot.exists).thenReturn(true);
        when(() => mockSnapshot.data()).thenReturn({
          'uid': 'uid1',
          'isOnline': false,
          'lastSeenAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);

        _setupDocumentRef(mockFirestore, mockDocRef);

        // Act
        final isOnline = await presenceService.isUserOnline('uid1');

        // Assert
        expect(isOnline, isFalse);
      });

      test('returns false when user status is stale (> 5 min)', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();
        final staleTime = DateTime.now().subtract(const Duration(minutes: 10));

        when(() => mockSnapshot.exists).thenReturn(true);
        when(() => mockSnapshot.data()).thenReturn({
          'uid': 'uid1',
          'isOnline': true,
          'lastSeenAt': staleTime.toIso8601String(),
          'updatedAt': staleTime.toIso8601String(),
        });
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);

        _setupDocumentRef(mockFirestore, mockDocRef);

        // Act
        final isOnline = await presenceService.isUserOnline('uid1');

        // Assert
        expect(isOnline, isFalse);
      });

      test('returns false when user not found', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();

        when(() => mockSnapshot.exists).thenReturn(false);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);

        _setupDocumentRef(mockFirestore, mockDocRef);

        // Act
        final isOnline = await presenceService.isUserOnline('uid999');

        // Assert
        expect(isOnline, isFalse);
      });
    });

    group('getUserLastSeen', () {
      test('returns last seen timestamp when user exists', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();
        final lastSeen = DateTime.now().subtract(const Duration(minutes: 5));

        when(() => mockSnapshot.exists).thenReturn(true);
        when(() => mockSnapshot.data()).thenReturn({
          'uid': 'uid1',
          'isOnline': false,
          'lastSeenAt': lastSeen.toIso8601String(),
          'updatedAt': lastSeen.toIso8601String(),
        });
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);

        _setupDocumentRef(mockFirestore, mockDocRef);

        // Act
        final seen = await presenceService.getUserLastSeen('uid1');

        // Assert
        expect(seen, isNotNull);
        expect(seen!.isBefore(DateTime.now()), isTrue);
      });

      test('returns null when user not found', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();

        when(() => mockSnapshot.exists).thenReturn(false);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);

        _setupDocumentRef(mockFirestore, mockDocRef);

        // Act
        final seen = await presenceService.getUserLastSeen('uid999');

        // Assert
        expect(seen, isNull);
      });
    });

    group('getUsersOnlineStatus', () {
      test('returns online status map for multiple users', () async {
        // Arrange
        final mockQuery = MockQuery();
        final mockSnapshot = MockQuerySnapshot();
        final now = DateTime.now();

        final doc1 = MockDocumentSnapshot();
        when(() => doc1.id).thenReturn('uid1');
        when(() => doc1['isOnline']).thenReturn(true);
        when(() => doc1['lastSeenAt']).thenReturn(now.toIso8601String());

        final doc2 = MockDocumentSnapshot();
        when(() => doc2.id).thenReturn('uid2');
        when(() => doc2['isOnline']).thenReturn(false);
        when(() => doc2['lastSeenAt']).thenReturn(now.toIso8601String());

        when(() => mockSnapshot.docs).thenReturn([doc1, doc2]);
        when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);

        _setupQueryRef(mockFirestore, mockQuery);

        // Act
        final statuses = await presenceService.getUsersOnlineStatus(['uid1', 'uid2', 'uid3']);

        // Assert
        expect(statuses, hasLength(3));
        expect(statuses['uid1'], isTrue);
        expect(statuses['uid2'], isFalse);
        expect(statuses['uid3'], isFalse); // Not found defaults to false
      });

      test('returns empty map on error', () async {
        // Arrange
        final mockQuery = MockQuery();
        when(() => mockQuery.get()).thenThrow(Exception('Firestore error'));

        _setupQueryRef(mockFirestore, mockQuery);

        // Act
        final statuses = await presenceService.getUsersOnlineStatus(['uid1']);

        // Assert
        expect(statuses, isEmpty);
      });
    });

    group('heartbeat', () {
      test('updates last seen timestamp', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        when(() => mockDocRef.update(any()))
            .thenAnswer((_) async => {});

        _setupDocumentRef(mockFirestore, mockDocRef);

        // Act
        await presenceService.heartbeat('uid1');

        // Assert
        verify(() => mockDocRef.update(any())).called(1);
      });

      test('creates entry if not found', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        when(() => mockDocRef.update(any()))
            .thenThrow(Exception('Document not found'));
        when(() => mockDocRef.set(any()))
            .thenAnswer((_) async => {});

        _setupDocumentRef(mockFirestore, mockDocRef);

        // Act
        await presenceService.heartbeat('uid1');

        // Assert - Should handle the error gracefully
        verify(() => mockDocRef.update(any())).called(1);
      });
    });

    group('cleanupStalePresence', () {
      test('removes presence records older than specified days', () async {
        // Arrange
        final mockCollectionRef = MockCollectionReference();
        final mockQuery = MockQuery();
        final mockSnapshot = MockQuerySnapshot();

        final doc1 = MockDocumentSnapshot();
        when(() => doc1.reference).thenReturn(MockDocumentReference());
        when(() => doc1.reference.delete()).thenAnswer((_) async => {});

        when(() => mockSnapshot.docs).thenReturn([doc1]);
        when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);
        when(() => mockCollectionRef.where(any(), isLessThan: any()))
            .thenReturn(mockQuery);

        when(() => mockFirestore.collection('presence'))
            .thenReturn(mockCollectionRef);

        // Act
        await presenceService.cleanupStalePresence(staleDaysOld: 30);

        // Assert
        verify(() => mockCollectionRef.where(any(), isLessThan: any()))
            .called(1);
      });
    });
  });
}

// Helper functions
void _setupDocumentRef(
  MockFirebaseFirestore mockFirestore,
  MockDocumentReference mockDocRef,
) {
  final mockCollectionRef = MockCollectionReference();

  when(() => mockFirestore.collection('presence'))
      .thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.doc(any())).thenReturn(mockDocRef);
}

void _setupQueryRef(
  MockFirebaseFirestore mockFirestore,
  MockQuery mockQuery,
) {
  final mockCollectionRef = MockCollectionReference();

  when(() => mockFirestore.collection('presence'))
      .thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.where(any(), whereIn: any()))
      .thenReturn(mockQuery);
}
