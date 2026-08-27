import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/spectating/application/providers/spectator_chat_providers.dart';
import 'package:toriverse/features/spectating/domain/models/spectator_message.dart';

/// Main spectator chat widget
///
/// Displays real-time chat messages and provides input for sending new messages.
/// Includes moderation features for commentators and moderators.
class SpectatorChatWidget extends ConsumerStatefulWidget {
  final String matchId;
  final String userId;
  final String displayName;
  final SpectatorChatRole userRole;

  const SpectatorChatWidget({
    Key? key,
    required this.matchId,
    required this.userId,
    required this.displayName,
    required this.userRole,
  }) : super(key: key);

  @override
  ConsumerState<SpectatorChatWidget> createState() =>
      _SpectatorChatWidgetState();
}

class _SpectatorChatWidgetState extends ConsumerState<SpectatorChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    setState(() => _isSending = true);

    try {
      // Check if user is muted
      final isMuted = await ref.read(
        isUserMutedProvider(
          _CheckMuteParams(
            matchId: widget.matchId,
            userId: widget.userId,
          ),
        ).future,
      );

      if (isMuted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are currently muted in this chat'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        setState(() => _isSending = false);
        return;
      }

      // Send message
      await ref.read(
        sendChatMessageProvider(
          _SendMessageParams(
            matchId: widget.matchId,
            userId: widget.userId,
            displayName: widget.displayName,
            text: _messageController.text,
            role: widget.userRole,
          ),
        ).future,
      );

      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chat messages list
        Expanded(
          child: _buildMessagesList(),
        ),

        // Divider
        Divider(height: 1),

        // Message input field
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildMessageInput(),
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    final messagesAsync = ref.watch(matchChatMessagesProvider(widget.matchId));

    return messagesAsync.when(
      data: (messages) {
        if (messages.isEmpty) {
          return Center(
            child: Text(
              'No messages yet. Be the first to comment!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
            ),
          );
        }

        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[messages.length - 1 - index];
            return _MessageTile(
              message: message,
              matchId: widget.matchId,
              currentUserRole: widget.userRole,
              currentUserId: widget.userId,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading messages: $error'),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            enabled: !_isSending,
            maxLines: null,
            maxLength: ChatModerationConfig.maxMessageLength,
            decoration: InputDecoration(
              hintText: 'Send a message...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              counterText: '',
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 48,
          height: 48,
          child: FloatingActionButton(
            onPressed: _isSending ? null : _sendMessage,
            mini: true,
            child: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Message tile widget
// ============================================================================

/// Individual message tile with moderation controls
class _MessageTile extends ConsumerWidget {
  final SpectatorMessage message;
  final String matchId;
  final SpectatorChatRole currentUserRole;
  final String currentUserId;

  const _MessageTile({
    required this.message,
    required this.matchId,
    required this.currentUserRole,
    required this.currentUserId,
  });

  void _showModerationMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currentUserRole.canPin)
              ListTile(
                leading: const Icon(Icons.push_pin),
                title: Text(message.isPinned ? 'Unpin message' : 'Pin message'),
                onTap: () {
                  if (message.isPinned) {
                    ref.read(
                      unpinChatMessageProvider(
                        _PinMessageParams(
                          matchId: matchId,
                          messageId: message.id,
                          userRole: currentUserRole,
                        ),
                      ),
                    );
                  } else {
                    ref.read(
                      pinChatMessageProvider(
                        _PinMessageParams(
                          matchId: matchId,
                          messageId: message.id,
                          userRole: currentUserRole,
                        ),
                      ),
                    );
                  }
                  Navigator.pop(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Report message'),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(context, ref);
              },
            ),
            if (currentUserRole.canModerate)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete message'),
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () {
                  ref.read(
                    deleteChatMessageProvider(
                      _DeleteMessageParams(
                        matchId: matchId,
                        messageId: message.id,
                        userRole: currentUserRole,
                      ),
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            if (currentUserRole.canModerate)
              ListTile(
                leading: const Icon(Icons.volume_off),
                title: const Text('Mute user'),
                onTap: () {
                  Navigator.pop(context);
                  _showMuteDialog(context, ref);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context, WidgetRef ref) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Message'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Why are you reporting this message?',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(
                reportChatMessageProvider(
                  _ReportMessageParams(
                    matchId: matchId,
                    messageId: message.id,
                    reportedBy: currentUserId,
                    reason: reasonController.text,
                  ),
                ),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message reported')),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _showMuteDialog(BuildContext context, WidgetRef ref) {
    int selectedMinutes = 5;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mute User'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mute duration: $selectedMinutes minutes'),
              Slider(
                value: selectedMinutes.toDouble(),
                min: 1,
                max: 60,
                divisions: 59,
                label: '$selectedMinutes',
                onChanged: (value) {
                  setState(() => selectedMinutes = value.toInt());
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(
                muteUserProvider(
                  _MuteUserParams(
                    matchId: matchId,
                    userId: message.userId,
                    duration: Duration(minutes: selectedMinutes),
                    userRole: currentUserRole,
                  ),
                ),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User muted for $selectedMinutes minutes')),
              );
            },
            child: const Text('Mute'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: message.isPinned
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          radius: 20,
          child: Text(
            message.displayName.isNotEmpty
                ? message.displayName[0].toUpperCase()
                : '?',
          ),
        ),
        title: Row(
          children: [
            Text(message.displayName),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getRoleColor(message.role),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                message.role.emoji,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            if (message.isPinned)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.push_pin,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.text),
            if (message.isModerated)
              Text(
                '⚠️ ${message.moderationReason ?? "Content flagged"}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.orange,
                    ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Options'),
              onTap: () {
                Future.microtask(
                  () => _showModerationMenu(context, ref),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(SpectatorChatRole role) {
    switch (role) {
      case SpectatorChatRole.viewer:
        return Colors.blue.withOpacity(0.2);
      case SpectatorChatRole.commentator:
        return Colors.orange.withOpacity(0.2);
      case SpectatorChatRole.streamer:
        return Colors.purple.withOpacity(0.2);
      case SpectatorChatRole.moderator:
        return Colors.red.withOpacity(0.2);
    }
  }
}
