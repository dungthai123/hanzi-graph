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
  bool _showSearchControls = false;

  // Responsive breakpoint
  static const double mobileBreakpoint = 664.0;

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

  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= mobileBreakpoint;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobile(context);

    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        // Update controller if selected character changes externally
        if (searchProvider.selectedCharacter.isNotEmpty && _controller.text != searchProvider.selectedCharacter) {
          _controller.text = searchProvider.selectedCharacter;
        }

        return Column(
          children: [
            // Search input field with controls
            _buildSearchInput(isMobile, searchProvider),

            // Search suggestions dropdown
            if (_showSuggestions) _buildSuggestions(isMobile, searchProvider),

            // Search controls (photo/file upload)
            if (_showSearchControls) _buildSearchControls(isMobile),
          ],
        );
      },
    );
  }

  Widget _buildSearchInput(bool isMobile, SearchProvider searchProvider) {
    return Container(
      height: 32, // --search-input-height from CSS
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // --input-background-color
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1AEEEEEE), // --primary-input-box-shadow
            blurRadius: 3,
            offset: Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(color: const Color(0x33333333)),
      ),
      child: Row(
        children: [
          // Search icon (explore button equivalent)
          Container(
            width: 32,
            height: 32,
            padding: const EdgeInsets.all(6),
            child: Icon(Icons.search, size: isMobile ? 16 : 20, color: const Color(0xFF777777)),
          ),

          // Search input field
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: TextStyle(
                fontSize: isMobile ? 16 : 20, // --search-font-size adapted for mobile
                fontWeight: FontWeight.w300,
              ),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: const Color(0xFF999999), fontSize: isMobile ? 16 : 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: isMobile ? 6 : 8),
              ),
              textInputAction: TextInputAction.search,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: (value) {
                setState(() {
                  _showSuggestions = value.isNotEmpty && _focusNode.hasFocus;
                });
                searchProvider.updateQuery(value);
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _performSearch(value, searchProvider);
                }
              },
              onTap: () {
                if (!isMobile) {
                  setState(() {
                    _showSearchControls = !_showSearchControls;
                  });
                }
              },
            ),
          ),

          // Additional controls button (mobile only)
          if (isMobile)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showSearchControls = !_showSearchControls;
                });
              },
              child: Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(6),
                child: Icon(
                  _showSearchControls ? Icons.keyboard_arrow_up : Icons.more_vert,
                  size: 16,
                  color: const Color(0xFF777777),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(bool isMobile, SearchProvider searchProvider) {
    // Get suggestions from searchProvider
    final suggestions = searchProvider.suggestions;

    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      constraints: BoxConstraints(maxHeight: isMobile ? 200 : 300),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ListTile(
            dense: isMobile,
            title: Text(suggestion, style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.w400)),
            onTap: () {
              _controller.text = suggestion;
              _performSearch(suggestion, searchProvider);
              setState(() {
                _showSuggestions = false;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchControls(bool isMobile) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _showSearchControls ? (isMobile ? 60 : 50) : 0,
      child:
          _showSearchControls
              ? Container(
                margin: const EdgeInsets.only(top: 8),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 10 : 14, // --controls-padding adapted
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0x33333333)),
                ),
                child: Row(
                  children: [
                    // Photo search button
                    Expanded(
                      child: _buildSearchControlButton(
                        icon: Icons.camera_alt,
                        label: 'Photo',
                        isMobile: isMobile,
                        onTap: () => _handlePhotoSearch(),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // File search button
                    Expanded(
                      child: _buildSearchControlButton(
                        icon: Icons.file_upload,
                        label: 'File',
                        isMobile: isMobile,
                        onTap: () => _handleFileSearch(),
                      ),
                    ),
                  ],
                ),
              )
              : const SizedBox.shrink(),
    );
  }

  Widget _buildSearchControlButton({
    required IconData icon,
    required String label,
    required bool isMobile,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: isMobile ? 6 : 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0x33333333)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isMobile ? 16 : 18, color: const Color(0xFF555555)),
            SizedBox(width: isMobile ? 4 : 6),
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF555555),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _performSearch(String query, SearchProvider searchProvider) {
    _focusNode.unfocus();
    setState(() {
      _showSuggestions = false;
      _showSearchControls = false;
    });

    // Trigger search in provider
    searchProvider.selectCharacter(query);

    // Update graph provider
    final graphProvider = Provider.of<GraphProvider>(context, listen: false);
    graphProvider.generateGraph(query);

    print('🔍 SearchBar: Searching for "$query"');
  }

  void _handlePhotoSearch() {
    // TODO: Implement photo search functionality
    print('📸 Photo search requested');
    setState(() {
      _showSearchControls = false;
    });
  }

  void _handleFileSearch() {
    // TODO: Implement file search functionality
    print('📁 File search requested');
    setState(() {
      _showSearchControls = false;
    });
  }
}
