import 'package:flutter/material.dart';

import '../controllers/field_controller_sync.dart';
import 'unified_customizable_async_picker_field.dart';
import 'unified_customizable_picker_controller.dart';
import 'unified_customizable_picker_fields.dart';
import 'unified_form_fields.dart';
import 'unified_input_brightness.dart';
import 'unified_input_decoration.dart';
import 'unified_picker_item_builders.dart';
import 'unified_picker_sheet_style.dart';

/// Reset-time snapshot for a [CustomizableSinglePickerController].
///
/// Use one of the factory constructors when wiring `resetValue` on
/// [UnifiedFormCustomizablePickerField] or
/// [UnifiedFormCustomizableAsyncPickerField]:
///
/// * `CustomizableSinglePickerSnapshot.typed('hello')`
/// * `CustomizableSinglePickerSnapshot.selected(someItem)`
/// * `CustomizableSinglePickerSnapshot.empty()`
@immutable
class CustomizableSinglePickerSnapshot<T> {
  /// Snapshot describing typed text mode.
  const CustomizableSinglePickerSnapshot.typed(String text)
    : kind = CustomizablePickerInputKind.typed,
      selectedItem = null,
      typedText = text;

  /// Snapshot describing a single selection (may be `null` to clear).
  const CustomizableSinglePickerSnapshot.selected(T? selected)
    : kind = CustomizablePickerInputKind.selected,
      selectedItem = selected,
      typedText = '';

  /// Empty snapshot (selected mode, `null` value).
  const CustomizableSinglePickerSnapshot.empty()
    : kind = CustomizablePickerInputKind.selected,
      selectedItem = null,
      typedText = '';

  /// Whether the snapshot represents typed text or a selection.
  final CustomizablePickerInputKind kind;

  /// Selected value when [kind] is [CustomizablePickerInputKind.selected].
  final T? selectedItem;

  /// Typed text when [kind] is [CustomizablePickerInputKind.typed].
  final String typedText;
}

/// Reset-time snapshot for a [CustomizableMultiPickerController].
@immutable
class CustomizableMultiPickerSnapshot<T> {
  /// Snapshot describing typed text mode.
  const CustomizableMultiPickerSnapshot.typed(String text)
    : kind = CustomizablePickerInputKind.typed,
      selectedItems = const [],
      typedText = text;

  /// Snapshot describing a multi selection.
  const CustomizableMultiPickerSnapshot.selected(List<T> items)
    : kind = CustomizablePickerInputKind.selected,
      selectedItems = items,
      typedText = '';

  /// Empty snapshot (selected mode, empty list).
  const CustomizableMultiPickerSnapshot.empty()
    : kind = CustomizablePickerInputKind.selected,
      selectedItems = const [],
      typedText = '';

  /// Whether the snapshot represents typed text or a multi selection.
  final CustomizablePickerInputKind kind;

  /// Selected values when [kind] is [CustomizablePickerInputKind.selected].
  final List<T> selectedItems;

  /// Typed text when [kind] is [CustomizablePickerInputKind.typed].
  final String typedText;
}

/// Form-aware wrapper around [UnifiedCustomizablePickerField].
///
/// The displayed value (typed text or selected `T`) is owned by [pickerController].
/// The [FormField] tracks the latest [CustomizableSinglePickerController] snapshot so
/// [FormState.validate] / [FormState.save] / [FormState.reset] all flow through the
/// existing unified shell.
///
/// **Reset**
/// - When [resetValue] is non-null, [FormState.reset] applies the returned
///   [CustomizableSinglePickerSnapshot] silently to the controller and notifies once.
/// - When [resetValue] is null, reset does not change the controller.
class UnifiedFormCustomizablePickerField<T> extends StatefulWidget {
  /// Creates a [Form]-aware customizable single-select picker field.
  const UnifiedFormCustomizablePickerField({
    super.key,
    required this.items,
    required this.label,
    required this.pickerController,
    this.decoration,
    this.decorationSet,
    this.brightness,
    this.allowFreeText = true,
    this.valueToString,
    this.searchBuilder,
    this.itemToWidget,
    this.gridItemBuilder,
    this.gridDelegate,
    this.suggestion = const [],
    this.hasSearch = true,
    this.searchAutoFocus = false,
    this.showClearButton = true,
    this.locked = false,
    this.isDisabled = false,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.resetValue,
    this.placeholder,
    this.isRequired = false,
    this.shakeOnError = false,
    this.pickerSheetStyle,
    this.pickerSheetBackgroundColor,
    this.pickerHeaderStyle,
  });

