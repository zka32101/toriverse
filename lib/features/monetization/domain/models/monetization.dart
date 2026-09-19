
/// Creator earnings aggregated by time period
class CreatorEarnings {
  final String id;
  final String creatorId;
  final double totalEarnings;
  final double subscriptionRevenue;
  final double giftRevenue;
  final double clipRevenue;
  final double platformFeeDeducted;
  final double taxDeducted;
  final double netEarnings;
  final int activeSubscribers;
  final int totalGiftsPurchased;
  final int totalClipsMonetized;
  final DateTime period;
  final DateTime updatedAt;

  const CreatorEarnings({
    required this.id,
    required this.creatorId,
    required this.totalEarnings,
    required this.subscriptionRevenue,
    required this.giftRevenue,
    required this.clipRevenue,
    required this.platformFeeDeducted,
    required this.taxDeducted,
    required this.netEarnings,
    required this.activeSubscribers,
    required this.totalGiftsPurchased,
    required this.totalClipsMonetized,
    required this.period,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'totalEarnings': totalEarnings,
      'subscriptionRevenue': subscriptionRevenue,
      'giftRevenue': giftRevenue,
      'clipRevenue': clipRevenue,
      'platformFeeDeducted': platformFeeDeducted,
      'taxDeducted': taxDeducted,
      'netEarnings': netEarnings,
      'activeSubscribers': activeSubscribers,
      'totalGiftsPurchased': totalGiftsPurchased,
      'totalClipsMonetized': totalClipsMonetized,
      'period': period.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CreatorEarnings.fromJson(Map<String, dynamic> json) {
    return CreatorEarnings(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      subscriptionRevenue: (json['subscriptionRevenue'] as num).toDouble(),
      giftRevenue: (json['giftRevenue'] as num).toDouble(),
      clipRevenue: (json['clipRevenue'] as num).toDouble(),
      platformFeeDeducted: (json['platformFeeDeducted'] as num).toDouble(),
      taxDeducted: (json['taxDeducted'] as num).toDouble(),
      netEarnings: (json['netEarnings'] as num).toDouble(),
      activeSubscribers: json['activeSubscribers'] as int,
      totalGiftsPurchased: json['totalGiftsPurchased'] as int,
      totalClipsMonetized: json['totalClipsMonetized'] as int,
      period: DateTime.parse(json['period'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Subscription tier configuration
class SubscriptionTier {
  final String id;
  final String creatorId;
  final String name;
  final String description;
  final int monthlyPriceJpy;
  final int? annualPriceJpy;
  final int tier; // 1=basic, 2=premium, 3=vip
  final bool includeExclusiveClips;
  final bool includePriorityChat;
  final bool includeCustomEmoji;
  final bool includeCreatorBadge;
  final bool includeEarlyAccess;
  final int maxSubscriberLimit;
  final int currentSubscribers;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubscriptionTier({
    required this.id,
    required this.creatorId,
    required this.name,
    required this.description,
    required this.monthlyPriceJpy,
    this.annualPriceJpy,
    required this.tier,
    required this.includeExclusiveClips,
    required this.includePriorityChat,
    required this.includeCustomEmoji,
    required this.includeCreatorBadge,
    required this.includeEarlyAccess,
    required this.maxSubscriberLimit,
    this.currentSubscribers = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'name': name,
      'description': description,
      'monthlyPriceJpy': monthlyPriceJpy,
      'annualPriceJpy': annualPriceJpy,
      'tier': tier,
      'includeExclusiveClips': includeExclusiveClips,
      'includePriorityChat': includePriorityChat,
      'includeCustomEmoji': includeCustomEmoji,
      'includeCreatorBadge': includeCreatorBadge,
      'includeEarlyAccess': includeEarlyAccess,
      'maxSubscriberLimit': maxSubscriberLimit,
      'currentSubscribers': currentSubscribers,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SubscriptionTier.fromJson(Map<String, dynamic> json) {
    return SubscriptionTier(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      monthlyPriceJpy: json['monthlyPriceJpy'] as int,
      annualPriceJpy: json['annualPriceJpy'] as int?,
      tier: json['tier'] as int,
      includeExclusiveClips: json['includeExclusiveClips'] as bool,
      includePriorityChat: json['includePriorityChat'] as bool,
      includeCustomEmoji: json['includeCustomEmoji'] as bool,
      includeCreatorBadge: json['includeCreatorBadge'] as bool,
      includeEarlyAccess: json['includeEarlyAccess'] as bool,
      maxSubscriberLimit: json['maxSubscriberLimit'] as int,
      currentSubscribers: json['currentSubscribers'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// User's active subscription to a creator
class UserSubscription {
  final String id;
  final String userId;
  final String creatorId;
  final String tierId;
  final String status; // active, paused, cancelled, expired
  final DateTime subscriptionStartDate;
  final DateTime subscriptionEndDate;
  final DateTime? nextBillingDate;
  final int priceJpy;
  final String billingCycle; // monthly, annual
  final bool autoRenew;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserSubscription({
    required this.id,
    required this.userId,
    required this.creatorId,
    required this.tierId,
    required this.status,
    required this.subscriptionStartDate,
    required this.subscriptionEndDate,
    required this.nextBillingDate,
    required this.priceJpy,
    required this.billingCycle,
    this.autoRenew = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'creatorId': creatorId,
      'tierId': tierId,
      'status': status,
      'subscriptionStartDate': subscriptionStartDate.toIso8601String(),
      'subscriptionEndDate': subscriptionEndDate.toIso8601String(),
      'nextBillingDate': nextBillingDate?.toIso8601String(),
      'priceJpy': priceJpy,
      'billingCycle': billingCycle,
      'autoRenew': autoRenew,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'] as String,
      userId: json['userId'] as String,
      creatorId: json['creatorId'] as String,
      tierId: json['tierId'] as String,
      status: json['status'] as String,
      subscriptionStartDate:
          DateTime.parse(json['subscriptionStartDate'] as String),
      subscriptionEndDate:
          DateTime.parse(json['subscriptionEndDate'] as String),
      nextBillingDate: json['nextBillingDate'] != null
          ? DateTime.parse(json['nextBillingDate'] as String)
          : null,
      priceJpy: json['priceJpy'] as int,
      billingCycle: json['billingCycle'] as String,
      autoRenew: json['autoRenew'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  UserSubscription copyWith({
    String? id,
    String? userId,
    String? creatorId,
    String? tierId,
    String? status,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
    DateTime? nextBillingDate,
    int? priceJpy,
    String? billingCycle,
    bool? autoRenew,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSubscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      creatorId: creatorId ?? this.creatorId,
      tierId: tierId ?? this.tierId,
      status: status ?? this.status,
      subscriptionStartDate:
          subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      priceJpy: priceJpy ?? this.priceJpy,
      billingCycle: billingCycle ?? this.billingCycle,
      autoRenew: autoRenew ?? this.autoRenew,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Virtual gift item definition
class VirtualGift {
  final String id;
  final String name;
  final String description;
  final String assetUrl;
  final int priceJpy;
  final int creatorRevenueJpy;
  final String rarity; // common, rare, legendary
  final bool isAvailable;
  final int totalGiftsSent;
  final DateTime createdAt;

  const VirtualGift({
    required this.id,
    required this.name,
    required this.description,
    required this.assetUrl,
    required this.priceJpy,
    required this.creatorRevenueJpy,
    required this.rarity,
    this.isAvailable = true,
    required this.totalGiftsSent,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'assetUrl': assetUrl,
      'priceJpy': priceJpy,
      'creatorRevenueJpy': creatorRevenueJpy,
      'rarity': rarity,
      'isAvailable': isAvailable,
      'totalGiftsSent': totalGiftsSent,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory VirtualGift.fromJson(Map<String, dynamic> json) {
    return VirtualGift(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      assetUrl: json['assetUrl'] as String,
      priceJpy: json['priceJpy'] as int,
      creatorRevenueJpy: json['creatorRevenueJpy'] as int,
      rarity: json['rarity'] as String,
      isAvailable: json['isAvailable'] as bool? ?? true,
      totalGiftsSent: json['totalGiftsSent'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Record of virtual gift purchase and sending
class GiftTransaction {
  final String id;
  final String giftId;
  final String senderId;
  final String receiverCreatorId;
  final int quantity;
  final int totalPriceJpy;
  final int creatorRevenueJpy;
  final String? personalMessage;
  final DateTime sentAt;
  final DateTime? deliveredAt;
  final DateTime createdAt;

  const GiftTransaction({
    required this.id,
    required this.giftId,
    required this.senderId,
    required this.receiverCreatorId,
    required this.quantity,
    required this.totalPriceJpy,
    required this.creatorRevenueJpy,
    required this.personalMessage,
    required this.sentAt,
    required this.deliveredAt,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'giftId': giftId,
      'senderId': senderId,
      'receiverCreatorId': receiverCreatorId,
      'quantity': quantity,
      'totalPriceJpy': totalPriceJpy,
      'creatorRevenueJpy': creatorRevenueJpy,
      'personalMessage': personalMessage,
      'sentAt': sentAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GiftTransaction.fromJson(Map<String, dynamic> json) {
    return GiftTransaction(
      id: json['id'] as String,
      giftId: json['giftId'] as String,
      senderId: json['senderId'] as String,
      receiverCreatorId: json['receiverCreatorId'] as String,
      quantity: json['quantity'] as int,
      totalPriceJpy: json['totalPriceJpy'] as int,
      creatorRevenueJpy: json['creatorRevenueJpy'] as int,
      personalMessage: json['personalMessage'] as String?,
      sentAt: DateTime.parse(json['sentAt'] as String),
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Subscription payment record
class SubscriptionTransaction {
  final String id;
  final String subscriptionId;
  final String userId;
  final String creatorId;
  final int amountJpy;
  final int creatorRevenueJpy;
  final String paymentMethod;
  final String status; // completed, pending, failed, refunded
  final DateTime billingDate;
  final DateTime? paidDate;
  final String? failureReason;
  final int? retryCount;
  final DateTime createdAt;

  const SubscriptionTransaction({
    required this.id,
    required this.subscriptionId,
    required this.userId,
    required this.creatorId,
    required this.amountJpy,
    required this.creatorRevenueJpy,
    required this.paymentMethod,
    required this.status,
    required this.billingDate,
    this.paidDate,
    this.failureReason,
    this.retryCount,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subscriptionId': subscriptionId,
      'userId': userId,
      'creatorId': creatorId,
      'amountJpy': amountJpy,
      'creatorRevenueJpy': creatorRevenueJpy,
      'paymentMethod': paymentMethod,
      'status': status,
      'billingDate': billingDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'failureReason': failureReason,
      'retryCount': retryCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SubscriptionTransaction.fromJson(Map<String, dynamic> json) {
    return SubscriptionTransaction(
      id: json['id'] as String,
      subscriptionId: json['subscriptionId'] as String,
      userId: json['userId'] as String,
      creatorId: json['creatorId'] as String,
      amountJpy: json['amountJpy'] as int,
      creatorRevenueJpy: json['creatorRevenueJpy'] as int,
      paymentMethod: json['paymentMethod'] as String,
      status: json['status'] as String,
      billingDate: DateTime.parse(json['billingDate'] as String),
      paidDate: json['paidDate'] != null
          ? DateTime.parse(json['paidDate'] as String)
          : null,
      failureReason: json['failureReason'] as String?,
      retryCount: json['retryCount'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Payout request and status
class CreatorPayout {
  final String id;
  final String creatorId;
  final double amountJpy;
  final String paymentMethodId;
  final String status; // pending, processing, completed, failed, cancelled
  final DateTime requestedAt;
  final DateTime? processedAt;
  final DateTime? completedAt;
  final String? failureReason;
  final String? transactionReference;
  final DateTime createdAt;

  const CreatorPayout({
    required this.id,
    required this.creatorId,
    required this.amountJpy,
    required this.paymentMethodId,
    required this.status,
    required this.requestedAt,
    this.processedAt,
    this.completedAt,
    this.failureReason,
    this.transactionReference,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'amountJpy': amountJpy,
      'paymentMethodId': paymentMethodId,
      'status': status,
      'requestedAt': requestedAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'failureReason': failureReason,
      'transactionReference': transactionReference,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CreatorPayout.fromJson(Map<String, dynamic> json) {
    return CreatorPayout(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      amountJpy: (json['amountJpy'] as num).toDouble(),
      paymentMethodId: json['paymentMethodId'] as String,
      status: json['status'] as String,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      failureReason: json['failureReason'] as String?,
      transactionReference: json['transactionReference'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  CreatorPayout copyWith({
    String? id,
    String? creatorId,
    double? amountJpy,
    String? paymentMethodId,
    String? status,
    DateTime? requestedAt,
    DateTime? processedAt,
    DateTime? completedAt,
    String? failureReason,
    String? transactionReference,
    DateTime? createdAt,
  }) {
    return CreatorPayout(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      amountJpy: amountJpy ?? this.amountJpy,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      processedAt: processedAt ?? this.processedAt,
      completedAt: completedAt ?? this.completedAt,
      failureReason: failureReason ?? this.failureReason,
      transactionReference: transactionReference ?? this.transactionReference,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Creator's payment method for payouts
class PaymentMethod {
  final String id;
  final String creatorId;
  final String type; // bank_transfer, paypal, stripe
  final String accountHolder;
  final String? accountNumber; // encrypted
  final String? routingNumber; // encrypted
  final String? paypalEmail;
  final String? stripeAccountId;
  final String currency; // JPY, USD, EUR
  final bool isDefault;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentMethod({
    required this.id,
    required this.creatorId,
    required this.type,
    required this.accountHolder,
    this.accountNumber,
    this.routingNumber,
    this.paypalEmail,
    this.stripeAccountId,
    required this.currency,
    this.isDefault = false,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'type': type,
      'accountHolder': accountHolder,
      'accountNumber': accountNumber,
      'routingNumber': routingNumber,
      'paypalEmail': paypalEmail,
      'stripeAccountId': stripeAccountId,
      'currency': currency,
      'isDefault': isDefault,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      type: json['type'] as String,
      accountHolder: json['accountHolder'] as String,
      accountNumber: json['accountNumber'] as String?,
      routingNumber: json['routingNumber'] as String?,
      paypalEmail: json['paypalEmail'] as String?,
      stripeAccountId: json['stripeAccountId'] as String?,
      currency: json['currency'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Creator's payout frequency settings
class PayoutSchedule {
  final String id;
  final String creatorId;
  final String frequency; // weekly, biweekly, monthly
  final double minimumPayoutThreshold; // JPY
  final bool autoPayoutEnabled;
  final DateTime nextPayoutDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PayoutSchedule({
    required this.id,
    required this.creatorId,
    required this.frequency,
    required this.minimumPayoutThreshold,
    required this.autoPayoutEnabled,
    required this.nextPayoutDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'frequency': frequency,
      'minimumPayoutThreshold': minimumPayoutThreshold,
      'autoPayoutEnabled': autoPayoutEnabled,
      'nextPayoutDate': nextPayoutDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PayoutSchedule.fromJson(Map<String, dynamic> json) {
    return PayoutSchedule(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      frequency: json['frequency'] as String,
      minimumPayoutThreshold:
          (json['minimumPayoutThreshold'] as num).toDouble(),
      autoPayoutEnabled: json['autoPayoutEnabled'] as bool,
      nextPayoutDate: DateTime.parse(json['nextPayoutDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Revenue split configuration
class RevenueAllocation {
  final String id;
  final String creatorId;
  final double subscriptionPlatformFeePercent;
  final double giftPlatformFeePercent;
  final double clipPlatformFeePercent;
  final double creatorSubscriptionPercent;
  final double creatorGiftPercent;
  final double creatorClipPercent;
  final DateTime effectiveDate;
  final DateTime createdAt;

  const RevenueAllocation({
    required this.id,
    required this.creatorId,
    required this.subscriptionPlatformFeePercent,
    required this.giftPlatformFeePercent,
    required this.clipPlatformFeePercent,
    required this.creatorSubscriptionPercent,
    required this.creatorGiftPercent,
    required this.creatorClipPercent,
    required this.effectiveDate,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'subscriptionPlatformFeePercent': subscriptionPlatformFeePercent,
      'giftPlatformFeePercent': giftPlatformFeePercent,
      'clipPlatformFeePercent': clipPlatformFeePercent,
      'creatorSubscriptionPercent': creatorSubscriptionPercent,
      'creatorGiftPercent': creatorGiftPercent,
      'creatorClipPercent': creatorClipPercent,
      'effectiveDate': effectiveDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RevenueAllocation.fromJson(Map<String, dynamic> json) {
    return RevenueAllocation(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      subscriptionPlatformFeePercent:
          (json['subscriptionPlatformFeePercent'] as num).toDouble(),
      giftPlatformFeePercent:
          (json['giftPlatformFeePercent'] as num).toDouble(),
      clipPlatformFeePercent:
          (json['clipPlatformFeePercent'] as num).toDouble(),
      creatorSubscriptionPercent:
          (json['creatorSubscriptionPercent'] as num).toDouble(),
      creatorGiftPercent: (json['creatorGiftPercent'] as num).toDouble(),
      creatorClipPercent: (json['creatorClipPercent'] as num).toDouble(),
      effectiveDate: DateTime.parse(json['effectiveDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Detailed analytics for creator earnings
class CreatorAnalytics {
  final String id;
  final String creatorId;
  final int totalSubscribers;
  final int newSubscribersThisPeriod;
  final int churnedSubscribersThisPeriod;
  final double churnRate;
  final double averageSubscriberLTV;
  final int uniqueGiftPurchasers;
  final int totalGiftsReceived;
  final double averageGiftValue;
  final int totalMonetizedClips;
  final double averageClipEarnings;
  final double subscriptionRevenueTrend;
  final double giftRevenueTrend;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime createdAt;

  const CreatorAnalytics({
    required this.id,
    required this.creatorId,
    required this.totalSubscribers,
    required this.newSubscribersThisPeriod,
    required this.churnedSubscribersThisPeriod,
    required this.churnRate,
    required this.averageSubscriberLTV,
    required this.uniqueGiftPurchasers,
    required this.totalGiftsReceived,
    required this.averageGiftValue,
    required this.totalMonetizedClips,
    required this.averageClipEarnings,
    required this.subscriptionRevenueTrend,
    required this.giftRevenueTrend,
    required this.periodStart,
    required this.periodEnd,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'totalSubscribers': totalSubscribers,
      'newSubscribersThisPeriod': newSubscribersThisPeriod,
      'churnedSubscribersThisPeriod': churnedSubscribersThisPeriod,
      'churnRate': churnRate,
      'averageSubscriberLTV': averageSubscriberLTV,
      'uniqueGiftPurchasers': uniqueGiftPurchasers,
      'totalGiftsReceived': totalGiftsReceived,
      'averageGiftValue': averageGiftValue,
      'totalMonetizedClips': totalMonetizedClips,
      'averageClipEarnings': averageClipEarnings,
      'subscriptionRevenueTrend': subscriptionRevenueTrend,
      'giftRevenueTrend': giftRevenueTrend,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CreatorAnalytics.fromJson(Map<String, dynamic> json) {
    return CreatorAnalytics(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      totalSubscribers: json['totalSubscribers'] as int,
      newSubscribersThisPeriod: json['newSubscribersThisPeriod'] as int,
      churnedSubscribersThisPeriod:
          json['churnedSubscribersThisPeriod'] as int,
      churnRate: (json['churnRate'] as num).toDouble(),
      averageSubscriberLTV: (json['averageSubscriberLTV'] as num).toDouble(),
      uniqueGiftPurchasers: json['uniqueGiftPurchasers'] as int,
      totalGiftsReceived: json['totalGiftsReceived'] as int,
      averageGiftValue: (json['averageGiftValue'] as num).toDouble(),
      totalMonetizedClips: json['totalMonetizedClips'] as int,
      averageClipEarnings: (json['averageClipEarnings'] as num).toDouble(),
      subscriptionRevenueTrend:
          (json['subscriptionRevenueTrend'] as num).toDouble(),
      giftRevenueTrend: (json['giftRevenueTrend'] as num).toDouble(),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Monetization milestones and achievements
class MonetizationAchievement {
  final String id;
  final String creatorId;
  final String achievementType; // first_sub, 100_subs, 1000_subs, 10k_earnings
  final String title;
  final String description;
  final String badgeAssetUrl;
  final DateTime unlockedAt;
  final DateTime createdAt;

  const MonetizationAchievement({
    required this.id,
    required this.creatorId,
    required this.achievementType,
    required this.title,
    required this.description,
    required this.badgeAssetUrl,
    required this.unlockedAt,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'achievementType': achievementType,
      'title': title,
      'description': description,
      'badgeAssetUrl': badgeAssetUrl,
      'unlockedAt': unlockedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MonetizationAchievement.fromJson(Map<String, dynamic> json) {
    return MonetizationAchievement(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      achievementType: json['achievementType'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      badgeAssetUrl: json['badgeAssetUrl'] as String,
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Multi-currency exchange rates
class CurrencyExchange {
  final String id;
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final DateTime rateDate;
  final DateTime lastUpdatedAt;

  const CurrencyExchange({
    required this.id,
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.rateDate,
    required this.lastUpdatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'rate': rate,
      'rateDate': rateDate.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    };
  }

  factory CurrencyExchange.fromJson(Map<String, dynamic> json) {
    return CurrencyExchange(
      id: json['id'] as String,
      fromCurrency: json['fromCurrency'] as String,
      toCurrency: json['toCurrency'] as String,
      rate: (json['rate'] as num).toDouble(),
      rateDate: DateTime.parse(json['rateDate'] as String),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
    );
  }
}

/// Tax information for creators
class TaxInfo {
  final String id;
  final String creatorId;
  final String taxId; // encrypted
  final String countryOfTaxResidence;
  final double estimatedAnnualIncome;
  final String taxFilingStatus; // individual, business
  final bool hasFiledTaxReturn;
  final DateTime lastTaxFilingDate;
  final String taxDocumentUrl; // encrypted
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaxInfo({
    required this.id,
    required this.creatorId,
    required this.taxId,
    required this.countryOfTaxResidence,
    required this.estimatedAnnualIncome,
    required this.taxFilingStatus,
    required this.hasFiledTaxReturn,
    required this.lastTaxFilingDate,
    required this.taxDocumentUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'taxId': taxId,
      'countryOfTaxResidence': countryOfTaxResidence,
      'estimatedAnnualIncome': estimatedAnnualIncome,
      'taxFilingStatus': taxFilingStatus,
      'hasFiledTaxReturn': hasFiledTaxReturn,
      'lastTaxFilingDate': lastTaxFilingDate.toIso8601String(),
      'taxDocumentUrl': taxDocumentUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TaxInfo.fromJson(Map<String, dynamic> json) {
    return TaxInfo(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      taxId: json['taxId'] as String,
      countryOfTaxResidence: json['countryOfTaxResidence'] as String,
      estimatedAnnualIncome:
          (json['estimatedAnnualIncome'] as num).toDouble(),
      taxFilingStatus: json['taxFilingStatus'] as String,
      hasFiledTaxReturn: json['hasFiledTaxReturn'] as bool,
      lastTaxFilingDate: DateTime.parse(json['lastTaxFilingDate'] as String),
      taxDocumentUrl: json['taxDocumentUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Referral bonus tracking
class ReferralBonus {
  final String id;
  final String referrerCreatorId;
  final String referredUserId;
  final String referralCode;
  final String status; // pending, completed, cancelled
  final double bonusAmountJpy;
  final DateTime referralDate;
  final DateTime? completionDate;
  final DateTime createdAt;

  const ReferralBonus({
    required this.id,
    required this.referrerCreatorId,
    required this.referredUserId,
    required this.referralCode,
    required this.status,
    required this.bonusAmountJpy,
    required this.referralDate,
    this.completionDate,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referrerCreatorId': referrerCreatorId,
      'referredUserId': referredUserId,
      'referralCode': referralCode,
      'status': status,
      'bonusAmountJpy': bonusAmountJpy,
      'referralDate': referralDate.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReferralBonus.fromJson(Map<String, dynamic> json) {
    return ReferralBonus(
      id: json['id'] as String,
      referrerCreatorId: json['referrerCreatorId'] as String,
      referredUserId: json['referredUserId'] as String,
      referralCode: json['referralCode'] as String,
      status: json['status'] as String,
      bonusAmountJpy: (json['bonusAmountJpy'] as num).toDouble(),
      referralDate: DateTime.parse(json['referralDate'] as String),
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  ReferralBonus copyWith({
    String? id,
    String? referrerCreatorId,
    String? referredUserId,
    String? referralCode,
    String? status,
    double? bonusAmountJpy,
    DateTime? referralDate,
    DateTime? completionDate,
    DateTime? createdAt,
  }) {
    return ReferralBonus(
      id: id ?? this.id,
      referrerCreatorId: referrerCreatorId ?? this.referrerCreatorId,
      referredUserId: referredUserId ?? this.referredUserId,
      referralCode: referralCode ?? this.referralCode,
      status: status ?? this.status,
      bonusAmountJpy: bonusAmountJpy ?? this.bonusAmountJpy,
      referralDate: referralDate ?? this.referralDate,
      completionDate: completionDate ?? this.completionDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Creator earnings configuration
class MonetizationSettings {
  final String id;
  final String creatorId;
  final bool subscriptionsEnabled;
  final bool giftsEnabled;
  final bool clipsMonetizationEnabled;
  final bool referralsEnabled;
  final String preferredPayoutCurrency;
  final String minimumPayoutCurrencyType;
  final bool taxInfoVerified;
  final bool paymentMethodVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MonetizationSettings({
    required this.id,
    required this.creatorId,
    this.subscriptionsEnabled = true,
    this.giftsEnabled = true,
    this.clipsMonetizationEnabled = true,
    this.referralsEnabled = true,
    required this.preferredPayoutCurrency,
    required this.minimumPayoutCurrencyType,
    this.taxInfoVerified = false,
    this.paymentMethodVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'subscriptionsEnabled': subscriptionsEnabled,
      'giftsEnabled': giftsEnabled,
      'clipsMonetizationEnabled': clipsMonetizationEnabled,
      'referralsEnabled': referralsEnabled,
      'preferredPayoutCurrency': preferredPayoutCurrency,
      'minimumPayoutCurrencyType': minimumPayoutCurrencyType,
      'taxInfoVerified': taxInfoVerified,
      'paymentMethodVerified': paymentMethodVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MonetizationSettings.fromJson(Map<String, dynamic> json) {
    return MonetizationSettings(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      subscriptionsEnabled: json['subscriptionsEnabled'] as bool? ?? true,
      giftsEnabled: json['giftsEnabled'] as bool? ?? true,
      clipsMonetizationEnabled:
          json['clipsMonetizationEnabled'] as bool? ?? true,
      referralsEnabled: json['referralsEnabled'] as bool? ?? true,
      preferredPayoutCurrency: json['preferredPayoutCurrency'] as String,
      minimumPayoutCurrencyType:
          json['minimumPayoutCurrencyType'] as String,
      taxInfoVerified: json['taxInfoVerified'] as bool? ?? false,
      paymentMethodVerified: json['paymentMethodVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
