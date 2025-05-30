import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/search_provider.dart';
import '../../providers/graph_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/sentence_data.dart';
import '../../models/definition_data.dart';

/// Examples widget - equivalent to explore.js functionality
/// Shows character definitions, sentences, and related information
class ExamplesWidget extends StatelessWidget {
  const ExamplesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SearchProvider, GraphProvider>(
      builder: (context, searchProvider, graphProvider, child) {
        final selectedCharacter =
            searchProvider.selectedCharacter.isNotEmpty
                ? searchProvider.selectedCharacter
                : graphProvider.centerCharacter;

        if (selectedCharacter.isEmpty) {
          return const Center(
            child: Text('Search for a character to see examples', style: TextStyle(fontSize: 16, color: Colors.grey)),
          );
        }

        // Add error boundary for data provider access
        try {
          final dataProvider = context.read<DataProvider>();

          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Character header
                _buildCharacterHeader(context, selectedCharacter),

                const SizedBox(height: 16),

                // Content sections
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Definition section
                        _buildDefinitionSection(context, selectedCharacter, dataProvider),

                        const SizedBox(height: 24),

                        // Examples section
                        _buildExamplesSection(context, selectedCharacter, dataProvider),

                        const SizedBox(height: 24),

                        // Related characters section
                        _buildRelatedCharactersSection(context, graphProvider),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } catch (e) {
          // Fallback for any provider access errors
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading data: ${e.toString()}', style: const TextStyle(fontSize: 16, color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Try to refresh the app state
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                  child: const Text('Restart App'),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildCharacterHeader(BuildContext context, String character) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Large character display
          Text(character, style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w300, color: Color(0xFF1A1A1A))),

          const SizedBox(width: 24),

          // Character info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Character Details', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Tap related characters in the graph to explore connections',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefinitionSection(BuildContext context, String character, DataProvider dataProvider) {
    try {
      final definition = dataProvider.getDefinition(character);

      if (definition == null) {
        return _buildSectionCard(context, 'Definition', const Text('No definition available'));
      }

      return _buildSectionCard(
        context,
        'Definition',
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pinyin
            if (definition.pinyin.isNotEmpty)
              Text(
                definition.pinyin,
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Color(0xFF666666)),
              ),

            const SizedBox(height: 8),

            // English definitions
            ...definition.english.map(
              (def) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $def', style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),

            // Parts of speech
            if (definition.parts.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    definition.parts
                        .map(
                          (part) =>
                              Chip(label: Text(part), backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1)),
                        )
                        .toList(),
              ),
            ],

            // HSK level
            if (definition.hskLevel > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'HSK Level ${definition.hskLevel}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.orange),
                ),
              ),
            ],
          ],
        ),
      );
    } catch (e) {
      return _buildSectionCard(
        context,
        'Definition',
        Text('Error loading definition: ${e.toString()}', style: const TextStyle(color: Colors.red)),
      );
    }
  }

  Widget _buildExamplesSection(BuildContext context, String character, DataProvider dataProvider) {
    try {
      final sentences = dataProvider.getSentences(character);

      if (sentences.isEmpty) {
        return _buildSectionCard(context, 'Example Sentences', const Text('No example sentences available'));
      }

      return _buildSectionCard(
        context,
        'Example Sentences',
        Column(children: sentences.take(5).map((sentence) => _buildSentenceItem(context, sentence)).toList()),
      );
    } catch (e) {
      return _buildSectionCard(
        context,
        'Example Sentences',
        Text('Error loading examples: ${e.toString()}', style: const TextStyle(color: Colors.red)),
      );
    }
  }

  Widget _buildSentenceItem(BuildContext context, SentenceData sentence) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chinese text
          Text(
            sentence.chinese,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A)),
          ),

          const SizedBox(height: 4),

          // Pinyin
          if (sentence.pinyin.isNotEmpty)
            Text(
              sentence.pinyin,
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Color(0xFF666666)),
            ),

          const SizedBox(height: 8),

          // English translation
          Text(sentence.english, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildRelatedCharactersSection(BuildContext context, GraphProvider graphProvider) {
    final relatedChars = graphProvider.getRelatedCharacters();

    if (relatedChars.isEmpty) {
      return _buildSectionCard(context, 'Related Characters', const Text('No related characters found'));
    }

    return _buildSectionCard(
      context,
      'Related Characters',
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: relatedChars.map((char) => _buildRelatedCharacterChip(context, char, graphProvider)).toList(),
      ),
    );
  }

  Widget _buildRelatedCharacterChip(BuildContext context, String character, GraphProvider graphProvider) {
    return GestureDetector(
      onTap: () {
        // Generate new graph for this character
        graphProvider.generateGraph(character);

        // Update search provider
        final searchProvider = context.read<SearchProvider>();
        searchProvider.selectCharacter(character);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
        ),
        child: Text(
          character,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, String title, Widget content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }
}
