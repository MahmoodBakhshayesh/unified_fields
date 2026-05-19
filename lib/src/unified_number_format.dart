import 'unified_date_picker_types.dart';
import 'unified_fields_typography.dart';

/// Fraction digits used when [allowDecimals] is true and [fractionDigits] is null
/// (step rounding in [UnifiedNumericStepField]).
const int kUnifiedNumberDefaultDecimalQuantizeDigits = 2;

/// Whether typed numeric input should allow Persian / Arabic-Indic digits.
bool unifiedNumberInputAllowsLocalizedDigits({
  UnifiedFieldsCalendarKind? calendarKind,
}) =>
    UnifiedFieldsTypography.instance.shouldUsePersianDigits(
      calendarKind: calendarKind,
    );

const String _kLocalizedDigitClass = r'0-9\u06F0-\u06F9\u0660-\u0669';

/// Input filter for [UnifiedNumericStepField] (ASCII and localized digits).
RegExp unifiedNumberInputPattern({
  required bool allowDecimals,
  UnifiedFieldsCalendarKind? calendarKind,
}) {
  final localized = unifiedNumberInputAllowsLocalizedDigits(
    calendarKind: calendarKind,
  );
  if (allowDecimals) {
    if (localized) {
      return RegExp(
        r'^[-+]?[' +
            _kLocalizedDigitClass +
            r']*\.?[' +
            _kLocalizedDigitClass +
            r']*$',
      );
    }
    return RegExp(r'^[-+]?\d*\.?\d*$');
  }
  if (localized) {
    return RegExp(r'^[-+]?[' + _kLocalizedDigitClass + r']*$');
  }
  return RegExp(r'^[-+]?\d*$');
}

/// Formats [value] for display in number fields (ASCII digits, then localization).
String formatUnifiedNumberFieldText(
  num value, {
  required bool allowDecimals,
  int? fractionDigits,
  UnifiedFieldsCalendarKind? calendarKind,
}) {
  final String raw;
  if (!allowDecimals) {
    raw = value.round().toString();
  } else {
    final fd = fractionDigits;
    if (fd != null) {
      raw = value.toDouble().toStringAsFixed(fd);
    } else {
      final d = value.toDouble();
      if (!d.isFinite) {
        raw = d.toString();
      } else if (d % 1 == 0) {
        raw = d.toInt().toString();
      } else {
        raw = d.toString();
      }
    }
  }
  return UnifiedFieldsTypography.instance.localizeDigits(
    raw,
    calendarKind: calendarKind,
  );
}

/// Localizes digits in partial numeric typing text (e.g. `12.` → `۱۲.`).
String localizeUnifiedNumberDisplayText(
  String text, {
  UnifiedFieldsCalendarKind? calendarKind,
}) =>
    UnifiedFieldsTypography.instance.localizeDigits(
      text,
      calendarKind: calendarKind,
    );
