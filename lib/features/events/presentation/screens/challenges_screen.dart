import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/index.dart';
import '../widgets/index.dart';

/// Challenges screen showing daily and weekly challenges
class ChallengesScreen extends ConsumerWidget {
  final String eventId;

  const ChallengesScreen({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyChallengesAsync = ref.watch(dailyChallengesProvider(eventId));
    final weeklyChallengesAsync = ref.watch(weeklyChallengesProvider(eventId));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Challenges'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Daily'),
              Tab(text: 'Weekly'),
            ],
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: TabBarView(
          children: [
            // Daily Challenges
            RefreshIndicator(
              onRefresh: () async {
                await ref.refresh(dailyChallengesProvider(eventId).future);
              },
              child: dailyChallengesAsync.when(
                data: (challenges) {
                  if (challenges.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'No daily challenges available',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: challenges.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return ChallengeCard(
                        challenge: challenges[index],
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Text('Error: ${error.toString()}'),
                ),
              ),
            ),

            // Weekly Challenges
            RefreshIndicator(
              onRefresh: () async {
                await ref.refresh(weeklyChallengesProvider(eventId).future);
              },
              child: weeklyChallengesAsync.when(
                data: (challenges) {
                  if (challenges.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'No weekly challenges available',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: challenges.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return ChallengeCard(
                        challenge: challenges[index],
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Text('Error: ${error.toString()}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
