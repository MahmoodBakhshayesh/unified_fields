import 'package:flutter/widgets.dart';

import '../fields/unified_input_picker.dart';
import 'base_unified_field_controller.dart';
import 'unified_number_field_controller.dart';
import 'unified_picker_field_controller.dart';

/// Focus node: [fieldController] → [binding] → [direct].
FocusNode? unifiedEffectiveFocusNode<T>({
  BaseUnifiedFieldController<T>? fieldController,
  UnifiedInputPicker<T>? binding,
  FocusNode? direct,
}) => fieldController?.focusNode ?? binding?.focusNode ?? direct;

/// Opens a picker sheet the same way as tapping the bound field.
typedef UnifiedFieldOpener = Future<void> Function(BuildContext context);

/// Validator signature shared by [FormField], [FormFieldValidator], and
/// [BaseUnifiedFieldController.validator].
typedef UnifiedFieldValueValidator<T> = String? Function(T? value);

void _attachHandles(
  Object? handle,
  UnifiedFieldOpener? opener,
  FocusNode? focusNode,
) {
  if (handle is BaseUnifiedFieldController) {
    handle.attachFieldOpener(opener);
    handle.attachFocusTarget(focusNode);
  }
}

/// Wires [binding] and [fieldController] to the field's opener and focus node.
void attachUnifiedFieldHandles({
  required UnifiedFieldOpener? opener,
  required FocusNode? focusNode,
  Object? binding,
  Object? fieldController,
}) {
  _attachHandles(binding, opener, focusNode);
  _attachHandles(fieldController, opener, focusNode);
}

/// Clears opener/focus attachments. Call from [State.dispose].
void detachUnifiedFieldHandles({Object? binding, Object? fieldController}) {
  _attachHandles(binding, null, null);
  _attachHandles(fieldController, null, null);
}

/// Deep equality for multi-select list values.
bool unifiedListsEqual<T>(List<T>? a, List<T>? b) {
  final bb = b ?? const [];
  if (a == null) return bb.isEmpty;
  if (a.length != bb.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != bb[i]) return false;
  }
  return true;
}

/// Pushes an external [binding] update into [formState] and [fieldController].
///
/// [T] is the [FormField] value type (`DateTime?`, `CoffeeFlavor?`, …).
void syncFormFieldFromExternalValue<T>({
  FormFieldState<T>? formState,
  required T? value,
  BaseUnifiedFieldController<T>? fieldController,
}) {
  if (formState != null && formState.value != value) {
    formState.didChange(value);
    unifiedFormClearErrorIfValid(formState);
  }
  if (fieldController != null && fieldController.value != value) {
    fieldController.value = value;
  }
}

/// Like [syncFormFieldFromExternalValue] for multi-select list fields.
void syncFormFieldFromExternalList<T>({
  FormFieldState<List<T>>? formState,
  required List<T> value,
  BaseUnifiedFieldController<List<T>>? fieldController,
}) {
  if (formState != null && !unifiedListsEqual(formState.value, value)) {
    formState.didChange(value);
    unifiedFormClearErrorIfValid(formState);
  }
  if (fieldController != null &&
      !unifiedListsEqual(fieldController.value, value)) {
    fieldController.value = value;
  }
}

/// Syncs a new field value to optional [onChanged], [binding], and [fieldController].
///
/// [V] is the stored value type (`CoffeeFlavor?`, `DateTime?`, …).
/// [formFieldState] must match the [FormField] value type (e.g. [FormFieldState] of
/// `CoffeeFlavor?` when [V] is `CoffeeFlavor`).
void syncUnifiedFieldValue<V>({
  required V? value,
  ValueChanged<V?>? onChanged,
  UnifiedInputPicker<V>? binding,
  BaseUnifiedFieldController<V>? fieldController,
  FormFieldState<V>? formFieldState,
}) {
  onChanged?.call(value);
  if (binding != null && binding.value != value) {
    binding.value = value;
  }
  if (fieldController != null && fieldController.value != value) {
    fieldController.value = value;
  }
  if (formFieldState != null) {
    unifiedFormClearErrorIfValid(formFieldState);
  }
}

/// Syncs list value for multi-select fields.
void syncUnifiedFieldListValue<T>({
  required List<T> value,
  ValueChanged<List<T>>? onChanged,
  UnifiedInputPicker<List<T>>? binding,
  BaseUnifiedFieldController<List<T>>? fieldController,
  FormFieldState<List<T>>? formFieldState,
}) {
  onChanged?.call(value);
  if (binding != null) {
    binding.value = value;
  }
  if (fieldController != null) {
    fieldController.value = value;
  }
  if (formFieldState != null) {
    unifiedFormClearErrorIfValid(formFieldState);
  }
}

