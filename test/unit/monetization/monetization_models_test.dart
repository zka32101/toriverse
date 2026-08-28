import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/monetization/domain/models/monetization.dart';

void main() {
  group('CreatorEarnings', () {
    test('creates earnings with correct defaults', () {
      final earnings = CreatorEarnings(
        id: 'earnings_001',
        creatorId: 'creator_001',
        totalEarnings: 50000,
        subscriptionRevenue: 30000,
        giftRevenue: 15000,
        clipRevenue: 5000,
        platformFeeDeducted: 5000,
        taxDeducted: 5000,
        netEarnings: 40000,
        activeSubscribers: 100,
        totalGiftsPurchased: 50,
        totalClipsMonetized: 25,
        period: DateTime(2026, 8),
        updatedAt: DateTime.now(),
      );

      expect(earnings.id, 'earnings_001');
      expect(earnings.totalEarnings, 50000);
      expect(earnings.netEarnings, 40000);
      expect(earnings.activeSubscribers, 100);
    });

    test('serializes to JSON correctly', () {
      final earnings = CreatorEarnings(
        id: 'earnings_001',
        creatorId: 'creator_001',
        totalEarnings: 50000,
        subscriptionRevenue: 30000,
        giftRevenue: 15000,
        clipRevenue: 5000,
        platformFeeDeducted: 5000,
        taxDeducted: 5000,
        netEarnings: 40000,
        activeSubscribers: 100,
        totalGiftsPurchased: 50,
        totalClipsMonetized: 25,
        period: DateTime(2026, 8),
        updatedAt: DateTime.now(),
      );

      final json = earnings.toJson();
      expect(json['id'], 'earnings_001');
      expect(json['totalEarnings'], 50000);
      expect(json['subscriptionRevenue'], 30000);
    });

    test('deserializes from JSON correctly', () {
      final now = DateTime.now();
      final json = {
        'id': 'earnings_001',
        'creatorId': 'creator_001',
        'totalEarnings': 50000.0,
        'subscriptionRevenue': 30000.0,
        'giftRevenue': 15000.0,
        'clipRevenue': 5000.0,
        'platformFeeDeducted': 5000.0,
        'taxDeducted': 5000.0,
        'netEarnings': 40000.0,
        'activeSubscribers': 100,
        'totalGiftsPurchased': 50,
        'totalClipsMonetized': 25,
        'period': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      final earnings = CreatorEarnings.fromJson(json);
      expect(earnings.id, 'earnings_001');
      expect(earnings.totalEarnings, 50000.0);
    });
  });

  group('SubscriptionTier', () {
    test('creates tier with correct defaults', () {
      final tier = SubscriptionTier(
        id: 'tier_001',
        creatorId: 'creator_001',
        name: 'Premium',
        description: 'Get exclusive content',
        monthlyPriceJpy: 500,
        annualPriceJpy: 5000,
        tier: 2,
        includeExclusiveClips: true,
        includePriorityChat: true,
        includeCustomEmoji: false,
        includeCreatorBadge: true,
        includeEarlyAccess: true,
        maxSubscriberLimit: 1000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(tier.id, 'tier_001');
      expect(tier.monthlyPriceJpy, 500);
      expect(tier.tier, 2);
      expect(tier.includeExclusiveClips, true);
    });

    test('supports multiple tiers', () {
      final tiers = [
        SubscriptionTier(
          id: 'tier_001',
          creatorId: 'creator_001',
          name: 'Basic',
          description: 'Basic tier',
          monthlyPriceJpy: 300,
          tier: 1,
          includeExclusiveClips: false,
          includePriorityChat: false,
          includeCustomEmoji: false,
          includeCreatorBadge: false,
          includeEarlyAccess: false,
          maxSubscriberLimit: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        SubscriptionTier(
          id: 'tier_002',
          creatorId: 'creator_001',
          name: 'Premium',
          description: 'Premium tier',
          monthlyPriceJpy: 700,
          tier: 2,
          includeExclusiveClips: true,
          includePriorityChat: true,
          includeCustomEmoji: false,
          includeCreatorBadge: true,
          includeEarlyAccess: true,
          maxSubscriberLimit: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      expect(tiers.length, 2);
      expect(tiers[0].tier, 1);
      expect(tiers[1].tier, 2);
    });
  });

  group('UserSubscription', () {
    test('creates subscription with correct defaults', () {
      final sub = UserSubscription(
        id: 'sub_001',
        userId: 'user_001',
        creatorId: 'creator_001',
        tierId: 'tier_001',
        status: 'active',
        subscriptionStartDate: DateTime.now(),
        subscriptionEndDate: DateTime.now().add(const Duration(days: 30)),
        nextBillingDate: DateTime.now().add(const Duration(days: 30)),
        priceJpy: 500,
        billingCycle: 'monthly',
        autoRenew: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(sub.status, 'active');
      expect(sub.autoRenew, true);
      expect(sub.billingCycle, 'monthly');
    });

    test('tracks subscription status transitions', () {
      final statuses = ['active', 'paused', 'cancelled', 'expired'];

      for (final status in statuses) {
        final sub = UserSubscription(
          id: 'sub_001',
          userId: 'user_001',
          creatorId: 'creator_001',
          tierId: 'tier_001',
          status: status,
          subscriptionStartDate: DateTime.now(),
          subscriptionEndDate: DateTime.now().add(const Duration(days: 30)),
          nextBillingDate: DateTime.now().add(const Duration(days: 30)),
          priceJpy: 500,
          billingCycle: 'monthly',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(sub.status, status);
      }
    });
  });

  group('VirtualGift', () {
    test('creates gift with correct defaults', () {
      final gift = VirtualGift(
        id: 'gift_001',
        name: 'Golden Trophy',
        description: 'Award for top creators',
        assetUrl: 'https://example.com/gift.png',
        priceJpy: 500,
        creatorRevenueJpy: 400,
        rarity: 'legendary',
        isAvailable: true,
        totalGiftsSent: 0,
        createdAt: DateTime.now(),
      );

      expect(gift.id, 'gift_001');
      expect(gift.priceJpy, 500);
      expect(gift.rarity, 'legendary');
    });

    test('supports multiple rarities', () {
      final rarities = ['common', 'rare', 'legendary'];

      for (final rarity in rarities) {
        final gift = VirtualGift(
          id: 'gift_$rarity',
          name: 'Test Gift',
          description: 'Test',
          assetUrl: 'https://example.com/gift.png',
          priceJpy: 100,
          creatorRevenueJpy: 80,
          rarity: rarity,
          totalGiftsSent: 0,
          createdAt: DateTime.now(),
        );

        expect(gift.rarity, rarity);
      }
    });
  });

  group('GiftTransaction', () {
    test('creates gift transaction with tracking', () {
      final transaction = GiftTransaction(
        id: 'transaction_001',
        giftId: 'gift_001',
        senderId: 'user_001',
        receiverCreatorId: 'creator_001',
        quantity: 5,
        totalPriceJpy: 2500,
        creatorRevenueJpy: 2000,
        personalMessage: 'Great content!',
        sentAt: DateTime.now(),
        deliveredAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(transaction.senderId, 'user_001');
      expect(transaction.receiverCreatorId, 'creator_001');
      expect(transaction.totalPriceJpy, 2500);
      expect(transaction.creatorRevenueJpy, 2000);
    });
  });

  group('SubscriptionTransaction', () {
    test('creates subscription transaction with correct status', () {
      final transaction = SubscriptionTransaction(
        id: 'transaction_001',
        subscriptionId: 'sub_001',
        userId: 'user_001',
        creatorId: 'creator_001',
        amountJpy: 500,
        creatorRevenueJpy: 400,
        paymentMethod: 'credit_card',
        status: 'completed',
        billingDate: DateTime.now(),
        paidDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(transaction.status, 'completed');
      expect(transaction.amountJpy, 500);
    });

    test('tracks transaction status', () {
      final statuses = ['completed', 'pending', 'failed', 'refunded'];

      for (final status in statuses) {
        final transaction = SubscriptionTransaction(
          id: 'transaction_001',
          subscriptionId: 'sub_001',
          userId: 'user_001',
          creatorId: 'creator_001',
          amountJpy: 500,
          creatorRevenueJpy: 400,
          paymentMethod: 'credit_card',
          status: status,
          billingDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        expect(transaction.status, status);
      }
    });
  });

  group('CreatorPayout', () {
    test('creates payout request with pending status', () {
      final payout = CreatorPayout(
        id: 'payout_001',
        creatorId: 'creator_001',
        amountJpy: 10000,
        paymentMethodId: 'method_001',
        status: 'pending',
        requestedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(payout.status, 'pending');
      expect(payout.amountJpy, 10000);
    });

    test('tracks payout status transitions', () {
      final statuses = ['pending', 'processing', 'completed', 'failed', 'cancelled'];

      for (final status in statuses) {
        final payout = CreatorPayout(
          id: 'payout_001',
          creatorId: 'creator_001',
          amountJpy: 10000,
          paymentMethodId: 'method_001',
          status: status,
          requestedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        expect(payout.status, status);
      }
    });
  });

  group('PaymentMethod', () {
    test('creates payment method with default flag', () {
      final method = PaymentMethod(
        id: 'method_001',
        creatorId: 'creator_001',
        type: 'bank_transfer',
        accountHolder: 'John Doe',
        accountNumber: 'encrypted_account_number',
        currency: 'JPY',
        isDefault: true,
        isVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(method.type, 'bank_transfer');
      expect(method.isDefault, true);
      expect(method.isVerified, true);
    });

    test('supports multiple payment types', () {
      final types = ['bank_transfer', 'paypal', 'stripe'];

      for (final type in types) {
        final method = PaymentMethod(
          id: 'method_$type',
          creatorId: 'creator_001',
          type: type,
          accountHolder: 'Test',
          currency: 'JPY',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(method.type, type);
      }
    });
  });

  group('CreatorAnalytics', () {
    test('calculates churn rate correctly', () {
      final analytics = CreatorAnalytics(
        id: 'analytics_001',
        creatorId: 'creator_001',
        totalSubscribers: 100,
        newSubscribersThisPeriod: 20,
        churnedSubscribersThisPeriod: 5,
        churnRate: 0.05,
        averageSubscriberLTV: 3500,
        uniqueGiftPurchasers: 50,
        totalGiftsReceived: 200,
        averageGiftValue: 1250,
        totalMonetizedClips: 25,
        averageClipEarnings: 2000,
        subscriptionRevenueTrend: 0.15,
        giftRevenueTrend: 0.10,
        periodStart: DateTime(2026, 8, 1),
        periodEnd: DateTime(2026, 8, 31),
        createdAt: DateTime.now(),
      );

      expect(analytics.churnRate, 0.05);
      expect(analytics.totalSubscribers, 100);
    });

    test('tracks revenue trends', () {
      final analytics = CreatorAnalytics(
        id: 'analytics_001',
        creatorId: 'creator_001',
        totalSubscribers: 100,
        newSubscribersThisPeriod: 20,
        churnedSubscribersThisPeriod: 5,
        churnRate: 0.05,
        averageSubscriberLTV: 3500,
        uniqueGiftPurchasers: 50,
        totalGiftsReceived: 200,
        averageGiftValue: 1250,
        totalMonetizedClips: 25,
        averageClipEarnings: 2000,
        subscriptionRevenueTrend: 0.15,
        giftRevenueTrend: 0.10,
        periodStart: DateTime(2026, 8, 1),
        periodEnd: DateTime(2026, 8, 31),
        createdAt: DateTime.now(),
      );

      expect(analytics.subscriptionRevenueTrend, 0.15);
      expect(analytics.giftRevenueTrend, 0.10);
    });
  });

  group('MonetizationAchievement', () {
    test('creates achievement with unlock date', () {
      final achievement = MonetizationAchievement(
        id: 'achievement_001',
        creatorId: 'creator_001',
        achievementType: 'first_sub',
        title: 'First Subscriber',
        description: 'Got your first subscriber!',
        badgeAssetUrl: 'https://example.com/badge.png',
        unlockedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(achievement.achievementType, 'first_sub');
      expect(achievement.title, 'First Subscriber');
    });

    test('supports multiple achievement types', () {
      final types = ['first_sub', '100_subs', '1000_subs', '10k_earnings'];

      for (final type in types) {
        final achievement = MonetizationAchievement(
          id: 'achievement_$type',
          creatorId: 'creator_001',
          achievementType: type,
          title: 'Achievement',
          description: 'You unlocked an achievement',
          badgeAssetUrl: 'https://example.com/badge.png',
          unlockedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        expect(achievement.achievementType, type);
      }
    });
  });

  group('ReferralBonus', () {
    test('creates referral bonus with tracking', () {
      final bonus = ReferralBonus(
        id: 'bonus_001',
        referrerCreatorId: 'creator_001',
        referredUserId: 'user_001',
        referralCode: 'REFER123',
        status: 'pending',
        bonusAmountJpy: 1000,
        referralDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(bonus.status, 'pending');
      expect(bonus.bonusAmountJpy, 1000);
      expect(bonus.referralCode, 'REFER123');
    });
  });

  group('MonetizationSettings', () {
    test('creates settings with defaults enabled', () {
      final settings = MonetizationSettings(
        id: 'settings_001',
        creatorId: 'creator_001',
        subscriptionsEnabled: true,
        giftsEnabled: true,
        clipsMonetizationEnabled: true,
        referralsEnabled: true,
        preferredPayoutCurrency: 'JPY',
        minimumPayoutCurrencyType: 'JPY',
        taxInfoVerified: false,
        paymentMethodVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(settings.subscriptionsEnabled, true);
      expect(settings.giftsEnabled, true);
      expect(settings.taxInfoVerified, false);
    });
  });

  group('TaxInfo', () {
    test('creates tax info with status', () {
      final taxInfo = TaxInfo(
        id: 'tax_001',
        creatorId: 'creator_001',
        taxId: 'encrypted_tax_id',
        countryOfTaxResidence: 'Japan',
        estimatedAnnualIncome: 1000000,
        taxFilingStatus: 'individual',
        hasFiledTaxReturn: true,
        lastTaxFilingDate: DateTime(2026, 3, 15),
        taxDocumentUrl: 'https://example.com/document.pdf',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(taxInfo.countryOfTaxResidence, 'Japan');
      expect(taxInfo.taxFilingStatus, 'individual');
      expect(taxInfo.hasFiledTaxReturn, true);
    });
  });
}
