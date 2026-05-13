import 'package:flutter/foundation.dart';

/// External handle to read/update unified field values (pickers, dates, durations, etc.).
///
/// Listen with [Listenable.merge] or attach to [AnimatedBuilder]; widgets sync both ways when bound.
class AppInputController<T> extends ChangeNotifier {
  /// Creates a controller, optionally seeded with [initialValue].
  AppInputController({T? initialValue}) : _value = initialValue;

  T? _value;

  String? _errorText;

  /// Current value (may be null).
  T? get value => _value;

  /// Imperative error message; rendered by the field when non-empty.
  String? get errorText => _errorText;

  /// True when [errorText] is non-empty.
  bool get hasError => (_errorText?.isNotEmpty ?? false);

  /// Updates [value] and notifies listeners if it changed.
  set value(T? next) {
    if (_value == next) return;
    _value = next;
    notifyListeners();
  }

  /// Replace bound value without notifying (e.g. batch updates); call [notifyListeners] yourself if needed.
  void silentSetValue(T? next) {
    _value = next;
  }

  /// Sets [errorText] and notifies listeners.
  void setError(String? message) {
    _errorText = message;
    notifyListeners();
  }

  /// Clears the error message.
  void clearError() => setError(null);

  /// Resets the controller: value becomes null and error is cleared.
  void clear() {
    value = null;
    clearError();
  }
}
