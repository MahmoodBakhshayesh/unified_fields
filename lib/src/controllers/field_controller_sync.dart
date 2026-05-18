import 'package:flutter/widgets.dart';

import '../fields/unified_input_picker.dart';
import 'base_unified_field_controller.dart';
import 'unified_picker_field_controller.dart';

/// Focus node: [fieldController] → [binding] → [direct].
FocusNode? unifiedEffectiveFocusNode<T>({
  BaseUnifiedFieldController<T>? fieldController,
  UnifiedInputPicker<T>? binding,
  FocusNode? direct,
}) => fieldController?.focusNode ?? binding?.focusNode ?? direct;

/// Opens a picker sheet the same way as tapping the bound field.
typedef UnifiedFieldOpener = Future<void> Function(BuildContext context);

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
void syncFormFieldFromExternalValue<T>({
  FormFieldState<T?>? formState,
  required T? value,
  BaseUnifiedFieldController<T>? fieldController,
}) {
  if (formState != null && formState.value != value) {
    formState.didChange(value);
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
  }
  if (fieldController != null &&
      !unifiedListsEqual(fieldController.value, value)) {
    fieldController.value = value;
  }
}

/// Syncs a new field value to optional [onChanged], [binding], and [fieldController].
void syncUnifiedFieldValue<T>({
  required T? value,
  ValueChanged<T?>? onChanged,
  UnifiedInputPicker<T>? binding,
  BaseUnifiedFieldController<T>? fieldController,
}) {
  onChanged?.call(value);
  if (binding != null && binding.value != value) {
    binding.value = value;
  }
  if (fieldController != null && fieldController.value != value) {
    fieldController.value = value;
  }
}

/// Syncs list value for multi-select fields.
void syncUnifiedFieldListValue<T>({
  required List<T> value,
  ValueChanged<List<T>>? onChanged,
  UnifiedInputPicker<List<T>>? binding,
  BaseUnifiedFieldController<List<T>>? fieldController,
}) {
  onChanged?.call(value);
  if (binding != null) {
    binding.value = value;
  }
  if (fieldController != null) {
    fieldController.value = value;
  }
}

/// Copies [widgetValidator] onto [fieldController] when the widget supplies one.
///
/// Keeps [BaseUnifiedFieldController.validate] and
/// [UnifiedFieldValidation.validateFields] aligned with a field / [FormField] validator.
/// Does nothing when [widgetValidator] is null (controller keeps its own validator).
void syncWidgetValidatorToFieldController<T>(
  BaseUnifiedFieldController<T>? fieldController,
  String? Function(T? value)? widgetValidator,
) {
  if (fieldController == null || widgetValidator == null) return;
  fieldController.validator = widgetValidator;
}

/// Like [syncWidgetValidatorToFieldController] for [String] fields whose widget
/// validator uses a non-nullable [String] argument.
void syncWidgetStringValidatorToFieldController(
  BaseUnifiedFieldController<String>? fieldController,
  String? Function(String value)? widgetValidator,
) {
  if (fieldController == null || widgetValidator == null) return;
  fieldController.validator = (value) => widgetValidator(value ?? '');
}

/// Picker fields validate display [String] while [UnifiedPickerFieldController]
/// stores [String? Function(T? value)?]; maps between them via [displayFor].
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
