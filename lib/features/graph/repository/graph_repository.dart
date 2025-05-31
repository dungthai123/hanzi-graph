import '../datasource/graph_datasource.dart';
import '../model/graph_model.dart';

/// Repository for graph operations
class GraphRepository {
  final GraphDataSource _dataSource;
  final Map<String, dynamic> _componentsData;

  GraphRepository(this._dataSource, this._componentsData);

  /// Generate graph for a character
  Future<GraphData> generateGraph(String character) async {
    return await _dataSource.generateGraph(character);
  }

  /// Build component tree for a character
  Future<GraphData> buildComponentTree(String character) async {
    return await _dataSource.buildComponentTree(character, _componentsData);
  }
}
