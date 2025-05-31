import 'dart:math' as math;
import '../model/graph_model.dart';

/// Data source for graph operations
class GraphDataSource {
  final Map<String, dynamic> _hanziData;

  GraphDataSource({required Map<String, dynamic> hanziData}) : _hanziData = hanziData;

  /// Generate graph for a character
  Future<GraphData> generateGraph(String character) async {
    try {
      final nodes = <GraphNode>[];
      final edges = <GraphEdge>[];

      // Add center node
      nodes.add(
        GraphNode(character: character, type: 'center', x: 0, y: 0, frequency: _getCharacterFrequency(character)),
      );

      // Get related characters from hanzi data
      final relatedChars = _getRelatedCharacters(character);

      // Add related nodes in a circle around center
      for (int i = 0; i < relatedChars.length; i++) {
        final angle = (i / relatedChars.length) * 2 * math.pi;
        final radius = 150.0;

        nodes.add(
          GraphNode(
            character: relatedChars[i],
            type: 'related',
            x: radius * math.cos(angle),
            y: radius * math.sin(angle),
            frequency: _getCharacterFrequency(relatedChars[i]),
          ),
        );

        // Add edge from center to related character
        edges.add(
          GraphEdge(
            source: character,
            target: relatedChars[i],
            type: 'similarity',
            weight: _calculateWeight(character, relatedChars[i]),
          ),
        );
      }

      return GraphData(centerCharacter: character, nodes: nodes, edges: edges, type: 'graph');
    } catch (e) {
      throw Exception('Failed to generate graph for $character: $e');
    }
  }

  /// Build component tree for a character
  Future<GraphData> buildComponentTree(String character, Map<String, dynamic> componentsData) async {
    try {
      final nodes = <GraphNode>[];
      final edges = <GraphEdge>[];

      // Add center node
      nodes.add(
        GraphNode(character: character, type: 'center', x: 0, y: 0, frequency: _getCharacterFrequency(character)),
      );

      // Get components from data
      final componentData = componentsData[character];
      if (componentData != null && componentData is Map<String, dynamic>) {
        final components = componentData['components'] as List? ?? [];

        // Add component nodes
        for (int i = 0; i < components.length; i++) {
          final component = components[i].toString();
          final angle = (i / components.length) * 2 * math.pi;
          final radius = 120.0;

          nodes.add(
            GraphNode(
              character: component,
              type: 'component',
              x: radius * math.cos(angle),
              y: radius * math.sin(angle),
              frequency: _getCharacterFrequency(component),
            ),
          );

          edges.add(GraphEdge(source: character, target: component, type: 'component', weight: 1));
        }
      }

      return GraphData(centerCharacter: character, nodes: nodes, edges: edges, type: 'components');
    } catch (e) {
      throw Exception('Failed to build component tree for $character: $e');
    }
  }

  /// Get character frequency from hanzi data
  int _getCharacterFrequency(String character) {
    final data = _hanziData[character];
    if (data is Map<String, dynamic>) {
      return data['frequency'] as int? ?? 1000;
    }
    return 1000; // Default frequency
  }

  /// Get related characters (simplified - in real implementation this would use ML/similarity algorithms)
  List<String> _getRelatedCharacters(String character) {
    // This is a simplified implementation
    // In the real app, this would use frequency data, semantic similarity, etc.
    final related = <String>[];

    // Get some characters from hanzi data as examples
    final allChars = _hanziData.keys.take(10).toList();
    for (final char in allChars) {
      if (char != character && related.length < 8) {
        related.add(char);
      }
    }

    return related;
  }

  /// Calculate edge weight between characters
  int _calculateWeight(String char1, String char2) {
    // Simplified weight calculation
    return 1;
  }
}
