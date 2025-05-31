import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/graph_provider.dart';
import '../../providers/search_provider.dart';
import '../../models/graph_data.dart';
import 'dart:math' as math;

/// Graph visualization widget - equivalent to cytoscape functionality in graph.js
class GraphWidget extends StatefulWidget {
  const GraphWidget({super.key});

  @override
  State<GraphWidget> createState() => _GraphWidgetState();
}

class _GraphWidgetState extends State<GraphWidget> {
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  String _colorCodeMode = 'tones'; // 'tones' or 'frequency'

  @override
  Widget build(BuildContext context) {
    return Consumer<GraphProvider>(
      builder: (context, graphProvider, child) {
        if (graphProvider.isGeneratingGraph) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Generating graph...')],
            ),
          );
        }

        final graph = graphProvider.currentGraph;
        if (graph == null || graph.nodes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_tree, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('No graph to display', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                const SizedBox(height: 8),
                Text(
                  'Search for a character to see relationships',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              // Graph visualization
              Positioned.fill(
                child: GestureDetector(
                  onScaleUpdate: (details) {
                    setState(() {
                      _scale = (_scale * details.scale).clamp(0.5, 3.0);
                      _offset += details.focalPointDelta;
                    });
                  },
                  onTapDown: (details) {
                    // Handle node/edge taps
                    _handleTap(context, details.localPosition, graph);
                  },
                  child: Transform(
                    transform:
                        Matrix4.identity()
                          ..translate(_offset.dx, _offset.dy)
                          ..scale(_scale),
                    child: CustomPaint(
                      painter: GraphPainter(
                        graph: graph,
                        colorCodeMode: _colorCodeMode,
                        graphMode: graphProvider.graphMode,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),

              // Controls
              Positioned(
                top: 16,
                right: 16,
                child: Column(
                  children: [
                    // Zoom controls
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                _scale = (_scale * 1.2).clamp(0.5, 3.0);
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                _scale = (_scale / 1.2).clamp(0.5, 3.0);
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.center_focus_strong),
                            onPressed: () {
                              setState(() {
                                _scale = 1.0;
                                _offset = Offset.zero;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Mode toggle
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.account_tree,
                              color: graphProvider.graphMode == 'graph' ? Theme.of(context).primaryColor : Colors.grey,
                            ),
                            onPressed: () {
                              graphProvider.switchGraphMode('graph');
                            },
                            tooltip: 'Character relationships',
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.schema,
                              color:
                                  graphProvider.graphMode == 'components'
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey,
                            ),
                            onPressed: () {
                              graphProvider.switchGraphMode('components');
                            },
                            tooltip: 'Character components',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Color mode toggle (equivalent to JavaScript header logo click)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          _colorCodeMode == 'tones' ? Icons.palette : Icons.trending_up,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _colorCodeMode = _colorCodeMode == 'tones' ? 'frequency' : 'tones';
                          });
                        },
                        tooltip: _colorCodeMode == 'tones' ? 'Switch to frequency colors' : 'Switch to tone colors',
                      ),
                    ),
                  ],
                ),
              ),

              // Legend
              Positioned(bottom: 16, left: 16, child: _buildLegend(context, graphProvider.graphMode)),
            ],
          ),
        );
      },
    );
  }

  /// Handle tap on graph area - detect if node or edge was tapped
  void _handleTap(BuildContext context, Offset localPosition, GraphData graph) {
    try {
      final adjustedPosition = Offset(
        (localPosition.dx - _offset.dx) / _scale,
        (localPosition.dy - _offset.dy) / _scale,
      );

      final painter = GraphPainter(
        graph: graph,
        colorCodeMode: _colorCodeMode,
        graphMode: context.read<GraphProvider>().graphMode,
      );

      // Get layout positions with safe size fallback
      final contextSize = context.size ?? const Size(400, 400);
      final positions = painter.calculateLayout(contextSize);

      // Check if tap hits a node
      for (final node in graph.nodes) {
        final nodePos = positions[node.character];
        if (nodePos != null) {
          final distance = (adjustedPosition - nodePos).distance;
          if (distance <= 25.0) {
            // Node tap detected
            _onNodeTap(context, node);
            return;
          }
        }
      }

      // Check if tap hits an edge
      for (final edge in graph.edges) {
        final sourcePos = positions[edge.source];
        final targetPos = positions[edge.target];
        if (sourcePos != null && targetPos != null) {
          // Simple edge hit detection - check if point is near the line
          final midPoint = Offset((sourcePos.dx + targetPos.dx) / 2, (sourcePos.dy + targetPos.dy) / 2);
          final distance = (adjustedPosition - midPoint).distance;
          if (distance <= 15.0) {
            // Edge tap detected
            _onEdgeTap(context, edge);
            return;
          }
        }
      }
    } catch (e) {
      print('Error handling graph tap: $e');
      // Gracefully handle the error without crashing
    }
  }

  /// Handle node tap - equivalent to JavaScript nodeTapHandler
  void _onNodeTap(BuildContext context, GraphNode node) {
    try {
      final searchProvider = context.read<SearchProvider>();
      final graphProvider = context.read<GraphProvider>();

      // In components mode, use the actual character (like JavaScript buildComponentTree tap handler)
      final character =
          graphProvider.graphMode == 'components' && node.path != null && node.path!.isNotEmpty
              ? node
                  .path!
                  .last // Use the actual character from the path
              : node.character;

      if (graphProvider.graphMode == 'components') {
        // In components mode, just show the meaning like JavaScript renderComponents
        // Don't navigate to a new graph, just update the search selection
        searchProvider.selectCharacter(character);
        print('Components node tapped: $character (showing meaning only, no navigation)');
      } else {
        // In graph mode, navigate to new graph like JavaScript nodeTapHandler
        searchProvider.selectCharacter(character);
        graphProvider.generateGraph(character);

        // Add to current path (equivalent to JavaScript currentPath.push)
        graphProvider.addToCurrentPath(character);
        print('Graph node tapped: ${node.character} -> character: $character (navigating to new graph)');
      }
    } catch (e) {
      print('Error handling node tap: $e');
    }
  }

  /// Handle edge tap - equivalent to JavaScript edgeTapHandler
  void _onEdgeTap(BuildContext context, GraphEdge edge) {
    try {
      final searchProvider = context.read<SearchProvider>();
      final graphProvider = context.read<GraphProvider>();

      if (edge.words.isNotEmpty) {
        // Select the first word from the edge (like JavaScript)
        final word = edge.words.first;
        searchProvider.selectCharacter(word);
        graphProvider.generateGraph(word);

        print('Edge tapped: ${edge.source} -> ${edge.target}, word: $word');
      }
    } catch (e) {
      print('Error handling edge tap: $e');
    }
  }

  Widget _buildLegend(BuildContext context, String mode) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _colorCodeMode == 'frequency' ? 'Frequency' : (mode == 'components' ? 'Components' : 'Tones'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          if (_colorCodeMode == 'frequency' && mode == 'graph') ...[
            _buildLegendItem(GraphPainter.frequencyColors[0], 'Most frequent'),
            _buildLegendItem(GraphPainter.frequencyColors[1], 'Common'),
            _buildLegendItem(GraphPainter.frequencyColors[2], 'Moderate'),
            _buildLegendItem(GraphPainter.frequencyColors[3], 'Less common'),
            _buildLegendItem(GraphPainter.frequencyColors[4], 'Rare'),
            _buildLegendItem(GraphPainter.frequencyColors[5], 'Very rare'),
          ] else if (_colorCodeMode == 'tones' && mode == 'graph') ...[
            _buildLegendItem(GraphPainter.toneColors[0], 'Tone 1 (high)'),
            _buildLegendItem(GraphPainter.toneColors[1], 'Tone 2 (rising)'),
            _buildLegendItem(GraphPainter.toneColors[2], 'Tone 3 (falling-rising)'),
            _buildLegendItem(GraphPainter.toneColors[3], 'Tone 4 (falling)'),
            _buildLegendItem(GraphPainter.toneColors[4], 'Neutral tone'),
          ] else if (mode == 'components') ...[
            _buildLegendItem(Theme.of(context).primaryColor, 'Root character'),
            _buildLegendItem(Colors.grey[600]!, 'Components'),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}

/// Custom painter for graph visualization - equivalent to cytoscape rendering
class GraphPainter extends CustomPainter {
  final GraphData graph;
  final String colorCodeMode;
  final String graphMode;

  // Colors from JavaScript graph.js - frequency-based
  static const List<Color> frequencyColors = [
    Color(0xFFfc5c7d), // Level 1 - Most frequent
    Color(0xFFea6596), // Level 2
    Color(0xFFd56eaf), // Level 3
    Color(0xFFbb75c8), // Level 4
    Color(0xFF9b7ce1), // Level 5
    Color(0xFF6a82fb), // Level 6 - Least frequent
  ];

  // Tone colors based on Chinese tone system
  static const List<Color> toneColors = [
    Color(0xFFe74c3c), // Tone 1 - Red (high level)
    Color(0xFFf39c12), // Tone 2 - Orange (rising)
    Color(0xFF27ae60), // Tone 3 - Green (falling-rising)
    Color(0xFF3498db), // Tone 4 - Blue (falling)
    Color(0xFF95a5a6), // Neutral tone - Gray
  ];

  GraphPainter({required this.graph, required this.colorCodeMode, required this.graphMode});

  @override
  void paint(Canvas canvas, Size size) {
    try {
      final paint =
          Paint()
            ..style = PaintingStyle.fill
            ..strokeWidth = 2.0;

      final textPainter = TextPainter(textDirection: TextDirection.ltr);

      // Calculate layout positions
      final positions = calculateLayout(size);

      // Draw edges first (behind nodes)
      for (final edge in graph.edges) {
        final sourcePos = positions[edge.source];
        final targetPos = positions[edge.target];

        if (sourcePos != null && targetPos != null) {
          _drawEdge(canvas, paint, textPainter, edge, sourcePos, targetPos);
        }
      }

      // Draw nodes
      for (final node in graph.nodes) {
        final position = positions[node.character];
        if (position != null) {
          _drawNode(canvas, paint, textPainter, node, position);
        }
      }
    } catch (e) {
      print('Error painting graph: $e');
      // Draw a fallback message
      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = const TextSpan(
        text: 'Graph rendering error',
        style: TextStyle(color: Colors.red, fontSize: 16),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size.width / 2 - textPainter.width / 2, size.height / 2 - textPainter.height / 2),
      );
    }
  }

  /// Calculate layout positions - equivalent to cytoscape layouts
  Map<String, Offset> calculateLayout(Size size) {
    final positions = <String, Offset>{};
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    if (graph.nodes.isEmpty) return positions;

    if (graphMode == 'components') {
      // Components mode: breadthfirst tree layout (like JavaScript bfsLayout)
      _calculateTreeLayout(positions, size);
    } else {
      // Graph mode: force-directed or circular layout
      if (graph.nodes.length > 95) {
        // Grid layout for large graphs (like JavaScript layout function)
        _calculateGridLayout(positions, size);
      } else {
        // Force-directed circular layout for smaller graphs
        _calculateCircularLayout(positions, size);
      }
    }

    return positions;
  }

  /// Calculate breadth-first tree layout like JavaScript bfsLayout
  /// Equivalent to cytoscape breadthfirst layout with padding, spacingFactor, and directed: true
  void _calculateTreeLayout(Map<String, Offset> positions, Size size) {
    final nodesByDepth = <int, List<GraphNode>>{};

    // Group nodes by depth (like JavaScript componentsBfs structure)
    for (final node in graph.nodes) {
      final depth = node.depth ?? 0;
      nodesByDepth.putIfAbsent(depth, () => []).add(node);
    }

    if (nodesByDepth.isEmpty) return;

    // Apply padding and spacing factor like JavaScript bfsLayout
    const padding = 6.0;
    const spacingFactor = 0.85;

    final maxDepth = nodesByDepth.keys.reduce(math.max);
    final usableHeight = (size.height - padding * 2) * spacingFactor;
    final levelHeight = maxDepth > 0 ? usableHeight / maxDepth : usableHeight;

    for (final entry in nodesByDepth.entries) {
      final depth = entry.key;
      final nodes = entry.value;

      // Sort by treeRank for consistent positioning (like JavaScript depthSort)
      nodes.sort((a, b) => (a.treeRank ?? 0).compareTo(b.treeRank ?? 0));

      // Calculate Y position - root at top, components below
      final y = padding + (levelHeight * depth);

      // Calculate X positions with spacing
      final usableWidth = size.width - padding * 2;
      final nodeSpacing = nodes.length > 1 ? usableWidth / (nodes.length - 1) : 0;
      final startX = padding + (nodes.length == 1 ? usableWidth / 2 : 0);

      for (int i = 0; i < nodes.length; i++) {
        final x = nodes.length == 1 ? startX : padding + (i * nodeSpacing);
        positions[nodes[i].character] = Offset(x, y);
      }
    }
  }

  void _calculateGridLayout(Map<String, Offset> positions, Size size) {
    final cols = math.sqrt(graph.nodes.length).ceil();
    final cellWidth = size.width / cols;
    final cellHeight = size.height / (graph.nodes.length / cols).ceil();

    for (int i = 0; i < graph.nodes.length; i++) {
      final row = i ~/ cols;
      final col = i % cols;
      final x = (col + 0.5) * cellWidth;
      final y = (row + 0.5) * cellHeight;
      positions[graph.nodes[i].character] = Offset(x, y);
    }
  }

  void _calculateCircularLayout(Map<String, Offset> positions, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final centerNode = graph.nodes.firstWhere((node) => node.type == 'center', orElse: () => graph.nodes.first);

    positions[centerNode.character] = Offset(centerX, centerY);

    final relatedNodes = graph.nodes.where((node) => node.type == 'related').toList();
    if (relatedNodes.isNotEmpty) {
      final radius = math.min(size.width, size.height) * 0.3;

      for (int i = 0; i < relatedNodes.length; i++) {
        final angle = (i * 2 * math.pi) / relatedNodes.length;
        final x = centerX + radius * math.cos(angle);
        final y = centerY + radius * math.sin(angle);
        positions[relatedNodes[i].character] = Offset(x, y);
      }
    }

    // Position any remaining nodes
    final otherNodes = graph.nodes.where((node) => node.type != 'center' && node.type != 'related').toList();

    if (otherNodes.isNotEmpty) {
      final outerRadius = math.min(size.width, size.height) * 0.45;
      for (int i = 0; i < otherNodes.length; i++) {
        final angle = (i * 2 * math.pi) / otherNodes.length;
        final x = centerX + outerRadius * math.cos(angle);
        final y = centerY + outerRadius * math.sin(angle);
        positions[otherNodes[i].character] = Offset(x, y);
      }
    }
  }

  void _drawNode(Canvas canvas, Paint paint, TextPainter textPainter, GraphNode node, Offset position) {
    // Node background
    final nodeRadius = 25.0;
    final nodeColor = _getNodeColor(node);

    paint.color = nodeColor;
    canvas.drawCircle(position, nodeRadius, paint);

    // Node border
    paint
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(position, nodeRadius, paint);

    // Character text - use the actual character, not the full path
    final displayText =
        graphMode == 'components' && node.path != null && node.path!.isNotEmpty
            ? node
                .path!
                .last // Show the actual character, not the concatenated path
            : node.character;

    textPainter.text = TextSpan(
      text: displayText,
      style: TextStyle(color: _getTextColor(nodeColor), fontSize: 16, fontWeight: FontWeight.w500),
    );
    textPainter.layout();

    final textOffset = Offset(position.dx - textPainter.width / 2, position.dy - textPainter.height / 2);
    textPainter.paint(canvas, textOffset);

    paint.style = PaintingStyle.fill;
  }

  void _drawEdge(
    Canvas canvas,
    Paint paint,
    TextPainter textPainter,
    GraphEdge edge,
    Offset sourcePos,
    Offset targetPos,
  ) {
    try {
      // Edge line color
      Color edgeColor;
      if (colorCodeMode == 'frequency' && graphMode == 'graph') {
        // Use frequency-based edge coloring
        final level = edge.level.clamp(1, frequencyColors.length);
        edgeColor = frequencyColors[level - 1];
      } else {
        // Default gray color
        edgeColor = Colors.grey[600]!;
      }

      paint
        ..color = edgeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = graphMode == 'components' ? 3.0 : 1.5;

      canvas.drawLine(sourcePos, targetPos, paint);

      // Arrow for components mode (like JavaScript cytoscape target-arrow-shape: triangle)
      if (graphMode == 'components') {
        _drawArrow(canvas, paint, sourcePos, targetPos);
      }

      // Edge label (word) - don't show labels in components mode like JavaScript
      if (edge.displayWord.isNotEmpty && graphMode != 'components') {
        final midPoint = Offset((sourcePos.dx + targetPos.dx) / 2, (sourcePos.dy + targetPos.dy) / 2);

        textPainter.text = TextSpan(
          text: edge.displayWord,
          style: const TextStyle(color: Colors.black, fontSize: 10, backgroundColor: Colors.white),
        );
        textPainter.layout();

        // Draw background for text
        final labelRect = Rect.fromCenter(
          center: midPoint,
          width: textPainter.width + 4,
          height: textPainter.height + 2,
        );

        paint
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawRRect(RRect.fromRectAndRadius(labelRect, const Radius.circular(2)), paint);

        final labelOffset = Offset(midPoint.dx - textPainter.width / 2, midPoint.dy - textPainter.height / 2);
        textPainter.paint(canvas, labelOffset);
      }

      paint.style = PaintingStyle.fill;
    } catch (e) {
      print('Error drawing edge: $e');
      // Draw a simple fallback line
      paint
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawLine(sourcePos, targetPos, paint);
      paint.style = PaintingStyle.fill;
    }
  }

  /// Draw arrow for component edges (like JavaScript cytoscape arrow styling)
  void _drawArrow(Canvas canvas, Paint paint, Offset start, Offset end) {
    const arrowSize = 8.0;
    final direction = (end - start).direction;

    // Calculate arrow tip position (slightly before the target node)
    final arrowTip = end - Offset.fromDirection(direction, 25 + arrowSize);

    final arrowLeft = arrowTip + Offset.fromDirection(direction + 2.8, arrowSize);
    final arrowRight = arrowTip + Offset.fromDirection(direction - 2.8, arrowSize);

    final arrowPath =
        Path()
          ..moveTo(arrowTip.dx, arrowTip.dy)
          ..lineTo(arrowLeft.dx, arrowLeft.dy)
          ..lineTo(arrowRight.dx, arrowRight.dy)
          ..close();

    paint
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.fill;
    canvas.drawPath(arrowPath, paint);
  }

  Color _getNodeColor(GraphNode node) {
    if (graphMode == 'components') {
      // In components mode, root is blue, components are gray (like JavaScript)
      return node.type == 'center' ? const Color(0xFF2196F3) : Colors.grey[300]!;
    }

    if (colorCodeMode == 'tones') {
      // Simple tone detection - would need actual pinyin data for accuracy
      return _getToneColorForCharacter(node.character);
    } else {
      // Frequency-based coloring
      final level = node.level.clamp(1, frequencyColors.length);
      return frequencyColors[level - 1];
    }
  }

  Color _getToneColorForCharacter(String character) {
    // Simplified tone detection - in a real app, use pinyin data
    final hash = character.codeUnitAt(0) % 5;
    return toneColors[hash];
  }

  Color _getTextColor(Color backgroundColor) {
    // Simple luminance check
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint for interactivity
  }
}
