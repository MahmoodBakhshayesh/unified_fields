import 'package:flutter/material.dart';

import '../fields/unified_input_palette.dart';

/// How an invalid dial prefix is shown on [UnifiedPhoneField].
enum UnifiedInvalidDialCodeDisplay {
  /// Inline / decorator error message (default).
  message,

  /// Tint only the dial-code text red (no extra message).
  highlightText,
}

/// Phone-field chrome: dial-code box, flag sizing, invalid-code display.
@immutable
class UnifiedInputPhoneStyle {
  /// Creates phone-field style overrides (all optional).
  const UnifiedInputPhoneStyle({
    this.dialCodeBackgroundColor,
    this.dialCodePadding,
    this.dialCodeBorderRadius,
    this.dialCodeBorderSide,
    this.dialCodeMinWidth,
    this.flagWidth,
    this.flagHeight,
    this.flagSize,
    this.flagBorderRadius,
    this.invalidDialCodeDisplay,
    this.invalidDialCodeTextColor,
  });

  /// Background of the dial-code segment (editable or fixed).
  final Color? dialCodeBackgroundColor;

  /// Padding inside the dial-code box.
  final EdgeInsetsGeometry? dialCodePadding;

  /// Corner radius of the dial-code box.
  final BorderRadius? dialCodeBorderRadius;

  /// Optional border around the dial-code box.
  final BorderSide? dialCodeBorderSide;

  /// Minimum width of the editable dial-code field.
  final double? dialCodeMinWidth;

  /// Flag width when [flagSize] is null.
  final double? flagWidth;

  /// Flag height when [flagSize] is null.
  final double? flagHeight;

  /// Sets both flag width and height (height = size × 0.75 when [flagHeight] is null).
  final double? flagSize;

  /// Clip radius for [UnifiedFlag].
  final BorderRadius? flagBorderRadius;

  /// Invalid `+` prefix feedback mode.
  final UnifiedInvalidDialCodeDisplay? invalidDialCodeDisplay;

  /// Dial-code text color when invalid and [invalidDialCodeDisplay] is [UnifiedInvalidDialCodeDisplay.highlightText].
  final Color? invalidDialCodeTextColor;

  /// Merges [other] on top of this.
  UnifiedInputPhoneStyle merge(UnifiedInputPhoneStyle? other) {
    if (other == null) return this;
    return UnifiedInputPhoneStyle(
      dialCodeBackgroundColor:
          other.dialCodeBackgroundColor ?? dialCodeBackgroundColor,
      dialCodePadding: other.dialCodePadding ?? dialCodePadding,
      dialCodeBorderRadius: other.dialCodeBorderRadius ?? dialCodeBorderRadius,
      dialCodeBorderSide: other.dialCodeBorderSide ?? dialCodeBorderSide,
      dialCodeMinWidth: other.dialCodeMinWidth ?? dialCodeMinWidth,
      flagWidth: other.flagWidth ?? flagWidth,
      flagHeight: other.flagHeight ?? flagHeight,
      flagSize: other.flagSize ?? flagSize,
      flagBorderRadius: other.flagBorderRadius ?? flagBorderRadius,
      invalidDialCodeDisplay:
          other.invalidDialCodeDisplay ?? invalidDialCodeDisplay,
      invalidDialCodeTextColor:
          other.invalidDialCodeTextColor ?? invalidDialCodeTextColor,
    );
  }

  /// Fills unset slots from [palette] and package defaults.
  UnifiedInputPhoneStyle applyDefaults(UnifiedInputPalette palette) {
    final fw = flagSize ?? flagWidth ?? 24.0;
    final fh = flagSize != null
        ? (flagHeight ?? flagSize! * 0.75)
        : (flagHeight ?? 18.0);
    return UnifiedInputPhoneStyle(
      dialCodeBackgroundColor: dialCodeBackgroundColor,
      dialCodePadding: dialCodePadding,
      dialCodeBorderRadius: dialCodeBorderRadius,
      dialCodeBorderSide: dialCodeBorderSide,
      dialCodeMinWidth: dialCodeMinWidth ?? 72,
      flagWidth: fw,
      flagHeight: fh,
      flagSize: flagSize,
      flagBorderRadius: flagBorderRadius ??
          const BorderRadius.all(Radius.circular(3)),
      invalidDialCodeDisplay: invalidDialCodeDisplay ??
          UnifiedInvalidDialCodeDisplay.message,
      invalidDialCodeTextColor:
          invalidDialCodeTextColor ?? palette.validationColor,
    );
  }
}
