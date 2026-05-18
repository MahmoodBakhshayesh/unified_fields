import 'package:flutter/widgets.dart';

/// Base listenable handle for unified fields (value, errors, focus, validation).
///
/// Mirrors the role of [TextEditingController] for non-text fields and can be
/// composed with field widgets via their `fieldController` parameter.
abstract class BaseUnifiedFieldController<T> extends ChangeNotifier {
  /// Creates a controller with optional [initialValue], [validator], and [focusNode].
  BaseUnifiedFieldController({
    T? initialValue,
    this.validator,
    FocusNode? focusNode,
  })  : _value = initialValue,
        _focusNode = focusNode,
        _ownsFocusNode = focusNode == null;

  T? _value;
  String? _errorText;

  /// Imperative validator; return an error message or null when valid.
  String? Function(T? value)? validator;
  final FocusNode? _focusNode;
  final bool _ownsFocusNode;

  /// Focus node shared with the bound field widget.
  late final FocusNode focusNode = _focusNode ?? FocusNode();

  Future<void> Function(BuildContext context)? _attachedFieldOpener;
  FocusNode? _attachedFocusNode;

  /// Opener registered by the bound field widget (same behavior as tapping the field).
  @protected
  Future<void> Function(BuildContext context)? get attachedFieldOpener =>
      _attachedFieldOpener;

  /// Current field value (may be null).
  T? get value => _value;

  /// Updates [value] and notifies listeners when it changes.
  ///
  /// When already in error, only clears the error if the new value passes
  /// [validator] (does not set new errors while the user edits).
  set value(T? next) => applyValueFromUser(next);

  /// User-driven value update (typing, picker selection, etc.).
  @protected
  void applyValueFromUser(T? next) {
    final changed = _value != next;
    if (changed) {
      _value = next;
    }
    _clearErrorIfValueNowValid();
    if (changed) {
      notifyListeners();
    }
  }

  /// Clears [errorText] when [validator] accepts the current [_value].
  void _clearErrorIfValueNowValid() {
    if (!hasError) return;
    final err = validator?.call(_value);
    if (err == null || err.isEmpty) {
      clearError();
    }
  }

  /// Last validation / API error shown on the field.
  String? get errorText => _errorText;

  /// True when [errorText] is non-empty.
  bool get hasError => _errorText?.isNotEmpty ?? false;

  /// Whether the value is considered empty (null for most types).
  bool get isEmpty => _value == null;

  /// Replace bound value without notifying (batch updates).
  void silentSetValue(T? next) => _value = next;

  /// Sets [errorText] and notifies listeners.
  void setError(String? message) {
    if (_errorText == message) return;
    _errorText = message;
    notifyListeners();
  }

  /// Clears the error message.
  void clearError() => setError(null);

  /// Runs [validator], updates [errorText], and returns the error (if any).
  String? validate() {
    final err = validator?.call(_value);
    if (err != null && err.isNotEmpty) {
      setError(err);
      return err;
    }
    clearError();
    return null;
  }

  /// Resets value to null and clears errors.
  void clear() {
    silentSetValue(null);
    clearError();
    notifyListeners();
  }

  /// Registers the field's picker opener. Pass `null` on dispose.
  void attachFieldOpener(Future<void> Function(BuildContext context)? opener) {
    _attachedFieldOpener = opener;
  }

  /// Registers the [FocusNode] wired on the bound field widget.
  ///
  /// When only a [binding] is used, call [requestFocus] on the binding and it
  /// will target this node (same as [fieldController]'s node when both are set).
  void attachFocusTarget(FocusNode? node) {
    _attachedFocusNode = node;
  }

  /// Requests keyboard / focus for the bound field.
  void requestFocus() {
    final node = _attachedFocusNode ?? focusNode;
    if (!node.canRequestFocus) return;
    node.requestFocus();
  }

  /// Removes focus from the bound field.
  void unfocus() => focusNode.unfocus();

  @override
  void dispose() {
    if (_ownsFocusNode) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
