import 'package:flutter/material.dart';

import '../controllers/unified_number_field_controller.dart';
import 'unified_numeric_step_field.dart';
import 'unified_input_brightness.dart';
import 'unified_input_decoration.dart';

/// Number field using [UnifiedNumericStepField] with [UnifiedInputDecoration] colors / typography.
///
/// Drive programmatic updates via [controller]; optionally observe edits with [onChanged].
/// Set [fractionDigits] when you need fixed decimal places for display and step rounding.
class UnifiedNumberField extends StatelessWidget {
  /// Creates a unified number field.
  const UnifiedNumberField({
    super.key,
    this.decoration,
    this.brightness,
    this.controller,
    this.fieldController,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.disabled = false,
    this.isDisabled = false,
    this.readOnly = false,
    this.locked = false,
    this.autofocus = false,
    this.allowDecimals = false,
    this.step = 1,
    this.min,
    this.max,
    this.fractionDigits,
    this.textInputAction,
    this.label,
    this.placeholder,
    this.isRequired = false,
  });

  /// Visual chrome.
  final UnifiedInputDecoration? decoration;

  /// Override [Theme] brightness for the unified palette.
  final UnifiedInputBrightness? brightness;

  /// Backing text controller. The field always edits this text.
  final TextEditingController? controller;

  /// Preferred imperative handle (wraps text editing + numeric value).
  final UnifiedNumberFieldController? fieldController;

  /// Optional focus node.
  final FocusNode? focusNode;

  /// Synchronous validator on the displayed text.
  final String? Function(String value)? validator;

  /// Called when the parsed numeric value changes.
  final ValueChanged<num>? onChanged;

  /// Forwarded to the inner text field's submit.
  final ValueChanged<String>? onSubmitted;

  /// When true, the field is disabled.
  final bool disabled;

  /// When true, greys out the label and shows a forbid suffix icon.
  final bool isDisabled;

  /// When true, greys out the field and shows a lock suffix icon.
  final bool locked;

  /// When true, the field is read-only.
  final bool readOnly;

  /// Autofocus on mount.
  final bool autofocus;

  /// Whether to allow decimal input.
  final bool allowDecimals;

  /// Step used by the increment / decrement buttons.
  final num step;

  /// Minimum allowed value.
  final num? min;

  /// Maximum allowed value.
  final num? max;

  /// Fixed number of decimals shown / rounded to.
  final int? fractionDigits;

  /// Field label. Overrides [UnifiedInputDecoration.label] when set.
  final String? label;

  /// Hint text shown when empty. Overrides [UnifiedInputDecoration.placeholder] when set.
  final String? placeholder;

  /// Forwarded to the inner text field.
  final TextInputAction? textInputAction;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final d = resolveUnifiedDecoration(
      context,
      overrides: decoration,
      brightness: brightness,
    );

    return UnifiedNumericStepField(
      controller: fieldController?.text.textController ?? controller,
      fieldController: fieldController,
      focusNode: fieldController?.focusNode ?? focusNode,
      label: label ?? d.label,
      placeholder: placeholder ?? d.placeholder,
      labelStyle: d.labelStyle,
      padding: d.contentPadding,
      borderRadius:
          d.borderRadius ?? const BorderRadius.all(Radius.circular(18)),
      borderSide:
          d.borderSide ??
          const BorderSide(color: Color(0xff58514C), width: 0.5),
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
      isDisabled: isDisabled,
      locked: locked,
      readOnly: readOnly,
      autofocus: autofocus,
      textInputAction: textInputAction,
      validator: validator,
      requiredField: isRequired || d.requiredField,
      showError: d.showError,
      validationColor: d.validationColor,
      validationIcon: d.validationIcon,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
    );
  }
}
