import 'base_unified_field_controller.dart';
import 'unified_field_validation.dart';

/// Groups unified field controllers for submit-time validation.
class UnifiedFormController {
  /// Creates a form controller with an optional initial [fields] list.
  UnifiedFormController([
    List<BaseUnifiedFieldController<Object?>> fields = const [],
  ]) : fields = List<BaseUnifiedFieldController<Object?>>.from(fields);

  /// Registered field controllers (add via [register]).
  final List<BaseUnifiedFieldController<Object?>> fields;

  /// Adds [controller] if not already registered.
  void register(BaseUnifiedFieldController<Object?> controller) {
    if (!fields.contains(controller)) {
      fields.add(controller);
    }
  }

  /// Removes [controller] from the group.
  void unregister(BaseUnifiedFieldController<Object?> controller) {
    fields.remove(controller);
  }

  /// Runs [UnifiedFieldValidation.validateFields] on [fields].
  bool validate() => UnifiedFieldValidation.validateFields(fields);

  /// Controllers that failed the last [validate] call.
  List<BaseUnifiedFieldController<Object?>> invalidFields() =>
      UnifiedFieldValidation.invalidFields(fields);

  /// Clears errors on all [fields].
  void clearErrors() {
    for (final c in fields) {
      c.clearError();
    }
  }

  /// Clears values and errors on all [fields].
  void clearAll() {
    for (final c in fields) {
      c.clear();
    }
  }
}
