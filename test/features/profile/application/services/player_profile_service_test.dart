/// Unit tests for PlayerProfileService
///
/// Tests profile CRUD, stats updates, and achievement management.

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toriverse/features/profile/application/services/player_profile_service.dart';
import 'package:toriverse/features/profile/domain/models/player_profile_models.dart';

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

class MockWriteBatch extends Mock implements WriteBatch {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late PlayerProfileService profileService;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    profileService = PlayerProfileService(firestore: mockFirestore);
  });

  group('PlayerProfileService', () {
    group('upsertProfile', () {
      test('creates new player profile', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        when(() => mockDocRef.set(any(), any()))
            .thenAnswer((_) async => {});

        _setupProfileDocRef(mockFirestore, mockDocRef);

        // Act
        await profileService.upsertProfile(
          uid: 'uid1',
          username: 'testPlayer',
          avatar: 'avatar_url',
          bio: 'Test bio',
        );

        // Assert
        verify(() => mockDocRef.set(any(), any())).called(1);
      });

      test('updates existing profile', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        when(() => mockDocRef.set(any(), any()))
            .thenAnswer((_) async => {});

        _setupProfileDocRef(mockFirestore, mockDocRef);

        // Act
        await profileService.upsertProfile(
          uid: 'uid1',
          username: 'updatedPlayer',
        );

        // Assert
        verify(() => mockDocRef.set(any(), any())).called(1);
      });
    });

    group('getProfile', () {
      test('retrieves player profile', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();
        when(() => mockSnapshot.exists).thenReturn(true);
        when(() => mockSnapshot.data()).thenReturn({
          'uid': 'uid1',
          'username': 'testPlayer',
          'avatar': 'avatar_url',
          'bio': 'Test bio',
          'joinedAt': DateTime.now().toIso8601String(),
          'totalMatches': 10,
          'totalWins': 8,
          'totalLosses': 2,
          'winRate': 0.8,
          'currentRank': 1,
          'currentRankPoints': 500,
          'matchStreak': 3,
          'bestStreak': 5,
          'friendCount': 10,
          'blockedCount': 0,
          'isPublic': true,
          'lastUpdated': DateTime.now().toIso8601String(),
        });
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);

        _setupProfileDocRef(mockFirestore, mockDocRef);

        // Act
        final profile = await profileService.getProfile('uid1');

        // Assert
        expect(profile, isNotNull);
        expect(profile!.uid, equals('uid1'));
        expect(profile.username, equals('testPlayer'));
        expect(profile.totalWins, equals(8));
        expect(profile.winRate, equals(0.8));
      });

      test('returns null when profile not found', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();
        when(() => mockSnapshot.exists).thenReturn(false);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);

        _setupProfileDocRef(mockFirestore, mockDocRef);

        // Act
        final profile = await profileService.getProfile('uid999');

        // Assert
        expect(profile, isNull);
      });
    });

    group('updateBio', () {
      test('updates player bio', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        when(() => mockDocRef.update(any())).thenAnswer((_) async => {});

        _setupProfileDocRef(mockFirestore, mockDocRef);

        // Act
        await profileService.updateBio(
          uid: 'uid1',
          bio: 'New bio',
        );

        // Assert
        verify(() => mockDocRef.update(any())).called(1);
      });
    });

    group('updateAvatar', () {
      test('updates player avatar', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        when(() => mockDocRef.update(any())).thenAnswer((_) async => {});

        _setupProfileDocRef(mockFirestore, mockDocRef);

        // Act
        await profileService.updateAvatar(
          uid: 'uid1',
          avatarUrl: 'new_avatar_url',
        );

        // Assert
        verify(() => mockDocRef.update(any())).called(1);
      });
    });

    group('setProfileVisibility', () {
      test('makes profile private', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        when(() => mockDocRef.update(any())).thenAnswer((_) async => {});

        _setupProfileDocRef(mockFirestore, mockDocRef);

        // Act
        await profileService.setProfileVisibility(
          uid: 'uid1',
          isPublic: false,
        );

        // Assert
        verify(() => mockDocRef.update(any())).called(1);
      });

      test('makes profile public', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        when(() => mockDocRef.update(any())).thenAnswer((_) async => {});

        _setupProfileDocRef(mockFirestore, mockDocRef);

        // Act
        await profileService.setProfileVisibility(
          uid: 'uid1',
          isPublic: true,
        );

        // Assert
        verify(() => mockDocRef.update(any())).called(1);
      });
    });

    group('updateStats', () {
      test('updates player stats', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        when(() => mockDocRef.update(any())).thenAnswer((_) async => {});

        _setupProfileDocRef(mockFirestore, mockDocRef);

        // Act
        await profileService.updateStats(
          uid: 'uid1',
          totalMatches: 20,
          totalWins: 15,
          totalLosses: 5,
          winRate: 0.75,
          matchStreak: 5,
          bestStreak: 10,
        );

        // Assert
        verify(() => mockDocRef.update(any())).called(1);
      });
    });

    group('updateRankInfo', () {
      test('updates player rank and points', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        when(() => mockDocRef.update(any())).thenAnswer((_) async => {});

        _setupProfileDocRef(mockFirestore, mockDocRef);

        // Act
        await profileService.updateRankInfo(
          uid: 'uid1',
          rank: 5,
          rankPoints: 1000,
        );

        // Assert
        verify(() => mockDocRef.update(any())).called(1);
      });
    });

    group('updateSocialCounts', () {
      test('updates friend and blocked counts', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        when(() => mockDocRef.update(any())).thenAnswer((_) async => {});

        _setupProfileDocRef(mockFirestore, mockDocRef);

        // Act
        await profileService.updateSocialCounts(
          uid: 'uid1',
          friendCount: 25,
          blockedCount: 2,
        );

        // Assert
        verify(() => mockDocRef.update(any())).called(1);
      });
    });

    group('unlockAchievement', () {
      test('unlocks new achievement', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();
        when(() => mockSnapshot.exists).thenReturn(false);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
        when(() => mockDocRef.set(any())).thenAnswer((_) async => {});

        _setupAchievementDocRef(mockFirestore, mockDocRef);

        // Act
        await profileService.unlockAchievement(
          uid: 'uid1',
          achievementId: 'first_win',
        );

        // Assert
        verify(() => mockDocRef.set(any())).called(1);
      });

      test('skips if achievement already unlocked', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();
        when(() => mockSnapshot.exists).thenReturn(true);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);

        _setupAchievementDocRef(mockFirestore, mockDocRef);

        // Act
        await profileService.unlockAchievement(
          uid: 'uid1',
          achievementId: 'first_win',
        );

        // Assert
        verifyNever(() => mockDocRef.set(any()));
      });

      test('throws error for unknown achievement', () async {
        // Act & Assert
        expect(
          profileService.unlockAchievement(
            uid: 'uid1',
            achievementId: 'unknown_achievement',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('getAchievements', () {
      test('retrieves player achievements', () async {
        // Arrange
        final mockQuery = MockQuery();
        final mockSnapshot = MockQuerySnapshot();

        when(() => mockSnapshot.docs).thenReturn([
          _createMockAchievementDoc('first_win'),
          _createMockAchievementDoc('ten_wins'),
        ]);
        when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);

        _setupGetAchievements(mockFirestore, mockQuery);

        // Act
        final achievements = await profileService.getAchievements('uid1');

        // Assert
        expect(achievements, isNotEmpty);
      });
    });

    group('hasAchievement', () {
      test('returns true if achievement is unlocked', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();
        when(() => mockSnapshot.exists).thenReturn(true);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);

        _setupAchievementDocRef(mockFirestore, mockDocRef);

        // Act
        final has = await profileService.hasAchievement(
          uid: 'uid1',
          achievementId: 'first_win',
        );

        // Assert
        expect(has, isTrue);
      });

      test('returns false if achievement is not unlocked', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();
        when(() => mockSnapshot.exists).thenReturn(false);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);

        _setupAchievementDocRef(mockFirestore, mockDocRef);

        // Act
        final has = await profileService.hasAchievement(
          uid: 'uid1',
          achievementId: 'fifty_wins',
        );

        // Assert
        expect(has, isFalse);
      });
    });

    group('searchProfiles', () {
      test('searches profiles by username', () async {
        // Arrange
        final mockQuery = MockQuery();
        final mockSnapshot = MockQuerySnapshot();

        when(() => mockSnapshot.docs).thenReturn([
          _createMockProfileDoc('uid1', 'alice'),
          _createMockProfileDoc('uid2', 'alice123'),
        ]);
        when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);

        _setupProfileSearch(mockFirestore, mockQuery);

        // Act
        final profiles = await profileService.searchProfiles(query: 'alice');

        // Assert
        expect(profiles, isNotEmpty);
      });

      test('returns empty list for empty query', () async {
        // Act
        final profiles = await profileService.searchProfiles(query: '');

        // Assert
        expect(profiles, isEmpty);
      });
    });

    group('PlayerProfile', () {
      test('calculates account age correctly', () {
        // Arrange
        final joined = DateTime.now().subtract(const Duration(days: 5));
        final profile = PlayerProfile(
          uid: 'uid1',
          username: 'test',
          joinedAt: joined,
          totalMatches: 0,
          totalWins: 0,
          totalLosses: 0,
          winRate: 0.0,
          currentRank: 0,
          currentRankPoints: 0,
          matchStreak: 0,
          bestStreak: 0,
          friendCount: 0,
          blockedCount: 0,
          isPublic: true,
          lastUpdated: DateTime.now(),
        );

        // Act & Assert
        expect(profile.accountAgeDays, lessThanOrEqualTo(5));
        expect(profile.isNewAccount, isTrue);
      });

      test('calculates stats correctly', () {
        // Arrange
        final profile = PlayerProfile(
          uid: 'uid1',
          username: 'test',
          joinedAt: DateTime.now(),
          totalMatches: 10,
          totalWins: 8,
          totalLosses: 2,
          winRate: 0.8,
          currentRank: 1,
          currentRankPoints: 500,
          matchStreak: 3,
          bestStreak: 5,
          friendCount: 10,
          blockedCount: 0,
          isPublic: true,
          lastUpdated: DateTime.now(),
        );

        // Act & Assert
        expect(profile.matchesNotWon, equals(2));
        expect(profile.winRate, equals(0.8));
      });
    });
  });
}

