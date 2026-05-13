import 'package:flutter/foundation.dart';

/// Whether the field value came from free typing or from the picker sheet.
enum CustomizablePickerInputKind {
  /// User typed text directly into the field.
  typed,

  /// User selected an item (single or multi) through the sheet.
  selected,
}

/// Holds either a typed [String] or a single selected item [T] for
/// [UnifiedCustomizablePickerField] and [UnifiedCustomizableAsyncPickerField].
class CustomizableSinglePickerController<T> extends ChangeNotifier {
  /// Creates a controller with optional initial state.
  CustomizableSinglePickerController({
    this.valueToString,
    CustomizablePickerInputKind initialKind = CustomizablePickerInputKind.selected,
    T? initialSelected,
    String initialTyped = '',
  })  : _kind = initialKind,
        _selected = initialSelected,
        _typedText = initialTyped;

  /// Renders an item to its display text.
  String Function(T value)? valueToString;

  CustomizablePickerInputKind _kind;
  T? _selected;
  String _typedText;

  /// Whether the controller currently holds typed text or a selection.
  CustomizablePickerInputKind get inputKind => _kind;

  /// Non-null only when [inputKind] is [CustomizablePickerInputKind.selected].
  T? get selectedItem => _kind == CustomizablePickerInputKind.selected ? _selected : null;

  /// Meaningful only when [inputKind] is [CustomizablePickerInputKind.typed].
  String get typedText => _kind == CustomizablePickerInputKind.typed ? _typedText : '';

  /// Display text used by the field.
  String get fieldDisplayText {
    switch (_kind) {
      case CustomizablePickerInputKind.selected:
        final v = _selected;
        if (v == null) return '';
        final fn = valueToString;
        return fn != null ? fn(v as T) : v.toString();
      case CustomizablePickerInputKind.typed:
        return _typedText;
    }
  }

  /// Switches to typed mode and updates the typed text.
  void applyTyped(String text) {
    _kind = CustomizablePickerInputKind.typed;
    _typedText = text;
    _selected = null;
    notifyListeners();
  }

  /// Switches to selected mode and updates the selected value.
  void applySelected(T? value) {
    _kind = CustomizablePickerInputKind.selected;
    _selected = value;
    _typedText = '';
    notifyListeners();
  }

  /// Parent-driven reset (e.g. form reload) without notifying.
  void silentReplace({
    required CustomizablePickerInputKind kind,
    T? selected,
    String typed = '',
  }) {
    _kind = kind;
    _selected = selected;
    _typedText = typed;
  }

  /// Call after [silentReplace] to refresh bound widgets.
  void notifyView() => notifyListeners();
}

/// Holds either a typed [String] or a multi selection [List] for
/// [UnifiedCustomizableMultiPickerField] and [UnifiedCustomizableAsyncMultiPickerField].
class CustomizableMultiPickerController<T> extends ChangeNotifier {
  /// Creates a controller with optional initial state.
  CustomizableMultiPickerController({
    this.valueToString,
    CustomizablePickerInputKind initialKind = CustomizablePickerInputKind.selected,
    List<T> initialSelected = const [],
    String initialTyped = '',
  })  : _kind = initialKind,
        _selected = List<T>.from(initialSelected),
        _typedText = initialTyped;

  /// Renders an item to its display text.
  String Function(T value)? valueToString;

  CustomizablePickerInputKind _kind;
  List<T> _selected;
  String _typedText;

  /// Whether the controller currently holds typed text or a selection.
  CustomizablePickerInputKind get inputKind => _kind;

  /// Empty when [inputKind] is [CustomizablePickerInputKind.typed].
  List<T> get selectedItems => _kind == CustomizablePickerInputKind.selected ? List<T>.unmodifiable(_selected) : const [];

  /// Meaningful only when [inputKind] is [CustomizablePickerInputKind.typed].
  String get typedText => _kind == CustomizablePickerInputKind.typed ? _typedText : '';

  /// Display text used by the field (comma-joined selection or typed text).
  String get fieldDisplayText {
    switch (_kind) {
      case CustomizablePickerInputKind.selected:
        final fn = valueToString;
        return _selected.map((e) => fn != null ? fn(e) : e.toString()).join(', ');
      case CustomizablePickerInputKind.typed:
        return _typedText;
    }
  }

  /// Switches to typed mode and updates the typed text.
  void applyTyped(String text) {
    _kind = CustomizablePickerInputKind.typed;
    _typedText = text;
    _selected = const [];
    notifyListeners();
  }

  /// Switches to selected mode and updates the selected values.
  void applySelected(List<T> values) {
    _kind = CustomizablePickerInputKind.selected;
    _selected = List<T>.from(values);
    _typedText = '';
    notifyListeners();
  }

  /// Parent-driven reset (e.g. form reload) without notifying.
  void silentReplace({
    required CustomizablePickerInputKind kind,
    List<T> selected = const [],
    String typed = '',
  }) {
    _kind = kind;
    _selected = List<T>.from(selected);
    _typedText = typed;
  }

  /// Call after [silentReplace] to refresh bound widgets.
  void notifyView() => notifyListeners();
}

// --- Reusable sync for multi picker + domain models --------------------------

/// Sets [controller] to **selected** when [selectedWhenNonEmpty] is non-empty,
/// otherwise to **typed** with [typedWhenEmptySelection].
void syncCustomizableMultiPickerFromSelectionOrTyped<T>({
  required CustomizableMultiPickerController<T> controller,
  required List<T> selectedWhenNonEmpty,
  required String typedWhenEmptySelection,
}) {
  if (selectedWhenNonEmpty.isNotEmpty) {
    controller.silentReplace(
      kind: CustomizablePickerInputKind.selected,
      selected: selectedWhenNonEmpty,
    );
  } else {
    controller.silentReplace(
      kind: CustomizablePickerInputKind.typed,
      typed: typedWhenEmptySelection,
    );
  }
  controller.notifyView();
}

/// Like [syncCustomizableMultiPickerFromSelectionOrTyped] but temporarily removes
/// [listener] so the sync does not echo into parent [onChange] handlers.
void assignCustomizableMultiPickerWithListener<T>(
  CustomizableMultiPickerController<T> controller,
  VoidCallback listener, {
  required List<T> selectedWhenNonEmpty,
  required String typedWhenEmptySelection,
}) {
  controller.removeListener(listener);
  syncCustomizableMultiPickerFromSelectionOrTyped(
    controller: controller,
    selectedWhenNonEmpty: selectedWhenNonEmpty,
    typedWhenEmptySelection: typedWhenEmptySelection,
  );
  controller.addListener(listener);
}
