import 'dart:async';
import 'data_service.dart';

/// Search service - equivalent to search.js and search-suggestions-worker.js
/// Handles search functionality and suggestions
class SearchService {
  DataService? _dataService;
  final StreamController<List<String>> _suggestionsController = StreamController.broadcast();
  final StreamController<SearchResult> _searchResultController = StreamController.broadcast();

  Stream<List<String>> get suggestionsStream => _suggestionsController.stream;
  Stream<SearchResult> get searchResultStream => _searchResultController.stream;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Initialize the search service
  Future<void> initialize(DataService dataService) async {
    _dataService = dataService;
    _isInitialized = true;
    print('Search service initialized');
  }

  /// Search for characters - equivalent to search() function in search.js
  Future<SearchResult> search(String query, {String mode = 'explore'}) async {
    if (_dataService == null || !_dataService!.isInitialized) {
      throw Exception('Search service not properly initialized');
    }

    final result = SearchResult(query: query, characters: [], suggestions: [], mode: mode);

    if (query.isEmpty) {
      _searchResultController.add(result);
      return result;
    }

    // Tokenize and search (simplified version of the JS tokenization logic)
    final tokenizedChars = _tokenizeInput(query);

    // Find matching characters
    for (final char in tokenizedChars) {
      if (_dataService!.hasCharacter(char)) {
        result.characters.add(char);
      }
    }

    // If no exact matches, search for partial matches
    if (result.characters.isEmpty) {
      final searchResults = _dataService!.searchCharacters(query);
      result.characters.addAll(searchResults.take(10));
    }

    // Generate suggestions
    result.suggestions.addAll(_generateSuggestions(query));

    _searchResultController.add(result);
    return result;
  }

  /// Generate search suggestions - equivalent to suggestSearches() in search.js
  void suggestSearches(String query) {
    if (_dataService == null || !_dataService!.isInitialized) {
      return;
    }

    final suggestions = _generateSuggestions(query);
    _suggestionsController.add(suggestions);
  }

  /// Generate suggestions based on query
  List<String> _generateSuggestions(String query) {
    if (query.isEmpty) return [];

    final suggestions = <String>[];

    // Add exact character matches
    if (_dataService!.hasCharacter(query)) {
      suggestions.add(query);
    }

    // Add partial matches
    final searchResults = _dataService!.searchCharacters(query);
    suggestions.addAll(searchResults.take(8));

    // Remove duplicates and sort
    final uniqueSuggestions = suggestions.toSet().toList();
    uniqueSuggestions.sort();

    return uniqueSuggestions.take(10).toList();
  }

  /// Tokenize input string into individual characters
  /// Simplified version of the tokenization logic from the JS code
  List<String> _tokenizeInput(String input) {
    final characters = <String>[];

    // For Chinese text, each character is typically one token
    for (int i = 0; i < input.length; i++) {
      final char = input[i];

      // Check if it's a Chinese character (simplified check)
      if (_isChineseCharacter(char)) {
        characters.add(char);
      }
    }

    // If no Chinese characters found, try the whole string
    if (characters.isEmpty && input.isNotEmpty) {
      characters.add(input);
    }

    return characters;
  }

  /// Check if a character is Chinese (simplified check)
  bool _isChineseCharacter(String char) {
    final codeUnit = char.codeUnitAt(0);

    // Chinese character ranges (simplified)
    return (codeUnit >= 0x4E00 && codeUnit <= 0x9FFF) || // CJK Unified Ideographs
        (codeUnit >= 0x3400 && codeUnit <= 0x4DBF) || // CJK Extension A
        (codeUnit >= 0xF900 && codeUnit <= 0xFAFF); // CJK Compatibility Ideographs
  }

  /// Dispose of resources
  void dispose() {
    _suggestionsController.close();
    _searchResultController.close();
  }
}

/// Search result model
class SearchResult {
  final String query;
  final List<String> characters;
  final List<String> suggestions;
  final String mode;

  SearchResult({required this.query, required this.characters, required this.suggestions, required this.mode});
}
