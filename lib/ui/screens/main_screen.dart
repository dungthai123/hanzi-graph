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

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header with search
            _buildHeader(),

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
                    return _buildMainContentWithExploration(selectedCharacter);
                  }

                  // Default view without character selected
                  return _buildDefaultContent();
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // App title and logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_tree, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text('HanziGraph', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.menu), onPressed: () => _showMenu(context)),
            ],
          ),

          const SizedBox(height: 16),

          // Search bar
          const SearchBarWidget(),
        ],
      ),
    );
  }

  /// Build main content with character exploration (equivalent to JavaScript layout)
  Widget _buildMainContentWithExploration(String selectedCharacter) {
    return Row(
      children: [
        // Left side: Graph visualization
        Expanded(flex: 1, child: Container(margin: const EdgeInsets.all(16), child: const GraphWidget())),

        // Right side: Character exploration (equivalent to explore.js content)
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(16),
            child: CharacterExplorationWidget(character: selectedCharacter),
          ),
        ),
      ],
    );
  }

  /// Build default content when no character is selected
  Widget _buildDefaultContent() {
    switch (_selectedIndex) {
      case 0: // Main/Graph view
        return Container(
          margin: const EdgeInsets.all(16),
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
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.account_tree), label: 'Graph'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.help), label: 'FAQ'),
      ],
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(context: context, builder: (context) => const MenuWidget());
  }
}
