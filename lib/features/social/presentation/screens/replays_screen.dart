import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/replay_providers.dart';
import '../widgets/replay_card.dart';

/// Screen for browsing and sharing replays
class ReplaysScreen extends ConsumerStatefulWidget {
  const ReplaysScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ReplaysScreen> createState() => _ReplaysScreenState();
}

class _ReplaysScreenState extends ConsumerState<ReplaysScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _selectedTag = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myReplaysAsync = ref.watch(myReplaysProvider);
    final publicReplaysAsync = ref.watch(publicReplaysProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Replays'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Replays'),
            Tab(text: 'Discover'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Replays Tab
          myReplaysAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text('Error loading replays: $err'),
            ),
            data: (replays) {
              if (replays.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.video_library_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No replays yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete a match to generate a replay',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 9 / 16,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: replays.length,
                itemBuilder: (context, index) {
                  return ReplayCard(
                    replay: replays[index],
                    onTap: () {
                      // Navigate to replay player
                    },
                  );
                },
              );
            },
          ),

          // Discover Tab
          Column(
            children: [
              // Search and filter bar
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by tag or creator...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 8),
                    // Popular tags
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          '#highlights',
                          '#clutch',
                          '#comeback',
                          '#fail',
                          '#epic',
                        ]
                            .map((tag) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: FilterChip(
                                label: Text(tag),
                                selected: _selectedTag == tag,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedTag = selected ? tag : '';
                                  });
                                },
                              ),
                            ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Public replays
              Expanded(
                child: publicReplaysAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Text('Error loading replays: $err'),
                  ),
                  data: (replays) {
                    if (replays.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.video_library_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No public replays',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 9 / 16,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: replays.length,
                      itemBuilder: (context, index) {
                        return ReplayCard(
                          replay: replays[index],
                          onTap: () {
                            // Navigate to replay player
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
