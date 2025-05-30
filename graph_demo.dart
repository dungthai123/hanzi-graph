import 'dart:convert';
import 'dart:io';
import 'lib/services/graph_service.dart';
import 'lib/services/data_service.dart';

Future<void> main() async {
  print('🚀 HanziGraph - Graph Feature Demo');
  print('==================================');

  try {
    // Initialize services
    final graphService = GraphService();
    final dataService = DataService();

    await graphService.initialize('simplified');

    // Load real data
    final definitionsFile = File('assets/data/simplified/definitions.json');
    final definitionsContent = await definitionsFile.readAsString();
    final definitions = json.decode(definitionsContent) as Map<String, dynamic>;

    final sentencesFile = File('assets/data/simplified/sentences.json');
    final sentencesContent = await sentencesFile.readAsString();
    final sentences = json.decode(sentencesContent) as List;

    final wordlistFile = File('assets/data/simplified/wordlist.json');
    final wordlistContent = await wordlistFile.readAsString();
    final wordlistData = json.decode(wordlistContent) as List;
    final wordlist = wordlistData.map((e) => e.toString()).toList();

    // Initialize data service
    await dataService.initialize(
      hanziData: {},
      sentencesData: sentences,
      definitionsData: definitions,
      componentsData: {},
    );

    print('✅ Services initialized');
    print('   📚 Characters: ${definitions.length}');
    print('   📝 Sentences: ${sentences.length}');
    print('   📖 Wordlist: ${wordlist.length}');
    print('');

    // Demo 1: Build graph from frequency data (like JavaScript buildGraphFromFrequencyList)
    print('🔧 Demo 1: Building graph from frequency data');
    print('   (Equivalent to JavaScript buildGraphFromFrequencyList function)');

    final topWords = wordlist.take(20).toList();
    print('   Using top ${topWords.length} words: ${topWords.take(10).join(", ")}...');

    final hanziData = graphService.buildGraphFromFrequencyList(topWords);
    print('   ✅ Graph built with ${hanziData.length} characters');

    // Show structure for "我"
    if (hanziData.containsKey('我')) {
      final nodeData = hanziData['我'];
      final level = nodeData['node']['level'];
      final edges = nodeData['edges'] as Map<String, dynamic>;
      print('   📊 Character "我": Level $level, ${edges.length} edges');
      print('      Connected to: ${edges.keys.take(5).join(", ")}');

      // Show edge details
      for (final edge in edges.entries.take(3)) {
        final edgeData = edge.value as Map<String, dynamic>;
        final words = edgeData['words'] as List;
        print('      → ${edge.key}: level ${edgeData['level']}, words: ${words.join(", ")}');
      }
    }
    print('');

    // Demo 2: Generate graph using DFS (like JavaScript dfs function)
    print('🕸️  Demo 2: Generating graph visualization');
    print('   (Equivalent to JavaScript dfs and buildGraph functions)');

    // Set the graph data in the service first
    graphService.setGraphData(hanziData);

    final graph = await graphService.generateGraph('我');
    print('   ✅ Graph generated for "${graph.centerCharacter}"');
    print('   📊 Nodes: ${graph.nodes.length}, Edges: ${graph.edges.length}');

    // Show nodes
    print(
      '   🔴 Center node: ${graph.nodes.where((n) => n.type == 'center').map((n) => '${n.character}(L${n.level})').join(", ")}',
    );
    final relatedNodes = graph.nodes.where((n) => n.type == 'related').toList();
    print('   🔵 Related nodes: ${relatedNodes.map((n) => '${n.character}(L${n.level})').join(", ")}');

    // Show edges
    print('   📝 Sample edges:');
    for (final edge in graph.edges.take(5)) {
      final words = edge.words.isNotEmpty ? edge.words.join(',') : edge.displayWord;
      print('      ${edge.source} ↔ ${edge.target} (Level ${edge.level}) - "$words"');
    }
    print('');

    // Demo 3: Component tree (like JavaScript componentsBfs)
    print('🌳 Demo 3: Building component tree');
    print('   (Equivalent to JavaScript componentsBfs function)');

    final componentsData = {
      '我': {
        'components': ['手', '戈'],
      },
      '手': {
        'components': ['丶', '二'],
      },
      '戈': {
        'components': ['一', '弋'],
      },
      '好': {
        'components': ['女', '子'],
      },
      '女': {
        'components': ['丿', '乚'],
      },
      '子': {
        'components': ['丿', '一'],
      },
    };

    final componentTree = graphService.buildComponentTree('我', componentsData);
    print('   ✅ Component tree built for "${componentTree.centerCharacter}"');
    print('   📊 Nodes: ${componentTree.nodes.length}, Edges: ${componentTree.edges.length}');

    // Show tree structure
    final nodesByDepth = <int, List<String>>{};
    for (final node in componentTree.nodes) {
      final depth = node.depth ?? 0;
      nodesByDepth.putIfAbsent(depth, () => []).add('${node.character}(${node.type})');
    }

    for (final entry in nodesByDepth.entries) {
      print('   Level ${entry.key}: ${entry.value.join(", ")}');
    }
    print('');

    // Demo 4: Real character relationships
    print('🔍 Demo 4: Real character relationships from data');
    print('   Using actual sentences and definitions');

    final testChar = '好';
    print('   Analyzing character: "$testChar"');

    // Get definition
    final definition = dataService.getDefinition(testChar);
    if (definition != null) {
      print('   📖 Definition: ${definition.english.first} (${definition.pinyin})');
    }

    // Get sentences
    final sentencesWithChar = dataService.getSentences(testChar);
    print('   📝 Found in ${sentencesWithChar.length} sentences');
    for (final sentence in sentencesWithChar.take(3)) {
      print('      "${sentence.chinese}" - ${sentence.english}');
    }

    // Generate graph for this character
    final realGraph = await graphService.generateGraph(testChar);
    print('   🕸️  Generated graph: ${realGraph.nodes.length} nodes, ${realGraph.edges.length} edges');
    final realRelated = realGraph.nodes.where((n) => n.type == 'related').map((n) => n.character).toList();
    print('      Related characters: ${realRelated.take(10).join(", ")}');
    print('');

    print('🎉 Graph Feature Demo Complete!');
    print('');
    print('✅ Successfully demonstrated:');
    print('   🔧 Graph building from frequency data (buildGraphFromFrequencyList)');
    print('   🕸️  DFS graph generation (dfs, buildGraph)');
    print('   🌳 Component tree building (componentsBfs)');
    print('   🔍 Real data integration with character relationships');
    print('   📊 Frequency-based node leveling and edge creation');
    print('   🎨 Graph visualization data structure');
    print('');
    print('🚀 The Flutter graph feature now works like the JavaScript version!');
  } catch (e) {
    print('❌ Error in graph demo: $e');
  }
}
