import 'package:flutter/material.dart';

import '../controllers/base_unified_field_controller.dart';
import 'unified_multi_picker_sheet.dart';
import 'unified_picker_item_builders.dart';
import 'unified_picker_sheet.dart';

/// Whether the field value came from free typing or from the picker sheet.
enum CustomizablePickerInputKind {
  /// User typed text directly into the field.
  typed,

  /// User selected an item (single or multi) through the sheet.
  selected,
}

/// Holds either a typed [String] or a single selected item [T] for
/// [UnifiedCustomizablePickerField] and [UnifiedCustomizableAsyncPickerField].
///
/// Acts as the field's [fieldController] (value, validate, focus, errors).
class CustomizableSinglePickerController<T>
    extends BaseUnifiedFieldController<T> {
  /// Creates a controller with optional initial state.
  CustomizableSinglePickerController({
    this.valueToString,
    CustomizablePickerInputKind initialKind =
        CustomizablePickerInputKind.selected,
    T? initialSelected,
    String initialTyped = '',
    super.validator,
    super.focusNode,
    this.displayValidator,
  }) : _kind = initialKind,
       _selected = initialSelected,
       _typedText = initialTyped,
       super(initialValue: initialSelected);

  /// Renders an item to its display text.
  String Function(T value)? valueToString;

  /// When [inputKind] is [CustomizablePickerInputKind.typed], validates [fieldDisplayText].
  final String? Function(String displayText)? displayValidator;

  CustomizablePickerInputKind _kind;
  T? _selected;
  String _typedText;

  /// Whether the controller currently holds typed text or a selection.
  CustomizablePickerInputKind get inputKind => _kind;

  /// Non-null only when [inputKind] is [CustomizablePickerInputKind.selected].
  T? get selectedItem =>
      _kind == CustomizablePickerInputKind.selected ? _selected : null;

  /// Meaningful only when [inputKind] is [CustomizablePickerInputKind.typed].
  String get typedText =>
      _kind == CustomizablePickerInputKind.typed ? _typedText : '';

  @override
  T? get value => selectedItem;

  @override
  set value(T? next) => applySelected(next);

  /// Display text used by the field.
  String get fieldDisplayText {
    switch (_kind) {
      case CustomizablePickerInputKind.selected:
        final v = _selected;
        if (v == null) return '';
        return unifiedPickerItemLabel(v as T, valueToString: valueToString);
      case CustomizablePickerInputKind.typed:
        return _typedText;
    }
  }

  @override
  String? validate() {
    if (_kind == CustomizablePickerInputKind.typed &&
        displayValidator != null) {
      final err = displayValidator!(fieldDisplayText);
      if (err != null && err.isNotEmpty) {
        setError(err);
        return err;
      }
      clearError();
      return null;
    }
    return super.validate();
  }

  void _revalidateAfterUserEdit() {
    if (hasError) validate();
  }

  /// Switches to typed mode and updates the typed text.
  void applyTyped(String text) {
    _kind = CustomizablePickerInputKind.typed;
    _typedText = text;
    _selected = null;
    silentSetValue(null);
    _revalidateAfterUserEdit();
    notifyListeners();
  }

  /// Switches to selected mode and updates the selected value.
  void applySelected(T? v) {
    _kind = CustomizablePickerInputKind.selected;
    _selected = v;
    _typedText = '';
    silentSetValue(v);
    _revalidateAfterUserEdit();
    notifyListeners();
  }

  @override
  void clear() {
    applySelected(null);
    clearError();
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
    silentSetValue(
      kind == CustomizablePickerInputKind.selected ? selected : null,
    );
  }

  /// Call after [silentReplace] to refresh bound widgets.
  void notifyView() => notifyListeners();

  List<T> _boundItems = const [];
  String _boundLabel = '';
  Future<List<T>> Function()? _boundItemProvider;
  List<T> _boundSuggestion = const [];
  bool _boundHasSearch = true;
  bool _boundSearchAutoFocus = false;
  bool _boundShowClearButton = true;
  String Function(T value)? _boundSearchBuilder;
  Widget Function(T value)? _boundItemToWidget;
  UnifiedPickerGridItemBuilder<T>? _boundGridItemBuilder;
  SliverGridDelegate? _boundGridDelegate;

  /// Registers static picker data for [openPicker] when no field is mounted.
  void bindPicker({
    required List<T> items,
    required String label,
    List<T> suggestion = const [],
    bool hasSearch = true,
    bool searchAutoFocus = false,
    bool showClearButton = true,
    String Function(T value)? searchBuilder,
    Widget Function(T value)? itemToWidget,
    UnifiedPickerGridItemBuilder<T>? gridItemBuilder,
    SliverGridDelegate? gridDelegate,
  }) {
    _boundItems = items;
    _boundLabel = label;
    _boundItemProvider = null;
    _boundSuggestion = suggestion;
    _boundHasSearch = hasSearch;
    _boundSearchAutoFocus = searchAutoFocus;
    _boundShowClearButton = showClearButton;
    _boundSearchBuilder = searchBuilder;
    _boundItemToWidget = itemToWidget;
    _boundGridItemBuilder = gridItemBuilder;
    _boundGridDelegate = gridDelegate;
  }

  /// Registers async picker data for [openPicker] when no field is mounted.
  void bindAsyncPicker({
    required Future<List<T>> Function() itemProvider,
    required String label,
    List<T> suggestion = const [],
    bool hasSearch = true,
    bool searchAutoFocus = false,
    bool showClearButton = true,
    String Function(T value)? searchBuilder,
    Widget Function(T value)? itemToWidget,
    UnifiedPickerGridItemBuilder<T>? gridItemBuilder,
    SliverGridDelegate? gridDelegate,
  }) {
    _boundItemProvider = itemProvider;
    _boundLabel = label;
    _boundItems = const [];
    _boundSuggestion = suggestion;
    _boundHasSearch = hasSearch;
    _boundSearchAutoFocus = searchAutoFocus;
    _boundShowClearButton = showClearButton;
    _boundSearchBuilder = searchBuilder;
    _boundItemToWidget = itemToWidget;
    _boundGridItemBuilder = gridItemBuilder;
    _boundGridDelegate = gridDelegate;
  }

  /// Sheet title used when opening without an attached field.
  void bindPickerLabel(String label) => _boundLabel = label;

  T? get _sheetSeedValue =>
      _kind == CustomizablePickerInputKind.selected ? _selected : null;

  /// Opens the picker sheet (same as tapping the bound field when mounted).
  Future<T?> openPicker(BuildContext context, {String? label}) async {
    final opener = attachedFieldOpener;
    if (opener != null) {
      await opener(context);
      return selectedItem;
    }
    final resolvedLabel = label ?? _boundLabel;
    List<T> items = _boundItems;
    final provider = _boundItemProvider;
    if (provider != null) {
      items = await provider();
      if (!context.mounted) return selectedItem;
    }
    assert(
      items.isNotEmpty,
      'CustomizableSinglePickerController.openPicker: mount the field first, '
      'or call bindPicker / bindAsyncPicker with items.',
    );
    final result = await showUnifiedSinglePickerSheet<T>(
      context: context,
      items: items,
      label: resolvedLabel,
      value: _sheetSeedValue,
      suggestion: _boundSuggestion,
      hasSearch: _boundHasSearch,
      hasClear: _boundShowClearButton,
      searchAutoFocus: _boundSearchAutoFocus,
      searchBuilder: _boundSearchBuilder,
      valueToString: valueToString,
      itemToWidget: _boundItemToWidget,
      gridItemBuilder: _boundGridItemBuilder,
      gridDelegate: _boundGridDelegate,
    );
    if (result == null) {
      applySelected(null);
    } else {
      applySelected(result);
    }
    return selectedItem;
  }
}

