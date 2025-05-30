/// Model for graph visualization data
class GraphData {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final String centerCharacter;

  const GraphData({required this.nodes, required this.edges, required this.centerCharacter});

  factory GraphData.fromJson(Map<String, dynamic> json) {
    return GraphData(
      nodes: (json['nodes'] as List?)?.map((n) => GraphNode.fromJson(n)).toList() ?? [],
      edges: (json['edges'] as List?)?.map((e) => GraphEdge.fromJson(e)).toList() ?? [],
      centerCharacter: json['centerCharacter'] ?? '',
    );
  }
}

class GraphNode {
  final String character;
  final int level;
  final String type;
  final int? depth;
  final int? treeRank;
  final List<String>? path;

  const GraphNode({
    required this.character,
    required this.level,
    required this.type,
    this.depth,
    this.treeRank,
    this.path,
  });

  factory GraphNode.fromJson(Map<String, dynamic> json) {
    return GraphNode(
      character: json['character'] ?? '',
      level: json['level'] ?? 1,
      type: json['type'] ?? 'character',
      depth: json['depth'],
      treeRank: json['treeRank'],
      path: json['path'] != null ? List<String>.from(json['path']) : null,
    );
  }
}

class GraphEdge {
  final String id;
  final String source;
  final String target;
  final int level;
  final List<String> words;
  final String displayWord;

  const GraphEdge({
    required this.id,
    required this.source,
    required this.target,
    required this.level,
    required this.words,
    required this.displayWord,
  });

  factory GraphEdge.fromJson(Map<String, dynamic> json) {
    return GraphEdge(
      id: json['id'] ?? '',
      source: json['source'] ?? '',
      target: json['target'] ?? '',
      level: json['level'] ?? 1,
      words: json['words'] != null ? List<String>.from(json['words']) : [],
      displayWord: json['displayWord'] ?? '',
    );
  }
}
