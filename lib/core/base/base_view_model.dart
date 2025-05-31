import 'package:flutter/foundation.dart';

/// Base view model class that provides common functionality
/// for all view models in the MVVM architecture
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool _isDisposed = false;

  /// Whether the view model is currently loading
  bool get isLoading => _isLoading;

  /// Current error message, if any
  String? get error => _error;

  /// Whether the view model has been disposed
  bool get isDisposed => _isDisposed;

  /// Set loading state
  void setLoading(bool loading) {
    if (_isDisposed) return;
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error state
  void setError(String? error) {
    if (_isDisposed) return;
    _error = error;
    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    if (_isDisposed) return;
    _error = null;
    notifyListeners();
  }

  /// Handle async operations with loading and error states
  Future<T?> handleAsyncOperation<T>(Future<T> Function() operation, {bool showLoading = true}) async {
    if (_isDisposed) return null;

    try {
      if (showLoading) setLoading(true);
      clearError();

      final result = await operation();

      if (showLoading) setLoading(false);
      return result;
    } catch (e) {
      if (showLoading) setLoading(false);
      setError(e.toString());
      return null;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