// Helper functions
void _setupProfileDocRef(
  MockFirebaseFirestore mockFirestore,
  MockDocumentReference mockDocRef,
) {
  final mockCollectionRef = MockCollectionReference();

  when(() => mockFirestore.collection('profiles'))
      .thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.doc(any())).thenReturn(mockDocRef);
}

void _setupAchievementDocRef(
  MockFirebaseFirestore mockFirestore,
  MockDocumentReference mockDocRef,
) {
  final mockProfileRef = MockDocumentReference();
  final mockCollectionRef = MockCollectionReference();
  final mockProfileCollectionRef = MockCollectionReference();

  when(() => mockFirestore.collection('profiles'))
      .thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.doc(any())).thenReturn(mockProfileRef);
  when(() => mockProfileRef.collection('achievements'))
      .thenReturn(mockProfileCollectionRef);
  when(() => mockProfileCollectionRef.doc(any())).thenReturn(mockDocRef);
}

void _setupGetAchievements(
  MockFirebaseFirestore mockFirestore,
  MockQuery mockQuery,
) {
  final mockProfileRef = MockDocumentReference();
  final mockCollectionRef = MockCollectionReference();
  final mockProfileCollectionRef = MockCollectionReference();

  when(() => mockFirestore.collection('profiles'))
      .thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.doc(any())).thenReturn(mockProfileRef);
  when(() => mockProfileRef.collection('achievements'))
      .thenReturn(mockProfileCollectionRef);
  when(() => mockProfileCollectionRef.get())
      .thenAnswer((_) async => MockQuerySnapshot());
}

