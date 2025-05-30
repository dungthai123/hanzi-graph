import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzi_graph/main.dart';
import 'package:hanzi_graph/core/app_initializer.dart';

void main() {
  group('App Integration Tests', () {
    testWidgets('App loads and shows character data from assets', (WidgetTester tester) async {
      // Create a real app initializer that loads from assets
      final appInitializer = AppInitializer();

      // Initialize the app (this will load real data)
      await appInitializer.initialize();

      // Verify that data was loaded
      expect(appInitializer.isInitialized, isTrue);
      expect(appInitializer.dataService.isInitialized, isTrue);

      // Verify we have some characters available
      final allChars = appInitializer.dataService.getAllCharacters();
      expect(allChars, isNotEmpty);
      print('Loaded ${allChars.length} characters from assets');

      // Test a specific character that should exist
      if (allChars.contains('我')) {
        final definition = appInitializer.dataService.getDefinition('我');
        expect(definition, isNotNull);
        expect(definition!.character, equals('我'));
        expect(definition.english, isNotEmpty);
        print('Found definition for 我: ${definition.english.join(", ")}');

        final sentences = appInitializer.dataService.getSentences('我');
        print('Found ${sentences.length} sentences containing 我');
        if (sentences.isNotEmpty) {
          print('Example: ${sentences.first.chinese} - ${sentences.first.english}');
        }
      }

      // Test search functionality
      final searchResults = appInitializer.dataService.searchCharacters('我');
      expect(searchResults, contains('我'));
      print('Search for "我" returned ${searchResults.length} results');

      // Build our app and trigger a frame
      await tester.pumpWidget(MyApp(appInitializer: appInitializer));
      await tester.pumpAndSettle();

      // Verify that the app starts properly
      expect(find.text('Welcome to HanziGraph'), findsOneWidget);

      // Try the sample search
      final tryButton = find.text('Try with "你"');
      if (tryButton.evaluate().isNotEmpty) {
        await tester.tap(tryButton);
        await tester.pumpAndSettle();

        // Should show character details
        expect(find.text('你'), findsWidgets);
      }
    });
  });
}