  /// Choices shown in the picker sheet.
  final List<T> items;

  /// Label for the field and sheet title fallback.
  final String label;

  /// Hint text shown when empty.
  final String? placeholder;

  /// Visual chrome.
  final UnifiedInputDecoration? decoration;

  /// Per-state decorations (focus, error, valid, locked, disabled, …).
  final UnifiedInputDecorationSet? decorationSet;

  /// Override [Theme] brightness for the unified palette.
  final UnifiedInputBrightness? brightness;

  /// Controller holding either typed text or a single selected `T`.
  final CustomizableSinglePickerController<T> pickerController;

  /// If false, the inner text field is read-only and tapping opens the sheet.
  final bool allowFreeText;

  /// Renders an item to its display text.
  final String Function(T value)? valueToString;

  /// Custom searchable text per item.
  final String Function(T value)? searchBuilder;

  /// Custom row builder inside the sheet (list layout).
  final Widget Function(T value)? itemToWidget;

  /// Custom grid tile builder; when set, the sheet uses a [GridView].
  final UnifiedPickerGridItemBuilder<T>? gridItemBuilder;

  /// Grid layout when [gridItemBuilder] is set. Defaults to [unifiedPickerDefaultGridDelegate].
  final SliverGridDelegate? gridDelegate;

  /// Optional suggestion list pinned above the searchable list.
  final List<T> suggestion;

  /// Whether the sheet shows a search field.
  final bool hasSearch;

  /// Autofocus the search field on open.
  final bool searchAutoFocus;

  /// Show a Clear button in the sheet header.
  final bool showClearButton;

  /// When true, the field is non-interactive.
  final bool locked;

  /// When true, greys out the label and shows a forbid suffix icon.
  final bool isDisabled;

  /// Validator on the current snapshot.
  final FormFieldValidator<CustomizableSinglePickerController<T>>? validator;

  /// Save callback. Receives the latest [pickerController] reference.
  final FormFieldSetter<CustomizableSinglePickerController<T>>? onSaved;

  /// Notified when the user types or selects a value.
  final ValueChanged<CustomizableSinglePickerController<T>>? onChanged;

  /// When non-null, [FormState.reset] restores the controller to this snapshot.
  final UnifiedFormResetValue<CustomizableSinglePickerSnapshot<T>>? resetValue;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  /// When true, shakes once when validation error appears on this field.
  final bool shakeOnError;

  /// Local picker sheet chrome; overrides theme when set.
  final UnifiedPickerSheetStyle? pickerSheetStyle;

  /// Sheet background override (wins over [pickerSheetStyle] and theme).
  final Color? pickerSheetBackgroundColor;

  /// Header override (wins over [pickerSheetStyle] and theme).
  final UnifiedInputPickerHeaderStyle? pickerHeaderStyle;

  @override
  State<UnifiedFormCustomizablePickerField<T>> createState() =>
      _UnifiedFormCustomizablePickerFieldState<T>();
}

