import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  print('🚀 HanziGraph Flutter Demo');
  print('=========================');

  try {
    // Load definitions data
    final definitionsFile = File('assets/data/simplified/definitions.json');
    final definitionsContent = await definitionsFile.readAsString();
    final definitions = json.decode(definitionsContent) as Map<String, dynamic>;

    // Load sentences data
    final sentencesFile = File('assets/data/simplified/sentences.json');
    final sentencesContent = await sentencesFile.readAsString();
    final sentences = json.decode(sentencesContent) as List;

    // Load wordlist data
    final wordlistFile = File('assets/data/simplified/wordlist.json');
    final wordlistContent = await wordlistFile.readAsString();
    final wordlist = json.decode(wordlistContent) as List;

    print('✅ Data loaded successfully!');
    print('   📚 Definitions: ${definitions.length} characters');
    print('   📝 Sentences: ${sentences.length} examples');
    print('   📖 Wordlist: ${wordlist.length} words');
    print('');

    // Demo: Test character "我"
    print('🔍 Testing character "我" (I/me):');
    if (definitions.containsKey('我')) {
      final myDefs = definitions['我'] as List;
      print('   📖 Definition: ${myDefs.first['en']} (${myDefs.first['pinyin']})');

      // Find sentences with "我"
      final mySentences =
          sentences
              .where((s) {
                final zh = s['zh'] as List?;
                return zh?.contains('我') == true;
              })
              .take(3)
              .toList();

      print('   📝 Example sentences:');
      for (final sentence in mySentences) {
        final chinese = (sentence['zh'] as List).join('');
        final english = sentence['en'];
        print('      $chinese - $english');
      }
    }

    print('');
    print('🔍 Testing character "好" (good):');
    if (definitions.containsKey('好')) {
      final goodDefs = definitions['好'] as List;
      print('   📖 Definition: ${goodDefs.first['en']} (${goodDefs.first['pinyin']})');

      // Find sentences with "好"
      final goodSentences =
          sentences
              .where((s) {
                final zh = s['zh'] as List?;
                return zh?.contains('好') == true;
              })
              .take(2)
              .toList();

      print('   📝 Example sentences:');
      for (final sentence in goodSentences) {
        final chinese = (sentence['zh'] as List).join('');
        final english = sentence['en'];
        print('      $chinese - $english');
      }
    }

    print('');
    print('🎯 Top 10 most frequent words:');
    for (int i = 0; i < 10 && i < wordlist.length; i++) {
      print('   ${i + 1}. ${wordlist[i]}');
    }

    print('');
    print('🎉 Demo completed! The Flutter app can now:');
    print('   ✅ Load real Chinese character data from JSON files');
    print('   ✅ Parse definitions with pinyin pronunciation');
    print('   ✅ Find example sentences containing specific characters');
    print('   ✅ Display character relationships and frequencies');
    print('   ✅ Provide search functionality across the dataset');
  } catch (e) {
    print('❌ Error running demo: $e');
  }
}
