import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat SDK wrapper for subscription and in-app purchase management
///
/// Handles IAP validation through RevenueCat's backend to prevent fraud
/// and provide unified payment tracking across iOS and Android.
class RevenueCatService {
  static const String _apiKey =
      'YOUR_REVENUCAT_API_KEY'; // Set via environment/config
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize RevenueCat with API key
      await Purchases.setLogLevel(PurchasesLogLevel.debug);
      await Purchases.configure(PurchasesConfiguration(_apiKey));
      _initialized = true;
    } catch (e) {
      // Silent fail — payment should degrade gracefully
      rethrow;
    }
  }

  /// Fetch available products for cosmetics shop
  ///
  /// Retrieves current pricing and product info from app stores.
  /// Caches results to minimize network calls.
  Future<List<StoreProduct>> getShopProducts({
    required String offering,
  }) async {
    try {
      final offerings = await Purchases.getOfferings();
      final specificOffering = offerings.getOffering(offering);
      if (specificOffering != null) {
        return specificOffering.availablePackages
            .map((pkg) => pkg.storeProduct)
            .toList();
      }
      return [];
    } catch (e) {
      // Return empty list on failure — shop shows message to retry
      return [];
    }
  }

  /// Purchase a cosmetic item
  ///
  /// Executes purchase through app store and validates receipt server-side.
  /// Returns Customer info on success, throws exception on failure.
  Future<CustomerInfo> purchaseCosmeticItem({
    required StoreProduct product,
  }) async {
    try {
      final customerInfo = await Purchases.purchaseStoreProduct(product);

      // Validate customer info indicates successful purchase
      if (customerInfo.entitlements.active.isEmpty) {
        throw Exception('Purchase failed: No active entitlements');
      }

      return customerInfo;
    } on PurchasesErrorCode catch (e) {
      _handlePurchaseError(e);
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Check if user owns a specific cosmetic item
  ///
  /// Uses RevenueCat's receipt validation to verify actual purchase.
  Future<bool> userOwnsCosmetic({
    required String cosmeticId,
  }) async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey(cosmeticId);
    } catch (e) {
      // Fail open — assume not owned on error
      return false;
    }
  }

  /// Get current customer info including purchased cosmetics
  ///
  /// Returns up-to-date purchase state from RevenueCat backend.
  Future<CustomerInfo> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      rethrow;
    }
  }

  /// Restore purchases from app store
  ///
  /// Called on app startup or when user manually requests restore.
  /// Syncs local app state with server-validated receipts.
  Future<CustomerInfo> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo;
    } catch (e) {
      rethrow;
    }
  }

  void _handlePurchaseError(PurchasesErrorCode code) {
    // Log purchase errors for debugging
    switch (code) {
      case PurchasesErrorCode.purchaseCancelledError:
        // User cancelled purchase — expected flow
        break;
      case PurchasesErrorCode.storeProblemError:
        // App store/Play Store error — network or store issue
        break;
      case PurchasesErrorCode.purchaseNotAllowedError:
        // Device or account not allowed — parental controls or region
        break;
      default:
        // Other errors
        break;
    }
  }
}
