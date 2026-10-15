import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'unified_input_brightness.dart';
import 'unified_input_palette.dart';
import 'unified_input_theme.dart';
import 'unified_picker_presentation.dart';

/// Shared list-row / search chrome for single, multi, and async picker sheets.
///
/// Resolves from [UnifiedInputPalette] so light and dark themes stay readable
/// (avoids hardcoded light-grey rows + inherited white [DefaultTextStyle]).
@immutable
class UnifiedPickerListChrome {
  const UnifiedPickerListChrome._({
    required this.palette,
    required this.rowBackground,
    required this.selectedRowBackground,
    required this.highlightedRowBackground,
    required this.dividerColor,
    required this.highlightBorderColor,
    required this.itemTextStyle,
    required this.mutedTextStyle,
    required this.searchDecoration,
    required this.searchTextStyle,
    required this.searchPlaceholderStyle,
    required this.searchPrefixColor,
  });

  /// Active palette used to derive sheet list/search colors.
  final UnifiedInputPalette palette;

  /// Default (unselected) list-row fill.
  final Color rowBackground;

  /// Selected list-row fill.
  final Color selectedRowBackground;

  /// Keyboard-highlight list-row fill.
  final Color highlightedRowBackground;

  /// Row divider color.
  final Color dividerColor;

  /// Start-edge accent when a row is keyboard-highlighted.
  final Color highlightBorderColor;

  /// Default item label style.
  final TextStyle itemTextStyle;

  /// Muted / empty-state text style.
  final TextStyle mutedTextStyle;

  /// Search field fill decoration.
  final BoxDecoration searchDecoration;

  /// Search field typed-text style.
  final TextStyle searchTextStyle;

  /// Search field placeholder style.
  final TextStyle searchPlaceholderStyle;

  /// Search prefix icon color.
  final Color searchPrefixColor;

  /// Resolve chrome for the ambient [UnifiedInputThemeScope] / [Theme].
  factory UnifiedPickerListChrome.of(BuildContext context) {
    final palette = UnifiedInputThemeResolver.resolvePalette(context);
    final brightness = UnifiedInputThemeResolver.inferBrightness(context);
    final isDark = brightness == UnifiedInputBrightness.dark;

    final rowBg = isDark
        ? Color.alphaBlend(
            Colors.white.withValues(alpha: 0.04),
            palette.sheetBackground,
          )
        : const Color(0xffF2F3F6);
    final selectedBg = isDark
        ? Colors.blueAccent.withValues(alpha: 0.28)
        : Colors.blueAccent.withValues(alpha: 0.3);
    final highlightedBg = isDark
        ? Colors.blueAccent.withValues(alpha: 0.14)
        : Colors.blueAccent.withValues(alpha: 0.12);
    final divider = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white;
    final searchFill = isDark
        ? Color.alphaBlend(
            Colors.white.withValues(alpha: 0.08),
            palette.sheetBackground,
          )
        : CupertinoColors.tertiarySystemFill.resolveFrom(context);

    return UnifiedPickerListChrome._(
      palette: palette,
      rowBackground: rowBg,
      selectedRowBackground: selectedBg,
      highlightedRowBackground: highlightedBg,
      dividerColor: divider,
      highlightBorderColor: Colors.blueAccent,
      itemTextStyle: TextStyle(
        color: palette.fieldTextColor,
        fontSize: 15,
        height: 1.25,
      ),
      mutedTextStyle: TextStyle(
        color: palette.hintColor,
        fontSize: 15,
        height: 1.25,
      ),
      searchDecoration: BoxDecoration(
        color: searchFill,
        borderRadius: BorderRadius.circular(10),
      ),
      searchTextStyle: TextStyle(
        color: palette.fieldTextColor,
        fontSize: 15,
      ),
      searchPlaceholderStyle: TextStyle(
        color: palette.hintColor,
        fontSize: 15,
      ),
      searchPrefixColor: palette.hintColor,
    );
  }

  /// Background for a standard list row.
  Color backgroundFor({required bool selected, bool highlighted = false}) {
    if (selected) return selectedRowBackground;
    if (highlighted) return highlightedRowBackground;
    return rowBackground;
  }

  /// Bottom divider + optional highlight accent on the start edge.
  Border borderFor({bool highlighted = false}) {
    return Border(
      bottom: BorderSide(color: dividerColor),
      left: highlighted
          ? BorderSide(color: highlightBorderColor, width: 3)
          : BorderSide.none,
    );
  }

  /// Themed search field used at the top of picker sheets / popovers.
  Widget buildSearchField({
    required TextEditingController controller,
    FocusNode? focusNode,
    bool autofocus = false,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onSubmitted,
    String? placeholder,
    Widget? trailing,
  }) {
    return UnifiedPickerSearchBox(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      inputFormatters: inputFormatters,
      onSubmitted: onSubmitted,
      placeholder: placeholder,
      trailing: trailing,
    );
  }
}

/// Search box for picker sheets and popovers (styled by [UnifiedPickerSurfaceStyle]).
class UnifiedPickerSearchBox extends StatelessWidget {
  /// Creates a picker search box.
  const UnifiedPickerSearchBox({
    super.key,
    required this.controller,
    this.focusNode,
    this.autofocus = false,
    this.inputFormatters,
    this.onSubmitted,
    this.placeholder,
    this.trailing,
  });

  /// Query controller.
  final TextEditingController controller;

  /// Focus node.
  final FocusNode? focusNode;

  /// Autofocus on open.
  final bool autofocus;

  /// Formatters (theme `pickerSearchInputFormatters`).
  final List<TextInputFormatter>? inputFormatters;

  /// Enter handler.
  final ValueChanged<String>? onSubmitted;

  /// Placeholder; defaults to "Search".
  final String? placeholder;

  /// Trailing slot (e.g. Clear in anchored popovers).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final s = UnifiedResolvedPickerSurface.of(context);
    final compact = UnifiedPickerPresentationScope.isCompactOf(context);
    OutlineInputBorder border(Color c, double w) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(s.searchBorderRadius),
          borderSide: c.a == 0 ? BorderSide.none : BorderSide(color: c, width: w),
        );
    final field = SizedBox(
      height: s.searchHeight,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        inputFormatters: inputFormatters ?? const [],
        onSubmitted: onSubmitted,
        style: s.searchTextStyle,
        cursorColor: s.accentColor,
        cursorWidth: 1.5,
        expands: true,
        maxLines: null,
        minLines: null,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: s.searchBackgroundColor,
          hintText: placeholder ?? MaterialLocalizations.of(context).searchFieldLabel,
          hintStyle: s.searchPlaceholderStyle,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          prefixIcon: Icon(s.searchIcon, size: 18, color: s.searchPlaceholderStyle.color),
          prefixIconConstraints: const BoxConstraints(minWidth: 34, minHeight: 18),
          border: border(s.searchBorderColor, 1),
          enabledBorder: border(s.searchBorderColor, 1),
          focusedBorder: border(s.searchFocusedBorderColor, 1.5),
        ),
      ),
    );
    final row = trailing == null
        ? field
        : Row(children: [Expanded(child: field), const SizedBox(width: 6), trailing!]);
    return compact ? row : Padding(padding: const EdgeInsets.fromLTRB(12, 4, 12, 8), child: row);
  }
}
