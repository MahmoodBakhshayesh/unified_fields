import 'package:flutter/material.dart';

/// Visual styling for +/- step buttons on [UnifiedNumericStepField].
@immutable
class UnifiedNumericStepButtonStyle {
  /// Creates step-button chrome overrides (all fields optional).
  const UnifiedNumericStepButtonStyle({
    this.iconColor,
    this.disabledIconColor,
    this.iconSize,
    this.buttonWidth,
    this.buttonHeight,
    this.spacing,
    this.backgroundColor,
    this.borderRadius,
  });

  /// Icon color when the field is editable.
  final Color? iconColor;

  /// Icon color when the field is disabled, locked, or read-only.
  final Color? disabledIconColor;

  /// Glyph size inside each step button.
  final double? iconSize;

  /// Width of each step button hit target.
  final double? buttonWidth;

  /// Height of each step button hit target.
  final double? buttonHeight;

  /// Horizontal gap between adjacent step buttons.
  final double? spacing;

  /// Optional background behind each step button.
  final Color? backgroundColor;

  /// Optional background corner radius.
  final BorderRadius? borderRadius;

  /// Merges [other] on top of this; non-null fields from [other] win.
  UnifiedNumericStepButtonStyle merge(UnifiedNumericStepButtonStyle? other) {
    if (other == null) return this;
    return UnifiedNumericStepButtonStyle(
      iconColor: other.iconColor ?? iconColor,
      disabledIconColor: other.disabledIconColor ?? disabledIconColor,
      iconSize: other.iconSize ?? iconSize,
      buttonWidth: other.buttonWidth ?? buttonWidth,
      buttonHeight: other.buttonHeight ?? buttonHeight,
      spacing: other.spacing ?? spacing,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      borderRadius: other.borderRadius ?? borderRadius,
    );
  }
}
