import 'package:riverpod/riverpod.dart';
import 'package:toriverse/features/monetization/data/repositories/monetization_repository.dart';
import 'package:toriverse/features/monetization/domain/models/monetization.dart';

// ==================== Repository Provider ====================

final monetizationRepositoryProvider = Provider(
  (ref) => MonetizationRepository(),
);

// ==================== Parameter Classes (Simple, no Freezed) ====================

class CreatorIdParam {
  const CreatorIdParam(this.creatorId);
  final String creatorId;

  @override
  int get hashCode => creatorId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CreatorIdParam && creatorId == other.creatorId;
}

class EarningsIdParam {
  const EarningsIdParam(this.creatorId, this.earningsId);
  final String creatorId;
  final String earningsId;

  @override
  int get hashCode => Object.hash(creatorId, earningsId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is EarningsIdParam && creatorId == other.creatorId && earningsId == other.earningsId;
}

class TierIdParam {
  const TierIdParam(this.creatorId, this.tierId);
  final String creatorId;
  final String tierId;

  @override
  int get hashCode => Object.hash(creatorId, tierId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TierIdParam && creatorId == other.creatorId && tierId == other.tierId;
}

class UserIdParam {
  const UserIdParam(this.userId);
  final String userId;

  @override
  int get hashCode => userId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserIdParam && userId == other.userId;
}

class SubscriptionIdParam {
  const SubscriptionIdParam(this.subscriptionId);
  final String subscriptionId;

  @override
  int get hashCode => subscriptionId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SubscriptionIdParam && subscriptionId == other.subscriptionId;
}

class UserCreatorParam {
  const UserCreatorParam(this.userId, this.creatorId);
  final String userId;
  final String creatorId;

  @override
  int get hashCode => Object.hash(userId, creatorId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserCreatorParam && userId == other.userId && creatorId == other.creatorId;
}

class GiftIdParam {
  const GiftIdParam(this.giftId);
  final String giftId;

  @override
  int get hashCode => giftId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is GiftIdParam && giftId == other.giftId;
}

class TransactionIdParam {
  const TransactionIdParam(this.transactionId);
  final String transactionId;

  @override
  int get hashCode => transactionId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TransactionIdParam && transactionId == other.transactionId;
}

class PayoutIdParam {
  const PayoutIdParam(this.creatorId, this.payoutId);
  final String creatorId;
  final String payoutId;

  @override
  int get hashCode => Object.hash(creatorId, payoutId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PayoutIdParam && creatorId == other.creatorId && payoutId == other.payoutId;
}

class PaymentMethodIdParam {
  const PaymentMethodIdParam(this.creatorId, this.methodId);
  final String creatorId;
  final String methodId;

  @override
  int get hashCode => Object.hash(creatorId, methodId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PaymentMethodIdParam && creatorId == other.creatorId && methodId == other.methodId;
}

class AnalyticsIdParam {
  const AnalyticsIdParam(this.creatorId, this.analyticsId);
  final String creatorId;
  final String analyticsId;

