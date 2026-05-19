import 'package:flutter/material.dart';

import 'fields/unified_input_palette.dart';
import 'unified_date_picker_types.dart';
import 'unified_date_wheel_style.dart';
import 'unified_date_year_strip_style.dart';

/// Visual styling for [showUnifiedFieldsDatePicker] calendar sheets and related UI.
///
/// Set on [UnifiedInputThemeData.datePickerStyle] or pass per [UnifiedDateField]
/// via [datePickerStyle]. Omit any slot to use palette / [ThemeData] defaults from
/// [resolve].
///
/// Wheel columns use [wheelStyle]; when null, wheels use [UnifiedFieldsDateWheelStyle.forPicker].
@immutable
class UnifiedInputDatePickerStyle {
  /// Creates date-picker chrome overrides (all optional).
  const UnifiedInputDatePickerStyle({
    this.sheetBackgroundColor,
    this.dialogBorderRadius,
    this.titleStyle,
    this.closeIconColor,
    this.rangeHintStyle,
    this.calendarToggleSelectedBackground,
    this.calendarToggleSelectedForeground,
    this.calendarToggleBackground,
    this.calendarToggleForeground,
    this.monthNavIconColor,
    this.monthTitleStyle,
    this.weekdayTextStyle,
    this.dayFontSize,
    this.dayFontWeight,
    this.dayFontWeightSelected,
    this.dayTextColor,
    this.dayDisabledTextColor,
    this.daySelectedBackgroundColor,
    this.daySelectedTextColor,
    this.dayTodayBorderColor,
    this.dayTodayTextColor,
    this.dayRangeMiddleBackgroundColor,
    this.dayCircleSize,
    this.cellHeight,
    this.monthJumpSelectedBackground,
    this.monthJumpSelectedBorderColor,
    this.monthJumpSelectedTextColor,
    this.monthJumpBackground,
    this.monthJumpBorderColor,
    this.monthJumpTextColor,
    this.monthJumpDisabledOpacity,
    this.monthJumpFontSize,
    this.yearListSelectedBackground,
    this.yearListSelectedTextColor,
    this.yearListTextColor,
    this.yearListCheckmarkColor,
    this.cancelButtonTextStyle,
    this.confirmButtonBackground,
    this.confirmButtonForeground,
    this.confirmButtonTextStyle,
    this.shamsiTextStyle,
    this.wheelStyle,
    this.yearStripStyle,
  });

  /// Sheet / dialog surface behind the picker.
  final Color? sheetBackgroundColor;

  /// Corner radius when shown as a centered dialog (desktop layout).
  final double? dialogBorderRadius;

  /// Title row text (field label / sheet title).
  final TextStyle? titleStyle;

  /// Close icon on the title row.
  final Color? closeIconColor;

  /// Hint under the title in range-pick mode.
  final TextStyle? rangeHintStyle;

  /// Gregorian / Shamsi toggle — selected segment background.
  final Color? calendarToggleSelectedBackground;

  /// Gregorian / Shamsi toggle — selected segment label color.
  final Color? calendarToggleSelectedForeground;

  /// Gregorian / Shamsi toggle — unselected segment background.
  final Color? calendarToggleBackground;

  /// Gregorian / Shamsi toggle — unselected segment label color.
  final Color? calendarToggleForeground;

  /// Month navigation chevrons and dropdown affordance.
  final Color? monthNavIconColor;

  /// Center month/year label in the day calendar header.
  final TextStyle? monthTitleStyle;

  /// Narrow weekday names row (Mon, Tue, …).
  final TextStyle? weekdayTextStyle;

  /// Day numeral font size in the month grid.
  final double? dayFontSize;

  /// Font weight for normal (non-endpoint) days.
  final FontWeight? dayFontWeight;

  /// Font weight for selected range endpoints / selected day.
  final FontWeight? dayFontWeightSelected;

  /// Default day label color.
  final Color? dayTextColor;

  /// Out-of-range / disabled day label color.
  final Color? dayDisabledTextColor;

  /// Filled circle behind a selected day or range endpoint.
  final Color? daySelectedBackgroundColor;

  /// Text on [daySelectedBackgroundColor].
  final Color? daySelectedTextColor;

  /// Border around “today” when not selected.
  final Color? dayTodayBorderColor;

