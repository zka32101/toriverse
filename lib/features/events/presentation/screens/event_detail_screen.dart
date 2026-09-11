import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/index.dart';
import '../../data/models/event_model.dart';
import '../widgets/index.dart';

/// Event detail screen showing event info, challenges, cosmetics, and leaderboard
class EventDetailScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailScreen({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailsStreamProvider(eventId));
    final hasJoinedAsync = ref.watch(hasJoinedEventProvider(eventId));
    final progressAsync = ref.watch(eventProgressStreamProvider(eventId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        elevation: 0,
      ),
      body: eventAsync.when(
        data: (event) {
          if (event == null) {
            return const Center(child: Text('Event not found'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.refresh(eventDetailsStreamProvider(eventId).future);
              await ref.refresh(hasJoinedEventProvider(eventId).future);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Banner
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      image: event.imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(event.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: event.imageUrl == null
                        ? Center(
                            child: Text(
                              event.theme,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          )
                        : null,
                  ),

                  // Event Info
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Name
                        Text(
                          event.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),

                        // Event Dates
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              '${event.startDate.toString().split(' ')[0]} - ${event.endDate.toString().split(' ')[0]}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Event Status
                        Chip(
                          label: Text(event.status.toUpperCase()),
                          backgroundColor: event.status == 'active'
                              ? Colors.green
                              : Colors.orange,
                          labelStyle: const TextStyle(color: Colors.white),
                        ),

                        const SizedBox(height: 16),

                        // Event Description
                        if (event.description != null)
                          Text(
                            event.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),

                        const SizedBox(height: 24),

                        // Join Button or Progress
                        hasJoinedAsync.when(
                          data: (hasJoined) {
                            if (!hasJoined) {
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    ref
                                        .read(eventNotifierProvider.notifier)
                                        .joinEvent(eventId);
                                  },
                                  child: const Text('Join Event'),
                                ),
                              );
                            }

                            return progressAsync.when(
                              data: (progress) {
                                if (progress == null) {
                                  return const SizedBox.shrink();
                                }

                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your Progress',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: 12),
                                    ProgressIndicator(
                                      label: 'Score',
                                      current: progress.totalScore,
                                      max: event.maxRankPoints,
                                    ),
                                    const SizedBox(height: 8),
                                    ProgressIndicator(
                                      label: 'Challenges',
                                      current:
                                          progress.completedChallenges.length,
                                      max: 10,
                                    ),
                                    const SizedBox(height: 8),
                                    ProgressIndicator(
                                      label: 'Cosmetics',
                                      current:
                                          progress.unlockedCosmetics.length,
                                      max: 20,
                                    ),
                                  ],
                                );
                              },
                              loading: () =>
                                  const CircularProgressIndicator(),
                              error: (error, stack) => Text('Error: $error'),
                            );
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stack) => Text('Error: $error'),
                        ),

                        const SizedBox(height: 24),

                        // Tabs for Challenges, Cosmetics, Leaderboard
                        DefaultTabController(
                          length: 3,
                          child: Column(
                            children: [
                              TabBar(
                                tabs: const [
                                  Tab(text: 'Challenges'),
                                  Tab(text: 'Cosmetics'),
                                  Tab(text: 'Leaderboard'),
                                ],
                                labelColor:
                                    Theme.of(context).primaryColor,
                                unselectedLabelColor:
                                    Colors.grey,
                              ),
                              SizedBox(
                                height: 400,
                                child: TabBarView(
                                  children: [
                                    // Challenges Tab
                                    _ChallengesTab(eventId: eventId),

                                    // Cosmetics Tab
                                    _CosmeticsTab(eventId: eventId),

                                    // Leaderboard Tab
                                    _LeaderboardTab(eventId: eventId),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _ChallengesTab extends ConsumerWidget {
  final String eventId;

  const _ChallengesTab({required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(eventChallengesFutureProvider(eventId));

    return challengesAsync.when(
      data: (challenges) {
        if (challenges.isEmpty) {
          return const Center(child: Text('No challenges available'));
        }

        return ListView.builder(
          itemCount: challenges.length,
          itemBuilder: (context, index) {
            return ChallengeCard(challenge: challenges[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _CosmeticsTab extends ConsumerWidget {
  final String eventId;

  const _CosmeticsTab({required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cosmeticsAsync =
        ref.watch(limitedCosmeticsProvider(eventId));

    return cosmeticsAsync.when(
      data: (cosmetics) {
        if (cosmetics.isEmpty) {
          return const Center(child: Text('No cosmetics available'));
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: cosmetics.length,
          itemBuilder: (context, index) {
            return LimitedCosmeticCard(cosmetic: cosmetics[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _LeaderboardTab extends ConsumerWidget {
  final String eventId;

  const _LeaderboardTab({required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync =
        ref.watch(leaderboardFutureProvider('$eventId|100'));

    return leaderboardAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return const Center(child: Text('No leaderboard entries yet'));
        }

        return ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            return LeaderboardEntryWidget(
              entry: entries[index],
              rank: index + 1,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
