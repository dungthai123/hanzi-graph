import 'package:flutter_test/flutter_test.dart';
import 'package:hanzi_graph/services/graph_service.dart';

void main() {
  group('GraphService', () {
    late GraphService graphService;

    setUp(() {
      graphService = GraphService();
    });

    test('builds graph from frequency list like JavaScript', () async {
      await graphService.initialize('simplified');

      // Test with a simple frequency list (like wordlist.json)
      final frequencyList = ['的', '我', '你', '了', '是', '在', '他', '我们', '不', '吗', '好'];

      // Build graph structure
      final hanziData = graphService.buildGraphFromFrequencyList(frequencyList);

      // Verify graph structure
      expect(hanziData, isNotEmpty);
      expect(hanziData.containsKey('我'), isTrue);
      expect(hanziData.containsKey('你'), isTrue);

      // Check node structure
      final nodeData = hanziData['我'];
      expect(nodeData['node']['level'], equals(1)); // First level (most frequent)
      expect(nodeData['edges'], isA<Map<String, dynamic>>());

      print('Graph structure for "我":');
      print('  Level: ${nodeData['node']['level']}');
      print('  Edges: ${nodeData['edges'].keys.toList()}');
    });

    test('generates graph with DFS like JavaScript', () async {
      await graphService.initialize('simplified');

      // Create test hanzi data
      final hanziData = {
        '我': {
          'node': {'level': 1},
          'edges': {
            '们': {
              'level': 1,
              'words': ['我们'],
            },
            '是': {
              'level': 1,
              'words': ['我是'],
            },
          },
        },
        '们': {
          'node': {'level': 1},
          'edges': {
            '我': {
              'level': 1,
              'words': ['我们'],
            },
          },
        },
        '是': {
          'node': {'level': 1},
          'edges': {
            '我': {
              'level': 1,
              'words': ['我是'],
            },
          },
        },
      };

      // Set the graph data in the service
      graphService.setGraphData(hanziData);

      // Generate graph
      final graph = await graphService.generateGraph('我');

      // Verify graph output
      expect(graph.centerCharacter, equals('我'));
      expect(graph.nodes, isNotEmpty);
      expect(graph.edges, isNotEmpty);

      // Check center node exists
      final centerNode = graph.nodes.firstWhere((node) => node.type == 'center');
      expect(centerNode.character, equals('我'));

      // Check related nodes
      final relatedNodes = graph.nodes.where((node) => node.type == 'related').toList();
      expect(relatedNodes, isNotEmpty);

      print('Generated graph:');
      print('  Center: ${graph.centerCharacter}');
      print('  Nodes: ${graph.nodes.length}');
      print('  Edges: ${graph.edges.length}');
      print('  Related characters: ${relatedNodes.map((n) => n.character).toList()}');
    });

    test('builds component tree like JavaScript', () async {
      await graphService.initialize('simplified');

      // Test components data
      final componentsData = {
        '我': {
          'components': ['手', '戈'],
        },
        '手': {
          'components': ['丶', '手'],
        },
        '戈': {
          'components': ['一', '戈'],
        },
      };

      // Build component tree
      final tree = graphService.buildComponentTree('我', componentsData);

      // Verify tree structure
      expect(tree.centerCharacter, equals('我'));
      expect(tree.nodes, isNotEmpty);
      expect(tree.edges, isNotEmpty);

      // Check root node
      final rootNode = tree.nodes.firstWhere((node) => node.type == 'center');
      expect(rootNode.character, equals('我'));
      expect(rootNode.depth, equals(0));

      // Check component nodes
      final componentNodes = tree.nodes.where((node) => node.type == 'component').toList();
      expect(componentNodes, isNotEmpty);

      print('Component tree:');
      print('  Root: ${tree.centerCharacter}');
      print('  Total nodes: ${tree.nodes.length}');
      print('  Component levels: ${componentNodes.map((n) => '${n.character}(depth:${n.depth})').toList()}');
    });

    test('calculates max edges correctly', () {
      expect(graphService.getMaxEdges('我'), equals(8)); // 1 unique char
      expect(graphService.getMaxEdges('我们'), equals(8)); // 2 unique chars
      expect(graphService.getMaxEdges('我们他'), equals(6)); // 3 unique chars
      expect(graphService.getMaxEdges('我们他她'), equals(5)); // 4 unique chars
      expect(graphService.getMaxEdges('我们他她它'), equals(4)); // 5 unique chars
    });
  });
}
