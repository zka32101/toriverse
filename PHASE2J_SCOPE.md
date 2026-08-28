# Phase 2j: Leaderboards & Social Features

**Status**: Planning  
**Target**: Community engagement & competitive ranking  
**Estimated Models**: 12-15 Freezed classes  
**Estimated Repository Methods**: 35-40  
**Estimated Riverpod Providers**: 30+  
**Estimated Widgets**: 5-6  
**Documentation**: 600+ lines  

---

## Vision

Transform toriverse from a purely competitive gaming platform into a **social-competitive community** where players:
- Compete for rankings and prestige
- Connect with peers (friends, clans, followers)
- Discover and follow top creators
- Engage in group activities (clan tournaments, LFG matchmaking)
- Build identity through profiles and cosmetics

---

## Domain Models (15 Total)

### Leaderboards (4 models)
1. **GlobalRanking**
   - userId, rank, rating, wins, losses, winRate
   - totalMatches, streakCurrent, streakBest, lastUpdatedAt
   - Used for seasonal global rankings

2. **SeasonalRanking**
   - userId, seasonId, rank, rating, seasonWins, seasonLosses
   - promotedFrom (division/tier), demotedTo
   - Track rank progression within season

3. **CreatorRanking**
   - creatorId, rank, totalEarnings, followerCount, viralScore
   - topClipId, averageClipEarnings, creatorTier (verified, featured)
   - Creator-specific leaderboard

4. **ClanRanking**
   - clanId, rank, totalMatches, clanRating, memberCount
   - winStreak, tournamentWins, totalEarnings
   - Clan team ranking

### Social (6 models)
5. **UserProfile**
   - userId, displayName, bio, avatarUrl, creatorBadge
   - joinedAt, totalMatches, totalWins, totalClipsCreated
   - preferredColorScheme, isVerified, isMuted, isBlocked

6. **UserRelationship**
   - userId, relatedUserId, type (friend, follower, blocked, muted)
   - followedAt, friendRequestStatus (pending, accepted, declined)
   - bidirectional friendship or one-directional following

7. **Friend**
   - userId, friendId, status (pending, accepted, rejected)
   - requestedAt, acceptedAt, isFavorite
   - User's friend list

8. **Follower**
   - userId (the content creator), followerId (the follower)
   - followedAt, isNotificationEnabled
   - One-directional following relationship

9. **UserMessage**
   - messageId, senderId, recipientId, content
   - sentAt, readAt, isStarred, replyToMessageId
   - Direct messaging between users

10. **Clan**
    - clanId, clanName, description, founderUserId, createdAt
    - memberCount, totalMatches, totalWins, clanRating
    - tagColor, bannerUrl, isRecruiting, joinPolicy (open, approval, closed)

### Community (5 models)
11. **ClanMembership**
    - memberId, clanId, userId, joinedAt, role (founder, officer, member)
    - isOwner, isOfficer, contributionScore
    - User's clan membership

12. **ActivityFeed**
    - feedId, userId, activityType (match_won, tier_up, clip_viral, friend_added, clan_joined)
    - relatedUserId, matchId, clipId, createdAt
    - User activity timeline

13. **OnlineStatus**
    - userId, status (online, offline, idle, in_match)
    - lastSeenAt, currentMatchId, isBusyStatus
    - Real-time presence tracking

14. **LFGPost**
    - postId, creatorId, title, description, skillLevel (beginner, intermediate, advanced)
    - matchType, preferredPlatforms, createdAt, fillStatus (open, closed)
    - Looking for Group matching post

15. **UserBlock/Mute**
    - blockId, userId, blockedUserId, reason, blockedAt
    - Blocking and muting relationships

---

## Repository Methods (40 Total)

### Leaderboards (15 methods)
- `getGlobalRanking(userId)` — Fetch user's global rank
- `getGlobalLeaderboard(limit, offset)` — Top N players
- `watchGlobalLeaderboard(limit, offset)` — Real-time rankings
- `getSeasonalRanking(userId, seasonId)` — User's season rank
- `getSeasonalLeaderboard(seasonId, limit)` — Season top players
- `updateRanking(userId, newRating)` — Update after match
- `getCreatorLeaderboard(limit)` — Top creators by earnings
- `watchCreatorLeaderboard(limit)` — Real-time creator rankings
- `getClanLeaderboard(limit)` — Top clans
- `updateClanRanking(clanId)` — Update clan stats
- `getRankHistory(userId)` — User's rating history
- `getUserRankProgress(userId, seasonId)` — Season progression
- `getStreakMilestone(userId)` — Best streak record
- `checkRankPromotion(userId, seasonId)` — Check if promoted
- `checkRankDemotion(userId, seasonId)` — Check if demoted

