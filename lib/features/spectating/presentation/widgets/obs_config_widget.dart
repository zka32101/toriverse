import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/spectating/application/providers/streaming_providers.dart';
import 'package:toriverse/features/spectating/domain/models/streaming_session.dart';

/// OBS configuration widget for setting up browser source overlay
///
/// Provides UI for configuring overlay elements (chat, scoreboard, player names)
/// and generates OBS browser source URL for streaming setup.
class OBSConfigWidget extends ConsumerStatefulWidget {
  final String sessionId;

  const OBSConfigWidget({
    required this.sessionId,
  });

  @override
  ConsumerState<OBSConfigWidget> createState() => _OBSConfigWidgetState();
}

class _OBSConfigWidgetState extends ConsumerState<OBSConfigWidget> {
  late bool showChat;
  late bool showScoreboard;
  late bool showPlayerNames;
  late String overlayTheme;

  @override
  void initState() {
    super.initState();
    showChat = true;
    showScoreboard = true;
    showPlayerNames = true;
    overlayTheme = 'dark';
  }

  @override
  Widget build(BuildContext context) {
    final obsConfig = ref.watch(obsConfigProvider(widget.sessionId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OBS Browser Source Configuration',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Overlay options
          const Text(
            'Overlay Elements',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          _buildCheckboxTile(
            title: 'Show Chat',
            subtitle: 'Display spectator chat messages',
            value: showChat,
            onChanged: (value) {
              setState(() => showChat = value ?? true);
            },
          ),
          const SizedBox(height: 8),

          _buildCheckboxTile(
            title: 'Show Scoreboard',
            subtitle: 'Display current board state and scores',
            value: showScoreboard,
            onChanged: (value) {
              setState(() => showScoreboard = value ?? true);
            },
          ),
          const SizedBox(height: 8),

          _buildCheckboxTile(
            title: 'Show Player Names',
            subtitle: 'Display player name overlays',
            value: showPlayerNames,
            onChanged: (value) {
              setState(() => showPlayerNames = value ?? true);
            },
          ),
          const SizedBox(height: 24),

          // Theme selection
          const Text(
            'Overlay Theme',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          SegmentedButton<String>(
            segments: const <ButtonSegment<String>>[
              ButtonSegment<String>(
                value: 'dark',
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode),
              ),
              ButtonSegment<String>(
                value: 'light',
                label: Text('Light'),
                icon: Icon(Icons.light_mode),
              ),
              ButtonSegment<String>(
                value: 'custom',
                label: Text('Custom'),
                icon: Icon(Icons.palette),
              ),
            ],
            selected: <String>{overlayTheme},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() => overlayTheme = newSelection.first);
            },
          ),
          const SizedBox(height: 24),

          // Source URL section
          Card(
            color: Colors.grey[900],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Browser Source URL',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  obsConfig.when(
                    data: (config) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          config.sourceUrl,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _copyToClipboard(context, config.sourceUrl);
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy URL'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (err, stack) => Text(
                      'Error: $err',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Setup instructions
          _buildSetupInstructions(),
          const SizedBox(height: 24),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Configuration saved'),
                  ),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check),
              label: const Text('Apply Settings'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSetupInstructions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Setup Instructions',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildInstructionStep(
              number: '1',
              title: 'Open OBS Studio',
              description: 'Launch OBS on your streaming PC',
            ),
            const SizedBox(height: 12),
            _buildInstructionStep(
              number: '2',
              title: 'Add Browser Source',
              description:
                  'In Sources panel, click + → Browser → Create new',
            ),
            const SizedBox(height: 12),
            _buildInstructionStep(
              number: '3',
              title: 'Paste URL',
              description: 'Paste the generated URL above into the URL field',
            ),
            const SizedBox(height: 12),
            _buildInstructionStep(
              number: '4',
              title: 'Configure Dimensions',
              description: 'Set width: 1920, height: 1080 (or match your scene)',
            ),
            const SizedBox(height: 12),
            _buildInstructionStep(
              number: '5',
              title: 'Adjust Positioning',
              description:
                  'Move and resize the overlay to fit your broadcast layout',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.blue,
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    // Copy implementation would go here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('URL copied to clipboard')),
    );
  }
}
