import 'package:purchases_flutter/purchases_flutter.dart';

/// Repository for subscription status management via RevenueCat
/// RevenueCat handles App Store/Play Store entitlements centrally
/// This layer abstracts the RevenueCat SDK for the app
class SubscriptionRepository {
  static const String rankPassEntitlementId = 'rank_pass';

  SubscriptionRepository();

  /// Initialize RevenueCat SDK
  /// Call this once at app startup
  Future<void> initialize(String revenueCatApiKey) async {
    await Purchases.setup(
      PurchasesConfiguration(revenueCatApiKey),
    );
  }

  /// Check if user has active rank pass subscription
  /// Returns true if entitlement is active, false otherwise
  Future<bool> hasActiveRankPass(String userId) async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final active = customerInfo.entitlements.all[rankPassEntitlementId]?.isActive ?? false;
      return active;
    } on PurchasesException catch (e) {
      print('Error checking rank pass: $e');
      return false;
    }
  }

  /// Get active entitlements for user
  /// Returns a list of entitlement IDs that are currently active
  Future<List<String>> getActiveEntitlements(String userId) async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.map((e) => e.identifier).toList();
    } on PurchasesException catch (e) {
      print('Error getting entitlements: $e');
      return [];
    }
  }

  /// Get subscription info (expiration date, etc)
  Future<EntitlementInfo?> getRankPassInfo() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[rankPassEntitlementId];
    } on PurchasesException catch (e) {
      print('Error getting rank pass info: $e');
      return null;
    }
  }

  /// Purchase rank pass
  /// Handles the purchase flow and RevenueCat entitlement granting
  Future<bool> purchaseRankPass({
    required String productId, // 'rank_pass_monthly' or similar
  }) async {
    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;

      if (offering != null) {
        final product = offering.getPackage(productId);
        if (product != null) {
          await Purchases.purchasePackage(product);
          return true;
        }
      }
      return false;
    } on PurchasesException catch (e) {
      print('Error purchasing rank pass: $e');
      return false;
    }
  }

  /// Get available packages for purchase
  /// Returns offerings from RevenueCat
  Future<List<Package>> getAvailablePackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current?.availablePackages ?? [];
    } on PurchasesException catch (e) {
      print('Error getting packages: $e');
      return [];
    }
  }

  /// Restore purchases (for lost transactions)
  /// Called when user changes device or reinstalls app
  Future<bool> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
      return true;
    } on PurchasesException catch (e) {
      print('Error restoring purchases: $e');
      return false;
    }
  }

  /// Listen for entitlement changes
  /// Emits whenever subscription status changes (via RevenueCat webhook)
  Stream<List<String>> watchActiveEntitlements() {
    // This would use a Riverpod notifier in practice
    // For now, returning a stream that can be monitored
    return Stream.periodic(
      const Duration(minutes: 5),
      (_) => getActiveEntitlements(''),
    ).asyncExpand((future) => Stream.fromFuture(future));
  }
}
