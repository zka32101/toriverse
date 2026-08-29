import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/remote_config_service.dart';

/// Riverpod provider for Remote Config service singleton
///
/// Provides access to tunable game balance parameters throughout the app.
/// Initialize via remoteConfigProvider during app startup.
final remoteConfigProvider = FutureProvider<RemoteConfigService>((ref) async {
  final service = RemoteConfigService();
  await service.initialize();
  return service;
});

/// Provider for submission window timeout in milliseconds
/// Default: 30000ms (30 seconds)
final submissionTimeoutProvider = FutureProvider<int>((ref) async {
  final config = await ref.watch(remoteConfigProvider.future);
  return config.getSubmissionWindowTimeoutMs();
});

/// Provider for weak bonus stone difference threshold
/// Default: 8 stones
final weakBonusThresholdProvider = FutureProvider<int>((ref) async {
  final config = await ref.watch(remoteConfigProvider.future);
  return config.getWeakBonusStoneDiffThreshold();
});

/// Provider for weak bonus round threshold
/// Default: 11 rounds
final weakBonusRoundThresholdProvider = FutureProvider<int>((ref) async {
  final config = await ref.watch(remoteConfigProvider.future);
  return config.getWeakBonusRoundThreshold();
});

/// Provider for rescue card consecutive attacks threshold
/// Default: 2
final rescueCardThresholdProvider = FutureProvider<int>((ref) async {
  final config = await ref.watch(remoteConfigProvider.future);
  return config.getRescueCardConsecutiveAttacksThreshold();
});

/// Provider for daily free rank match attempts
/// Default: 1
final dailyFreeRankMatchesProvider = FutureProvider<int>((ref) async {
  final config = await ref.watch(remoteConfigProvider.future);
  return config.getDailyFreeRankMatches();
});
