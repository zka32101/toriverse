import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/match_room_providers.dart';
import '../../application/providers/friend_providers.dart';

/// Screen for managing a match room and inviting friends
class MatchRoomScreen extends ConsumerStatefulWidget {
  final String roomId;

  const MatchRoomScreen({
    Key? key,
    required this.roomId,
  }) : super(key: key);

  @override
  ConsumerState<MatchRoomScreen> createState() => _MatchRoomScreenState();
}

class _MatchRoomScreenState extends ConsumerState<MatchRoomScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showInviteFriendsDialog() {
    final selectedFriends = <String>{};

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final friendsAsync = ref.watch(friendsListProvider);

          return AlertDialog(
            title: const Text('Invite Friends'),
            content: friendsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
              data: (friends) {
                return SizedBox(
                  width: 300,
                  child: ListView.builder(
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      return CheckboxListTile(
                        value: selectedFriends.contains(friend.uid),
                        onChanged: (selected) {
                          setState(() {
                            if (selected ?? false) {
                              selectedFriends.add(friend.uid);
                            } else {
                              selectedFriends.remove(friend.uid);
                            }
                          });
                        },
                        title: Text(friend.uid),
                      );
                    },
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final currentUid = ref.read(currentUserUidProvider) ?? '';

                  for (final friendUid in selectedFriends) {
                    ref
                        .read(matchRoomNotifierProvider.notifier)
                        .inviteFriendToRoom(
                          roomId: widget.roomId,
                          fromUid: currentUid,
                          toUid: friendUid,
                        );
                  }

                  Navigator.pop(context);
                },
                child: const Text('Send Invites'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomAsync = ref.watch(watchRoomProvider(widget.roomId));
    final currentUid = ref.read(currentUserUidProvider) ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Room'),
      ),
      body: roomAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error loading room: $err'),
        ),
        data: (room) {
          if (room == null) {
            return const Center(child: Text('Room not found'));
          }

          final isCreator = room.creatorUid == currentUid;
          final maxPlayers = room.settings['maxPlayers'] as int? ?? 3;
          final availableSlots = maxPlayers - room.players.length;

          return Column(
            children: [
              // Room status
              Container(
                padding: const EdgeInsets.all(16),
                color: room.status == 'waiting'
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                child: Column(
                  children: [
                    Text(
                      room.status.toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            color: room.status == 'waiting'
                                ? Colors.blue
                                : Colors.green,
                          ),
                    ),
                    const SizedBox(height: 8),
                    if (room.status == 'waiting')
                      Text(
                        'Waiting for ${availableSlots} more player${availableSlots != 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),

              // Player slots
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Players (${room.players.length}/$maxPlayers)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        maxPlayers,
                        (index) {
                          if (index < room.players.length) {
                            return Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  child: Icon(
                                    room.players[index] == 'AI'
                                        ? Icons.android
                                        : Icons.person,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  room.players[index] == 'AI'
                                      ? 'AI'
                                      : 'Player ${index + 1}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall,
                                ),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor:
                                      Colors.grey.withOpacity(0.3),
                                  child: const Icon(Icons.person_outline),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Empty',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (availableSlots > 0 && !isCreator)
                      ElevatedButton.icon(
                        onPressed: _showInviteFriendsDialog,
                        icon: const Icon(Icons.person_add),
                        label: const Text('Invite Friends'),
                      ),
                    if (isCreator) ...[
                      if (availableSlots > 0)
                        ElevatedButton.icon(
                          onPressed: _showInviteFriendsDialog,
                          icon: const Icon(Icons.person_add),
                          label: const Text('Invite Friends'),
                        ),
                      const SizedBox(height: 8),
                      if (room.players.length >= 2)
                        ElevatedButton.icon(
                          onPressed: () {
                            // Start the match
                            ref
                                .read(matchRoomNotifierProvider.notifier)
                                .startMatchFromRoom(
                                  roomId: widget.roomId,
                                  matchId: 'match_${widget.roomId}',
                                );

                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Match'),
                        ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          ref
                              .read(matchRoomNotifierProvider.notifier)
                              .cancelRoom(
                                roomId: widget.roomId,
                                creatorUid: currentUid,
                              );

                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Cancel Room'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
