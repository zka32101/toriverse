import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/organizing/application/providers/organizer_providers.dart';
import 'package:toriverse/features/organizing/domain/models/organizer.dart';

/// Participant management interface for tournament organizers
///
/// Displays registration requests, allows approval/rejection,
/// and shows active participants in the tournament.
class ParticipantManagementWidget extends ConsumerWidget {
  final String tournamentId;

  const ParticipantManagementWidget({
    required this.tournamentId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registrationsAsync = ref.watch(
      registrationsProvider(_GetRegistrationsParams(tournamentId)),
    );

    return registrationsAsync.when(
      data: (registrations) {
        final pending = registrations.where((r) => r.status == 'pending').toList();
        final approved = registrations.where((r) => r.status == 'approved').toList();
        final rejected = registrations.where((r) => r.status == 'rejected').toList();

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Participant Management'),
              bottom: TabBar(
                tabs: [
                  Tab(
                    child: Text(
                      'Pending (${pending.length})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Approved (${approved.length})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Rejected (${rejected.length})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildPendingList(context, ref, pending),
                _buildApprovedList(context, ref, approved),
                _buildRejectedList(context, ref, rejected),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, stack) => Center(
        child: Text('Error loading registrations: $err'),
      ),
    );
  }

  Widget _buildPendingList(
    BuildContext context,
    WidgetRef ref,
    List<TournamentRegistration> pending,
  ) {
    if (pending.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No pending registrations',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: pending.length,
      itemBuilder: (context, index) {
        final registration = pending[index];
        return _RegistrationCard(
          registration: registration,
          tournamentId: tournamentId,
          onApprove: () => _approveRegistration(context, ref, registration),
          onReject: () => _rejectRegistration(context, ref, registration),
        );
      },
    );
  }

  Widget _buildApprovedList(
    BuildContext context,
    WidgetRef ref,
    List<TournamentRegistration> approved,
  ) {
    if (approved.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No approved participants yet',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: approved.length,
      itemBuilder: (context, index) {
        final registration = approved[index];
        return _ParticipantCard(
          registration: registration,
          index: index + 1,
        );
      },
    );
  }

  Widget _buildRejectedList(
    BuildContext context,
    WidgetRef ref,
    List<TournamentRegistration> rejected,
  ) {
    if (rejected.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No rejected participants',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: rejected.length,
      itemBuilder: (context, index) {
        final registration = rejected[index];
        return _RejectedCard(registration: registration);
      },
    );
  }

  void _approveRegistration(
    BuildContext context,
    WidgetRef ref,
    TournamentRegistration registration,
  ) async {
    try {
      await ref.read(approveRegistrationProvider((
        tournamentId,
        registration.id,
      )).future);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${registration.displayName} approved',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving registration: $e')),
        );
      }
    }
  }

  void _rejectRegistration(
    BuildContext context,
    WidgetRef ref,
    TournamentRegistration registration,
  ) async {
    final reason = await _showRejectDialog(context);
    if (reason == null) return;

    try {
      await ref.read(rejectRegistrationProvider((
        tournamentId,
        registration.id,
        reason,
      )).future);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${registration.displayName} rejected',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting registration: $e')),
        );
      }
    }
  }

  Future<String?> _showRejectDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Registration'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Reason for rejection (optional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

/// Registration request card
class _RegistrationCard extends StatelessWidget {
  final TournamentRegistration registration;
  final String tournamentId;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _RegistrationCard({
    required this.registration,
    required this.tournamentId,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        registration.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        registration.userId,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'PENDING',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
            if (registration.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  registration.notes,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red[300]!),
                    ),
                    child: Text(
                      'Reject',
                      style: TextStyle(color: Colors.red[600]),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                    ),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Approved participant card
class _ParticipantCard extends StatelessWidget {
  final TournamentRegistration registration;
  final int index;

  const _ParticipantCard({
    required this.registration,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[100],
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    registration.displayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Registered ${registration.registeredAt != null ? _formatDate(registration.registeredAt!) : 'recently'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.check_circle, color: Colors.green[600]),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

/// Rejected participant card
class _RejectedCard extends StatelessWidget {
  final TournamentRegistration registration;

  const _RejectedCard({required this.registration});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.block, color: Colors.red[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    registration.displayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (registration.notes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      registration.notes,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
