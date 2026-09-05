import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/leaderboards_and_social_repository.dart';

part 'repository_provider.g.dart';

// ============================================================================
// SINGLETON REPOSITORY PROVIDER
// ============================================================================

@riverpod
LeaderboardsAndSocialRepository leaderboardsAndSocialRepositoryProvider(
  LeaderboardsAndSocialRepositoryProviderRef ref,
) {
  return LeaderboardsAndSocialRepository(
    firestore: FirebaseFirestore.instance,
    analytics: FirebaseAnalytics.instance,
  );
}
