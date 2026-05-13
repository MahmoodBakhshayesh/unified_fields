import 'package:flutter/foundation.dart';

/// External handle to read/update unified field values (pickers, dates, durations, etc.).
///
/// Listen with [Listenable.merge] or attach to [AnimatedBuilder]; widgets sync both ways when bound.
class AppInputController<T> extends ChangeNotifier {
  AppInputController({T? initialValue}) : _value = initialValue;

  T? _value;

  String? _errorText;

  T? get value => _value;

  String? get errorText => _errorText;

  bool get hasError => (_errorText?.isNotEmpty ?? false);

  set value(T? next) {
    if (_value == next) return;
    _value = next;
    notifyListeners();
  }

  /// Replace bound value without notifying (e.g. batch updates); call [notifyListeners] yourself if needed.
  void silentSetValue(T? next) {
    _value = next;
  }

  void setError(String? message) {
    _errorText = message;
    notifyListeners();
  }

  void clearError() => setError(null);

  void clear() {
    value = null;
    clearError();
  }
}
