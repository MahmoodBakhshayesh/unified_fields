import 'package:flutter/material.dart';

import 'fields/unified_input_palette.dart';
import 'fields/unified_input_theme.dart';
import 'unified_input_date_picker_style.dart';

/// Styling knobs shared by [UnifiedFieldsStyledTimePicker],
/// [UnifiedFieldsStyledCalendarPicker], and their modal wrappers.
///
/// Every field is optional; unset values fall back to [ThemeData] /
/// [UnifiedInputDatePickerStyle] when resolved via
/// [UnifiedFieldsPickerTheme.resolve].
class UnifiedFieldsPickerTheme {
  const UnifiedFieldsPickerTheme({
    this.primaryColor,
    this.onPrimaryColor,
    this.sheetBackgroundColor,
    this.headlineColor,
    this.subheadColor,
    this.borderColor,
    this.accentColor,
    this.rangeBandColor,
    this.disabledColor,
    this.controlRadius,
    this.sheetRadius,
    this.confirmLabel,
    this.cancelLabel,
    this.confirmColor,
    this.confirmTextColor,
    this.cancelColor,
    this.barrierColor,
    this.railGradientColors,
  });

  final Color? primaryColor;
  final Color? onPrimaryColor;
  final Color? sheetBackgroundColor;
  final Color? headlineColor;
  final Color? subheadColor;
  final Color? borderColor;
  final Color? accentColor;
  final Color? rangeBandColor;
  final Color? disabledColor;
  final double? controlRadius;
  final double? sheetRadius;
  final String? confirmLabel;
  final String? cancelLabel;
  final Color? confirmColor;
  final Color? confirmTextColor;
  final Color? cancelColor;
  final Color? barrierColor;
  final List<Color>? railGradientColors;

  /// Resolves this theme merged with [datePickerStyle] and [ThemeData].
  static UnifiedFieldsPickerTheme resolve(
    BuildContext context, {
    UnifiedFieldsPickerTheme? overrides,
    UnifiedInputDatePickerStyle? datePickerStyle,
  }) {
    final theme = Theme.of(context);
    final palette = UnifiedInputThemeResolver.resolvePalette(context);
    final resolvedDate = UnifiedInputThemeResolver.resolveDatePickerStyle(
      context,
      overrides: datePickerStyle,
    );
    final primary = overrides?.primaryColor ??
        resolvedDate.confirmButtonBackground ??
        theme.colorScheme.primary;
    final onPrimary = overrides?.onPrimaryColor ??
        resolvedDate.confirmButtonForeground ??
        theme.colorScheme.onPrimary;
    final sheetBg = overrides?.sheetBackgroundColor ??
        resolvedDate.sheetBackgroundColor ??
        theme.bottomSheetTheme.backgroundColor ??
        palette.sheetBackground;
    final headline = overrides?.headlineColor ?? palette.fieldTextColor;
    final subhead = overrides?.subheadColor ?? palette.hintColor;
    final border = overrides?.borderColor ?? palette.borderColor;
    final isDark = theme.brightness == Brightness.dark;

    return UnifiedFieldsPickerTheme(
      primaryColor: primary,
      onPrimaryColor: onPrimary,
      sheetBackgroundColor: sheetBg,
      headlineColor: headline,
      subheadColor: subhead,
      borderColor: border,
      accentColor: overrides?.accentColor ?? Colors.orange,
      rangeBandColor: overrides?.rangeBandColor ??
          resolvedDate.dayRangeMiddleBackgroundColor ??
          primary.withValues(alpha: isDark ? 0.18 : 0.13),
      disabledColor: overrides?.disabledColor ??
          resolvedDate.dayDisabledTextColor ??
          subhead.withValues(alpha: 0.45),
      controlRadius: overrides?.controlRadius ?? 12,
      sheetRadius: overrides?.sheetRadius ?? resolvedDate.dialogBorderRadius ?? 24,
      confirmLabel: overrides?.confirmLabel,
      cancelLabel: overrides?.cancelLabel,
      confirmColor: overrides?.confirmColor ?? primary,
      confirmTextColor: overrides?.confirmTextColor ?? onPrimary,
      cancelColor: overrides?.cancelColor ?? primary,
      barrierColor: overrides?.barrierColor,
      railGradientColors: overrides?.railGradientColors,
    );
  }

  Color get primary => primaryColor ?? const Color(0xFF27756A);
  Color get onPrimary => onPrimaryColor ?? Colors.white;
  Color get background => sheetBackgroundColor ?? Colors.white;
  Color get headline => headlineColor ?? const Color(0xFF1A1A1A);
  Color get subhead => subheadColor ?? const Color(0xFF666666);
  Color get border => borderColor ?? const Color(0xFFE9E9E9);
  Color get accent => accentColor ?? Colors.orange;
  Color get rangeBand => rangeBandColor ?? primary.withValues(alpha: 0.13);
  Color get disabled => disabledColor ?? subhead.withValues(alpha: 0.45);
  double get radius => controlRadius ?? 12;
  double get modalRadius => sheetRadius ?? 24;
  Color get confirmFill => confirmColor ?? primary;
  Color get confirmText => confirmTextColor ?? onPrimary;
  Color get cancelFg => cancelColor ?? primary;
  List<Color> get railGradient =>
      railGradientColors ??
      const [
        Color(0xffb8c0f0),
        Color(0xffdfe6fb),
        Color(0xffffe9c2),
        Color(0xffdfe6fb),
        Color(0xffb8c0f0),
      ];

  UnifiedFieldsPickerTheme copyWith({
    Color? primaryColor,
    Color? onPrimaryColor,
    Color? sheetBackgroundColor,
    Color? headlineColor,
    Color? subheadColor,
    Color? borderColor,
    Color? accentColor,
    Color? rangeBandColor,
    Color? disabledColor,
    double? controlRadius,
    double? sheetRadius,
    String? confirmLabel,
    String? cancelLabel,
    Color? confirmColor,
    Color? confirmTextColor,
    Color? cancelColor,
    Color? barrierColor,
    List<Color>? railGradientColors,
  }) {
    return UnifiedFieldsPickerTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      onPrimaryColor: onPrimaryColor ?? this.onPrimaryColor,
      sheetBackgroundColor: sheetBackgroundColor ?? this.sheetBackgroundColor,
      headlineColor: headlineColor ?? this.headlineColor,
      subheadColor: subheadColor ?? this.subheadColor,
      borderColor: borderColor ?? this.borderColor,
      accentColor: accentColor ?? this.accentColor,
      rangeBandColor: rangeBandColor ?? this.rangeBandColor,
      disabledColor: disabledColor ?? this.disabledColor,
      controlRadius: controlRadius ?? this.controlRadius,
      sheetRadius: sheetRadius ?? this.sheetRadius,
      confirmLabel: confirmLabel ?? this.confirmLabel,
      cancelLabel: cancelLabel ?? this.cancelLabel,
      confirmColor: confirmColor ?? this.confirmColor,
      confirmTextColor: confirmTextColor ?? this.confirmTextColor,
      cancelColor: cancelColor ?? this.cancelColor,
      barrierColor: barrierColor ?? this.barrierColor,
      railGradientColors: railGradientColors ?? this.railGradientColors,
    );
  }
}