class _UnifiedFormCustomizablePickerFieldState<T>
    extends State<UnifiedFormCustomizablePickerField<T>> {
  final GlobalKey<FormFieldState<CustomizableSinglePickerController<T>>>
  _fieldKey =
      GlobalKey<FormFieldState<CustomizableSinglePickerController<T>>>();

  void _onControllerChanged() {
    final fieldState = _fieldKey.currentState;
    if (fieldState == null) return;
    fieldState.didChange(widget.pickerController);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unifiedFormClearErrorIfValid(fieldState);
    });
  }

  @override
  void initState() {
    super.initState();
    widget.pickerController.addListener(_onControllerChanged);
    syncCustomizableSingleFormValidatorToFieldController(
      widget.pickerController,
      widget.validator,
    );
  }

  @override
  void didUpdateWidget(
    covariant UnifiedFormCustomizablePickerField<T> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pickerController != widget.pickerController) {
      oldWidget.pickerController.removeListener(_onControllerChanged);
      widget.pickerController.addListener(_onControllerChanged);
    }
    if (oldWidget.validator != widget.validator ||
        oldWidget.pickerController != widget.pickerController) {
      syncCustomizableSingleFormValidatorToFieldController(
        widget.pickerController,
        widget.validator,
      );
    }
  }

  @override
  void dispose() {
    widget.pickerController.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _applyReset() {
    final fn = widget.resetValue;
    if (fn == null) return;
    final snap = fn();
    widget.pickerController.silentReplace(
      kind: snap.kind,
      selected: snap.selectedItem,
      typed: snap.typedText,
    );
    widget.pickerController.notifyView();
  }

  @override
  Widget build(BuildContext context) {
    syncCustomizableSingleFormValidatorToFieldController(
      widget.pickerController,
      widget.validator,
    );
    return UnifiedFormField<CustomizableSinglePickerController<T>>(
      formFieldKey: _fieldKey,
      initialValue: widget.pickerController,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onReset: _applyReset,
      shakeOnError: widget.shakeOnError,
      builder: (context, fieldState) {
        return UnifiedCustomizablePickerField<T>(
          items: widget.items,
          label: widget.label,
          pickerController: widget.pickerController,
          decoration: widget.decoration,
          decorationSet: widget.decorationSet,
          brightness: widget.brightness,
          allowFreeText: widget.allowFreeText,
          valueToString: widget.valueToString,
          searchBuilder: widget.searchBuilder,
          itemToWidget: widget.itemToWidget,
          gridItemBuilder: widget.gridItemBuilder,
          gridDelegate: widget.gridDelegate,
          suggestion: widget.suggestion,
          hasSearch: widget.hasSearch,
          searchAutoFocus: widget.searchAutoFocus,
          showClearButton: widget.showClearButton,
          locked: widget.locked,
          isDisabled: widget.isDisabled,
          placeholder: widget.placeholder,
          isRequired: widget.isRequired,
          onChanged: widget.onChanged,
          pickerSheetStyle: widget.pickerSheetStyle,
          pickerSheetBackgroundColor: widget.pickerSheetBackgroundColor,
          pickerHeaderStyle: widget.pickerHeaderStyle,
          validator: (_) {
            final err = fieldState.errorText;
            return (err == null || err.isEmpty) ? null : err;
          },
        );
      },
    );
  }
}

/// Form-aware wrapper around [UnifiedCustomizableMultiPickerField].
class UnifiedFormCustomizableMultiPickerField<T> extends StatefulWidget {
  /// Creates a [Form]-aware customizable multi-select picker field.
  const UnifiedFormCustomizableMultiPickerField({
    super.key,
    required this.items,
    required this.label,
    required this.pickerController,
    this.decoration,
    this.decorationSet,
    this.brightness,
    this.allowFreeText = true,
    this.valueToString,
    this.searchBuilder,
    this.itemToWidget,
    this.gridItemBuilder,
    this.gridDelegate,
    this.suggestion = const [],
    this.hasSearch = true,
    this.searchAutoFocus = false,
    this.showClearButton = true,
    this.locked = false,
    this.isDisabled = false,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.resetValue,
    this.placeholder,
    this.isRequired = false,
    this.shakeOnError = false,
    this.pickerSheetStyle,
    this.pickerSheetBackgroundColor,
    this.pickerHeaderStyle,
  });

  /// Choices shown in the picker sheet.
  final List<T> items;

  /// Label for the field and sheet title fallback.
  final String label;

  /// Hint text shown when empty.
  final String? placeholder;

  /// Visual chrome.
  final UnifiedInputDecoration? decoration;

  /// Per-state decorations (focus, error, valid, locked, disabled, …).
  final UnifiedInputDecorationSet? decorationSet;

  /// Override [Theme] brightness for the unified palette.
  final UnifiedInputBrightness? brightness;

