import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/graph_viewmodel.dart';

/// Main screen for graph visualization
class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  final TextEditingController _characterController = TextEditingController();

  @override
  void dispose() {
    _characterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graph Visualization'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<GraphViewModel>(
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
                // Input Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Generate Graph', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _characterController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter character...',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (value) {
                                  if (value.trim().isNotEmpty) {
                                    viewModel.generateGraph(value.trim());
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                final character = _characterController.text.trim();
                                if (character.isNotEmpty) {
                                  viewModel.generateGraph(character);
                                }
                              },
                              child: const Text('Graph'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                final character = _characterController.text.trim();
                                if (character.isNotEmpty) {
                                  viewModel.generateComponentsTree(character);
                                }
                              },
                              child: const Text('Components'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Mode Toggle
                if (viewModel.currentGraph != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Text('Mode:', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(width: 16),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'graph', label: Text('Graph')),
                              ButtonSegment(value: 'components', label: Text('Components')),
                            ],
                            selected: {viewModel.graphMode},
                            onSelectionChanged: (Set<String> selected) {
                              viewModel.switchGraphMode(selected.first);
                            },
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => viewModel.clearGraph(),
                            icon: const Icon(Icons.clear),
                            tooltip: 'Clear Graph',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Graph Visualization
                if (viewModel.currentGraph != null && viewModel.showGraph) ...[
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Graph for: ${viewModel.centerCharacter}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const Spacer(),
                                Text(
                                  'Nodes: ${viewModel.currentGraph!.nodes.length}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Simple node visualization
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Stack(
                                  children: [
                                    // Center node
                                    Center(
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            viewModel.centerCharacter,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onPrimary,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Related nodes positioned around center
                                    ...viewModel.currentGraph!.nodes.where((node) => node.type != 'center').map((node) {
                                      return Positioned(
                                        left: MediaQuery.of(context).size.width / 2 + node.x - 120,
                                        top: MediaQuery.of(context).size.height / 2 + node.y - 200,
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color:
                                                node.type == 'component'
                                                    ? Theme.of(context).colorScheme.secondary
                                                    : Theme.of(context).colorScheme.tertiary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              node.character,
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSecondary,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Graph info
                            Text(
                              'Type: ${viewModel.currentGraph!.type.toUpperCase()}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),

                            // Related characters list
                            if (viewModel.getRelatedCharacters().isNotEmpty) ...[
                              Text(
                                'Related Characters:',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                children:
                                    viewModel.getRelatedCharacters().map((char) {
                                      return Chip(
                                        label: Text(char, style: const TextStyle(fontSize: 14)),
                                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                      );
                                    }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                // Empty state
                if (viewModel.currentGraph == null) ...[
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_tree, size: 64, color: Theme.of(context).colorScheme.outline),
                          const SizedBox(height: 16),
                          Text(
                            'Enter a character to generate a graph',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ],
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
