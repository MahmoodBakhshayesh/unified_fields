import 'package:flutter/material.dart';

import 'unified_numeric_step_field.dart';
import 'unified_input_brightness.dart';
import 'unified_input_decoration.dart';

/// Number field using [UnifiedNumericStepField] with [UnifiedInputDecoration] colors / typography.
///
/// Drive programmatic updates via [controller]; optionally observe edits with [onChanged].
/// Set [fractionDigits] when you need fixed decimal places for display and step rounding.
class UnifiedNumberField extends StatelessWidget {
  const UnifiedNumberField({
    super.key,
    this.decoration,
    this.brightness,
    this.controller,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.disabled = false,
    this.readOnly = false,
    this.autofocus = false,
    this.allowDecimals = false,
    this.step = 1,
    this.min,
    this.max,
    this.fractionDigits,
    this.textInputAction,
    this.label,
  });

  final UnifiedInputDecoration? decoration;
  final UnifiedInputBrightness? brightness;

  final TextEditingController? controller;
  final FocusNode? focusNode;

  final String? Function(String value)? validator;
  final ValueChanged<num>? onChanged;
  final ValueChanged<String>? onSubmitted;

  final bool disabled;
  final bool readOnly;
  final bool autofocus;
  final bool allowDecimals;
  final num step;
  final num? min;
  final num? max;
  final int? fractionDigits;
  final String? label;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final d = resolveUnifiedDecoration(context, overrides: decoration, brightness: brightness);

    return UnifiedNumericStepField(
      controller: controller,
      focusNode: focusNode,
      label: label ?? d.label,
      placeholder: d.placeholder ?? d.label,
      labelStyle: d.labelStyle,
      padding: d.contentPadding,
      borderRadius:
          d.borderRadius ?? const BorderRadius.all(Radius.circular(18)),
      borderSide: d.borderSide ?? const BorderSide(color: Color(0xff58514C), width: 0.5),
      backgroundColor: d.backgroundColor ?? Colors.black26,
      headerBackgroundColor: d.headerBackgroundColor ?? d.backgroundColor,
      height: d.height,
      style: d.fieldStyle,
      allowDecimals: allowDecimals,
      step: step,
      min: min,
      max: max,
      fractionDigits: fractionDigits,
      disabled: disabled,
      readOnly: readOnly,
      autofocus: autofocus,
      textInputAction: textInputAction,
      validator: validator,
      showError: d.showError,
      validationColor: d.validationColor,
      validationIcon: d.validationIcon,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
    );
  }
}
