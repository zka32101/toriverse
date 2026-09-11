import 'package:toriverse/shared/models/cosmetic_item.dart';

/// Service for cosmetic showcase and collection comparison
///
/// Manages display of cosmetic collections, statistics, and comparisons.
class CosmeticShowcaseService {
  /// Calculate collection statistics
  ///
  /// Returns counts and rarity breakdown of user's cosmetics.
  CosmeticCollectionStats calculateStats(
    List<CosmeticItem> ownedCosmetics,
  ) {
    final totalOwned = ownedCosmetics.length;

    final byRarity = <CosmeticRarity, int>{
      CosmeticRarity.common: 0,
      CosmeticRarity.rare: 0,
      CosmeticRarity.limited: 0,
    };

    final byType = <CosmeticType, int>{
      CosmeticType.board: 0,
      CosmeticType.stoneBlack: 0,
      CosmeticType.stoneWhite: 0,
      CosmeticType.stoneRed: 0,
    };

    for (final cosmetic in ownedCosmetics) {
      byRarity[cosmetic.rarity] = (byRarity[cosmetic.rarity] ?? 0) + 1;
      byType[cosmetic.type] = (byType[cosmetic.type] ?? 0) + 1;
    }

    return CosmeticCollectionStats(
      totalOwned: totalOwned,
      byRarity: byRarity,
      byType: byType,
      mostRecentPurchaseDate: _getMostRecentPurchaseDate(ownedCosmetics),
    );
  }

  /// Get date of most recent purchase
  DateTime? _getMostRecentPurchaseDate(List<CosmeticItem> cosmetics) {
    if (cosmetics.isEmpty) return null;
    return cosmetics.reduce((a, b) {
      final aDate = a.purchasedAt ?? DateTime(1970);
      final bDate = b.purchasedAt ?? DateTime(1970);
      return aDate.isAfter(bDate) ? a : b;
    }).purchasedAt;
  }

  /// Calculate collection completion percentage
  ///
  /// Returns percentage of all available cosmetics owned.
  double calculateCompletionPercentage(
    int ownedCount,
    int totalAvailable,
  ) {
    if (totalAvailable == 0) return 0;
    return (ownedCount / totalAvailable * 100).clamp(0, 100);
  }

  /// Get cosmetics for showcase display
  ///
  /// Organizes cosmetics by rarity for visual showcase.
  CosmeticShowcaseDisplay getShowcaseDisplay(
    List<CosmeticItem> ownedCosmetics,
    List<CosmeticItem> allAvailable,
  ) {
    // Sort by rarity and acquisition date
    final sorted = List<CosmeticItem>.from(ownedCosmetics)..sort((a, b) {
      final rarityOrder = {
        CosmeticRarity.limited: 0,
        CosmeticRarity.rare: 1,
        CosmeticRarity.common: 2,
      };
      final aOrder = rarityOrder[a.rarity] ?? 3;
      final bOrder = rarityOrder[b.rarity] ?? 3;

      if (aOrder != bOrder) return aOrder.compareTo(bOrder);

      final aDate = a.purchasedAt ?? DateTime(1970);
      final bDate = b.purchasedAt ?? DateTime(1970);
      return bDate.compareTo(aDate); // Newest first
    });

    // Group by rarity for display
    final byRarity = <CosmeticRarity, List<CosmeticItem>>{
      CosmeticRarity.limited: [],
      CosmeticRarity.rare: [],
      CosmeticRarity.common: [],
    };

    for (final cosmetic in sorted) {
      byRarity[cosmetic.rarity]?.add(cosmetic);
    }

    return CosmeticShowcaseDisplay(
      totalOwned: ownedCosmetics.length,
      totalAvailable: allAvailable.length,
      limitedEditions: byRarity[CosmeticRarity.limited] ?? [],
      rareCosmetics: byRarity[CosmeticRarity.rare] ?? [],
      commonCosmetics: byRarity[CosmeticRarity.common] ?? [],
    );
  }

  /// Compare two users' collections
  ///
  /// Returns comparison statistics.
  CollectionComparison compareCollections(
    List<CosmeticItem> userACosmetics,
    List<CosmeticItem> userBCosmetics,
  ) {
    final userASet = userACosmetics.map((c) => c.id).toSet();
    final userBSet = userBCosmetics.map((c) => c.id).toSet();

    final userAOnly = userASet.difference(userBSet);
    final userBOnly = userBSet.difference(userASet);
    final shared = userASet.intersection(userBSet);

    return CollectionComparison(
      userACount: userACosmetics.length,
      userBCount: userBCosmetics.length,
      sharedCount: shared.length,
      userAUniqueCount: userAOnly.length,
      userBUniqueCount: userBOnly.length,
      userACompletion: userACosmetics.length,
      userBCompletion: userBCosmetics.length,
    );
  }

