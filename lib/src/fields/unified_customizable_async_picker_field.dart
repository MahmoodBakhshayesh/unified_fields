import '../unified_fields_context.dart';
import '../app_colors.dart';
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
    this.validator,
    this.placeholder,
  });

  final Future<List<T>> Function() itemProvider;
  final String label;
  final String? placeholder;

  final UnifiedInputDecoration? decoration;
  final UnifiedInputBrightness? brightness;

  final CustomizableSinglePickerController<T> pickerController;

  /// If false, the text field is read-only and tapping the field opens the sheet (after load).
  final bool allowFreeText;

  final String Function(T value)? valueToString;
  final String Function(T value)? searchBuilder;
  final Widget Function(T value)? itemToWidget;

  final List<T> suggestion;
  final bool hasSearch;
  final bool searchAutoFocus;
  final bool showClearButton;
  final bool locked;
  final String? Function(String value)? validator;

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

  void _onPickerController() => setState(_syncText);

  @override
  void dispose() {
    widget.pickerController.removeListener(_onPickerController);
    _txt.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    if (widget.locked || _loading) return;
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
          label: dec.placeholder ?? dec.label ?? widget.label,
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
    final readOnly = widget.locked || !widget.allowFreeText;

    final suffix = dec.suffixIcon ??
        IconButton(
          onPressed: widget.locked || _loading ? null : _open,
          icon: Icon(
            Icons.arrow_drop_down,
            color: AppColors.textColorDark,
          ),
        );

    final field = UnifiedBaseTextField(
      controller: _txt,
      readOnly: readOnly,
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
      requiredField: dec.requiredField,
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
            onTap: widget.locked || _loading ? null : _open,
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
    this.validator,
  });

  final Future<List<T>> Function() itemProvider;
  final String label;

  final UnifiedInputDecoration? decoration;
  final UnifiedInputBrightness? brightness;

  final CustomizableMultiPickerController<T> pickerController;

  final bool allowFreeText;

  final String Function(T value)? valueToString;
  final String Function(T value)? searchBuilder;
  final Widget Function(T value)? itemToWidget;

  final List<T> suggestion;
  final bool hasSearch;
  final bool searchAutoFocus;
  final bool showClearButton;
  final bool locked;
  final String? Function(String value)? validator;

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

  void _onPickerController() => setState(_syncText);

  @override
  void dispose() {
    widget.pickerController.removeListener(_onPickerController);
    _txt.dispose();
    super.dispose();
  }

  Future<void> _open(UnifiedInputDecoration dec) async {
    if (widget.locked || _loading) return;
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
          label: dec.placeholder ?? dec.label ?? widget.label,
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
    final readOnly = widget.locked || !widget.allowFreeText;

    final suffix = dec.suffixIcon ??
        IconButton(
          onPressed: widget.locked || _loading ? null : () => _open(dec),
          icon: Icon(
            Icons.arrow_drop_down,
            color: AppColors.textColorDark,
          ),
        );

    final field = UnifiedBaseTextField(
      controller: _txt,
      readOnly: readOnly,
      onChanged: widget.allowFreeText ? _onFieldTextChanged : null,
      label: dec.label ?? widget.label,
      placeholder: dec.placeholder ?? widget.label,
      labelStyle: dec.labelStyle,
      style: dec.fieldStyle,
      backgroundColor: dec.backgroundColor ?? Colors.black26,
      headerBackgroundColor: dec.headerBackgroundColor ?? dec.backgroundColor ?? Colors.black26,
      borderRadius: dec.borderRadius ?? const BorderRadius.all(Radius.circular(18)),
      borderSide: dec.borderSide,
      height: dec.height,
      rowLabelRatio: dec.rowLabelRatio,
      labelInRow: dec.labelInRow,
      requiredField: dec.requiredField,
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
            onTap: widget.locked || _loading ? null : () => _open(dec),
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
