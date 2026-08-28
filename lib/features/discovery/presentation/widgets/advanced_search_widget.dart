import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/discovery_providers.dart';
import '../../domain/models/discovery.dart';

class AdvancedSearchWidget extends ConsumerStatefulWidget {
  final Function(List<SearchResult> results)? onResultsFound;

  const AdvancedSearchWidget({
    Key? key,
    this.onResultsFound,
  }) : super(key: key);

  @override
  ConsumerState<AdvancedSearchWidget> createState() =>
      _AdvancedSearchWidgetState();
}

class _AdvancedSearchWidgetState extends ConsumerState<AdvancedSearchWidget> {
  late TextEditingController _searchController;
  SearchType _selectedType = SearchType.creator;
  String? _selectedSkillLevel;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    final filters = <String, dynamic>{
      if (_selectedSkillLevel != null) 'skillLevel': _selectedSkillLevel,
      if (_selectedDateRange != null) 'dateRange': _selectedDateRange,
    };

    // Perform search using provider
    ref.read(searchResultsProvider(SearchParam(
      query: query,
      searchType: _selectedType,
      filters: filters,
      limit: 50,
    )).future).then((results) {
      widget.onResultsFound?.call(results);
    });
  }

  @override
  Widget build(BuildContext context) {
    final suggestionsAsync = ref.watch(
      searchSuggestionsProvider(_searchController.text),
    );

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search creators, clips, matches...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _searchController.clear()),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) => setState(() {}),
            onSubmitted: (value) => _performSearch(),
          ),
        ),
        // Search type tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: SearchType.values.map((type) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_getTypeLabel(type)),
                    selected: _selectedType == type,
                    onSelected: (selected) {
                      setState(() => _selectedType = type);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Filter options
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedSkillLevel,
                  hint: const Text('Skill Level'),
                  items: ['Beginner', 'Intermediate', 'Advanced']
                      .map((level) => DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedSkillLevel = value),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  setState(() => _selectedDateRange = range);
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(_selectedDateRange != null ? 'Date Range Set' : 'Date'),
              ),
            ],
          ),
        ),
        // Search suggestions
        if (suggestionsAsync.hasValue && suggestionsAsync.value!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Searches',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: suggestionsAsync.value!
                      .map((suggestion) => ActionChip(
                            label: Text(suggestion),
                            onPressed: () {
                              _searchController.text = suggestion;
                              _performSearch();
                            },
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        // Search button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _performSearch,
            icon: const Icon(Icons.search),
            label: const Text('Search'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
      ],
    );
  }

  String _getTypeLabel(SearchType type) {
    switch (type) {
      case SearchType.creator:
        return 'Creators';
      case SearchType.clip:
        return 'Clips';
      case SearchType.match:
        return 'Matches';
      case SearchType.clan:
        return 'Clans';
    }
  }
}
