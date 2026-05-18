/// How the field label is positioned relative to the input.
enum UnifiedFieldLabelMode {
  /// Label in a left column sharing one border with the field ([labelInRow] legacy).
  labelInRow,

  /// Label rendered above the field in its own row (package style before floating default).
  labelInColumn,

  /// Material-style label that floats inside the field border when focused or filled.
  floatingLabel,
}

/// Resolves [UnifiedFieldLabelMode] from explicit [mode], [themeMode], or legacy [labelInRow].
UnifiedFieldLabelMode resolveUnifiedFieldLabelMode({
  UnifiedFieldLabelMode? mode,
  bool labelInRow = false,
  UnifiedFieldLabelMode? themeMode,
}) {
  if (mode != null) return mode;
  if (themeMode != null) return themeMode;
  if (labelInRow) return UnifiedFieldLabelMode.labelInRow;
  return UnifiedFieldLabelMode.floatingLabel;
}
