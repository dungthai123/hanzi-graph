import 'package:flutter/material.dart';
import '../services/data_service.dart';

/// Search provider - equivalent to search.js functionality
/// Handles character search and suggestions
class SearchProvider extends ChangeNotifier {
  DataService? _dataService;

  String _query = '';
  List<String> _results = [];
  List<String> _suggestions = [];
  String _selectedCharacter = '';
  bool _isSearching = false;

  // Getters
  String get query => _query;
  List<String> get results => _results;
  List<String> get suggestions => _suggestions;
  String get selectedCharacter => _selectedCharacter;
  bool get isSearching => _isSearching;

  /// Initialize with data service
  void initialize(DataService dataService) {
    _dataService = dataService;
  }

  /// Update search query and generate suggestions
  void updateQuery(String query) {
    _query = query;
    if (query.isEmpty) {
      _suggestions = [];
      _results = [];
    } else {
      _generateSuggestions(query);
    }
    notifyListeners();
  }

  /// Perform search
  Future<void> search(String query) async {
    if (query.isEmpty || _dataService == null) return;

    _isSearching = true;
    _query = query;
    notifyListeners();

    try {
      // Use real search from DataService
      _results = _dataService!.searchCharacters(query);
      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _isSearching = false;
      notifyListeners();
      print('Search error: $e');
    }
  }

  /// Select a character for exploration
  void selectCharacter(String character) {
    print('🔍 SearchProvider: Selecting character "$character"');
    _selectedCharacter = character;
    _query = character;
    print('🔍 SearchProvider: Selected character set to "$_selectedCharacter"');
    print('🔍 SearchProvider: Query updated to "$_query"');
    notifyListeners();
    print('🔍 SearchProvider: Listeners notified');
  }

  /// Clear search
  void clearSearch() {
    _query = '';
    _results = [];
    _suggestions = [];
    _selectedCharacter = '';
    notifyListeners();
  }

  /// Clear only the selected character (for navigation)
  void clearSelectedCharacter() {
    _selectedCharacter = '';
    notifyListeners();
  }

  /// Generate search suggestions using real data
  void _generateSuggestions(String query) {
    if (query.isEmpty || _dataService == null) {
      _suggestions = [];
      return;
    }

    try {
      // Get suggestions from DataService
      final searchResults = _dataService!.searchCharacters(query);
      _suggestions = searchResults.take(8).toList();
      print('🔍 SearchProvider: Generated ${_suggestions.length} suggestions for "$query": ${_suggestions.join(", ")}');
    } catch (e) {
      // Fallback to basic suggestions if DataService fails
      _suggestions = _getBasicSuggestions(query);
      print('🔍 SearchProvider: Fallback suggestions for "$query": ${_suggestions.join(", ")}');
      print('Suggestions error: $e');
    }
  }

  /// Basic fallback suggestions
  List<String> _getBasicSuggestions(String query) {
    // Only use characters that exist in the data service
    if (_dataService == null) return [];

    final availableChars = _dataService!.getAllCharacters();

    // Filter available characters based on the query
    final suggestions =
        availableChars
            .where((char) => char.contains(query) || char.startsWith(query) || char == query)
            .take(8)
            .toList();

    print(
      '🔍 SearchProvider: Fallback suggestions from ${availableChars.length} available chars: ${suggestions.join(", ")}',
    );
    return suggestions;
  }

  /// Get available characters from data service
  List<String> getAllCharacters() {
    if (_dataService == null) return [];
    return _dataService!.getAllCharacters();
  }

  /// Check if character exists in data
  bool hasCharacter(String character) {
    if (_dataService == null) return false;
    return _dataService!.hasCharacter(character);
  }
}
