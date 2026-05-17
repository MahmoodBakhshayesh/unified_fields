import '../controllers/base_unified_field_controller.dart';

/// External handle to read/update unified field values (text, pickers, dates, etc.).
///
/// Prefer [BaseUnifiedFieldController] subclasses (e.g. [UnifiedTextFieldController])
/// for validation, focus, and type-specific actions. [UnifiedInputPicker] is the
/// lightweight binding used by `binding:` parameters.
///
/// Listen with [Listenable.merge] or attach to [AnimatedBuilder]; widgets sync both ways when bound.
class UnifiedInputPicker<T> extends BaseUnifiedFieldController<T> {
  /// Creates a binding controller, optionally seeded with [initialValue].
  UnifiedInputPicker({super.initialValue, super.validator, super.focusNode});
}

/// @deprecated Renamed to [UnifiedInputPicker].
@Deprecated('Use UnifiedInputPicker')
typedef AppInputController<T> = UnifiedInputPicker<T>;
