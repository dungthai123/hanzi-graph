import 'dart:convert';
import 'package:flutter/services.dart';
import '../services/data_service.dart';
import '../services/search_service.dart';
import '../services/graph_service.dart';

/// Main app initializer following the JavaScript initialization flow:
/// 1. Data Loading Phase (data-load.js equivalent)
/// 2. Module Initialization Sequence
/// 3. Core Infrastructure Setup
/// 4. UI & State Management preparation
/// 5. Core Features initialization
class AppInitializer {
  final DataService _dataService = DataService();
  final SearchService _searchService = SearchService();
  final GraphService _graphService = GraphService();

  // Data containers - equivalent to window.hanzi, window.sentences, etc.
  late Map<String, dynamic> hanziData;
  late List<dynamic> sentencesData; // Changed to List since sentences.json is an array
  late Map<String, dynamic> definitionsData;
  late Map<String, dynamic> componentsData;
  late Map<String, dynamic> freqsData;

  bool _isInitialized = false;
  String _selectedCharacterSet = 'simplified'; // Default graph prefix

  bool get isInitialized => _isInitialized;
  String get selectedCharacterSet => _selectedCharacterSet;

  /// Initialize the app following the specified flow
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Phase 1: Data Loading Phase (equivalent to data-load.js)
      await _dataLoadingPhase();

      // Phase 2: Core Infrastructure (equivalent to dataLayerInit, fileAnalysisInitialize)
      await _coreInfrastructureInit();

      // Phase 3: UI & State Management preparation (equivalent to orchestratorInit, optionsInit)
      await _uiStateManagementInit();

      // Phase 4: Core Features (equivalent to graphInit, studyModeInit, exploreInit, etc.)
      await _coreFeaturesInit();

      // Phase 5: Search & Event Handlers setup (equivalent to searchInit)
      await _searchEventHandlersInit();

      // Phase 6: Secondary Features (equivalent to statsInit, faqInit)
      await _secondaryFeaturesInit();