  /// Controller holding either typed text or a `List` of selected `T`.
  final CustomizableMultiPickerController<T> pickerController;

  /// If false, the inner text field is read-only and tapping opens the sheet.
  final bool allowFreeText;

  /// Renders an item to its display text.
  final String Function(T value)? valueToString;

  /// Custom searchable text per item.
  final String Function(T value)? searchBuilder;

  /// Custom row builder inside the sheet (list layout).
  final Widget Function(T value)? itemToWidget;

  /// Custom grid tile builder; when set, the sheet uses a [GridView].
  final UnifiedPickerMultiGridItemBuilder<T>? gridItemBuilder;

  /// Grid layout when [gridItemBuilder] is set. Defaults to [unifiedPickerDefaultGridDelegate].
  final SliverGridDelegate? gridDelegate;

  /// Optional suggestion list pinned above the searchable list.
  final List<T> suggestion;

  /// Whether the sheet shows a search field.
  final bool hasSearch;

  /// Autofocus the search field on open.
  final bool searchAutoFocus;

  /// Show a Clear button in the sheet header.
  final bool showClearButton;

  /// When true, the field is non-interactive.
  final bool locked;

  /// When true, greys out the label and shows a forbid suffix icon.
  final bool isDisabled;

  /// Validator on the current snapshot.
  final FormFieldValidator<CustomizableMultiPickerController<T>>? validator;

  /// Save callback. Receives the latest [pickerController] reference.
  final FormFieldSetter<CustomizableMultiPickerController<T>>? onSaved;

  /// Notified when the user types or selects values.
  final ValueChanged<CustomizableMultiPickerController<T>>? onChanged;

  /// When non-null, [FormState.reset] restores the controller to this snapshot.
  final UnifiedFormResetValue<CustomizableMultiPickerSnapshot<T>>? resetValue;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  /// When true, shakes once when validation error appears on this field.
  final bool shakeOnError;

  /// Local picker sheet chrome; overrides theme when set.
  final UnifiedPickerSheetStyle? pickerSheetStyle;

  /// Sheet background override (wins over [pickerSheetStyle] and theme).
  final Color? pickerSheetBackgroundColor;

  /// Header override (wins over [pickerSheetStyle] and theme).
  final UnifiedInputPickerHeaderStyle? pickerHeaderStyle;

  @override
  State<UnifiedFormCustomizableMultiPickerField<T>> createState() =>
      _UnifiedFormCustomizableMultiPickerFieldState<T>();
}

class _UnifiedFormCustomizableMultiPickerFieldState<T>
    extends State<UnifiedFormCustomizableMultiPickerField<T>> {
  final GlobalKey<FormFieldState<CustomizableMultiPickerController<T>>>
  _fieldKey = GlobalKey<FormFieldState<CustomizableMultiPickerController<T>>>();

  void _onControllerChanged() {
    final fieldState = _fieldKey.currentState;
    if (fieldState == null) return;
    fieldState.didChange(widget.pickerController);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unifiedFormClearErrorIfValid(fieldState);
    });
  }

  @override
  void initState() {
    super.initState();
    widget.pickerController.addListener(_onControllerChanged);
    syncCustomizableMultiFormValidatorToFieldController(
      widget.pickerController,
      widget.validator,
    );
  }

  @override
  void didUpdateWidget(
    covariant UnifiedFormCustomizableMultiPickerField<T> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pickerController != widget.pickerController) {
      oldWidget.pickerController.removeListener(_onControllerChanged);
      widget.pickerController.addListener(_onControllerChanged);
    }
    if (oldWidget.validator != widget.validator ||
        oldWidget.pickerController != widget.pickerController) {
      syncCustomizableMultiFormValidatorToFieldController(
        widget.pickerController,
        widget.validator,
      );
    }
  }

  @override
  void dispose() {
    widget.pickerController.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _applyReset() {
    final fn = widget.resetValue;
    if (fn == null) return;
    final snap = fn();
    widget.pickerController.silentReplace(
      kind: snap.kind,
      selected: snap.selectedItems,
      typed: snap.typedText,
    );
    widget.pickerController.notifyView();
  }

  @override
  Widget build(BuildContext context) {
    syncCustomizableMultiFormValidatorToFieldController(
      widget.pickerController,
      widget.validator,
    );
    return UnifiedFormField<CustomizableMultiPickerController<T>>(
      formFieldKey: _fieldKey,
      initialValue: widget.pickerController,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onReset: _applyReset,
      shakeOnError: widget.shakeOnError,
      builder: (context, fieldState) {
        return UnifiedCustomizableMultiPickerField<T>(
          items: widget.items,
          label: widget.label,
          pickerController: widget.pickerController,
          decoration: widget.decoration,
          decorationSet: widget.decorationSet,
          brightness: widget.brightness,
          allowFreeText: widget.allowFreeText,
          valueToString: widget.valueToString,
          searchBuilder: widget.searchBuilder,
          itemToWidget: widget.itemToWidget,
          gridItemBuilder: widget.gridItemBuilder,
          gridDelegate: widget.gridDelegate,
          suggestion: widget.suggestion,
          hasSearch: widget.hasSearch,
          searchAutoFocus: widget.searchAutoFocus,
          showClearButton: widget.showClearButton,
          locked: widget.locked,
          isDisabled: widget.isDisabled,
          placeholder: widget.placeholder,
          isRequired: widget.isRequired,
          onChanged: widget.onChanged,
          pickerSheetStyle: widget.pickerSheetStyle,
          pickerSheetBackgroundColor: widget.pickerSheetBackgroundColor,
          pickerHeaderStyle: widget.pickerHeaderStyle,
          validator: (_) {
            final err = fieldState.errorText;
            return (err == null || err.isEmpty) ? null : err;
          },
        );
      },
    );
  }
}