/// Copies a [FormField] / widget validator onto [fieldController].
///
/// Accepts [FormFieldValidator], [UnifiedFieldValueValidator], or any
/// `String? Function(T? value)` (including `(T value) => …` when [T] is nullable).
void syncWidgetFormValidatorToFieldController<T>(
  BaseUnifiedFieldController<T>? fieldController,
  UnifiedFieldValueValidator<T>? widgetValidator,
) {
  if (fieldController == null || widgetValidator == null) return;
  fieldController.validator = widgetValidator;
}

/// Copies [widgetValidator] onto [fieldController] (alias of
/// [syncWidgetFormValidatorToFieldController]).
void syncWidgetValidatorToFieldController<T>(
  BaseUnifiedFieldController<T>? fieldController,
  UnifiedFieldValueValidator<T>? widgetValidator,
) => syncWidgetFormValidatorToFieldController(fieldController, widgetValidator);

/// [FormFieldValidator] for [String] fields (nullable argument).
void syncWidgetFormStringValidatorToFieldController(
  BaseUnifiedFieldController<String>? fieldController,
  FormFieldValidator<String>? widgetValidator,
) {
  syncWidgetFormValidatorToFieldController(fieldController, widgetValidator);
}

/// Non-form [String] fields whose validator uses a non-nullable [String] argument.
void syncWidgetStringValidatorToFieldController(
  BaseUnifiedFieldController<String>? fieldController,
  String? Function(String value)? widgetValidator,
) {
  if (fieldController == null || widgetValidator == null) return;
  fieldController.validator = (value) => widgetValidator(value ?? '');
}

/// Picker fields validate display [String] while [UnifiedPickerFieldController]
/// stores [T?]; maps between them via [displayFor].
void syncPickerStringValidatorToFieldController<T>(
  UnifiedPickerFieldController<T>? fieldController,
  String? Function(String value)? widgetValidator,
  String Function(T? value) displayFor,
) {
  if (fieldController == null || widgetValidator == null) return;
  fieldController.validator = (value) => widgetValidator(displayFor(value));
}

/// Like [syncPickerStringValidatorToFieldController] for multi-select pickers.
void syncMultiPickerStringValidatorToFieldController<T>(
  UnifiedMultiPickerFieldController<T>? fieldController,
  String? Function(String value)? widgetValidator,
  String Function(List<T>? value) displayFor,
) {
  if (fieldController == null || widgetValidator == null) return;
  fieldController.validator = (value) => widgetValidator(displayFor(value));
}

/// Maps a display-[String] [widgetValidator] (non-form fields) onto a typed
/// [BaseUnifiedFieldController] using [displayFor].
void syncDisplayStringValidatorToFieldController<T>({
  BaseUnifiedFieldController<T>? fieldController,
  String? Function(String value)? widgetValidator,
  required String Function(T? value) displayFor,
}) {
  if (fieldController == null || widgetValidator == null) return;
  fieldController.validator = (value) => widgetValidator(displayFor(value));
}

/// [UnifiedNumberFieldController]: widget validates edited text; controller stores [num?].
void syncNumberDisplayValidatorToFieldController(
  UnifiedNumberFieldController? fieldController,
  String? Function(String value)? widgetValidator,
) {
  if (fieldController == null || widgetValidator == null) return;
  fieldController.validator =
      (_) => widgetValidator(fieldController.text.textController.text);
}

/// Copies a [FormFieldValidator] for numeric text onto [UnifiedNumberFieldController].
void syncNumberFormStringValidatorToFieldController(
  UnifiedNumberFieldController? fieldController,
  FormFieldValidator<String>? widgetValidator,
) {
  if (fieldController == null || widgetValidator == null) return;
  fieldController.validator =
      (_) => widgetValidator(fieldController.text.textController.text);
}

/// Clears [FormFieldState] error when the current value passes [validator].
///
/// Does not set new errors while the user edits (invalid → valid only).
///
/// Must stay generic: reading [FormField.validator] through an untyped
/// [FormFieldState] causes a runtime cast error for typed validators
/// such as `String? Function(List<T>?)`.
void unifiedFormClearErrorIfValid<T>(FormFieldState<T> fieldState) {
  if (!fieldState.hasError) return;
  final validator = fieldState.widget.validator;
  if (validator == null) return;
  if (validator(fieldState.value) == null) {
    fieldState.validate();
  }
}

/// Effective value: [fieldController] → [binding] → [direct].
T? unifiedEffectiveValue<T>({
  BaseUnifiedFieldController<T>? fieldController,
  UnifiedInputPicker<T>? binding,
  T? direct,
}) => fieldController?.value ?? binding?.value ?? direct;

/// Effective list value for multi-select fields.
List<T> unifiedEffectiveListValue<T>({
  BaseUnifiedFieldController<List<T>>? fieldController,
  UnifiedInputPicker<List<T>>? binding,
  List<T> direct = const [],
}) => fieldController?.value ?? binding?.value ?? direct;
