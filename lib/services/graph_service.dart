import '../models/graph_data.dart';

/// Graph service - equivalent to graph.js and graph-functions.js
/// Handles graph generation and character relationship mapping
class GraphService {
  String _characterSet = 'simplified';
  bool _isInitialized = false;
  Map<String, dynamic> _hanziGraphData = {}; // Prebuilt graph data
  final Map<String, int> _wordFrequencyData = {}; // Word frequency rankings

  // Graph building constants (from graph-functions.js)
  static const int maxEdges = 8;
  static const int maxWordsPerEdge = 2;
  static const int maxIndexForMultipleWordsOnEdge = 10000;

  // Frequency ranks (from graph.js)
  static const List<int> ranks = [1000, 2000, 4000, 7000, 10000, 999999999];

  bool get isInitialized => _isInitialized;

  /// Initialize the graph service with prebuilt graph data
  Future<void> initialize(String characterSet) async {
    _characterSet = characterSet;
    _isInitialized = true;
    print('Graph service initialized for $_characterSet');
  }

  /// Set prebuilt graph data (from graph.json)
  void setGraphData(Map<String, dynamic> hanziData) {
    _hanziGraphData = hanziData;
    print('Graph data loaded: ${_hanziGraphData.length} characters');
  }

  /// Set word frequency data (from wordlist.json)
  void setWordFrequencyData(List<dynamic> wordList) {
    _wordFrequencyData.clear();
    for (int i = 0; i < wordList.length; i++) {
      final word = wordList[i].toString();
      _wordFrequencyData[word] = i + 1; // 1-indexed frequency rank
    }
    print('Word frequency data loaded: ${_wordFrequencyData.length} words');
  }

  /// Find rank of a word in frequency list
  int findRank(String word) {
    if (!_wordFrequencyData.containsKey(word)) {
      return ranks.length;
    }

    final freq = _wordFrequencyData[word]!;
    for (int i = 0; i < ranks.length; i++) {
      if (freq < ranks[i]) {
        return i + 1;
      }
    }
    return ranks.length;
  }

  /// Generate graph using DFS (equivalent to dfs function in graph.js)
  void dfs(String start, GraphData result, int maxDepth, Set<String> visited, int maxEdgesLimit) {
    if (maxDepth < 0) return;

    final curr = _hanziGraphData[start];
    if (curr == null) return;

    visited.add(start);
    final usedEdges = <String>[];

    // Process edges
    final edges = curr['edges'] as Map<String, dynamic>? ?? {};
    for (final entry in edges.entries) {
      if (usedEdges.length >= maxEdgesLimit) break;

      final key = entry.key;
      final value = entry.value as Map<String, dynamic>;

      // Don't add outgoing edges when we won't process the next layer
      if (maxDepth > 0) {
        if (!visited.contains(key)) {
          // Create edge
          final edgeId = [start, key]..sort();
          final edge = GraphEdge(
            id: edgeId.join(''),
            source: start,
            target: key,
            level: value['level'] as int? ?? 1,
            words: List<String>.from(value['words'] as List? ?? []),
            displayWord: (value['words'] as List?)?.isNotEmpty == true ? value['words'][0] as String : '',
          );

          // Check if edge already exists
          final existsAlready = result.edges.any(
            (e) =>
                (e.source == edge.source && e.target == edge.target) ||
                (e.source == edge.target && e.target == edge.source),
          );

          if (!existsAlready) {
            result.edges.add(edge);
            usedEdges.add(key);
          }
        }
      }
    }

    // Add node
    final nodeLevel = curr['node']?['level'] as int? ?? 1;
    final nodeExists = result.nodes.any((n) => n.character == start);
    if (!nodeExists) {
      result.nodes.add(
        GraphNode(character: start, level: nodeLevel, type: start == result.centerCharacter ? 'center' : 'related'),
      );
    }

    // Recursive DFS
    for (final key in usedEdges) {
      if (!visited.contains(key)) {
        dfs(key, result, maxDepth - 1, visited, maxEdgesLimit);
      }
    }
  }

  /// Add edges between characters in a word (equivalent to addEdges in graph.js)
  void addEdges(String word, GraphData result) {
    for (int i = 0; i < word.length - 1; i++) {
      _addEdge(word[i], word[i + 1], word, result);
    }
    if (word.length > 1) {
      // Also connect last to first
      _addEdge(word[word.length - 1], word[0], word, result);
    }
  }

