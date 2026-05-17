import 'package:flutter/material.dart';

import 'fields/unified_input_palette.dart';
import 'fields/unified_input_theme.dart';

/// Visual styling for [UnifiedFieldsDateWheelPickerSheet] scroll wheels.
///
/// Color fields are optional; omitted values are filled by [resolve]. Pass only
/// the slots you want to override, e.g. `UnifiedFieldsDateWheelStyle(selectionFill: Colors.blue)`.
@immutable
class UnifiedFieldsDateWheelStyle {
  /// Creates wheel chrome. Omit colors to use [resolve] defaults.
  const UnifiedFieldsDateWheelStyle({
    this.wheelBackground,
    this.dayColumnBackground,
    this.selectionFill,
    this.selectionBorder,
    this.columnDivider,
    this.headerDivider,
    this.fadeColor,
    this.headerTextColor,
    this.itemTextColor,
    this.magnification,
    this.squeeze,
    this.diameterRatio,
    this.itemExtent,
    this.wheelHeight,
    this.cornerRadius,
    this.selectionRadius,
    this.wheelDayNumberWidth,
    this.wheelWeekdayWidth,
  });

  /// Background of the full wheel panel.
  final Color? wheelBackground;

  /// Optional tint behind the day column only; null means same as other columns.
  final Color? dayColumnBackground;

  /// Fill behind the centered selection row.
  final Color? selectionFill;

  /// Top / bottom lines framing the selection row.
  final Color? selectionBorder;

  /// Vertical separators between year / month / day columns.
  final Color? columnDivider;

  /// Line under column header labels.
  final Color? headerDivider;

  /// Base color for top / bottom fade gradients.
  final Color? fadeColor;

  /// Column header label color.
  final Color? headerTextColor;

  /// Wheel item label color.
  final Color? itemTextColor;

  /// CupertinoPicker magnification for the centered row.
  final double? magnification;

  /// CupertinoPicker squeeze factor.
  final double? squeeze;

  /// CupertinoPicker cylinder diameter.
  final double? diameterRatio;

  /// Height of each wheel row.
  final double? itemExtent;

  /// Total height of the wheel area.
  final double? wheelHeight;

  /// Outer panel corner radius.
  final double? cornerRadius;

  /// Selection highlight corner radius.
  final double? selectionRadius;

  /// Fixed width for the day-of-month numeral in the day wheel column.
  final double? wheelDayNumberWidth;

  /// Fixed width for the weekday name beside the day numeral.
  final double? wheelWeekdayWidth;

  static const double _kMagnification = 1.18;
  static const double _kSqueeze = 1.02;
  static const double _kDiameterRatio = 1.35;
  static const double _kItemExtent = 42;
  static const double _kWheelHeight = 252;
  static const double _kCornerRadius = 12;
  static const double _kSelectionRadius = 8;
  static const double _kWheelDayNumberWidth = 28;
  static const double _kWheelWeekdayWidth = 88;

  /// Theme defaults (no separate day-column tint unless you set [dayColumnBackground]).
  factory UnifiedFieldsDateWheelStyle.resolve(
    UnifiedInputPalette palette,
    ThemeData theme, {
    Color? sheetBackground,
  }) {
    final primary = theme.colorScheme.primary;
    final sheetBg =
        sheetBackground ??
        theme.bottomSheetTheme.backgroundColor ??
        palette.sheetBackground;
    final isDark = theme.brightness == Brightness.dark;

    return UnifiedFieldsDateWheelStyle(
      wheelBackground: Color.alphaBlend(
        palette.sheetHeaderBackground.withValues(alpha: isDark ? 0.35 : 0.85),
        sheetBg,
      ),
      selectionFill: primary.withValues(alpha: isDark ? 0.18 : 0.10),
      selectionBorder: primary.withValues(alpha: isDark ? 0.55 : 0.38),
      columnDivider: palette.fieldTextColor.withValues(alpha: 0.14),
      headerDivider: palette.fieldTextColor.withValues(alpha: 0.10),
      fadeColor: sheetBg,
      headerTextColor: palette.hintColor,
      itemTextColor: palette.fieldTextColor,
      magnification: _kMagnification,
      squeeze: _kSqueeze,
      diameterRatio: _kDiameterRatio,
      itemExtent: _kItemExtent,
      wheelHeight: _kWheelHeight,
      cornerRadius: _kCornerRadius,
      selectionRadius: _kSelectionRadius,
      wheelDayNumberWidth: _kWheelDayNumberWidth,
      wheelWeekdayWidth: _kWheelWeekdayWidth,
    );
  }

