import 'package:flutter/material.dart';

import '../unified_date_picker_types.dart';
import '../unified_fields_typography.dart';
import 'unified_flag.dart';
import 'unified_input_phone_style.dart';
import 'unified_phone_format.dart';
import 'unified_phone_flag_assets.dart';
import 'unified_phone_models.dart';

export 'unified_country_enum.dart' show UnifiedCountry;

/// Flag, dial code, and display helpers for [UnifiedCountry].
extension UnifiedCountryX on UnifiedCountry {
  /// Bundled SVG asset path for this country flag.
  String get flagAssetPath => unifiedFlagAssetPath(isoCode);

  /// Regional-indicator flag emoji for [isoCode].
  String get flagEmoji => isoToFlagEmoji(isoCode);

  /// [dialCode] with Persian digits when requested.
  String localizedDialCode({
    bool? usePersianDigits,
    UnifiedFieldsCalendarKind? digitCalendarKind,
  }) =>
      unifiedPhoneLocalizeDisplay(
        dialCode,
        usePersianDigits: usePersianDigits,
        digitCalendarKind: digitCalendarKind,
      );
}

/// Lookup and dial-code matching for [UnifiedCountry].
abstract final class UnifiedCountries {
  /// All bundled countries (same as [UnifiedCountry.values]).
  static final List<UnifiedCountry> defaults = List<UnifiedCountry>.unmodifiable(
    UnifiedCountry.values,
  );

  /// All enum values.
  static List<UnifiedCountry> get supported => UnifiedCountry.values;

  /// Default selection when none is provided (United States).
  static const UnifiedCountry defaultCountry = UnifiedCountry.us;

  /// Finds by ISO code (case-insensitive).
  static UnifiedCountry? byIso(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    final key = iso.toUpperCase();
    for (final c in UnifiedCountry.values) {
      if (c.isoCode == key) return c;
    }
    return null;
  }

  /// Finds the longest matching dial code prefix in [digitsWithPlus] (must start with `+`).
  static UnifiedCountry? matchDialCode(
    String digitsWithPlus, [
    List<UnifiedCountry>? pool,
  ]) {
    pool ??= defaults;
    digitsWithPlus = UnifiedFieldsTypography.fromPersianDigits(digitsWithPlus);
    if (!digitsWithPlus.startsWith('+')) return null;
    UnifiedCountry? best;
    for (final c in pool) {
      if (digitsWithPlus.startsWith(c.dialCode) &&
          (best == null || c.dialCode.length > best.dialCode.length)) {
        best = c;
      }
    }
    return best;
  }

  /// True when [code] is a valid prefix of some country dial code in [pool].
  static bool isValidDialCodePrefix(
    String code, [
    List<UnifiedCountry>? pool,
  ]) {
    pool ??= defaults;
    code = UnifiedFieldsTypography.fromPersianDigits(code);
    if (!code.startsWith('+')) return false;
    if (code == '+') return true;
    for (final c in pool) {
      if (c.dialCode.startsWith(code) || code.startsWith(c.dialCode)) {
        return true;
      }
    }
    return false;
  }
}

/// Localized display helpers for [UnifiedPhoneNumber].
extension UnifiedPhoneNumberDisplay on UnifiedPhoneNumber {
  /// E.164-style string with optional Persian digits.
  String localizedE164({
    bool? usePersianDigits,
    UnifiedFieldsCalendarKind? digitCalendarKind,
  }) =>
      unifiedPhoneLocalizeDisplay(
        e164,
        usePersianDigits: usePersianDigits,
        digitCalendarKind: digitCalendarKind,
      );

