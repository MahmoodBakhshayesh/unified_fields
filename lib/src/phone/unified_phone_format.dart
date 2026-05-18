import 'package:flutter/services.dart';

import '../unified_date_picker_types.dart';
import '../unified_fields_typography.dart';
import 'unified_country.dart';
import 'unified_phone_models.dart';

/// Applies [mask] (`#` = digit) to [digits] for display.
String applyUnifiedPhoneMask(String digits, String mask) {
  if (digits.isEmpty) return '';
  final buffer = StringBuffer();
  var i = 0;
  for (var m = 0; m < mask.length && i < digits.length; m++) {
    if (mask[m] == '#') {
      buffer.write(digits[i]);
      i++;
    } else {
      buffer.write(mask[m]);
    }
  }
  return buffer.toString();
}

/// Strips non-digits from [raw] (accepts Persian / Arabic-Indic numerals).
String unifiedPhoneDigitsOnly(String raw) =>
    UnifiedFieldsTypography.fromPersianDigits(raw).replaceAll(RegExp(r'\D'), '');

/// Whether Persian digit rules apply for phone formatters / display.
bool unifiedPhoneUsePersianDigits({
  bool? usePersianDigits,
  UnifiedFieldsCalendarKind? digitCalendarKind,
}) {
  if (usePersianDigits == true) return true;
  if (usePersianDigits == false) return false;
  return UnifiedFieldsTypography.instance.shouldUsePersianDigits(
    calendarKind: digitCalendarKind,
  );
}

/// Localizes phone display text when Persian mode is active.
String unifiedPhoneLocalizeDisplay(
  String asciiText, {
  bool? usePersianDigits,
  UnifiedFieldsCalendarKind? digitCalendarKind,
}) {
  if (!unifiedPhoneUsePersianDigits(
    usePersianDigits: usePersianDigits,
    digitCalendarKind: digitCalendarKind,
  )) {
    return asciiText;
  }
  final typography = UnifiedFieldsTypography.instance;
  if (!typography.localizeAsciiDigits) return asciiText;
  if (usePersianDigits == true) {
    return UnifiedFieldsTypography.toPersianDigits(asciiText);
  }
  return typography.localizeDigits(
    asciiText,
    calendarKind: digitCalendarKind,
  );
}

/// Max ITU country-code digits (excluding `+`).
const int kUnifiedPhoneMaxDialDigits = 4;

/// Formats all digits after `+` with dial code + masked national segment.
String formatUnifiedFullPhoneText(
  String digitsAfterPlus, {
  required String nationalMask,
  required List<UnifiedCountry> countries,
  int maxDialDigits = kUnifiedPhoneMaxDialDigits,
  bool? usePersianDigits,
  UnifiedFieldsCalendarKind? digitCalendarKind,
}) {
  if (digitsAfterPlus.isEmpty) {
    return unifiedPhoneLocalizeDisplay(
      '+',
      usePersianDigits: usePersianDigits,
      digitCalendarKind: digitCalendarKind,
    );
  }
  final clipped = digitsAfterPlus.length > maxDialDigits + _maskDigitCount(nationalMask)
      ? digitsAfterPlus.substring(
          0,
          maxDialDigits + _maskDigitCount(nationalMask),
        )
      : digitsAfterPlus;

  final matched = UnifiedCountries.matchDialCode('+$clipped', countries);
  if (matched == null) {
    return unifiedPhoneLocalizeDisplay(
      '+$clipped',
      usePersianDigits: usePersianDigits,
      digitCalendarKind: digitCalendarKind,
    );
  }

  final dialDigitCount = matched.dialCode.length - 1;
  final dialDigits = clipped.length <= dialDigitCount
      ? clipped
      : clipped.substring(0, dialDigitCount);
  final nationalDigits = clipped.length > dialDigitCount
      ? clipped.substring(dialDigitCount)
      : '';
  if (nationalDigits.isEmpty) {
    return unifiedPhoneLocalizeDisplay(
      '+$dialDigits',
      usePersianDigits: usePersianDigits,
      digitCalendarKind: digitCalendarKind,
    );
  }
  final masked = applyUnifiedPhoneMask(nationalDigits, nationalMask);
  return unifiedPhoneLocalizeDisplay(
    '+$dialDigits $masked',
    usePersianDigits: usePersianDigits,
    digitCalendarKind: digitCalendarKind,
  );
}

