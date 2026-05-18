/// ISO 3166-1 alpha-2 codes whose SVG file uses a `c_` prefix in the bundle.
const Map<String, String> kUnifiedFlagIsoAssetStemOverrides = {
  'as': 'c_as',
  'do': 'c_do',
  'in': 'c_in',
  'is': 'c_is',
};

/// Resolves [isoCode] to the asset file stem under `country_{stem}.svg`.
String resolveUnifiedFlagAssetStem(String isoCode) {
  final normalized = isoCode.trim().toLowerCase().replaceAll('-', '_');
  if (normalized.contains('_')) return normalized;
  return kUnifiedFlagIsoAssetStemOverrides[normalized] ?? normalized;
}
