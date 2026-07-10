import 'package:flutter/material.dart';

/// Prefix / suffix adornment chrome for unified fields.
///
/// Set globally on [UnifiedInputThemeData.adornmentStyle] or per subtree via
/// [UnifiedInputFieldDefaults], then override one field with [UnifiedInputDecoration].
@immutable
class UnifiedInputAdornmentStyle {
  /// Creates adornment overrides (all fields optional).
  const UnifiedInputAdornmentStyle({
    this.prefixIconColor,
    this.suffixIconColor,
    this.prefixPadding,
    this.suffixPadding,
    this.prefixWidth,
    this.prefixHeight,
    this.suffixWidth,
    this.suffixHeight,
    this.iconSize,
    this.gap,
  });

  /// Tint for leading [Icon] adornments when they omit an explicit color.
  final Color? prefixIconColor;

  /// Tint for trailing [Icon] adornments when they omit an explicit color.
  final Color? suffixIconColor;

  /// Padding around the composed leading adornment row.
  final EdgeInsetsGeometry? prefixPadding;

  /// Padding around the composed trailing adornment row.
  final EdgeInsetsGeometry? suffixPadding;

  /// Default slot width for leading icon adornments.
  final double? prefixWidth;

  /// Default slot height for leading icon adornments.
  final double? prefixHeight;

  /// Default slot width for trailing adornments.
  final double? suffixWidth;

  /// Default slot height for trailing adornments.
  final double? suffixHeight;

  /// Glyph size for normalized icon adornments.
  final double? iconSize;

  /// Horizontal gap between multiple adornments on the same side.
  final double? gap;

  /// Merges [other] on top of this; non-null fields from [other] win.
  UnifiedInputAdornmentStyle merge(UnifiedInputAdornmentStyle? other) {
    if (other == null) return this;
    return UnifiedInputAdornmentStyle(
      prefixIconColor: other.prefixIconColor ?? prefixIconColor,
      suffixIconColor: other.suffixIconColor ?? suffixIconColor,
      prefixPadding: other.prefixPadding ?? prefixPadding,
      suffixPadding: other.suffixPadding ?? suffixPadding,
      prefixWidth: other.prefixWidth ?? prefixWidth,
      prefixHeight: other.prefixHeight ?? prefixHeight,
      suffixWidth: other.suffixWidth ?? suffixWidth,
      suffixHeight: other.suffixHeight ?? suffixHeight,
      iconSize: other.iconSize ?? iconSize,
      gap: other.gap ?? gap,
    );
  }
}