  @override
  int get hashCode => Object.hash(creatorId, analyticsId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AnalyticsIdParam && creatorId == other.creatorId && analyticsId == other.analyticsId;
}

// ==================== Creator Earnings ====================

final creatorEarningsProvider = FutureProvider.autoDispose
    .family<CreatorEarnings?, EarningsIdParam>((ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getCreatorEarnings(param.creatorId, param.earningsId);
});

final watchCreatorEarningsProvider =
    StreamProvider.autoDispose.family<CreatorEarnings?, EarningsIdParam>(
        (ref, param) {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.watchCreatorEarnings(param.creatorId, param.earningsId);
});

final creatorEarningsHistoryProvider =
    FutureProvider.autoDispose.family<List<CreatorEarnings>, CreatorIdParam>(
        (ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getEarningsHistory(param.creatorId);
});

final watchCreatorEarningsHistoryProvider =
    StreamProvider.autoDispose.family<List<CreatorEarnings>, CreatorIdParam>(
        (ref, param) {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.watchEarningsHistory(param.creatorId);
});

final createCreatorEarningsProvider =
    FutureProvider.family<CreatorEarnings, CreatorEarnings>((ref, earnings) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  final result = await repo.createCreatorEarnings(earnings);
  ref.invalidate(watchCreatorEarningsHistoryProvider(CreatorIdParam(earnings.creatorId)));
  return result;
});

// ==================== Subscription Tiers ====================

final subscriptionTierProvider =
    FutureProvider.autoDispose.family<SubscriptionTier?, TierIdParam>((ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getSubscriptionTier(param.creatorId, param.tierId);
});

final creatorSubscriptionTiersProvider =
    FutureProvider.autoDispose.family<List<SubscriptionTier>, CreatorIdParam>(
        (ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getCreatorSubscriptionTiers(param.creatorId);
});

final watchCreatorSubscriptionTiersProvider =
    StreamProvider.autoDispose.family<List<SubscriptionTier>, CreatorIdParam>(
        (ref, param) {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.watchCreatorSubscriptionTiers(param.creatorId);
});

final createSubscriptionTierProvider =
    FutureProvider.family<SubscriptionTier, SubscriptionTier>((ref, tier) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  final result = await repo.createSubscriptionTier(tier);
  ref.invalidate(watchCreatorSubscriptionTiersProvider(CreatorIdParam(tier.creatorId)));
  return result;
});

final updateSubscriptionTierProvider =
    FutureProvider.family<SubscriptionTier, SubscriptionTier>((ref, tier) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  final result = await repo.updateSubscriptionTier(tier);
  ref.invalidate(subscriptionTierProvider(TierIdParam(tier.creatorId, tier.id)));
  ref.invalidate(watchCreatorSubscriptionTiersProvider(CreatorIdParam(tier.creatorId)));
  return result;
});

// ==================== User Subscriptions ====================

final userSubscriptionProvider =
    FutureProvider.autoDispose.family<UserSubscription?, SubscriptionIdParam>(
        (ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getUserSubscription(param.subscriptionId);
});

final activeSubscriptionProvider =
    StreamProvider.autoDispose.family<UserSubscription?, UserCreatorParam>((ref, param) {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.watchActiveSubscription(param.userId, param.creatorId);
});

final userSubscriptionsProvider =
    FutureProvider.autoDispose.family<List<UserSubscription>, UserIdParam>((ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getUserSubscriptions(param.userId);
});

final creatorSubscribersProvider =
    FutureProvider.autoDispose.family<List<UserSubscription>, CreatorIdParam>((ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getCreatorSubscribers(param.creatorId);
});

final createUserSubscriptionProvider =
    FutureProvider.family<UserSubscription, UserSubscription>((ref, subscription) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  final result = await repo.createUserSubscription(subscription);
  ref.invalidate(userSubscriptionsProvider(UserIdParam(subscription.userId)));
  ref.invalidate(creatorSubscribersProvider(CreatorIdParam(subscription.creatorId)));
  ref.invalidate(activeSubscriptionProvider(
      UserCreatorParam(subscription.userId, subscription.creatorId)));
  return result;
});

final cancelUserSubscriptionProvider =
    FutureProvider.family<void, SubscriptionIdParam>((ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  final subscription = await repo.getUserSubscription(param.subscriptionId);
  if (subscription != null) {
    await repo.cancelUserSubscription(param.subscriptionId);
    ref.invalidate(userSubscriptionsProvider(UserIdParam(subscription.userId)));
    ref.invalidate(creatorSubscribersProvider(CreatorIdParam(subscription.creatorId)));
  }
});

// ==================== Virtual Gifts ====================

final virtualGiftProvider =
    FutureProvider.autoDispose.family<VirtualGift?, GiftIdParam>((ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getVirtualGift(param.giftId);
});

final availableVirtualGiftsProvider =
    FutureProvider.autoDispose<List<VirtualGift>>((ref) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getAvailableVirtualGifts();
});

final watchAvailableVirtualGiftsProvider =
    StreamProvider.autoDispose<List<VirtualGift>>((ref) {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.watchAvailableVirtualGifts();
});

// ==================== Gift Transactions ====================

final giftTransactionProvider =
    FutureProvider.autoDispose.family<GiftTransaction?, TransactionIdParam>(
        (ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getGiftTransaction(param.transactionId);
});

final creatorReceivedGiftsProvider =
    FutureProvider.autoDispose.family<List<GiftTransaction>, CreatorIdParam>((ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getCreatorReceivedGifts(param.creatorId);
});

final watchCreatorReceivedGiftsProvider =
    StreamProvider.autoDispose.family<List<GiftTransaction>, CreatorIdParam>((ref, param) {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.watchCreatorReceivedGifts(param.creatorId);
});

final userSentGiftsProvider =
    FutureProvider.autoDispose.family<List<GiftTransaction>, UserIdParam>((ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getUserSentGifts(param.userId);
});

final recordGiftTransactionProvider =
    FutureProvider.family<GiftTransaction, GiftTransaction>((ref, transaction) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  final result = await repo.recordGiftTransaction(transaction);
  ref.invalidate(
      creatorReceivedGiftsProvider(CreatorIdParam(transaction.receiverCreatorId)));
  ref.invalidate(
      userSentGiftsProvider(UserIdParam(transaction.senderId)));
  ref.invalidate(virtualGiftProvider(GiftIdParam(transaction.giftId)));
  return result;
});

