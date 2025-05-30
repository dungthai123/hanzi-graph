import '../models/sentence_data.dart';
import '../models/definition_data.dart';
import '../models/component_data.dart';

/// Data service - equivalent to data-layer.js
/// Manages access to all loaded data
class DataService {
  Map<String, dynamic> _hanziData = {};
  List<dynamic> _sentencesData = [];
  Map<String, dynamic> _definitionsData = {};
  Map<String, dynamic> _componentsData = {};

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Initialize the data service with loaded data
  Future<void> initialize({
    required Map<String, dynamic> hanziData,
    required List<dynamic> sentencesData,
    required Map<String, dynamic> definitionsData,
    required Map<String, dynamic> componentsData,
  }) async {
    _hanziData = hanziData;
    _sentencesData = sentencesData;
    _definitionsData = definitionsData;
    _componentsData = componentsData;

    _isInitialized = true;
    print('Data service initialized with data');
  }

  /// Get character definitions
  DefinitionData? getDefinition(String character) {
    final definitionsList = _definitionsData[character] as List?;
    if (definitionsList == null || definitionsList.isEmpty) {
      print('📚 DataService: No definition found for "$character"');
      return null;
    }

    // Parse the definitions list from the JSON structure
    // Each character has a list of definitions with "en" and "pinyin" fields
    final firstDef = definitionsList.first as Map<String, dynamic>;
    final allDefinitions =
        definitionsList
            .map((def) => (def as Map<String, dynamic>)['en'] as String? ?? '')
            .where((def) => def.isNotEmpty)
            .toList();

    final result = DefinitionData(
      character: character,
      english: allDefinitions,
      pinyin: firstDef['pinyin'] as String? ?? '',
      parts: [], // Not available in this data structure
      hskLevel: 0, // Not available in this data structure
    );

    print('📚 DataService: Found definition for "$character": ${result.english.first} (${result.pinyin})');
    return result;
  }

  /// Get sentences containing character
  List<SentenceData> getSentences(String character) {
    final sentences = <SentenceData>[];

    // _sentencesData is a list of sentence objects
    for (final sentenceObj in _sentencesData) {
      if (sentenceObj is Map<String, dynamic>) {
        final zhChars = sentenceObj['zh'] as List?;

        // Check if this sentence contains the character
        if (zhChars != null && zhChars.contains(character)) {
          final chinese = zhChars.join('');
          final english = sentenceObj['en'] as String? ?? '';
          final pinyin = sentenceObj['pinyin'] as String? ?? '';

          sentences.add(
            SentenceData(
              chinese: chinese,
              english: english,
              pinyin: pinyin,
              characters: zhChars.map((c) => c.toString()).toList(),
              source: 'simplified',
            ),
          );
        }
      }
    }

    return sentences;
  }

  /// Get component data
  ComponentData? getComponent(String component) {
    final data = _componentsData[component];
    if (data != null && data is Map<String, dynamic>) {
      return ComponentData.fromJson(component, data);
    }
    return null;
  }

  /// Get components (sub-parts) of a character
  List<String> getComponents(String character) {
    final componentData = getComponent(character);
    return componentData?.components ?? [];
  }

  /// Get compounds (characters that use this character as a component)
  List<String> getCompounds(String character) {
    final componentData = getComponent(character);
    return componentData?.componentOf ?? [];
  }

  /// Get all characters that contain a specific component
  List<String> getCharactersWithComponent(String component) {
    final characters = <String>[];

    _componentsData.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        final components = value['components'] as List?;
        if (components != null && components.contains(component)) {
          characters.add(key);
        }
      }
    });

    return characters;
  }

  /// Search for characters by partial match
  List<String> searchCharacters(String query) {
    final results = <String>[];

    if (query.isEmpty) return results;

    // Search in definitions data since that's where our characters are
    _definitionsData.forEach((key, value) {
      if (key.contains(query)) {
        results.add(key);
      }
    });

    // Sort by length (shorter characters first) and limit results
    results.sort((a, b) => a.length.compareTo(b.length));

    return results.take(50).toList(); // Limit results
  }

  /// Get hanzi data for a specific character
  Map<String, dynamic>? getHanziData(String character) {
    return _hanziData[character] as Map<String, dynamic>?;
  }

  /// Get all available characters
  List<String> getAllCharacters() {
    return _definitionsData.keys.toList();
  }

  /// Get all components data
  Map<String, dynamic> getAllComponentsData() {
    return Map.from(_componentsData);
  }

  /// Check if character exists in data
  bool hasCharacter(String character) {
    return _definitionsData.containsKey(character);
  }
}
