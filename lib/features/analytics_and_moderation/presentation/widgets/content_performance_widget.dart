import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/analytics_and_moderation_providers.dart';
import '../../domain/models/analytics_and_moderation.dart';

class ContentPerformanceWidget extends ConsumerWidget {
  final String creatorId;
  final int limit;
  final String period;

  const ContentPerformanceWidget({
    Key? key,
    required this.creatorId,
    this.limit = 10,
    this.period = 'month',
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topContentAsync = ref.watch(
      topContentProvider(
        TopContentParam(creatorId: creatorId, limit: limit, period: period),
      ),
    );

    return topContentAsync.when(
      data: (contentList) => _buildContentList(context, contentList),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading content performance: $error'),
      ),
    );
  }

  Widget _buildContentList(BuildContext context, List<ContentPerformance> contentList) {
    if (contentList.isEmpty) {
      return const Center(child: Text('No content performance data available'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contentList.length,
      itemBuilder: (context, index) {
        final content = contentList[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(content.contentType),
            subtitle: Text(
              '${content.views} views · ${content.likeCount} likes · '
              '${(content.completionRate * 100).toStringAsFixed(0)}% completion',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.share, size: 16, color: Colors.grey[600]),
                Text('${content.shareCount}', style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
        );
      },
    );
  }
}
