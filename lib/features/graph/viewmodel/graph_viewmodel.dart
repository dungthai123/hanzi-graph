import '../../../core/base/base_view_model.dart';
import '../model/graph_model.dart';
import '../repository/graph_repository.dart';

/// View model for graph visualization operations
class GraphViewModel extends BaseViewModel {
  final GraphRepository _repository;

  GraphViewModel(this._repository);

  // State
  GraphData? _currentGraph;
  String _centerCharacter = '';
  bool _showGraph = true;
  String _graphMode = 'graph'; // 'graph' or 'components'

  // Getters
  GraphData? get currentGraph => _currentGraph;
  String get centerCharacter => _centerCharacter;
  bool get showGraph => _showGraph;
  String get graphMode => _graphMode;

  /// Generate graph for a character using real frequency data
  Future<void> generateGraph(String character) async {
    if (character.isEmpty) return;

    _centerCharacter = character;
    _graphMode = 'graph';

    await handleAsyncOperation(() async {
      _currentGraph = await _repository.generateGraph(character);
      return _currentGraph;
    });
  }

  /// Generate components tree for a character
  Future<void> generateComponentsTree(String character) async {
    if (character.isEmpty) return;

    _centerCharacter = character;
    _graphMode = 'components';

    await handleAsyncOperation(() async {
      _currentGraph = await _repository.buildComponentTree(character);
      return _currentGraph;
    });
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
    return _currentGraph?.getNodeByCharacter(character);
  }

  /// Get related characters for current center
  List<String> getRelatedCharacters() {
    return _currentGraph?.getRelatedCharacters() ?? [];
  }

  /// Switch between graph and components mode
  Future<void> switchGraphMode(String mode) async {
    if (mode == 'components' && _centerCharacter.isNotEmpty) {
      await generateComponentsTree(_centerCharacter);
    } else if (mode == 'graph' && _centerCharacter.isNotEmpty) {
      await generateGraph(_centerCharacter);
    }
  }
}
