import '../../../core/base/base_view_model.dart';
import '../model/hanzi_model.dart';
import '../repository/hanzi_repository.dart';

/// View model for hanzi operations
class HanziViewModel extends BaseViewModel {
  final HanziRepository _repository;

  HanziViewModel(this._repository);

  // State
  HanziDetails? _currentHanziDetails;
  List<String> _searchResults = [];
  String _selectedCharacter = '';

  // Getters
  HanziDetails? get currentHanziDetails => _currentHanziDetails;
  List<String> get searchResults => _searchResults;
  String get selectedCharacter => _selectedCharacter;

  /// Get complete details for a hanzi character
  Future<void> getHanziDetails(String character) async {
    if (character.isEmpty) return;

    await handleAsyncOperation(() async {
      _selectedCharacter = character;
      _currentHanziDetails = await _repository.getHanziDetails(character);
      return _currentHanziDetails;
    });
  }

  /// Search for characters
  Future<void> searchCharacters(String query) async {
    await handleAsyncOperation(() async {
      _searchResults = await _repository.searchCharacters(query);
      return _searchResults;
    }, showLoading: false);
  }

  /// Get definition for a character
  Future<HanziDefinition?> getDefinition(String character) async {
    return await _repository.getDefinition(character);
  }

  /// Get sentences for a character
  Future<List<HanziSentence>> getSentences(String character) async {
    final result = await handleAsyncOperation(() async {
      return await _repository.getSentences(character);
    });
    return result ?? [];
  }

  /// Get component data for a character
  Future<HanziComponent?> getComponent(String character) async {
    return await _repository.getComponent(character);
  }

  /// Get all available characters
  Future<List<String>> getAllCharacters() async {
    final result = await handleAsyncOperation(() async {
      return await _repository.getAllCharacters();
    });
    return result ?? [];
  }

  /// Check if character exists
  Future<bool> hasCharacter(String character) async {
    final result = await handleAsyncOperation(() async {
      return await _repository.hasCharacter(character);
    });
    return result ?? false;
  }

  /// Clear current hanzi details
  void clearHanziDetails() {
    _currentHanziDetails = null;
    _selectedCharacter = '';
    notifyListeners();
  }

  /// Clear search results
  void clearSearchResults() {
    _searchResults.clear();
    notifyListeners();
  }

  /// Select a character from search results
  Future<void> selectCharacter(String character) async {
    clearSearchResults();
    await getHanziDetails(character);
  }
}