### User Profiles (8 methods)
- `createUserProfile(profile)` — First profile creation
- `getUserProfile(userId)` — Fetch user profile
- `watchUserProfile(userId)` — Real-time profile updates
- `updateUserProfile(profile)` — Update profile details
- `searchUsers(query, limit)` — Search by name/display
- `getUserStats(userId)` — Aggregate stats (wins, losses, matches)
- `getTopPlayers(limit)` — Most matched with / popular
- `getVerifiedUsers()` — Verified/featured users list

### Relationships (12 methods)
- `sendFriendRequest(userId, friendId)` — Send friend request
- `acceptFriendRequest(userId, friendId)` — Accept request
- `declineFriendRequest(userId, friendId)` — Decline request
- `getUserFriends(userId)` — User's friend list
- `followUser(userId, followerId)` — Follow creator
- `unfollowUser(userId, followerId)` — Unfollow creator
- `getUserFollowers(userId)` — User's followers list
- `getFollowingList(userId)` — Whom user is following
- `blockUser(userId, blockedUserId, reason)` — Block user
- `unblockUser(userId, blockedUserId)` — Unblock user
- `muteUser(userId, mutedUserId)` — Mute notifications
- `unmuteUser(userId, mutedUserId)` — Unmute notifications

### Messaging (5 methods)
- `sendMessage(userId, recipientId, content)` — Send DM
- `getUserMessages(userId, limit)` — DM history
- `watchUserMessages(userId)` — Real-time messages
- `markMessageAsRead(messageId)` — Mark read
- `searchMessages(userId, query)` — Search DMs

### Clans (10 methods)
- `createClan(clan, founderUserId)` — Create new clan
- `getClan(clanId)` — Fetch clan details
- `watchClan(clanId)` — Real-time clan updates
- `updateClan(clan)` — Update clan info
- `joinClan(userId, clanId)` — Request to join
- `approveJoinRequest(userId, clanId)` — Approve join
- `getClanMembers(clanId)` — Get member list
- `promoteToOfficer(userId, memberId)` — Promote officer
- `removeMember(clanId, memberId)` — Remove from clan
- `dissolveClans(clanId)` — Disband clan

### Activity & Status (5 methods)
- `recordActivity(activity)` — Log user activity
- `getUserActivityFeed(userId, limit)` — Activity timeline
- `watchUserActivityFeed(userId, limit)` — Real-time feed
- `updateOnlineStatus(userId, status)` — Update presence
- `getOnlineUsers(limit)` — List online users

### LFG & Matching (5 methods)
- `createLFGPost(post)` — Post LFG request
- `getLFGPosts(skillLevel, limit)` — Browse LFG posts
- `watchLFGPosts(skillLevel)` — Real-time LFG
- `joinLFGPost(userId, postId)` — Express interest
- `closeLFGPost(postId)` — Mark post as filled

---

## Riverpod Providers (30+ Total)

### StreamProviders (Real-time, 12 total)
- `watchGlobalLeaderboardProvider` — Real-time rankings
- `watchSeasonalLeaderboardProvider` — Season rankings
- `watchCreatorLeaderboardProvider` — Creator rankings
- `watchUserProfileProvider` — User profile changes
- `watchUserMessagesProvider` — Real-time DMs
- `watchClanProvider` — Clan updates
- `watchUserActivityFeedProvider` — Activity timeline
- `watchOnlineStatusProvider` — Presence changes
- `watchUserFollowersProvider` — Follower changes
- `watchLFGPostsProvider` — LFG posts
- `watchClanMembersProvider` — Clan membership changes
- `watchUserFriendsProvider` — Friend list changes

### FutureProviders (Async, 15+ total)
- `userProfileProvider` — Fetch profile
- `userStatsProvider` — User statistics
- `globalLeaderboardProvider` — Global rankings
- `seasonalLeaderboardProvider` — Season rankings
- `creatorLeaderboardProvider` — Creator rankings
- `userFriendsProvider` — Friend list
- `userFollowersProvider` — Followers list
- `userFollowingProvider` — Following list
- `userMessagesProvider` — DM history
- `clanProvider` — Clan details
- `clanMembersProvider` — Clan members
- `userActivityFeedProvider` — Activity timeline
- `lfgPostsProvider` — LFG posts
- `onlineUsersProvider` — Online users
- `userSearchResultsProvider` — Search results

### MutationProviders (Transactions, 5+ total)
- `updateRankingProvider` → Invalidates leaderboards
- `sendFriendRequestProvider` → Invalidates friend list
- `sendMessageProvider` → Invalidates messages
- `createClanProvider` → Invalidates clan list
- `recordActivityProvider` → Invalidates activity feed

---

## Widgets (6 Total)

### 1. GlobalLeaderboardWidget
- Ranked list of top 100 players
- Current rank highlight
- Filter by season/all-time
- Real-time rank changes

