import 'package:flutter/material.dart';

import '../unified_fields_strings.dart';
import '../unified_sheet_button.dart';
import 'unified_input_theme.dart';

/// Shared title bar for [PickerSheetWidget] and [MultiPickerSheetWidget].
class UnifiedPickerSheetHeader extends StatelessWidget {
  /// Creates a picker sheet header.
  const UnifiedPickerSheetHeader({
    super.key,
    required this.title,
    this.showClear = false,
    this.onClear,
  });

  /// Title text (already localized by the caller when needed).
  final String title;

  /// Whether to show the Clear action.
  final bool showClear;

  /// Called when Clear is pressed; defaults to popping `null`.
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final palette = UnifiedInputThemeResolver.resolvePalette(context);
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

    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: titleStyle),
          ),
          if (showClear)
            UnifiedSheetButton(
              label: UnifiedFieldsStrings.instance.clear,
              reverse: true,
              color: clearColor,
              onPressed: onClear ?? () => Navigator.of(context).pop(Null),
            ),
          const CloseButton(),
        ],
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
    final radius = style.borderRadius ?? 4;
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }
}
