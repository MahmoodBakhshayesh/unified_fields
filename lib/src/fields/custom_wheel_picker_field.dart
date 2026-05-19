import 'package:flutter/material.dart';

import '../custom_wheel_picker_sheet.dart';
import '../custom_wheel_picker_types.dart';
import '../unified_date_wheel_style.dart';
import 'unified_base_text_field.dart';
import 'unified_field_decoration_context.dart';
import 'unified_input_brightness.dart';
import 'unified_input_decoration.dart';
import 'unified_input_theme.dart';
export '../custom_wheel_picker_types.dart';
export '../custom_wheel_picker_sheet.dart';

/// Multi-column wheel picker field with unified chrome.
///
/// Configure wheels with a column map and matching value map:
///
/// ```dart
/// CustomWheelPicker(
///   label: 'Configuration',
///   columns: {
///     0: CustomWheelPickerColumn.typed<int>(
///       options: [1, 2, 3],
///       label: 'Qty',
///     ),
///     1: CustomWheelPickerColumn.typed<String>(
///       options: ['Small', 'Large'],
///       label: 'Size',
///     ),
///   },
///   value: {0: 2, 1: 'Large'},
///   onChanged: (next) => setState(() => _value = next),
/// )
/// ```
///
/// Dart does not support `CustomWheelPicker<int, String>` type parameters on one
/// widget; use [CustomWheelPickerColumn.typed] per column and `Map<int, Object?>`
/// for [value] instead.
class CustomWheelPicker extends StatefulWidget {
  /// Creates a custom multi-wheel picker field.
  CustomWheelPicker({
    super.key,
    required this.columns,
    required this.label,
    this.value = const {},
    this.onChanged,
    this.decoration,
    this.decorationSet,
    this.brightness,
    this.placeholder,
    this.isRequired = false,
    this.locked = false,
    this.isDisabled = false,
    this.validator,
    this.validationOverrideMessage,
    this.wheelLayout = CustomWheelPickerWheelLayout.vertical,
    this.wheelStyle,
    this.valueSeparator = ' · ',
    this.pickerSheetStyle,
    this.pickerSheetBackgroundColor,
    this.pickerHeaderStyle,
    this.pickerSheetModalSettings,
  }) : assert(columns.isNotEmpty, 'columns must not be empty');

  /// Wheel definitions keyed by column index.
  final Map<int, CustomWheelPickerColumn> columns;

  /// Current selection keyed by column index.
  final CustomWheelPickerValue value;

  /// Called when the user confirms a new selection in the sheet.
  final ValueChanged<CustomWheelPickerValue>? onChanged;

  /// Field label and sheet title fallback.
  final String label;

  /// Hint when nothing is selected.
  final String? placeholder;

  /// Visual chrome.
  final UnifiedInputDecoration? decoration;

  /// Per-state decorations.
  final UnifiedInputDecorationSet? decorationSet;

  /// Palette brightness override.
  final UnifiedInputBrightness? brightness;

  /// Required marker override.
  final bool isRequired;

  /// Non-interactive display.
  final bool locked;

  /// Disabled state.
  final bool isDisabled;

  /// Validates displayed summary text.
  final String? Function(String displayText)? validator;

  /// External error message (e.g. from [FormField]).
  final String? validationOverrideMessage;

  /// Vertical wheels in a row, or horizontal wheels stacked.
  final CustomWheelPickerWheelLayout wheelLayout;

  /// Wheel chrome inside the sheet.
  final UnifiedFieldsDateWheelStyle? wheelStyle;

  /// Separator between column values in the field text.
  final String valueSeparator;

  /// Local sheet chrome bundle.
  final UnifiedPickerSheetStyle? pickerSheetStyle;

  /// Sheet background override.
  final Color? pickerSheetBackgroundColor;

  /// Sheet header override.
  final UnifiedInputPickerHeaderStyle? pickerHeaderStyle;

  /// Modal flags override (`isScrollControlled`, `isDismissible`, …).
  final UnifiedPickerSheetModalSettings? pickerSheetModalSettings;

  @override
  State<CustomWheelPicker> createState() => _CustomWheelPickerState();
}

class _CustomWheelPickerState extends State<CustomWheelPicker> {
  late final TextEditingController _textController = TextEditingController();

  String get _displayText => formatCustomWheelPickerValue(
        widget.columns,
        widget.value,
        separator: widget.valueSeparator,
      );

  @override
  void initState() {
    super.initState();
    _syncText();
  }

  @override
  void didUpdateWidget(covariant CustomWheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value ||
        oldWidget.columns != widget.columns ||
        oldWidget.valueSeparator != widget.valueSeparator) {
      _syncText();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _syncText() {
    _textController.text = _displayText;
  }

  String _sheetTitle(UnifiedInputDecoration dec) =>
      dec.placeholder ?? dec.label ?? widget.label;

  Future<void> _open(BuildContext context) async {
    if (widget.isDisabled || widget.locked) return;
    FocusScope.of(context).unfocus();
    final picked = await showCustomWheelPicker(
      context: context,
      columns: widget.columns,
      value: widget.value,
      title: _sheetTitle(
        resolveUnifiedDecoration(
          context,
          overrides: widget.decoration,
          brightness: widget.brightness,
        ),
      ),
      wheelLayout: widget.wheelLayout,
      wheelStyle: widget.wheelStyle,
      pickerSheetStyle: widget.pickerSheetStyle,
      pickerSheetBackgroundColor: widget.pickerSheetBackgroundColor,
      pickerHeaderStyle: widget.pickerHeaderStyle,
      pickerSheetModalSettings: widget.pickerSheetModalSettings,
    );
    if (!mounted || picked == null) return;
    widget.onChanged?.call(picked);
    _syncText();
    setState(() {});
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

    return GestureDetector(
      onTap: widget.locked || widget.isDisabled
          ? null
          : () => _open(context),
      child: AbsorbPointer(
        child: UnifiedBaseTextField(
          decorationSet: chrome.activeSet,
          brightness: widget.brightness,
          controller: _textController,
          readOnly: true,
          label: dec.label ?? widget.label,
          placeholder: widget.placeholder ?? dec.placeholder ?? widget.label,
          labelStyle: dec.labelStyle,
          style: dec.fieldStyle,
          placeholderStyle: dec.placeholderStyle,
          backgroundColor: dec.backgroundColor,
          headerBackgroundColor:
              dec.headerBackgroundColor ?? dec.backgroundColor ?? Colors.black26,
          borderRadius: dec.borderRadius,
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
          suffixIcon: dec.suffixIcon ??
              (widget.isDisabled || widget.locked
                  ? null
                  : UnifiedInputThemeResolver.defaultSuffixIcon(
                      context,
                      UnifiedInputFieldSuffixKind.picker,
                      UnifiedInputThemeResolver.resolvePalette(context),
                    )),
          padding: dec.contentPadding,
          isDisabled: widget.isDisabled,
          locked: widget.locked,
          validator: (value) {
            final o = widget.validationOverrideMessage;
            if (o != null) {
              return o.isEmpty ? null : o;
            }
            return widget.validator?.call(value);
          },
        ),
      ),
    );
  }
}