      _isInitialized = true;
      print('App initialization completed successfully');
    } catch (e) {
      print('Error during app initialization: $e');
      rethrow;
    }
  }

  /// Phase 1: Data Loading Phase - equivalent to data-load.js and Promise.all in main.js
  Future<void> _dataLoadingPhase() async {
    print('Starting data loading phase...');

    // Determine character set (equivalent to graphPrefix logic in data-load.js)
    _selectedCharacterSet = await _determineCharacterSet();

    // Load all data files concurrently (equivalent to Promise.all in main.js)
    final futures = <Future<void>>[];

    // Load sentences data
    futures.add(_loadSentencesData());

    // Load definitions data
    futures.add(_loadDefinitionsData());

    // Load components data
    futures.add(_loadComponentsData());

    // Load graph data - try graph.json first, fallback to building from wordlist
    futures.add(_loadGraphData());

    // Wait for all data to load
    await Future.wait(futures);

    print('Data loading phase completed');
  }

  /// Phase 2: Core Infrastructure Init
  Future<void> _coreInfrastructureInit() async {
    print('Initializing core infrastructure...');

    // Initialize data service (equivalent to dataLayerInit)
    await _dataServiceInit();

    print('Core infrastructure initialized');
  }

  /// Phase 2: Data Service Init
  Future<void> _dataServiceInit() async {
    print('Initializing data service...');

    // Initialize data service with loaded data
    await _dataService.initialize(
      hanziData: hanziData,
      sentencesData: sentencesData,
      definitionsData: definitionsData,
      componentsData: componentsData,
    );

    print('Data service initialized with:');
    print('  📚 Definitions: ${definitionsData.length} characters');
    print('  📝 Sentences: ${sentencesData.length} examples');
    print('  🧩 Components: ${componentsData.length} components');
    print('  📊 Hanzi data: ${hanziData.length} entries');

    // Test a sample character lookup
    final testChar = '我';
    final hasChar = _dataService.hasCharacter(testChar);
    final definition = _dataService.getDefinition(testChar);
    print(
      '  🔍 Test character "$testChar": ${hasChar ? "✅" : "❌"} exists, ${definition != null ? "✅" : "❌"} has definition',
    );

    print('Data service initialization complete');
  }

  /// Phase 3: UI & State Management Init
  Future<void> _uiStateManagementInit() async {
    print('Initializing UI & state management...');

    // UI orchestrator and options initialization will be handled by providers
    // This is where we prepare any global state that needs to be ready

    print('UI & state management initialized');
  }

  /// Phase 4: Core Features Init
  Future<void> _coreFeaturesInit() async {
    print('Initializing core features...');

    // Initialize graph service (equivalent to graphInit)
    await _graphService.initialize(_selectedCharacterSet);

    // Load graph data into the service
    _graphService.setGraphData(hanziData);

    // Load frequency data if available
    if (freqsData.isNotEmpty) {
      final wordList = freqsData.keys.toList();
      _graphService.setWordFrequencyData(wordList);
      print('📊 Frequency data loaded into GraphService: ${wordList.length} words');
    } else {
      print('📊 No frequency data available');
    }

    print('Core features initialized');
  }

  /// Phase 5: Search & Event Handlers Init
  Future<void> _searchEventHandlersInit() async {
    print('Initializing search & event handlers...');

    // Initialize search service (equivalent to searchInit)
    await _searchService.initialize(_dataService);

    print('Search & event handlers initialized');
  }

  /// Phase 6: Secondary Features Init
  Future<void> _secondaryFeaturesInit() async {
    print('Initializing secondary features...');

    // Stats, FAQ, and other secondary features initialization
    // These will be handled by their respective providers/services

    print('Secondary features initialized');
  }

  /// Determine character set based on preferences (equivalent to data-load.js logic)
  Future<String> _determineCharacterSet() async {
    // For now, return simplified as default
    // In a real app, this would check saved preferences, URL parameters, etc.
    return 'simplified';
  }

  /// Load sentences data
  Future<void> _loadSentencesData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/$_selectedCharacterSet/sentences.json');
      final jsonData = json.decode(jsonString);

      // sentences.json is an array, so we store it directly
      if (jsonData is List) {
        sentencesData = jsonData;
      } else {
        print('Warning: sentences.json is not an array, storing as empty list');
        sentencesData = [];
      }
    } catch (e) {
      print('Error loading sentences data: $e');
      sentencesData = [];
    }
  }

  /// Load definitions data
  Future<void> _loadDefinitionsData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/$_selectedCharacterSet/definitions.json');
      definitionsData = json.decode(jsonString);
    } catch (e) {
      print('Error loading definitions data: $e');
      definitionsData = {};
    }
  }

  /// Load components data
  Future<void> _loadComponentsData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/components/components.json');
      componentsData = json.decode(jsonString);
    } catch (e) {
      print('Error loading components data: $e');
      componentsData = {};
    }
  }

  /// Load graph data - try graph.json first, fallback to building from wordlist
  Future<void> _loadGraphData() async {
    try {
      // Try to load prebuilt graph.json first
      final jsonString = await rootBundle.loadString('assets/data/$_selectedCharacterSet/graph.json');
      hanziData = json.decode(jsonString);
      freqsData = {}; // Initialize empty, will be populated if needed
      print('✅ Loaded prebuilt graph data: ${hanziData.length} characters');
    } catch (e) {
      print('⚠️ Could not load graph.json: $e');
      print('📝 Falling back to building graph from wordlist...');

      // Fallback: load wordlist and build graph data
      try {
        final jsonString = await rootBundle.loadString('assets/data/$_selectedCharacterSet/wordlist.json');
        final wordList = json.decode(jsonString);

        // wordlist.json is an array of words, so we create a frequency map and build graph
        if (wordList is List) {
          freqsData = {};
          hanziData = {};

          // Create frequency data
          for (int i = 0; i < wordList.length; i++) {
            final word = wordList[i].toString();
            freqsData[word] = i + 1; // 1-indexed frequency rank
          }

          // Build basic graph data from frequency list
          hanziData = _buildBasicGraphFromWordList(wordList);
          print('✅ Built graph from wordlist: ${hanziData.length} characters, ${freqsData.length} words');
        } else {
          print('❌ Warning: wordlist.json is not an array');
          freqsData = {};
          hanziData = {};
        }
      } catch (e) {
        print('❌ Error loading frequency data: $e');
        freqsData = {};
        hanziData = {};
      }
    }
  }

  /// Build basic graph structure from word list (simplified version)
  Map<String, dynamic> _buildBasicGraphFromWordList(List<dynamic> wordList) {
    final graph = <String, dynamic>{};

    for (int i = 0; i < wordList.length && i < 1000; i++) {
      // Limit to first 1000 words for performance
      final word = wordList[i].toString();
      final level = (i ~/ 200) + 1; // Create 5 levels based on frequency

      // Add each character to the graph
      for (int j = 0; j < word.length; j++) {
        final char = word[j];

        if (!graph.containsKey(char)) {
          graph[char] = {
            'node': {'level': level},
            'edges': <String, dynamic>{},
          };
        }

        // Create edges to other characters in the same word
        for (int k = 0; k < word.length; k++) {
          if (j != k) {
            final otherChar = word[k];
            final edges = graph[char]['edges'] as Map<String, dynamic>;

            if (!edges.containsKey(otherChar) && edges.length < 8) {
              // Max 8 edges
              edges[otherChar] = {
                'level': level,
                'words': [word],
              };
            } else if (edges.containsKey(otherChar)) {
              final edgeData = edges[otherChar] as Map<String, dynamic>;
              final words = edgeData['words'] as List<dynamic>;
              if (words.length < 2 && !words.contains(word)) {
                // Max 2 words per edge
                words.add(word);
              }
            }
          }
        }
      }
    }

    return graph;
  }

  /// Get initialized services
  DataService get dataService => _dataService;
  SearchService get searchService => _searchService;
  GraphService get graphService => _graphService;
}
