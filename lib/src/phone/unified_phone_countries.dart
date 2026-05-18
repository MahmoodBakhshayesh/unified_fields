import 'unified_country.dart';

export 'unified_country.dart' show UnifiedCountries, UnifiedCountry;

/// @deprecated Use [UnifiedCountries].
@Deprecated('Use UnifiedCountries')
abstract final class UnifiedPhoneCountries {
  /// @deprecated Use [UnifiedCountries.defaults].
  @Deprecated('Use UnifiedCountries.defaults')
  static final List<UnifiedCountry> defaults = UnifiedCountries.defaults;

  /// @deprecated Use [UnifiedCountries.byIso].
  @Deprecated('Use UnifiedCountries.byIso')
  static UnifiedCountry? byIso(String? iso) => UnifiedCountries.byIso(iso);

  /// @deprecated Use [UnifiedCountries.matchDialCode].
  @Deprecated('Use UnifiedCountries.matchDialCode')
  static UnifiedCountry? matchDialCode(
    String digitsWithPlus,
    List<UnifiedCountry> pool,
  ) =>
      UnifiedCountries.matchDialCode(digitsWithPlus, pool);

  /// @deprecated Use [UnifiedCountries.isValidDialCodePrefix].
  @Deprecated('Use UnifiedCountries.isValidDialCodePrefix')
  static bool isValidDialCodePrefix(String code, List<UnifiedCountry> pool) =>
      UnifiedCountries.isValidDialCodePrefix(code, pool);
}
