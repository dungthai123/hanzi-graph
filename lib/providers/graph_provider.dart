import 'package:flutter/material.dart';
import '../models/graph_data.dart';
import '../services/graph_service.dart';
import '../services/data_service.dart';
import '../providers/data_provider.dart';

/// Graph provider for managing graph visualization state
class GraphProvider extends ChangeNotifier {
  GraphService? _graphService;
  DataService? _dataService;
  DataProvider? _dataProvider;

  GraphData? _currentGraph;
  String _centerCharacter = '';
  bool _isGeneratingGraph = false;
  bool _showGraph = true;
  String _graphMode = 'graph'; // 'graph' or 'components'

  // Getters
  GraphData? get currentGraph => _currentGraph;
  String get centerCharacter => _centerCharacter;
  bool get isGeneratingGraph => _isGeneratingGraph;
  bool get showGraph => _showGraph;
  String get graphMode => _graphMode;

  /// Initialize with graph service and data service
  void initialize(GraphService graphService, DataService dataService, DataProvider dataProvider) {
    _graphService = graphService;
    _dataService = dataService;
    _dataProvider = dataProvider;
  }

  /// Generate graph for a character using real frequency data
  Future<void> generateGraph(String character) async {
    print('🕸️ GraphProvider: Starting graph generation for "$character"');

    if (_graphService == null || _dataService == null || character.isEmpty) {
      print('❌ GraphProvider: Cannot generate graph - missing services or empty character');
      print('   GraphService: ${_graphService != null ? "✅" : "❌"}');
      print('   DataService: ${_dataService != null ? "✅" : "❌"}');
      print('   Character: "$character"');
      return;
    }

    _centerCharacter = character;
    _isGeneratingGraph = true;
    _graphMode = 'graph';
    print('🕸️ GraphProvider: State updated, notifying listeners...');
    notifyListeners();

    try {
      print('🕸️ GraphProvider: Calling GraphService.generateGraph...');
      // Generate the graph using the preloaded data
      final graph = await _graphService!.generateGraph(character);
      _currentGraph = graph;
      _isGeneratingGraph = false;

      print('✅ GraphProvider: Graph generated successfully!');
      print('   Center: "${graph.centerCharacter}"');
      print('   Nodes: ${graph.nodes.length} (${graph.nodes.map((n) => n.character).join(", ")})');
      print('   Edges: ${graph.edges.length}');

      notifyListeners();
    } catch (e) {
      _isGeneratingGraph = false;
      print('❌ GraphProvider: Graph generation error: $e');
      notifyListeners();
    }
  }

  /// Generate components tree for a character
  Future<void> generateComponentsTree(String character) async {
    if (_graphService == null || _dataService == null || character.isEmpty) return;

    print('🌳 GraphProvider: Starting component tree generation for "$character"');

    _centerCharacter = character;
    _isGeneratingGraph = true;
    _graphMode = 'components';
    notifyListeners();

    try {
      // Get the real components data from the loaded JSON
      final componentsData = _getAllComponentsData();
      print('🌳 GraphProvider: Using real components data with ${componentsData.keys.length} entries');

      final graph = _graphService!.buildComponentTree(character, componentsData);
      _currentGraph = graph;
      _isGeneratingGraph = false;
      notifyListeners();
      print('✅ Components tree generated for "$character"');
    } catch (e) {
      _isGeneratingGraph = false;
      notifyListeners();
      print('❌ Components tree generation error: $e');
    }
  }

  /// Get all components data from the DataService
  Map<String, dynamic> _getAllComponentsData() {
    // Access the components data that was loaded by the AppInitializer
    try {
      // Get the raw components data directly
      final componentsData = _dataProvider?.getAllComponentsData() ?? {};
      print('🌳 GraphProvider: Retrieved components data with ${componentsData.keys.length} entries');
      return componentsData;
    } catch (e) {
      print('❌ GraphProvider: Error getting components data: $e');
      return {};
    }
  }

  /// Update graph data
  void updateGraph(GraphData graph) {
    _currentGraph = graph;
    notifyListeners();
  }

  /// Clear current graph
  void clearGraph() {
    _currentGraph = null;
    _centerCharacter = '';
    notifyListeners();
  }

  /// Toggle graph visibility
  void toggleGraphVisibility() {
    _showGraph = !_showGraph;
    notifyListeners();
  }

  /// Show graph
  void showGraphView() {
    _showGraph = true;
    notifyListeners();
  }

  /// Hide graph
  void hideGraphView() {
    _showGraph = false;
    notifyListeners();
  }

  /// Get node by character
  GraphNode? getNodeByCharacter(String character) {
    if (_currentGraph == null) return null;

    try {
      return _currentGraph!.nodes.firstWhere((node) => node.character == character);
    } catch (e) {
      return null;
    }
  }

  /// Get related characters for current center
  List<String> getRelatedCharacters() {
    if (_currentGraph == null) return [];

    return _currentGraph!.nodes.where((node) => node.type == 'related').map((node) => node.character).toList();
  }

  /// Switch between graph and components mode
  void switchGraphMode(String mode) {
    if (mode == 'components' && _centerCharacter.isNotEmpty) {
      generateComponentsTree(_centerCharacter);
    } else if (mode == 'graph' && _centerCharacter.isNotEmpty) {
      generateGraph(_centerCharacter);
    }
  }

  /// Add character to current path (equivalent to JavaScript currentPath.push)
  void addToCurrentPath(String character) {
    // In the JavaScript version, this tracks the navigation path
    print('Added to current path: $character');
    notifyListeners();
  }
}
