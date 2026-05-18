import 'package:flutter/material.dart';

import 'unified_field_label_mode.dart';
import 'unified_input_brightness.dart';
import 'unified_input_palette.dart';
import 'unified_input_theme.dart';

/// Shared visual + validation metadata for unified inputs.
///
/// Widget-specific parameters stay on each field; this carries the cross-cutting chrome.
@immutable
class UnifiedInputDecoration {
  /// Default field label (overridden by a field-level `label` when both are set).
  final String? label;

  /// Default placeholder / hint (overridden by a field-level `placeholder`).
  final String? placeholder;

  /// Override for the label text style.
  final TextStyle? labelStyle;

  /// Override for the inner field text style.
  final TextStyle? fieldStyle;

  /// Field background color.
  final Color? backgroundColor;

  /// Background for the left label area when [labelInRow] is true.
  final Color? headerBackgroundColor;

  /// Border radius of the field box.
  final BorderRadius? borderRadius;

  /// Border side of the field box.
  final BorderSide? borderSide;

  /// Fixed minimum height of the inner field row.
  final double? height;

  /// Flex ratio for the label vs body when [labelInRow] is true.
  final List<int> rowLabelRatio;

  /// When true, the label is rendered on the left of the field (split row),
  /// otherwise on top. Prefer [labelMode].
  final bool labelInRow;

  /// Label placement; overrides [labelInRow] when set. Defaults to floating label.
  final UnifiedFieldLabelMode? labelMode;

  /// Default for `isRequired` (overridden by field-level `isRequired`).
  final bool requiredField;

  /// Whether to draw the inline error strip when the field has an error.
  final bool showError;

  /// Color used for error chrome (border, label) when present.
  final Color? validationColor;

  /// Optional icon shown in the inline error strip.
  final IconData? validationIcon;

  /// Leading widget shown before the field content.
  final Widget? prefix;

  /// Leading icon shown before the field content.
  final Widget? prefixIcon;

  /// Trailing widget shown after the field content.
  final Widget? suffixIcon;

  /// Inner padding of the editing area.
  final EdgeInsetsGeometry? contentPadding;

  /// Creates a decoration; all fields are optional and merged on top of the
  /// resolved palette defaults from [resolveUnifiedDecoration].
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
    this.labelMode,
    this.requiredField = false,
    this.showError = true,
    this.validationColor,
    this.validationIcon,
    this.prefix,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
  });

  /// Merges [other] on top of this; non-null fields from [other] win.
  UnifiedInputDecoration merge(UnifiedInputDecoration? other) {
    if (other == null) return this;
    return UnifiedInputDecoration(
      label: other.label ?? label,
      placeholder: other.placeholder ?? placeholder,
      labelStyle: other.labelStyle ?? labelStyle,
      fieldStyle: other.fieldStyle ?? fieldStyle,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      headerBackgroundColor:
          other.headerBackgroundColor ?? headerBackgroundColor,
      borderRadius: other.borderRadius ?? borderRadius,
      borderSide: other.borderSide ?? borderSide,
      height: other.height ?? height,
      rowLabelRatio: other.rowLabelRatio,
      labelInRow: other.labelInRow,
      labelMode: other.labelMode ?? labelMode,
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
      labelStyle:
          labelStyle ??
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
      labelMode: labelMode,
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
  final palette = brightness != null
      ? UnifiedInputThemeResolver.paletteFor(brightness)
      : UnifiedInputThemeResolver.resolvePalette(context);
  return const UnifiedInputDecoration().merge(overrides).applyPalette(palette);
}
