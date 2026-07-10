/// Which +/- step buttons are shown on [UnifiedNumericStepField].
enum UnifiedNumericStepButtons {
  /// Increment and decrement (default).
  both,

  /// Only the increment (+) button.
  incrementOnly,

  /// Only the decrement (−) button.
  decrementOnly,

  /// Hide step buttons; [UnifiedInputDecoration] prefix/suffix may still show.
  none,
}

/// Where step buttons sit relative to the value and optional adornments.
enum UnifiedNumericStepButtonPlacement {
  /// Decrement on the leading edge, increment on the trailing edge (default).
  split,

  /// Both buttons on the leading ([UnifiedBaseTextField.prefix]) side.
  leading,

  /// Both buttons on the trailing ([UnifiedBaseTextField.suffixIcon]) side.
  trailing,
}

/// Order of custom adornments vs step buttons on the leading edge.
enum UnifiedNumericLeadingAdornmentOrder {
  /// `prefixIcon` / `prefix`, then step buttons (default).
  adornmentsThenSteps,

  /// Step buttons, then `prefixIcon` / `prefix`.
  stepsThenAdornments,
}

/// Order of custom adornments vs step buttons on the trailing edge.
enum UnifiedNumericTrailingAdornmentOrder {
  /// Step buttons, then `suffixIcon` (default).
  stepsThenAdornments,

  /// `suffixIcon`, then step buttons.
  adornmentsThenSteps,
}
