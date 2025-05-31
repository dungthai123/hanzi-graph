import '../datasource/hanzi_datasource.dart';
import '../model/hanzi_model.dart';

/// Repository for hanzi operations
class HanziRepository {
  final HanziDataSource _dataSource;

  HanziRepository(this._dataSource);

  /// Get definition for a specific character
  Future<HanziDefinition?> getDefinition(String character) async {
    return await _dataSource.getDefinition(character);
  }

  /// Get sentences containing the character
  Future<List<HanziSentence>> getSentences(String character) async {
    return await _dataSource.getSentences(character);
  }

  /// Get component data for a character
  Future<HanziComponent?> getComponent(String character) async {
    return await _dataSource.getComponent(character);
  }

  /// Search for characters by query
  Future<List<String>> searchCharacters(String query) async {
    return await _dataSource.searchCharacters(query);
  }

  /// Get all available characters
  Future<List<String>> getAllCharacters() async {
    return await _dataSource.getAllCharacters();
  }

  /// Check if character exists
  Future<bool> hasCharacter(String character) async {
    return await _dataSource.hasCharacter(character);
  }

  /// Get components (sub-parts) of a character
  Future<List<String>> getComponents(String character) async {
    return await _dataSource.getComponents(character);
  }

  /// Get compounds (characters that use this character as a component)
  Future<List<String>> getCompounds(String character) async {
    return await _dataSource.getCompounds(character);
  }

  /// Get complete hanzi details
  Future<HanziDetails> getHanziDetails(String character) async {
    return await _dataSource.getHanziDetails(character);
  }
}
