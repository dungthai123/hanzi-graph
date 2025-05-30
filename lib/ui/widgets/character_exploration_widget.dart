import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/graph_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/definition_data.dart';
import '../../models/sentence_data.dart';
import 'character_component.dart';

/// Character exploration widget - equivalent to explore.js functionality
/// Provides tabbed interface for character details: Meaning, Components, Stats, Flow
class CharacterExplorationWidget extends StatefulWidget {
  final String character;

  const CharacterExplorationWidget({super.key, required this.character});

  @override
  State<CharacterExplorationWidget> createState() => _CharacterExplorationWidgetState();
}

class _CharacterExplorationWidgetState extends State<CharacterExplorationWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _onTabChanged(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    try {
      final graphProvider = context.read<GraphProvider>();

      switch (index) {
        case 0: // Meaning
          // No special action needed
          break;
        case 1: // Components
          graphProvider.generateComponentsTree(widget.character);
          break;
        case 2: // Stats
          // Stats will be calculated in the tab content
          break;
        case 3: // Flow
          // Flow will be handled in the tab content
          break;
      }
    } catch (e) {
      debugPrint('Error switching tab: $e');
      // Don't crash, just log the error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.character.isEmpty) {
      return _buildEmptyState();
    }

    debugPrint('🔍 CharacterExploration: Building for character "${widget.character}"');

    try {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Character header
            _buildCharacterHeader(),

            // Tab bar
            _buildTabBar(),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _MeaningTab(character: widget.character),
                  _ComponentsTab(character: widget.character),
                  _StatsTab(character: widget.character),
                  _FlowTab(character: widget.character),
                ],
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error building CharacterExplorationWidget: $e');
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading character: ${widget.character}',
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
              const SizedBox(height: 8),
              Text('Error: ${e.toString()}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.translate, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),

          // Walkthrough instructions like JavaScript components page
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Text(
                  'Select a character to explore',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),
                Text(
                  'To get started, search for any character.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'The diagram shows the components of each character, the components of its components, and so on.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'The diagram is color-coded by tone. When a component has similar pronunciation with its parent, a label with pinyin (initial, final, or both) is shown.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          // Large character display with tone coloring
          GestureDetector(
            onTap: () {
              final graphProvider = context.read<GraphProvider>();
              graphProvider.generateGraph(widget.character);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getCharacterColor(widget.character),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
              ),
              child: Text(
                widget.character,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w400,
                  color: _getTextColor(_getCharacterColor(widget.character)),
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          // Character info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Character: ${widget.character}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Consumer<DataProvider>(
                  builder: (context, dataProvider, child) {
                    try {
                      final definition = dataProvider.getDefinition(widget.character);
                      if (definition != null && definition.english.isNotEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              definition.pinyin.isNotEmpty ? definition.pinyin : 'No pinyin available',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: _getCharacterColor(widget.character),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(definition.english.first, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                          ],
                        );
                      }
                      return Text(
                        'Click to explore relationships',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      );
                    } catch (e) {
                      debugPrint('Error in character header: $e');
                      return Text(
                        'Character data unavailable',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Theme.of(context).primaryColor,
        indicatorWeight: 3,
        tabs: const [Tab(text: 'Meaning'), Tab(text: 'Components'), Tab(text: 'Stats'), Tab(text: 'Flow')],
      ),
    );
  }

  Color _getCharacterColor(String character) {
    // Simple tone-based coloring (placeholder)
    final hash = character.codeUnitAt(0) % 5;
    switch (hash) {
      case 0:
        return const Color(0xFFff635f); // Tone 1
      case 1:
        return const Color(0xFF7aeb34); // Tone 2
      case 2:
        return const Color(0xFFde68ee); // Tone 3
      case 3:
        return const Color(0xFF68aaee); // Tone 4
      default:
        return Colors.grey[700]!; // Neutral tone
    }
  }

  Color _getTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}

/// Meaning tab - equivalent to meaning section in explore.js
class _MeaningTab extends StatelessWidget {
  final String character;

  const _MeaningTab({required this.character});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          try {
            final definition = dataProvider.getDefinition(character);
            final sentences = dataProvider.getSentences(character);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Definitions section
                _buildDefinitionsSection(definition),

                const SizedBox(height: 24),

                // Examples section
                _buildExamplesSection(sentences),
              ],
            );
          } catch (e) {
            debugPrint('Error in MeaningTab: $e');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading meaning data for: $character',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  Text('Error: ${e.toString()}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDefinitionsSection(DefinitionData? definition) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Definitions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        if (definition != null && definition.english.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pinyin
                Text(
                  definition.pinyin.isNotEmpty ? definition.pinyin : 'No pinyin available',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF1976D2)),
                ),
                const SizedBox(height: 8),

                // English definitions
                ...definition.english.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${entry.key + 1}.', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(entry.value, style: const TextStyle(fontSize: 16))),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: Text(
              definition == null ? 'No definition found for this character.' : 'Definition data incomplete.',
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExamplesSection(List<SentenceData> sentences) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Example Sentences', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        if (sentences.isNotEmpty) ...[
          ...sentences.take(5).map((sentence) => _buildExampleItem(sentence)),

          if (sentences.length > 5) ...[
            const SizedBox(height: 8),
            Text(
              'And ${sentences.length - 5} more examples...',
              style: TextStyle(fontSize: 14, color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
          ],
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: const Text(
              'No example sentences found.',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExampleItem(SentenceData sentence) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chinese text with character highlighting
          _buildNavigableSentence(sentence.chinese),

          const SizedBox(height: 8),

          // Pinyin if available
          if (sentence.pinyin.isNotEmpty) ...[
            Text(sentence.pinyin, style: TextStyle(fontSize: 14, color: Colors.grey[600], fontStyle: FontStyle.italic)),
            const SizedBox(height: 4),
          ],

          // English translation
          Text(sentence.english, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildNavigableSentence(String chinese) {
    return Wrap(
      children:
          chinese.split('').map((char) {
            return GestureDetector(
              onTap: () {
                // TODO: Navigate to character
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Text(
                  char,
                  style: TextStyle(
                    fontSize: 18,
                    color: char == character ? Colors.red : Colors.black,
                    fontWeight: char == character ? FontWeight.bold : FontWeight.normal,
                    decoration: char == character ? TextDecoration.underline : null,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}

/// Components tab - equivalent to components section in explore.js
class _ComponentsTab extends StatelessWidget {
  final String character;

  const _ComponentsTab({required this.character});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instructions (like JavaScript explore.js explanation)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: const Text(
              'Click any character in the diagram above to update the tree.',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ),

          const SizedBox(height: 16),

          // Character component details (like JavaScript renderComponents)
          _buildComponentDetails(context),
        ],
      ),
    );
  }

  Widget _buildComponentDetails(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        try {
          final componentsData = dataProvider.getAllComponentsData();
          final characterData = componentsData[character];

          if (characterData == null) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: Text(
                'No component data found for "$character"',
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Character header (like JavaScript renderCharacterHeader)
              _buildCharacterHeader(context),

              const SizedBox(height: 16),

              // Pronunciations (like JavaScript renderPronunciations)
              _buildPronunciations(context),

              const SizedBox(height: 16),

              // Components section (like JavaScript renderRelatedCharacters)
              _buildComponentsSection(characterData),

              const SizedBox(height: 16),

              // Compounds section (like JavaScript renderRelatedCharacters)
              _buildCompoundsSection(characterData),
            ],
          );
        } catch (e) {
          debugPrint('Error in ComponentsTab: $e');
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Column(
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                Text('Error loading component data for: $character', style: const TextStyle(color: Colors.red)),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildCharacterHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Character display with tone coloring
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _getCharacterColor(character), borderRadius: BorderRadius.circular(8)),
            child: Text(
              character,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: _getTextColor(_getCharacterColor(character)),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Character info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Character: $character', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text('Click to update the component diagram', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPronunciations(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final definition = dataProvider.getDefinition(character);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pronunciations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            if (definition != null && definition.pinyin.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getCharacterColor(character).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getCharacterColor(character).withOpacity(0.3)),
                ),
                child: Text(
                  definition.pinyin,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _getCharacterColor(character)),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: const Text(
                  'No pronunciation data available',
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildComponentsSection(Map<String, dynamic> characterData) {
    final components = characterData['components'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Components', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),

        if (components.isNotEmpty) ...[
          _buildRelatedCharacters(components, 'components'),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: const Text(
              "No components found. Maybe we can't break this down any more.",
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompoundsSection(Map<String, dynamic> characterData) {
    final compounds = characterData['componentOf'] as List? ?? [];
    // Sort compounds by frequency if possible (like JavaScript)
    final sortedCompounds = List<String>.from(compounds.map((c) => c.toString()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Compounds', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),

        if (sortedCompounds.isNotEmpty) ...[
          _buildRelatedCharacters(sortedCompounds, 'compounds'),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: const Text(
              'This character is not a component of others.',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRelatedCharacters(List<dynamic> characters, String type) {
    return Builder(
      builder: (context) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              characters.map((char) {
                final charStr = char.toString();
                return GestureDetector(
                  onTap: () {
                    // Navigate to character (like JavaScript navigate functionality)
                    final graphProvider = context.read<GraphProvider>();
                    if (type == 'components') {
                      // Update component tree
                      graphProvider.generateComponentsTree(charStr);
                    } else {
                      // For compounds, could switch to graph mode or stay in components
                      graphProvider.generateComponentsTree(charStr);
                    }
                    debugPrint('Navigating to character: $charStr');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getCharacterColor(charStr).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _getCharacterColor(charStr).withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          charStr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _getCharacterColor(charStr),
                          ),
                        ),

                        // Show pinyin relationship if available (like JavaScript findPinyinRelationships)
                        // This is simplified - in the real implementation, use actual pinyin comparison
                        const SizedBox(width: 4),
                        Text(
                          _getPinyinRelationship(character, charStr, type),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        );
      },
    );
  }

  String _getPinyinRelationship(String source, String target, String type) {
    // Simplified pinyin relationship detection
    // In the real implementation, this would use actual pinyin data
    // and the findPinyinRelationships function from pronunciation-parser.js
    return ''; // Return empty for now, could be enhanced with actual pinyin comparison
  }

  Color _getCharacterColor(String character) {
    // Simple tone-based coloring (placeholder)
    final hash = character.codeUnitAt(0) % 5;
    switch (hash) {
      case 0:
        return const Color(0xFFff635f); // Tone 1
      case 1:
        return const Color(0xFF7aeb34); // Tone 2
      case 2:
        return const Color(0xFFde68ee); // Tone 3
      case 3:
        return const Color(0xFF68aaee); // Tone 4
      default:
        return Colors.grey[700]!; // Neutral tone
    }
  }

  Color _getTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}

/// Stats tab - equivalent to stats section in explore.js
class _StatsTab extends StatelessWidget {
  final String character;

  const _StatsTab({required this.character});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildFrequencyStats(), const SizedBox(height: 24), _buildUsageStats(context)],
      ),
    );
  }

  Widget _buildFrequencyStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Frequency Statistics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatItem('Character Frequency', _getCharacterFrequency(character)),
              const SizedBox(height: 8),
              _buildStatItem('Usage Level', _getUsageLevel(character)),
              const SizedBox(height: 8),
              _buildStatItem('Learning Priority', _getLearningPriority(character)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsageStats(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Usage Statistics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        Consumer<DataProvider>(
          builder: (context, dataProvider, child) {
            try {
              final sentences = dataProvider.getSentences(character);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatItem('Example Sentences', '${sentences.length}'),
                    const SizedBox(height: 8),
                    _buildStatItem('Average Sentence Length', _getAverageSentenceLength(sentences)),
                    const SizedBox(height: 8),
                    _buildStatItem('Common Patterns', _getCommonPatterns(character)),
                  ],
                ),
              );
            } catch (e) {
              debugPrint('Error in StatsTab usage stats: $e');
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text('Error loading usage statistics', style: const TextStyle(fontSize: 16, color: Colors.red)),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _getCharacterFrequency(String character) {
    // Simplified frequency calculation
    final common = ['我', '你', '他', '她', '的', '是', '在', '有', '了', '不'];
    if (common.contains(character)) {
      return 'Very High';
    }
    return 'Moderate';
  }

  String _getUsageLevel(String character) {
    return 'Beginner';
  }

  String _getLearningPriority(String character) {
    return 'High';
  }

  String _getAverageSentenceLength(List<SentenceData> sentences) {
    if (sentences.isEmpty) return '0';
    final total = sentences.fold(0, (sum, sentence) => sum + sentence.chinese.length);
    return (total / sentences.length).toStringAsFixed(1);
  }

  String _getCommonPatterns(String character) {
    return 'Subject, Object';
  }
}

/// Flow tab - equivalent to flow section in explore.js
class _FlowTab extends StatelessWidget {
  final String character;

  const _FlowTab({required this.character});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Usage Flow Diagram', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),

          _buildFlowDiagram(context),

          const SizedBox(height: 24),

          _buildUsagePatterns(),
        ],
      ),
    );
  }

  Widget _buildFlowDiagram(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timeline, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('Flow diagram visualization', style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Shows character usage patterns in context', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildUsagePatterns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Common Usage Patterns', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        ..._getUsagePatterns(character).map((pattern) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(pattern, style: const TextStyle(fontSize: 16))),
              ],
            ),
          );
        }),
      ],
    );
  }

  List<String> _getUsagePatterns(String character) {
    switch (character) {
      case '我':
        return ['Used as subject pronoun (我是...)', 'Possessive form (我的...)', 'Used in compound words (我们)'];
      case '你':
        return ['Used as subject pronoun (你好)', 'Possessive form (你的...)', 'In questions (你是谁?)'];
      case '好':
        return ['As adjective (好人)', 'As exclamation (好!)', 'In greetings (你好)'];
      default:
        return ['Common usage pattern 1', 'Common usage pattern 2', 'Common usage pattern 3'];
    }
  }
}
