import 'package:flutter/material.dart';

import '../controllers/field_controller_sync.dart';
import 'unified_base_text_field.dart';
import 'unified_customizable_picker_controller.dart';
import 'unified_input_brightness.dart';
import 'unified_field_decoration_context.dart';
import 'unified_input_decoration.dart';
import 'unified_input_theme.dart';
import 'unified_multi_picker_sheet.dart';
import 'unified_picker_item_builders.dart';
import 'unified_picker_sheet.dart';
import 'unified_picker_sheet_style.dart';

/// Like [UnifiedAsyncPickerField] but supports free typing vs sheet selection via
/// [pickerController], same model as [UnifiedCustomizablePickerField].
///
/// Choices come from [itemProvider] when the field or suffix is pressed.
class UnifiedCustomizableAsyncPickerField<T> extends StatefulWidget {
  /// Creates a customizable async single-select picker field.
  const UnifiedCustomizableAsyncPickerField({
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
    this.disabled = false,
    this.isDisabled = false,
    this.validator,
    this.placeholder,
    this.isRequired = false,
    this.onChanged,
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

  /// Holds either typed text or a selected [T].
  final CustomizableSinglePickerController<T> pickerController;

  /// If false, the text field is read-only and tapping the field opens the sheet (after load).
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

  @override
  State<UnifiedCustomizableAsyncPickerField<T>> createState() =>
      _UnifiedCustomizableAsyncPickerFieldState<T>();
}

class _UnifiedCustomizableAsyncPickerFieldState<T>
    extends State<UnifiedCustomizableAsyncPickerField<T>> {
  late final TextEditingController _txt = TextEditingController();
  List<T> _items = [];
  bool _loading = false;

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

  String _sheetLabel(UnifiedInputDecoration dec) =>
      widget.placeholder ?? dec.placeholder ?? dec.label ?? widget.label;

  void _syncFieldController(UnifiedInputDecoration dec) {
    widget.pickerController.bindAsyncPicker(
      itemProvider: widget.itemProvider,
      label: _sheetLabel(dec),
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
    covariant UnifiedCustomizableAsyncPickerField<T> oldWidget,
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
        oldWidget.label != widget.label ||
        oldWidget.decoration != widget.decoration ||
        oldWidget.itemProvider != widget.itemProvider) {
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
    if (widget.locked || _inactive || _loading) return;
    if (!mounted) return;

    final dec = resolveUnifiedDecoration(
      context,
      overrides: widget.decoration,
      brightness: widget.brightness,
    );

    setState(() => _loading = true);
    try {
      _items = await widget.itemProvider();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    if (!mounted || !context.mounted) return;

    final sheetChrome = resolvePickerSheetStyleOverrides(
      pickerSheetStyle: widget.pickerSheetStyle,
      pickerSheetBackgroundColor: widget.pickerSheetBackgroundColor,
      pickerHeaderStyle: widget.pickerHeaderStyle,
    );
    FocusScope.of(context).requestFocus(FocusNode());
    final dynamic result = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      builder: (c) => Padding(
        padding: EdgeInsets.zero,
        child: PickerSheetWidget<T>(
          suggestion: widget.suggestion,
          value: _sheetSeedValue,
          searchAutoFocus: widget.searchAutoFocus,
          hasClear: widget.showClearButton,
          searchBuilder: widget.searchBuilder,
          items: _items,
          label: _sheetLabel(dec),
          itemToWidget: widget.itemToWidget,
          hasSearch: widget.hasSearch,
          gridItemBuilder: widget.gridItemBuilder,
          gridDelegate: widget.gridDelegate,
          sheetBackgroundColor: sheetChrome.sheetBackgroundColor,
          pickerHeaderStyle: sheetChrome.pickerHeaderStyle,
        ),
      ),
    );

    if (!mounted) return;

    if (result == Null) {
      widget.pickerController.applySelected(null);
    } else if (result != null) {
      widget.pickerController.applySelected(result as T);
    }
    _syncText();
    setState(() {});
  }

  Future<void> _open() async {
    if (!mounted) return;
    await _presentPicker(context);
  }

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
    final Widget? suffix = widget.locked || _inactive || _loading
        ? dec.suffixIcon
        : (dec.suffixIcon ??
              UnifiedInputThemeResolver.defaultSuffixIcon(
                context,
                UnifiedInputFieldSuffixKind.picker,
                palette,
                onPressed: _open,
              ));

    final field = UnifiedBaseTextField(
        decorationSet: chrome.activeSet,
        brightness: widget.brightness,
        controller: _txt,
        readOnly: readOnly,
        interactionBlocked: !canType,
        loading: _loading,
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
        suffixIcon: suffix,
        padding: dec.contentPadding,
        validator: widget.validator,
      );

    if (canType) return field;

    return GestureDetector(
      onTap: widget.locked || _inactive || _loading ? null : _open,
      child: field,
    );
  }
}

/// Like [UnifiedAsyncMultiPickerField] but uses [CustomizableMultiPickerController]
/// for typed vs selected state, same model as [UnifiedCustomizableMultiPickerField].
class UnifiedCustomizableAsyncMultiPickerField<T> extends StatefulWidget {
  /// Creates a customizable async multi-select picker field.
  const UnifiedCustomizableAsyncMultiPickerField({
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
    this.disabled = false,
    this.isDisabled = false,
    this.validator,
    this.placeholder,
    this.isRequired = false,
    this.onChanged,
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

  /// Holds either typed text or selected [List] of [T].
  final CustomizableMultiPickerController<T> pickerController;

  /// If false, the text field is read-only and tapping the field opens the sheet.
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
  final bool disabled;

  /// When true, greys out the label and shows a forbid suffix icon.
  final bool isDisabled;

  /// Synchronous validator on the displayed text.
  final String? Function(String value)? validator;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  /// Notified when the controller value transitions (typed text or selection change).
  final ValueChanged<CustomizableMultiPickerController<T>>? onChanged;

  /// Local picker sheet chrome; overrides theme when set.
  final UnifiedPickerSheetStyle? pickerSheetStyle;

  /// Sheet background override (wins over [pickerSheetStyle] and theme).
  final Color? pickerSheetBackgroundColor;

  /// Header override (wins over [pickerSheetStyle] and theme).
  final UnifiedInputPickerHeaderStyle? pickerHeaderStyle;

  @override
  State<UnifiedCustomizableAsyncMultiPickerField<T>> createState() =>
      _UnifiedCustomizableAsyncMultiPickerFieldState<T>();
}

class _UnifiedCustomizableAsyncMultiPickerFieldState<T>
    extends State<UnifiedCustomizableAsyncMultiPickerField<T>> {
  late final TextEditingController _txt = TextEditingController();
  List<T> _items = [];
  bool _loading = false;

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

  String _sheetLabel(UnifiedInputDecoration dec) =>
      widget.placeholder ?? dec.placeholder ?? dec.label ?? widget.label;

  void _syncFieldController(UnifiedInputDecoration dec) {
    widget.pickerController.bindAsyncPicker(
      itemProvider: widget.itemProvider,
      label: _sheetLabel(dec),
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
    covariant UnifiedCustomizableAsyncMultiPickerField<T> oldWidget,
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
        oldWidget.label != widget.label ||
        oldWidget.decoration != widget.decoration ||
        oldWidget.itemProvider != widget.itemProvider) {
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
    if (widget.locked || _inactive || _loading) return;
    if (!mounted) return;

    final dec = resolveUnifiedDecoration(
      context,
      overrides: widget.decoration,
      brightness: widget.brightness,
    );

    setState(() => _loading = true);
    try {
      _items = await widget.itemProvider();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    if (!mounted || !context.mounted) return;

    final sheetChrome = resolvePickerSheetStyleOverrides(
      pickerSheetStyle: widget.pickerSheetStyle,
      pickerSheetBackgroundColor: widget.pickerSheetBackgroundColor,
      pickerHeaderStyle: widget.pickerHeaderStyle,
    );
    FocusScope.of(context).requestFocus(FocusNode());
    final dynamic result = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      builder: (c) => Padding(
        padding: EdgeInsets.zero,
        child: MultiPickerSheetWidget<T>(
          suggestion: widget.suggestion,
          values: List<T>.from(_sheetSeedValues),
          searchAutoFocus: widget.searchAutoFocus,
          hasClear: widget.showClearButton,
          searchBuilder: widget.searchBuilder,
          items: _items,
          label: _sheetLabel(dec),
          itemToWidget: widget.itemToWidget,
          hasSearch: widget.hasSearch,
          gridItemBuilder: widget.gridItemBuilder,
          gridDelegate: widget.gridDelegate,
          sheetBackgroundColor: sheetChrome.sheetBackgroundColor,
          pickerHeaderStyle: sheetChrome.pickerHeaderStyle,
        ),
      ),
    );

    if (!mounted) return;

    if (result == Null) {
      widget.pickerController.applySelected(<T>[]);
    } else if (result != null) {
      final raw = result as List;
      widget.pickerController.applySelected(raw.cast<T>().toList());
    }
    _syncText();
    setState(() {});
  }

  Future<void> _open() async {
    if (!mounted) return;
    await _presentPicker(context);
  }

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
    final Widget? suffix = widget.locked || _inactive || _loading
        ? dec.suffixIcon
        : (dec.suffixIcon ??
              UnifiedInputThemeResolver.defaultSuffixIcon(
                context,
                UnifiedInputFieldSuffixKind.multiPicker,
                palette,
                onPressed: _open,
              ));

    final field = UnifiedBaseTextField(
        decorationSet: chrome.activeSet,
        brightness: widget.brightness,
        controller: _txt,
        readOnly: readOnly,
        interactionBlocked: !canType,
        loading: _loading,
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
        suffixIcon: suffix,
        padding: dec.contentPadding,
        validator: widget.validator,
      );

    if (canType) return field;

    return GestureDetector(
      onTap: widget.locked || _inactive || _loading ? null : _open,
      child: field,
    );
  }
}
