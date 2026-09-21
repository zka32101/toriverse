
/// Helper: deep equality for List fields (avoids adding a package dependency).
bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Helper: deep equality for Map fields (avoids adding a package dependency).
bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
      return false;
    }
  }
  return true;
}

/// User's organizer profile and capabilities
class OrganizerProfile {
  final String uid;
  final String displayName;
  final String email;
  final int tournamentCount;
  final int totalParticipants;
  final double avgRating;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final bool canHostPremium;
  final List<String> tournamentIds;
  final String bio;
  final String avatarUrl;

  const OrganizerProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.tournamentCount,
    required this.totalParticipants,
    required this.avgRating,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.canHostPremium = false,
    this.tournamentIds = const [],
    this.bio = '',
    this.avatarUrl = '',
  });

  OrganizerProfile copyWith({
    String? uid,
    String? displayName,
    String? email,
    int? tournamentCount,
    int? totalParticipants,
    double? avgRating,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    bool? canHostPremium,
    List<String>? tournamentIds,
    String? bio,
    String? avatarUrl,
  }) {
    return OrganizerProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      tournamentCount: tournamentCount ?? this.tournamentCount,
      totalParticipants: totalParticipants ?? this.totalParticipants,
      avgRating: avgRating ?? this.avgRating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      canHostPremium: canHostPremium ?? this.canHostPremium,
      tournamentIds: tournamentIds ?? this.tournamentIds,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'displayName': displayName,
        'email': email,
        'tournamentCount': tournamentCount,
        'totalParticipants': totalParticipants,
        'avgRating': avgRating,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isVerified': isVerified,
        'canHostPremium': canHostPremium,
        'tournamentIds': tournamentIds,
        'bio': bio,
        'avatarUrl': avatarUrl,
      };

  factory OrganizerProfile.fromJson(Map<String, dynamic> json) => OrganizerProfile(
        uid: json['uid'] as String,
        displayName: json['displayName'] as String,
        email: json['email'] as String,
        tournamentCount: (json['tournamentCount'] as num).toInt(),
        totalParticipants: (json['totalParticipants'] as num).toInt(),
        avgRating: (json['avgRating'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        isVerified: json['isVerified'] as bool? ?? false,
        canHostPremium: json['canHostPremium'] as bool? ?? false,
        tournamentIds: (json['tournamentIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        bio: json['bio'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String? ?? '',
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrganizerProfile &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          displayName == other.displayName &&
          email == other.email &&
          tournamentCount == other.tournamentCount &&
          totalParticipants == other.totalParticipants &&
          avgRating == other.avgRating &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          isVerified == other.isVerified &&
          canHostPremium == other.canHostPremium &&
          _listEquals(tournamentIds, other.tournamentIds) &&
          bio == other.bio &&
          avatarUrl == other.avatarUrl;

  @override
  int get hashCode => Object.hashAll([
        uid,
        displayName,
        email,
        tournamentCount,
        totalParticipants,
        avgRating,
        createdAt,
        updatedAt,
        isVerified,
        canHostPremium,
        Object.hashAll(tournamentIds),
        bio,
        avatarUrl,
      ]);
}

/// Tournament being created/drafted
class TournamentDraft {
  final String organizerId;
  final String name;
  final String description;
  final String format;
  final DateTime? startDate;
  final DateTime? registrationDeadline;
  final int maxParticipants;
  final int currentParticipants;
  final PrizePoolConfig prizePool;
  final List<String> rules;
  final String status; // draft, published, active, finished
  final bool isFeatured;
  final bool isPremium;
  final String bannerUrl;
  final String rulesetId;
  final Map<String, dynamic> bracketSettings;

  const TournamentDraft({
    required this.organizerId,
    required this.name,
    required this.description,
    required this.format,
    this.startDate,
    this.registrationDeadline,
    this.maxParticipants = 64,
    this.currentParticipants = 0,
    required this.prizePool,
    this.rules = const [],
    this.status = 'draft',
    this.isFeatured = false,
    this.isPremium = false,
    this.bannerUrl = '',
    this.rulesetId = '',
    this.bracketSettings = const {},
  });

  TournamentDraft copyWith({
    String? organizerId,
    String? name,
    String? description,
    String? format,
    DateTime? startDate,
    DateTime? registrationDeadline,
    int? maxParticipants,
    int? currentParticipants,
    PrizePoolConfig? prizePool,
    List<String>? rules,
    String? status,
    bool? isFeatured,
    bool? isPremium,
    String? bannerUrl,
    String? rulesetId,
    Map<String, dynamic>? bracketSettings,
  }) {
    return TournamentDraft(
      organizerId: organizerId ?? this.organizerId,
      name: name ?? this.name,
      description: description ?? this.description,
      format: format ?? this.format,
      startDate: startDate ?? this.startDate,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      prizePool: prizePool ?? this.prizePool,
      rules: rules ?? this.rules,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      isPremium: isPremium ?? this.isPremium,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      rulesetId: rulesetId ?? this.rulesetId,
      bracketSettings: bracketSettings ?? this.bracketSettings,
    );
  }

  Map<String, dynamic> toJson() => {
        'organizerId': organizerId,
        'name': name,
        'description': description,
        'format': format,
        'startDate': startDate?.toIso8601String(),
        'registrationDeadline': registrationDeadline?.toIso8601String(),
        'maxParticipants': maxParticipants,
        'currentParticipants': currentParticipants,
        'prizePool': prizePool.toJson(),
        'rules': rules,
        'status': status,
        'isFeatured': isFeatured,
        'isPremium': isPremium,
        'bannerUrl': bannerUrl,
        'rulesetId': rulesetId,
        'bracketSettings': bracketSettings,
      };

  factory TournamentDraft.fromJson(Map<String, dynamic> json) => TournamentDraft(
        organizerId: json['organizerId'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        format: json['format'] as String,
        startDate: json['startDate'] != null
            ? DateTime.parse(json['startDate'] as String)
            : null,
        registrationDeadline: json['registrationDeadline'] != null
            ? DateTime.parse(json['registrationDeadline'] as String)
            : null,
        maxParticipants: (json['maxParticipants'] as num?)?.toInt() ?? 64,
        currentParticipants: (json['currentParticipants'] as num?)?.toInt() ?? 0,
        prizePool:
            PrizePoolConfig.fromJson(json['prizePool'] as Map<String, dynamic>),
        rules: (json['rules'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        status: json['status'] as String? ?? 'draft',
        isFeatured: json['isFeatured'] as bool? ?? false,
        isPremium: json['isPremium'] as bool? ?? false,
        bannerUrl: json['bannerUrl'] as String? ?? '',
        rulesetId: json['rulesetId'] as String? ?? '',
        bracketSettings: json['bracketSettings'] != null
            ? Map<String, dynamic>.from(json['bracketSettings'] as Map)
            : const {},
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TournamentDraft &&
          runtimeType == other.runtimeType &&
          organizerId == other.organizerId &&
          name == other.name &&
          description == other.description &&
          format == other.format &&
          startDate == other.startDate &&
          registrationDeadline == other.registrationDeadline &&
          maxParticipants == other.maxParticipants &&
          currentParticipants == other.currentParticipants &&
          prizePool == other.prizePool &&
          _listEquals(rules, other.rules) &&
          status == other.status &&
          isFeatured == other.isFeatured &&
          isPremium == other.isPremium &&
          bannerUrl == other.bannerUrl &&
          rulesetId == other.rulesetId &&
          _mapEquals(bracketSettings, other.bracketSettings);

  @override
  int get hashCode => Object.hashAll([
        organizerId,
        name,
        description,
        format,
        startDate,
        registrationDeadline,
        maxParticipants,
        currentParticipants,
        prizePool,
        Object.hashAll(rules),
        status,
        isFeatured,
        isPremium,
        bannerUrl,
        rulesetId,
        Object.hashAll(bracketSettings.entries.map((e) => Object.hash(e.key, e.value))),
      ]);
}

/// Prize pool configuration for tournaments
class PrizePoolConfig {
  final int totalAmount;
  final Map<int, int> distribution; // rank -> amount (JPY)
  final String currency;
  final String sponsorName;
  final bool isPaidOut;
  final DateTime? paidOutAt;

  const PrizePoolConfig({
    required this.totalAmount,
    required this.distribution,
    this.currency = 'JPY',
    this.sponsorName = '',
    this.isPaidOut = false,
    this.paidOutAt,
  });

  PrizePoolConfig copyWith({
    int? totalAmount,
    Map<int, int>? distribution,
    String? currency,
    String? sponsorName,
    bool? isPaidOut,
    DateTime? paidOutAt,
  }) {
    return PrizePoolConfig(
      totalAmount: totalAmount ?? this.totalAmount,
      distribution: distribution ?? this.distribution,
      currency: currency ?? this.currency,
      sponsorName: sponsorName ?? this.sponsorName,
      isPaidOut: isPaidOut ?? this.isPaidOut,
      paidOutAt: paidOutAt ?? this.paidOutAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalAmount': totalAmount,
        'distribution': distribution.map((k, v) => MapEntry(k.toString(), v)),
        'currency': currency,
        'sponsorName': sponsorName,
        'isPaidOut': isPaidOut,
        'paidOutAt': paidOutAt?.toIso8601String(),
      };

  factory PrizePoolConfig.fromJson(Map<String, dynamic> json) => PrizePoolConfig(
        totalAmount: (json['totalAmount'] as num).toInt(),
        distribution: (json['distribution'] as Map).map(
          (k, v) => MapEntry(int.parse(k.toString()), (v as num).toInt()),
        ),
        currency: json['currency'] as String? ?? 'JPY',
        sponsorName: json['sponsorName'] as String? ?? '',
        isPaidOut: json['isPaidOut'] as bool? ?? false,
        paidOutAt: json['paidOutAt'] != null
            ? DateTime.parse(json['paidOutAt'] as String)
            : null,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrizePoolConfig &&
          runtimeType == other.runtimeType &&
          totalAmount == other.totalAmount &&
          _mapEquals(distribution, other.distribution) &&
          currency == other.currency &&
          sponsorName == other.sponsorName &&
          isPaidOut == other.isPaidOut &&
          paidOutAt == other.paidOutAt;

  @override
  int get hashCode => Object.hashAll([
        totalAmount,
        Object.hashAll(distribution.entries.map((e) => Object.hash(e.key, e.value))),
        currency,
        sponsorName,
        isPaidOut,
        paidOutAt,
      ]);
}

/// Tournament configuration details
class TournamentConfig {
  final String tournamentId;
  final String organizerId;
  final String format;
  final bool allowLateRegistration;
  final int submissionTimeSeconds;
  final bool requirePlayerConfirmation;
  final bool autoStartMatches;
  final String timezone;
  final List<String> allowedCountries;
  final int minAge;
  final int spectatorLimit;
  final bool allowStreamers;
  final bool recordMatches;
  final bool autoGenerateClips;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TournamentConfig({
    required this.tournamentId,
    required this.organizerId,
    required this.format,
    this.allowLateRegistration = false,
    this.submissionTimeSeconds = 30,
    this.requirePlayerConfirmation = false,
    this.autoStartMatches = false,
    this.timezone = 'Asia/Tokyo',
    this.allowedCountries = const [],
    this.minAge = 0,
    this.spectatorLimit = 0,
    this.allowStreamers = false,
    this.recordMatches = false,
    this.autoGenerateClips = false,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'tournamentId': tournamentId,
        'organizerId': organizerId,
        'format': format,
        'allowLateRegistration': allowLateRegistration,
        'submissionTimeSeconds': submissionTimeSeconds,
        'requirePlayerConfirmation': requirePlayerConfirmation,
        'autoStartMatches': autoStartMatches,
        'timezone': timezone,
        'allowedCountries': allowedCountries,
        'minAge': minAge,
        'spectatorLimit': spectatorLimit,
        'allowStreamers': allowStreamers,
        'recordMatches': recordMatches,
        'autoGenerateClips': autoGenerateClips,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory TournamentConfig.fromJson(Map<String, dynamic> json) => TournamentConfig(
        tournamentId: json['tournamentId'] as String,
        organizerId: json['organizerId'] as String,
        format: json['format'] as String,
        allowLateRegistration: json['allowLateRegistration'] as bool? ?? false,
        submissionTimeSeconds: (json['submissionTimeSeconds'] as num?)?.toInt() ?? 30,
        requirePlayerConfirmation: json['requirePlayerConfirmation'] as bool? ?? false,
        autoStartMatches: json['autoStartMatches'] as bool? ?? false,
        timezone: json['timezone'] as String? ?? 'Asia/Tokyo',
        allowedCountries: (json['allowedCountries'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        minAge: (json['minAge'] as num?)?.toInt() ?? 0,
        spectatorLimit: (json['spectatorLimit'] as num?)?.toInt() ?? 0,
        allowStreamers: json['allowStreamers'] as bool? ?? false,
        recordMatches: json['recordMatches'] as bool? ?? false,
        autoGenerateClips: json['autoGenerateClips'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TournamentConfig &&
          runtimeType == other.runtimeType &&
          tournamentId == other.tournamentId &&
          organizerId == other.organizerId &&
          format == other.format &&
          allowLateRegistration == other.allowLateRegistration &&
          submissionTimeSeconds == other.submissionTimeSeconds &&
          requirePlayerConfirmation == other.requirePlayerConfirmation &&
          autoStartMatches == other.autoStartMatches &&
          timezone == other.timezone &&
          _listEquals(allowedCountries, other.allowedCountries) &&
          minAge == other.minAge &&
          spectatorLimit == other.spectatorLimit &&
          allowStreamers == other.allowStreamers &&
          recordMatches == other.recordMatches &&
          autoGenerateClips == other.autoGenerateClips &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hashAll([
        tournamentId,
        organizerId,
        format,
        allowLateRegistration,
        submissionTimeSeconds,
        requirePlayerConfirmation,
        autoStartMatches,
        timezone,
        Object.hashAll(allowedCountries),
        minAge,
        spectatorLimit,
        allowStreamers,
        recordMatches,
        autoGenerateClips,
        createdAt,
        updatedAt,
      ]);
}

/// Organizer tournament statistics
class OrganizerStats {
  final String organizerId;
  final int totalTournaments;
  final int completedTournaments;
  final int totalParticipants;
  final int totalViewers;
  final int totalPrizePoolAwarded;
  final double avgPlayerRating;
  final double organizerRating;
  final List<TournamentReview> reviews;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrganizerStats({
    required this.organizerId,
    this.totalTournaments = 0,
    this.completedTournaments = 0,
    this.totalParticipants = 0,
    this.totalViewers = 0,
    this.totalPrizePoolAwarded = 0,
    this.avgPlayerRating = 0.0,
    this.organizerRating = 0.0,
    this.reviews = const [],
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'organizerId': organizerId,
        'totalTournaments': totalTournaments,
        'completedTournaments': completedTournaments,
        'totalParticipants': totalParticipants,
        'totalViewers': totalViewers,
        'totalPrizePoolAwarded': totalPrizePoolAwarded,
        'avgPlayerRating': avgPlayerRating,
        'organizerRating': organizerRating,
        'reviews': reviews.map((e) => e.toJson()).toList(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory OrganizerStats.fromJson(Map<String, dynamic> json) => OrganizerStats(
        organizerId: json['organizerId'] as String,
        totalTournaments: (json['totalTournaments'] as num?)?.toInt() ?? 0,
        completedTournaments: (json['completedTournaments'] as num?)?.toInt() ?? 0,
        totalParticipants: (json['totalParticipants'] as num?)?.toInt() ?? 0,
        totalViewers: (json['totalViewers'] as num?)?.toInt() ?? 0,
        totalPrizePoolAwarded: (json['totalPrizePoolAwarded'] as num?)?.toInt() ?? 0,
        avgPlayerRating: (json['avgPlayerRating'] as num?)?.toDouble() ?? 0.0,
        organizerRating: (json['organizerRating'] as num?)?.toDouble() ?? 0.0,
        reviews: (json['reviews'] as List<dynamic>?)
                ?.map((e) => TournamentReview.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrganizerStats &&
          runtimeType == other.runtimeType &&
          organizerId == other.organizerId &&
          totalTournaments == other.totalTournaments &&
          completedTournaments == other.completedTournaments &&
          totalParticipants == other.totalParticipants &&
          totalViewers == other.totalViewers &&
          totalPrizePoolAwarded == other.totalPrizePoolAwarded &&
          avgPlayerRating == other.avgPlayerRating &&
          organizerRating == other.organizerRating &&
          _listEquals(reviews, other.reviews) &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hashAll([
        organizerId,
        totalTournaments,
        completedTournaments,
        totalParticipants,
        totalViewers,
        totalPrizePoolAwarded,
        avgPlayerRating,
        organizerRating,
        Object.hashAll(reviews),
        createdAt,
        updatedAt,
      ]);
}

/// Review/rating for tournament organizer
class TournamentReview {
  final String id;
  final String tournamentId;
  final String reviewerId;
  final String reviewerName;
  final double rating; // 1-5 stars
  final String comment;
  final List<String> categories; // 'fair-play', 'communication', 'fairness', etc
  final DateTime? createdAt;

  const TournamentReview({
    required this.id,
    required this.tournamentId,
    required this.reviewerId,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    this.categories = const [],
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tournamentId': tournamentId,
        'reviewerId': reviewerId,
        'reviewerName': reviewerName,
        'rating': rating,
        'comment': comment,
        'categories': categories,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory TournamentReview.fromJson(Map<String, dynamic> json) => TournamentReview(
        id: json['id'] as String,
        tournamentId: json['tournamentId'] as String,
        reviewerId: json['reviewerId'] as String,
        reviewerName: json['reviewerName'] as String,
        rating: (json['rating'] as num).toDouble(),
        comment: json['comment'] as String,
        categories: (json['categories'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TournamentReview &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          tournamentId == other.tournamentId &&
          reviewerId == other.reviewerId &&
          reviewerName == other.reviewerName &&
          rating == other.rating &&
          comment == other.comment &&
          _listEquals(categories, other.categories) &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hashAll([
        id,
        tournamentId,
        reviewerId,
        reviewerName,
        rating,
        comment,
        Object.hashAll(categories),
        createdAt,
      ]);
}

/// Tournament participation request from player
class TournamentRegistration {
  final String id;
  final String tournamentId;
  final String userId;
  final String displayName;
  final DateTime? registeredAt;
  final String status; // pending, approved, rejected, withdrawn
  final DateTime? approvedAt;
  final String notes; // organizer notes about player

  const TournamentRegistration({
    required this.id,
    required this.tournamentId,
    required this.userId,
    required this.displayName,
    this.registeredAt,
    this.status = 'pending',
    this.approvedAt,
    this.notes = '',
  });

  TournamentRegistration copyWith({
    String? id,
    String? tournamentId,
    String? userId,
    String? displayName,
    DateTime? registeredAt,
    String? status,
    DateTime? approvedAt,
    String? notes,
  }) {
    return TournamentRegistration(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      registeredAt: registeredAt ?? this.registeredAt,
      status: status ?? this.status,
      approvedAt: approvedAt ?? this.approvedAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tournamentId': tournamentId,
        'userId': userId,
        'displayName': displayName,
        'registeredAt': registeredAt?.toIso8601String(),
        'status': status,
        'approvedAt': approvedAt?.toIso8601String(),
        'notes': notes,
      };

  factory TournamentRegistration.fromJson(Map<String, dynamic> json) =>
      TournamentRegistration(
        id: json['id'] as String,
        tournamentId: json['tournamentId'] as String,
        userId: json['userId'] as String,
        displayName: json['displayName'] as String,
        registeredAt: json['registeredAt'] != null
            ? DateTime.parse(json['registeredAt'] as String)
            : null,
        status: json['status'] as String? ?? 'pending',
        approvedAt: json['approvedAt'] != null
            ? DateTime.parse(json['approvedAt'] as String)
            : null,
        notes: json['notes'] as String? ?? '',
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TournamentRegistration &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          tournamentId == other.tournamentId &&
          userId == other.userId &&
          displayName == other.displayName &&
          registeredAt == other.registeredAt &&
          status == other.status &&
          approvedAt == other.approvedAt &&
          notes == other.notes;

  @override
  int get hashCode => Object.hashAll([
        id,
        tournamentId,
        userId,
        displayName,
        registeredAt,
        status,
        approvedAt,
        notes,
      ]);
}

/// Payout request for tournament prizes
class PayoutRequest {
  final String id;
  final String tournamentId;
  final String organizerId;
  final int totalAmount;
  final Map<String, int> payouts; // userId -> amount (JPY)
  final String status; // pending, approved, processing, completed, failed
  final String bankAccount;
  final DateTime? requestedAt;
  final DateTime? processedAt;
  final String notes;

  const PayoutRequest({
    required this.id,
    required this.tournamentId,
    required this.organizerId,
    required this.totalAmount,
    required this.payouts,
    this.status = 'pending',
    this.bankAccount = '',
    this.requestedAt,
    this.processedAt,
    this.notes = '',
  });

  PayoutRequest copyWith({
    String? id,
    String? tournamentId,
    String? organizerId,
    int? totalAmount,
    Map<String, int>? payouts,
    String? status,
    String? bankAccount,
    DateTime? requestedAt,
    DateTime? processedAt,
    String? notes,
  }) {
    return PayoutRequest(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      organizerId: organizerId ?? this.organizerId,
      totalAmount: totalAmount ?? this.totalAmount,
      payouts: payouts ?? this.payouts,
      status: status ?? this.status,
      bankAccount: bankAccount ?? this.bankAccount,
      requestedAt: requestedAt ?? this.requestedAt,
      processedAt: processedAt ?? this.processedAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tournamentId': tournamentId,
        'organizerId': organizerId,
        'totalAmount': totalAmount,
        'payouts': payouts,
        'status': status,
        'bankAccount': bankAccount,
        'requestedAt': requestedAt?.toIso8601String(),
        'processedAt': processedAt?.toIso8601String(),
        'notes': notes,
      };

  factory PayoutRequest.fromJson(Map<String, dynamic> json) => PayoutRequest(
        id: json['id'] as String,
        tournamentId: json['tournamentId'] as String,
        organizerId: json['organizerId'] as String,
        totalAmount: (json['totalAmount'] as num).toInt(),
        payouts: (json['payouts'] as Map).map(
          (k, v) => MapEntry(k.toString(), (v as num).toInt()),
        ),
        status: json['status'] as String? ?? 'pending',
        bankAccount: json['bankAccount'] as String? ?? '',
        requestedAt: json['requestedAt'] != null
            ? DateTime.parse(json['requestedAt'] as String)
            : null,
        processedAt: json['processedAt'] != null
            ? DateTime.parse(json['processedAt'] as String)
            : null,
        notes: json['notes'] as String? ?? '',
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PayoutRequest &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          tournamentId == other.tournamentId &&
          organizerId == other.organizerId &&
          totalAmount == other.totalAmount &&
          _mapEquals(payouts, other.payouts) &&
          status == other.status &&
          bankAccount == other.bankAccount &&
          requestedAt == other.requestedAt &&
          processedAt == other.processedAt &&
          notes == other.notes;

  @override
  int get hashCode => Object.hashAll([
        id,
        tournamentId,
        organizerId,
        totalAmount,
        Object.hashAll(payouts.entries.map((e) => Object.hash(e.key, e.value))),
        status,
        bankAccount,
        requestedAt,
        processedAt,
        notes,
      ]);
}

/// Template for organizing recurring tournament series
class TournamentTemplate {
  final String id;
  final String organizerId;
  final String name;
  final String format;
  final PrizePoolConfig prizePoolTemplate;
  final List<String> rules;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TournamentTemplate({
    required this.id,
    required this.organizerId,
    required this.name,
    required this.format,
    required this.prizePoolTemplate,
    this.rules = const [],
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'organizerId': organizerId,
        'name': name,
        'format': format,
        'prizePoolTemplate': prizePoolTemplate.toJson(),
        'rules': rules,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory TournamentTemplate.fromJson(Map<String, dynamic> json) => TournamentTemplate(
        id: json['id'] as String,
        organizerId: json['organizerId'] as String,
        name: json['name'] as String,
        format: json['format'] as String,
        prizePoolTemplate:
            PrizePoolConfig.fromJson(json['prizePoolTemplate'] as Map<String, dynamic>),
        rules: (json['rules'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TournamentTemplate &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizerId == other.organizerId &&
          name == other.name &&
          format == other.format &&
          prizePoolTemplate == other.prizePoolTemplate &&
          _listEquals(rules, other.rules) &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hashAll([
        id,
        organizerId,
        name,
        format,
        prizePoolTemplate,
        Object.hashAll(rules),
        createdAt,
        updatedAt,
      ]);
}
