/// Service for managing seasonal cosmetics rotation
///
/// Handles limited-time cosmetics, seasonal themes, and rotation logic.
class SeasonalCosmeticsService {
  /// Season definitions
  static const Map<int, Season> seasons = {
    1: Season(
      id: 1,
      name: '秋祭り (Fall Festival)',
      theme: SeasonalTheme.autumn,
      startDate: '2026-09-01',
      endDate: '2026-09-30',
      featuredCosmetics: [
        'board_sakura_autumn',
        'stone_red_festival',
        'stone_black_lantern',
      ],
    ),
    2: Season(
      id: 2,
      name: '冬季 (Winter Season)',
      theme: SeasonalTheme.winter,
      startDate: '2026-10-01',
      endDate: '2026-10-31',
      featuredCosmetics: [
        'board_frost_crystal',
        'stone_white_snow',
        'stone_blue_ice',
      ],
    ),
    3: Season(
      id: 3,
      name: '春開花 (Spring Bloom)',
      theme: SeasonalTheme.spring,
      startDate: '2026-11-01',
      endDate: '2026-11-30',
      featuredCosmetics: [
        'board_cherry_blossom',
        'stone_pink_blossom',
        'stone_white_petal',
      ],
    ),
  };

  /// Get current season
  static Season? getCurrentSeason() {
    final now = DateTime.now();

    for (final season in seasons.values) {
      final start = DateTime.parse(season.startDate);
      final end = DateTime.parse(season.endDate);

      if (now.isAfter(start) && now.isBefore(end)) {
        return season;
      }
    }

    return null;
  }

  /// Get next upcoming season
  static Season? getNextSeason() {
    final now = DateTime.now();

    final upcoming = seasons.values
        .where((s) => DateTime.parse(s.startDate).isAfter(now))
        .toList();

    if (upcoming.isEmpty) return null;

    upcoming.sort((a, b) =>
        DateTime.parse(a.startDate).compareTo(DateTime.parse(b.startDate)));

    return upcoming.first;
  }

  /// Check if cosmetic is seasonal (limited time)
  static bool isSeasonalCosmetic(String cosmeticId) {
    for (final season in seasons.values) {
      if (season.featuredCosmetics.contains(cosmeticId)) {
        return true;
      }
    }
    return false;
  }

  /// Get season containing cosmetic
  static Season? getSeasonForCosmetic(String cosmeticId) {
    for (final season in seasons.values) {
      if (season.featuredCosmetics.contains(cosmeticId)) {
        return season;
      }
    }
    return null;
  }

  /// Calculate days until season ends
  static int getDaysUntilSeasonEnd(Season season) {
    final end = DateTime.parse(season.endDate);
    final now = DateTime.now();
    return end.difference(now).inDays;
  }

  /// Check if cosmetic is currently available
  static bool isCosmeticAvailable(String cosmeticId) {
    final season = getSeasonForCosmetic(cosmeticId);
    if (season == null) return true; // Non-seasonal cosmetics always available

    final now = DateTime.now();
    final start = DateTime.parse(season.startDate);
    final end = DateTime.parse(season.endDate);

    return now.isAfter(start) && now.isBefore(end);
  }

  /// Get availability status text
  static String getAvailabilityStatus(String cosmeticId) {
    if (!isSeasonalCosmetic(cosmeticId)) {
      return '常時入手可能'; // Always available
    }

    final season = getSeasonForCosmetic(cosmeticId);
    if (season == null) return 'Not found';

    if (isCosmeticAvailable(cosmeticId)) {
      final daysLeft = getDaysUntilSeasonEnd(season);
      return '残り$daysLeft日で入手不可'; // X days left
    } else {
      return '現在は入手不可'; // Currently unavailable
    }
  }

  /// Get cosmetics expiring soon
  static List<String> getCosmeticsExpiringWithin(int days) {
    final expiring = <String>[];
    final now = DateTime.now();

    for (final season in seasons.values) {
      final end = DateTime.parse(season.endDate);
      final daysUntilEnd = end.difference(now).inDays;

      if (daysUntilEnd > 0 && daysUntilEnd <= days) {
        expiring.addAll(season.featuredCosmetics);
      }
    }

    return expiring;
  }

  /// Archive old season cosmetics
  ///
  /// Marks cosmetics as unobtainable but keeps in user collections.
  static List<String> getArchivedCosmetics() {
    final archived = <String>[];
    final now = DateTime.now();

    for (final season in seasons.values) {
      final end = DateTime.parse(season.endDate);
      if (now.isAfter(end)) {
        archived.addAll(season.featuredCosmetics);
      }
    }

    return archived;
  }
}

/// Season definition
class Season {
  /// Unique season ID
  final int id;

  /// Display name (bilingual)
  final String name;

  /// Visual theme
  final SeasonalTheme theme;

  /// Start date (YYYY-MM-DD)
  final String startDate;

  /// End date (YYYY-MM-DD)
  final String endDate;

  /// Featured seasonal cosmetics
  final List<String> featuredCosmetics;

  const Season({
    required this.id,
    required this.name,
    required this.theme,
    required this.startDate,
    required this.endDate,
    required this.featuredCosmetics,
  });

  /// Get season duration in days
  int getDuration() {
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    return end.difference(start).inDays;
  }

  /// Check if season is active
  bool isActive() {
    final now = DateTime.now();
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    return now.isAfter(start) && now.isBefore(end);
  }

  /// Convert to JSON
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'theme': theme.toString(),
        'start_date': startDate,
        'end_date': endDate,
        'featured_cosmetics': featuredCosmetics,
      };

  /// Create from JSON
  factory Season.fromMap(Map<String, dynamic> map) {
    return Season(
      id: map['id'] as int,
      name: map['name'] as String,
      theme: _parseTheme(map['theme'] as String),
      startDate: map['start_date'] as String,
      endDate: map['end_date'] as String,
      featuredCosmetics:
          List<String>.from(map['featured_cosmetics'] as List),
    );
  }
}

/// Seasonal themes
enum SeasonalTheme {
  autumn('秋'),
  winter('冬'),
  spring('春'),
  summer('夏'),
  festival('祭り'),
  anniversary('周年記念'),
  holiday('ホリデー'),
  special('特別');

  final String displayName;

  const SeasonalTheme(this.displayName);
}

/// Parse theme from string
SeasonalTheme _parseTheme(String value) {
  for (final theme in SeasonalTheme.values) {
    if (theme.toString() == value) return theme;
  }
  return SeasonalTheme.special;
}

/// Seasonal cosmetic metadata
class SeasonalCosmeticInfo {
  /// Cosmetic ID
  final String cosmeticId;

  /// Season it belongs to
  final Season season;

  /// Display name with season indicator
  final String displayName;

  /// Rarity boost from season theme
  final int rarityBoost;

  /// Exclusive cosmetic (unavailable any other time)
  final bool isExclusive;

  SeasonalCosmeticInfo({
    required this.cosmeticId,
    required this.season,
    required this.displayName,
    required this.rarityBoost,
    required this.isExclusive,
  });

  /// Get availability window text
  String getAvailabilityWindow() {
    return '${season.startDate} - ${season.endDate}';
  }

  /// Check if currently obtainable
  bool isCurrentlyObtainable() {
    return season.isActive();
  }
}
