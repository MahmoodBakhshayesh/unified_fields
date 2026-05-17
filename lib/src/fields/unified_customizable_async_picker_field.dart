import '../unified_fields_context.dart';
import '../unified_colors.dart';
import 'package:flutter/material.dart';


import 'unified_base_text_field.dart';
import 'unified_customizable_picker_controller.dart';
import 'unified_input_brightness.dart';
import 'unified_input_decoration.dart';
import 'unified_multi_picker_sheet.dart';
import 'unified_picker_sheet.dart';

/// Like [UnifiedAsyncPickerField] but supports free typing vs sheet selection via
/// [pickerController], same model as [UnifiedCustomizablePickerField].
///
/// Choices come from [itemProvider] when the dropdown [IconButton] is pressed.
class UnifiedCustomizableAsyncPickerField<T> extends StatefulWidget {
  /// Creates a customizable async single-select picker field.
  const UnifiedCustomizableAsyncPickerField({
    super.key,
    required this.itemProvider,
    required this.label,
    required this.pickerController,
    this.decoration,
    this.brightness,
    this.allowFreeText = true,
    this.valueToString,
    this.searchBuilder,
    this.itemToWidget,
    this.suggestion = const [],
    this.hasSearch = true,
    this.searchAutoFocus = false,
    this.showClearButton = true,
    this.locked = false,
    this.isDisabled = false,
    this.validator,
    this.placeholder,
    this.isRequired = false,
    this.onChanged,
  });

  /// Fetched when the user opens the picker.
  final Future<List<T>> Function() itemProvider;

  /// Label for the field and sheet title fallback.
  final String label;

  /// Hint text shown when empty.
  final String? placeholder;

  /// Visual chrome.
  final UnifiedInputDecoration? decoration;

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

  /// Custom row builder inside the sheet.
  final Widget Function(T value)? itemToWidget;

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

  /// Synchronous validator on the displayed text.
  final String? Function(String value)? validator;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  /// Notified when the controller value transitions (typed text or selection change).
  final ValueChanged<CustomizableSinglePickerController<T>>? onChanged;

  @override
  State<UnifiedCustomizableAsyncPickerField<T>> createState() => _UnifiedCustomizableAsyncPickerFieldState<T>();
}

class _UnifiedCustomizableAsyncPickerFieldState<T> extends State<UnifiedCustomizableAsyncPickerField<T>> {
  late final TextEditingController _txt = TextEditingController();
  List<T> _items = [];
  bool _loading = false;

  bool _applyingDisplayText = false;

  T? get _sheetSeedValue {
    final pc = widget.pickerController;
    return pc.inputKind == CustomizablePickerInputKind.selected ? pc.selectedItem : null;
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

  @override
  void initState() {
    super.initState();
    widget.pickerController.valueToString = widget.valueToString;
    widget.pickerController.addListener(_onPickerController);
    _syncText();
  }

  @override
  void didUpdateWidget(covariant UnifiedCustomizableAsyncPickerField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pickerController != widget.pickerController) {
      oldWidget.pickerController.removeListener(_onPickerController);
      oldWidget.pickerController.valueToString = null;
      widget.pickerController.valueToString = widget.valueToString;
      widget.pickerController.addListener(_onPickerController);
    } else {
      widget.pickerController.valueToString = widget.valueToString;
    }
    _syncText();
  }

  void _onPickerController() {
    setState(_syncText);
    widget.onChanged?.call(widget.pickerController);
  }

