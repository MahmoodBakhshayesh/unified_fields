import 'package:flutter/material.dart';

import 'unified_field_label_mode.dart';
import 'unified_input_field_defaults.dart';

/// Label [TextStyle] and [padding] for one [UnifiedFieldLabelMode].
@immutable
class UnifiedInputLabelModeStyle {
  /// Creates label chrome for a single label layout mode.
  const UnifiedInputLabelModeStyle({
    this.labelStyle,
    this.labelPadding,
  });

  /// Label text style for this layout mode.
  final TextStyle? labelStyle;

  /// Padding around the label widget for this layout mode.
  final EdgeInsetsGeometry? labelPadding;

  /// Merges [other] on top of this; non-null fields from [other] win.
  UnifiedInputLabelModeStyle merge(UnifiedInputLabelModeStyle? other) {
    if (other == null) return this;
    return UnifiedInputLabelModeStyle(
      labelStyle: other.labelStyle ?? labelStyle,
      labelPadding: other.labelPadding ?? labelPadding,
    );
  }

  /// Reads the matching style bucket from [fieldDefaults], if any.
  static UnifiedInputLabelModeStyle? forMode(
    UnifiedInputFieldDefaults? fieldDefaults,
    UnifiedFieldLabelMode mode,
  ) {
    if (fieldDefaults == null) return null;
    return switch (mode) {
      UnifiedFieldLabelMode.labelInRow => fieldDefaults.labelInRowStyle,
      UnifiedFieldLabelMode.labelInColumn => fieldDefaults.labelInColumnStyle,
      UnifiedFieldLabelMode.floatingLabel => fieldDefaults.floatingLabelStyle,
    };
  }

  /// Built-in label padding when nothing is set on decoration, widget, or theme.
  static EdgeInsetsGeometry defaultLabelPadding(UnifiedFieldLabelMode mode) {
    return switch (mode) {
      UnifiedFieldLabelMode.labelInRow =>
        const EdgeInsets.symmetric(horizontal: 8),
      UnifiedFieldLabelMode.labelInColumn =>
        const EdgeInsets.only(bottom: 4, top: 8),
      UnifiedFieldLabelMode.floatingLabel => EdgeInsets.zero,
    };
  }

  /// Resolves padding: decoration → widget → [fieldDefaults] for [mode] → built-in.
  static EdgeInsetsGeometry resolveLabelPadding({
    required UnifiedFieldLabelMode mode,
    EdgeInsetsGeometry? decorationPadding,
    EdgeInsetsGeometry? widgetPadding,
    UnifiedInputFieldDefaults? fieldDefaults,
  }) {
    return decorationPadding ??
        widgetPadding ??
        forMode(fieldDefaults, mode)?.labelPadding ??
        defaultLabelPadding(mode);
  }

  /// Resolves style before palette/disabled color is applied.
  static TextStyle? resolveLabelStyle({
    required UnifiedFieldLabelMode mode,
    TextStyle? decorationStyle,
    TextStyle? widgetStyle,
    UnifiedInputFieldDefaults? fieldDefaults,
  }) {
    return decorationStyle ??
        widgetStyle ??
        forMode(fieldDefaults, mode)?.labelStyle;
  }
}