  /// Add single edge between two characters
  void _addEdge(String base, String target, String word, GraphData result) {
    if (!_hanziGraphData.containsKey(base) || !_hanziGraphData.containsKey(target)) return;
    if (base == target) return;

    // Check if edge already exists
    final edgeExists = result.edges.any(
      (edge) => (edge.source == base && edge.target == target) || (edge.source == target && edge.target == base),
    );

    if (!edgeExists) {
      final edgeId = [base, target]..sort();
      result.edges.add(
        GraphEdge(
          id: edgeId.join(''),
          source: base,
          target: target,
          level: findRank(word),
          words: [word],
          displayWord: word,
        ),
      );
    }
  }

  /// Get max edges for a word based on unique characters (from graph.js)
  int getMaxEdges(String word) {
    final unique = word.split('').toSet();
    if (unique.length < 3) return 8;
    if (unique.length < 4) return 6;
    if (unique.length < 5) return 5;
    return 4;
  }

  /// Generate graph for a word/character (equivalent to buildGraph in graph.js)
  Future<GraphData> generateGraph(String value) async {
    print('🔧 GraphService: Starting graph generation for "$value"');
    final result = GraphData(centerCharacter: value, nodes: [], edges: []);

    if (_hanziGraphData.isEmpty) {
      print('❌ GraphService: No graph data loaded');
      return result;
    }

    print('🔧 GraphService: Graph data available: ${_hanziGraphData.length} characters');

    // Check if the character exists in our data
    final hasCharacter = _hanziGraphData.containsKey(value);
    print('🔧 GraphService: Character "$value" exists in graph data: $hasCharacter');

    if (hasCharacter) {
      final charData = _hanziGraphData[value];
      print('🔧 GraphService: Character data: $charData');
    }

    const maxDepth = 1;
    final visited = <String>{};

    // Process each character in the input value (like JavaScript buildGraph)
    for (final character in value.split('')) {
      if (_hanziGraphData.containsKey(character)) {
        print('🔧 GraphService: Processing character "$character" with DFS...');
        dfs(character, result, maxDepth, visited, getMaxEdges(value));
      } else {
        print('⚠️ GraphService: Character "$character" not found in graph data');
      }
    }

    // Add edges between characters in the word itself
    if (value.length > 1) {
      print('🔧 GraphService: Adding edges between characters in word "$value"');
      addEdges(value, result);
    }

    print('✅ GraphService: Graph generation complete!');
    print('   Generated ${result.nodes.length} nodes: ${result.nodes.map((n) => n.character).join(", ")}');
    print('   Generated ${result.edges.length} edges');

    return result;
  }

  /// Build components tree (equivalent to componentsBfs in graph.js)
  GraphData buildComponentTree(String value, Map<String, dynamic> componentsData) {
    print('🌳 GraphService: Building component tree for "$value"');
    print('🌳 GraphService: Components data keys: ${componentsData.keys.toList()}');

    final result = GraphData(centerCharacter: value, nodes: [], edges: []);

    // Queue with word and path (like JavaScript componentsBfs)
    final queue = <Map<String, dynamic>>[
      {
        'word': value,
        'path': [value],
      },
    ];

    // Track counts by depth for treeRank (like JavaScript countsByDepth)
    final countsByDepth = <int, int>{};
    final processedNodes = <String>{}; // Track processed nodes to prevent infinite loops

    while (queue.isNotEmpty) {
      final curr = queue.removeAt(0);
      final word = curr['word'] as String;
      final path = curr['path'] as List<String>;
      final depth = path.length - 1;

      // Create node ID by joining path (like JavaScript: curr.path.join(''))
      final nodeId = path.join('');

      // Prevent infinite loops by checking if we've already processed this node
      if (processedNodes.contains(nodeId)) {
        print('🌳 GraphService: Skipping already processed node: $nodeId');
        continue;
      }
      processedNodes.add(nodeId);

      // Initialize depth counter if needed
      if (!countsByDepth.containsKey(depth)) {
        countsByDepth[depth] = 0;
      }

      print('🌳 GraphService: Adding node "$word" at depth $depth with ID "$nodeId"');

      // Add node with proper structure (like JavaScript componentsBfs elements.nodes.push)
      result.nodes.add(
        GraphNode(
          character: nodeId, // Use the full path as character ID (like JavaScript id: curr.path.join(''))
          level:
              word.isNotEmpty && _hanziGraphData.containsKey(word)
                  ? (_hanziGraphData[word]?['node']?['level'] as int? ?? 6)
                  : 6, // Use level from hanzi data or default to 6
          type: depth == 0 ? 'center' : 'component',
          depth: depth,
          treeRank: countsByDepth[depth]!, // Like JavaScript countsByDepth[curr.path.length - 1]++
          path: List<String>.from(path), // Store the actual path for navigation
        ),
      );

      // Increment counter for this depth
      countsByDepth[depth] = countsByDepth[depth]! + 1;

      // Add components if they exist (like JavaScript for (const component of window.components[curr.word].components))
      if (componentsData.containsKey(word)) {
        final componentsList = componentsData[word]?['components'] as List?;
        if (componentsList != null && componentsList.isNotEmpty) {
          print('🌳 GraphService: Processing ${componentsList.length} components for "$word": $componentsList');

          for (final component in componentsList) {
            final componentStr = component.toString();
            final newPath = [...path, componentStr];
            final targetId = newPath.join(''); // Like JavaScript: curr.path.join('') + component

            print('🌳 GraphService: Adding edge from "$nodeId" to "$targetId"');

            // Add edge (like JavaScript elements.edges.push)
            result.edges.add(
              GraphEdge(
                id: '_edge$nodeId$componentStr', // Like JavaScript: '_edge' + curr.path.join('') + component
                source: nodeId,
                target: targetId,
                level: 1,
                words: [],
                displayWord: '',
              ),
            );

            // Add component to queue for processing (like JavaScript queue.push)
            queue.add({'word': componentStr, 'path': newPath});
          }
        } else {
          print('🌳 GraphService: No components found for "$word"');
        }
      } else {
        print('🌳 GraphService: No component data for "$word"');
      }
    }

    print('✅ GraphService: Component tree built - ${result.nodes.length} nodes, ${result.edges.length} edges');
    print('   Nodes by depth: $countsByDepth');

    // Debug output to match JavaScript structure
    for (final node in result.nodes) {
      print(
        '   Node: ${node.character} (word: ${node.path?.last ?? 'unknown'}, depth: ${node.depth}, treeRank: ${node.treeRank})',
      );
    }

    return result;
  }

