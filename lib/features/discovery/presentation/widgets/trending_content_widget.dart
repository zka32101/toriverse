import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/discovery_providers.dart';
import '../../domain/models/discovery.dart';

class TrendingContentWidget extends ConsumerStatefulWidget {
  final ContentTypeEnum contentType;

  const TrendingContentWidget({
    Key? key,
    this.contentType = ContentTypeEnum.creator,
  }) : super(key: key);

  @override
  ConsumerState<TrendingContentWidget> createState() =>
      _TrendingContentWidgetState();
}

class _TrendingContentWidgetState extends ConsumerState<TrendingContentWidget> {
  String _selectedTimeframe = 'week';

  @override
  Widget build(BuildContext context) {
    final trendingAsync = _getTrendingProvider();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with timeframe selector
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trending ${_getContentLabel(widget.contentType)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButton<String>(
                value: _selectedTimeframe,
                items: ['week', 'month', 'all_time']
                    .map((period) => DropdownMenuItem(
                          value: period,
                          child: Text(_getTimeframeLabel(period)),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedTimeframe = value ?? 'week');
                },
              ),
            ],
          ),
        ),
        // Trending content list
        Expanded(
          child: trendingAsync.when(
            data: (items) => _buildTrendingList(context, items),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading trending: $error'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getTrendingProvider() {
    final params = TrendingParam(
      contentType: widget.contentType,
      timeframe: _selectedTimeframe,
      limit: 50,
    );

    switch (widget.contentType) {
      case ContentTypeEnum.creator:
        return ref.watch(trendingCreatorsProvider(params));
      case ContentTypeEnum.clip:
        return ref.watch(trendingClipsProvider(params));
      case ContentTypeEnum.match:
        return ref.watch(trendingMatchesProvider(params));
      default:
        return ref.watch(trendingClipsProvider(params));
    }
  }

  Widget _buildTrendingList(BuildContext context, dynamic items) {
    if (items.isEmpty) {
      return const Center(
        child: Text('No trending content available'),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _TrendingTile(
          rank: index + 1,
          item: item,
          contentType: widget.contentType,
          onTap: () {
            // Navigate to content detail
          },
        );
      },
    );
  }

  String _getContentLabel(ContentTypeEnum type) {
    switch (type) {
      case ContentTypeEnum.creator:
        return 'Creators';
      case ContentTypeEnum.clip:
        return 'Clips';
      case ContentTypeEnum.match:
        return 'Matches';
      case ContentTypeEnum.clan:
        return 'Clans';
    }
  }

  String _getTimeframeLabel(String timeframe) {
    switch (timeframe) {
      case 'week':
        return 'This Week';
      case 'month':
        return 'This Month';
      case 'all_time':
        return 'All Time';
      default:
        return timeframe;
    }
  }
}

class _TrendingTile extends StatelessWidget {
  final int rank;
  final dynamic item;
  final ContentTypeEnum contentType;
  final VoidCallback onTap;

  const _TrendingTile({
    Key? key,
    required this.rank,
    required this.item,
    required this.contentType,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Rank badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _getRankGradient(rank),
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getItemTitle(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getMetricIcon(),
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getMetricValue(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Trending indicator
              if (rank <= 3)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up, size: 14, color: Colors.red),
                      SizedBox(width: 4),
                      Text(
                        'Trending',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getItemTitle() {
    if (item is CreatorSearchCard) {
      return item.displayName;
    } else if (item is SearchResult) {
      return item.displayData['title'] ?? 'Untitled';
    }
    return 'Content';
  }

  String _getMetricValue() {
    if (item is CreatorSearchCard) {
      return '${item.followerCount} followers';
    } else if (item is SearchResult) {
      return '${(item.matchScore * 100).toStringAsFixed(0)}% match';
    }
    return '';
  }

  IconData _getMetricIcon() {
    if (item is CreatorSearchCard) {
      return Icons.person;
    }
    return Icons.visibility;
  }

  LinearGradient _getRankGradient(int rank) {
    if (rank == 1) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.amber[700]!, Colors.amber[400]!],
      );
    } else if (rank == 2) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.grey[400]!, Colors.grey[300]!],
      );
    } else if (rank == 3) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.orange[700]!, Colors.orange[400]!],
      );
    }
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.blue[400]!, Colors.blue[300]!],
    );
  }
}
