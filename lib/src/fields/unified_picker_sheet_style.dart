import 'package:flutter/material.dart';

/// Chrome for single / multi picker sheet title bars.
@immutable
class UnifiedInputPickerHeaderStyle {
  /// Creates optional picker header overrides.
  const UnifiedInputPickerHeaderStyle({
    this.padding,
    this.backgroundColor,
    this.titleStyle,
    this.clearButtonColor,
  });

  /// Padding around the title row (Clear + close).
  final EdgeInsets? padding;

  /// Header bar background; defaults to palette `sheetHeaderBackground`.
  final Color? backgroundColor;

  /// Title text style.
  final TextStyle? titleStyle;

  /// Clear action color on [UnifiedSheetButton].
  final Color? clearButtonColor;
}

/// Checkbox appearance in [MultiPickerSheetWidget] rows.
@immutable
class UnifiedInputMultiPickerCheckboxStyle {
  /// Creates optional multi-picker checkbox overrides.
  const UnifiedInputMultiPickerCheckboxStyle({
    this.size,
    this.borderRadius,
    this.fillColor,
    this.checkColor,
    this.borderColor,
  });

  /// Width and height of the checkbox box.
  final double? size;

  /// Corner radius of the checkbox shape.
  final double? borderRadius;

  /// Fill when selected; defaults to [ThemeData.colorScheme.primary].
  final Color? fillColor;

  /// Check mark color; defaults to [ThemeData.colorScheme.onPrimary].
  final Color? checkColor;

  /// Border when unselected; defaults to palette border.
  final Color? borderColor;
}