  /// “Today” label when not selected (falls back to [dayTextColor]).
  final Color? dayTodayTextColor;

  /// Background for days between range endpoints.
  final Color? dayRangeMiddleBackgroundColor;

  /// Diameter of the circular day indicator (selected / today).
  final double? dayCircleSize;

  /// Height of each day row in the month grid.
  final double? cellHeight;

  /// Month jump grid — selected cell fill.
  final Color? monthJumpSelectedBackground;

  /// Month jump grid — selected cell border.
  final Color? monthJumpSelectedBorderColor;

  /// Month jump grid — selected label color.
  final Color? monthJumpSelectedTextColor;

  /// Month jump grid — unselected cell fill.
  final Color? monthJumpBackground;

  /// Month jump grid — unselected cell border.
  final Color? monthJumpBorderColor;

  /// Month jump grid — unselected label color.
  final Color? monthJumpTextColor;

  /// Opacity applied to disabled month jump cells.
  final double? monthJumpDisabledOpacity;

  /// Month jump cell label font size.
  final double? monthJumpFontSize;

  /// Year list — selected row background (month/year granularity).
  final Color? yearListSelectedBackground;

  /// Year list — selected row text / check color.
  final Color? yearListSelectedTextColor;

  /// Year list — unselected row text color.
  final Color? yearListTextColor;

  /// Year list — trailing check icon when selected.
  final Color? yearListCheckmarkColor;

  /// Cancel text button label style.
  final TextStyle? cancelButtonTextStyle;

  /// Confirm [FilledButton] background.
  final Color? confirmButtonBackground;

  /// Confirm [FilledButton] foreground (label + icon).
  final Color? confirmButtonForeground;

  /// Confirm button label style (color may be overridden by [confirmButtonForeground]).
  final TextStyle? confirmButtonTextStyle;

  /// Optional style merged into picker text when the active calendar is Shamsi (Jalali).
  ///
  /// Same idea as [UnifiedInputFieldDefaults.textStylePersian] for field text: set
  /// `fontFamily`, size, or weight for Persian month names and numerals. Applied via
  /// [calendarTextStyle] before Persian digit localization.
  final TextStyle? shamsiTextStyle;

  /// Wheel picker chrome; merged with [UnifiedFieldsDateWheelStyle.forPicker] defaults.
  final UnifiedFieldsDateWheelStyle? wheelStyle;

  /// Horizontal year strip (month/year jump + month granularity): fade, magnification, sizing.
  ///
  /// Falls back to [wheelStyle] for [UnifiedFieldsDateYearStripStyle.fadeColor] and
  /// [UnifiedFieldsDateYearStripStyle.magnification] when unset.
  final UnifiedFieldsDateYearStripStyle? yearStripStyle;

  /// Resolved year-strip chrome for [sheetBackgroundColor].
  UnifiedFieldsDateYearStripStyle resolvedYearStripStyle() =>
      UnifiedFieldsDateYearStripStyle.resolve(
        overrides: yearStripStyle,
        wheelStyle: wheelStyle,
        sheetBackground: sheetBackgroundColor,
      );

  /// Returns [style], merging [shamsiTextStyle] when [calendarKind] is [UnifiedFieldsCalendarKind.jalali].
  TextStyle calendarTextStyle(
    TextStyle style,
    UnifiedFieldsCalendarKind calendarKind,
  ) {
    if (calendarKind == UnifiedFieldsCalendarKind.jalali &&
        shamsiTextStyle != null) {
      return style.merge(shamsiTextStyle!);
    }
    return style;
  }

  static const double _kDayCircleSize = 34;
  static const double _kCellHeight = 40;
  static const double _kDialogRadius = 20;
  static const double _kDayFontSize = 14;
  static const double _kMonthJumpFontSize = 13;
  static const double _kMonthJumpDisabledOpacity = 0.38;

