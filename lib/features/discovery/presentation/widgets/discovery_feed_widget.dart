import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/discovery_providers.dart';
import '../../domain/models/discovery.dart';

class DiscoveryFeedWidget extends ConsumerWidget {
  final String userId;
  final int limit;

  const DiscoveryFeedWidget({
    Key? key,
    required this.userId,
    this.limit = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(
      watchPersonalizedFeedProvider(userId),
    );

    return feedAsync.when(
      data: (feed) => _buildDiscoveryFeed(context, feed),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading discovery feed: $error'),
      ),
    );
  }

  Widget _buildDiscoveryFeed(BuildContext context, RecommendationFeed feed) {
    if (feed.items.isEmpty) {
      return const Center(
        child: Text('No recommendations available'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Personalized recommendations based on your interests',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Discovery items carousel
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: feed.items.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _DiscoveryCard(
                    item: feed.items[index],
                    onTap: () {
                      // Handle tap - navigate to profile/content
                    },
                  ),
                );
              },
            ),
          ),
          // Trending section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'What\'s Trending',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // View all trending
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoveryCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _DiscoveryCard({
    Key? key,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.withOpacity(0.1),
                Colors.purple.withOpacity(0.1),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar/Image placeholder
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                ),
                child: const Center(
                  child: Icon(Icons.image, size: 40),
                ),
              ),
              const SizedBox(height: 12),
              // Content info
              Text(
                item['displayName'] ?? 'Unknown',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Stats
              Row(
                children: [
                  Icon(Icons.person, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${item['followerCount'] ?? 0} followers',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Follow/Action button
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  minimumSize: const Size(double.infinity, 32),
                ),
                child: const Text('Follow', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
