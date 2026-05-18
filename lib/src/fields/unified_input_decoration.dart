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

/// Visual state used to pick a layer from [UnifiedInputDecorationSet].
enum UnifiedInputFieldVisualState {
  /// Default enabled appearance (no focus, no error).
  base,

  /// Field has focus and is editable.
  focused,

  /// Validation succeeded (no error, validator has run).
  valid,

  /// Field has a non-empty error message.
  error,

  /// [UnifiedBaseTextField.locked] is true.
  locked,

  /// [UnifiedBaseTextField.disabled] or [UnifiedBaseTextField.isDisabled].
  disabled,

  /// [UnifiedBaseTextField.loading] is true.
  loading,

  /// [UnifiedBaseTextField.readOnly] without disabled/locked.
  readOnly,
}

/// Per-state [UnifiedInputDecoration] overrides, similar to Material [InputDecoration] focus/error borders.
///
/// Each layer is optional; unspecified properties fall back to [base] (then palette defaults).
/// Pass on a field via [decorationSet], or globally on [UnifiedInputThemeData.fieldDecorationSet].
@immutable
class UnifiedInputDecorationSet {
  /// Creates a set of optional per-state decorations.
  const UnifiedInputDecorationSet({
    this.base,
    this.focused,
    this.valid,
    this.error,
    this.locked,
    this.disabled,
    this.loading,
    this.readOnly,
  });

  /// Default / enabled decoration (merged with legacy single [UnifiedInputDecoration] on fields).
  final UnifiedInputDecoration? base;

  /// When the field has focus (and is editable).
  final UnifiedInputDecoration? focused;

  /// When validation passed and there is no error (only applied if this layer is non-null).
  final UnifiedInputDecoration? valid;

  /// When the field shows an error message.
  final UnifiedInputDecoration? error;

  /// When [UnifiedBaseTextField.locked] is true.
  final UnifiedInputDecoration? locked;

  /// When the field is disabled.
  final UnifiedInputDecoration? disabled;

  /// When [UnifiedBaseTextField.loading] is true.
  final UnifiedInputDecoration? loading;

  /// When the field is read-only (and not disabled/locked).
  final UnifiedInputDecoration? readOnly;

  /// Merges [other] on top of this; non-null layers from [other] replace this set's layers.
  UnifiedInputDecorationSet merge(UnifiedInputDecorationSet? other) {
    if (other == null) return this;
    return UnifiedInputDecorationSet(
      base: other.base ?? base,
      focused: other.focused ?? focused,
      valid: other.valid ?? valid,
      error: other.error ?? error,
      locked: other.locked ?? locked,
      disabled: other.disabled ?? disabled,
      loading: other.loading ?? loading,
      readOnly: other.readOnly ?? readOnly,
    );
  }

  /// Decoration layer for [state] (may be null).
  UnifiedInputDecoration? layerFor(UnifiedInputFieldVisualState state) {
    switch (state) {
      case UnifiedInputFieldVisualState.base:
        return base;
      case UnifiedInputFieldVisualState.focused:
        return focused;
      case UnifiedInputFieldVisualState.valid:
        return valid;
      case UnifiedInputFieldVisualState.error:
        return error;
      case UnifiedInputFieldVisualState.locked:
        return locked;
      case UnifiedInputFieldVisualState.disabled:
        return disabled;
      case UnifiedInputFieldVisualState.loading:
        return loading;
      case UnifiedInputFieldVisualState.readOnly:
        return readOnly;
    }
  }

  /// Whether [state] has an explicit decoration layer.
  bool hasLayerFor(UnifiedInputFieldVisualState state) => layerFor(state) != null;

  /// True when any layer (including [base]) is set.
  bool get isConfigured =>
      base != null ||
      focused != null ||
      valid != null ||
      error != null ||
      locked != null ||
      disabled != null ||
      loading != null ||
      readOnly != null;

  /// Resolves the active decoration for [state] (palette applied).
  UnifiedInputDecoration resolve(
    BuildContext context, {
    required UnifiedInputFieldVisualState state,
    UnifiedInputBrightness? brightness,
    UnifiedInputDecoration? fieldDecoration,
  }) {
    final palette = brightness != null
        ? UnifiedInputThemeResolver.paletteFor(brightness)
        : UnifiedInputThemeResolver.resolvePalette(context);
    var merged = const UnifiedInputDecoration()
        .merge(base)
        .merge(fieldDecoration);
    final overlay = layerFor(state);
    if (overlay != null) {
      merged = merged.merge(overlay);
    }
    return merged.applyPalette(palette);
  }
}

/// Picks the highest-priority visual state for a field.
UnifiedInputFieldVisualState resolveUnifiedInputFieldVisualState({
  required bool disabled,
  required bool locked,
  required bool loading,
  required bool hasError,
  required bool showValid,
  required bool readOnly,
  required bool focused,
}) {
  if (disabled) return UnifiedInputFieldVisualState.disabled;
  if (locked) return UnifiedInputFieldVisualState.locked;
  if (loading) return UnifiedInputFieldVisualState.loading;
  if (hasError) return UnifiedInputFieldVisualState.error;
  if (showValid) return UnifiedInputFieldVisualState.valid;
  if (readOnly) return UnifiedInputFieldVisualState.readOnly;
  if (focused) return UnifiedInputFieldVisualState.focused;
  return UnifiedInputFieldVisualState.base;
}

/// Theme scope + field [decoration] / [decorationSet] composed for [UnifiedBaseTextField].
UnifiedInputDecorationSet composeFieldDecorationSet(
  BuildContext context, {
  UnifiedInputDecoration? decoration,
  UnifiedInputDecorationSet? decorationSet,
}) {
  final themeSet =
      UnifiedInputThemeScope.themeDataOf(context).fieldDecorationSet;
  return const UnifiedInputDecorationSet()
      .merge(themeSet)
      .merge(UnifiedInputDecorationSet(base: decoration))
      .merge(decorationSet);
}