  /// Merges [overrides] onto this style (typically [resolve] + custom [wheelStyle]).
  UnifiedFieldsDateWheelStyle merge(UnifiedFieldsDateWheelStyle? overrides) {
    if (overrides == null) return this;
    return UnifiedFieldsDateWheelStyle(
      wheelBackground: overrides.wheelBackground ?? wheelBackground,
      dayColumnBackground: overrides.dayColumnBackground ?? dayColumnBackground,
      selectionFill: overrides.selectionFill ?? selectionFill,
      selectionBorder: overrides.selectionBorder ?? selectionBorder,
      columnDivider: overrides.columnDivider ?? columnDivider,
      headerDivider: overrides.headerDivider ?? headerDivider,
      fadeColor: overrides.fadeColor ?? fadeColor,
      headerTextColor: overrides.headerTextColor ?? headerTextColor,
      itemTextColor: overrides.itemTextColor ?? itemTextColor,
      magnification: overrides.magnification ?? magnification,
      squeeze: overrides.squeeze ?? squeeze,
      diameterRatio: overrides.diameterRatio ?? diameterRatio,
      itemExtent: overrides.itemExtent ?? itemExtent,
      wheelHeight: overrides.wheelHeight ?? wheelHeight,
      cornerRadius: overrides.cornerRadius ?? cornerRadius,
      selectionRadius: overrides.selectionRadius ?? selectionRadius,
      wheelDayNumberWidth: overrides.wheelDayNumberWidth ?? wheelDayNumberWidth,
      wheelWeekdayWidth: overrides.wheelWeekdayWidth ?? wheelWeekdayWidth,
    );
  }

  /// [resolve] merged with optional [overrides], with all metrics filled in.
  static UnifiedFieldsDateWheelStyle forPicker(
    UnifiedInputPalette palette,
    ThemeData theme, {
    UnifiedFieldsDateWheelStyle? overrides,
    BuildContext? context,
  }) {
    final sheetBg = context != null
        ? UnifiedInputThemeResolver.resolvePickerSheetBackground(
            context,
            palette: palette,
          )
        : null;
    final merged = UnifiedFieldsDateWheelStyle.resolve(
      palette,
      theme,
      sheetBackground: sheetBg,
    ).merge(overrides);
    return UnifiedFieldsDateWheelStyle(
      wheelBackground: merged.wheelBackground!,
      dayColumnBackground: merged.dayColumnBackground,
      selectionFill: merged.selectionFill!,
      selectionBorder: merged.selectionBorder!,
      columnDivider: merged.columnDivider!,
      headerDivider: merged.headerDivider!,
      fadeColor: merged.fadeColor!,
      headerTextColor: merged.headerTextColor!,
      itemTextColor: merged.itemTextColor!,
      magnification: merged.magnification ?? _kMagnification,
      squeeze: merged.squeeze ?? _kSqueeze,
      diameterRatio: merged.diameterRatio ?? _kDiameterRatio,
      itemExtent: merged.itemExtent ?? _kItemExtent,
      wheelHeight: merged.wheelHeight ?? _kWheelHeight,
      cornerRadius: merged.cornerRadius ?? _kCornerRadius,
      selectionRadius: merged.selectionRadius ?? _kSelectionRadius,
      wheelDayNumberWidth: merged.wheelDayNumberWidth ?? _kWheelDayNumberWidth,
      wheelWeekdayWidth: merged.wheelWeekdayWidth ?? _kWheelWeekdayWidth,
    );
  }
}