// ==================== Subscription Transactions ====================

final subscriptionTransactionProvider =
    FutureProvider.autoDispose.family<SubscriptionTransaction?, TransactionIdParam>(
        (ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getSubscriptionTransaction(param.transactionId);
});

final creatorSubscriptionTransactionsProvider =
    FutureProvider.autoDispose.family<List<SubscriptionTransaction>, CreatorIdParam>(
        (ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getCreatorSubscriptionTransactions(param.creatorId);
});

final watchCreatorSubscriptionTransactionsProvider =
    StreamProvider.autoDispose.family<List<SubscriptionTransaction>, CreatorIdParam>(
        (ref, param) {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.watchCreatorSubscriptionTransactions(param.creatorId);
});

final recordSubscriptionTransactionProvider =
    FutureProvider.family<SubscriptionTransaction, SubscriptionTransaction>(
        (ref, transaction) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  final result = await repo.recordSubscriptionTransaction(transaction);
  ref.invalidate(
      creatorSubscriptionTransactionsProvider(CreatorIdParam(transaction.creatorId)));
  return result;
});

// ==================== Creator Payouts ====================

final creatorPayoutsProvider =
    FutureProvider.autoDispose.family<List<CreatorPayout>, CreatorIdParam>((ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getCreatorPayouts(param.creatorId);
});

final watchCreatorPayoutsProvider =
    StreamProvider.autoDispose.family<List<CreatorPayout>, CreatorIdParam>((ref, param) {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.watchCreatorPayouts(param.creatorId);
});

final payoutProvider =
    FutureProvider.autoDispose.family<CreatorPayout?, PayoutIdParam>((ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getPayout(param.creatorId, param.payoutId);
});

final requestPayoutProvider =
    FutureProvider.family<CreatorPayout, CreatorPayout>((ref, payout) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  final result = await repo.requestPayout(payout);
  ref.invalidate(creatorPayoutsProvider(CreatorIdParam(payout.creatorId)));
  return result;
});

final updatePayoutStatusProvider =
    FutureProvider.family<CreatorPayout, PayoutIdParam>((ref, param) async {
  // Note: Status should be passed differently - this is simplified
  final repo = ref.watch(monetizationRepositoryProvider);
  final payout = await repo.getPayout(param.creatorId, param.payoutId);
  if (payout != null) {
    ref.invalidate(creatorPayoutsProvider(CreatorIdParam(param.creatorId)));
  }
  return payout!;
});

// ==================== Payment Methods ====================

final creatorPaymentMethodsProvider =
    FutureProvider.autoDispose.family<List<PaymentMethod>, CreatorIdParam>((ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getCreatorPaymentMethods(param.creatorId);
});

final defaultPaymentMethodProvider =
    FutureProvider.autoDispose.family<PaymentMethod?, CreatorIdParam>((ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getDefaultPaymentMethod(param.creatorId);
});

final paymentMethodProvider = FutureProvider.autoDispose
    .family<PaymentMethod?, PaymentMethodIdParam>((ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getPaymentMethod(param.creatorId, param.methodId);
});

final addPaymentMethodProvider =
    FutureProvider.family<PaymentMethod, PaymentMethod>((ref, method) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  final result = await repo.addPaymentMethod(method);
  ref.invalidate(creatorPaymentMethodsProvider(CreatorIdParam(method.creatorId)));
  return result;
});

final updatePaymentMethodProvider =
    FutureProvider.family<PaymentMethod, PaymentMethod>((ref, method) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  final result = await repo.updatePaymentMethod(method);
  ref.invalidate(creatorPaymentMethodsProvider(CreatorIdParam(method.creatorId)));
  ref.invalidate(paymentMethodProvider(PaymentMethodIdParam(method.creatorId, method.id)));
  return result;
});

// ==================== Payout Schedule ====================

final payoutScheduleProvider =
    FutureProvider.autoDispose.family<PayoutSchedule?, CreatorIdParam>((ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getPayoutSchedule(param.creatorId);
});

