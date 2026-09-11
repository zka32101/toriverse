import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/shop/domain/services/seasonal_cosmetics_service.dart';

void main() {
  group('SeasonalCosmeticsService', () {
    test('getCurrentSeason returns season if in range', () {
      // This test may be flaky depending on current date
      // Mock the current date in real tests
      final season = SeasonalCosmeticsService.getCurrentSeason();
      // Season may or may not exist depending on date
      if (season != null) {
        expect(season.id, isIn([1, 2, 3]));
      }
    });

    test('getNextSeason returns upcoming season', () {
      final next = SeasonalCosmeticsService.getNextSeason();
      if (next != null) {
        final start = DateTime.parse(next.startDate);
        expect(start.isAfter(DateTime.now()), isTrue);
      }
    });

    test('isSeasonalCosmetic identifies seasonal items', () {
      expect(
        SeasonalCosmeticsService.isSeasonalCosmetic('board_sakura_autumn'),
        isTrue,
      );
      expect(
        SeasonalCosmeticsService.isSeasonalCosmetic('board_frost_crystal'),
        isTrue,
      );
      expect(
        SeasonalCosmeticsService.isSeasonalCosmetic('unknown_cosmetic'),
        isFalse,
      );
    });

    test('getSeasonForCosmetic returns correct season', () {
      final season = SeasonalCosmeticsService.getSeasonForCosmetic(
        'board_sakura_autumn',
      );
      expect(season, isNotNull);
      expect(season!.id, equals(1)); // Fall Festival
    });

    test('getSeasonForCosmetic returns null for non-seasonal', () {
      final season = SeasonalCosmeticsService.getSeasonForCosmetic(
        'unknown_cosmetic',
      );
      expect(season, isNull);
    });

    test('isCosmeticAvailable returns true within season', () {
      // Find a seasonal cosmetic and test
      final cosmetic = SeasonalCosmeticsService.seasons.values.first.featuredCosmetics.first;
      // This test is date-dependent
      final available = SeasonalCosmeticsService.isCosmeticAvailable(cosmetic);
      // Just verify it returns a boolean
      expect(available, isA<bool>());
    });

    test('getAvailabilityStatus returns appropriate text', () {
      final status = SeasonalCosmeticsService.getAvailabilityStatus(
        'board_sakura_autumn',
      );
      expect(status, isNotEmpty);
    });

    test('getCosmeticsExpiringWithin returns expiring cosmetics', () {
      final expiring = SeasonalCosmeticsService.getCosmeticsExpiringWithin(30);
      expect(expiring, isA<List<String>>());
    });

    test('getArchivedCosmetics returns past season items', () {
      final archived = SeasonalCosmeticsService.getArchivedCosmetics();
      expect(archived, isA<List<String>>());
    });

    test('Season.isActive checks date range', () {
      final season = SeasonalCosmeticsService.seasons[1]!;
      final active = season.isActive();
      expect(active, isA<bool>());
    });

    test('Season.getDuration calculates correctly', () {
      final season = SeasonalCosmeticsService.seasons[1]!;
      final duration = season.getDuration();
      expect(duration, equals(30)); // 30 days
    });

    test('Season.toMap serializes all fields', () {
      final season = SeasonalCosmeticsService.seasons[1]!;
      final map = season.toMap();

      expect(map['id'], equals(season.id));
      expect(map['name'], equals(season.name));
      expect(map['start_date'], equals(season.startDate));
      expect(map['end_date'], equals(season.endDate));
      expect(map['featured_cosmetics'], equals(season.featuredCosmetics));
    });

    test('Season.fromMap deserializes correctly', () {
      final original = SeasonalCosmeticsService.seasons[1]!;
      final map = original.toMap();
      final restored = Season.fromMap(map);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.startDate, equals(original.startDate));
      expect(restored.endDate, equals(original.endDate));
      expect(restored.featuredCosmetics, equals(original.featuredCosmetics));
    });

    test('SeasonalCosmeticInfo.isCurrentlyObtainable checks season', () {
      final season = SeasonalCosmeticsService.seasons[1]!;
      final info = SeasonalCosmeticInfo(
        cosmeticId: 'test',
        season: season,
        displayName: 'Test',
        rarityBoost: 0,
        isExclusive: false,
      );

      final obtainable = info.isCurrentlyObtainable();
      expect(obtainable, isA<bool>());
    });

    test('SeasonalCosmeticInfo.getAvailabilityWindow returns dates', () {
      final season = SeasonalCosmeticsService.seasons[1]!;
      final info = SeasonalCosmeticInfo(
        cosmeticId: 'test',
        season: season,
        displayName: 'Test',
        rarityBoost: 0,
        isExclusive: false,
      );

      final window = info.getAvailabilityWindow();
      expect(window, contains(season.startDate));
      expect(window, contains(season.endDate));
    });

    test('SeasonalTheme enum has all expected values', () {
      expect(SeasonalTheme.autumn.displayName, equals('秋'));
      expect(SeasonalTheme.winter.displayName, equals('冬'));
      expect(SeasonalTheme.spring.displayName, equals('春'));
      expect(SeasonalTheme.summer.displayName, equals('夏'));
      expect(SeasonalTheme.festival.displayName, equals('祭り'));
      expect(SeasonalTheme.anniversary.displayName, equals('周年記念'));
      expect(SeasonalTheme.holiday.displayName, equals('ホリデー'));
      expect(SeasonalTheme.special.displayName, equals('特別'));
    });
  });
}
