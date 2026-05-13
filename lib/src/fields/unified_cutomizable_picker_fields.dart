import '../app_colors.dart';
import 'package:flutter/material.dart';

import 'unified_base_text_field.dart';
import 'unified_customizable_picker_controller.dart';
import 'unified_input_brightness.dart';
import 'unified_input_decoration.dart';
import 'unified_multi_picker_sheet.dart';
import 'unified_picker_sheet.dart';

/// Single-select field backed by [PickerSheetWidget] (search + scroll-to-item list).
///
/// State is held in [pickerController]: either typed text or a selected [T].
class UnifiedCustomizablePickerField<T> extends StatefulWidget {
  const UnifiedCustomizablePickerField({
    super.key,
    required this.items,
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

  final List<T> items;
  final String label;
  final String? placeholder;

  final UnifiedInputDecoration? decoration;
  final UnifiedInputBrightness? brightness;

  final CustomizableSinglePickerController<T> pickerController;

  /// If false, the text field is read-only and tapping the field opens the sheet.
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
  State<UnifiedCustomizablePickerField<T>> createState() => _UnifiedCustomizablePickerFieldState<T>();
}

class _UnifiedCustomizablePickerFieldState<T> extends State<UnifiedCustomizablePickerField<T>> {
  late final TextEditingController _txt = TextEditingController();

  /// [UnifiedBaseTextField] calls [onChanged] for programmatic [TextEditingController] updates too;
  /// skip echoing those into [CustomizableSinglePickerController.applyTyped].
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
  void didUpdateWidget(covariant UnifiedCustomizablePickerField<T> oldWidget) {
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

  Future<void> _open(BuildContext context) async {
    if (widget.locked) return;
    final dec = resolveUnifiedDecoration(context, overrides: widget.decoration, brightness: widget.brightness);
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
          items: widget.items,
          label: dec.placeholder ?? dec.label ?? widget.label,
          itemToWidget: widget.itemToWidget,
          hasSearch: widget.hasSearch,
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

  void _onFieldTextChanged(String raw) {
    if (_applyingDisplayText) return;
    widget.pickerController.applyTyped(raw);
  }

  @override
  Widget build(BuildContext context) {
    final dec = resolveUnifiedDecoration(context, overrides: widget.decoration, brightness: widget.brightness);
    final readOnly = widget.locked || !widget.allowFreeText;

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
      suffixIcon: IconButton(
        onPressed: widget.locked ? null : () => _open(context),
        icon: Icon(
          Icons.arrow_drop_down,
          color: AppColors.textColorDark,
        ),
      ),
      padding: dec.contentPadding,
      validator: widget.validator,
    );

    if (!widget.allowFreeText) {
      return GestureDetector(
        onTap: widget.locked ? null : () => _open(context),
        child: field,
      );
    }
    return field;
  }
}

/// Customizable multi-select field backed by [MultiPickerSheetWidget].
class UnifiedCustomizableMultiPickerField<T> extends StatefulWidget {
  const UnifiedCustomizableMultiPickerField({
    super.key,
    required this.items,
    required this.label,
    required this.pickerController,
    this.decoration,
    this.brightness,
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

  final List<T> items;
  final String label;

  final UnifiedInputDecoration? decoration;
  final UnifiedInputBrightness? brightness;

  final CustomizableMultiPickerController<T> pickerController;

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
  State<UnifiedCustomizableMultiPickerField<T>> createState() => _UnifiedCustomizableMultiPickerFieldState<T>();
}

class _UnifiedCustomizableMultiPickerFieldState<T> extends State<UnifiedCustomizableMultiPickerField<T>> {
  late final TextEditingController _txt = TextEditingController();

  /// See [_UnifiedCustomizablePickerFieldState._applyingDisplayText].
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
  void didUpdateWidget(covariant UnifiedCustomizableMultiPickerField<T> oldWidget) {
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

  Future<void> _open(BuildContext context, UnifiedInputDecoration dec) async {
    if (widget.locked) return;
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
          items: widget.items,
          label: dec.placeholder ?? dec.label ?? widget.label,
          itemToWidget: widget.itemToWidget,
          hasSearch: widget.hasSearch,
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

  void _onFieldTextChanged(String raw) {
    if (_applyingDisplayText) return;
    widget.pickerController.applyTyped(raw);
  }

  @override
  Widget build(BuildContext context) {
    final dec = resolveUnifiedDecoration(context, overrides: widget.decoration, brightness: widget.brightness);

    return UnifiedBaseTextField(
      controller: _txt,
      readOnly: widget.locked,
      onChanged: _onFieldTextChanged,
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
      suffixIcon: IconButton(
        onPressed: widget.locked ? null : () => _open(context, dec),
        icon: Icon(
          Icons.arrow_drop_down,
          color: AppColors.textColorDark,
        ),
      ),
      padding: dec.contentPadding,
      validator: widget.validator,
    );
  }
}
