import 'package:flutter/material.dart';

import '../unified_fields_strings.dart';
import '../unified_sheet_button.dart';
import 'unified_input_theme.dart';
import 'unified_picker_sheet_style.dart';

/// Shared title bar for [PickerSheetWidget] and [MultiPickerSheetWidget].
///
/// Builds a [Row] from [itemOrder] (or theme [UnifiedInputPickerHeaderStyle.itemOrder]).
/// Slots are laid out in **reading order** (start → end) for the current [TextDirection].
/// Only includes each [UnifiedPickerHeaderItem] when it is available; [title] is always
/// expanded. Default order: title → help → close → clear.
class UnifiedPickerSheetHeader extends StatelessWidget {
  /// Creates a picker sheet header.
  const UnifiedPickerSheetHeader({
    super.key,
    required this.title,
    this.titleWidget,
    this.helpText,
    this.helpWidget,
    this.showClear = false,
    this.onClear,
    this.itemOrder,
    this.closeButton,
    this.clearButton,
    this.pickerHeaderStyle,
  });

  /// Title text (already localized by the caller when needed).
  final String title;

  /// When set, used instead of [Text] for [title].
  final Widget? titleWidget;

  /// Help line (overrides theme [UnifiedInputPickerHeaderStyle.helpText] when set).
  final String? helpText;

  /// Custom help widget; wins over [helpText].
  final Widget? helpWidget;

  /// Whether to show the Clear action.
  final bool showClear;

  /// Called when Clear is pressed; defaults to popping `null`.
  final VoidCallback? onClear;

  /// Overrides theme [UnifiedInputPickerHeaderStyle.itemOrder] for this sheet.
  final List<UnifiedPickerHeaderItem>? itemOrder;

  /// Replaces the default [CloseButton].
  final Widget? closeButton;

  /// Replaces the default clear [UnifiedSheetButton] when [showClear] is true.
  final Widget? clearButton;

  /// Merged on top of [UnifiedInputThemeData.pickerHeaderStyle] for this sheet.
  final UnifiedInputPickerHeaderStyle? pickerHeaderStyle;

  @override
  Widget build(BuildContext context) {
    final palette = UnifiedInputThemeResolver.resolvePalette(context);
    final style = UnifiedInputThemeResolver.pickerHeaderStyle(
      context,
      override: pickerHeaderStyle,
    );
    final padding = UnifiedInputThemeResolver.pickerHeaderPadding(context);
    final background = UnifiedInputThemeResolver.pickerHeaderBackgroundColor(
      context,
      palette,
    );
    final titleStyle = UnifiedInputThemeResolver.pickerHeaderTitleStyle(
      context,
      palette,
    );
    final clearColor = UnifiedInputThemeResolver.pickerHeaderClearButtonColor(
      context,
    );
    final helpStyle = UnifiedInputThemeResolver.pickerHeaderHelpTextStyle(
      context,
      palette,
    );
    final order =
        itemOrder ?? style.itemOrder ?? kDefaultUnifiedPickerHeaderItemOrder;
    final textDirection = Directionality.of(context);

    final titleChild = Align(
      alignment: AlignmentDirectional.centerStart,
      child: titleWidget ??
          Text(
            title,
            style: titleStyle,
            textAlign: TextAlign.start,
            textDirection: textDirection,
          ),
    );
    final helpChild = helpWidget ??
        _helpFromString(
          helpText ?? style.helpText,
          helpStyle,
          textDirection: textDirection,
        );
    final closeChild = closeButton ?? const CloseButton();
    final clearChild = showClear
        ? (clearButton ??
              UnifiedSheetButton(
                label: UnifiedFieldsStrings.instance.clear,
                reverse: true,
                color: clearColor,
                onPressed: onClear ?? () => Navigator.of(context).pop(Null),
              ))
        : null;

    final children = <Widget>[];
    final seen = <UnifiedPickerHeaderItem>{};

    for (final slot in order) {
      if (!seen.add(slot)) continue;

      switch (slot) {
        case UnifiedPickerHeaderItem.title:
          children.add(Expanded(child: titleChild));
        case UnifiedPickerHeaderItem.help:
          if (helpChild != null) {
            children.add(helpChild);
          }
        case UnifiedPickerHeaderItem.close:
          children.add(closeChild);
        case UnifiedPickerHeaderItem.clear:
          if (clearChild != null) {
            children.add(clearChild);
          }
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: padding,
      child: Directionality(
        textDirection: textDirection,
        child: Row(
          textDirection: textDirection,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }

  static Widget? _helpFromString(
    String? text,
    TextStyle style, {
    required TextDirection textDirection,
  }) {
    if (text == null || text.isEmpty) return null;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.start,
        textDirection: textDirection,
      ),
    );
  }
}

/// Checkbox used in multi-picker list rows (themed, non-interactive; row handles tap).
class UnifiedMultiPickerCheckbox extends StatelessWidget {
  /// Creates a display-only checkbox for a row selection state.
  const UnifiedMultiPickerCheckbox({
    super.key,
    required this.value,
  });

  /// Whether the row is selected.
  final bool value;

  @override
  Widget build(BuildContext context) {
    final palette = UnifiedInputThemeResolver.resolvePalette(context);
    final style = UnifiedInputThemeResolver.multiPickerCheckboxStyle(context);
    final theme = Theme.of(context);
    final size = style.size ?? 20;
    final radius = style.borderRadius ?? BorderRadius.circular(4);
    final fill = style.fillColor ?? theme.colorScheme.primary;
    final check = style.checkColor ?? theme.colorScheme.onPrimary;
    final border = style.borderColor ?? palette.borderColor;

    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size,
        child: Checkbox(
          value: value,
          onChanged: (_) {},
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return fill;
            return Colors.transparent;
          }),
          checkColor: check,
          side: BorderSide(color: border, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
    );
  }
}
