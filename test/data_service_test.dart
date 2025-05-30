import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:hanzi_graph/services/data_service.dart';
import 'dart:convert';

void main() {
  group('DataService', () {
    late DataService dataService;

    setUp(() {
      dataService = DataService();
    });

    testWidgets('loads and parses real data correctly', (WidgetTester tester) async {
      // Simulate loading real data files
      const testDefinitions = {
        "我": [
          {"en": "I; me; my", "pinyin": "wo3"},
        ],
        "是": [
          {"en": "to be", "pinyin": "shi4"},
        ],
        "好": [
          {"en": "good", "pinyin": "hao3"},
        ],
      };

      const testSentences = [
        {
          "en": "I am!",
          "zh": ["我", "是"],
          "pinyin": "Wo3 shi4",
        },
        {
          "en": "Good.",
          "zh": ["好"],
          "pinyin": "Hao3",
        },
      ];

      // Initialize the data service
      await dataService.initialize(
        hanziData: {},
        sentencesData: testSentences,
        definitionsData: testDefinitions,
        componentsData: {},
      );

      // Test that definitions are parsed correctly
      final definition = dataService.getDefinition('我');
      expect(definition, isNotNull);
      expect(definition!.character, equals('我'));
      expect(definition.english, contains('I; me; my'));
      expect(definition.pinyin, equals('wo3'));

      // Test that sentences are found correctly
      final sentences = dataService.getSentences('我');
      expect(sentences, isNotEmpty);
      expect(sentences.first.chinese, equals('我是'));
      expect(sentences.first.english, equals('I am!'));

      // Test search functionality
      final searchResults = dataService.searchCharacters('我');
      expect(searchResults, contains('我'));

      // Test character existence check
      expect(dataService.hasCharacter('我'), isTrue);
      expect(dataService.hasCharacter('不存在'), isFalse);
    });
  });
}
