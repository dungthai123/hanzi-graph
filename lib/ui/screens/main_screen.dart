import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_initializer.dart';
import '../../providers/search_provider.dart';
import '../../providers/graph_provider.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/graph_widget.dart';
import '../widgets/examples_widget.dart';
import '../widgets/menu_widget.dart';
import '../widgets/faq_widget.dart';
import '../widgets/character_exploration_widget.dart';

/// Main screen widget - equivalent to main HTML structure
class MainScreen extends StatefulWidget {
  final AppInitializer appInitializer;

  const MainScreen({super.key, required this.appInitializer});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isGraphExpanded = false;
  late AnimationController _graphExpandController;
  late Animation<double> _graphExpandAnimation;

  // Responsive breakpoints following HTML/CSS patterns
  static const double mobileBreakpoint = 664.0;
  static const double tabletBreakpoint = 1024.0;

  @override
  void initState() {
    super.initState();
    _graphExpandController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _graphExpandAnimation = CurvedAnimation(parent: _graphExpandController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _graphExpandController.dispose();
    super.dispose();
  }

  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= mobileBreakpoint;
  }

  bool _isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > mobileBreakpoint && width <= tabletBreakpoint;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC), // --background-color
      body: SafeArea(
        child: Column(
          children: [
            // Header with search
            _buildHeader(isMobile),

            // Main content area
            Expanded(
              child: Consumer2<SearchProvider, GraphProvider>(
                builder: (context, searchProvider, graphProvider, child) {
                  final selectedCharacter = searchProvider.selectedCharacter;

                  // Debug logging
                  if (selectedCharacter.isNotEmpty) {
                    print('🖥️ MainScreen: Character selected: "$selectedCharacter"');
                  }

                  // Show character exploration when a character is selected
                  if (selectedCharacter.isNotEmpty) {
                    return _buildMainContentWithExploration(selectedCharacter, isMobile);
                  }

                  // Default view without character selected
                  return _buildDefaultContent(isMobile);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isMobile ? _buildBottomNavigation() : null,
      floatingActionButton: isMobile && !_isGraphExpanded ? _buildGraphExpandFab() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      height: 50, // --primary-header-height
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F8F8), // --header-background-color
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Left menu button
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(8)),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.menu, color: Colors.white, size: 20),
              onPressed: () => _showMenu(context),
            ),
          ),

          const SizedBox(width: 12),

          // Logo and title
          Container(
            padding: const EdgeInsets.all(4),
            child: Text(
              '汉', // Chinese logo like HTML
              style: TextStyle(
                fontSize: isMobile ? 26 : 30, // Responsive font size
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
              ),
            ),
          ),

          if (!isMobile) ...[
            const SizedBox(width: 8),
            Text('HanziGraph', style: TextStyle(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold)),
          ],

          const SizedBox(width: 16),

          // Search bar - takes remaining space
          const Expanded(child: SearchBarWidget()),

          const SizedBox(width: 12),

          // Right menu button (study button)
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF6DE200), // --positive-button-color
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.school, color: Colors.white, size: 20),
              onPressed: () {
                // Handle study mode
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build main content with character exploration (responsive layout)
  Widget _buildMainContentWithExploration(String selectedCharacter, bool isMobile) {
    if (isMobile) {
      return _buildMobileExplorationLayout(selectedCharacter);
    } else {
      return _buildDesktopExplorationLayout(selectedCharacter);
    }
  }

  Widget _buildMobileExplorationLayout(String selectedCharacter) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use LayoutBuilder to get accurate available space
        final availableHeight = constraints.maxHeight;

        return Column(
          children: [
            // Text container (character exploration)
            AnimatedBuilder(
              animation: _graphExpandAnimation,
              builder: (context, child) {
                final textHeight = _isGraphExpanded ? 0.0 : (availableHeight * 0.5) - 4; // 50% minus small margin

                return Container(
                  height: textHeight.clamp(0.0, double.infinity),
                  width: double.infinity,
                  margin: const EdgeInsets.all(8),
                  child:
                      textHeight > 0
                          ? ClipRect(
                            child: SizedBox(
                              height: textHeight,
                              child: CharacterExplorationWidget(character: selectedCharacter),
                            ),
                          )
                          : const SizedBox.shrink(),
                );
              },
            ),

            // Divider with resize indicator
            if (!_isGraphExpanded) _buildMobileDivider(),

            // Graph container
            AnimatedBuilder(
              animation: _graphExpandAnimation,
              builder: (context, child) {
                final graphHeight =
                    _isGraphExpanded
                        ? availableHeight -
                            16 // Full height minus small padding
                        : (availableHeight * 0.5) - 50; // 50% minus divider space

                return Container(
                  height: graphHeight.clamp(0.0, double.infinity),
                  width: double.infinity,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: _isGraphExpanded ? null : const Border(top: BorderSide(color: Color(0x33333333))),
                  ),
                  child: Stack(
                    children: [ClipRect(child: const GraphWidget()), if (_isGraphExpanded) _buildCollapseButton()],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDesktopExplorationLayout(String selectedCharacter) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1300), // max-width from CSS
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Left side: Graph visualization
          Expanded(flex: 1, child: Container(margin: const EdgeInsets.all(16), child: const GraphWidget())),

          // Right side: Character exploration
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(16),
              child: CharacterExplorationWidget(character: selectedCharacter),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDivider() {
    return GestureDetector(
      onTap: () {
        // Allow tapping divider to toggle graph expansion
        _toggleGraphExpansion();
      },
      child: Container(
        height: 20,
        width: double.infinity,
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(width: 8),
            Icon(Icons.drag_handle, size: 16, color: Colors.black.withOpacity(0.3)),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(4)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapseButton() {
    return Positioned(
      top: 8,
      left: 8,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFCFCFC),
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: InkWell(
            onTap: _toggleGraphExpansion,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 36,
              height: 36,
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey[700]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGraphExpandFab() {
    return AnimatedOpacity(
      opacity: _isGraphExpanded ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: FloatingActionButton.small(
        onPressed: _isGraphExpanded ? null : _toggleGraphExpansion,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
        heroTag: "graph_expand_fab",
        tooltip: "Expand graph view",
        child: const Icon(Icons.keyboard_arrow_up, size: 20),
      ),
    );
  }

  void _toggleGraphExpansion() {
    setState(() {
      _isGraphExpanded = !_isGraphExpanded;
    });

    if (_isGraphExpanded) {
      _graphExpandController.forward();
    } else {
      _graphExpandController.reverse();
    }

    // Provide haptic feedback
    try {
      // Optional: Add haptic feedback if available
      // HapticFeedback.lightImpact();
    } catch (e) {
      // Ignore if haptic feedback is not available
    }
  }

  /// Build default content when no character is selected (responsive)
  Widget _buildDefaultContent(bool isMobile) {
    if (isMobile) {
      return _buildMobileDefaultContent();
    } else {
      return _buildDesktopDefaultContent();
    }
  }

  Widget _buildMobileDefaultContent() {
    switch (_selectedIndex) {
      case 0: // Main/Graph view
        return LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;

            return Column(
              children: [
                // Graph takes 50% on mobile
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(8),
                  child: ClipRect(child: const GraphWidget()),
                ),

                _buildMobileDivider(),

                // Examples take remaining 50%
                Container(
                  height: (availableHeight * 0.5) - 20, // 50% minus divider space
                  width: double.infinity,
                  margin: const EdgeInsets.all(8),
                  child: ClipRect(child: const ExamplesWidget()),
                ),
              ],
            );
          },
        );
      case 1: // Search/Examples view
        return Container(margin: const EdgeInsets.all(8), child: const ExamplesWidget());
      case 2: // FAQ view
        return Container(margin: const EdgeInsets.all(8), child: const FaqWidget());
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDesktopDefaultContent() {
    switch (_selectedIndex) {
      case 0: // Main/Graph view
        return Container(
          constraints: const BoxConstraints(maxWidth: 1300),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Graph takes most of the space
              const Expanded(flex: 2, child: GraphWidget()),

              const SizedBox(height: 16),

              // Examples below
              const Expanded(flex: 1, child: ExamplesWidget()),
            ],
          ),
        );
      case 1: // Search/Examples view
        return Container(margin: const EdgeInsets.all(16), child: const ExamplesWidget());
      case 2: // FAQ view
        return Container(margin: const EdgeInsets.all(16), child: const FaqWidget());
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFFF8F8F8),
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: const Color(0xFF777777),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.account_tree), label: 'Graph'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.help), label: 'FAQ'),
      ],
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Color(0xFFF7F7F7), // --popover-background-color
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const MenuWidget(),
          ),
    );
  }
}
