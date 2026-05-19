import 'package:flutter/material.dart';

import '../controllers/field_controller_sync.dart';
import 'unified_base_text_field.dart';
import 'unified_picker_item_builders.dart';
import 'unified_customizable_picker_controller.dart';
import 'unified_input_brightness.dart';
import 'unified_field_decoration_context.dart';
import 'unified_input_decoration.dart';
import 'unified_input_theme.dart';
import 'unified_multi_picker_sheet.dart';
import 'unified_picker_sheet.dart';

/// Single-select field backed by [PickerSheetWidget] (search + scroll-to-item list).
///
/// State is held in [pickerController]: either typed text or a selected [T].
class UnifiedCustomizablePickerField<T> extends StatefulWidget {
  /// Creates a customizable single-select picker field.
  const UnifiedCustomizablePickerField({
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
    this.disabled = false,
    this.isDisabled = false,
    this.validator,
    this.placeholder,
    this.isRequired = false,
    this.onChanged,
    this.pickerSheetStyle,
    this.pickerSheetBackgroundColor,
    this.pickerHeaderStyle,
    this.pickerSheetModalSettings,
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

  /// Holds either typed text or a selected [T]. See
  /// [CustomizableSinglePickerController].
  final CustomizableSinglePickerController<T> pickerController;

  /// If false, the text field is read-only and tapping the field opens the sheet.
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
  final bool disabled;

  /// When true, greys out the label and shows a forbid suffix icon.
  final bool isDisabled;

  /// Synchronous validator on the displayed text.
  final String? Function(String value)? validator;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  /// Notified when the controller value transitions (typed text or selection change).
  final ValueChanged<CustomizableSinglePickerController<T>>? onChanged;

  /// Local picker sheet chrome; overrides theme when set.
  final UnifiedPickerSheetStyle? pickerSheetStyle;

  /// Sheet background override (wins over [pickerSheetStyle] and theme).
  final Color? pickerSheetBackgroundColor;

  /// Header override (wins over [pickerSheetStyle] and theme).
  final UnifiedInputPickerHeaderStyle? pickerHeaderStyle;

  /// Modal flags override (`isScrollControlled`, `isDismissible`, …).
  final UnifiedPickerSheetModalSettings? pickerSheetModalSettings;

  @override
  State<UnifiedCustomizablePickerField<T>> createState() =>
      _UnifiedCustomizablePickerFieldState<T>();
}

class _UnifiedCustomizablePickerFieldState<T>
    extends State<UnifiedCustomizablePickerField<T>> {
  late final TextEditingController _txt = TextEditingController();

  /// [UnifiedBaseTextField] calls [onChanged] for programmatic [TextEditingController] updates too;
  /// skip echoing those into [CustomizableSinglePickerController.applyTyped].
  bool _applyingDisplayText = false;

  bool get _inactive => widget.disabled || widget.isDisabled;

  T? get _sheetSeedValue {
    final pc = widget.pickerController;
    return pc.inputKind == CustomizablePickerInputKind.selected
        ? pc.selectedItem
        : null;
  }

  void _syncText() {
    final pc = widget.pickerController;
    final next = pc.fieldDisplayText;
    if (_txt.text != next) {
      _applyingDisplayText = true;
      try {
        _txt.text = next;
      } finally {
        _applyingDisplayText = false;
      }
    }
  }

  void _syncFieldController(UnifiedInputDecoration dec) {
    widget.pickerController.bindPicker(
      items: widget.items,
      label: widget.placeholder ?? dec.placeholder ?? dec.label ?? widget.label,
      suggestion: widget.suggestion,
      hasSearch: widget.hasSearch,
      searchAutoFocus: widget.searchAutoFocus,
      showClearButton: widget.showClearButton,
      searchBuilder: widget.searchBuilder,
      itemToWidget: widget.itemToWidget,
      gridItemBuilder: widget.gridItemBuilder,
      gridDelegate: widget.gridDelegate,
    );
    attachUnifiedFieldHandles(
      opener: _presentPicker,
      focusNode: widget.pickerController.focusNode,
      fieldController: widget.pickerController,
    );
  }

  @override
  void initState() {
    super.initState();
    widget.pickerController.valueToString = widget.valueToString;
    widget.pickerController.addListener(_onPickerController);
    _syncText();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncFieldController(
      resolveUnifiedDecoration(
        context,
        overrides: widget.decoration,
        brightness: widget.brightness,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant UnifiedCustomizablePickerField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pickerController != widget.pickerController) {
      detachUnifiedFieldHandles(fieldController: oldWidget.pickerController);
      oldWidget.pickerController.removeListener(_onPickerController);
      oldWidget.pickerController.valueToString = null;
      widget.pickerController.valueToString = widget.valueToString;
      widget.pickerController.addListener(_onPickerController);
    } else {
      widget.pickerController.valueToString = widget.valueToString;
    }
    if (oldWidget.pickerController != widget.pickerController ||
        oldWidget.items != widget.items ||
        oldWidget.label != widget.label ||
        oldWidget.decoration != widget.decoration) {
      _syncFieldController(
        resolveUnifiedDecoration(
          context,
          overrides: widget.decoration,
          brightness: widget.brightness,
        ),
      );
    }
    _syncText();
  }

  void _onPickerController() {
    setState(_syncText);
    widget.onChanged?.call(widget.pickerController);
  }

  @override
  void dispose() {
    detachUnifiedFieldHandles(fieldController: widget.pickerController);
    widget.pickerController.removeListener(_onPickerController);
    _txt.dispose();
    super.dispose();
  }

  Future<void> _presentPicker(BuildContext context) async {
    if (widget.locked || _inactive) return;
    final dec = resolveUnifiedDecoration(
      context,
      overrides: widget.decoration,
      brightness: widget.brightness,
    );
    final sheetChrome = resolvePickerSheetStyleOverrides(
      pickerSheetStyle: widget.pickerSheetStyle,
      pickerSheetBackgroundColor: widget.pickerSheetBackgroundColor,
      pickerHeaderStyle: widget.pickerHeaderStyle,
    );
    FocusScope.of(context).requestFocus(FocusNode());
    final dynamic result = await showUnifiedFieldsPickerBottomSheet<dynamic>(
      context: context,
      pickerSheetStyle: widget.pickerSheetStyle,
      modalSettings: widget.pickerSheetModalSettings,
      builder: (c) => Padding(
        padding: EdgeInsets.zero,
        child: PickerSheetWidget<T>(
          suggestion: widget.suggestion,
          value: _sheetSeedValue,
          searchAutoFocus: widget.searchAutoFocus,
          hasClear: widget.showClearButton,
          searchBuilder: widget.searchBuilder,
          items: widget.items,
          label:
              widget.placeholder ??
              dec.placeholder ??
              dec.label ??
              widget.label,
          valueToString: widget.valueToString,
          itemToWidget: widget.itemToWidget,
          hasSearch: widget.hasSearch,
          gridItemBuilder: widget.gridItemBuilder,
          gridDelegate: widget.gridDelegate,
          sheetBackgroundColor: sheetChrome.sheetBackgroundColor,
          pickerHeaderStyle: sheetChrome.pickerHeaderStyle,
        ),
      ),
    );

    if (!context.mounted) return;

    if (result == Null) {
      widget.pickerController.applySelected(null);
    } else if (result != null) {
      widget.pickerController.applySelected(result as T);
    }
    _syncText();
    setState(() {});
  }

  Future<void> _open(BuildContext context) => _presentPicker(context);

  void _onFieldTextChanged(String raw) {
    if (_applyingDisplayText) return;
    widget.pickerController.applyTyped(raw);
  }

  @override
  Widget build(BuildContext context) {
    final chrome = resolveUnifiedFieldDecorationContext(
      context,
      decoration: widget.decoration,
      decorationSet: widget.decorationSet,
      brightness: widget.brightness,
    );
    final dec = chrome.resolved;
    final readOnly = widget.locked || _inactive || !widget.allowFreeText;
    final canType = widget.allowFreeText && !readOnly;

    final palette = UnifiedInputThemeResolver.resolvePalette(context);
    final suffix = widget.locked || _inactive
        ? null
        : UnifiedInputThemeResolver.defaultSuffixIcon(
            context,
            UnifiedInputFieldSuffixKind.picker,
            palette,
            onPressed: () => _open(context),
          );

    final field = UnifiedBaseTextField(
      decorationSet: chrome.activeSet,
      brightness: widget.brightness,
      controller: _txt,
      readOnly: readOnly,
      interactionBlocked: !canType,
      focusNode: widget.pickerController.focusNode,
      errorText: widget.pickerController.errorText,
      isDisabled: _inactive,
      locked: widget.locked,
      onChanged: widget.allowFreeText ? _onFieldTextChanged : null,
      label: dec.label ?? widget.label,
      placeholder: widget.placeholder ?? dec.placeholder ?? widget.label,
      labelStyle: dec.labelStyle,
      style: dec.fieldStyle,
      placeholderStyle: dec.placeholderStyle,
      backgroundColor: dec.backgroundColor,
      headerBackgroundColor:
          dec.headerBackgroundColor ?? dec.backgroundColor,
      borderRadius:
          dec.borderRadius,
      borderSide: dec.borderSide,
      height: dec.height,
      rowLabelRatio: dec.rowLabelRatio,
      labelInRow: dec.labelInRow,
      labelMode: dec.labelMode,
      requiredField: widget.isRequired || dec.requiredField,
      showError: dec.showError,
      validationColor: dec.validationColor,
      validationIcon: dec.validationIcon,
      prefix: dec.prefix,
      prefixIcon: dec.prefixIcon,
      suffixIcon: dec.suffixIcon ?? suffix,
      padding: dec.contentPadding,
      validator: widget.validator,
    );

    if (canType) return field;

    return GestureDetector(
      onTap: widget.locked || _inactive ? null : () => _open(context),
      child: field,
    );
  }
}

/// Customizable multi-select field backed by [MultiPickerSheetWidget].
class UnifiedCustomizableMultiPickerField<T> extends StatefulWidget {
  /// Creates a customizable multi-select picker field.
  const UnifiedCustomizableMultiPickerField({
    super.key,
    required this.items,
    required this.label,
    required this.pickerController,
    this.decoration,
    this.decorationSet,
    this.brightness,
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
    this.disabled = false,
    this.isDisabled = false,
    this.validator,
    this.placeholder,
    this.isRequired = false,
    this.allowFreeText = true,
    this.onChanged,
    this.pickerSheetStyle,
    this.pickerSheetBackgroundColor,
    this.pickerHeaderStyle,
    this.pickerSheetModalSettings,
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

  /// Holds either typed text or selected [List] of [T].
  final CustomizableMultiPickerController<T> pickerController;

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
  final bool disabled;

  /// When true, greys out the label and shows a forbid suffix icon.
  final bool isDisabled;

  /// Synchronous validator on the displayed text.
  final String? Function(String value)? validator;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  /// If false, the text field is read-only and tapping the field opens the sheet.
  final bool allowFreeText;

  /// Notified when the controller value transitions (typed text or selection change).
  final ValueChanged<CustomizableMultiPickerController<T>>? onChanged;

  /// Local picker sheet chrome; overrides theme when set.
  final UnifiedPickerSheetStyle? pickerSheetStyle;

  /// Sheet background override (wins over [pickerSheetStyle] and theme).
  final Color? pickerSheetBackgroundColor;

  /// Header override (wins over [pickerSheetStyle] and theme).
  final UnifiedInputPickerHeaderStyle? pickerHeaderStyle;

  /// Modal flags override (`isScrollControlled`, `isDismissible`, …).
  final UnifiedPickerSheetModalSettings? pickerSheetModalSettings;

  @override
  State<UnifiedCustomizableMultiPickerField<T>> createState() =>
      _UnifiedCustomizableMultiPickerFieldState<T>();
}

class _UnifiedCustomizableMultiPickerFieldState<T>
    extends State<UnifiedCustomizableMultiPickerField<T>> {
  late final TextEditingController _txt = TextEditingController();

  /// See [_UnifiedCustomizablePickerFieldState._applyingDisplayText].
  bool _applyingDisplayText = false;

  bool get _inactive => widget.disabled || widget.isDisabled;

  List<T> get _sheetSeedValues {
    final pc = widget.pickerController;
    return pc.inputKind == CustomizablePickerInputKind.selected
        ? List<T>.from(pc.selectedItems)
        : <T>[];
  }

  void _syncText() {
    final pc = widget.pickerController;
    final next = pc.fieldDisplayText;
    if (_txt.text != next) {
      _applyingDisplayText = true;
      try {
        _txt.text = next;
      } finally {
        _applyingDisplayText = false;
      }
    }
  }

  void _syncFieldController(UnifiedInputDecoration dec) {
    widget.pickerController.bindPicker(
      items: widget.items,
      label: widget.placeholder ?? dec.placeholder ?? dec.label ?? widget.label,
      suggestion: widget.suggestion,
      hasSearch: widget.hasSearch,
      searchAutoFocus: widget.searchAutoFocus,
      showClearButton: widget.showClearButton,
      searchBuilder: widget.searchBuilder,
      itemToWidget: widget.itemToWidget,
      gridItemBuilder: widget.gridItemBuilder,
      gridDelegate: widget.gridDelegate,
    );
    attachUnifiedFieldHandles(
      opener: _presentPicker,
      focusNode: widget.pickerController.focusNode,
      fieldController: widget.pickerController,
    );
  }

  @override
  void initState() {
    super.initState();
    widget.pickerController.valueToString = widget.valueToString;
    widget.pickerController.addListener(_onPickerController);
    _syncText();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncFieldController(
      resolveUnifiedDecoration(
        context,
        overrides: widget.decoration,
        brightness: widget.brightness,
      ),
    );
  }

  @override
  void didUpdateWidget(
    covariant UnifiedCustomizableMultiPickerField<T> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pickerController != widget.pickerController) {
      detachUnifiedFieldHandles(fieldController: oldWidget.pickerController);
      oldWidget.pickerController.removeListener(_onPickerController);
      oldWidget.pickerController.valueToString = null;
      widget.pickerController.valueToString = widget.valueToString;
      widget.pickerController.addListener(_onPickerController);
    } else {
      widget.pickerController.valueToString = widget.valueToString;
    }
    if (oldWidget.pickerController != widget.pickerController ||
        oldWidget.items != widget.items ||
        oldWidget.label != widget.label ||
        oldWidget.decoration != widget.decoration) {
      _syncFieldController(
        resolveUnifiedDecoration(
          context,
          overrides: widget.decoration,
          brightness: widget.brightness,
        ),
      );
    }
    _syncText();
  }

  void _onPickerController() {
    setState(_syncText);
    widget.onChanged?.call(widget.pickerController);
  }

  @override
  void dispose() {
    detachUnifiedFieldHandles(fieldController: widget.pickerController);
    widget.pickerController.removeListener(_onPickerController);
    _txt.dispose();
    super.dispose();
  }

  Future<void> _presentPicker(BuildContext context) async {
    if (widget.locked || _inactive) return;
    final dec = resolveUnifiedDecoration(
      context,
      overrides: widget.decoration,
      brightness: widget.brightness,
    );
    final sheetChrome = resolvePickerSheetStyleOverrides(
      pickerSheetStyle: widget.pickerSheetStyle,
      pickerSheetBackgroundColor: widget.pickerSheetBackgroundColor,
      pickerHeaderStyle: widget.pickerHeaderStyle,
    );
    FocusScope.of(context).requestFocus(FocusNode());
    final dynamic result = await showUnifiedFieldsPickerBottomSheet<dynamic>(
      context: context,
      pickerSheetStyle: widget.pickerSheetStyle,
      modalSettings: widget.pickerSheetModalSettings,
      builder: (c) => Padding(
        padding: EdgeInsets.zero,
        child: MultiPickerSheetWidget<T>(
          suggestion: widget.suggestion,
          values: List<T>.from(_sheetSeedValues),
          searchAutoFocus: widget.searchAutoFocus,
          hasClear: widget.showClearButton,
          searchBuilder: widget.searchBuilder,
          items: widget.items,
          label:
              widget.placeholder ??
              dec.placeholder ??
              dec.label ??
              widget.label,
          valueToString: widget.valueToString,
          itemToWidget: widget.itemToWidget,
          hasSearch: widget.hasSearch,
          gridItemBuilder: widget.gridItemBuilder,
          gridDelegate: widget.gridDelegate,
          sheetBackgroundColor: sheetChrome.sheetBackgroundColor,
          pickerHeaderStyle: sheetChrome.pickerHeaderStyle,
        ),
      ),
    );

    if (!context.mounted) return;

    if (result == Null) {
      widget.pickerController.applySelected(<T>[]);
    } else if (result != null) {
      final raw = result as List;
      widget.pickerController.applySelected(raw.cast<T>().toList());
    }
    _syncText();
    setState(() {});
  }

  Future<void> _open(BuildContext context) => _presentPicker(context);

  void _onFieldTextChanged(String raw) {
    if (_applyingDisplayText) return;
    widget.pickerController.applyTyped(raw);
  }

  @override
  Widget build(BuildContext context) {
    final chrome = resolveUnifiedFieldDecorationContext(
      context,
      decoration: widget.decoration,
      decorationSet: widget.decorationSet,
      brightness: widget.brightness,
    );
    final dec = chrome.resolved;
    final readOnly = widget.locked || _inactive || !widget.allowFreeText;
    final canType = widget.allowFreeText && !readOnly;

    final palette = UnifiedInputThemeResolver.resolvePalette(context);
    final suffix = widget.locked || _inactive
        ? null
        : UnifiedInputThemeResolver.defaultSuffixIcon(
            context,
            UnifiedInputFieldSuffixKind.picker,
            palette,
            onPressed: () => _open(context),
          );

    final field = UnifiedBaseTextField(
      decorationSet: chrome.activeSet,
      brightness: widget.brightness,
      controller: _txt,
      readOnly: readOnly,
      interactionBlocked: !canType,
      focusNode: widget.pickerController.focusNode,
      errorText: widget.pickerController.errorText,
      isDisabled: _inactive,
      locked: widget.locked,
      onChanged: widget.allowFreeText ? _onFieldTextChanged : null,
      label: dec.label ?? widget.label,
      placeholder: widget.placeholder ?? dec.placeholder ?? widget.label,
      labelStyle: dec.labelStyle,
      style: dec.fieldStyle,
      placeholderStyle: dec.placeholderStyle,
      backgroundColor: dec.backgroundColor,
      headerBackgroundColor:
          dec.headerBackgroundColor ?? dec.backgroundColor,
      borderRadius:
          dec.borderRadius,
      borderSide: dec.borderSide,
      height: dec.height,
      rowLabelRatio: dec.rowLabelRatio,
      labelInRow: dec.labelInRow,
      labelMode: dec.labelMode,
      requiredField: widget.isRequired || dec.requiredField,
      showError: dec.showError,
      validationColor: dec.validationColor,
      validationIcon: dec.validationIcon,
      prefix: dec.prefix,
      prefixIcon: dec.prefixIcon,
      suffixIcon: dec.suffixIcon ?? suffix,
      padding: dec.contentPadding,
      validator: widget.validator,
    );

    if (canType) return field;

    return GestureDetector(
      onTap: widget.locked || _inactive ? null : () => _open(context),
      child: field,
    );
  }
}
