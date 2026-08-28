import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:toriverse/features/monetization/domain/models/monetization.dart';

/// Repository for managing creator monetization
class MonetizationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAnalytics _analytics;

  MonetizationRepository({
    FirebaseFirestore? firestore,
    FirebaseAnalytics? analytics,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _analytics = analytics ?? FirebaseAnalytics.instance;

  // ==================== Creator Earnings ====================

  Future<CreatorEarnings> createCreatorEarnings(CreatorEarnings earnings) async {
    final docRef = _firestore
        .collection('creators')
        .doc(earnings.creatorId)
        .collection('earnings')
        .doc(earnings.id);

    await docRef.set(earnings.toJson());
    await _analytics.logEvent(
      name: 'creator_earnings_created',
      parameters: {
        'creator_id': earnings.creatorId,
        'total_earnings': earnings.totalEarnings,
        'period': earnings.period.toIso8601String(),
      },
    );
    return earnings;
  }

  Future<CreatorEarnings?> getCreatorEarnings(
    String creatorId,
    String earningsId,
  ) async {
    final doc = await _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('earnings')
        .doc(earningsId)
        .get();

    return doc.exists ? CreatorEarnings.fromJson(doc.data()!) : null;
  }

  Stream<CreatorEarnings?> watchCreatorEarnings(
    String creatorId,
    String earningsId,
  ) {
    return _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('earnings')
        .doc(earningsId)
        .snapshots()
        .map((doc) => doc.exists ? CreatorEarnings.fromJson(doc.data()!) : null);
  }

  Future<List<CreatorEarnings>> getEarningsHistory(
    String creatorId,
    {int limit = 12},
  ) async {
    final docs = await _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('earnings')
        .orderBy('period', descending: true)
        .limit(limit)
        .get();

    return docs.docs.map((doc) => CreatorEarnings.fromJson(doc.data())).toList();
  }

  Stream<List<CreatorEarnings>> watchEarningsHistory(
    String creatorId,
    {int limit = 12},
  ) {
    return _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('earnings')
        .orderBy('period', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CreatorEarnings.fromJson(doc.data())).toList());
  }

  Future<CreatorEarnings> updateCreatorEarnings(CreatorEarnings earnings) async {
    final docRef = _firestore
        .collection('creators')
        .doc(earnings.creatorId)
        .collection('earnings')
        .doc(earnings.id);

    await docRef.update({
      ...earnings.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return earnings;
  }

  // ==================== Subscription Tiers ====================

  Future<SubscriptionTier> createSubscriptionTier(SubscriptionTier tier) async {
    final docRef = _firestore
        .collection('creators')
        .doc(tier.creatorId)
        .collection('subscription_tiers')
        .doc(tier.id);

    await docRef.set(tier.toJson());
    await _analytics.logEvent(
      name: 'subscription_tier_created',
      parameters: {
        'creator_id': tier.creatorId,
        'tier_name': tier.name,
        'price_jpy': tier.monthlyPriceJpy,
      },
    );
    return tier;
  }

  Future<SubscriptionTier?> getSubscriptionTier(
    String creatorId,
    String tierId,
  ) async {
    final doc = await _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('subscription_tiers')
        .doc(tierId)
        .get();

    return doc.exists ? SubscriptionTier.fromJson(doc.data()!) : null;
  }

  Future<List<SubscriptionTier>> getCreatorSubscriptionTiers(String creatorId) async {
    final docs = await _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('subscription_tiers')
        .orderBy('tier')
        .get();

    return docs.docs.map((doc) => SubscriptionTier.fromJson(doc.data())).toList();
  }

  Stream<List<SubscriptionTier>> watchCreatorSubscriptionTiers(String creatorId) {
    return _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('subscription_tiers')
        .orderBy('tier')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => SubscriptionTier.fromJson(doc.data())).toList());
  }

  Future<SubscriptionTier> updateSubscriptionTier(SubscriptionTier tier) async {
    final docRef = _firestore
        .collection('creators')
        .doc(tier.creatorId)
        .collection('subscription_tiers')
        .doc(tier.id);

    await docRef.update({
      ...tier.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return tier;
  }

  Future<void> deleteSubscriptionTier(String creatorId, String tierId) async {
    await _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('subscription_tiers')
        .doc(tierId)
        .delete();

    await _analytics.logEvent(
      name: 'subscription_tier_deleted',
      parameters: {
        'creator_id': creatorId,
        'tier_id': tierId,
      },
    );
  }

  // ==================== User Subscriptions ====================

  Future<UserSubscription> createUserSubscription(UserSubscription subscription) async {
    final docRef = _firestore
        .collection('user_subscriptions')
        .doc(subscription.id);

    await docRef.set(subscription.toJson());

    // Also add to user's subscription list
    await _firestore
        .collection('users')
        .doc(subscription.userId)
        .collection('subscriptions')
        .doc(subscription.id)
        .set(subscription.toJson());

    // Add to creator's subscriber list
    await _firestore
        .collection('creators')
        .doc(subscription.creatorId)
        .collection('subscribers')
        .doc(subscription.userId)
        .set({
          'subscriptionId': subscription.id,
          'tierId': subscription.tierId,
          'subscribedAt': FieldValue.serverTimestamp(),
        });

    await _analytics.logEvent(
      name: 'user_subscription_created',
      parameters: {
        'user_id': subscription.userId,
        'creator_id': subscription.creatorId,
        'tier_id': subscription.tierId,
        'price_jpy': subscription.priceJpy,
      },
    );

    return subscription;
  }

  Future<UserSubscription?> getUserSubscription(String subscriptionId) async {
    final doc = await _firestore
        .collection('user_subscriptions')
        .doc(subscriptionId)
        .get();

    return doc.exists ? UserSubscription.fromJson(doc.data()!) : null;
  }

  Future<UserSubscription?> getActiveSubscription(
    String userId,
    String creatorId,
  ) async {
    final docs = await _firestore
        .collection('user_subscriptions')
        .where('userId', isEqualTo: userId)
        .where('creatorId', isEqualTo: creatorId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    return docs.docs.isNotEmpty
        ? UserSubscription.fromJson(docs.docs.first.data())
        : null;
  }

  Stream<UserSubscription?> watchActiveSubscription(
    String userId,
    String creatorId,
  ) {
    return _firestore
        .collection('user_subscriptions')
        .where('userId', isEqualTo: userId)
        .where('creatorId', isEqualTo: creatorId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty
            ? UserSubscription.fromJson(snapshot.docs.first.data())
            : null);
  }

  Future<List<UserSubscription>> getUserSubscriptions(String userId) async {
    final docs = await _firestore
        .collection('users')
        .doc(userId)
        .collection('subscriptions')
        .where('status', isEqualTo: 'active')
        .get();

    return docs.docs.map((doc) => UserSubscription.fromJson(doc.data())).toList();
  }

  Future<List<UserSubscription>> getCreatorSubscribers(String creatorId) async {
    final docs = await _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('subscribers')
        .get();

    final subscriptionIds = docs.docs.map((d) => d.get('subscriptionId') as String).toList();

    if (subscriptionIds.isEmpty) return [];

    final subscriptions = await Future.wait(
      subscriptionIds.map((id) => getUserSubscription(id)),
    );

    return subscriptions.whereType<UserSubscription>().toList();
  }

  Future<UserSubscription> updateUserSubscription(UserSubscription subscription) async {
    await _firestore
        .collection('user_subscriptions')
        .doc(subscription.id)
        .update({
          ...subscription.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

    return subscription;
  }

  Future<void> cancelUserSubscription(String subscriptionId) async {
    final subscription = await getUserSubscription(subscriptionId);
    if (subscription != null) {
      await updateUserSubscription(
        subscription.copyWith(status: 'cancelled'),
      );

      await _analytics.logEvent(
        name: 'user_subscription_cancelled',
        parameters: {
          'user_id': subscription.userId,
          'creator_id': subscription.creatorId,
          'subscription_id': subscriptionId,
        },
      );
    }
  }

  // ==================== Virtual Gifts ====================

  Future<VirtualGift> createVirtualGift(VirtualGift gift) async {
    final docRef = _firestore.collection('virtual_gifts').doc(gift.id);
    await docRef.set(gift.toJson());

    await _analytics.logEvent(
      name: 'virtual_gift_created',
      parameters: {
        'gift_id': gift.id,
        'gift_name': gift.name,
        'price_jpy': gift.priceJpy,
      },
    );
    return gift;
  }

  Future<VirtualGift?> getVirtualGift(String giftId) async {
    final doc = await _firestore.collection('virtual_gifts').doc(giftId).get();
    return doc.exists ? VirtualGift.fromJson(doc.data()!) : null;
  }

  Future<List<VirtualGift>> getAvailableVirtualGifts() async {
    final docs = await _firestore
        .collection('virtual_gifts')
        .where('isAvailable', isEqualTo: true)
        .orderBy('rarity')
        .get();

    return docs.docs.map((doc) => VirtualGift.fromJson(doc.data())).toList();
  }

  Stream<List<VirtualGift>> watchAvailableVirtualGifts() {
    return _firestore
        .collection('virtual_gifts')
        .where('isAvailable', isEqualTo: true)
        .orderBy('rarity')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => VirtualGift.fromJson(doc.data())).toList());
  }

  Future<VirtualGift> updateVirtualGift(VirtualGift gift) async {
    await _firestore.collection('virtual_gifts').doc(gift.id).update(gift.toJson());
    return gift;
  }

  // ==================== Gift Transactions ====================

  Future<GiftTransaction> recordGiftTransaction(GiftTransaction transaction) async {
    final docRef = _firestore
        .collection('gift_transactions')
        .doc(transaction.id);

    await docRef.set(transaction.toJson());

    // Add to receiver's received gifts
    await _firestore
        .collection('creators')
        .doc(transaction.receiverCreatorId)
        .collection('received_gifts')
        .doc(transaction.id)
        .set(transaction.toJson());

    // Add to sender's sent gifts
    await _firestore
        .collection('users')
        .doc(transaction.senderId)
        .collection('sent_gifts')
        .doc(transaction.id)
        .set(transaction.toJson());

    // Increment gift send count on virtual gift
    await _firestore
        .collection('virtual_gifts')
        .doc(transaction.giftId)
        .update({
          'totalGiftsSent': FieldValue.increment(transaction.quantity),
        });

    await _analytics.logEvent(
      name: 'gift_sent',
      parameters: {
        'sender_id': transaction.senderId,
        'receiver_creator_id': transaction.receiverCreatorId,
        'gift_id': transaction.giftId,
        'quantity': transaction.quantity,
        'total_price_jpy': transaction.totalPriceJpy,
      },
    );

    return transaction;
  }

  Future<GiftTransaction?> getGiftTransaction(String transactionId) async {
    final doc = await _firestore
        .collection('gift_transactions')
        .doc(transactionId)
        .get();

    return doc.exists ? GiftTransaction.fromJson(doc.data()!) : null;
  }

  Future<List<GiftTransaction>> getCreatorReceivedGifts(
    String creatorId,
    {int limit = 20},
  ) async {
    final docs = await _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('received_gifts')
        .orderBy('sentAt', descending: true)
        .limit(limit)
        .get();

    return docs.docs.map((doc) => GiftTransaction.fromJson(doc.data())).toList();
  }

  Stream<List<GiftTransaction>> watchCreatorReceivedGifts(
    String creatorId,
    {int limit = 20},
  ) {
    return _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('received_gifts')
        .orderBy('sentAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => GiftTransaction.fromJson(doc.data())).toList());
  }

  Future<List<GiftTransaction>> getUserSentGifts(
    String userId,
    {int limit = 20},
  ) async {
    final docs = await _firestore
        .collection('users')
        .doc(userId)
        .collection('sent_gifts')
        .orderBy('sentAt', descending: true)
        .limit(limit)
        .get();

    return docs.docs.map((doc) => GiftTransaction.fromJson(doc.data())).toList();
  }

  // ==================== Subscription Transactions ====================

  Future<SubscriptionTransaction> recordSubscriptionTransaction(
    SubscriptionTransaction transaction,
  ) async {
    final docRef = _firestore
        .collection('subscription_transactions')
        .doc(transaction.id);

    await docRef.set(transaction.toJson());

    // Add to creator's transactions
    await _firestore
        .collection('creators')
        .doc(transaction.creatorId)
        .collection('subscription_transactions')
        .doc(transaction.id)
        .set(transaction.toJson());

    // Add to user's transactions
    await _firestore
        .collection('users')
        .doc(transaction.userId)
        .collection('subscription_transactions')
        .doc(transaction.id)
        .set(transaction.toJson());

    await _analytics.logEvent(
      name: 'subscription_payment_recorded',
      parameters: {
        'user_id': transaction.userId,
        'creator_id': transaction.creatorId,
        'amount_jpy': transaction.amountJpy,
        'status': transaction.status,
      },
    );

    return transaction;
  }

  Future<SubscriptionTransaction?> getSubscriptionTransaction(
    String transactionId,
  ) async {
    final doc = await _firestore
        .collection('subscription_transactions')
        .doc(transactionId)
        .get();

    return doc.exists ? SubscriptionTransaction.fromJson(doc.data()!) : null;
  }

  Future<List<SubscriptionTransaction>> getCreatorSubscriptionTransactions(
    String creatorId,
    {int limit = 50},
  ) async {
    final docs = await _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('subscription_transactions')
        .orderBy('billingDate', descending: true)
        .limit(limit)
        .get();

    return docs.docs.map((doc) => SubscriptionTransaction.fromJson(doc.data())).toList();
  }

  Stream<List<SubscriptionTransaction>> watchCreatorSubscriptionTransactions(
    String creatorId,
    {int limit = 50},
  ) {
    return _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('subscription_transactions')
        .orderBy('billingDate', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => SubscriptionTransaction.fromJson(doc.data())).toList());
  }

  Future<SubscriptionTransaction> updateSubscriptionTransaction(
    SubscriptionTransaction transaction,
  ) async {
    await _firestore
        .collection('subscription_transactions')
        .doc(transaction.id)
        .update(transaction.toJson());

    return transaction;
  }

  // ==================== Creator Payouts ====================

  Future<CreatorPayout> requestPayout(CreatorPayout payout) async {
    final docRef = _firestore
        .collection('creators')
        .doc(payout.creatorId)
        .collection('payouts')
        .doc(payout.id);

    await docRef.set(payout.toJson());

    await _analytics.logEvent(
      name: 'payout_requested',
      parameters: {
        'creator_id': payout.creatorId,
        'amount_jpy': payout.amountJpy,
        'payment_method_id': payout.paymentMethodId,
      },
    );

    return payout;
  }

  Future<CreatorPayout?> getPayout(String creatorId, String payoutId) async {
    final doc = await _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('payouts')
        .doc(payoutId)
        .get();

    return doc.exists ? CreatorPayout.fromJson(doc.data()!) : null;
  }

  Future<List<CreatorPayout>> getCreatorPayouts(
    String creatorId,
    {int limit = 20},
  ) async {
    final docs = await _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('payouts')
        .orderBy('requestedAt', descending: true)
        .limit(limit)
        .get();

    return docs.docs.map((doc) => CreatorPayout.fromJson(doc.data())).toList();
  }

  Stream<List<CreatorPayout>> watchCreatorPayouts(
    String creatorId,
    {int limit = 20},
  ) {
    return _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('payouts')
        .orderBy('requestedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CreatorPayout.fromJson(doc.data())).toList());
  }

  Future<CreatorPayout> updatePayoutStatus(
    String creatorId,
    String payoutId,
    String status,
  ) async {
    final payout = await getPayout(creatorId, payoutId);
    if (payout != null) {
      final updatedPayout = payout.copyWith(status: status);
      await _firestore
          .collection('creators')
          .doc(creatorId)
          .collection('payouts')
          .doc(payoutId)
          .update({
            ...updatedPayout.toJson(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      await _analytics.logEvent(
        name: 'payout_status_updated',
        parameters: {
          'creator_id': creatorId,
          'payout_id': payoutId,
          'new_status': status,
        },
      );

      return updatedPayout;
    }
    throw Exception('Payout not found');
  }

  // ==================== Payment Methods ====================

  Future<PaymentMethod> addPaymentMethod(PaymentMethod method) async {
    final docRef = _firestore
        .collection('creators')
        .doc(method.creatorId)
        .collection('payment_methods')
        .doc(method.id);

    await docRef.set(method.toJson());

    await _analytics.logEvent(
      name: 'payment_method_added',
      parameters: {
        'creator_id': method.creatorId,
        'payment_type': method.type,
      },
    );

    return method;
  }

  Future<PaymentMethod?> getPaymentMethod(
    String creatorId,
    String methodId,
  ) async {
    final doc = await _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('payment_methods')
        .doc(methodId)
        .get();

    return doc.exists ? PaymentMethod.fromJson(doc.data()!) : null;
  }

  Future<List<PaymentMethod>> getCreatorPaymentMethods(String creatorId) async {
    final docs = await _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('payment_methods')
        .get();

    return docs.docs.map((doc) => PaymentMethod.fromJson(doc.data())).toList();
  }

  Future<PaymentMethod?> getDefaultPaymentMethod(String creatorId) async {
    final docs = await _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('payment_methods')
        .where('isDefault', isEqualTo: true)
        .limit(1)
        .get();

    return docs.docs.isNotEmpty ? PaymentMethod.fromJson(docs.docs.first.data()) : null;
  }

  Future<PaymentMethod> updatePaymentMethod(PaymentMethod method) async {
    await _firestore
        .collection('creators')
        .doc(method.creatorId)
        .collection('payment_methods')
        .doc(method.id)
        .update({
          ...method.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

    return method;
  }

  Future<void> deletePaymentMethod(String creatorId, String methodId) async {
    await _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('payment_methods')
        .doc(methodId)
        .delete();

    await _analytics.logEvent(
      name: 'payment_method_deleted',
      parameters: {
        'creator_id': creatorId,
        'payment_method_id': methodId,
      },
    );
  }

  // ==================== Payout Schedule ====================

  Future<PayoutSchedule> createPayoutSchedule(PayoutSchedule schedule) async {
    final docRef = _firestore
        .collection('creators')
        .doc(schedule.creatorId)
        .collection('payout_schedule')
        .doc(schedule.id);

    await docRef.set(schedule.toJson());
    return schedule;
  }

  Future<PayoutSchedule?> getPayoutSchedule(String creatorId) async {
    final docs = await _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('payout_schedule')
        .limit(1)
        .get();

    return docs.docs.isNotEmpty ? PayoutSchedule.fromJson(docs.docs.first.data()) : null;
  }

  Future<PayoutSchedule> updatePayoutSchedule(PayoutSchedule schedule) async {
    await _firestore
        .collection('creators')
        .doc(schedule.creatorId)
        .collection('payout_schedule')
        .doc(schedule.id)
        .update({
          ...schedule.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

    return schedule;
  }

  // ==================== Revenue Allocation ====================

  Future<RevenueAllocation> setRevenueAllocation(RevenueAllocation allocation) async {
    final docRef = _firestore
        .collection('revenue_allocation')
        .doc(allocation.id);

    await docRef.set(allocation.toJson());
    return allocation;
  }

  Future<RevenueAllocation?> getCurrentRevenueAllocation() async {
    final docs = await _firestore
        .collection('revenue_allocation')
        .orderBy('effectiveDate', descending: true)
        .limit(1)
        .get();

    return docs.docs.isNotEmpty ? RevenueAllocation.fromJson(docs.docs.first.data()) : null;
  }

  // ==================== Creator Analytics ====================

  Future<CreatorAnalytics> updateCreatorAnalytics(CreatorAnalytics analytics) async {
    final docRef = _firestore
        .collection('creators')
        .doc(analytics.creatorId)
        .collection('analytics')
        .doc(analytics.id);

    await docRef.set(analytics.toJson());
    return analytics;
  }

  Future<CreatorAnalytics?> getCreatorAnalytics(
    String creatorId,
    String analyticsId,
  ) async {
    final doc = await _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('analytics')
        .doc(analyticsId)
        .get();

    return doc.exists ? CreatorAnalytics.fromJson(doc.data()!) : null;
  }

  Future<List<CreatorAnalytics>> getCreatorAnalyticsHistory(
    String creatorId,
    {int limit = 12},
  ) async {
    final docs = await _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('analytics')
        .orderBy('periodEnd', descending: true)
        .limit(limit)
        .get();

    return docs.docs.map((doc) => CreatorAnalytics.fromJson(doc.data())).toList();
  }

  Stream<List<CreatorAnalytics>> watchCreatorAnalyticsHistory(
    String creatorId,
    {int limit = 12},
  ) {
    return _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('analytics')
        .orderBy('periodEnd', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CreatorAnalytics.fromJson(doc.data())).toList());
  }

  // ==================== Achievements ====================

  Future<MonetizationAchievement> unlockAchievement(
    MonetizationAchievement achievement,
  ) async {
    final docRef = _firestore
        .collection('creators')
        .doc(achievement.creatorId)
        .collection('achievements')
        .doc(achievement.id);

    await docRef.set(achievement.toJson());

    await _analytics.logEvent(
      name: 'monetization_achievement_unlocked',
      parameters: {
        'creator_id': achievement.creatorId,
        'achievement_type': achievement.achievementType,
        'title': achievement.title,
      },
    );

    return achievement;
  }

  Future<List<MonetizationAchievement>> getCreatorAchievements(String creatorId) async {
    final docs = await _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('achievements')
        .orderBy('unlockedAt', descending: true)
        .get();

    return docs.docs.map((doc) => MonetizationAchievement.fromJson(doc.data())).toList();
  }

  Stream<List<MonetizationAchievement>> watchCreatorAchievements(String creatorId) {
    return _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('achievements')
        .orderBy('unlockedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MonetizationAchievement.fromJson(doc.data()))
            .toList());
  }

  // ==================== Settings ====================

  Future<MonetizationSettings> createMonetizationSettings(
    MonetizationSettings settings,
  ) async {
    final docRef = _firestore
        .collection('creators')
        .doc(settings.creatorId)
        .collection('monetization_settings')
        .doc(settings.id);

    await docRef.set(settings.toJson());
    return settings;
  }

  Future<MonetizationSettings?> getMonetizationSettings(String creatorId) async {
    final docs = await _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('monetization_settings')
        .limit(1)
        .get();

    return docs.docs.isNotEmpty
        ? MonetizationSettings.fromJson(docs.docs.first.data())
        : null;
  }

  Future<MonetizationSettings> updateMonetizationSettings(
    MonetizationSettings settings,
  ) async {
    await _firestore
        .collection('creators')
        .doc(settings.creatorId)
        .collection('monetization_settings')
        .doc(settings.id)
        .update({
          ...settings.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

    return settings;
  }

  // ==================== Tax Info ====================

  Future<TaxInfo> saveTaxInfo(TaxInfo taxInfo) async {
    final docRef = _firestore
        .collection('creators')
        .doc(taxInfo.creatorId)
        .collection('tax_info')
        .doc(taxInfo.id);

    await docRef.set(taxInfo.toJson());

    await _analytics.logEvent(
      name: 'tax_info_saved',
      parameters: {
        'creator_id': taxInfo.creatorId,
        'country': taxInfo.countryOfTaxResidence,
      },
    );

    return taxInfo;
  }

  Future<TaxInfo?> getTaxInfo(String creatorId) async {
    final docs = await _firestore
        .collection('creators')
        .doc(creatorId)
        .collection('tax_info')
        .limit(1)
        .get();

    return docs.docs.isNotEmpty ? TaxInfo.fromJson(docs.docs.first.data()) : null;
  }

  // ==================== Referral Bonuses ====================

  Future<ReferralBonus> createReferralBonus(ReferralBonus bonus) async {
    final docRef = _firestore.collection('referral_bonuses').doc(bonus.id);
    await docRef.set(bonus.toJson());

    await _analytics.logEvent(
      name: 'referral_bonus_created',
      parameters: {
        'referrer_creator_id': bonus.referrerCreatorId,
        'referred_user_id': bonus.referredUserId,
        'bonus_amount_jpy': bonus.bonusAmountJpy,
      },
    );

    return bonus;
  }

  Future<ReferralBonus?> getReferralBonus(String bonusId) async {
    final doc = await _firestore.collection('referral_bonuses').doc(bonusId).get();
    return doc.exists ? ReferralBonus.fromJson(doc.data()!) : null;
  }

  Future<List<ReferralBonus>> getCreatorReferralBonuses(String creatorId) async {
    final docs = await _firestore
        .collection('referral_bonuses')
        .where('referrerCreatorId', isEqualTo: creatorId)
        .orderBy('referralDate', descending: true)
        .get();

    return docs.docs.map((doc) => ReferralBonus.fromJson(doc.data())).toList();
  }

  Future<ReferralBonus> completeReferralBonus(String bonusId) async {
    final bonus = await getReferralBonus(bonusId);
    if (bonus != null) {
      await _firestore.collection('referral_bonuses').doc(bonusId).update({
        'status': 'completed',
        'completionDate': FieldValue.serverTimestamp(),
      });

      await _analytics.logEvent(
        name: 'referral_bonus_completed',
        parameters: {
          'bonus_id': bonusId,
          'bonus_amount_jpy': bonus.bonusAmountJpy,
        },
      );

      return bonus.copyWith(status: 'completed');
    }
    throw Exception('Referral bonus not found');
  }
}
