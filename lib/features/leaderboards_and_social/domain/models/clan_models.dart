import 'package:freezed_annotation/freezed_annotation.dart';

part 'clan_models.freezed.dart';
part 'clan_models.g.dart';

// ============================================================================
// COMMUNITY - CLANS (2 Models)
// ============================================================================

enum JoinPolicy { open, approval, closed }

@freezed
class Clan with _$Clan {
  const factory Clan({
    required String clanId,
    required String clanName,
    required String description,
    required String founderUserId,
    required DateTime createdAt,
    required int memberCount,
    required int totalMatches,
    required int totalWins,
    required double clanRating,
    required String tagColor,
    required String bannerUrl,
    required bool isRecruiting,
    required JoinPolicy joinPolicy,
  }) = _Clan;

  factory Clan.fromJson(Map<String, dynamic> json) => _$ClanFromJson(json);
}

enum ClanMemberRole { founder, officer, member }

@freezed
class ClanMembership with _$ClanMembership {
  const factory ClanMembership({
    required String memberId,
    required String clanId,
    required String userId,
    required DateTime joinedAt,
    required ClanMemberRole role,
    required bool isOwner,
    required bool isOfficer,
    required int contributionScore,
  }) = _ClanMembership;

  factory ClanMembership.fromJson(Map<String, dynamic> json) =>
      _$ClanMembershipFromJson(json);
}
