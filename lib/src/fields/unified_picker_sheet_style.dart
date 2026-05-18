import 'package:flutter/material.dart';

/// A slot in a picker sheet header row ([UnifiedPickerSheetHeader]).
enum UnifiedPickerHeaderItem {
  /// Title (always shown; uses [Expanded] in the row).
  title,

  /// Help text / widget when provided.
  help,

  /// Close control (dismisses the sheet).
  close,

  /// Clear action when [UnifiedPickerSheetHeader.showClear] is true.
  clear,
}

/// Default header order: title expands, then help, close, clear.
const List<UnifiedPickerHeaderItem> kDefaultUnifiedPickerHeaderItemOrder = [
  UnifiedPickerHeaderItem.title,
  UnifiedPickerHeaderItem.help,
  UnifiedPickerHeaderItem.close,
  UnifiedPickerHeaderItem.clear,
];

/// Local overrides for list-picker bottom sheets on picker fields.
///
/// When null on a field, [UnifiedInputThemeData.pickerSheetBackgroundColor] and
/// [pickerHeaderStyle] from [UnifiedInputThemeScope] apply.
@immutable
class UnifiedPickerSheetStyle {
  /// Creates per-field picker sheet chrome overrides.
  const UnifiedPickerSheetStyle({
    this.pickerSheetBackgroundColor,
    this.pickerHeaderStyle,
  });

  /// Sheet surface color; overrides theme [UnifiedInputThemeData.pickerSheetBackgroundColor].
  final Color? pickerSheetBackgroundColor;

  /// Header row chrome; merged on top of theme [UnifiedInputThemeData.pickerHeaderStyle].
  final UnifiedInputPickerHeaderStyle? pickerHeaderStyle;
}

/// Resolves field-level picker sheet overrides (direct params win over [pickerSheetStyle]).
({Color? sheetBackgroundColor, UnifiedInputPickerHeaderStyle? pickerHeaderStyle})
resolvePickerSheetStyleOverrides({
  UnifiedPickerSheetStyle? pickerSheetStyle,
  Color? pickerSheetBackgroundColor,
  UnifiedInputPickerHeaderStyle? pickerHeaderStyle,
}) {
  return (
    sheetBackgroundColor:
        pickerSheetBackgroundColor ??
        pickerSheetStyle?.pickerSheetBackgroundColor,
    pickerHeaderStyle:
        pickerHeaderStyle ?? pickerSheetStyle?.pickerHeaderStyle,
  );
}

/// Chrome for single / multi picker sheet title bars.
@immutable
class UnifiedInputPickerHeaderStyle {
  /// Creates optional picker header overrides.
  const UnifiedInputPickerHeaderStyle({
    this.padding,
    this.backgroundColor,
    this.titleStyle,
    this.helpTextStyle,
    this.clearButtonColor,
    this.itemOrder,
    this.closeButton,
    this.clearButton,
    this.helpText,
  });

  /// Padding around the title row ([EdgeInsetsDirectional] recommended).
  final EdgeInsetsGeometry? padding;

  /// Header bar background; defaults to palette `sheetHeaderBackground`.
  final Color? backgroundColor;

  /// Title text style.
  final TextStyle? titleStyle;

  /// Style for [helpText] (and per-sheet [UnifiedPickerSheetHeader.helpText]).
  final TextStyle? helpTextStyle;

  /// Clear action color on [UnifiedSheetButton].
  final Color? clearButtonColor;

  /// Reading-order layout of header slots (start → end for the ambient [TextDirection]);
  /// omitted entries are skipped if unavailable.
  ///
  /// Defaults to [kDefaultUnifiedPickerHeaderItemOrder]. [UnifiedPickerHeaderItem.title]
  /// is wrapped in [Expanded]; other items use intrinsic width.
  final List<UnifiedPickerHeaderItem>? itemOrder;

  /// Replaces the default [CloseButton] when set.
  final Widget? closeButton;

  /// Replaces the default clear [UnifiedSheetButton] when set.
  final Widget? clearButton;

  /// Default help copy when the sheet does not pass [UnifiedPickerSheetHeader.helpText].
  final String? helpText;

  /// Merges [override] on top of this; non-null fields from [override] win.
  UnifiedInputPickerHeaderStyle merge(UnifiedInputPickerHeaderStyle? override) {
    if (override == null) return this;
    return UnifiedInputPickerHeaderStyle(
      padding: override.padding ?? padding,
      backgroundColor: override.backgroundColor ?? backgroundColor,
      titleStyle: override.titleStyle ?? titleStyle,
      helpTextStyle: override.helpTextStyle ?? helpTextStyle,
      clearButtonColor: override.clearButtonColor ?? clearButtonColor,
      itemOrder: override.itemOrder ?? itemOrder,
      closeButton: override.closeButton ?? closeButton,
      clearButton: override.clearButton ?? clearButton,
      helpText: override.helpText ?? helpText,
    );
  }
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
  final BorderRadius? borderRadius;

  /// Fill when selected; defaults to [ThemeData.colorScheme.primary].
  final Color? fillColor;

  /// Check mark color; defaults to [ThemeData.colorScheme.onPrimary].
  final Color? checkColor;

  /// Border when unselected; defaults to palette border.
  final Color? borderColor;
}
