import 'package:freezed_annotation/freezed_annotation.dart';

part 'monetization.freezed.dart';
part 'monetization.g.dart';

/// Creator earnings aggregated by time period
@freezed
class CreatorEarnings with _$CreatorEarnings {
  const factory CreatorEarnings({
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
  }) = _CreatorEarnings;

  factory CreatorEarnings.fromJson(Map<String, dynamic> json) =>
      _$CreatorEarningsFromJson(json);
}

/// Subscription tier configuration
@freezed
class SubscriptionTier with _$SubscriptionTier {
  const factory SubscriptionTier({
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
    @Default(0) int currentSubscribers,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SubscriptionTier;

  factory SubscriptionTier.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionTierFromJson(json);
}

/// User's active subscription to a creator
@freezed
class UserSubscription with _$UserSubscription {
  const factory UserSubscription({
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
    @Default(false) bool autoRenew,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserSubscription;

  factory UserSubscription.fromJson(Map<String, dynamic> json) =>
      _$UserSubscriptionFromJson(json);
}

/// Virtual gift item definition
@freezed
class VirtualGift with _$VirtualGift {
  const factory VirtualGift({
    required String id,
    required String name,
    required String description,
    required String assetUrl,
    required int priceJpy,
    required int creatorRevenueJpy,
    required String rarity, // common, rare, legendary
    @Default(true) bool isAvailable,
    required int totalGiftsSent,
    required DateTime createdAt,
  }) = _VirtualGift;

  factory VirtualGift.fromJson(Map<String, dynamic> json) =>
      _$VirtualGiftFromJson(json);
}

/// Record of virtual gift purchase and sending
@freezed
class GiftTransaction with _$GiftTransaction {
  const factory GiftTransaction({
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
  }) = _GiftTransaction;

  factory GiftTransaction.fromJson(Map<String, dynamic> json) =>
      _$GiftTransactionFromJson(json);
}

/// Subscription payment record
@freezed
class SubscriptionTransaction with _$SubscriptionTransaction {
  const factory SubscriptionTransaction({
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
  }) = _SubscriptionTransaction;

  factory SubscriptionTransaction.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionTransactionFromJson(json);
}

/// Payout request and status
@freezed
class CreatorPayout with _$CreatorPayout {
  const factory CreatorPayout({
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
  }) = _CreatorPayout;

  factory CreatorPayout.fromJson(Map<String, dynamic> json) =>
      _$CreatorPayoutFromJson(json);
}

/// Creator's payment method for payouts
@freezed
class PaymentMethod with _$PaymentMethod {
  const factory PaymentMethod({
    required String id,
    required String creatorId,
    required String type, // bank_transfer, paypal, stripe
    required String accountHolder,
    required String? accountNumber, // encrypted
    required String? routingNumber, // encrypted
    required String? paypalEmail,
    required String? stripeAccountId,
    required String currency, // JPY, USD, EUR
    @Default(false) bool isDefault,
    @Default(true) bool isVerified,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PaymentMethod;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodFromJson(json);
}

/// Creator's payout frequency settings
@freezed
class PayoutSchedule with _$PayoutSchedule {
  const factory PayoutSchedule({
    required String id,
    required String creatorId,
    required String frequency, // weekly, biweekly, monthly
    required double minimumPayoutThreshold, // JPY
    required bool autoPayoutEnabled,
    required DateTime nextPayoutDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PayoutSchedule;

  factory PayoutSchedule.fromJson(Map<String, dynamic> json) =>
      _$PayoutScheduleFromJson(json);
}

/// Revenue split configuration
@freezed
class RevenueAllocation with _$RevenueAllocation {
  const factory RevenueAllocation({
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
  }) = _RevenueAllocation;

  factory RevenueAllocation.fromJson(Map<String, dynamic> json) =>
      _$RevenueAllocationFromJson(json);
}

/// Detailed analytics for creator earnings
@freezed
class CreatorAnalytics with _$CreatorAnalytics {
  const factory CreatorAnalytics({
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
  }) = _CreatorAnalytics;

  factory CreatorAnalytics.fromJson(Map<String, dynamic> json) =>
      _$CreatorAnalyticsFromJson(json);
}

/// Monetization milestones and achievements
@freezed
class MonetizationAchievement with _$MonetizationAchievement {
  const factory MonetizationAchievement({
    required String id,
    required String creatorId,
    required String achievementType, // first_sub, 100_subs, 1000_subs, 10k_earnings
    required String title,
    required String description,
    required String badgeAssetUrl,
    required DateTime unlockedAt,
    required DateTime createdAt,
  }) = _MonetizationAchievement;

  factory MonetizationAchievement.fromJson(Map<String, dynamic> json) =>
      _$MonetizationAchievementFromJson(json);
}

/// Multi-currency exchange rates
@freezed
class CurrencyExchange with _$CurrencyExchange {
  const factory CurrencyExchange({
    required String id,
    required String fromCurrency,
    required String toCurrency,
    required double rate,
    required DateTime rateDate,
    required DateTime lastUpdatedAt,
  }) = _CurrencyExchange;

  factory CurrencyExchange.fromJson(Map<String, dynamic> json) =>
      _$CurrencyExchangeFromJson(json);
}

/// Tax information for creators
@freezed
class TaxInfo with _$TaxInfo {
  const factory TaxInfo({
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
  }) = _TaxInfo;

  factory TaxInfo.fromJson(Map<String, dynamic> json) =>
      _$TaxInfoFromJson(json);
}

/// Referral bonus tracking
@freezed
class ReferralBonus with _$ReferralBonus {
  const factory ReferralBonus({
    required String id,
    required String referrerCreatorId,
    required String referredUserId,
    required String referralCode,
    required String status, // pending, completed, cancelled
    required double bonusAmountJpy,
    required DateTime referralDate,
    required DateTime? completionDate,
    required DateTime createdAt,
  }) = _ReferralBonus;

  factory ReferralBonus.fromJson(Map<String, dynamic> json) =>
      _$ReferralBonusFromJson(json);
}

/// Creator earnings configuration
@freezed
class MonetizationSettings with _$MonetizationSettings {
  const factory MonetizationSettings({
    required String id,
    required String creatorId,
    @Default(true) bool subscriptionsEnabled,
    @Default(true) bool giftsEnabled,
    @Default(true) bool clipsMonetizationEnabled,
    @Default(true) bool referralsEnabled,
    required String preferredPayoutCurrency,
    required String minimumPayoutCurrencyType,
    @Default(false) bool taxInfoVerified,
    @Default(false) bool paymentMethodVerified,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MonetizationSettings;

  factory MonetizationSettings.fromJson(Map<String, dynamic> json) =>
      _$MonetizationSettingsFromJson(json);
}