### 2. UserProfileWidget
- User's profile card (avatar, name, bio, stats)
- Match history summary
- Friend/follower buttons
- Block/mute options
- Badges and achievements

### 3. FriendsSocialWidget
- Friends list with online status
- Recent messages quick access
- Add friend / friend request pending
- Block/mute management

### 4. ClanManagementWidget
- Clan info and members list
- Join/leave clan
- Officer management
- Clan chat

### 5. ActivityFeedWidget
- Timeline of user activities
- Friends' recent wins/achievements
- Followed creators' clips
- New match notifications

### 6. LFGMatchmakingWidget
- Browse LFG posts
- Create LFG request
- Join LFG group
- Real-time notifications

---

## Firestore Schema

```
firestore/
├── users/
│   └── {userId}/
│       ├── profile: UserProfile
│       ├── rankings/
│       │   ├── global: GlobalRanking
│       │   └── seasonal_{seasonId}: SeasonalRanking
│       ├── friends/
│       │   └── {friendId}: Friend (denormalized)
│       ├── followers/
│       │   └── {followerId}: Follower (denormalized)
│       ├── following/
│       │   └── {followeeId}: Follower (denormalized)
│       ├── messages/
│       │   └── {messageId}: UserMessage (denormalized)
│       ├── activity_feed/
│       │   └── {activityId}: ActivityFeed
│       ├── blocks/
│       │   └── {blockedUserId}: { reason, blockedAt }
│       └── mutes/
│           └── {mutedUserId}: { mutedAt }
├── global_rankings/
│   └── {rankingId}: GlobalRanking (canonical)
├── seasonal_rankings/
│   └── {seasonId}/
│       └── {userId}: SeasonalRanking
├── creator_rankings/
│   └── {rankingId}: CreatorRanking
├── clans/
│   └── {clanId}/
│       ├── clan: Clan
│       ├── members/
│       │   └── {userId}: ClanMembership
│       └── activity_feed/
│           └── {activityId}: ActivityFeed (clan-specific)
├── messages/
│   └── {conversationId}/
│       └── {messageId}: UserMessage
├── online_status/
│   └── {userId}: OnlineStatus
├── activity_feed/
│   └── {feedId}: ActivityFeed (global/canonical)
└── lfg_posts/
    └── {postId}: LFGPost
```

---

## Analytics Events

```dart
'user_ranked_up' { user_id, old_rating, new_rating, new_rank }
'user_friend_request_sent' { user_id, friend_id }
'user_friend_request_accepted' { user_id, friend_id }
'user_followed' { user_id, follower_id }
'clan_created' { clan_id, founder_id, clan_name }
'clan_member_joined' { clan_id, user_id }
'lfg_post_created' { user_id, skill_level, match_type }
'user_message_sent' { sender_id, recipient_id }
'user_online_status_changed' { user_id, status }
```

---

## Performance Targets

| Metric | Target |
|--------|--------|
| Leaderboard load | < 1.5s |
| Profile load | < 800ms |
| Friends list load | < 500ms |
| Message history load | < 1s |
| Real-time ranking update | < 500ms |
| Clan member list | < 800ms |

---

## Testing Strategy

- **Unit Tests** (30+ specs): Models, calculations
- **Widget Tests** (40+ specs): Leaderboard, profile, friends, clan widgets
- **Integration Tests** (5 specs): Friend request → accept → message flow

---

## Implementation Plan

### Step 1: Domain Models (15 classes)
- Leaderboards: GlobalRanking, SeasonalRanking, CreatorRanking, ClanRanking
- Social: UserProfile, UserRelationship, Friend, Follower, UserMessage
- Community: Clan, ClanMembership, ActivityFeed, OnlineStatus, LFGPost

### Step 2: Repository (40 methods)
- Leaderboards, profiles, relationships, messaging, clans, activity, LFG

### Step 3: Riverpod Providers (30+ providers)
- StreamProviders for real-time data
- FutureProviders for async operations
- MutationProviders with cache invalidation

### Step 4: UI Widgets (6 widgets)
- Leaderboard display, user profiles, friends, clans, activity, LFG

### Step 5: Tests & Documentation
- Comprehensive test specs
- 600+ line documentation

---

## Success Metrics

✅ All 15 models compile  
✅ All 40+ repository methods work  
✅ All 30+ providers with proper invalidation  
✅ All 6 widgets render correctly  
✅ Real-time updates < 500ms  
✅ Leaderboard updates reflect matches within 30s  
✅ Friend requests instant  
✅ Messages real-time  
✅ Clan operations < 1s  

---

**Next Steps:**
1. Confirm Phase 2j scope ✓
2. Implement domain models
3. Implement repository
4. Implement providers
5. Implement widgets
6. Test & document
7. Create PR #12
8. Merge & move to Phase 2k

**Estimated Duration**: 4-6 hours continuous development

