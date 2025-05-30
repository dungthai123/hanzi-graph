import '../services/data_service.dart';
import '../models/definition_data.dart';
import '../models/sentence_data.dart';
import '../models/component_data.dart';

/// Data provider that wraps the DataService to make it accessible throughout the app
class DataProvider {
  final DataService _dataService;

  DataProvider(this._dataService);

  /// Get character definition
  DefinitionData? getDefinition(String character) {
    return _dataService.getDefinition(character);
  }

  /// Get sentences containing character
  List<SentenceData> getSentences(String character) {
    return _dataService.getSentences(character);
  }

  /// Get component data
  ComponentData? getComponent(String component) {
    return _dataService.getComponent(component);
  }

  /// Get components (sub-parts) of a character
  List<String> getComponents(String character) {
    return _dataService.getComponents(character);
  }

  /// Get compounds (characters that use this character as a component)
  List<String> getCompounds(String character) {
    return _dataService.getCompounds(character);
  }

  /// Get all characters that contain a specific component
  List<String> getCharactersWithComponent(String component) {
    return _dataService.getCharactersWithComponent(component);
  }

  /// Search for characters
  List<String> searchCharacters(String query) {
    return _dataService.searchCharacters(query);
  }

  /// Get hanzi data for a character
  Map<String, dynamic>? getHanziData(String character) {
    return _dataService.getHanziData(character);
  }

  /// Check if character exists
  bool hasCharacter(String character) {
    return _dataService.hasCharacter(character);
  }

  /// Get all characters
  List<String> getAllCharacters() {
    return _dataService.getAllCharacters();
  }

  /// Get all components data
  Map<String, dynamic> getAllComponentsData() {
    return _dataService.getAllComponentsData();
  }
}
