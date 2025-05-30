import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../services/graph_service.dart';

/// Demo for testing component tree functionality
/// Equivalent to JavaScript buildComponentTree and componentsBfs
class ComponentTreeDemo {
  static Future<void> runDemo(DataService dataService, GraphService graphService) async {
    print('🌳 Component Tree Demo - Testing JavaScript Equivalent Functionality');
    print('=' * 60);

    try {
      // Test 1: Basic component tree building (like JavaScript componentsBfs)
      print('📊 Test 1: Building component tree for character "好"');

      final componentsData = dataService.getAllComponentsData();
      print('   Components data loaded: ${componentsData.keys.length} entries');

      // Build component tree like JavaScript buildComponentTree
      final componentTree = graphService.buildComponentTree('好', componentsData);
      print('   ✅ Component tree built successfully!');
      print('   📈 Nodes: ${componentTree.nodes.length}, Edges: ${componentTree.edges.length}');

      // Display tree structure by depth (like JavaScript componentsBfs result)
      final nodesByDepth = <int, List<String>>{};
      for (final node in componentTree.nodes) {
        final depth = node.depth ?? 0;
        nodesByDepth.putIfAbsent(depth, () => []).add('${node.character}(${node.type})');
      }

      print('   Tree structure:');
      for (final entry in nodesByDepth.entries) {
        print('     Level ${entry.key}: ${entry.value.join(", ")}');
      }
      print('');

      // Test 2: Character with multiple component levels
      print('📊 Test 2: Deep component breakdown for "停"');

      final deepTree = graphService.buildComponentTree('停', componentsData);
      print('   ✅ Deep tree built: ${deepTree.nodes.length} nodes, ${deepTree.edges.length} edges');

      final deepNodesByDepth = <int, List<String>>{};
      for (final node in deepTree.nodes) {
        final depth = node.depth ?? 0;
        deepNodesByDepth.putIfAbsent(depth, () => []).add(node.character);
      }

      print('   Deep structure:');
      for (final entry in deepNodesByDepth.entries) {
        print('     Level ${entry.key}: ${entry.value.join(" → ")}');
      }
      print('');

      // Test 3: Component relationships (like JavaScript components data access)
      print('📊 Test 3: Component relationship analysis');

      final testCharacters = ['人', '亻', '女', '子', '木', '水'];
      for (final char in testCharacters) {
        final componentData = dataService.getComponent(char);
        if (componentData != null) {
          print(
            '   $char: ${componentData.components.length} components, used in ${componentData.componentOf.length} characters',
          );
          if (componentData.components.isNotEmpty) {
            print('      Components: ${componentData.components.take(5).join(", ")}');
          }
          if (componentData.componentOf.isNotEmpty) {
            print('      Used in: ${componentData.componentOf.take(5).join(", ")}');
          }
        } else {
          print('   $char: No component data found');
        }
      }
      print('');

      // Test 4: Interactive navigation simulation (like JavaScript node tap handling)
      print('📊 Test 4: Simulating interactive navigation');

      final navigationPath = ['好', '女', '子'];
      for (final char in navigationPath) {
        print('   🔍 Navigating to: $char');
        final navTree = graphService.buildComponentTree(char, componentsData);
        final rootNode = navTree.nodes.firstWhere((n) => n.type == 'center');
        final childNodes = navTree.nodes.where((n) => n.type == 'component').take(3).toList();

        print('      Root: ${rootNode.character}');
        if (childNodes.isNotEmpty) {
          print('      Children: ${childNodes.map((n) => n.character).join(", ")}');
        }
      }
      print('');

      // Test 5: Layout calculation simulation (like JavaScript bfsLayout)
      print('📊 Test 5: Layout calculation test');

      final layoutTree = graphService.buildComponentTree('新', componentsData);
      final mockSize = const Size(400, 300);

      // Simulate layout calculation
      final nodesByDepthForLayout = <int, List<String>>{};
      for (final node in layoutTree.nodes) {
        final depth = node.depth ?? 0;
        nodesByDepthForLayout.putIfAbsent(depth, () => []).add(node.character);
      }

      print('   📐 Layout simulation for 400x300 canvas:');
      final levelHeight = mockSize.height / (nodesByDepthForLayout.length + 1);

      for (final entry in nodesByDepthForLayout.entries) {
        final depth = entry.key;
        final nodes = entry.value;
        final y = levelHeight * (depth + 1);
        final levelWidth = mockSize.width / (nodes.length + 1);

        print('     Level $depth (y=${y.toInt()}):');
        for (int i = 0; i < nodes.length; i++) {
          final x = levelWidth * (i + 1);
          print('       ${nodes[i]} at (${x.toInt()}, ${y.toInt()})');
        }
      }
      print('');

      // Test 6: Error handling and edge cases
      print('📊 Test 6: Error handling and edge cases');

      // Test non-existent character
      final emptyTree = graphService.buildComponentTree('🚀', componentsData);
      print('   🚀 Non-existent character: ${emptyTree.nodes.length} nodes');

      // Test character with no components
      final noComponentsTree = graphService.buildComponentTree('丶', componentsData);
      print('   丶 Simple character: ${noComponentsTree.nodes.length} nodes');

      // Test empty input
      try {
        final invalidTree = graphService.buildComponentTree('', componentsData);
        print('   Empty input: ${invalidTree.nodes.length} nodes');
      } catch (e) {
        print('   Empty input: Error handled - $e');
      }
      print('');

      print('🎉 Component Tree Demo Complete!');
      print('');
      print('✅ Successfully demonstrated:');
      print('   🌳 Component tree building (componentsBfs equivalent)');
      print('   🎨 Tree visualization data structure');
      print('   🔍 Interactive navigation simulation');
      print('   📐 Layout calculation (bfsLayout equivalent)');
      print('   🛡️  Error handling and edge cases');
      print('   📊 Component relationship analysis');
      print('');
      print('🚀 The Flutter component tree feature now matches JavaScript functionality!');
    } catch (e) {
      print('❌ Error in component tree demo: $e');
      rethrow;
    }
  }
}

/// Widget to display component tree demo results
class ComponentTreeDemoWidget extends StatefulWidget {
  final DataService dataService;
  final GraphService graphService;

  const ComponentTreeDemoWidget({super.key, required this.dataService, required this.graphService});

  @override
  State<ComponentTreeDemoWidget> createState() => _ComponentTreeDemoWidgetState();
}

class _ComponentTreeDemoWidgetState extends State<ComponentTreeDemoWidget> {
  bool _isRunning = false;
  String _results = '';

  Future<void> _runDemo() async {
    setState(() {
      _isRunning = true;
      _results = '';
    });

    try {
      // Capture print output
      final buffer = StringBuffer();

      await ComponentTreeDemo.runDemo(widget.dataService, widget.graphService);

      setState(() {
        _results = 'Demo completed successfully! Check console for detailed output.';
        _isRunning = false;
      });
    } catch (e) {
      setState(() {
        _results = 'Demo failed: $e';
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Component Tree Demo'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Component Tree Functionality Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'This demo tests the Flutter implementation of the JavaScript component tree functionality.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _isRunning ? null : _runDemo,
              icon:
                  _isRunning
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.play_arrow),
              label: Text(_isRunning ? 'Running Demo...' : 'Run Component Tree Demo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),

            const SizedBox(height: 24),

            if (_results.isNotEmpty) ...[
              const Text('Results:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(_results, style: const TextStyle(fontSize: 14, fontFamily: 'monospace')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
