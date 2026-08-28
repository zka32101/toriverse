import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/analytics_and_moderation_providers.dart';
import '../../domain/models/analytics_and_moderation.dart';

class ModerationDashboardWidget extends ConsumerWidget {
  final ReportStatus status;
  final int limit;

  const ModerationDashboardWidget({
    Key? key,
    this.status = ReportStatus.open,
    this.limit = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(
      watchReportsQueueProvider(ReportsQueueParam(status: status, limit: limit)),
    );

    return queueAsync.when(
      data: (reports) => _buildQueue(context, ref, reports),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading moderation queue: $error'),
      ),
    );
  }

  Widget _buildQueue(BuildContext context, WidgetRef ref, List<UserReport> reports) {
    if (reports.isEmpty) {
      return const Center(child: Text('No reports in the queue'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: const Icon(Icons.flag, color: Colors.red),
            title: Text('${report.reason.name} · ${report.reportedUserId}'),
            subtitle: Text(report.description ?? 'No description provided'),
            trailing: PopupMenuButton<ReportStatus>(
              onSelected: (newStatus) async {
                final repo = ref.read(analyticsAndModerationRepositoryProvider);
                await repo.updateReportStatus(report.reportId, newStatus);
                ref.invalidate(watchReportsQueueProvider);
                ref.invalidate(reportsQueueProvider);
              },
              itemBuilder: (context) => ReportStatus.values
                  .map((s) => PopupMenuItem(value: s, child: Text(s.name)))
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}
