import 'package:flutter/material.dart';

import 'unified_input_palette.dart';
import 'unified_input_theme.dart';

/// Shared bottom-sheet chrome for list pickers, wheel pickers, and [CustomWheelPicker].
///
/// Set on [UnifiedInputThemeData.basePickerSheetStyle] or per field via
/// [UnifiedPickerSheetStyle.basePickerSheetStyle]. Field-level
/// [UnifiedPickerSheetStyle.pickerSheetBackgroundColor] still overrides
/// [sheetBackgroundColor] when set.
@immutable
class UnifiedBasePickerSheetStyle {
  /// Creates optional base picker sheet overrides.
  const UnifiedBasePickerSheetStyle({
    this.sheetBackgroundColor,
    this.sheetBorderRadius,
    this.contentPadding,
    this.footerPadding,
    this.panelPadding,
    this.panelBackgroundColor,
    this.panelBorderRadius,
    this.panelBorderColor,
    this.panelBorderWidth,
  });

  /// Outer sheet / [Material] color behind header + body + footer.
  final Color? sheetBackgroundColor;

  /// Corner radius of the modal bottom sheet ([showModalBottomSheet] shape).
  final BorderRadius? sheetBorderRadius;

  /// Padding around the wheel / list body (inside the sheet, below the header).
  final EdgeInsetsGeometry? contentPadding;

  /// Padding around the cancel / confirm row.
  final EdgeInsetsGeometry? footerPadding;

  /// Padding inside the wheel panel [DecoratedBox].
  final EdgeInsetsGeometry? panelPadding;

  /// Wheel panel fill (maps to [UnifiedFieldsDateWheelStyle.wheelBackground] when unset).
  final Color? panelBackgroundColor;

  /// Wheel panel corner radius.
  final BorderRadius? panelBorderRadius;

  /// Wheel panel border color.
  final Color? panelBorderColor;

  /// Wheel panel border width.
  final double? panelBorderWidth;

  /// Default top corner radius for modal picker sheets.
  static const double kDefaultSheetRadius = 12;

  /// Default corner radius for the wheel/list panel inside the sheet.
  static const double kDefaultPanelRadius = 12;

  /// Default border width around the wheel panel.
  static const double kDefaultPanelBorderWidth = 1;

  /// Default padding around picker body content.
  static const EdgeInsets kDefaultContentPadding =
      EdgeInsets.fromLTRB(16, 4, 16, 8);

  /// Default padding around cancel / confirm actions.
  static const EdgeInsets kDefaultFooterPadding =
      EdgeInsets.fromLTRB(16, 8, 16, 16);

  /// Merges [other] on top of this.
  UnifiedBasePickerSheetStyle merge(UnifiedBasePickerSheetStyle? other) {
    if (other == null) return this;
    return UnifiedBasePickerSheetStyle(
      sheetBackgroundColor:
          other.sheetBackgroundColor ?? sheetBackgroundColor,
      sheetBorderRadius: other.sheetBorderRadius ?? sheetBorderRadius,
      contentPadding: other.contentPadding ?? contentPadding,
      footerPadding: other.footerPadding ?? footerPadding,
      panelPadding: other.panelPadding ?? panelPadding,
      panelBackgroundColor:
          other.panelBackgroundColor ?? panelBackgroundColor,
      panelBorderRadius: other.panelBorderRadius ?? panelBorderRadius,
      panelBorderColor: other.panelBorderColor ?? panelBorderColor,
      panelBorderWidth: other.panelBorderWidth ?? panelBorderWidth,
    );
  }

  /// Theme → field [pickerSheetStyle.base] → [fieldOverride] → legacy [pickerSheetBackgroundColor].
  static UnifiedBasePickerSheetStyle resolve(
    BuildContext context, {
    UnifiedBasePickerSheetStyle? fieldOverride,
    UnifiedPickerSheetStyle? pickerSheetStyle,
    Color? pickerSheetBackgroundColor,
    UnifiedInputPalette? palette,
  }) {
    final p = palette ?? UnifiedInputThemeResolver.resolvePalette(context);
    final themeBase =
        UnifiedInputThemeScope.themeDataOf(context).basePickerSheetStyle;
    final bundled = pickerSheetStyle?.basePickerSheetStyle;
    final legacyBg = pickerSheetBackgroundColor ??
        pickerSheetStyle?.pickerSheetBackgroundColor;

    final merged = const UnifiedBasePickerSheetStyle()
        .merge(themeBase)
        .merge(bundled)
        .merge(fieldOverride);

    final sheetBg = legacyBg ??
        merged.sheetBackgroundColor ??
        UnifiedInputThemeScope.themeDataOf(context).pickerSheetBackgroundColor ??
        Theme.of(context).bottomSheetTheme.backgroundColor ??
        p.sheetBackground;

    final panelBg = merged.panelBackgroundColor ?? p.sheetHeaderBackground;

    return UnifiedBasePickerSheetStyle(
      sheetBackgroundColor: sheetBg,
      sheetBorderRadius: merged.sheetBorderRadius ??
          const BorderRadius.vertical(top: Radius.circular(kDefaultSheetRadius)),
      contentPadding: merged.contentPadding ?? kDefaultContentPadding,
      footerPadding: merged.footerPadding ?? kDefaultFooterPadding,
      panelPadding: merged.panelPadding ?? EdgeInsets.zero,
      panelBackgroundColor: panelBg,
      panelBorderRadius: merged.panelBorderRadius ??
          BorderRadius.circular(kDefaultPanelRadius),
      panelBorderColor: merged.panelBorderColor ??
          p.borderColor.withValues(alpha: 0.65),
      panelBorderWidth: merged.panelBorderWidth ?? kDefaultPanelBorderWidth,
    );
  }
}
