/// Graph node model
class GraphNode {
  final String character;
  final String type;
  final double x;
  final double y;
  final int frequency;
  final Map<String, dynamic>? data;

  const GraphNode({
    required this.character,
    required this.type,
    required this.x,
    required this.y,
    required this.frequency,
    this.data,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is GraphNode && runtimeType == other.runtimeType && character == other.character;

  @override
  int get hashCode => character.hashCode;
}

/// Graph edge model
class GraphEdge {
  final String source;
  final String target;
  final String type;
  final int weight;
  final Map<String, dynamic>? data;

  const GraphEdge({required this.source, required this.target, required this.type, required this.weight, this.data});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphEdge && runtimeType == other.runtimeType && source == other.source && target == other.target;

  @override
  int get hashCode => Object.hash(source, target);
}

/// Complete graph data model
class GraphData {
  final String centerCharacter;
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final String type; // 'graph' or 'components'

  const GraphData({required this.centerCharacter, required this.nodes, required this.edges, required this.type});

  /// Get node by character
  GraphNode? getNodeByCharacter(String character) {
    try {
      return nodes.firstWhere((node) => node.character == character);
    } catch (e) {
      return null;
    }
  }

  /// Get related characters (nodes that are not the center)
  List<String> getRelatedCharacters() {
    return nodes.where((node) => node.character != centerCharacter).map((node) => node.character).toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphData &&
          runtimeType == other.runtimeType &&
          centerCharacter == other.centerCharacter &&
          type == other.type;

  @override
  int get hashCode => Object.hash(centerCharacter, type);
}
