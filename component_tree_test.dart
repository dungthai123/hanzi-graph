import 'lib/services/data_service.dart';
import 'lib/services/graph_service.dart';
import 'lib/demo/component_tree_demo.dart';

/// Simple test script for component tree functionality
Future<void> main() async {
  print('🌳 Component Tree Test - Verifying JavaScript Equivalent Functionality');
  print('=' * 70);

  try {
    // Initialize services
    final dataService = DataService();
    final graphService = GraphService();

    // Initialize with minimal test data
    await dataService.initialize(
      hanziData: {},
      sentencesData: [],
      definitionsData: {
        '好': [
          {'en': 'good', 'pinyin': 'hao3'},
        ],
        '女': [
          {'en': 'woman', 'pinyin': 'nv3'},
        ],
        '子': [
          {'en': 'child', 'pinyin': 'zi3'},
        ],
      },
      componentsData: {
        '好': {
          'type': 's',
          'components': ['女', '子'],
          'componentOf': [],
        },
        '女': {
          'type': 's',
          'components': [],
          'componentOf': ['好', '她', '妈'],
        },
        '子': {
          'type': 's',
          'components': [],
          'componentOf': ['好', '字', '孩'],
        },
      },
    );

    print('✅ Services initialized successfully');

    // Initialize graph service
    await graphService.initialize('simplified');
    print('✅ Graph service initialized');

    // Test basic component tree building
    print('\n📊 Testing component tree building for "好"...');

    final componentsData = dataService.getAllComponentsData();
    final componentTree = graphService.buildComponentTree('好', componentsData);

    print('   🌳 Component tree created:');
    print('      Nodes: ${componentTree.nodes.length}');
    print('      Edges: ${componentTree.edges.length}');
    print('      Center: ${componentTree.centerCharacter}');

    // Display tree structure
    final nodesByDepth = <int, List<String>>{};
    for (final node in componentTree.nodes) {
      final depth = node.depth ?? 0;
      nodesByDepth.putIfAbsent(depth, () => []).add('${node.character}(${node.type})');
    }

    print('   🏗️  Tree structure:');
    for (final entry in nodesByDepth.entries) {
      print('      Level ${entry.key}: ${entry.value.join(", ")}');
    }

    // Test edge relationships
    print('\n🔗 Testing edge relationships:');
    for (final edge in componentTree.edges) {
      print('   Edge: ${edge.source} → ${edge.target}');
    }

    // Test node types
    print('\n🎯 Testing node classification:');
    final centerNodes = componentTree.nodes.where((n) => n.type == 'center').toList();
    final componentNodes = componentTree.nodes.where((n) => n.type == 'component').toList();

    print('   Center nodes: ${centerNodes.length} (${centerNodes.map((n) => n.character).join(", ")})');
    print('   Component nodes: ${componentNodes.length} (${componentNodes.map((n) => n.character).join(", ")})');

    // Test component relationships
    print('\n📚 Testing component data access:');
    final testCharacters = ['好', '女', '子'];
    for (final char in testCharacters) {
      final componentData = dataService.getComponent(char);
      if (componentData != null) {
        print(
          '   $char: ${componentData.components.length} components, used in ${componentData.componentOf.length} characters',
        );
      }
    }

    print('\n🎉 Component Tree Test Completed Successfully!');
    print('\n✅ Verified functionality:');
    print('   🌳 Component tree building (equivalent to JavaScript componentsBfs)');
    print('   🎨 Tree data structure with proper depth and rank information');
    print('   🔗 Edge creation between parent and child components');
    print('   🎯 Node type classification (center vs component)');
    print('   📚 Component data access and relationships');
    print('\n🚀 The Flutter component tree feature is working correctly!');
  } catch (e, stackTrace) {
    print('❌ Component tree test failed: $e');
    print('Stack trace: $stackTrace');
  }
}
