import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/clipping/application/providers/clip_providers.dart';
import 'package:toriverse/features/clipping/domain/models/clip.dart';

/// Widget for generating clips from highlight moments
class ClipGeneratorWidget extends ConsumerStatefulWidget {
  final String matchId;
  final String highlightId;
  final String creatorId;
  final int startTimestamp;
  final int endTimestamp;
  final String momentType;

  const ClipGeneratorWidget({
    Key? key,
    required this.matchId,
    required this.highlightId,
    required this.creatorId,
    required this.startTimestamp,
    required this.endTimestamp,
    required this.momentType,
  }) : super(key: key);

  @override
  ConsumerState<ClipGeneratorWidget> createState() => _ClipGeneratorWidgetState();
}

class _ClipGeneratorWidgetState extends ConsumerState<ClipGeneratorWidget> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String _selectedTemplate = 'standard';
  bool _includeMusic = true;
  bool _includeEffects = true;
  bool _includeTextOverlay = true;
  bool _generateVertical = true;
  bool _generateSquare = true;
  bool _generateLandscape = true;
  List<String> _selectedPlatforms = ['youtube', 'instagram', 'tiktok'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForGeneration() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
      );
      return;
    }

    try {
      final config = ClipGenerationConfig(
        id: 'config_${widget.matchId}',
        template: _selectedTemplate,
        includeMusic: _includeMusic,
        includeEffects: _includeEffects,
        includeTextOverlay: _includeTextOverlay,
        generateVertical: _generateVertical,
        generateSquare: _generateSquare,
        generateLandscape: _generateLandscape,
        platforms: _selectedPlatforms,
      );

      final createParam = CreateClipParam(
        matchId: widget.matchId,
        highlightId: widget.highlightId,
        creatorId: widget.creatorId,
        title: _titleController.text,
        description: _descriptionController.text,
        momentType: widget.momentType,
        startTimestamp: widget.startTimestamp,
        endTimestamp: widget.endTimestamp,
      );

      final clip = await ref.read(createClipProvider(createParam).future);

      // Submit for generation
      await ref.read(
        submitForGenerationProvider(
          SubmitForGenerationParam(clipId: clip.id, config: config),
        ).future,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clip submitted for generation!')),
        );
        _titleController.clear();
        _descriptionController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Clip',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          // Title field
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Clip Title',
              hintText: 'e.g., Incredible Upset Victory',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Description field
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Describe what makes this moment special...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Template selection
          Text(
            'Template',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['standard', 'highlight_reel', 'dramatic', 'funny']
                .map((template) => ChoiceChip(
                  label: Text(template),
                  selected: _selectedTemplate == template,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedTemplate = template);
                    }
                  },
                ))
                .toList(),
          ),
          const SizedBox(height: 24),
          // Format options
          Text(
            'Format Options',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            title: const Text('Include Music'),
            value: _includeMusic,
            onChanged: (value) => setState(() => _includeMusic = value ?? true),
            dense: true,
          ),
          CheckboxListTile(
            title: const Text('Include Effects'),
            value: _includeEffects,
            onChanged: (value) => setState(() => _includeEffects = value ?? true),
            dense: true,
          ),
          CheckboxListTile(
            title: const Text('Include Text Overlay'),
            value: _includeTextOverlay,
            onChanged: (value) => setState(() => _includeTextOverlay = value ?? true),
            dense: true,
          ),
          const SizedBox(height: 24),
          // Aspect ratios
          Text(
            'Generate For',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            title: const Text('Landscape (16:9)'),
            value: _generateLandscape,
            onChanged: (value) => setState(() => _generateLandscape = value ?? true),
            dense: true,
          ),
          CheckboxListTile(
            title: const Text('Vertical (9:16)'),
            value: _generateVertical,
            onChanged: (value) => setState(() => _generateVertical = value ?? true),
            dense: true,
          ),
          CheckboxListTile(
            title: const Text('Square (1:1)'),
            value: _generateSquare,
            onChanged: (value) => setState(() => _generateSquare = value ?? true),
            dense: true,
          ),
          const SizedBox(height: 24),
          // Platform selection
          Text(
            'Platforms',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['youtube', 'instagram', 'tiktok', 'twitter', 'twitch']
                .map((platform) => FilterChip(
                  label: Text(platform),
                  selected: _selectedPlatforms.contains(platform),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedPlatforms.add(platform);
                      } else {
                        _selectedPlatforms.remove(platform);
                      }
                    });
                  },
                ))
                .toList(),
          ),
          const SizedBox(height: 32),
          // Submit button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _submitForGeneration,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Submit for Generation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
