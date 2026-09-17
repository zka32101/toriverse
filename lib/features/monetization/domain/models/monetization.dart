
/// Creator earnings aggregated by time period
class CreatorEarnings {
  const CreatorEarnings({
    required String id,
    required String creatorId,
    required double totalEarnings,
    required double subscriptionRevenue,
    required double giftRevenue,
    required double clipRevenue,
    required double platformFeeDeducted,
    required double taxDeducted,
    required double netEarnings,
    required int activeSubscribers,
    required int totalGiftsPurchased,
    required int totalClipsMonetized,
    required DateTime period,
    required DateTime updatedAt,
  });
}

/// Subscription tier configuration
class SubscriptionTier {
  const SubscriptionTier({
    required String id,
    required String creatorId,
    required String name,
    required String description,
    required int monthlyPriceJpy,
    required int? annualPriceJpy,
    required int tier, // 1=basic, 2=premium, 3=vip
    required bool includeExclusiveClips,
    required bool includePriorityChat,
    required bool includeCustomEmoji,
    required bool includeCreatorBadge,
    required bool includeEarlyAccess,
    required int maxSubscriberLimit,
    int currentSubscribers,
    required DateTime createdAt,
    required DateTime updatedAt,
  });
}

/// User's active subscription to a creator
class UserSubscription {
  const UserSubscription({
    required String id,
    required String userId,
    required String creatorId,
    required String tierId,
    required String status, // active, paused, cancelled, expired
    required DateTime subscriptionStartDate,
    required DateTime subscriptionEndDate,
    required DateTime? nextBillingDate,
    required int priceJpy,
    required String billingCycle, // monthly, annual
    bool autoRenew,
    required DateTime createdAt,
    required DateTime updatedAt,
  });
}

/// Virtual gift item definition
class VirtualGift {
  const VirtualGift({
    required String id,
    required String name,
    required String description,
    required String assetUrl,
    required int priceJpy,
    required int creatorRevenueJpy,
    required String rarity, // common, rare, legendary
    bool isAvailable,
    required int totalGiftsSent,
    required DateTime createdAt,
  });
}

/// Record of virtual gift purchase and sending
class GiftTransaction {
  const GiftTransaction({
    required String id,
    required String giftId,
    required String senderId,
    required String receiverCreatorId,
    required int quantity,
    required int totalPriceJpy,
    required int creatorRevenueJpy,
    required String? personalMessage,
    required DateTime sentAt,
    required DateTime? deliveredAt,
    required DateTime createdAt,
  });
}

/// Subscription payment record
class SubscriptionTransaction {
  const SubscriptionTransaction({
    required String id,
    required String subscriptionId,
    required String userId,
    required String creatorId,
    required int amountJpy,
    required int creatorRevenueJpy,
    required String paymentMethod,
    required String status, // completed, pending, failed, refunded
    required DateTime billingDate,
    required DateTime? paidDate,
    required String? failureReason,
    required int? retryCount,
    required DateTime createdAt,
  });
}

/// Payout request and status
class CreatorPayout {
  const CreatorPayout({
    required String id,
    required String creatorId,
    required double amountJpy,
    required String paymentMethodId,
    required String status, // pending, processing, completed, failed, cancelled
    required DateTime requestedAt,
    required DateTime? processedAt,
    required DateTime? completedAt,
    required String? failureReason,
    required String? transactionReference,
    required DateTime createdAt,
  });
}

/// Creator's payment method for payouts
class PaymentMethod {
  const PaymentMethod({
    required String id,
    required String creatorId,
    required String type, // bank_transfer, paypal, stripe
    required String accountHolder,
    required String? accountNumber, // encrypted
    required String? routingNumber, // encrypted
    required String? paypalEmail,
    required String? stripeAccountId,
    required String currency, // JPY, USD, EUR
    bool isDefault,
    bool isVerified,
    required DateTime createdAt,
    required DateTime updatedAt,
  });
}

/// Creator's payout frequency settings
class PayoutSchedule {
  const PayoutSchedule({
    required String id,
    required String creatorId,
    required String frequency, // weekly, biweekly, monthly
    required double minimumPayoutThreshold, // JPY
    required bool autoPayoutEnabled,
    required DateTime nextPayoutDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  });
}

/// Revenue split configuration
class RevenueAllocation {
  const RevenueAllocation({
    required String id,
    required String creatorId,
    required double subscriptionPlatformFeePercent,
    required double giftPlatformFeePercent,
    required double clipPlatformFeePercent,
    required double creatorSubscriptionPercent,
    required double creatorGiftPercent,
    required double creatorClipPercent,
    required DateTime effectiveDate,
    required DateTime createdAt,
  });
}

/// Detailed analytics for creator earnings
class CreatorAnalytics {
  const CreatorAnalytics({
    required String id,
    required String creatorId,
    required int totalSubscribers,
    required int newSubscribersThisPeriod,
    required int churnedSubscribersThisPeriod,
    required double churnRate,
    required double averageSubscriberLTV,
    required int uniqueGiftPurchasers,
    required int totalGiftsReceived,
    required double averageGiftValue,
    required int totalMonetizedClips,
    required double averageClipEarnings,
    required double subscriptionRevenueTrend,
    required double giftRevenueTrend,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DateTime createdAt,
  });
}

/// Monetization milestones and achievements
class MonetizationAchievement {
  const MonetizationAchievement({
    required String id,
    required String creatorId,
    required String achievementType, // first_sub, 100_subs, 1000_subs, 10k_earnings
    required String title,
    required String description,
    required String badgeAssetUrl,
    required DateTime unlockedAt,
    required DateTime createdAt,
  });
}

/// Multi-currency exchange rates
class CurrencyExchange {
  const CurrencyExchange({
    required String id,
    required String fromCurrency,
    required String toCurrency,
    required double rate,
    required DateTime rateDate,
    required DateTime lastUpdatedAt,
  });
}

/// Tax information for creators
class TaxInfo {
  const TaxInfo({
    required String id,
    required String creatorId,
    required String taxId, // encrypted
    required String countryOfTaxResidence,
    required double estimatedAnnualIncome,
    required String taxFilingStatus, // individual, business
    required bool hasFiledTaxReturn,
    required DateTime lastTaxFilingDate,
    required String taxDocumentUrl, // encrypted
    required DateTime createdAt,
    required DateTime updatedAt,
  });
}

/// Referral bonus tracking
class ReferralBonus {
  const ReferralBonus({
    required String id,
    required String referrerCreatorId,
    required String referredUserId,
    required String referralCode,
    required String status, // pending, completed, cancelled
    required double bonusAmountJpy,
    required DateTime referralDate,
    required DateTime? completionDate,
    required DateTime createdAt,
  });
}

/// Creator earnings configuration
class MonetizationSettings {
  const MonetizationSettings({
    required String id,
    required String creatorId,
    bool subscriptionsEnabled,
    bool giftsEnabled,
    bool clipsMonetizationEnabled,
    bool referralsEnabled,
    required String preferredPayoutCurrency,
    required String minimumPayoutCurrencyType,
    bool taxInfoVerified,
    bool paymentMethodVerified,
    required DateTime createdAt,
    required DateTime updatedAt,
  });
}