/// Holds either a typed [String] or a multi selection [List] for
/// [UnifiedCustomizableMultiPickerField] and [UnifiedCustomizableAsyncMultiPickerField].
class CustomizableMultiPickerController<T>
    extends BaseUnifiedFieldController<List<T>> {
  /// Creates a controller with optional initial state.
  CustomizableMultiPickerController({
    this.valueToString,
    CustomizablePickerInputKind initialKind =
        CustomizablePickerInputKind.selected,
    List<T> initialSelected = const [],
    String initialTyped = '',
    super.validator,
    super.focusNode,
    this.displayValidator,
  }) : _kind = initialKind,
       _selected = List<T>.from(initialSelected),
       _typedText = initialTyped,
       super(initialValue: List<T>.from(initialSelected));

  /// Renders an item to its display text.
  String Function(T value)? valueToString;

  /// When [inputKind] is [CustomizablePickerInputKind.typed], validates [fieldDisplayText].
  final String? Function(String displayText)? displayValidator;

  CustomizablePickerInputKind _kind;
  List<T> _selected;
  String _typedText;

  /// Whether the controller currently holds typed text or a selection.
  CustomizablePickerInputKind get inputKind => _kind;

  /// Empty when [inputKind] is [CustomizablePickerInputKind.typed].
  List<T> get selectedItems => _kind == CustomizablePickerInputKind.selected
      ? List<T>.unmodifiable(_selected)
      : const [];

  /// Meaningful only when [inputKind] is [CustomizablePickerInputKind.typed].
  String get typedText =>
      _kind == CustomizablePickerInputKind.typed ? _typedText : '';

  @override
  List<T>? get value => _kind == CustomizablePickerInputKind.selected
      ? List<T>.from(_selected)
      : null;

  @override
  set value(List<T>? next) => applySelected(next ?? <T>[]);

  /// Display text used by the field (comma-joined selection or typed text).
  String get fieldDisplayText {
    switch (_kind) {
      case CustomizablePickerInputKind.selected:
        return _selected
            .map(
              (e) => unifiedPickerItemLabel(e, valueToString: valueToString),
            )
            .join(', ');
      case CustomizablePickerInputKind.typed:
        return _typedText;
    }
  }

  @override
  String? validate() {
    if (_kind == CustomizablePickerInputKind.typed &&
        displayValidator != null) {
      final err = displayValidator!(fieldDisplayText);
      if (err != null && err.isNotEmpty) {
        setError(err);
        return err;
      }
      clearError();
      return null;
    }
    return super.validate();
  }

  void _revalidateAfterUserEdit() {
    if (hasError) validate();
  }

  /// Switches to typed mode and updates the typed text.
  void applyTyped(String text) {
    _kind = CustomizablePickerInputKind.typed;
    _typedText = text;
    _selected = const [];
    silentSetValue(null);
    _revalidateAfterUserEdit();
    notifyListeners();
  }

  /// Switches to selected mode and updates the selected values.
  void applySelected(List<T> values) {
    _kind = CustomizablePickerInputKind.selected;
    _selected = List<T>.from(values);
    _typedText = '';
    silentSetValue(_selected);
    _revalidateAfterUserEdit();
    notifyListeners();
  }

  @override
  void clear() {
    applySelected(<T>[]);
    clearError();
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
    silentSetValue(
      kind == CustomizablePickerInputKind.selected ? _selected : null,
    );
  }

  /// Call after [silentReplace] to refresh bound widgets.
  void notifyView() => notifyListeners();

  List<T> _boundItems = const [];
  String _boundLabel = '';
  Future<List<T>> Function()? _boundItemProvider;
  List<T> _boundSuggestion = const [];
  bool _boundHasSearch = true;
  bool _boundSearchAutoFocus = false;
  bool _boundShowClearButton = true;
  String Function(T value)? _boundSearchBuilder;
  Widget Function(T value)? _boundItemToWidget;
  UnifiedPickerMultiGridItemBuilder<T>? _boundGridItemBuilder;
  SliverGridDelegate? _boundGridDelegate;

  /// Registers static picker data for [openPicker] when no field is mounted.
  void bindPicker({
    required List<T> items,
    required String label,
    List<T> suggestion = const [],
    bool hasSearch = true,
    bool searchAutoFocus = false,
    bool showClearButton = true,
    String Function(T value)? searchBuilder,
    Widget Function(T value)? itemToWidget,
    UnifiedPickerMultiGridItemBuilder<T>? gridItemBuilder,
    SliverGridDelegate? gridDelegate,
  }) {
    _boundItems = items;
    _boundLabel = label;
    _boundItemProvider = null;
    _boundSuggestion = suggestion;
    _boundHasSearch = hasSearch;
    _boundSearchAutoFocus = searchAutoFocus;
    _boundShowClearButton = showClearButton;
    _boundSearchBuilder = searchBuilder;
    _boundItemToWidget = itemToWidget;
    _boundGridItemBuilder = gridItemBuilder;
    _boundGridDelegate = gridDelegate;
  }

  /// Registers async picker data for [openPicker] when no field is mounted.
  void bindAsyncPicker({
    required Future<List<T>> Function() itemProvider,
    required String label,
    List<T> suggestion = const [],
    bool hasSearch = true,
    bool searchAutoFocus = false,
    bool showClearButton = true,
    String Function(T value)? searchBuilder,
    Widget Function(T value)? itemToWidget,
    UnifiedPickerMultiGridItemBuilder<T>? gridItemBuilder,
    SliverGridDelegate? gridDelegate,
  }) {
    _boundItemProvider = itemProvider;
    _boundLabel = label;
    _boundItems = const [];
    _boundSuggestion = suggestion;
    _boundHasSearch = hasSearch;
    _boundSearchAutoFocus = searchAutoFocus;
    _boundShowClearButton = showClearButton;
    _boundSearchBuilder = searchBuilder;
    _boundItemToWidget = itemToWidget;
    _boundGridItemBuilder = gridItemBuilder;
    _boundGridDelegate = gridDelegate;
  }

  /// Sheet title used when opening without an attached field.
  void bindPickerLabel(String label) => _boundLabel = label;

  List<T> get _sheetSeedValues =>
      _kind == CustomizablePickerInputKind.selected
          ? List<T>.from(_selected)
          : <T>[];

  /// Opens the multi picker sheet (same as tapping the bound field when mounted).
  Future<List<T>?> openPicker(BuildContext context, {String? label}) async {
    final opener = attachedFieldOpener;
    if (opener != null) {
      await opener(context);
      return selectedItems;
    }
    final resolvedLabel = label ?? _boundLabel;
    List<T> items = _boundItems;
    final provider = _boundItemProvider;
    if (provider != null) {
      items = await provider();
      if (!context.mounted) return selectedItems;
    }
    assert(
      items.isNotEmpty,
      'CustomizableMultiPickerController.openPicker: mount the field first, '
      'or call bindPicker / bindAsyncPicker with items.',
    );
    final result = await showUnifiedMultiPickerSheet<T>(
      context: context,
      items: items,
      label: resolvedLabel,
      values: _sheetSeedValues,
      suggestion: _boundSuggestion,
      hasSearch: _boundHasSearch,
      hasClear: _boundShowClearButton,
      searchAutoFocus: _boundSearchAutoFocus,
      searchBuilder: _boundSearchBuilder,
      valueToString: valueToString,
      itemToWidget: _boundItemToWidget,
      gridItemBuilder: _boundGridItemBuilder,
      gridDelegate: _boundGridDelegate,
    );
    if (result != null) {
      applySelected(result);
    }
    return selectedItems;
  }
}

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
