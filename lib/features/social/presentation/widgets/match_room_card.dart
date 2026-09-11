import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/match_room_model.dart';

/// Card widget for displaying a match room in list view
class MatchRoomCard extends ConsumerWidget {
  final MatchRoom room;
  final VoidCallback? onJoinTap;

  const MatchRoomCard({
    Key? key,
    required this.room,
    this.onJoinTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxPlayers = room.settings['maxPlayers'] as int? ?? 3;
    final isFull = room.players.length >= maxPlayers;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Match Room',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created by ${room.creatorUid}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: room.status == 'waiting'
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    room.status.toUpperCase(),
                    style: TextStyle(
                      color: room.status == 'waiting'
                          ? Colors.orange
                          : Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Player slots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                maxPlayers,
                (index) => Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < room.players.length
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    border: Border.all(
                      color: index < room.players.length
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      index < room.players.length
                          ? (room.players[index] == 'AI'
                              ? Icons.android
                              : Icons.person)
                          : Icons.person_outline,
                      size: 20,
                      color: index < room.players.length
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Status text
            Text(
              '${room.players.length}/$maxPlayers players',
              style: Theme.of(context).textTheme.bodySmall,
            ),

            // Join button (if applicable)
            if (onJoinTap != null && !isFull)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onJoinTap,
                    child: const Text('Join Room'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
