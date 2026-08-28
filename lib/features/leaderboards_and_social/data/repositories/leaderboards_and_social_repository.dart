import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../leaderboards_and_social/domain/models/leaderboards_and_social.dart';

part 'leaderboards_and_social_repository.g.dart';

class LeaderboardsAndSocialRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAnalytics _analytics;

  LeaderboardsAndSocialRepository({
    required FirebaseFirestore firestore,
    required FirebaseAnalytics analytics,
  })  : _firestore = firestore,
        _analytics = analytics;

  // =========================================================================
  // LEADERBOARDS (15 methods)
  // =========================================================================

  Future<GlobalRanking> getGlobalRanking(String userId) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('rankings')
        .doc('global');
    final doc = await docRef.get();
    return GlobalRanking.fromJson(doc.data() ?? {});
  }

  Stream<GlobalRanking> watchGlobalRanking(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('rankings')
        .doc('global')
        .snapshots()
        .map((doc) => GlobalRanking.fromJson(doc.data() ?? {}));
  }

  Future<List<GlobalRanking>> getGlobalLeaderboard(
    int limit, {
    int offset = 0,
  }) async {
    final docs = await _firestore
        .collectionGroup('global_rankings')
        .orderBy('rank', descending: false)
        .limit(limit)
        .offset(offset)
        .get();

    return docs.docs
        .map((doc) => GlobalRanking.fromJson(doc.data()))
        .toList();
  }

  Stream<List<GlobalRanking>> watchGlobalLeaderboard(int limit) {
    return _firestore
        .collectionGroup('global_rankings')
        .orderBy('rank', descending: false)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GlobalRanking.fromJson(doc.data()))
            .toList());
  }

  Future<SeasonalRanking> getSeasonalRanking(
    String userId,
    String seasonId,
  ) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('rankings')
        .doc('seasonal_$seasonId');
    final doc = await docRef.get();
    return SeasonalRanking.fromJson(doc.data() ?? {});
  }

  Future<List<SeasonalRanking>> getSeasonalLeaderboard(
    String seasonId,
    int limit,
  ) async {
    final docs = await _firestore
        .collectionGroup('seasonal_rankings')
        .where('seasonId', isEqualTo: seasonId)
        .orderBy('rank', descending: false)
        .limit(limit)
        .get();

    return docs.docs
        .map((doc) => SeasonalRanking.fromJson(doc.data()))
        .toList();
  }

  Stream<List<SeasonalRanking>> watchSeasonalLeaderboard(
    String seasonId,
    int limit,
  ) {
    return _firestore
        .collectionGroup('seasonal_rankings')
        .where('seasonId', isEqualTo: seasonId)
        .orderBy('rank', descending: false)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SeasonalRanking.fromJson(doc.data()))
            .toList());
  }

  Future<GlobalRanking> updateRanking(String userId, double newRating) async {
    final globalRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('rankings')
        .doc('global');

    final doc = await globalRef.get();
    final currentRanking = GlobalRanking.fromJson(doc.data() ?? {});

    final updatedRanking = currentRanking.copyWith(
      rating: newRating,
      lastUpdatedAt: DateTime.now(),
    );

    await globalRef.set(updatedRanking.toJson());
    await _analytics.logEvent(
      name: 'ranking_updated',
      parameters: {
        'user_id': userId,
        'new_rating': newRating,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    return updatedRanking;
  }

  Future<List<GlobalRanking>> getRankHistory(String userId) async {
    final docs = await _firestore
        .collection('users')
        .doc(userId)
        .collection('rank_history')
        .orderBy('timestamp', descending: true)
        .get();

    return docs.docs
        .map((doc) => GlobalRanking.fromJson(doc.data()))
        .toList();
  }

  Stream<List<GlobalRanking>> watchRankHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('rank_history')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GlobalRanking.fromJson(doc.data()))
            .toList());
  }

  Future<SeasonalRanking> getUserRankProgress(
    String userId,
    String seasonId,
  ) async {
    return getSeasonalRanking(userId, seasonId);
  }

  Future<int?> getStreakMilestone(String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('rankings')
        .doc('global')
        .get();

    final ranking = GlobalRanking.fromJson(doc.data() ?? {});
    return ranking.streakBest > 0 ? ranking.streakBest : null;
  }

  Future<bool> checkRankPromotion(String userId, String seasonId) async {
    final ranking = await getSeasonalRanking(userId, seasonId);
    return ranking.promotedFrom > 0;
  }

  Future<bool> checkRankDemotion(String userId, String seasonId) async {
    final ranking = await getSeasonalRanking(userId, seasonId);
    return ranking.demotedTo > 0;
  }

  Future<List<CreatorRanking>> getCreatorLeaderboard(int limit) async {
    final docs = await _firestore
        .collection('creator_rankings')
        .orderBy('rank', descending: false)
        .limit(limit)
        .get();

    return docs.docs
        .map((doc) => CreatorRanking.fromJson(doc.data()))
        .toList();
  }

  Stream<List<CreatorRanking>> watchCreatorLeaderboard(int limit) {
    return _firestore
        .collection('creator_rankings')
        .orderBy('rank', descending: false)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CreatorRanking.fromJson(doc.data()))
            .toList());
  }

  Future<List<ClanRanking>> getClanLeaderboard(int limit) async {
    final docs = await _firestore
        .collection('clan_rankings')
        .orderBy('rank', descending: false)
        .limit(limit)
        .get();

    return docs.docs
        .map((doc) => ClanRanking.fromJson(doc.data()))
        .toList();
  }

  Future<ClanRanking> updateClanRanking(String clanId) async {
    final docRef = _firestore.collection('clan_rankings').doc(clanId);
    final doc = await docRef.get();
    final ranking = ClanRanking.fromJson(doc.data() ?? {});

    final updated = ranking.copyWith(lastUpdatedAt: DateTime.now());
    await docRef.set(updated.toJson());

    return updated;
  }

  // =========================================================================
  // USER PROFILES (8 methods)
  // =========================================================================

  Future<UserProfile> createUserProfile(UserProfile profile) async {
    await _firestore
        .collection('users')
        .doc(profile.userId)
        .collection('profile')
        .doc('data')
        .set(profile.toJson());

    await _analytics.logEvent(
      name: 'user_profile_created',
      parameters: {
        'user_id': profile.userId,
        'display_name': profile.displayName,
      },
    );

    return profile;
  }

  Future<UserProfile> getUserProfile(String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('profile')
        .doc('data')
        .get();

    return UserProfile.fromJson(doc.data() ?? {});
  }

  Stream<UserProfile> watchUserProfile(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('profile')
        .doc('data')
        .snapshots()
        .map((doc) => UserProfile.fromJson(doc.data() ?? {}));
  }

  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    await _firestore
        .collection('users')
        .doc(profile.userId)
        .collection('profile')
        .doc('data')
        .update(profile.toJson());

    await _analytics.logEvent(
      name: 'user_profile_updated',
      parameters: {
        'user_id': profile.userId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    return profile;
  }

  Future<List<UserProfile>> searchUsers(String query, int limit) async {
    final docs = await _firestore
        .collectionGroup('profile')
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThan: query + 'z')
        .limit(limit)
        .get();

    return docs.docs
        .map((doc) => UserProfile.fromJson(doc.data()))
        .toList();
  }

  Future<UserProfile> getUserStats(String userId) async {
    return getUserProfile(userId);
  }

  Future<List<UserProfile>> getTopPlayers(int limit) async {
    final docs = await _firestore
        .collectionGroup('profile')
        .orderBy('totalWins', descending: true)
        .limit(limit)
        .get();

    return docs.docs
        .map((doc) => UserProfile.fromJson(doc.data()))
        .toList();
  }

  Future<List<UserProfile>> getVerifiedUsers() async {
    final docs = await _firestore
        .collectionGroup('profile')
        .where('isVerified', isEqualTo: true)
        .get();

    return docs.docs
        .map((doc) => UserProfile.fromJson(doc.data()))
        .toList();
  }

  // =========================================================================
  // RELATIONSHIPS (12 methods)
  // =========================================================================

  Future<Friend> sendFriendRequest(String userId, String friendId) async {
    final friendDoc = Friend(
      id: '$userId-$friendId',
      userId: userId,
      friendId: friendId,
      status: FriendStatus.pending,
      requestedAt: DateTime.now(),
      acceptedAt: null,
      isFavorite: false,
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .doc(friendId)
        .set(friendDoc.toJson());

    await _analytics.logEvent(
      name: 'user_friend_request_sent',
      parameters: {
        'user_id': userId,
        'friend_id': friendId,
      },
    );

    return friendDoc;
  }

  Future<Friend> acceptFriendRequest(String userId, String friendId) async {
    final friendRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .doc(friendId);

    final doc = await friendRef.get();
    final friend = Friend.fromJson(doc.data() ?? {});

    final updated = friend.copyWith(
      status: FriendStatus.accepted,
      acceptedAt: DateTime.now(),
    );

    await friendRef.set(updated.toJson());

    await _analytics.logEvent(
      name: 'user_friend_request_accepted',
      parameters: {
        'user_id': userId,
        'friend_id': friendId,
      },
    );

    return updated;
  }

  Future<Friend> declineFriendRequest(String userId, String friendId) async {
    final friendRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .doc(friendId);

    final doc = await friendRef.get();
    final friend = Friend.fromJson(doc.data() ?? {});

    final updated = friend.copyWith(status: FriendStatus.rejected);
    await friendRef.set(updated.toJson());

    return updated;
  }

  Future<List<Friend>> getUserFriends(String userId) async {
    final docs = await _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .where('status', isEqualTo: 'accepted')
        .get();

    return docs.docs.map((doc) => Friend.fromJson(doc.data())).toList();
  }

  Stream<List<Friend>> watchUserFriends(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Friend.fromJson(doc.data())).toList());
  }

  Future<Follower> followUser(String userId, String followerId) async {
    final followerDoc = Follower(
      id: '$userId-$followerId',
      userId: userId,
      followerId: followerId,
      followedAt: DateTime.now(),
      isNotificationEnabled: true,
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('followers')
        .doc(followerId)
        .set(followerDoc.toJson());

    await _analytics.logEvent(
      name: 'user_followed',
      parameters: {
        'user_id': userId,
        'follower_id': followerId,
      },
    );

    return followerDoc;
  }

  Future<void> unfollowUser(String userId, String followerId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('followers')
        .doc(followerId)
        .delete();
  }

  Future<List<Follower>> getUserFollowers(String userId) async {
    final docs = await _firestore
        .collection('users')
        .doc(userId)
        .collection('followers')
        .get();

    return docs.docs.map((doc) => Follower.fromJson(doc.data())).toList();
  }

  Stream<List<Follower>> watchUserFollowers(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('followers')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Follower.fromJson(doc.data())).toList());
  }

  Future<List<Follower>> getFollowingList(String userId) async {
    final docs = await _firestore
        .collection('users')
        .doc(userId)
        .collection('following')
        .get();

    return docs.docs.map((doc) => Follower.fromJson(doc.data())).toList();
  }

  Stream<List<Follower>> watchFollowingList(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('following')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Follower.fromJson(doc.data())).toList());
  }

  Future<UserBlock> blockUser(
    String userId,
    String blockedUserId,
    String reason,
  ) async {
    final blockDoc = UserBlock(
      blockId: '$userId-$blockedUserId',
      userId: userId,
      blockedUserId: blockedUserId,
      reason: reason,
      blockedAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('blocks')
        .doc(blockedUserId)
        .set(blockDoc.toJson());

    return blockDoc;
  }

  Future<void> unblockUser(String userId, String blockedUserId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('blocks')
        .doc(blockedUserId)
        .delete();
  }

  Future<UserMute> muteUser(String userId, String mutedUserId) async {
    final muteDoc = UserMute(
      muteId: '$userId-$mutedUserId',
      userId: userId,
      mutedUserId: mutedUserId,
      mutedAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('mutes')
        .doc(mutedUserId)
        .set(muteDoc.toJson());

    return muteDoc;
  }

  Future<void> unmuteUser(String userId, String mutedUserId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('mutes')
        .doc(mutedUserId)
        .delete();
  }

  // =========================================================================
  // MESSAGING (5 methods)
  // =========================================================================

  Future<UserMessage> sendMessage(
    String senderId,
    String recipientId,
    String content,
  ) async {
    final conversationId = [senderId, recipientId]..sort();
    final messageId = '${DateTime.now().millisecondsSinceEpoch}';

    final messageDoc = UserMessage(
      messageId: messageId,
      senderId: senderId,
      recipientId: recipientId,
      content: content,
      sentAt: DateTime.now(),
      readAt: null,
      isStarred: false,
      replyToMessageId: null,
    );

    await _firestore
        .collection('messages')
        .doc(conversationId.join('-'))
        .collection('messages')
        .doc(messageId)
        .set(messageDoc.toJson());

    await _analytics.logEvent(
      name: 'user_message_sent',
      parameters: {
        'sender_id': senderId,
        'recipient_id': recipientId,
      },
    );

    return messageDoc;
  }

  Future<List<UserMessage>> getUserMessages(String userId, int limit) async {
    final docs = await _firestore
        .collectionGroup('messages')
        .where('recipientId', isEqualTo: userId)
        .orderBy('sentAt', descending: true)
        .limit(limit)
        .get();

    return docs.docs.map((doc) => UserMessage.fromJson(doc.data())).toList();
  }

  Stream<List<UserMessage>> watchUserMessages(String userId) {
    return _firestore
        .collectionGroup('messages')
        .where('recipientId', isEqualTo: userId)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserMessage.fromJson(doc.data()))
            .toList());
  }

  Future<UserMessage> markMessageAsRead(String messageId) async {
    // Implementation: Update message read status
    // This would require knowing the conversation and message path
    return UserMessage(
      messageId: messageId,
      senderId: '',
      recipientId: '',
      content: '',
      sentAt: DateTime.now(),
      readAt: DateTime.now(),
      isStarred: false,
      replyToMessageId: null,
    );
  }

  Future<List<UserMessage>> searchMessages(
    String userId,
    String query,
  ) async {
    final docs = await _firestore
        .collectionGroup('messages')
        .where('recipientId', isEqualTo: userId)
        .where('content', isGreaterThanOrEqualTo: query)
        .where('content', isLessThan: query + 'z')
        .get();

    return docs.docs.map((doc) => UserMessage.fromJson(doc.data())).toList();
  }

  // =========================================================================
  // CLANS (10 methods)
  // =========================================================================

  Future<Clan> createClan(Clan clan, String founderUserId) async {
    await _firestore.collection('clans').doc(clan.clanId).set(clan.toJson());

    final membership = ClanMembership(
      memberId: '$founderUserId-${clan.clanId}',
      clanId: clan.clanId,
      userId: founderUserId,
      joinedAt: DateTime.now(),
      role: ClanMemberRole.founder,
      isOwner: true,
      isOfficer: false,
      contributionScore: 0,
    );

    await _firestore
        .collection('clans')
        .doc(clan.clanId)
        .collection('members')
        .doc(founderUserId)
        .set(membership.toJson());

    await _analytics.logEvent(
      name: 'clan_created',
      parameters: {
        'clan_id': clan.clanId,
        'founder_id': founderUserId,
        'clan_name': clan.clanName,
      },
    );

    return clan;
  }

  Future<Clan> getClan(String clanId) async {
    final doc = await _firestore.collection('clans').doc(clanId).get();
    return Clan.fromJson(doc.data() ?? {});
  }

  Stream<Clan> watchClan(String clanId) {
    return _firestore
        .collection('clans')
        .doc(clanId)
        .snapshots()
        .map((doc) => Clan.fromJson(doc.data() ?? {}));
  }

  Future<Clan> updateClan(Clan clan) async {
    await _firestore
        .collection('clans')
        .doc(clan.clanId)
        .update(clan.toJson());
    return clan;
  }

  Future<ClanMembership> joinClan(String userId, String clanId) async {
    final membership = ClanMembership(
      memberId: '$userId-$clanId',
      clanId: clanId,
      userId: userId,
      joinedAt: DateTime.now(),
      role: ClanMemberRole.member,
      isOwner: false,
      isOfficer: false,
      contributionScore: 0,
    );

    await _firestore
        .collection('clans')
        .doc(clanId)
        .collection('members')
        .doc(userId)
        .set(membership.toJson());

    await _analytics.logEvent(
      name: 'clan_member_joined',
      parameters: {
        'clan_id': clanId,
        'user_id': userId,
      },
    );

    return membership;
  }

  Future<ClanMembership> approveJoinRequest(
    String userId,
    String clanId,
  ) async {
    return joinClan(userId, clanId);
  }

  Future<List<ClanMembership>> getClanMembers(String clanId) async {
    final docs = await _firestore
        .collection('clans')
        .doc(clanId)
        .collection('members')
        .get();

    return docs.docs
        .map((doc) => ClanMembership.fromJson(doc.data()))
        .toList();
  }

  Stream<List<ClanMembership>> watchClanMembers(String clanId) {
    return _firestore
        .collection('clans')
        .doc(clanId)
        .collection('members')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClanMembership.fromJson(doc.data()))
            .toList());
  }

  Future<ClanMembership> promoteToOfficer(
    String userId,
    String memberId,
  ) async {
    final memberRef = _firestore
        .collection('clans')
        .doc(userId)
        .collection('members')
        .doc(memberId);

    final doc = await memberRef.get();
    final membership = ClanMembership.fromJson(doc.data() ?? {});

    final updated = membership.copyWith(
      role: ClanMemberRole.officer,
      isOfficer: true,
    );

    await memberRef.set(updated.toJson());
    return updated;
  }

  Future<void> removeMember(String clanId, String memberId) async {
    await _firestore
        .collection('clans')
        .doc(clanId)
        .collection('members')
        .doc(memberId)
        .delete();
  }

  Future<void> dissolveClan(String clanId) async {
    await _firestore.collection('clans').doc(clanId).delete();
  }

  // =========================================================================
  // ACTIVITY & STATUS (5 methods)
  // =========================================================================

  Future<ActivityFeed> recordActivity(ActivityFeed activity) async {
    await _firestore
        .collection('users')
        .doc(activity.userId)
        .collection('activity_feed')
        .doc(activity.feedId)
        .set(activity.toJson());

    await _analytics.logEvent(
      name: 'activity_recorded',
      parameters: {
        'user_id': activity.userId,
        'activity_type': activity.activityType.toString(),
      },
    );

    return activity;
  }

  Future<List<ActivityFeed>> getUserActivityFeed(String userId, int limit) async {
    final docs = await _firestore
        .collection('users')
        .doc(userId)
        .collection('activity_feed')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return docs.docs
        .map((doc) => ActivityFeed.fromJson(doc.data()))
        .toList();
  }

  Stream<List<ActivityFeed>> watchUserActivityFeed(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('activity_feed')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivityFeed.fromJson(doc.data()))
            .toList());
  }

  Future<OnlineStatus> updateOnlineStatus(
    String userId,
    OnlineStatusType status,
  ) async {
    final onlineStatus = OnlineStatus(
      userId: userId,
      status: status,
      lastSeenAt: DateTime.now(),
      currentMatchId: null,
      isBusyStatus: status == OnlineStatusType.inMatch,
    );

    await _firestore
        .collection('online_status')
        .doc(userId)
        .set(onlineStatus.toJson());

    await _analytics.logEvent(
      name: 'user_online_status_changed',
      parameters: {
        'user_id': userId,
        'status': status.toString(),
      },
    );

    return onlineStatus;
  }

  Future<List<OnlineStatus>> getOnlineUsers(int limit) async {
    final docs = await _firestore
        .collection('online_status')
        .where('status', isEqualTo: 'online')
        .limit(limit)
        .get();

    return docs.docs
        .map((doc) => OnlineStatus.fromJson(doc.data()))
        .toList();
  }

  Stream<List<OnlineStatus>> watchOnlineUsers() {
    return _firestore
        .collection('online_status')
        .where('status', isEqualTo: 'online')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OnlineStatus.fromJson(doc.data()))
            .toList());
  }

  // =========================================================================
  // LFG & MATCHING (5 methods)
  // =========================================================================

  Future<LFGPost> createLFGPost(LFGPost post) async {
    await _firestore.collection('lfg_posts').doc(post.postId).set(post.toJson());

    await _analytics.logEvent(
      name: 'lfg_post_created',
      parameters: {
        'user_id': post.creatorId,
        'skill_level': post.skillLevel.toString(),
        'match_type': post.matchType,
      },
    );

    return post;
  }

  Future<List<LFGPost>> getLFGPosts(SkillLevel skillLevel, int limit) async {
    final docs = await _firestore
        .collection('lfg_posts')
        .where('skillLevel', isEqualTo: skillLevel.toString())
        .where('fillStatus', isEqualTo: 'open')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return docs.docs.map((doc) => LFGPost.fromJson(doc.data())).toList();
  }

  Stream<List<LFGPost>> watchLFGPosts(SkillLevel skillLevel) {
    return _firestore
        .collection('lfg_posts')
        .where('skillLevel', isEqualTo: skillLevel.toString())
        .where('fillStatus', isEqualTo: 'open')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => LFGPost.fromJson(doc.data())).toList());
  }

  Future<LFGPost> joinLFGPost(String userId, String postId) async {
    final docRef = _firestore.collection('lfg_posts').doc(postId);
    final doc = await docRef.get();
    final post = LFGPost.fromJson(doc.data() ?? {});

    final applicantIds = [...post.applicantIds, userId];
    final updated = post.copyWith(applicantIds: applicantIds);

    await docRef.set(updated.toJson());
    return updated;
  }

  Future<LFGPost> closeLFGPost(String postId) async {
    final docRef = _firestore.collection('lfg_posts').doc(postId);
    final doc = await docRef.get();
    final post = LFGPost.fromJson(doc.data() ?? {});

    final updated = post.copyWith(fillStatus: LFGFillStatus.closed);
    await docRef.set(updated.toJson());

    return updated;
  }
}

@riverpod
LeaderboardsAndSocialRepository leaderboardsAndSocialRepository(
  LeaderboardsAndSocialRepositoryRef ref,
) {
  return LeaderboardsAndSocialRepository(
    firestore: FirebaseFirestore.instance,
    analytics: FirebaseAnalytics.instance,
  );
}
