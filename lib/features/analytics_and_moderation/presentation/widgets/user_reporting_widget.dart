import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/analytics_and_moderation_providers.dart';
import '../../domain/models/analytics_and_moderation.dart';

class UserReportingWidget extends ConsumerStatefulWidget {
  final String reporterId;
  final String reportedUserId;
  final VoidCallback? onSubmitted;

  const UserReportingWidget({
    Key? key,
    required this.reporterId,
    required this.reportedUserId,
    this.onSubmitted,
  }) : super(key: key);

  @override
  ConsumerState<UserReportingWidget> createState() => _UserReportingWidgetState();
}

class _UserReportingWidgetState extends ConsumerState<UserReportingWidget> {
  ReportReason _selectedReason = ReportReason.harassment;
  final _descriptionController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    setState(() => _submitting = true);
    try {
      final repo = ref.read(analyticsAndModerationRepositoryProvider);
      await repo.createUserReport(
        widget.reporterId,
        widget.reportedUserId,
        _selectedReason,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );
      ref.invalidate(reportsQueueProvider);
      ref.invalidate(watchReportsQueueProvider);
      widget.onSubmitted?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted. Thank you.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Report User',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text('Reason', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          DropdownButtonFormField<ReportReason>(
            value: _selectedReason,
            items: ReportReason.values
                .map((reason) => DropdownMenuItem(
                      value: reason,
                      child: Text(reason.name),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedReason = value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Additional details (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submitReport,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit Report'),
            ),
          ),
        ],
      ),
    );
  }
}
