import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/search_provider.dart';
import '../../providers/graph_provider.dart';

/// Search bar widget - equivalent to search functionality in the JavaScript app
class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _showSuggestions = _focusNode.hasFocus && _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        // Update controller if selected character changes externally
        if (searchProvider.selectedCharacter.isNotEmpty && _controller.text != searchProvider.selectedCharacter) {
          _controller.text = searchProvider.selectedCharacter;
        }

        return Column(
          children: [
            // Search input field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Search for Chinese characters...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  suffixIcon:
                      _controller.text.isNotEmpty
                          ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[600]),
                            onPressed: () {
                              _controller.clear();
                              searchProvider.clearSearch();
                              setState(() {
                                _showSuggestions = false;
                              });
                            },
                          )
                          : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                style: const TextStyle(fontSize: 18),
                onChanged: (value) {
                  searchProvider.updateQuery(value);
                  setState(() {
                    _showSuggestions = value.isNotEmpty && _focusNode.hasFocus;
                  });
                },
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _handleSearch(value);
                  }
                },
              ),
            ),

            // Search suggestions dropdown
            if (_showSuggestions && searchProvider.suggestions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: searchProvider.suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = searchProvider.suggestions[index];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(suggestion, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                        ),
                      ),
                      title: Text(suggestion, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      subtitle: Text(
                        'Tap to explore character',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      onTap: () {
                        _selectCharacter(suggestion);
                      },
                    );
                  },
                ),
              ),
            ],

            // Loading indicator
            if (searchProvider.isSearching) ...[
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 12),
                  Text('Searching...'),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  void _handleSearch(String query) {
    final searchProvider = context.read<SearchProvider>();
    final graphProvider = context.read<GraphProvider>();

    if (query.length == 1) {
      // Single character - select for exploration
      _selectCharacter(query);
    } else {
      // Multi-character query - perform search
      searchProvider.search(query);
    }

    // Hide suggestions and unfocus
    setState(() {
      _showSuggestions = false;
    });
    _focusNode.unfocus();
  }

  void _selectCharacter(String character) {
    final searchProvider = context.read<SearchProvider>();
    final graphProvider = context.read<GraphProvider>();

    print('🔍 Search: Selecting character "$character"');

    // Update the text field
    _controller.text = character;

    // Select character for exploration (equivalent to JavaScript character selection)
    searchProvider.selectCharacter(character);
    print('🔍 Search: Selected character set to "${searchProvider.selectedCharacter}"');

    // Generate graph for the character
    graphProvider.generateGraph(character);
    print('🔍 Search: Graph generation triggered for "$character"');

    // Hide suggestions and unfocus
    setState(() {
      _showSuggestions = false;
    });
    _focusNode.unfocus();
  }
}
