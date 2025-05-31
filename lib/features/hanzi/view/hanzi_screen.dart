import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/hanzi_viewmodel.dart';

/// Main screen for hanzi operations
class HanziScreen extends StatefulWidget {
  const HanziScreen({super.key});

  @override
  State<HanziScreen> createState() => _HanziScreenState();
}

class _HanziScreenState extends State<HanziScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hanzi Explorer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<HanziViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${viewModel.error}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => viewModel.clearError(), child: const Text('Dismiss')),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Search Characters', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter character to search...',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (value) {
                                  if (value.trim().isNotEmpty) {
                                    viewModel.searchCharacters(value.trim());
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                final query = _searchController.text.trim();
                                if (query.isNotEmpty) {
                                  viewModel.searchCharacters(query);
                                }
                              },
                              child: const Text('Search'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Search Results
                if (viewModel.searchResults.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Search Results (${viewModel.searchResults.length})',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                viewModel.searchResults.map((char) {
                                  return ActionChip(
                                    label: Text(char, style: const TextStyle(fontSize: 18)),
                                    onPressed: () => viewModel.selectCharacter(char),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Character Details
                if (viewModel.currentHanziDetails != null) ...[
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(viewModel.selectedCharacter, style: Theme.of(context).textTheme.headlineLarge),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () => viewModel.clearHanziDetails(),
                                    icon: const Icon(Icons.close),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Definition
                              if (viewModel.currentHanziDetails!.hasDefinition) ...[
                                Text('Definition', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 8),
                                Text(
                                  'Pinyin: ${viewModel.currentHanziDetails!.definition!.pinyin}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'English: ${viewModel.currentHanziDetails!.definition!.english.join(', ')}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Components
                              if (viewModel.currentHanziDetails!.hasComponents) ...[
                                Text('Components', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children:
                                      viewModel.currentHanziDetails!.components.map((comp) {
                                        return Chip(label: Text(comp, style: const TextStyle(fontSize: 16)));
                                      }).toList(),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Sentences
                              if (viewModel.currentHanziDetails!.hasSentences) ...[
                                Text('Example Sentences', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 8),
                                ...viewModel.currentHanziDetails!.sentences.take(3).map((sentence) {
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sentence.chinese,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            sentence.pinyin,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(sentence.english, style: Theme.of(context).textTheme.bodyMedium),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