  /// Build graph from frequency list (equivalent to buildGraphFromFrequencyList in graph-functions.js)
  /// This is used for creating graph data from scratch, but we prefer using prebuilt graph.json
  Map<String, dynamic> buildGraphFromFrequencyList(List<String> freqs) {
    Map<String, dynamic> graph = {};
    int currentLevel = 0;
    int maxForCurrentLevel = ranks[currentLevel];

    for (int i = 0; i < freqs.length; i++) {
      if (i > maxForCurrentLevel) {
        currentLevel++;
        if (currentLevel >= ranks.length) {
          currentLevel = ranks.length - 1;
        }
        maxForCurrentLevel = ranks[currentLevel];
      }

      final word = freqs[i];

      // First, ensure all characters in this word are in the graph with current level
      for (int j = 0; j < word.length; j++) {
        final character = word[j];
        if (!graph.containsKey(character)) {
          graph[character] = {
            'node': {
              'level': currentLevel + 1, // Avoid zero index
            },
            'edges': <String, dynamic>{},
          };
        }
      }

      // Create edges between all characters in the word
      for (int j = 0; j < word.length; j++) {
        final outerCharacter = word[j];
        for (int k = 0; k < word.length; k++) {
          final character = word[k];
          if (j == k) continue;

          final edges = graph[character]['edges'] as Map<String, dynamic>;

          if (!edges.containsKey(outerCharacter) && edges.length < maxEdges) {
            edges[outerCharacter] = {'level': currentLevel + 1, 'words': <String>[]};
          }

          if (edges.containsKey(outerCharacter)) {
            final edgeData = edges[outerCharacter] as Map<String, dynamic>;
            final words = edgeData['words'] as List<String>;

            if (words.length < maxWordsPerEdge && !words.contains(word)) {
              if (i < maxIndexForMultipleWordsOnEdge || words.isEmpty) {
                words.add(word);
              }
            }
          }
        }
      }
    }

    return graph;
  }
}

/// Simple cosine function for positioning
double cos(double radians) {
  // Simplified cosine approximation
  final x = radians % (2 * 3.14159);
  if (x < 3.14159 / 2) {
    return 1 - (x * x) / 2;
  } else if (x < 3.14159) {
    final y = x - 3.14159 / 2;
    return -(1 - (y * y) / 2);
  } else if (x < 3 * 3.14159 / 2) {
    final y = x - 3.14159;
    return -(1 - (y * y) / 2);
  } else {
    final y = x - 3 * 3.14159 / 2;
    return 1 - (y * y) / 2;
  }
}

/// Simple sine function for positioning
double sin(double radians) {
  return cos(radians - 3.14159 / 2);
}
