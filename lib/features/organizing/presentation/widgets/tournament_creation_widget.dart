import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/organizing/application/providers/organizer_providers.dart';
import 'package:toriverse/features/organizing/domain/models/organizer.dart';

/// Multi-step tournament creation form
///
/// Guides organizers through creating a new tournament with:
/// - Basic info (name, description, format)
/// - Configuration (dates, participant limits)
/// - Prize pool setup
/// - Rules and settings
class TournamentCreationWidget extends ConsumerStatefulWidget {
  final String organizerId;
  final VoidCallback? onTournamentCreated;

  const TournamentCreationWidget({
    required this.organizerId,
    this.onTournamentCreated,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<TournamentCreationWidget> createState() =>
      _TournamentCreationWidgetState();
}

class _TournamentCreationWidgetState extends ConsumerState<TournamentCreationWidget> {
  int _currentStep = 0;
  late PageController _pageController;

  // Form data
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _prizePoolController;
  String _selectedFormat = 'single_elimination';
  int _maxParticipants = 64;
  Map<int, int> _prizeDistribution = {
    1: 300000,
    2: 150000,
    3: 50000,
  };
  List<String> _rules = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _prizePoolController = TextEditingController(text: '500000');
    _pageController = PageController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _prizePoolController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Tournament'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Step indicator
          _buildStepIndicator(),
          // Step content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentStep = index);
              },
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBasicInfoStep(),
                _buildConfigurationStep(),
                _buildPrizePoolStep(),
                _buildReviewStep(),
              ],
            ),
          ),
          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? Colors.blue : Colors.grey[300],
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getStepTitle(index),
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _getStepTitle(int index) {
    switch (index) {
      case 0:
        return 'Basic Info';
      case 1:
        return 'Setup';
      case 2:
        return 'Prizes';
      case 3:
        return 'Review';
      default:
        return '';
    }
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tournament Name',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'e.g., Summer Championship 2026',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Description',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: 'Tournament details and theme',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          const Text(
            'Tournament Format',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildFormatSelector(),
        ],
      ),
    );
  }

  Widget _buildFormatSelector() {
    final formats = [
      ('single_elimination', 'Single Elimination', '64 players max'),
      ('double_elimination', 'Double Elimination', '32 players max'),
      ('round_robin', 'Round Robin', '16 players max'),
      ('swiss', 'Swiss System', '128 players max'),
      ('ladder', 'Ladder', '1000+ players'),
    ];

    return Column(
      children: formats.map((format) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            child: ListTile(
              title: Text(format.$2),
              subtitle: Text(format.$3),
              trailing: Radio<String>(
                value: format.$1,
                groupValue: _selectedFormat,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedFormat = value);
                  }
                },
              ),
              onTap: () {
                setState(() => _selectedFormat = format.$1);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: _selectedFormat == format.$1 ? Colors.blue : Colors.grey[300]!,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConfigurationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Maximum Participants',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _maxParticipants.toDouble(),
            min: 3,
            max: 128,
            divisions: 50,
            label: '$_maxParticipants',
            onChanged: (value) {
              setState(() => _maxParticipants = value.toInt());
            },
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$_maxParticipants player${_maxParticipants != 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tournament Rules',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildRulesInput(),
          if (_rules.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _rules
                  .map(
                    (rule) => Chip(
                      label: Text(rule),
                      onDeleted: () {
                        setState(() => _rules.remove(rule));
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRulesInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Add a rule...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                setState(() => _rules.add(value));
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            // Handle rule addition
          },
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _buildPrizePoolStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Prize Pool (JPY)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _prizePoolController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefix: const Text('¥'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              _updatePrizeDistribution();
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Prize Distribution',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildPrizeDistributionTable(),
        ],
      ),
    );
  }

  Widget _buildPrizeDistributionTable() {
    return Column(
      children: _prizeDistribution.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.key == 1 ? '🥇 1st Place' : entry.key == 2 ? '🥈 2nd Place' : '🥉 3rd Place',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '¥${entry.value}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _updatePrizeDistribution() {
    final total = int.tryParse(_prizePoolController.text) ?? 0;
    setState(() {
      _prizeDistribution = {
        1: (total * 0.6).toInt(),
        2: (total * 0.3).toInt(),
        3: (total * 0.1).toInt(),
      };
    });
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Tournament Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _reviewItem('Name', _nameController.text),
          _reviewItem('Description', _descriptionController.text),
          _reviewItem('Format', _selectedFormat),
          _reviewItem('Max Participants', '$_maxParticipants'),
          _reviewItem(
            'Prize Pool',
            '¥${int.tryParse(_prizePoolController.text) ?? 0}',
          ),
          if (_rules.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Rules',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            ..._rules
                .map((rule) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('• $rule'),
                ))
                .toList(),
          ],
        ],
      ),
    );
  }

  Widget _reviewItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            ElevatedButton(
              onPressed: _previousStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
              ),
              child: const Text('Previous'),
            )
          else
            const SizedBox(width: 100),
          if (_currentStep < 3)
            ElevatedButton(
              onPressed: _validateAndNextStep,
              child: const Text('Next'),
            )
          else
            ElevatedButton(
              onPressed: _createTournament,
              child: const Text('Create'),
            ),
        ],
      ),
    );
  }

  void _previousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _validateAndNextStep() {
    if (_currentStep == 0 && _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter tournament name')),
      );
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _createTournament() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter tournament name')),
      );
      return;
    }

    final prizeAmount = int.tryParse(_prizePoolController.text) ?? 0;
    if (prizeAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid prize pool amount')),
      );
      return;
    }

    final prizePool = PrizePoolConfig(
      totalAmount: prizeAmount,
      distribution: _prizeDistribution,
      currency: 'JPY',
    );

    try {
      await ref.read(createTournamentProvider(_CreateTournamentParams(
        organizerId: widget.organizerId,
        name: _nameController.text,
        description: _descriptionController.text,
        format: _selectedFormat,
        maxParticipants: _maxParticipants,
        prizePool: prizePool,
      )).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tournament created successfully')),
        );
        widget.onTournamentCreated?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating tournament: $e')),
        );
      }
    }
  }
}
