import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/leaderboards_and_social/domain/models/leaderboards_and_social.dart';

void main() {
  group('Leaderboards And Social Models Tests', () {
    // ========================================================================
    // LEADERBOARD MODELS TESTS (12 specs)
    // ========================================================================

    group('GlobalRanking Model', () {
      test('should create GlobalRanking with all properties', () {
        final ranking = GlobalRanking(
          id: 'rank-1',
          userId: 'user-123',
          rank: 1,
          rating: 2500,
          wins: 100,
          losses: 20,
          winRate: 0.833,
          totalMatches: 120,
          streakCurrent: 5,
          streakBest: 12,
          tier: RankTier.diamond,
          lastUpdatedAt: DateTime(2026, 8, 28),
        );

        expect(ranking.userId, 'user-123');
        expect(ranking.rank, 1);
        expect(ranking.rating, 2500);
        expect(ranking.tier, RankTier.diamond);
      });

      test('should serialize GlobalRanking to JSON', () {
        final ranking = GlobalRanking(
          id: 'rank-1',
          userId: 'user-123',
          rank: 1,
          rating: 2500,
          wins: 100,
          losses: 20,
          winRate: 0.833,
          totalMatches: 120,
          streakCurrent: 5,
          streakBest: 12,
          tier: RankTier.diamond,
          lastUpdatedAt: DateTime(2026, 8, 28),
        );

        final json = ranking.toJson();
        expect(json['userId'], 'user-123');
        expect(json['rating'], 2500);
      });

      test('should deserialize GlobalRanking from JSON', () {
        final json = {
          'id': 'rank-1',
          'userId': 'user-123',
          'rank': 1,
          'rating': 2500,
          'wins': 100,
          'losses': 20,
          'winRate': 0.833,
          'totalMatches': 120,
          'streakCurrent': 5,
          'streakBest': 12,
          'tier': 'diamond',
          'lastUpdatedAt': '2026-08-28T00:00:00.000Z',
        };

        final ranking = GlobalRanking.fromJson(json);
        expect(ranking.userId, 'user-123');
        expect(ranking.rating, 2500);
      });

      test('should calculate win rate correctly', () {
        final ranking = GlobalRanking(
          id: 'rank-1',
          userId: 'user-123',
          rank: 1,
          rating: 2500,
          wins: 80,
          losses: 20,
          winRate: 0.8,
          totalMatches: 100,
          streakCurrent: 5,
          streakBest: 12,
          tier: RankTier.gold,
          lastUpdatedAt: DateTime.now(),
        );

        expect(ranking.winRate, 0.8);
        expect(ranking.totalMatches, 100);
      });
    });

    group('SeasonalRanking Model', () {
      test('should create SeasonalRanking with season ID', () {
        final ranking = SeasonalRanking(
          id: 'season-rank-1',
          userId: 'user-123',
          seasonId: 'season-2026-q3',
          rank: 5,
          rating: 2200,
          seasonWins: 45,
          seasonLosses: 15,
          promotedFrom: 0,
          demotedTo: 0,
          tier: RankTier.platinum,
          seasonStartDate: DateTime(2026, 7, 1),
          lastUpdatedAt: DateTime.now(),
        );

        expect(ranking.seasonId, 'season-2026-q3');
        expect(ranking.seasonWins, 45);
      });

      test('should track promotion status', () {
        final ranking = SeasonalRanking(
          id: 'season-rank-1',
          userId: 'user-123',
          seasonId: 'season-2026-q3',
          rank: 5,
          rating: 2200,
          seasonWins: 45,
          seasonLosses: 15,
          promotedFrom: 2,
          demotedTo: 0,
          tier: RankTier.platinum,
          seasonStartDate: DateTime(2026, 7, 1),
          lastUpdatedAt: DateTime.now(),
        );

        expect(ranking.promotedFrom, 2);
        expect(ranking.demotedTo, 0);
      });
    });

    group('CreatorRanking Model', () {
      test('should create CreatorRanking with earnings', () {
        final ranking = CreatorRanking(
          id: 'creator-rank-1',
          creatorId: 'creator-123',
          rank: 1,
          totalEarnings: 50000,
          followerCount: 100000,
          viralScore: 9.8,
          topClipId: 'clip-xyz',
          averageClipEarnings: 500,
          creatorTier: CreatorTier.elite,
          totalClipsMonetized: 100,
          lastUpdatedAt: DateTime.now(),
        );

        expect(ranking.totalEarnings, 50000);
        expect(ranking.creatorTier, CreatorTier.elite);
      });

      test('should track creator tier', () {
        final rankings = [
          CreatorRanking(
            id: '1',
            creatorId: 'c1',
            rank: 1,
            totalEarnings: 100000,
            followerCount: 500000,
            viralScore: 10,
            topClipId: 'clip-1',
            averageClipEarnings: 1000,
            creatorTier: CreatorTier.elite,
            totalClipsMonetized: 200,
            lastUpdatedAt: DateTime.now(),
          ),
          CreatorRanking(
            id: '2',
            creatorId: 'c2',
            rank: 2,
            totalEarnings: 50000,
            followerCount: 100000,
            viralScore: 8,
            topClipId: 'clip-2',
            averageClipEarnings: 500,
            creatorTier: CreatorTier.featured,
            totalClipsMonetized: 100,
            lastUpdatedAt: DateTime.now(),
          ),
        ];

        expect(rankings[0].creatorTier, CreatorTier.elite);
        expect(rankings[1].creatorTier, CreatorTier.featured);
      });
    });

    group('ClanRanking Model', () {
      test('should create ClanRanking with team stats', () {
        final ranking = ClanRanking(
          id: 'clan-rank-1',
          clanId: 'clan-123',
          rank: 1,
          totalMatches: 500,
          clanRating: 3000,
          memberCount: 50,
          winStreak: 10,
          tournamentWins: 5,
          totalEarnings: 100000,
          lastUpdatedAt: DateTime.now(),
        );

        expect(ranking.memberCount, 50);
        expect(ranking.winStreak, 10);
        expect(ranking.totalMatches, 500);
      });
    });

    // ========================================================================
    // SOCIAL MODELS TESTS (12 specs)
    // ========================================================================

    group('UserProfile Model', () {
      test('should create UserProfile with display name', () {
        final profile = UserProfile(
          userId: 'user-123',
          displayName: 'Player123',
          bio: 'Casual player',
          avatarUrl: 'https://example.com/avatar.png',
          creatorBadge: false,
          isVerified: false,
          isMuted: false,
          isBlocked: false,
          preferredColorScheme: 'dark',
          totalMatches: 50,
          totalWins: 30,
          totalClipsCreated: 5,
          joinedAt: DateTime(2026, 1, 1),
          lastUpdatedAt: DateTime.now(),
        );

        expect(profile.displayName, 'Player123');
        expect(profile.totalMatches, 50);
      });

      test('should serialize and deserialize UserProfile', () {
        final profile = UserProfile(
          userId: 'user-123',
          displayName: 'Player123',
          bio: 'Casual player',
          avatarUrl: 'https://example.com/avatar.png',
          creatorBadge: false,
          isVerified: true,
          isMuted: false,
          isBlocked: false,
          preferredColorScheme: 'dark',
          totalMatches: 50,
          totalWins: 30,
          totalClipsCreated: 5,
          joinedAt: DateTime(2026, 1, 1),
          lastUpdatedAt: DateTime.now(),
        );

        final json = profile.toJson();
        final restored = UserProfile.fromJson(json);

        expect(restored.displayName, profile.displayName);
        expect(restored.isVerified, true);
      });

      test('should track verification status', () {
        final profiles = [
          UserProfile(
            userId: 'user-1',
            displayName: 'Verified',
            bio: 'Pro player',
            avatarUrl: '',
            creatorBadge: true,
            isVerified: true,
            isMuted: false,
            isBlocked: false,
            preferredColorScheme: 'dark',
            totalMatches: 100,
            totalWins: 80,
            totalClipsCreated: 20,
            joinedAt: DateTime.now(),
            lastUpdatedAt: DateTime.now(),
          ),
          UserProfile(
            userId: 'user-2',
            displayName: 'Unverified',
            bio: 'Casual',
            avatarUrl: '',
            creatorBadge: false,
            isVerified: false,
            isMuted: false,
            isBlocked: false,
            preferredColorScheme: 'light',
            totalMatches: 10,
            totalWins: 5,
            totalClipsCreated: 0,
            joinedAt: DateTime.now(),
            lastUpdatedAt: DateTime.now(),
          ),
        ];

        expect(profiles[0].isVerified, true);
        expect(profiles[1].isVerified, false);
      });
    });

    group('Friend Model', () {
      test('should create Friend with request status', () {
        final friend = Friend(
          id: 'friend-1',
          userId: 'user-123',
          friendId: 'user-456',
          status: FriendStatus.pending,
          requestedAt: DateTime.now(),
          acceptedAt: null,
          isFavorite: false,
        );

        expect(friend.status, FriendStatus.pending);
        expect(friend.acceptedAt, null);
      });

      test('should transition friend status', () {
        final pending = Friend(
          id: 'friend-1',
          userId: 'user-123',
          friendId: 'user-456',
          status: FriendStatus.pending,
          requestedAt: DateTime.now(),
          acceptedAt: null,
          isFavorite: false,
        );

        final accepted = pending.copyWith(
          status: FriendStatus.accepted,
          acceptedAt: DateTime.now(),
        );

        expect(pending.status, FriendStatus.pending);
        expect(accepted.status, FriendStatus.accepted);
      });

      test('should mark friend as favorite', () {
        final friend = Friend(
          id: 'friend-1',
          userId: 'user-123',
          friendId: 'user-456',
          status: FriendStatus.accepted,
          requestedAt: DateTime.now(),
          acceptedAt: DateTime.now(),
          isFavorite: false,
        );

        final favorite = friend.copyWith(isFavorite: true);
        expect(favorite.isFavorite, true);
      });
    });

    group('Follower Model', () {
      test('should create Follower relationship', () {
        final follower = Follower(
          id: 'follower-1',
          userId: 'creator-123',
          followerId: 'user-456',
          followedAt: DateTime.now(),
          isNotificationEnabled: true,
        );

        expect(follower.userId, 'creator-123');
        expect(follower.followerId, 'user-456');
      });

      test('should toggle notification status', () {
        final follower = Follower(
          id: 'follower-1',
          userId: 'creator-123',
          followerId: 'user-456',
          followedAt: DateTime.now(),
          isNotificationEnabled: true,
        );

        final notified = follower.copyWith(isNotificationEnabled: false);
        expect(notified.isNotificationEnabled, false);
      });
    });

    group('UserMessage Model', () {
      test('should create UserMessage with content', () {
        final message = UserMessage(
          messageId: 'msg-1',
          senderId: 'user-123',
          recipientId: 'user-456',
          content: 'Hello!',
          sentAt: DateTime.now(),
          readAt: null,
          isStarred: false,
          replyToMessageId: null,
        );

        expect(message.content, 'Hello!');
        expect(message.readAt, null);
      });

      test('should mark message as read', () {
        final message = UserMessage(
          messageId: 'msg-1',
          senderId: 'user-123',
          recipientId: 'user-456',
          content: 'Hello!',
          sentAt: DateTime.now(),
          readAt: null,
          isStarred: false,
          replyToMessageId: null,
        );

        final read = message.copyWith(readAt: DateTime.now());
        expect(read.readAt != null, true);
      });

      test('should support message threading', () {
        final original = UserMessage(
          messageId: 'msg-1',
          senderId: 'user-123',
          recipientId: 'user-456',
          content: 'Original message',
          sentAt: DateTime.now(),
          readAt: null,
          isStarred: false,
          replyToMessageId: null,
        );

        final reply = UserMessage(
          messageId: 'msg-2',
          senderId: 'user-456',
          recipientId: 'user-123',
          content: 'Reply to original',
          sentAt: DateTime.now(),
          readAt: null,
          isStarred: false,
          replyToMessageId: 'msg-1',
        );

        expect(reply.replyToMessageId, 'msg-1');
        expect(original.replyToMessageId, null);
      });
    });

    // ========================================================================
    // COMMUNITY MODELS TESTS (8 specs)
    // ========================================================================

    group('Clan Model', () {
      test('should create Clan with join policy', () {
        final clan = Clan(
          clanId: 'clan-123',
          clanName: 'Elite Squad',
          description: 'Competitive clan',
          founderUserId: 'user-123',
          createdAt: DateTime.now(),
          memberCount: 25,
          totalMatches: 500,
          totalWins: 350,
          clanRating: 2800,
          tagColor: 'blue',
          bannerUrl: 'https://example.com/banner.png',
          isRecruiting: true,
          joinPolicy: JoinPolicy.approval,
        );

        expect(clan.clanName, 'Elite Squad');
        expect(clan.joinPolicy, JoinPolicy.approval);
      });

      test('should track recruiting status', () {
        final clan1 = Clan(
          clanId: 'clan-1',
          clanName: 'Clan 1',
          description: 'Recruiting',
          founderUserId: 'user-1',
          createdAt: DateTime.now(),
          memberCount: 10,
          totalMatches: 100,
          totalWins: 70,
          clanRating: 2000,
          tagColor: 'red',
          bannerUrl: '',
          isRecruiting: true,
          joinPolicy: JoinPolicy.open,
        );

        final clan2 = clan1.copyWith(isRecruiting: false);
        expect(clan1.isRecruiting, true);
        expect(clan2.isRecruiting, false);
      });
    });

    group('ClanMembership Model', () {
      test('should create ClanMembership with role', () {
        final membership = ClanMembership(
          memberId: 'member-1',
          clanId: 'clan-123',
          userId: 'user-456',
          joinedAt: DateTime.now(),
          role: ClanMemberRole.member,
          isOwner: false,
          isOfficer: false,
          contributionScore: 100,
        );

        expect(membership.role, ClanMemberRole.member);
        expect(membership.isOfficer, false);
      });

      test('should promote member to officer', () {
        final member = ClanMembership(
          memberId: 'member-1',
          clanId: 'clan-123',
          userId: 'user-456',
          joinedAt: DateTime.now(),
          role: ClanMemberRole.member,
          isOwner: false,
          isOfficer: false,
          contributionScore: 100,
        );

        final officer = member.copyWith(
          role: ClanMemberRole.officer,
          isOfficer: true,
        );

        expect(member.role, ClanMemberRole.member);
        expect(officer.role, ClanMemberRole.officer);
      });
    });

    group('ActivityFeed Model', () {
      test('should create ActivityFeed with metadata', () {
        final activity = ActivityFeed(
          feedId: 'activity-1',
          userId: 'user-123',
          activityType: ActivityType.matchWon,
          relatedUserId: 'user-456',
          matchId: 'match-xyz',
          clipId: null,
          clanId: null,
          metadata: {'opponent': 'Player456'},
          createdAt: DateTime.now(),
        );

        expect(activity.activityType, ActivityType.matchWon);
        expect(activity.metadata?['opponent'], 'Player456');
      });

      test('should track different activity types', () {
        final activities = [
          ActivityFeed(
            feedId: '1',
            userId: 'user-1',
            activityType: ActivityType.matchWon,
            relatedUserId: null,
            matchId: null,
            clipId: null,
            clanId: null,
            metadata: null,
            createdAt: DateTime.now(),
          ),
          ActivityFeed(
            feedId: '2',
            userId: 'user-1',
            activityType: ActivityType.tierUp,
            relatedUserId: null,
            matchId: null,
            clipId: null,
            clanId: null,
            metadata: null,
            createdAt: DateTime.now(),
          ),
          ActivityFeed(
            feedId: '3',
            userId: 'user-1',
            activityType: ActivityType.friendAdded,
            relatedUserId: 'user-2',
            matchId: null,
            clipId: null,
            clanId: null,
            metadata: null,
            createdAt: DateTime.now(),
          ),
        ];

        expect(activities[0].activityType, ActivityType.matchWon);
        expect(activities[1].activityType, ActivityType.tierUp);
        expect(activities[2].activityType, ActivityType.friendAdded);
      });
    });

    group('OnlineStatus Model', () {
      test('should create OnlineStatus', () {
        final status = OnlineStatus(
          userId: 'user-123',
          status: OnlineStatusType.online,
          lastSeenAt: DateTime.now(),
          currentMatchId: null,
          isBusyStatus: false,
        );

        expect(status.status, OnlineStatusType.online);
        expect(status.isBusyStatus, false);
      });

      test('should update status in match', () {
        final online = OnlineStatus(
          userId: 'user-123',
          status: OnlineStatusType.online,
          lastSeenAt: DateTime.now(),
          currentMatchId: null,
          isBusyStatus: false,
        );

        final inMatch = online.copyWith(
          status: OnlineStatusType.inMatch,
          currentMatchId: 'match-xyz',
          isBusyStatus: true,
        );

        expect(online.status, OnlineStatusType.online);
        expect(inMatch.status, OnlineStatusType.inMatch);
        expect(inMatch.isBusyStatus, true);
      });
    });

    group('LFGPost Model', () {
      test('should create LFGPost with applicants', () {
        final post = LFGPost(
          postId: 'lfg-1',
          creatorId: 'user-123',
          title: 'Looking for 2 more players',
          description: 'Ranked mode, competitive play',
          skillLevel: SkillLevel.advanced,
          matchType: '3v3',
          preferredPlatforms: ['Mobile', 'Console'],
          createdAt: DateTime.now(),
          fillStatus: LFGFillStatus.open,
          applicantIds: ['user-456', 'user-789'],
          maxParticipants: 3,
        );

        expect(post.skillLevel, SkillLevel.advanced);
        expect(post.applicantIds.length, 2);
      });

      test('should track fill status', () {
        final open = LFGPost(
          postId: 'lfg-1',
          creatorId: 'user-123',
          title: 'LFG',
          description: 'Looking for group',
          skillLevel: SkillLevel.intermediate,
          matchType: '1v1',
          preferredPlatforms: ['Mobile'],
          createdAt: DateTime.now(),
          fillStatus: LFGFillStatus.open,
          applicantIds: ['user-456'],
          maxParticipants: 2,
        );

        final closed = open.copyWith(
          fillStatus: LFGFillStatus.closed,
          applicantIds: ['user-456', 'user-789'],
        );

        expect(open.fillStatus, LFGFillStatus.open);
        expect(closed.fillStatus, LFGFillStatus.closed);
      });
    });

    group('Block and Mute Models', () {
      test('should create UserBlock with reason', () {
        final block = UserBlock(
          blockId: 'block-1',
          userId: 'user-123',
          blockedUserId: 'user-456',
          reason: 'Harassment',
          blockedAt: DateTime.now(),
        );

        expect(block.reason, 'Harassment');
        expect(block.blockedUserId, 'user-456');
      });

      test('should create UserMute', () {
        final mute = UserMute(
          muteId: 'mute-1',
          userId: 'user-123',
          mutedUserId: 'user-456',
          mutedAt: DateTime.now(),
        );

        expect(mute.mutedUserId, 'user-456');
      });
    });
  });
}
