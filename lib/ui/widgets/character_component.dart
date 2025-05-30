import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../providers/graph_provider.dart';
import '../../models/component_data.dart';
import 'component_tree_widget.dart';

/// Widget for displaying character component relationships
/// Equivalent to the components functionality in components-demo.js
/// Transpiled from renderComponents, renderCharacterHeader, and related functions
class CharacterComponentWidget extends StatelessWidget {
  final String character;
  final VoidCallback? onCharacterTap;
  final bool showComponentTree;

  const CharacterComponentWidget({
    super.key,
    required this.character,
    this.onCharacterTap,
    this.showComponentTree = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final componentData = dataProvider.getComponent(character);

        if (componentData == null) {
          return _buildNoDataState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions (like JavaScript renderComponents first character)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Click any character for more information.',
                      style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Main character display
            _buildCharacterHeader(context, componentData),

            const SizedBox(height: 24),

            // Component Tree Visualization (equivalent to JavaScript buildComponentTree)
            if (showComponentTree) ...[_buildComponentTreeSection(context), const SizedBox(height: 24)],

            // Components section (equivalent to JavaScript renderComponents components section)
            _buildComponentsSection(context, componentData),

            const SizedBox(height: 24),

            // Compounds section (equivalent to JavaScript renderComponents compounds section)
            _buildCompoundsSection(context, componentData),
          ],
        );
      },
    );
  }

  /// Component Tree Visualization Section
  /// Equivalent to JavaScript buildComponentTree integration
  Widget _buildComponentTreeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.account_tree, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Component Tree Visualization', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Interactive breakdown showing how this character is composed. Click nodes to explore.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),

        // Component Tree Widget (equivalent to JavaScript cytoscape container)
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ComponentTreeWidget(
            initialCharacter: character,
            onCharacterTap: (tappedCharacter) {
              // Update the character exploration when tree node is tapped
              // Equivalent to JavaScript cy.on('tap', 'node') handler
              onCharacterTap?.call();

              // Also trigger a new exploration for the tapped character
              final graphProvider = context.read<GraphProvider>();
              graphProvider.generateComponentsTree(tappedCharacter);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoDataState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'No component data available for: $character',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'This character may not be in our component database.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Character header - equivalent to JavaScript renderCharacterHeader
  Widget _buildCharacterHeader(BuildContext context, ComponentData componentData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
            Theme.of(context).primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Large character display (equivalent to JavaScript characterSpan)
          GestureDetector(
            onTap: () {
              // Equivalent to JavaScript characterSpan.addEventListener('click')
              final graphProvider = context.read<GraphProvider>();
              graphProvider.generateComponentsTree(character);
              onCharacterTap?.call();
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getCharacterColor(character),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Consumer<DataProvider>(
                builder: (context, dataProvider, child) {
                  return Text(
                    character,
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w400,
                      color: _getTextColor(_getCharacterColor(character)),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 24),

          // Character information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Character title (like JavaScript characterHolder h2)
                Text(character, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),

                // Pinyin and definition
                Consumer<DataProvider>(
                  builder: (context, dataProvider, child) {
                    final definition = dataProvider.getDefinition(character);
                    if (definition != null && definition.pinyin.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pinyin with tone coloring (like JavaScript renderDefinitions)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getToneColor(definition.pinyin).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              definition.pinyin,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: _getToneColor(definition.pinyin),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            definition.english.isNotEmpty ? definition.english.first : 'No definition available',
                            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                          ),
                        ],
                      );
                    }
                    return Text(
                      'Click to explore relationships',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Component stats
                Row(
                  children: [
                    _buildStatChip('Components: ${componentData.components.length}', Colors.blue),
                    const SizedBox(width: 12),
                    _buildStatChip('Used in: ${componentData.componentOf.length}', Colors.green),
                  ],
                ),

                const SizedBox(height: 12),

                // Type indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: componentData.type == 's' ? Colors.orange[100] : Colors.purple[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    componentData.type == 's' ? 'Simplified' : 'Traditional',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: componentData.type == 's' ? Colors.orange[800] : Colors.purple[800],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Action button for component tree
                ElevatedButton.icon(
                  onPressed: () {
                    final graphProvider = context.read<GraphProvider>();
                    graphProvider.generateComponentsTree(character);
                  },
                  icon: const Icon(Icons.account_tree, size: 16),
                  label: const Text('View Component Tree'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
    );
  }

  /// Components section - equivalent to JavaScript renderComponents components section
  Widget _buildComponentsSection(BuildContext context, ComponentData componentData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.construction, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Components (Sub-parts)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),

        if (componentData.hasComponents) ...[
          const Text(
            'This character is made up of these components:',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          _buildNavigableCharacterGrid(context, componentData.components),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.grey[600]),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "No components found. Maybe we can't break this down any more.",
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Compounds section - equivalent to JavaScript renderComponents compounds section
  Widget _buildCompoundsSection(BuildContext context, ComponentData componentData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.extension, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text(
              'Compounds (Characters using this component)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (componentData.isComponentOfOthers) ...[
          const Text('This character is used as a component in:', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 12),
          _buildNavigableCharacterGrid(context, componentData.componentOf.take(20).toList()), // Limit display

          if (componentData.componentOf.length > 20) ...[
            const SizedBox(height: 12),
            Text(
              'And ${componentData.componentOf.length - 20} more...',
              style: TextStyle(fontSize: 14, color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
          ],
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.grey[600]),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'This character is not used as a component in other characters.',
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Navigable character grid - equivalent to JavaScript makeSentenceNavigable
  Widget _buildNavigableCharacterGrid(BuildContext context, List<String> characters) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: characters.map((char) => _buildNavigableCharacterChip(context, char)).toList(),
    );
  }

  /// Navigable character chip - equivalent to JavaScript navigable character elements
  Widget _buildNavigableCharacterChip(BuildContext context, String char) {
    return GestureDetector(
      onTap: () {
        // Equivalent to JavaScript a.addEventListener('click') in makeSentenceNavigable
        final graphProvider = context.read<GraphProvider>();
        graphProvider.generateComponentsTree(char);
        onCharacterTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Character with tone coloring
            Consumer<DataProvider>(
              builder: (context, dataProvider, child) {
                final definition = dataProvider.getDefinition(char);
                final toneColor = definition != null ? _getToneColor(definition.pinyin) : Colors.grey[700]!;

                return Text(char, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: toneColor));
              },
            ),
            const SizedBox(height: 4),
            // Pinyin
            Consumer<DataProvider>(
              builder: (context, dataProvider, child) {
                final definition = dataProvider.getDefinition(char);
                final pinyin = definition?.pinyin ?? '';
                return Text(pinyin.isNotEmpty ? pinyin : '?', style: TextStyle(fontSize: 10, color: Colors.grey[600]));
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Get character color - equivalent to JavaScript toneColor function
  Color _getCharacterColor(String character) {
    // Simple hash-based coloring for fallback
    final hash = character.codeUnitAt(0) % 5;
    switch (hash) {
      case 0:
        return const Color(0xFFff635f); // Red-ish
      case 1:
        return const Color(0xFF7aeb34); // Green-ish
      case 2:
        return const Color(0xFFde68ee); // Purple-ish
      case 3:
        return const Color(0xFF68aaee); // Blue-ish
      default:
        return Colors.grey[700]!; // Neutral
    }
  }

  /// Get tone color from pinyin - equivalent to JavaScript toneColor function
  Color _getToneColor(String pinyin) {
    if (pinyin.isEmpty) return Colors.grey[700]!;

    final lastChar = pinyin[pinyin.length - 1];
    switch (lastChar) {
      case '1':
        return const Color(0xFFff635f); // Red
      case '2':
        return const Color(0xFF7aeb34); // Green
      case '3':
        return const Color(0xFFde68ee); // Purple
      case '4':
        return const Color(0xFF68aaee); // Blue
      default:
        return Colors.grey[700]!; // Neutral tone
    }
  }

  Color _getTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