/// Form-aware wrapper around [UnifiedCustomizableAsyncPickerField].
class UnifiedFormCustomizableAsyncPickerField<T> extends StatefulWidget {
  /// Creates a [Form]-aware customizable async single-select picker field.
  const UnifiedFormCustomizableAsyncPickerField({
    super.key,
    required this.itemProvider,
    required this.label,
    required this.pickerController,
    this.decoration,
    this.decorationSet,
    this.brightness,
    this.allowFreeText = true,
    this.valueToString,
    this.searchBuilder,
    this.itemToWidget,
    this.gridItemBuilder,
    this.gridDelegate,
    this.suggestion = const [],
    this.hasSearch = true,
    this.searchAutoFocus = false,
    this.showClearButton = true,
    this.locked = false,
    this.isDisabled = false,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.resetValue,
    this.placeholder,
    this.isRequired = false,
    this.shakeOnError = false,
    this.pickerSheetStyle,
    this.pickerSheetBackgroundColor,
    this.pickerHeaderStyle,
  });

  /// Fetched when the user opens the picker.
  final Future<List<T>> Function() itemProvider;

  /// Label for the field and sheet title fallback.
  final String label;

  /// Hint text shown when empty.
  final String? placeholder;

  /// Visual chrome.
  final UnifiedInputDecoration? decoration;

  /// Per-state decorations (focus, error, valid, locked, disabled, …).
  final UnifiedInputDecorationSet? decorationSet;

  /// Override [Theme] brightness for the unified palette.
  final UnifiedInputBrightness? brightness;

  /// Controller holding either typed text or a single selected `T`.
  final CustomizableSinglePickerController<T> pickerController;

  /// If false, the inner text field is read-only and tapping opens the sheet (after load).
  final bool allowFreeText;

  /// Renders an item to its display text.
  final String Function(T value)? valueToString;

  /// Custom searchable text per item.
  final String Function(T value)? searchBuilder;

  /// Custom row builder inside the sheet (list layout).
  final Widget Function(T value)? itemToWidget;

  /// Custom grid tile builder; when set, the sheet uses a [GridView].
  final UnifiedPickerGridItemBuilder<T>? gridItemBuilder;

  /// Grid layout when [gridItemBuilder] is set. Defaults to [unifiedPickerDefaultGridDelegate].
  final SliverGridDelegate? gridDelegate;

  /// Optional suggestion list pinned above the searchable list.
  final List<T> suggestion;

  /// Whether the sheet shows a search field.
  final bool hasSearch;

