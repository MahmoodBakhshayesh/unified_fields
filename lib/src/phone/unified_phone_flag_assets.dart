import 'unified_flag_asset_resolver.dart';

/// Package name for asset lookups from apps depending on [unified_fields].
const String unifiedFieldsPackageName = 'unified_fields';

/// Asset path for a country flag SVG.
String unifiedFlagAssetPath(String code) {
  final stem = resolveUnifiedFlagAssetStem(code);
  return 'assets/flags/countries/country_$stem.svg';
}

/// @deprecated Use [unifiedFlagAssetPath].
String unifiedPhoneCountryFlagAssetPath(String isoCode) => unifiedFlagAssetPath(isoCode);
