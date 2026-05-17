import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Base listenable handle for unified fields (value, errors, focus, validation).
///
/// Mirrors the role of [TextEditingController] for non-text fields and can be
/// composed with field widgets via their `fieldController` parameter.
abstract class BaseUnifiedFieldController<T> extends ChangeNotifier {
  /// Creates a controller with optional [initialValue], [validator], and [focusNode].
  BaseUnifiedFieldController({
    T? initialValue,
    String? Function(T? value)? validator,
    FocusNode? focusNode,
  })  : _value = initialValue,
        _validator = validator,
        _focusNode = focusNode,
        _ownsFocusNode = focusNode == null;

  T? _value;
  String? _errorText;
  String? Function(T? value)? _validator;
  final FocusNode? _focusNode;
  final bool _ownsFocusNode;

  /// Focus node shared with the bound field widget.
  late final FocusNode focusNode = _focusNode ?? FocusNode();

  Future<void> Function(BuildContext context)? _attachedFieldOpener;
  FocusNode? _attachedFocusNode;

  /// Opener registered by the bound field widget (same behavior as tapping the field).
  @protected
  Future<void> Function(BuildContext context)? get attachedFieldOpener => _attachedFieldOpener;

  /// Current field value (may be null).
  T? get value => _value;

  /// Updates [value] and notifies listeners when it changes.
  set value(T? next) {
    if (_value == next) return;
    _value = next;
    notifyListeners();
  }

  /// Imperative validator; return an error message or null when valid.
  String? Function(T? value)? get validator => _validator;

  set validator(String? Function(T? value)? fn) {
    _validator = fn;
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
    final err = _validator?.call(_value);
    if (err != null && err.isNotEmpty) {
      setError(err);
      return err;
    }
    clearError();
    return null;
  }

  /// Resets value to null and clears errors.
  void clear() {
    value = null;
    clearError();
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