void _setupProfileSearch(
  MockFirebaseFirestore mockFirestore,
  MockQuery mockQuery,
) {
  final mockCollectionRef = MockCollectionReference();

  when(() => mockFirestore.collection('profiles'))
      .thenReturn(mockCollectionRef);
  when(() => mockCollectionRef.where(any(), isGreaterThanOrEqualTo: any()))
      .thenReturn(mockQuery);
  when(() => mockQuery.where(any(), isLessThan: any()))
      .thenReturn(mockQuery);
  when(() => mockQuery.where(any(), isEqualTo: true))
      .thenReturn(mockQuery);
  when(() => mockQuery.orderBy(any())).thenReturn(mockQuery);
  when(() => mockQuery.limit(any())).thenReturn(mockQuery);
}

MockDocumentSnapshot _createMockAchievementDoc(String id) {
  final mockDoc = MockDocumentSnapshot();
  when(() => mockDoc.data()).thenReturn({
    'id': id,
    'name': 'Achievement Name',
    'description': 'Achievement Description',
    'icon': '🏆',
    'type': 'AchievementType.milestone',
    'unlockedAt': DateTime.now().toIso8601String(),
  });
  return mockDoc;
}

MockDocumentSnapshot _createMockProfileDoc(String uid, String username) {
  final mockDoc = MockDocumentSnapshot();
  when(() => mockDoc.id).thenReturn(uid);
  when(() => mockDoc.data()).thenReturn({
    'uid': uid,
    'username': username,
    'joinedAt': DateTime.now().toIso8601String(),
    'totalMatches': 10,
    'totalWins': 8,
    'totalLosses': 2,
    'winRate': 0.8,
    'currentRank': 1,
    'currentRankPoints': 500,
    'matchStreak': 3,
    'bestStreak': 5,
    'friendCount': 10,
    'blockedCount': 0,
    'isPublic': true,
    'lastUpdated': DateTime.now().toIso8601String(),
  });
  return mockDoc;
}
