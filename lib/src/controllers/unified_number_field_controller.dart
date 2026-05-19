import 'package:flutter/widgets.dart';

import '../unified_fields_typography.dart';
import '../unified_number_format.dart';
import 'base_unified_field_controller.dart';
import 'unified_text_field_controller.dart';

/// Controller for [UnifiedNumberField] / [UnifiedNumericStepField].
///
/// Wraps a [UnifiedTextFieldController] for the underlying text editing surface.
class UnifiedNumberFieldController extends BaseUnifiedFieldController<num> {
  /// Creates a number field controller.
  UnifiedNumberFieldController({
    num? initialValue,
    super.validator,
    FocusNode? focusNode,
    this.allowDecimals = false,
    this.step = 1,
    this.min,
    this.max,
    this.fractionDigits,
  }) : text = UnifiedTextFieldController(
         initialValue: initialValue == null
             ? null
             : formatUnifiedNumberFieldText(
                 initialValue,
                 allowDecimals: allowDecimals,
                 fractionDigits: fractionDigits,
               ),
         focusNode: focusNode,
       ),
       super(initialValue: initialValue) {
    text.addListener(_syncFromText);
  }

  /// Underlying text editing controller for the numeric surface.
  final UnifiedTextFieldController text;

  /// When true, decimal input is allowed.
  final bool allowDecimals;

  /// Step size for increment/decrement controls.
  final num step;

  /// Minimum allowed value.
  final num? min;

  /// Maximum allowed value.
  final num? max;

  /// Fraction digits when formatting parsed numbers.
  final int? fractionDigits;

  void _syncFromText() {
    final normalized = UnifiedFieldsTypography.fromPersianDigits(
      text.textController.text.trim(),
    );
    final parsed =
        num.tryParse(normalized) ?? double.tryParse(normalized);
    applyValueFromUser(parsed);
  }

  String _displayTextForValue(num? next) {
    if (next == null) return '';
    return formatUnifiedNumberFieldText(
      next,
      allowDecimals: allowDecimals,
      fractionDigits: fractionDigits,
    );
  }

  @override
  set value(num? next) {
    super.value = next;
    final s = _displayTextForValue(next);
    if (text.textController.text != s) {
      text.textController.text = s;
    }
  }

  @override
  String? validate() {
    final err = validator?.call(value);
    if (err != null && err.isNotEmpty) {
      setError(err);
      text.setError(err);
      return err;
    }
    clearError();
    text.clearError();
    return null;
  }

  @override
  void clear() {
    text.clear();
    super.clear();
  }

  @override
  void requestFocus() => text.requestFocus();

  @override
  void dispose() {
    text.removeListener(_syncFromText);
    text.dispose();
    super.dispose();
  }
}
