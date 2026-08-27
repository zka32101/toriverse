import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User document model for Firestore
/// Maps to 'users' collection with document ID = uid
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String displayName,
    @Default(0) int rankPoints,
    @Default(0) int completedMatchStreak,
    @Default(0) int freeMatchUsedToday,
    @Default('trial') String subscriptionStatus, // 'trial', 'active', 'cancelled'
    required DateTime createdAt,
    DateTime? lastPlayedAt,
    DateTime? lastDailyResetAt,
    @Default([]) List<String> ownedCosmetics, // cosmetic item IDs
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
