import 'package:flutter/painting.dart';

import 'unified_date_picker_types.dart';

/// Persian (Eastern Arabic) digit display and optional numeral font for unified_fields.
///
/// Set before `runApp` for app-wide Persian digits in all fields:
///
/// ```dart
/// UnifiedFieldsTypography.instance = const UnifiedFieldsTypography(
///   usePersianDigitsGlobally: true,
/// );
/// ```
///
/// Shamsi (Jalali) pickers use Persian digits by default when
/// [usePersianDigitsInShamsi] is `true` (bundled [KookFaNum] font).
class UnifiedFieldsTypography {
  /// Creates typography / digit options.
  const UnifiedFieldsTypography({
    this.persianFontFamily = kUnifiedFieldsDefaultPersianFontFamily,
    this.usePersianDigitsGlobally = false,
    this.usePersianDigitsInShamsi = true,
    this.localizeAsciiDigits = true,
  });

  /// Active settings for unified_fields widgets.
  static UnifiedFieldsTypography instance = const UnifiedFieldsTypography();

  /// Font family registered in this package's `pubspec.yaml` ([KookFaNum]).
  static const String kUnifiedFieldsDefaultPersianFontFamily = 'KookFaNum';

  /// Font applied when Persian digits are active (override with your own if needed).
  final String? persianFontFamily;

  /// When `true`, all unified fields and pickers show Persian digits.
  final bool usePersianDigitsGlobally;

  /// When `true`, Shamsi / Jalali calendar UI uses Persian digits.
  final bool usePersianDigitsInShamsi;

  /// When `true`, ASCII `0`–`9` in displayed strings become ۰–۹.
  final bool localizeAsciiDigits;

  /// Whether Persian digit rules apply for [calendarKind].
  bool shouldUsePersianDigits({UnifiedFieldsCalendarKind? calendarKind}) {
    if (usePersianDigitsGlobally) return true;
    if (calendarKind == UnifiedFieldsCalendarKind.jalali && usePersianDigitsInShamsi) {
      return true;
    }
    return false;
  }

  /// Localizes digits in [text] when [shouldUsePersianDigits] is true.
  String localizeDigits(
    String text, {
    UnifiedFieldsCalendarKind? calendarKind,
  }) {
    if (!shouldUsePersianDigits(calendarKind: calendarKind)) return text;
    if (!localizeAsciiDigits) return text;
    return toPersianDigits(text);
  }

  /// Merges [persianFontFamily] into [style] when Persian digits are active.
  TextStyle mergeDigitStyle(
    TextStyle style, {
    UnifiedFieldsCalendarKind? calendarKind,
  }) {
    if (!shouldUsePersianDigits(calendarKind: calendarKind)) return style;
    final family = persianFontFamily;
    if (family == null || family.isEmpty) return style;
    return style.copyWith(fontFamily: family);
  }

  /// Converts Persian (۰–۹) and Arabic-Indic (٠–٩) digits to ASCII `0`–`9`.
  static String fromPersianDigits(String input) {
    if (input.isEmpty) return input;
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0x06F0 && rune <= 0x06F9) {
        buffer.writeCharCode(0x30 + (rune - 0x06F0));
      } else if (rune >= 0x0660 && rune <= 0x0669) {
        buffer.writeCharCode(0x30 + (rune - 0x0660));
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  /// Replaces ASCII digits in [input] with Persian digits (۰–۹).
  static String toPersianDigits(String input) {
    if (input.isEmpty) return input;
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0x30 && rune <= 0x39) {
        buffer.writeCharCode(0x06F0 + (rune - 0x30));
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }
}
