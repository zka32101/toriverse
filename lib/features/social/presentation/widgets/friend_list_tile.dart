import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/friend_providers.dart';
import '../../data/models/friend_model.dart';

/// Tile widget for displaying a friend in the friends list
class FriendListTile extends ConsumerWidget {
  final Friend friend;

  const FriendListTile({
    Key? key,
    required this.friend,
  }) : super(key: key);

  void _showFriendMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              friend.uid,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Message'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to messaging screen (future feature)
              },
            ),
            ListTile(
              leading: const Icon(Icons.games),
              title: const Text('Invite to Match'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to create match room screen
              },
            ),
            if (friend.isFavorite)
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Unpin Friend'),
                onTap: () {
                  ref
                      .read(friendNotifierProvider.notifier)
                      .toggleFavoriteFriend(
                        uid: '', // Would be current user UID
                        friendUid: friend.uid,
                      );
                  Navigator.pop(context);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: const Text('Pin Friend'),
                onTap: () {
                  ref
                      .read(friendNotifierProvider.notifier)
                      .toggleFavoriteFriend(
                        uid: '', // Would be current user UID
                        friendUid: friend.uid,
                      );
                  Navigator.pop(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.note_outlined),
              title: const Text('Add Note'),
              onTap: () {
                Navigator.pop(context);
                _showNotesDialog(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block User'),
              onTap: () {
                ref.read(friendNotifierProvider.notifier).blockUser(
                  uid: '', // Would be current user UID
                  blockedUid: friend.uid,
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Remove Friend',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                ref.read(friendNotifierProvider.notifier).removeFriend(
                  uid: '', // Would be current user UID
                  friendUid: friend.uid,
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotesDialog(BuildContext context, WidgetRef ref) {
    final notesController = TextEditingController(text: friend.notes ?? '');

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notes'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            hintText: 'Add personal notes about this friend...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(friendNotifierProvider.notifier).updateFriendNotes(
                uid: '', // Would be current user UID
                friendUid: friend.uid,
                notes: notesController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(friend.uid.substring(0, 2).toUpperCase()),
      ),
      title: Text(friend.uid),
      subtitle: friend.lastInteraction != null
          ? Text('Last played: ${friend.lastInteraction}')
          : null,
      trailing: friend.isFavorite
          ? const Icon(Icons.star, color: Colors.amber)
          : null,
      onTap: () {
        // Navigate to friend profile
      },
      onLongPress: () => _showFriendMenu(context, ref),
    );
  }
}
