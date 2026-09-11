import 'package:riverpod/riverpod.dart';
import '../services/offline_queue_analytics_service.dart';

/// Provides the OfflineQueueAnalyticsService singleton
/// Used for tracking offline queue performance metrics
final offlineQueueAnalyticsProvider =
    Provider<OfflineQueueAnalyticsService>((ref) {
  return OfflineQueueAnalyticsService();
});