  @override
  void dispose() {
    widget.pickerController.removeListener(_onPickerController);
    _txt.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    if (widget.locked || widget.isDisabled || _loading) return;
    if (!mounted) return;

    final dec = resolveUnifiedDecoration(context, overrides: widget.decoration, brightness: widget.brightness);

    setState(() => _loading = true);
    try {
      _items = await widget.itemProvider();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    if (!mounted) return;

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
          label: widget.placeholder ?? dec.placeholder ?? dec.label ?? widget.label,
          itemToWidget: widget.itemToWidget,
          hasSearch: widget.hasSearch,
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

  void _onFieldTextChanged(String raw) {
    if (_applyingDisplayText) return;
    widget.pickerController.applyTyped(raw);
  }

  @override
  Widget build(BuildContext context) {
    final dec = resolveUnifiedDecoration(context, overrides: widget.decoration, brightness: widget.brightness);
    final readOnly = widget.locked || widget.isDisabled || !widget.allowFreeText;

    final Widget? suffix = widget.isDisabled || widget.locked
        ? dec.suffixIcon
        : (dec.suffixIcon ??
            IconButton(
              onPressed: widget.locked || widget.isDisabled || _loading ? null : _open,
              icon: Icon(
                Icons.arrow_drop_down,
                color: UnifiedColors.textColorDark,
              ),
            ));

    final field = UnifiedBaseTextField(
      controller: _txt,
      readOnly: readOnly,
      isDisabled: widget.isDisabled,
      locked: widget.locked,
      onChanged: widget.allowFreeText ? _onFieldTextChanged : null,
      label: dec.label ?? widget.label,
      placeholder: widget.placeholder ?? dec.placeholder ?? widget.label,
      labelStyle: dec.labelStyle,
      style: dec.fieldStyle,
      backgroundColor: dec.backgroundColor ?? Colors.black26,
      headerBackgroundColor: dec.headerBackgroundColor ?? dec.backgroundColor ?? Colors.black26,
      borderRadius: dec.borderRadius ?? const BorderRadius.all(Radius.circular(18)),
      borderSide: dec.borderSide,
      height: dec.height,
      rowLabelRatio: dec.rowLabelRatio,
      labelInRow: dec.labelInRow,
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

    final wrapped = !widget.allowFreeText
        ? GestureDetector(
            onTap: widget.locked || widget.isDisabled || _loading ? null : _open,
            child: field,
          )
        : field;

    return Stack(
      alignment: Alignment.center,
      children: [
        wrapped,
        if (_loading)
          Positioned.fill(
            child: AbsorbPointer(
              child: Material(
                color: Colors.black.withValues(alpha: 0.05),
                child: Center(
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.mainColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
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
    this.brightness,
    this.allowFreeText = true,
    this.valueToString,
    this.searchBuilder,
    this.itemToWidget,
    this.suggestion = const [],
    this.hasSearch = true,
    this.searchAutoFocus = false,
    this.showClearButton = true,
    this.locked = false,
    this.isDisabled = false,
    this.validator,
    this.placeholder,
    this.isRequired = false,
    this.onChanged,
  });

  /// Fetched when the user opens the picker.
  final Future<List<T>> Function() itemProvider;

  /// Label for the field and sheet title fallback.
  final String label;

  /// Hint text shown when empty.
  final String? placeholder;

  /// Visual chrome.
  final UnifiedInputDecoration? decoration;

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

  /// Custom row builder inside the sheet.
  final Widget Function(T value)? itemToWidget;

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

  /// Synchronous validator on the displayed text.
  final String? Function(String value)? validator;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  /// Notified when the controller value transitions (typed text or selection change).
  final ValueChanged<CustomizableMultiPickerController<T>>? onChanged;

  @override
  State<UnifiedCustomizableAsyncMultiPickerField<T>> createState() => _UnifiedCustomizableAsyncMultiPickerFieldState<T>();
}

class _UnifiedCustomizableAsyncMultiPickerFieldState<T> extends State<UnifiedCustomizableAsyncMultiPickerField<T>> {
  late final TextEditingController _txt = TextEditingController();
  List<T> _items = [];
  bool _loading = false;

  bool _applyingDisplayText = false;

  List<T> get _sheetSeedValues {
    final pc = widget.pickerController;
    return pc.inputKind == CustomizablePickerInputKind.selected ? List<T>.from(pc.selectedItems) : <T>[];
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

  @override
  void initState() {
    super.initState();
    widget.pickerController.valueToString = widget.valueToString;
    widget.pickerController.addListener(_onPickerController);
    _syncText();
  }

  @override
  void didUpdateWidget(covariant UnifiedCustomizableAsyncMultiPickerField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pickerController != widget.pickerController) {
      oldWidget.pickerController.removeListener(_onPickerController);
      oldWidget.pickerController.valueToString = null;
      widget.pickerController.valueToString = widget.valueToString;
      widget.pickerController.addListener(_onPickerController);
    } else {
      widget.pickerController.valueToString = widget.valueToString;
    }
    _syncText();
  }

  void _onPickerController() {
    setState(_syncText);
    widget.onChanged?.call(widget.pickerController);
  }

  @override
  void dispose() {
    widget.pickerController.removeListener(_onPickerController);
    _txt.dispose();
    super.dispose();
  }

  Future<void> _open(UnifiedInputDecoration dec) async {
    if (widget.locked || widget.isDisabled || _loading) return;
    if (!mounted) return;

    setState(() => _loading = true);
    try {
      _items = await widget.itemProvider();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    if (!mounted) return;

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
          label: widget.placeholder ?? dec.placeholder ?? dec.label ?? widget.label,
          itemToWidget: widget.itemToWidget,
          hasSearch: widget.hasSearch,
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

  void _onFieldTextChanged(String raw) {
    if (_applyingDisplayText) return;
    widget.pickerController.applyTyped(raw);
  }

  @override
  Widget build(BuildContext context) {
    final dec = resolveUnifiedDecoration(context, overrides: widget.decoration, brightness: widget.brightness);
    final readOnly = widget.locked || widget.isDisabled || !widget.allowFreeText;

    final Widget? suffix = widget.isDisabled || widget.locked
        ? dec.suffixIcon
        : (dec.suffixIcon ??
            IconButton(
              onPressed: widget.locked || widget.isDisabled || _loading ? null : () => _open(dec),
              icon: Icon(
                Icons.arrow_drop_down,
                color: UnifiedColors.textColorDark,
              ),
            ));

    final field = UnifiedBaseTextField(
      controller: _txt,
      readOnly: readOnly,
      isDisabled: widget.isDisabled,
      locked: widget.locked,
      onChanged: widget.allowFreeText ? _onFieldTextChanged : null,
      label: dec.label ?? widget.label,
      placeholder: widget.placeholder ?? dec.placeholder ?? widget.label,
      labelStyle: dec.labelStyle,
      style: dec.fieldStyle,
      backgroundColor: dec.backgroundColor ?? Colors.black26,
      headerBackgroundColor: dec.headerBackgroundColor ?? dec.backgroundColor ?? Colors.black26,
      borderRadius: dec.borderRadius ?? const BorderRadius.all(Radius.circular(18)),
      borderSide: dec.borderSide,
      height: dec.height,
      rowLabelRatio: dec.rowLabelRatio,
      labelInRow: dec.labelInRow,
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

    final wrapped = !widget.allowFreeText
        ? GestureDetector(
            onTap: widget.locked || widget.isDisabled || _loading ? null : () => _open(dec),
            child: field,
          )
        : field;

    return Stack(
      alignment: Alignment.center,
      children: [
        wrapped,
        if (_loading)
          Positioned.fill(
            child: AbsorbPointer(
              child: Material(
                color: Colors.black.withValues(alpha: 0.05),
                child: Center(
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.mainColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