  /// Fills unset values from [palette] and [theme].
  UnifiedInputDatePickerStyle applyDefaults(
    UnifiedInputPalette palette,
    ThemeData theme, {
    Color? sheetBackground,
  }) {
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final sheetBg = sheetBackground ??
        theme.bottomSheetTheme.backgroundColor ??
        palette.sheetBackground;
    final isDark = theme.brightness == Brightness.dark;

    return UnifiedInputDatePickerStyle(
      sheetBackgroundColor: sheetBackgroundColor ?? sheetBg,
      dialogBorderRadius: dialogBorderRadius ?? _kDialogRadius,
      titleStyle: titleStyle ??
          TextStyle(
            fontSize: theme.textTheme.titleMedium?.fontSize ?? 16,
            fontWeight: FontWeight.w600,
            color: palette.fieldTextColor,
          ),
      closeIconColor:
          closeIconColor ?? palette.fieldTextColor.withValues(alpha: 0.85),
      rangeHintStyle: rangeHintStyle ??
          TextStyle(
            fontSize: theme.textTheme.bodySmall?.fontSize ?? 12,
            color: palette.hintColor,
          ),
      calendarToggleSelectedBackground:
          calendarToggleSelectedBackground ?? primary,
      calendarToggleSelectedForeground:
          calendarToggleSelectedForeground ?? onPrimary,
      calendarToggleBackground:
          calendarToggleBackground ?? palette.sheetHeaderBackground,
      calendarToggleForeground:
          calendarToggleForeground ?? palette.fieldTextColor,
      monthNavIconColor: monthNavIconColor ?? palette.fieldTextColor,
      monthTitleStyle: monthTitleStyle ??
          TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: palette.fieldTextColor,
          ),
      weekdayTextStyle: weekdayTextStyle ??
          TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: palette.hintColor,
          ),
      dayFontSize: dayFontSize ?? _kDayFontSize,
      dayFontWeight: dayFontWeight ?? FontWeight.w500,
      dayFontWeightSelected: dayFontWeightSelected ?? FontWeight.w700,
      dayTextColor: dayTextColor ?? palette.fieldTextColor,
      dayDisabledTextColor:
          dayDisabledTextColor ?? palette.hintColor.withValues(alpha: 0.35),
      daySelectedBackgroundColor: daySelectedBackgroundColor ?? primary,
      daySelectedTextColor: daySelectedTextColor ?? onPrimary,
      dayTodayBorderColor: dayTodayBorderColor ?? primary,
      dayTodayTextColor: dayTodayTextColor ?? palette.fieldTextColor,
      dayRangeMiddleBackgroundColor: dayRangeMiddleBackgroundColor ??
          primary.withValues(alpha: isDark ? 0.18 : 0.14),
      dayCircleSize: dayCircleSize ?? _kDayCircleSize,
      cellHeight: cellHeight ?? _kCellHeight,
      monthJumpSelectedBackground:
          monthJumpSelectedBackground ?? primary,
      monthJumpSelectedBorderColor:
          monthJumpSelectedBorderColor ?? primary,
      monthJumpSelectedTextColor:
          monthJumpSelectedTextColor ?? onPrimary,
      monthJumpBackground:
          monthJumpBackground ?? palette.sheetHeaderBackground,
      monthJumpBorderColor: monthJumpBorderColor ??
          palette.borderColor.withValues(alpha: 0.65),
      monthJumpTextColor: monthJumpTextColor ?? palette.fieldTextColor,
      monthJumpDisabledOpacity:
          monthJumpDisabledOpacity ?? _kMonthJumpDisabledOpacity,
      monthJumpFontSize: monthJumpFontSize ?? _kMonthJumpFontSize,
      yearListSelectedBackground: yearListSelectedBackground ??
          primary.withValues(alpha: isDark ? 0.18 : 0.12),
      yearListSelectedTextColor: yearListSelectedTextColor ?? primary,
      yearListTextColor: yearListTextColor ?? palette.fieldTextColor,
      yearListCheckmarkColor: yearListCheckmarkColor ?? primary,
      cancelButtonTextStyle: cancelButtonTextStyle,
      confirmButtonBackground: confirmButtonBackground ?? primary,
      confirmButtonForeground: confirmButtonForeground ?? onPrimary,
      confirmButtonTextStyle: confirmButtonTextStyle,
      shamsiTextStyle: shamsiTextStyle,
      wheelStyle: wheelStyle,
      yearStripStyle: yearStripStyle,
    );
  }

  /// Merges [other] on top of this (non-null fields from [other] win).
  UnifiedInputDatePickerStyle merge(UnifiedInputDatePickerStyle? other) {
    if (other == null) return this;
    return UnifiedInputDatePickerStyle(
      sheetBackgroundColor:
          other.sheetBackgroundColor ?? sheetBackgroundColor,
      dialogBorderRadius: other.dialogBorderRadius ?? dialogBorderRadius,
      titleStyle: other.titleStyle ?? titleStyle,
      closeIconColor: other.closeIconColor ?? closeIconColor,
      rangeHintStyle: other.rangeHintStyle ?? rangeHintStyle,
      calendarToggleSelectedBackground: other.calendarToggleSelectedBackground ??
          calendarToggleSelectedBackground,
      calendarToggleSelectedForeground: other.calendarToggleSelectedForeground ??
          calendarToggleSelectedForeground,
      calendarToggleBackground:
          other.calendarToggleBackground ?? calendarToggleBackground,
      calendarToggleForeground:
          other.calendarToggleForeground ?? calendarToggleForeground,
      monthNavIconColor: other.monthNavIconColor ?? monthNavIconColor,
      monthTitleStyle: other.monthTitleStyle ?? monthTitleStyle,
      weekdayTextStyle: other.weekdayTextStyle ?? weekdayTextStyle,
      dayFontSize: other.dayFontSize ?? dayFontSize,
      dayFontWeight: other.dayFontWeight ?? dayFontWeight,
      dayFontWeightSelected:
          other.dayFontWeightSelected ?? dayFontWeightSelected,
      dayTextColor: other.dayTextColor ?? dayTextColor,
      dayDisabledTextColor:
          other.dayDisabledTextColor ?? dayDisabledTextColor,
      daySelectedBackgroundColor: other.daySelectedBackgroundColor ??
          daySelectedBackgroundColor,
      daySelectedTextColor:
          other.daySelectedTextColor ?? daySelectedTextColor,
      dayTodayBorderColor: other.dayTodayBorderColor ?? dayTodayBorderColor,
      dayTodayTextColor: other.dayTodayTextColor ?? dayTodayTextColor,
      dayRangeMiddleBackgroundColor: other.dayRangeMiddleBackgroundColor ??
          dayRangeMiddleBackgroundColor,
      dayCircleSize: other.dayCircleSize ?? dayCircleSize,
      cellHeight: other.cellHeight ?? cellHeight,
      monthJumpSelectedBackground: other.monthJumpSelectedBackground ??
          monthJumpSelectedBackground,
      monthJumpSelectedBorderColor: other.monthJumpSelectedBorderColor ??
          monthJumpSelectedBorderColor,
      monthJumpSelectedTextColor:
          other.monthJumpSelectedTextColor ?? monthJumpSelectedTextColor,
      monthJumpBackground: other.monthJumpBackground ?? monthJumpBackground,
      monthJumpBorderColor: other.monthJumpBorderColor ?? monthJumpBorderColor,
      monthJumpTextColor: other.monthJumpTextColor ?? monthJumpTextColor,
      monthJumpDisabledOpacity:
          other.monthJumpDisabledOpacity ?? monthJumpDisabledOpacity,
      monthJumpFontSize: other.monthJumpFontSize ?? monthJumpFontSize,
      yearListSelectedBackground: other.yearListSelectedBackground ??
          yearListSelectedBackground,
      yearListSelectedTextColor:
          other.yearListSelectedTextColor ?? yearListSelectedTextColor,
      yearListTextColor: other.yearListTextColor ?? yearListTextColor,
      yearListCheckmarkColor:
          other.yearListCheckmarkColor ?? yearListCheckmarkColor,
      cancelButtonTextStyle:
          other.cancelButtonTextStyle ?? cancelButtonTextStyle,
      confirmButtonBackground:
          other.confirmButtonBackground ?? confirmButtonBackground,
      confirmButtonForeground:
          other.confirmButtonForeground ?? confirmButtonForeground,
      confirmButtonTextStyle:
          other.confirmButtonTextStyle ?? confirmButtonTextStyle,
      shamsiTextStyle: other.shamsiTextStyle ?? shamsiTextStyle,
      wheelStyle: wheelStyle?.merge(other.wheelStyle) ?? other.wheelStyle,
      yearStripStyle: yearStripStyle?.merge(other.yearStripStyle) ??
          other.yearStripStyle,
    );
  }

}
