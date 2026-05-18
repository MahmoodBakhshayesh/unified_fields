import 'unified_country_enum.dart';

export 'unified_country_enum.dart' show UnifiedCountry;

/// Parsed phone value from [UnifiedPhoneField].
class UnifiedPhoneNumber {
  /// Creates a phone value.
  const UnifiedPhoneNumber({
    required this.country,
    required this.nationalDigits,
  });

  /// Selected country (dial code + metadata).
  final UnifiedCountry country;

  /// National significant number (digits only, no dial code).
  final String nationalDigits;

  /// E.164-style string (`+` + country + national).
  String get e164 => '${country.dialCode}$nationalDigits';

  /// Display string with space after dial code.
  String get display => nationalDigits.isEmpty
      ? country.dialCode
      : '${country.dialCode} $nationalDigits';

  @override
  bool operator ==(Object other) =>
      other is UnifiedPhoneNumber &&
      other.country == country &&
      other.nationalDigits == nationalDigits;

  @override
  int get hashCode => Object.hash(country, nationalDigits);
}

/// Converts `US` → 🇺🇸.
String isoToFlagEmoji(String isoCode) {
  if (isoCode.length != 2) return '';
  final upper = isoCode.toUpperCase();
  final first = upper.codeUnitAt(0);
  final second = upper.codeUnitAt(1);
  if (first < 65 || first > 90 || second < 65 || second > 90) return '';
  return String.fromCharCode(0x1F1E6 + first - 65) +
      String.fromCharCode(0x1F1E6 + second - 65);
}

/// Default national mask when none is provided (`#` = digit).
const String kUnifiedPhoneDefaultNationalMask = '### ### ####';