  /// Autofocus the search field on open.
  final bool searchAutoFocus;

  /// Show a Clear button in the sheet header.
  final bool showClearButton;

  /// When true, the field is non-interactive.
  final bool locked;

  /// When true, greys out the label and shows a forbid suffix icon.
  final bool isDisabled;

  /// Validator on the current snapshot.
  final FormFieldValidator<CustomizableSinglePickerController<T>>? validator;

  /// Save callback. Receives the latest [pickerController] reference.
  final FormFieldSetter<CustomizableSinglePickerController<T>>? onSaved;

  /// Notified when the user types or selects a value.
  final ValueChanged<CustomizableSinglePickerController<T>>? onChanged;

  /// When non-null, [FormState.reset] restores the controller to this snapshot.
  final UnifiedFormResetValue<CustomizableSinglePickerSnapshot<T>>? resetValue;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  /// When true, shakes once when validation error appears on this field.
  final bool shakeOnError;

  /// Local picker sheet chrome; overrides theme when set.
  final UnifiedPickerSheetStyle? pickerSheetStyle;

  /// Sheet background override (wins over [pickerSheetStyle] and theme).
  final Color? pickerSheetBackgroundColor;

  /// Header override (wins over [pickerSheetStyle] and theme).
  final UnifiedInputPickerHeaderStyle? pickerHeaderStyle;

  @override
  State<UnifiedFormCustomizableAsyncPickerField<T>> createState() =>
      _UnifiedFormCustomizableAsyncPickerFieldState<T>();
}

class _UnifiedFormCustomizableAsyncPickerFieldState<T>
    extends State<UnifiedFormCustomizableAsyncPickerField<T>> {
  final GlobalKey<FormFieldState<CustomizableSinglePickerController<T>>>
  _fieldKey =
      GlobalKey<FormFieldState<CustomizableSinglePickerController<T>>>();

  void _onControllerChanged() {
    final fieldState = _fieldKey.currentState;
    if (fieldState == null) return;
    fieldState.didChange(widget.pickerController);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unifiedFormClearErrorIfValid(fieldState);
    });
  }

  @override
  void initState() {
    super.initState();
    widget.pickerController.addListener(_onControllerChanged);
    syncCustomizableSingleFormValidatorToFieldController(
      widget.pickerController,
      widget.validator,
    );
  }

  @override
  void didUpdateWidget(
    covariant UnifiedFormCustomizableAsyncPickerField<T> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pickerController != widget.pickerController) {
      oldWidget.pickerController.removeListener(_onControllerChanged);
      widget.pickerController.addListener(_onControllerChanged);
    }
    if (oldWidget.validator != widget.validator ||
        oldWidget.pickerController != widget.pickerController) {
      syncCustomizableSingleFormValidatorToFieldController(
        widget.pickerController,
        widget.validator,
      );
    }
  }

  @override
  void dispose() {
    widget.pickerController.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _applyReset() {
    final fn = widget.resetValue;
    if (fn == null) return;
    final snap = fn();
    widget.pickerController.silentReplace(
      kind: snap.kind,
      selected: snap.selectedItem,
      typed: snap.typedText,
    );
    widget.pickerController.notifyView();
  }

  @override
  Widget build(BuildContext context) {
    syncCustomizableSingleFormValidatorToFieldController(
      widget.pickerController,
      widget.validator,
    );
    return UnifiedFormField<CustomizableSinglePickerController<T>>(
      formFieldKey: _fieldKey,
      initialValue: widget.pickerController,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onReset: _applyReset,
      shakeOnError: widget.shakeOnError,
      builder: (context, fieldState) {
        return UnifiedCustomizableAsyncPickerField<T>(
          itemProvider: widget.itemProvider,
          label: widget.label,
          pickerController: widget.pickerController,
          decoration: widget.decoration,
          decorationSet: widget.decorationSet,
          brightness: widget.brightness,
          allowFreeText: widget.allowFreeText,
          valueToString: widget.valueToString,
          searchBuilder: widget.searchBuilder,
          itemToWidget: widget.itemToWidget,
          gridItemBuilder: widget.gridItemBuilder,
          gridDelegate: widget.gridDelegate,
          suggestion: widget.suggestion,
          hasSearch: widget.hasSearch,
          searchAutoFocus: widget.searchAutoFocus,
          showClearButton: widget.showClearButton,
          locked: widget.locked,
          isDisabled: widget.isDisabled,
          placeholder: widget.placeholder,
          isRequired: widget.isRequired,
          onChanged: widget.onChanged,
          pickerSheetStyle: widget.pickerSheetStyle,
          pickerSheetBackgroundColor: widget.pickerSheetBackgroundColor,
          pickerHeaderStyle: widget.pickerHeaderStyle,
          validator: (_) {
            final err = fieldState.errorText;
            return (err == null || err.isEmpty) ? null : err;
          },
        );
      },
    );
  }
}

