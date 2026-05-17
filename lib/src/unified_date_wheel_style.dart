import 'package:flutter/material.dart';

import 'fields/unified_input_palette.dart';

/// Visual styling for [UnifiedFieldsDateWheelPickerSheet] scroll wheels.
@immutable
class UnifiedFieldsDateWheelStyle {
  /// Creates wheel chrome colors and metrics.
  const UnifiedFieldsDateWheelStyle({
    required this.wheelBackground,
    required this.dayColumnBackground,
    required this.selectionFill,
    required this.selectionBorder,
    required this.columnDivider,
    required this.headerDivider,
    required this.fadeColor,
    required this.headerTextColor,
    required this.itemTextColor,
    this.magnification = 1.18,
    this.squeeze = 1.02,
    this.diameterRatio = 1.35,
    this.itemExtent = 42,
    this.wheelHeight = 252,
    this.cornerRadius = 12,
    this.selectionRadius = 8,
  });

  /// Background of the full wheel panel.
  final Color wheelBackground;

  /// Subtle tint behind the day column (matches common iOS-style pickers).
  final Color dayColumnBackground;

  /// Fill behind the centered selection row.
  final Color selectionFill;

  /// Top / bottom lines framing the selection row.
  final Color selectionBorder;

  /// Vertical separators between day / month / year columns.
  final Color columnDivider;

  /// Line under column header labels.
  final Color headerDivider;

  /// Base color for top / bottom fade gradients.
  final Color fadeColor;

  /// Column header label color.
  final Color headerTextColor;

  /// Wheel item label color.
  final Color itemTextColor;

  /// CupertinoPicker magnification for the centered row.
  final double magnification;

  /// CupertinoPicker squeeze factor.
  final double squeeze;

  /// CupertinoPicker cylinder diameter.
  final double diameterRatio;

  /// Height of each wheel row.
  final double itemExtent;

  /// Total height of the wheel area.
  final double wheelHeight;

  /// Outer panel corner radius.
  final double cornerRadius;

  /// Selection highlight corner radius.
  final double selectionRadius;

  /// Builds defaults from [palette] and [theme] (primary-tinted selection band).
  factory UnifiedFieldsDateWheelStyle.resolve(
    UnifiedInputPalette palette,
    ThemeData theme,
  ) {
    final primary = theme.colorScheme.primary;
    final sheetBg = theme.bottomSheetTheme.backgroundColor ??
        palette.sheetBackground;
    final isDark = theme.brightness == Brightness.dark;

    return UnifiedFieldsDateWheelStyle(
      wheelBackground: Color.alphaBlend(
        palette.sheetHeaderBackground.withValues(alpha: isDark ? 0.35 : 0.85),
        sheetBg,
      ),
      dayColumnBackground: Color.alphaBlend(
        palette.headerBackground.withValues(alpha: isDark ? 0.45 : 0.55),
        sheetBg,
      ),
      selectionFill: primary.withValues(alpha: isDark ? 0.18 : 0.10),
      selectionBorder: primary.withValues(alpha: isDark ? 0.55 : 0.38),
      columnDivider: palette.fieldTextColor.withValues(alpha: 0.14),
      headerDivider: palette.fieldTextColor.withValues(alpha: 0.10),
      fadeColor: sheetBg,
      headerTextColor: palette.hintColor,
      itemTextColor: palette.fieldTextColor,
    );
  }
}
