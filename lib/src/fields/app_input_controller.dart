import '../controllers/base_unified_field_controller.dart';

/// External handle to read/update unified field values (pickers, dates, durations, etc.).
///
/// Prefer [BaseUnifiedFieldController] subclasses (e.g. [UnifiedTextFieldController])
/// for validation, focus, and type-specific actions. [AppInputController] remains as a
/// lightweight alias for existing `binding` parameters.
///
/// Listen with [Listenable.merge] or attach to [AnimatedBuilder]; widgets sync both ways when bound.
class AppInputController<T> extends BaseUnifiedFieldController<T> {
  /// Creates a controller, optionally seeded with [initialValue].
  AppInputController({
    super.initialValue,
    super.validator,
    super.focusNode,
  });
}