  /// Generate shareable collection summary
  ///
  /// Creates text summary for sharing on social media.
  String generateShareText(
    String displayName,
    CosmeticCollectionStats stats,
    int completionPercentage,
  ) {
    return '''🎨 $displayName's Cosmetic Collection

総数: ${stats.totalOwned}個
├ 限定: ${stats.byRarity[CosmeticRarity.limited] ?? 0}
├ レア: ${stats.byRarity[CosmeticRarity.rare] ?? 0}
└ コモン: ${stats.byRarity[CosmeticRarity.common] ?? 0}

進捗: $completionPercentage%

#トリバース #cosmetics''';
  }

  /// Get collection achievements
  ///
  /// Returns list of achievements based on collection.
  List<CollectionAchievement> getAchievements(
    List<CosmeticItem> ownedCosmetics,
    List<CosmeticItem> allAvailable,
  ) {
    final achievements = <CollectionAchievement>[];
    final stats = calculateStats(ownedCosmetics);

    // All common cosmetics achievement
    final commonAvailable =
        allAvailable.where((c) => c.rarity == CosmeticRarity.common).length;
    if (stats.byRarity[CosmeticRarity.common] == commonAvailable) {
      achievements.add(CollectionAchievement(
        id: 'collect_all_common',
        title: 'Common Collector',
        description: 'Collect all common cosmetics',
        earnedAt: DateTime.now(),
      ));
    }

    // First limited edition
    if ((stats.byRarity[CosmeticRarity.limited] ?? 0) > 0) {
      achievements.add(CollectionAchievement(
        id: 'first_limited',
        title: 'Exclusive Owner',
        description: 'Own a limited edition cosmetic',
        earnedAt: DateTime.now(),
      ));
    }

    // 10 cosmetics milestone
    if (stats.totalOwned >= 10) {
      achievements.add(CollectionAchievement(
        id: 'collector_10',
        title: 'Dedicated Collector',
        description: 'Own 10+ cosmetics',
        earnedAt: DateTime.now(),
      ));
    }

    // 25 cosmetics milestone
    if (stats.totalOwned >= 25) {
      achievements.add(CollectionAchievement(
        id: 'collector_25',
        title: 'Master Collector',
        description: 'Own 25+ cosmetics',
        earnedAt: DateTime.now(),
      ));
    }

    return achievements;
  }
}

/// Collection statistics
class CosmeticCollectionStats {
  /// Total cosmetics owned
  final int totalOwned;

  /// Count by rarity
  final Map<CosmeticRarity, int> byRarity;

  /// Count by type
  final Map<CosmeticType, int> byType;

  /// Date of most recent purchase
  final DateTime? mostRecentPurchaseDate;

  CosmeticCollectionStats({
    required this.totalOwned,
    required this.byRarity,
    required this.byType,
    this.mostRecentPurchaseDate,
  });
}

/// Formatted showcase display
class CosmeticShowcaseDisplay {
  /// Total owned
  final int totalOwned;

  /// Total available in catalog
  final int totalAvailable;

  /// Limited edition cosmetics
  final List<CosmeticItem> limitedEditions;

  /// Rare cosmetics
  final List<CosmeticItem> rareCosmetics;

  /// Common cosmetics
  final List<CosmeticItem> commonCosmetics;

  CosmeticShowcaseDisplay({
    required this.totalOwned,
    required this.totalAvailable,
    required this.limitedEditions,
    required this.rareCosmetics,
    required this.commonCosmetics,
  });

  /// Get completion percentage
  double getCompletionPercentage() {
    if (totalAvailable == 0) return 0;
    return (totalOwned / totalAvailable * 100);
  }
}

/// Collection comparison between two users
class CollectionComparison {
  /// User A collection size
  final int userACount;

  /// User B collection size
  final int userBCount;

  /// Cosmetics both users own
  final int sharedCount;

  /// Cosmetics only user A owns
  final int userAUniqueCount;

  /// Cosmetics only user B owns
  final int userBUniqueCount;

  /// User A's completion
  final int userACompletion;

  /// User B's completion
  final int userBCompletion;

  CollectionComparison({
    required this.userACount,
    required this.userBCount,
    required this.sharedCount,
    required this.userAUniqueCount,
    required this.userBUniqueCount,
    required this.userACompletion,
    required this.userBCompletion,
  });

  /// Determine which user has larger collection
  String getLeader() {
    if (userACount > userBCount) return 'A';
    if (userBCount > userACount) return 'B';
    return 'Tie';
  }

  /// Get lead size
  int getLeadSize() {
    return (userACount - userBCount).abs();
  }
}

/// Collection achievement
class CollectionAchievement {
  /// Achievement ID
  final String id;

  /// Display title
  final String title;

  /// Description
  final String description;

  /// When earned
  final DateTime earnedAt;

  CollectionAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.earnedAt,
  });
}
