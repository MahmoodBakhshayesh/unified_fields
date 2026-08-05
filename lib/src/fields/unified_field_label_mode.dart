/// How the field label is positioned relative to the input.
enum UnifiedFieldLabelMode {
  /// Label in a left column sharing one border with the field ([labelInRow] legacy).
  labelInRow,

  /// Label rendered above the field in its own row (package style before floating default).
  labelInColumn,

  /// Material-style label that floats inside the field border when focused or filled.
  floatingLabel,
}

/// Resolves [UnifiedFieldLabelMode] from explicit [mode], legacy [labelInRow], or [themeMode].
///
/// Order: explicit [mode] → field [labelInRow] flag → theme → floating.
/// Field-level `labelInRow: true` must win over a theme default of column/floating,
/// otherwise [UnifiedInputDecoration.rowLabelRatio] appears to do nothing in apps
/// whose theme is not row-first (unlike the package example).
UnifiedFieldLabelMode resolveUnifiedFieldLabelMode({
  UnifiedFieldLabelMode? mode,
  bool labelInRow = false,
  UnifiedFieldLabelMode? themeMode,
}) {
  if (mode != null) return mode;
  if (labelInRow) return UnifiedFieldLabelMode.labelInRow;
  if (themeMode != null) return themeMode;
  return UnifiedFieldLabelMode.floatingLabel;
}
