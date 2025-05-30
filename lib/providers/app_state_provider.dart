import 'package:flutter/material.dart';

/// Available states in the app
enum AppState {
  main, // Main explore screen
  study, // Study mode (not implemented as per requirements)
  faq, // FAQ screen
  stats, // Stats screen (not implemented as per requirements)
  menu, // Menu screen
}

/// Available panes within main state
enum MainPane {
  explore, // Explore pane with examples
  study, // Study pane (not used as per requirements)
}

/// App state provider - equivalent to ui-orchestrator.js
/// Manages switching between different states/screens in the app
class AppStateProvider extends ChangeNotifier {
  AppState _currentState = AppState.main;
  MainPane _currentPane = MainPane.explore;
  AppState? _previousState;

  String _currentSearchQuery = '';
  bool _isSearchFocused = false;
  bool _showWalkthrough = true;

  // Getters
  AppState get currentState => _currentState;
  MainPane get currentPane => _currentPane;
  AppState? get previousState => _previousState;
  String get currentSearchQuery => _currentSearchQuery;
  bool get isSearchFocused => _isSearchFocused;
  bool get showWalkthrough => _showWalkthrough;

  /// Switch to a different app state
  void switchToState(AppState newState) {
    if (newState == _currentState) return;

    // Save previous state for state-preserving screens
    if (_shouldPreserveState(newState)) {
      _previousState = _currentState;
    } else {
      _previousState = null;
    }

    _currentState = newState;
    notifyListeners();
  }

  /// Switch to a different pane within main state
  void switchToPane(MainPane newPane) {
    if (newPane == _currentPane) return;

    _currentPane = newPane;
    notifyListeners();
  }

  /// Go back to previous state
  void goBack() {
    if (_previousState != null) {
      final temp = _currentState;
      _currentState = _previousState!;
      _previousState = temp;
      notifyListeners();
    } else {
      // Default back action
      switchToState(AppState.main);
    }
  }

  /// Update search query
  void updateSearchQuery(String query) {
    _currentSearchQuery = query;

    // Hide walkthrough when user starts searching
    if (query.isNotEmpty && _showWalkthrough) {
      _showWalkthrough = false;
    }

    notifyListeners();
  }

  /// Set search focus state
  void setSearchFocus(bool focused) {
    _isSearchFocused = focused;
    notifyListeners();
  }

  /// Show or hide walkthrough
  void setShowWalkthrough(bool show) {
    _showWalkthrough = show;
    notifyListeners();
  }

  /// Check if state should preserve previous state
  bool _shouldPreserveState(AppState state) {
    return state == AppState.faq || state == AppState.stats || state == AppState.menu;
  }

  /// Get appropriate button text for left button
  String getLeftButtonText() {
    switch (_currentState) {
      case AppState.main:
      case AppState.study:
        return 'Menu';
      case AppState.faq:
      case AppState.stats:
      case AppState.menu:
        return 'Back';
    }
  }

  /// Get appropriate button text for right button
  String? getRightButtonText() {
    switch (_currentState) {
      case AppState.main:
        return 'Study';
      case AppState.study:
        return 'Explore';
      default:
        return null; // No right button for other states
    }
  }

  /// Get appropriate action for left button
  VoidCallback getLeftButtonAction() {
    switch (_currentState) {
      case AppState.main:
      case AppState.study:
        return () => switchToState(AppState.menu);
      default:
        return goBack;
    }
  }

  /// Get appropriate action for right button
  VoidCallback? getRightButtonAction() {
    switch (_currentState) {
      case AppState.main:
        return () => switchToState(AppState.study);
      case AppState.study:
        return () => switchToState(AppState.main);
      default:
        return null;
    }
  }

  /// Reset to initial state
  void reset() {
    _currentState = AppState.main;
    _currentPane = MainPane.explore;
    _previousState = null;
    _currentSearchQuery = '';
    _isSearchFocused = false;
    _showWalkthrough = true;
    notifyListeners();
  }
}
