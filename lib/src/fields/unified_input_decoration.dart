import 'package:flutter/material.dart';

import 'unified_input_brightness.dart';
import 'unified_input_palette.dart';
import 'unified_input_theme.dart';

/// Shared visual + validation metadata for unified inputs.
///
/// Widget-specific parameters stay on each field; this carries the cross-cutting chrome.
@immutable
class UnifiedInputDecoration {
  final String? label;
  final String? placeholder;
  final TextStyle? labelStyle;
  final TextStyle? fieldStyle;
  final Color? backgroundColor;
  final Color? headerBackgroundColor;
  final BorderRadius? borderRadius;
  final BorderSide? borderSide;
  final double? height;
  final List<int> rowLabelRatio;
  final bool labelInRow;

  final bool requiredField;
  final bool showError;
  final Color? validationColor;
  final IconData? validationIcon;

  final Widget? prefix;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  final EdgeInsetsGeometry? contentPadding;

  const UnifiedInputDecoration({
    this.label,
    this.placeholder,
    this.labelStyle,
    this.fieldStyle,
    this.backgroundColor,
    this.headerBackgroundColor,
    this.borderRadius,
    this.borderSide,
    this.height = 56,
    this.rowLabelRatio = const [12, 33],
    this.labelInRow = false,
    this.requiredField = false,
    this.showError = true,
    this.validationColor,
    this.validationIcon,
    this.prefix,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
  });

  UnifiedInputDecoration merge(UnifiedInputDecoration? other) {
    if (other == null) return this;
    return UnifiedInputDecoration(
      label: other.label ?? label,
      placeholder: other.placeholder ?? placeholder,
      labelStyle: other.labelStyle ?? labelStyle,
      fieldStyle: other.fieldStyle ?? fieldStyle,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      headerBackgroundColor: other.headerBackgroundColor ?? headerBackgroundColor,
      borderRadius: other.borderRadius ?? borderRadius,
      borderSide: other.borderSide ?? borderSide,
      height: other.height ?? height,
      rowLabelRatio: other.rowLabelRatio,
      labelInRow: other.labelInRow,
      requiredField: other.requiredField,
      showError: other.showError,
      validationColor: other.validationColor ?? validationColor,
      validationIcon: other.validationIcon ?? validationIcon,
      prefix: other.prefix ?? prefix,
      prefixIcon: other.prefixIcon ?? prefixIcon,
      suffixIcon: other.suffixIcon ?? suffixIcon,
      contentPadding: other.contentPadding ?? contentPadding,
    );
  }

  /// Applies palette defaults for unspecified colors/radius/border.
  UnifiedInputDecoration applyPalette(UnifiedInputPalette palette) {
    return UnifiedInputDecoration(
      label: label,
      placeholder: placeholder,
      labelStyle: labelStyle ??
          TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: palette.labelColor,
          ),
      fieldStyle: fieldStyle ?? TextStyle(color: palette.fieldTextColor),
      backgroundColor: backgroundColor ?? palette.bodyBackground,
      headerBackgroundColor: headerBackgroundColor ?? palette.headerBackground,
      borderRadius: borderRadius ?? palette.borderRadius,
      borderSide: borderSide ?? palette.defaultBorderSide,
      height: height,
      rowLabelRatio: rowLabelRatio,
      labelInRow: labelInRow,
      requiredField: requiredField,
      showError: showError,
      validationColor: validationColor ?? palette.validationColor,
      validationIcon: validationIcon,
      prefix: prefix,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: contentPadding,
    );
  }
}

/// Merged [overrides] with defaults, then palette colors from context ([Theme] + [UnifiedInputThemeScope]) or [brightness].
UnifiedInputDecoration resolveUnifiedDecoration(
  BuildContext context, {
  UnifiedInputDecoration? overrides,
  UnifiedInputBrightness? brightness,
}) {
  final palette = brightness != null ? UnifiedInputThemeResolver.paletteFor(brightness) : UnifiedInputThemeResolver.resolvePalette(context);
  return const UnifiedInputDecoration().merge(overrides).applyPalette(palette);
}