/// Form-aware wrapper around [UnifiedCustomizableAsyncMultiPickerField].
class UnifiedFormCustomizableAsyncMultiPickerField<T> extends StatefulWidget {
  /// Creates a [Form]-aware customizable async multi-select picker field.
  const UnifiedFormCustomizableAsyncMultiPickerField({
    super.key,
    required this.itemProvider,
    required this.label,
    required this.pickerController,
    this.decoration,
    this.decorationSet,
    this.brightness,
    this.allowFreeText = true,
    this.valueToString,
    this.searchBuilder,
    this.itemToWidget,
    this.gridItemBuilder,
    this.gridDelegate,
    this.suggestion = const [],
    this.hasSearch = true,
    this.searchAutoFocus = false,
    this.showClearButton = true,
    this.locked = false,
    this.isDisabled = false,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.resetValue,
    this.placeholder,
    this.isRequired = false,
    this.shakeOnError = false,
    this.pickerSheetStyle,
    this.pickerSheetBackgroundColor,
    this.pickerHeaderStyle,
  });

  /// Fetched when the user opens the picker.
  final Future<List<T>> Function() itemProvider;

  /// Label for the field and sheet title fallback.
  final String label;

  /// Hint text shown when empty.
  final String? placeholder;

  /// Visual chrome.
  final UnifiedInputDecoration? decoration;

  /// Per-state decorations (focus, error, valid, locked, disabled, …).
  final UnifiedInputDecorationSet? decorationSet;

  /// Override [Theme] brightness for the unified palette.
  final UnifiedInputBrightness? brightness;

  /// Controller holding either typed text or a `List` of selected `T`.
  final CustomizableMultiPickerController<T> pickerController;

  /// If false, the inner text field is read-only and tapping opens the sheet.
  final bool allowFreeText;

  /// Renders an item to its display text.
  final String Function(T value)? valueToString;

  /// Custom searchable text per item.
  final String Function(T value)? searchBuilder;

  /// Custom row builder inside the sheet (list layout).
  final Widget Function(T value)? itemToWidget;

  /// Custom grid tile builder; when set, the sheet uses a [GridView].
  final UnifiedPickerMultiGridItemBuilder<T>? gridItemBuilder;

  /// Grid layout when [gridItemBuilder] is set. Defaults to [unifiedPickerDefaultGridDelegate].
  final SliverGridDelegate? gridDelegate;

  /// Optional suggestion list pinned above the searchable list.
  final List<T> suggestion;

  /// Whether the sheet shows a search field.
  final bool hasSearch;

  /// Autofocus the search field on open.
  final bool searchAutoFocus;

  /// Show a Clear button in the sheet header.
  final bool showClearButton;

  /// When true, the field is non-interactive.
  final bool locked;

  /// When true, greys out the label and shows a forbid suffix icon.
  final bool isDisabled;

  /// Validator on the current snapshot.
  final FormFieldValidator<CustomizableMultiPickerController<T>>? validator;

  /// Save callback. Receives the latest [pickerController] reference.
  final FormFieldSetter<CustomizableMultiPickerController<T>>? onSaved;

  /// Notified when the user types or selects values.
  final ValueChanged<CustomizableMultiPickerController<T>>? onChanged;

