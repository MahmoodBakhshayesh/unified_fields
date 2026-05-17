import 'base_unified_field_controller.dart';

/// Cross-field validation helpers for unified controllers.
abstract final class UnifiedFieldValidation {
  /// Runs [BaseUnifiedFieldController.validate] on each controller.
  ///
  /// Returns `true` when every controller is valid.
  static bool validateFields(Iterable<BaseUnifiedFieldController<Object?>> controllers) {
    var ok = true;
    for (final c in controllers) {
      if (c.validate() != null) {
        ok = false;
      }
    }
    return ok;
  }

  /// Same as [validateFields] but returns the list of controllers that failed.
  static List<BaseUnifiedFieldController<Object?>> invalidFields(
    Iterable<BaseUnifiedFieldController<Object?>> controllers,
  ) {
    final bad = <BaseUnifiedFieldController<Object?>>[];
    for (final c in controllers) {
      if (c.validate() != null) {
        bad.add(c);
      }
    }
    return bad;
  }
}