int _maskDigitCount(String mask) =>
    mask.split('').where((c) => c == '#').length;

/// One-field entry: `+`, dial digits, then masked national digits.
class UnifiedPhoneFullNumberFormatter extends TextInputFormatter {
  /// Creates a formatter for a single combined phone field.
  UnifiedPhoneFullNumberFormatter({
    this.nationalMask = kUnifiedPhoneDefaultNationalMask,
    this.maxDialDigits = kUnifiedPhoneMaxDialDigits,
    List<UnifiedCountry>? countries,
    this.usePersianDigits,
    this.digitCalendarKind,
  }) : countries = countries ?? UnifiedCountry.values;

  /// National mask (`#` = digit) applied after the matched dial code.
  final String nationalMask;

  /// Max dial-code digits typed after `+` before national digits.
  final int maxDialDigits;

  /// Used to detect dial-code length for masking.
  final List<UnifiedCountry> countries;

  /// Forces Persian digits on (`true`) or off (`false`); null uses [digitCalendarKind] / global typography.
  final bool? usePersianDigits;

  /// When [UnifiedFieldsCalendarKind.jalali], Persian digits are used unless overridden.
  final UnifiedFieldsCalendarKind? digitCalendarKind;

  int get _maxNationalDigits => _maskDigitCount(nationalMask);

  /// Max digits allowed after `+` (dial + national).
  int get maxDigitCount => maxDialDigits + _maxNationalDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var t = UnifiedFieldsTypography.fromPersianDigits(newValue.text);
    if (t.isEmpty) {
      final empty = unifiedPhoneLocalizeDisplay(
        '+',
        usePersianDigits: usePersianDigits,
        digitCalendarKind: digitCalendarKind,
      );
      return TextEditingValue(
        text: empty,
        selection: TextSelection.collapsed(offset: empty.length),
      );
    }
    if (!t.startsWith('+')) {
      t = '+$t';
    }
    final digits = unifiedPhoneDigitsOnly(t);
    final out = formatUnifiedFullPhoneText(
      digits,
      nationalMask: nationalMask,
      countries: countries,
      maxDialDigits: maxDialDigits,
      usePersianDigits: usePersianDigits,
      digitCalendarKind: digitCalendarKind,
    );
    return TextEditingValue(
      text: out,
      selection: TextSelection.collapsed(offset: out.length),
    );
  }
}

/// Input formatter: digits only, optional max length from mask `#` count.
class UnifiedPhoneNationalFormatter extends TextInputFormatter {
  /// Creates a formatter for national digits.
  UnifiedPhoneNationalFormatter({
    this.mask = kUnifiedPhoneDefaultNationalMask,
    this.usePersianDigits,
    this.digitCalendarKind,
  });

  /// Mask used only to determine max digit count.
  final String mask;

  /// Forces Persian digits on (`true`) or off (`false`); null uses [digitCalendarKind] / global typography.
  final bool? usePersianDigits;

  /// When [UnifiedFieldsCalendarKind.jalali], Persian digits are used unless overridden.
  final UnifiedFieldsCalendarKind? digitCalendarKind;

  int get _maxDigits => _maskDigitCount(mask);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = unifiedPhoneDigitsOnly(newValue.text);
    final clipped =
        digits.length > _maxDigits ? digits.substring(0, _maxDigits) : digits;
    final masked = applyUnifiedPhoneMask(clipped, mask);
    final display = unifiedPhoneLocalizeDisplay(
      masked,
      usePersianDigits: usePersianDigits,
      digitCalendarKind: digitCalendarKind,
    );
    return TextEditingValue(
      text: display,
      selection: TextSelection.collapsed(offset: display.length),
    );
  }
}

/// @deprecated Use [UnifiedPhoneFullNumberFormatter] for single-field entry.
class UnifiedPhoneDialCodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var t = newValue.text;
    if (t.isEmpty) {
      return const TextEditingValue(
        text: '+',
        selection: TextSelection.collapsed(offset: 1),
      );
    }
    if (!t.startsWith('+')) {
      t = '+$t';
    }
    final digits = unifiedPhoneDigitsOnly(t);
    final clipped = digits.length > kUnifiedPhoneMaxDialDigits
        ? digits.substring(0, kUnifiedPhoneMaxDialDigits)
        : digits;
    final out = '+$clipped';
    return TextEditingValue(
      text: out,
      selection: TextSelection.collapsed(offset: out.length),
    );
  }
}