final createPayoutScheduleProvider =
    FutureProvider.family<PayoutSchedule, PayoutSchedule>((ref, schedule) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  final result = await repo.createPayoutSchedule(schedule);
  ref.invalidate(payoutScheduleProvider(CreatorIdParam(schedule.creatorId)));
  return result;
});

final updatePayoutScheduleProvider =
    FutureProvider.family<PayoutSchedule, PayoutSchedule>((ref, schedule) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  final result = await repo.updatePayoutSchedule(schedule);
  ref.invalidate(payoutScheduleProvider(CreatorIdParam(schedule.creatorId)));
  return result;
});

// ==================== Creator Analytics ====================

final creatorAnalyticsProvider =
    FutureProvider.autoDispose.family<CreatorAnalytics?, AnalyticsIdParam>((ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getCreatorAnalytics(param.creatorId, param.analyticsId);
});

final creatorAnalyticsHistoryProvider =
    FutureProvider.autoDispose.family<List<CreatorAnalytics>, CreatorIdParam>(
        (ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getCreatorAnalyticsHistory(param.creatorId);
});

final watchCreatorAnalyticsHistoryProvider =
    StreamProvider.autoDispose.family<List<CreatorAnalytics>, CreatorIdParam>((ref, param) {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.watchCreatorAnalyticsHistory(param.creatorId);
});

final updateCreatorAnalyticsProvider =
    FutureProvider.family<CreatorAnalytics, CreatorAnalytics>((ref, analytics) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  final result = await repo.updateCreatorAnalytics(analytics);
  ref.invalidate(creatorAnalyticsHistoryProvider(CreatorIdParam(analytics.creatorId)));
  return result;
});

// ==================== Achievements ====================

final creatorAchievementsProvider =
    FutureProvider.autoDispose.family<List<MonetizationAchievement>, CreatorIdParam>(
        (ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getCreatorAchievements(param.creatorId);
});

final watchCreatorAchievementsProvider =
    StreamProvider.autoDispose.family<List<MonetizationAchievement>, CreatorIdParam>(
        (ref, param) {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.watchCreatorAchievements(param.creatorId);
});

final unlockAchievementProvider =
    FutureProvider.family<MonetizationAchievement, MonetizationAchievement>(
        (ref, achievement) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  final result = await repo.unlockAchievement(achievement);
  ref.invalidate(creatorAchievementsProvider(CreatorIdParam(achievement.creatorId)));
  return result;
});

// ==================== Settings & Tax ====================

final monetizationSettingsProvider =
    FutureProvider.autoDispose.family<MonetizationSettings?, CreatorIdParam>((ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getMonetizationSettings(param.creatorId);
});

final createMonetizationSettingsProvider =
    FutureProvider.family<MonetizationSettings, MonetizationSettings>((ref, settings) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  final result = await repo.createMonetizationSettings(settings);
  ref.invalidate(monetizationSettingsProvider(CreatorIdParam(settings.creatorId)));
  return result;
});

final updateMonetizationSettingsProvider =
    FutureProvider.family<MonetizationSettings, MonetizationSettings>((ref, settings) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  final result = await repo.updateMonetizationSettings(settings);
  ref.invalidate(monetizationSettingsProvider(CreatorIdParam(settings.creatorId)));
  return result;
});

final taxInfoProvider =
    FutureProvider.autoDispose.family<TaxInfo?, CreatorIdParam>((ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getTaxInfo(param.creatorId);
});

final saveTaxInfoProvider = FutureProvider.family<TaxInfo, TaxInfo>((ref, taxInfo) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  final result = await repo.saveTaxInfo(taxInfo);
  ref.invalidate(taxInfoProvider(CreatorIdParam(taxInfo.creatorId)));
  return result;
});

// ==================== Referral Bonuses ====================

final creatorReferralBonusesProvider =
    FutureProvider.autoDispose.family<List<ReferralBonus>, CreatorIdParam>((ref, param) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  return repo.getCreatorReferralBonuses(param.creatorId);
});

final createReferralBonusProvider =
    FutureProvider.family<ReferralBonus, ReferralBonus>((ref, bonus) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  final result = await repo.createReferralBonus(bonus);
  ref.invalidate(creatorReferralBonusesProvider(CreatorIdParam(bonus.referrerCreatorId)));
  return result;
});

final completeReferralBonusProvider =
    FutureProvider.family<ReferralBonus, String>((ref, bonusId) async {
  final repo = ref.watch(monetizationRepositoryProvider);
  // This would need to be refactored to track creator ID differently
  return repo.completeReferralBonus(bonusId);
});
