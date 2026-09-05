import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/index.dart';
import '../widgets/index.dart';

/// Event leaderboard screen showing player rankings
class EventLeaderboardScreen extends ConsumerWidget {
  final String eventId;

  const EventLeaderboardScreen({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync =
        ref.watch(leaderboardFutureProvider('$eventId|100'));
    final userRankAsync = ref.watch(userRankEntryProvider(eventId));
    final totalParticipantsAsync =
        ref.watch(totalParticipantsProvider(eventId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.refresh(leaderboardFutureProvider('$eventId|100').future);
          await ref.refresh(userRankEntryProvider(eventId).future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // User's Rank Card
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: userRankAsync.when(
                  data: (userEntry) {
                    if (userEntry == null) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'Join the event to see your rank',
                              style:
                                  Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      );
                    }

                    return Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Rank',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '#${userEntry.rank}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      userEntry.displayName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${userEntry.score}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Points',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) =>
                      Center(child: Text('Error: $error')),
                ),
              ),

              // Total Participants
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: totalParticipantsAsync.when(
                  data: (count) {
                    return Text(
                      '$count players',
                      style: Theme.of(context).textTheme.bodySmall,
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (error, stack) => const SizedBox.shrink(),
                ),
              ),

              const Divider(),

              // Leaderboard List
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: leaderboardAsync.when(
                  data: (entries) {
                    if (entries.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            'No leaderboard entries yet',
                            style:
                                Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return LeaderboardEntryWidget(
                          entry: entries[index],
                          rank: index + 1,
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) =>
                      Center(child: Text('Error: $error')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