  /// When non-null, [FormState.reset] restores the controller to this snapshot.
  final UnifiedFormResetValue<CustomizableMultiPickerSnapshot<T>>? resetValue;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  /// When true, shakes once when validation error appears on this field.
  final bool shakeOnError;

  /// Local picker sheet chrome; overrides theme when set.
  final UnifiedPickerSheetStyle? pickerSheetStyle;

  /// Sheet background override (wins over [pickerSheetStyle] and theme).
  final Color? pickerSheetBackgroundColor;

  /// Header override (wins over [pickerSheetStyle] and theme).
  final UnifiedInputPickerHeaderStyle? pickerHeaderStyle;

  @override
  State<UnifiedFormCustomizableAsyncMultiPickerField<T>> createState() =>
      _UnifiedFormCustomizableAsyncMultiPickerFieldState<T>();
}

class _UnifiedFormCustomizableAsyncMultiPickerFieldState<T>
    extends State<UnifiedFormCustomizableAsyncMultiPickerField<T>> {
  final GlobalKey<FormFieldState<CustomizableMultiPickerController<T>>>
  _fieldKey = GlobalKey<FormFieldState<CustomizableMultiPickerController<T>>>();

  void _onControllerChanged() {
    final fieldState = _fieldKey.currentState;
    if (fieldState == null) return;
    fieldState.didChange(widget.pickerController);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unifiedFormClearErrorIfValid(fieldState);
    });
  }

  @override
  void initState() {
    super.initState();
    widget.pickerController.addListener(_onControllerChanged);
    syncCustomizableMultiFormValidatorToFieldController(
      widget.pickerController,
      widget.validator,
    );
  }

  @override
  void didUpdateWidget(
    covariant UnifiedFormCustomizableAsyncMultiPickerField<T> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pickerController != widget.pickerController) {
      oldWidget.pickerController.removeListener(_onControllerChanged);
      widget.pickerController.addListener(_onControllerChanged);
    }
    if (oldWidget.validator != widget.validator ||
        oldWidget.pickerController != widget.pickerController) {
      syncCustomizableMultiFormValidatorToFieldController(
        widget.pickerController,
        widget.validator,
      );
    }
  }

  @override
  void dispose() {
    widget.pickerController.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _applyReset() {
    final fn = widget.resetValue;
    if (fn == null) return;
    final snap = fn();
    widget.pickerController.silentReplace(
      kind: snap.kind,
      selected: snap.selectedItems,
      typed: snap.typedText,
    );
    widget.pickerController.notifyView();
  }

  @override
  Widget build(BuildContext context) {
    syncCustomizableMultiFormValidatorToFieldController(
      widget.pickerController,
      widget.validator,
    );
    return UnifiedFormField<CustomizableMultiPickerController<T>>(
      formFieldKey: _fieldKey,
      initialValue: widget.pickerController,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onReset: _applyReset,
      shakeOnError: widget.shakeOnError,
      builder: (context, fieldState) {
        return UnifiedCustomizableAsyncMultiPickerField<T>(
          itemProvider: widget.itemProvider,
          label: widget.label,
          pickerController: widget.pickerController,
          decoration: widget.decoration,
          decorationSet: widget.decorationSet,
          brightness: widget.brightness,
          allowFreeText: widget.allowFreeText,
          valueToString: widget.valueToString,
          searchBuilder: widget.searchBuilder,
          itemToWidget: widget.itemToWidget,
          gridItemBuilder: widget.gridItemBuilder,
          gridDelegate: widget.gridDelegate,
          suggestion: widget.suggestion,
          hasSearch: widget.hasSearch,
          searchAutoFocus: widget.searchAutoFocus,
          showClearButton: widget.showClearButton,
          locked: widget.locked,
          isDisabled: widget.isDisabled,
          placeholder: widget.placeholder,
          isRequired: widget.isRequired,
          onChanged: widget.onChanged,
          pickerSheetStyle: widget.pickerSheetStyle,
          pickerSheetBackgroundColor: widget.pickerSheetBackgroundColor,
          pickerHeaderStyle: widget.pickerHeaderStyle,
          validator: (_) {
            final err = fieldState.errorText;
            return (err == null || err.isEmpty) ? null : err;
          },
        );
      },
    );
  }
}
