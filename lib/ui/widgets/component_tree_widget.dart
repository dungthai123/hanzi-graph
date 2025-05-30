import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/graph_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/graph_data.dart';
import 'dart:math' as math;

/// Component Tree Visualization Widget
/// Equivalent to the JavaScript buildComponentTree functionality using cytoscape
/// Transpiled from components-demo.js and graph.js
class ComponentTreeWidget extends StatefulWidget {
  final String? initialCharacter;
  final Function(String)? onCharacterTap;

  const ComponentTreeWidget({super.key, this.initialCharacter, this.onCharacterTap});

  @override
  State<ComponentTreeWidget> createState() => _ComponentTreeWidgetState();
}

class _ComponentTreeWidgetState extends State<ComponentTreeWidget> {
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  String? _currentCharacter;

  @override
  void initState() {
    super.initState();
    _currentCharacter = widget.initialCharacter;

    if (_currentCharacter != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final graphProvider = context.read<GraphProvider>();
        graphProvider.generateComponentsTree(_currentCharacter!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GraphProvider>(
      builder: (context, graphProvider, child) {
        if (graphProvider.isGeneratingGraph) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Building component tree...')],
            ),
          );
        }

        final graph = graphProvider.currentGraph;
        if (graph == null || graph.nodes.isEmpty || graphProvider.graphMode != 'components') {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_tree, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('No component tree to display', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                const SizedBox(height: 8),
                if (_currentCharacter == null)
                  Text(
                    'Search for a character to see its component breakdown',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              // Component tree visualization
              Positioned.fill(
                child: GestureDetector(
                  onScaleUpdate: (details) {
                    setState(() {
                      _scale = (_scale * details.scale).clamp(0.5, 3.0);
                      _offset += details.focalPointDelta;
                    });
                  },
                  onTapDown: (details) {
                    _handleTap(context, details.localPosition, graph);
                  },
                  child: Transform(
                    transform:
                        Matrix4.identity()
                          ..translate(_offset.dx, _offset.dy)
                          ..scale(_scale),
                    child: Consumer<DataProvider>(
                      builder: (context, dataProvider, child) {
                        return CustomPaint(
                          painter: ComponentTreePainter(graph: graph, dataProvider: dataProvider),
                          size: Size.infinite,
                        );
                      },
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
                    // Reset view button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.center_focus_strong),
                        onPressed: () {
                          setState(() {
                            _scale = 1.0;
                            _offset = Offset.zero;
                          });
                        },
                        tooltip: 'Reset view',
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Zoom controls
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.zoom_in),
                            onPressed: () {
                              setState(() {
                                _scale = (_scale * 1.2).clamp(0.5, 3.0);
                              });
                            },
                            tooltip: 'Zoom in',
                          ),
                          IconButton(
                            icon: const Icon(Icons.zoom_out),
                            onPressed: () {
                              setState(() {
                                _scale = (_scale / 1.2).clamp(0.5, 3.0);
                              });
                            },
                            tooltip: 'Zoom out',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Character info header
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.account_tree, color: Theme.of(context).primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Components of: ${graph.centerCharacter}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Handle tap on component tree - detect node taps
  void _handleTap(BuildContext context, Offset localPosition, GraphData graph) {
    try {
      final adjustedPosition = Offset(
        (localPosition.dx - _offset.dx) / _scale,
        (localPosition.dy - _offset.dy) / _scale,
      );

      final painter = ComponentTreePainter(graph: graph, dataProvider: context.read<DataProvider>());
      final contextSize = context.size ?? const Size(400, 400);
      final positions = painter.calculateTreeLayout(contextSize);

      // Check if tap hits a node
      for (final node in graph.nodes) {
        final nodePos = positions[node.character];
        if (nodePos != null) {
          final distance = (adjustedPosition - nodePos).distance;
          if (distance <= 30.0) {
            // Node tap detected - equivalent to JavaScript cy.on('tap', 'node')
            _onNodeTap(context, node.character);
            return;
          }
        }
      }
    } catch (e) {
      // Handle tap error silently in production
      debugPrint('Error handling component tree tap: $e');
    }
  }

  /// Handle node tap - equivalent to JavaScript node tap handler
  void _onNodeTap(BuildContext context, String character) {
    try {
      setState(() {
        _currentCharacter = character;
      });

      // Update component tree (like JavaScript buildComponentTree)
      final graphProvider = context.read<GraphProvider>();
      graphProvider.generateComponentsTree(character);

      // Notify parent widget (equivalent to renderComponents call in JS)
      widget.onCharacterTap?.call(character);

      debugPrint('Component tree node tapped: $character');
    } catch (e) {
      debugPrint('Error handling component tree node tap: $e');
    }
  }
}

/// Custom painter for component tree visualization
/// Equivalent to cytoscape rendering with breadth-first layout
/// Transpiled from components-demo.js getStylesheet() and cytoscape configuration
class ComponentTreePainter extends CustomPainter {
  final GraphData graph;
  final DataProvider dataProvider;

  // Tone colors from JavaScript toneColor function
  static const List<Color> toneColors = [
    Color(0xFFff635f), // Tone 1 - Red
    Color(0xFF7aeb34), // Tone 2 - Green
    Color(0xFFde68ee), // Tone 3 - Purple
    Color(0xFF68aaee), // Tone 4 - Blue
    Color(0xFF888888), // Neutral tone - Gray
  ];

  // Pinyin initials and finals for sophisticated parsing
  // Based on JavaScript pinyinInitials and pinyinFinals arrays
  static const List<String> pinyinInitials = [
    'zh',
    'ch',
    'sh',
    'b',
    'p',
    'm',
    'f',
    'd',
    't',
    'n',
    'l',
    'g',
    'k',
    'h',
    'z',
    'c',
    's',
    'r',
    'j',
    'q',
    'x',
  ];

  static const List<String> pinyinFinals = [
    'uang',
    'iang',
    'iong',
    'ueng',
    'uai',
    'uan',
    'üan',
    'iao',
    'ian',
    'ang',
    'eng',
    'ong',
    'ai',
    'ei',
    'ao',
    'ou',
    'an',
    'en',
    'ua',
    'uo',
    'ui',
    'un',
    'ia',
    'ie',
    'iu',
    'in',
    'ing',
    'üe',
    'ün',
    'a',
    'o',
    'e',
    'u',
    'i',
    'ü',
  ];

  ComponentTreePainter({required this.graph, required this.dataProvider});

  @override
  void paint(Canvas canvas, Size size) {
    try {
      final paint =
          Paint()
            ..style = PaintingStyle.fill
            ..strokeWidth = 3.0;

      final textPainter = TextPainter(textDirection: TextDirection.ltr);

      // Calculate tree layout positions (like JavaScript bfsLayout)
      final positions = calculateTreeLayout(size);

      // Draw edges first (behind nodes) with arrows and labels
      for (final edge in graph.edges) {
        final sourcePos = positions[edge.source];
        final targetPos = positions[edge.target];

        if (sourcePos != null && targetPos != null) {
          _drawTreeEdge(canvas, paint, textPainter, edge, sourcePos, targetPos);
        }
      }

      // Draw nodes
      for (final node in graph.nodes) {
        final position = positions[node.character];
        if (position != null) {
          _drawTreeNode(canvas, paint, textPainter, node, position);
        }
      }
    } catch (e) {
      debugPrint('Error painting component tree: $e');
      // Draw fallback message
      _drawFallbackMessage(canvas, size);
    }
  }

  /// Calculate tree layout positions - equivalent to JavaScript bfsLayout
  /// Uses breadthfirst layout with padding and spacing like cytoscape
  Map<String, Offset> calculateTreeLayout(Size size) {
    final positions = <String, Offset>{};

    if (graph.nodes.isEmpty) return positions;

    // Group nodes by depth (like JavaScript componentsBfs structure)
    final nodesByDepth = <int, List<GraphNode>>{};

    for (final node in graph.nodes) {
      final depth = node.depth ?? 0;
      nodesByDepth.putIfAbsent(depth, () => []).add(node);
    }

    final maxDepth = nodesByDepth.keys.reduce(math.max);

    // Apply padding and spacing factor like JavaScript bfsLayout
    const padding = 6.0;
    const spacingFactor = 0.85;

    final levelHeight = (size.height - padding * 2) / (maxDepth + 1) * spacingFactor;

    // Layout each depth level
    for (final entry in nodesByDepth.entries) {
      final depth = entry.key;
      final nodes = entry.value;

      // Sort by treeRank for consistent positioning (like JavaScript)
      nodes.sort((a, b) => (a.treeRank ?? 0).compareTo(b.treeRank ?? 0));

      final y = padding + levelHeight * depth + levelHeight / 2;
      final levelWidth = (size.width - padding * 2) / (nodes.length + 1);

      for (int i = 0; i < nodes.length; i++) {
        final x = padding + levelWidth * (i + 1);
        positions[nodes[i].character] = Offset(x, y);
      }
    }

    return positions;
  }

  /// Draw tree node - styled like JavaScript cytoscape nodes
  /// Equivalent to JavaScript node style configuration
  void _drawTreeNode(Canvas canvas, Paint paint, TextPainter textPainter, GraphNode node, Offset position) {
    final nodeRadius = 30.0;
    final isRoot = node.type == 'center';

    // Node background color using tone-based coloring like JavaScript
    final nodeColor =
        isRoot
            ? const Color(0xFF2196F3) // Blue for root
            : _getToneColorForCharacter(node.character);

    paint.color = nodeColor;
    canvas.drawCircle(position, nodeRadius, paint);

    // Node border
    paint
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isRoot ? 3.0 : 2.0;
    canvas.drawCircle(position, nodeRadius, paint);

    // Character text (equivalent to JavaScript 'label': 'data(word)')
    textPainter.text = TextSpan(
      text: node.character,
      style: TextStyle(
        color: _getTextColor(nodeColor), // Like JavaScript makeLegible function
        fontSize: isRoot ? 24 : 20, // Like JavaScript 'font-size': '20px'
        fontWeight: isRoot ? FontWeight.bold : FontWeight.w500,
      ),
    );
    textPainter.layout();

    final textOffset = Offset(position.dx - textPainter.width / 2, position.dy - textPainter.height / 2);
    textPainter.paint(canvas, textOffset);

    paint.style = PaintingStyle.fill;
  }

  /// Draw tree edge with arrow and label - like JavaScript edge styling
  /// Equivalent to JavaScript edge style configuration with edgeLabel function
  void _drawTreeEdge(Canvas canvas, Paint paint, TextPainter textPainter, GraphEdge edge, Offset start, Offset end) {
    // Edge line (equivalent to JavaScript edge style)
    paint
      ..color =
          Colors.grey[600]! // Like JavaScript 'line-color': '#121212'
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0; // Like JavaScript 'width': '3px'

    canvas.drawLine(start, end, paint);

    // Arrow pointing toward target (like JavaScript 'target-arrow-shape': 'triangle')
    _drawArrow(canvas, paint, start, end);

    // Edge label with pinyin relationship (equivalent to JavaScript edgeLabel function)
    final edgeLabel = _getEdgeLabel(edge);
    if (edgeLabel.isNotEmpty) {
      _drawEdgeLabel(canvas, textPainter, edgeLabel, start, end);
    }
  }

  /// Draw arrow on edge - equivalent to JavaScript target-arrow-shape
  void _drawArrow(Canvas canvas, Paint paint, Offset start, Offset end) {
    const arrowSize = 10.0;
    final direction = (end - start).direction;

    // Calculate arrow tip position (slightly before the target node)
    final arrowTip = end - Offset.fromDirection(direction, 30 + arrowSize);

    final arrowLeft = arrowTip + Offset.fromDirection(direction + 2.8, arrowSize);
    final arrowRight = arrowTip + Offset.fromDirection(direction - 2.8, arrowSize);

    final arrowPath =
        Path()
          ..moveTo(arrowTip.dx, arrowTip.dy)
          ..lineTo(arrowLeft.dx, arrowLeft.dy)
          ..lineTo(arrowRight.dx, arrowRight.dy)
          ..close();

    paint
      ..color =
          Colors.grey[700]! // Like JavaScript 'target-arrow-color'
      ..style = PaintingStyle.fill;
    canvas.drawPath(arrowPath, paint);
  }

  /// Draw edge label - equivalent to JavaScript edge label styling
  void _drawEdgeLabel(Canvas canvas, TextPainter textPainter, String label, Offset start, Offset end) {
    final midPoint = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);

    // Text background (like JavaScript text-background styling)
    textPainter.text = TextSpan(
      text: label,
      style: const TextStyle(
        color: Colors.white, // Like JavaScript 'color': '#fff'
        fontSize: 12, // Like JavaScript 'font-size': '12px'
        fontWeight: FontWeight.w500,
      ),
    );
    textPainter.layout();

    // Background rectangle (like JavaScript text-background)
    final backgroundRect = Rect.fromCenter(
      center: midPoint,
      width: textPainter.width + 4, // Like JavaScript 'text-background-padding': '2px'
      height: textPainter.height + 4,
    );

    final backgroundPaint =
        Paint()
          ..color =
              Colors
                  .black // Like JavaScript 'text-background-color': '#000'
          ..style = PaintingStyle.fill;

    canvas.drawRect(backgroundRect, backgroundPaint);

    // Draw text
    final textOffset = Offset(midPoint.dx - textPainter.width / 2, midPoint.dy - textPainter.height / 2);
    textPainter.paint(canvas, textOffset);
  }

  /// Get edge label - equivalent to JavaScript edgeLabel function
  /// Enhanced with sophisticated pinyin parsing like components-demo.js
  String _getEdgeLabel(GraphEdge edge) {
    try {
      // Extract source and target characters from edge IDs (like JavaScript)
      final sourceChar = _getCharacterFromEdgeId(edge.source);
      final targetChar = _getCharacterFromEdgeId(edge.target);

      if (sourceChar.isEmpty || targetChar.isEmpty) return '';

      final sourceDef = dataProvider.getDefinition(sourceChar);
      final targetDef = dataProvider.getDefinition(targetChar);

      if (sourceDef == null || targetDef == null || sourceDef.pinyin.isEmpty || targetDef.pinyin.isEmpty) return '';

      // Enhanced pinyin relationship finding (like JavaScript edgeLabel function)
      final sourcePinyin = _trimTone(sourceDef.pinyin.toLowerCase());
      final targetPinyin = _trimTone(targetDef.pinyin.toLowerCase());

      // First pass: check for exact matches (minus tone, already expressed through color)
      if (sourcePinyin == targetPinyin) {
        return targetPinyin;
      }

      // Second pass: parse pinyin and check for initial/final matches
      final sourceParsed = _parsePinyin(sourcePinyin);
      final targetParsed = _parsePinyin(targetPinyin);

      final sourceInitial = sourceParsed['initial'];
      final sourceFinal = sourceParsed['final'];
      final targetInitial = targetParsed['initial'];
      final targetFinal = targetParsed['final'];

      // Check for initial matches
      if (sourceInitial != null && targetInitial != null && sourceInitial == targetInitial) {
        return '$targetInitial-';
      }

      // Check for final matches
      if (sourceFinal != null && targetFinal != null && sourceFinal == targetFinal) {
        return '-$targetFinal';
      }

      return '';
    } catch (e) {
      return '';
    }
  }

  /// Parse pinyin into initial and final components
  /// Equivalent to JavaScript parsePinyin function from components-demo.js
  Map<String, String?> _parsePinyin(String pinyin) {
    if (pinyin.isEmpty) return {'initial': null, 'final': null};

    // Find initial (longest match first, like JavaScript sort)
    String? initial;
    for (final candidate in pinyinInitials) {
      if (pinyin.startsWith(candidate)) {
        initial = candidate;
        break;
      }
    }

    // Find final (what remains after initial)
    final remaining = initial != null ? pinyin.substring(initial.length) : pinyin;

    // Find final (longest match first)
    String? final_;
    for (final candidate in pinyinFinals) {
      if (remaining.endsWith(candidate)) {
        final_ = candidate;
        break;
      }
    }

    return {'initial': initial, 'final': final_};
  }

  /// Extract character from edge ID (handles path-based IDs from JavaScript)
  String _getCharacterFromEdgeId(String edgeId) {
    if (edgeId.isEmpty) return '';
    return edgeId[edgeId.length - 1];
  }

  /// Trim tone from pinyin - equivalent to JavaScript trimTone function
  String _trimTone(String pinyin) {
    if (pinyin.isEmpty) return pinyin;
    final lastChar = pinyin[pinyin.length - 1];
    if ('12345'.contains(lastChar)) {
      return pinyin.substring(0, pinyin.length - 1);
    }
    return pinyin;
  }

  /// Get tone-based color for character - equivalent to JavaScript toneColor function
  Color _getToneColorForCharacter(String character) {
    try {
      final definition = dataProvider.getDefinition(character);
      if (definition != null && definition.pinyin.isNotEmpty) {
        final tone = _getTone(definition.pinyin);
        return _getToneColor(tone);
      }
    } catch (e) {
      // Fallback to hash-based coloring
    }

    // Fallback: hash-based tone assignment
    final hash = character.codeUnitAt(0) % 5;
    return toneColors[hash];
  }

  /// Get tone from pinyin - equivalent to JavaScript getTone function
  String _getTone(String pinyin) {
    if (pinyin.isEmpty) return '5';
    final lastChar = pinyin[pinyin.length - 1];
    if ('1234'.contains(lastChar)) {
      return lastChar;
    }
    return '5'; // Neutral tone
  }

  /// Get color for tone - equivalent to JavaScript toneColor function
  Color _getToneColor(String tone) {
    switch (tone) {
      case '1':
        return const Color(0xFFff635f); // Red
      case '2':
        return const Color(0xFF7aeb34); // Green
      case '3':
        return const Color(0xFFde68ee); // Purple
      case '4':
        return const Color(0xFF68aaee); // Blue
      default:
        return const Color(0xFF888888); // Gray for neutral tone
    }
  }

  /// Get contrasting text color - equivalent to JavaScript makeLegible function
  Color _getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Draw fallback message on error
  void _drawFallbackMessage(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = const TextSpan(
      text: 'Component tree rendering error',
      style: TextStyle(color: Colors.red, fontSize: 16),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, size.height / 2 - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(ComponentTreePainter oldDelegate) {
    return oldDelegate.graph != graph || oldDelegate.dataProvider != dataProvider;
  }
}
