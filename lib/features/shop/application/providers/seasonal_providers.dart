import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:toriverse/features/shop/domain/services/seasonal_cosmetics_service.dart';
import 'package:toriverse/shared/models/cosmetic_item.dart';
import 'cosmetics_providers.dart';

/// Provider for SeasonalCosmeticsService
final seasonalCosmeticsServiceProvider = Provider<SeasonalCosmeticsService>((ref) {
  return SeasonalCosmeticsService();
});

/// Provider for current season
final currentSeasonProvider = Provider<Season?>((ref) {
  final service = ref.watch(seasonalCosmeticsServiceProvider);
  return service.getCurrentSeason();
});

/// Provider for next upcoming season
final nextSeasonProvider = Provider<Season?>((ref) {
  final service = ref.watch(seasonalCosmeticsServiceProvider);
  return service.getNextSeason();
});

/// Provider for cosmetics in current season
final currentSeasonalCosmeticsProvider =
    FutureProvider<List<CosmeticItem>>((ref) async {
  final service = ref.watch(seasonalCosmeticsServiceProvider);
  final allCosmetics = await ref.watch(availableCosmeticsProvider.future);
  final currentSeason = ref.watch(currentSeasonProvider);

  if (currentSeason == null) return [];

  return allCosmetics
      .where((cosmetic) => currentSeason.featuredCosmetics.contains(cosmetic.id))
      .toList();
});

/// Provider for cosmetics expiring within N days
final cosmeticsExpiringProvider =
    FutureProvider.family<List<String>, int>((ref, days) {
  final service = ref.watch(seasonalCosmeticsServiceProvider);
  return service.getCosmeticsExpiringWithin(days);
});

/// Provider for archived (unavailable) cosmetics
final archivedCosmeticsProvider =
    FutureProvider<List<CosmeticItem>>((ref) async {
  final service = ref.watch(seasonalCosmeticsServiceProvider);
  final allCosmetics = await ref.watch(availableCosmeticsProvider.future);
  final archived = service.getArchivedCosmetics();

  return allCosmetics
      .where((cosmetic) => archived.contains(cosmetic.id))
      .toList();
});

/// Provider for days until current season ends
final daysUntilSeasonEndProvider = Provider<int>((ref) {
  final service = ref.watch(seasonalCosmeticsServiceProvider);
  final currentSeason = ref.watch(currentSeasonProvider);

  if (currentSeason == null) return 0;

  return service.getDaysUntilSeasonEnd(currentSeason);
});

/// Provider for availability status text
final cosmeticAvailabilityProvider =
    Provider.family<String, String>((ref, cosmeticId) {
  final service = ref.watch(seasonalCosmeticsServiceProvider);
  return service.getAvailabilityStatus(cosmeticId);
});

/// State notifier for seasonal operations
class SeasonalNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseAnalytics _analytics;
  final SeasonalCosmeticsService _seasonalService;

  SeasonalNotifier({
    required FirebaseAnalytics analytics,
    required SeasonalCosmeticsService seasonalService,
  })  : _analytics = analytics,
        _seasonalService = seasonalService,
        super(const AsyncValue.data(null));

  /// Log seasonal cosmetic viewed event
  Future<void> logSeasonalCosmeticViewed({
    required String cosmeticId,
    required int seasonId,
    required int daysUntilExpiration,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _analytics.logEvent(
        name: 'seasonal_cosmetic_viewed',
        parameters: {
          'cosmetic_id': cosmeticId,
          'season_id': seasonId,
          'days_until_expiration': daysUntilExpiration,
        },
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Log seasonal cosmetic purchased event
  Future<void> logSeasonalCosmeticPurchased({
    required String cosmeticId,
    required int seasonId,
    required int priceYen,
    required int daysLeft,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _analytics.logEvent(
        name: 'seasonal_cosmetic_purchased',
        parameters: {
          'cosmetic_id': cosmeticId,
          'season_id': seasonId,
          'price_yen': priceYen,
          'days_left': daysLeft,
        },
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Log expiration notification event
  Future<void> logExpirationNotified({
    required String cosmeticId,
    required int daysUntilExpiration,
    required List<String> platforms,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _analytics.logEvent(
        name: 'seasonal_expiration_notified',
        parameters: {
          'cosmetic_id': cosmeticId,
          'days_until_expiration': daysUntilExpiration,
          'platforms': platforms.join(','),
        },
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Log season rotation event
  Future<void> logSeasonRotated({
    required int previousSeasonId,
    required int newSeasonId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _analytics.logEvent(
        name: 'season_rotated',
        parameters: {
          'previous_season_id': previousSeasonId,
          'new_season_id': newSeasonId,
        },
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for seasonal operations
final seasonalNotifierProvider =
    StateNotifierProvider<SeasonalNotifier, AsyncValue<void>>((ref) {
  return SeasonalNotifier(
    analytics: FirebaseAnalytics.instance,
    seasonalService: ref.watch(seasonalCosmeticsServiceProvider),
  );
});