  /// Formatted display (`+` dial + masked national) with optional Persian digits.
  String localizedDisplay({
    bool? usePersianDigits,
    UnifiedFieldsCalendarKind? digitCalendarKind,
    String nationalMask = kUnifiedPhoneDefaultNationalMask,
  }) {
    if (nationalDigits.isEmpty) {
      return country.localizedDialCode(
        usePersianDigits: usePersianDigits,
        digitCalendarKind: digitCalendarKind,
      );
    }
    final masked = applyUnifiedPhoneMask(nationalDigits, nationalMask);
    return unifiedPhoneLocalizeDisplay(
      '${country.dialCode} $masked',
      usePersianDigits: usePersianDigits,
      digitCalendarKind: digitCalendarKind,
    );
  }
}

/// Public country row: flag, optional name, optional localized dial code.
///
/// Use anywhere (lists, chips, settings) — not only inside [UnifiedPhoneField].
class UnifiedCountryWidget extends StatelessWidget {
  /// Creates a country display row.
  const UnifiedCountryWidget({
    super.key,
    required this.country,
    this.showFlag = true,
    this.showName = false,
    this.showDialCode = false,
    this.nameStyle,
    this.dialCodeStyle,
    this.flagStyle,
    this.usePersianDigits,
    this.digitCalendarKind,
    this.spacing = 8,
    this.textDirection = TextDirection.ltr,
  });

  /// Supported country entry.
  final UnifiedCountry country;

  /// Shows the SVG flag via [UnifiedFlag].
  final bool showFlag;

  /// Shows [UnifiedCountry.name].
  final bool showName;

  /// Shows [UnifiedCountry.dialCode] (localized when Persian mode is on).
  final bool showDialCode;

  /// Style for the country name.
  final TextStyle? nameStyle;

  /// Style for the dial code.
  final TextStyle? dialCodeStyle;

  /// Passed to [UnifiedFlag].
  final UnifiedInputPhoneStyle? flagStyle;

  /// When `true`, dial code uses Persian digits; when `false`, ASCII only.
  final bool? usePersianDigits;

  /// Jalali calendar enables Persian digits unless [usePersianDigits] overrides.
  final UnifiedFieldsCalendarKind? digitCalendarKind;

  /// Horizontal gap between flag, name, and dial code.
  final double spacing;

  /// Text direction for name and dial code (defaults to LTR for phone numbers).
  final TextDirection textDirection;

  TextStyle _mergeDigit(TextStyle? base, TextStyle fallback) {
    final style = base ?? fallback;
    if (!unifiedPhoneUsePersianDigits(
      usePersianDigits: usePersianDigits,
      digitCalendarKind: digitCalendarKind,
    )) {
      return style;
    }
    var merged = UnifiedFieldsTypography.instance.mergeDigitStyle(
      style,
      calendarKind: digitCalendarKind,
    );
    if (usePersianDigits == true &&
        (merged.fontFamily == null || merged.fontFamily!.isEmpty)) {
      final family = UnifiedFieldsTypography.instance.persianFontFamily;
      if (family != null && family.isNotEmpty) {
        merged = merged.copyWith(fontFamily: family);
      }
    }
    return merged;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nameFallback = theme.textTheme.bodyMedium ?? const TextStyle();
    final dialFallback = theme.textTheme.bodySmall ?? nameFallback;

    final children = <Widget>[];
    if (showFlag) {
      children.add(UnifiedFlag(code: country.isoCode, style: flagStyle));
    }
    if (showName) {
      if (children.isNotEmpty) children.add(SizedBox(width: spacing));
      children.add(
        Flexible(
          child: Text(
            country.name,
            style: _mergeDigit(nameStyle, nameFallback),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
    if (showDialCode) {
      if (children.isNotEmpty) children.add(SizedBox(width: spacing));
      children.add(
        Text(
          country.localizedDialCode(
            usePersianDigits: usePersianDigits,
            digitCalendarKind: digitCalendarKind,
          ),
          style: _mergeDigit(dialCodeStyle, dialFallback),
        ),
      );
    }

    return Directionality(
      textDirection: textDirection,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

/// @deprecated Use [UnifiedCountryWidget].
@Deprecated('Use UnifiedCountryWidget')
typedef UnifiedCountryRow = UnifiedCountryWidget;
