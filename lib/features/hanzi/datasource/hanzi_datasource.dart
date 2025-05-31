import '../model/hanzi_model.dart';

/// Data source for hanzi operations
class HanziDataSource {
  final Map<String, dynamic> _hanziData;
  final List<dynamic> _sentencesData;
  final Map<String, dynamic> _definitionsData;
  final Map<String, dynamic> _componentsData;

  HanziDataSource({
    required Map<String, dynamic> hanziData,
    required List<dynamic> sentencesData,
    required Map<String, dynamic> definitionsData,
    required Map<String, dynamic> componentsData,
  }) : _hanziData = hanziData,
       _sentencesData = sentencesData,
       _definitionsData = definitionsData,
       _componentsData = componentsData;

  /// Get definition for a specific character
  Future<HanziDefinition?> getDefinition(String character) async {
    try {
      final definitionsList = _definitionsData[character] as List?;
      if (definitionsList == null || definitionsList.isEmpty) {
        return null;
      }

      final firstDef = definitionsList.first as Map<String, dynamic>;
      final allDefinitions =
          definitionsList
              .map((def) => (def as Map<String, dynamic>)['en'] as String? ?? '')
              .where((def) => def.isNotEmpty)
              .toList();

      return HanziDefinition(
        character: character,
        english: allDefinitions,
        pinyin: firstDef['pinyin'] as String? ?? '',
        parts: [],
        hskLevel: 0,
      );
    } catch (e) {
      throw Exception('Failed to get definition for $character: $e');
    }
  }

  /// Get sentences containing the character
  Future<List<HanziSentence>> getSentences(String character) async {
    try {
      final sentences = <HanziSentence>[];

      for (final sentenceObj in _sentencesData) {
        if (sentenceObj is Map<String, dynamic>) {
          final zhChars = sentenceObj['zh'] as List?;

          if (zhChars != null && zhChars.contains(character)) {
            final chinese = zhChars.join('');
            final english = sentenceObj['en'] as String? ?? '';
            final pinyin = sentenceObj['pinyin'] as String? ?? '';

            sentences.add(
              HanziSentence(
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
    } catch (e) {
      throw Exception('Failed to get sentences for $character: $e');
    }
  }

  /// Get component data for a character
  Future<HanziComponent?> getComponent(String component) async {
    try {
      final data = _componentsData[component];
      if (data != null && data is Map<String, dynamic>) {
        return HanziComponent.fromJson(component, data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get component data for $component: $e');
    }
  }

  /// Search for characters by query
  Future<List<String>> searchCharacters(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final results = <String>[];
      final trimmedQuery = query.trim();

      _definitionsData.forEach((key, value) {
        if (key.contains(trimmedQuery)) {
          results.add(key);
        }
      });

      results.sort((a, b) => a.length.compareTo(b.length));
      return results.take(50).toList();
    } catch (e) {
      throw Exception('Failed to search characters with query $query: $e');
    }
  }

  /// Get all available characters
  Future<List<String>> getAllCharacters() async {
    try {
      return _definitionsData.keys.toList();
    } catch (e) {
      throw Exception('Failed to get all characters: $e');
    }
  }

  /// Check if character exists
  Future<bool> hasCharacter(String character) async {
    try {
      return _definitionsData.containsKey(character);
    } catch (e) {
      throw Exception('Failed to check if character exists: $e');
    }
  }

  /// Get components (sub-parts) of a character
  Future<List<String>> getComponents(String character) async {
    try {
      final component = await getComponent(character);
      return component?.components ?? [];
    } catch (e) {
      throw Exception('Failed to get components for $character: $e');
    }
  }

  /// Get compounds (characters that use this character as a component)
  Future<List<String>> getCompounds(String character) async {
    try {
      final component = await getComponent(character);
      return component?.componentOf ?? [];
    } catch (e) {
      throw Exception('Failed to get compounds for $character: $e');
    }
  }

  /// Get complete hanzi details
  Future<HanziDetails> getHanziDetails(String character) async {
    try {
      final definition = await getDefinition(character);
      final sentences = await getSentences(character);
      final component = await getComponent(character);
      final components = await getComponents(character);
      final compounds = await getCompounds(character);

      return HanziDetails(
        character: character,
        definition: definition,
        sentences: sentences,
        component: component,
        components: components,
        compounds: compounds,
      );
    } catch (e) {
      throw Exception('Failed to get hanzi details for $character: $e');
    }
  }
}
