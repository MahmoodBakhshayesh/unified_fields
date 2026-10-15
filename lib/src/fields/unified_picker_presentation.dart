import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'unified_input_brightness.dart';
import 'unified_input_theme.dart';
import 'unified_picker_keyboard.dart';

/// Where a picker (list, multi, async, date, time, duration) opens.
enum UnifiedPickerPresentation {
  /// Modal bottom sheet from the bottom edge (package default, phone style).
  bottomSheet,

  /// Dropdown anchored to the field: opens under it (or above when there is no
  /// room), at least as wide as the field — desktop / web style.
  anchored,

  /// Centered dialog using [UnifiedPickerSurfaceStyle] chrome.
  dialog,

  /// [anchored] when the window is at least
  /// [UnifiedPickerSurfaceStyle.adaptiveBreakpoint] wide, otherwise [bottomSheet].
  adaptive,
}

/// Visual tokens for picker surfaces (dropdown popovers, dialogs, list rows,
/// search box, action buttons, compact date / time / duration pickers).
///
/// Every value is optional. Set it once on
/// [UnifiedInputThemeData.pickerSurfaceStyle] to match a design system, or per
/// field via [UnifiedPickerSheetStyle.surfaceStyle]. Unset values resolve from
/// [UnifiedInputPalette] and [ThemeData] ([UnifiedResolvedPickerSurface.of]).
@immutable
class UnifiedPickerSurfaceStyle {
  /// Creates optional picker surface overrides.
  const UnifiedPickerSurfaceStyle({
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.shadows,
    this.padding,
    this.rowHeight,
    this.sheetRowHeight,
    this.rowPadding,
    this.rowRadius,
    this.rowSpacing,
    this.rowColor,
    this.rowHoverColor,
    this.rowSelectedColor,
    this.rowSelectedTextColor,
    this.rowHighlightColor,
    this.showRowDividers,
    this.dividerColor,
    this.itemTextStyle,
    this.mutedTextStyle,
    this.sectionTextStyle,
    this.selectedIcon,
    this.accentColor,
    this.onAccentColor,
    this.searchHeight,
    this.searchBackgroundColor,
    this.searchBorderColor,
    this.searchFocusedBorderColor,
    this.searchBorderRadius,
    this.searchTextStyle,
    this.searchPlaceholderStyle,
    this.searchIcon,
    this.actionHeight,
    this.actionRadius,
    this.actionTextStyle,
    this.secondaryActionColor,
    this.secondaryActionTextColor,
    this.anchoredMaxHeight,
    this.anchoredGap,
    this.anchoredMinWidth,
    this.anchoredScreenMargin,
    this.anchoredBarrierColor,
    this.dialogWidth,
    this.dialogBarrierColor,
    this.adaptiveBreakpoint,
    this.monoTextStyle,
    this.todayColor,
  });

  /// Surface fill.
  final Color? backgroundColor;

  /// Surface outline color.
  final Color? borderColor;

  /// Surface outline width (0 hides it).
  final double? borderWidth;

  /// Surface corner radius.
  final double? borderRadius;

  /// Surface elevation shadows.
  final List<BoxShadow>? shadows;

  /// Inner padding around list rows in compact (anchored / dialog) mode.
  final EdgeInsets? padding;

  /// Row height in compact mode.
  final double? rowHeight;

  /// Row height in bottom-sheet mode (touch friendly).
  final double? sheetRowHeight;

  /// Row content padding.
  final EdgeInsetsGeometry? rowPadding;

  /// Row corner radius (rows are inset pills in compact mode).
  final double? rowRadius;

  /// Vertical gap between rows.
  final double? rowSpacing;

  /// Idle row fill.
  final Color? rowColor;

  /// Hovered row fill.
  final Color? rowHoverColor;

  /// Selected row fill.
  final Color? rowSelectedColor;

  /// Selected row text / check color.
  final Color? rowSelectedTextColor;

  /// Keyboard-highlighted row fill (Arrow keys).
  final Color? rowHighlightColor;

  /// Hairline between rows.
  final bool? showRowDividers;

  /// Row divider / footer separator color.
  final Color? dividerColor;

  /// Row label style.
  final TextStyle? itemTextStyle;

  /// Captions, counts and empty-state text.
  final TextStyle? mutedTextStyle;

  /// Small uppercase section labels (e.g. "Suggested").
  final TextStyle? sectionTextStyle;

  /// Trailing icon on the selected row of single pickers (null hides it).
  final IconData? selectedIcon;

  /// Accent for selection, primary actions and focused search.
  final Color? accentColor;

  /// Foreground on [accentColor].
  final Color? onAccentColor;

  /// Search box height.
  final double? searchHeight;

  /// Search box fill.
  final Color? searchBackgroundColor;

  /// Search box idle outline.
  final Color? searchBorderColor;

  /// Search box focused outline.
  final Color? searchFocusedBorderColor;

  /// Search box radius.
  final double? searchBorderRadius;

  /// Search typed text.
  final TextStyle? searchTextStyle;

  /// Search placeholder.
  final TextStyle? searchPlaceholderStyle;

  /// Search leading icon.
  final IconData? searchIcon;

  /// Height of footer / header action buttons.
  final double? actionHeight;

  /// Radius of action buttons.
  final double? actionRadius;

  /// Label style of action buttons.
  final TextStyle? actionTextStyle;

  /// Fill of secondary (Cancel / Clear) actions.
  final Color? secondaryActionColor;

  /// Text of secondary actions.
  final Color? secondaryActionTextColor;

  /// Max popover height when anchored.
  final double? anchoredMaxHeight;

  /// Gap between the field and the popover.
  final double? anchoredGap;

  /// Minimum popover width (narrow fields still get a usable list / calendar).
  final double? anchoredMinWidth;

  /// Distance kept from the window edges.
  final double? anchoredScreenMargin;

  /// Barrier behind an anchored popover (default transparent).
  final Color? anchoredBarrierColor;

  /// Width of [UnifiedPickerPresentation.dialog] list pickers.
  final double? dialogWidth;

  /// Barrier behind a dialog picker.
  final Color? dialogBarrierColor;

  /// Window width at which [UnifiedPickerPresentation.adaptive] anchors.
  final double? adaptiveBreakpoint;

  /// Digits in compact date / time / duration pickers (typed entry, columns).
  final TextStyle? monoTextStyle;

  /// Outline of "today" in the compact calendar.
  final Color? todayColor;

  /// Non-null values of [other] win.
  UnifiedPickerSurfaceStyle merge(UnifiedPickerSurfaceStyle? other) {
    if (other == null) return this;
    return UnifiedPickerSurfaceStyle(
      backgroundColor: other.backgroundColor ?? backgroundColor,
      borderColor: other.borderColor ?? borderColor,
      borderWidth: other.borderWidth ?? borderWidth,
      borderRadius: other.borderRadius ?? borderRadius,
      shadows: other.shadows ?? shadows,
      padding: other.padding ?? padding,
      rowHeight: other.rowHeight ?? rowHeight,
      sheetRowHeight: other.sheetRowHeight ?? sheetRowHeight,
      rowPadding: other.rowPadding ?? rowPadding,
      rowRadius: other.rowRadius ?? rowRadius,
      rowSpacing: other.rowSpacing ?? rowSpacing,
      rowColor: other.rowColor ?? rowColor,
      rowHoverColor: other.rowHoverColor ?? rowHoverColor,
      rowSelectedColor: other.rowSelectedColor ?? rowSelectedColor,
      rowSelectedTextColor: other.rowSelectedTextColor ?? rowSelectedTextColor,
      rowHighlightColor: other.rowHighlightColor ?? rowHighlightColor,
      showRowDividers: other.showRowDividers ?? showRowDividers,
      dividerColor: other.dividerColor ?? dividerColor,
      itemTextStyle: itemTextStyle?.merge(other.itemTextStyle) ?? other.itemTextStyle,
      mutedTextStyle: mutedTextStyle?.merge(other.mutedTextStyle) ?? other.mutedTextStyle,
      sectionTextStyle: sectionTextStyle?.merge(other.sectionTextStyle) ?? other.sectionTextStyle,
      selectedIcon: other.selectedIcon ?? selectedIcon,
      accentColor: other.accentColor ?? accentColor,
      onAccentColor: other.onAccentColor ?? onAccentColor,
      searchHeight: other.searchHeight ?? searchHeight,
      searchBackgroundColor: other.searchBackgroundColor ?? searchBackgroundColor,
      searchBorderColor: other.searchBorderColor ?? searchBorderColor,
      searchFocusedBorderColor: other.searchFocusedBorderColor ?? searchFocusedBorderColor,
      searchBorderRadius: other.searchBorderRadius ?? searchBorderRadius,
      searchTextStyle: searchTextStyle?.merge(other.searchTextStyle) ?? other.searchTextStyle,
      searchPlaceholderStyle:
          searchPlaceholderStyle?.merge(other.searchPlaceholderStyle) ?? other.searchPlaceholderStyle,
      searchIcon: other.searchIcon ?? searchIcon,
      actionHeight: other.actionHeight ?? actionHeight,
      actionRadius: other.actionRadius ?? actionRadius,
      actionTextStyle: actionTextStyle?.merge(other.actionTextStyle) ?? other.actionTextStyle,
      secondaryActionColor: other.secondaryActionColor ?? secondaryActionColor,
      secondaryActionTextColor: other.secondaryActionTextColor ?? secondaryActionTextColor,
      anchoredMaxHeight: other.anchoredMaxHeight ?? anchoredMaxHeight,
      anchoredGap: other.anchoredGap ?? anchoredGap,
      anchoredMinWidth: other.anchoredMinWidth ?? anchoredMinWidth,
      anchoredScreenMargin: other.anchoredScreenMargin ?? anchoredScreenMargin,
      anchoredBarrierColor: other.anchoredBarrierColor ?? anchoredBarrierColor,
      dialogWidth: other.dialogWidth ?? dialogWidth,
      dialogBarrierColor: other.dialogBarrierColor ?? dialogBarrierColor,
      adaptiveBreakpoint: other.adaptiveBreakpoint ?? adaptiveBreakpoint,
      monoTextStyle: monoTextStyle?.merge(other.monoTextStyle) ?? other.monoTextStyle,
      todayColor: other.todayColor ?? todayColor,
    );
  }
}

/// [UnifiedPickerSurfaceStyle] with every value resolved (theme → field → defaults).
@immutable
class UnifiedResolvedPickerSurface {
  const UnifiedResolvedPickerSurface._({
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.shadows,
    required this.padding,
    required this.rowHeight,
    required this.sheetRowHeight,
    required this.rowPadding,
    required this.rowRadius,
    required this.rowSpacing,
    required this.rowColor,
    required this.rowHoverColor,
    required this.rowSelectedColor,
    required this.rowSelectedTextColor,
    required this.rowHighlightColor,
    required this.showRowDividers,
    required this.dividerColor,
    required this.itemTextStyle,
    required this.mutedTextStyle,
    required this.sectionTextStyle,
    required this.selectedIcon,
    required this.accentColor,
    required this.onAccentColor,
    required this.searchHeight,
    required this.searchBackgroundColor,
    required this.searchBorderColor,
    required this.searchFocusedBorderColor,
    required this.searchBorderRadius,
    required this.searchTextStyle,
    required this.searchPlaceholderStyle,
    required this.searchIcon,
    required this.actionHeight,
    required this.actionRadius,
    required this.actionTextStyle,
    required this.secondaryActionColor,
    required this.secondaryActionTextColor,
    required this.anchoredMaxHeight,
    required this.anchoredGap,
    required this.anchoredMinWidth,
    required this.anchoredScreenMargin,
    required this.anchoredBarrierColor,
    required this.dialogWidth,
    required this.dialogBarrierColor,
    required this.adaptiveBreakpoint,
    required this.monoTextStyle,
    required this.todayColor,
  });

  /// See [UnifiedPickerSurfaceStyle.backgroundColor].
  final Color backgroundColor;
  /// See [UnifiedPickerSurfaceStyle.borderColor].
  final Color borderColor;
  /// See [UnifiedPickerSurfaceStyle.borderWidth].
  final double borderWidth;
  /// See [UnifiedPickerSurfaceStyle.borderRadius].
  final double borderRadius;
  /// See [UnifiedPickerSurfaceStyle.shadows].
  final List<BoxShadow> shadows;
  /// See [UnifiedPickerSurfaceStyle.padding].
  final EdgeInsets padding;
  /// See [UnifiedPickerSurfaceStyle.rowHeight].
  final double rowHeight;
  /// See [UnifiedPickerSurfaceStyle.sheetRowHeight].
  final double sheetRowHeight;
  /// See [UnifiedPickerSurfaceStyle.rowPadding].
  final EdgeInsetsGeometry rowPadding;
  /// See [UnifiedPickerSurfaceStyle.rowRadius].
  final double rowRadius;
  /// See [UnifiedPickerSurfaceStyle.rowSpacing].
  final double rowSpacing;
  /// See [UnifiedPickerSurfaceStyle.rowColor].
  final Color rowColor;
  /// See [UnifiedPickerSurfaceStyle.rowHoverColor].
  final Color rowHoverColor;
  /// See [UnifiedPickerSurfaceStyle.rowSelectedColor].
  final Color rowSelectedColor;
  /// See [UnifiedPickerSurfaceStyle.rowSelectedTextColor].
  final Color rowSelectedTextColor;
  /// See [UnifiedPickerSurfaceStyle.rowHighlightColor].
  final Color rowHighlightColor;
  /// See [UnifiedPickerSurfaceStyle.showRowDividers].
  final bool showRowDividers;
  /// See [UnifiedPickerSurfaceStyle.dividerColor].
  final Color dividerColor;
  /// See [UnifiedPickerSurfaceStyle.itemTextStyle].
  final TextStyle itemTextStyle;
  /// See [UnifiedPickerSurfaceStyle.mutedTextStyle].
  final TextStyle mutedTextStyle;
  /// See [UnifiedPickerSurfaceStyle.sectionTextStyle].
  final TextStyle sectionTextStyle;
  /// See [UnifiedPickerSurfaceStyle.selectedIcon].
  final IconData? selectedIcon;
  /// See [UnifiedPickerSurfaceStyle.accentColor].
  final Color accentColor;
  /// See [UnifiedPickerSurfaceStyle.onAccentColor].
  final Color onAccentColor;
  /// See [UnifiedPickerSurfaceStyle.searchHeight].
  final double searchHeight;
  /// See [UnifiedPickerSurfaceStyle.searchBackgroundColor].
  final Color searchBackgroundColor;
  /// See [UnifiedPickerSurfaceStyle.searchBorderColor].
  final Color searchBorderColor;
  /// See [UnifiedPickerSurfaceStyle.searchFocusedBorderColor].
  final Color searchFocusedBorderColor;
  /// See [UnifiedPickerSurfaceStyle.searchBorderRadius].
  final double searchBorderRadius;
  /// See [UnifiedPickerSurfaceStyle.searchTextStyle].
  final TextStyle searchTextStyle;
  /// See [UnifiedPickerSurfaceStyle.searchPlaceholderStyle].
  final TextStyle searchPlaceholderStyle;
  /// See [UnifiedPickerSurfaceStyle.searchIcon].
  final IconData searchIcon;
  /// See [UnifiedPickerSurfaceStyle.actionHeight].
  final double actionHeight;
  /// See [UnifiedPickerSurfaceStyle.actionRadius].
  final double actionRadius;
  /// See [UnifiedPickerSurfaceStyle.actionTextStyle].
  final TextStyle actionTextStyle;
  /// See [UnifiedPickerSurfaceStyle.secondaryActionColor].
  final Color secondaryActionColor;
  /// See [UnifiedPickerSurfaceStyle.secondaryActionTextColor].
  final Color secondaryActionTextColor;
  /// See [UnifiedPickerSurfaceStyle.anchoredMaxHeight].
  final double anchoredMaxHeight;
  /// See [UnifiedPickerSurfaceStyle.anchoredGap].
  final double anchoredGap;
  /// See [UnifiedPickerSurfaceStyle.anchoredMinWidth].
  final double anchoredMinWidth;
  /// See [UnifiedPickerSurfaceStyle.anchoredScreenMargin].
  final double anchoredScreenMargin;
  /// See [UnifiedPickerSurfaceStyle.anchoredBarrierColor].
  final Color anchoredBarrierColor;
  /// See [UnifiedPickerSurfaceStyle.dialogWidth].
  final double dialogWidth;
  /// See [UnifiedPickerSurfaceStyle.dialogBarrierColor].
  final Color dialogBarrierColor;
  /// See [UnifiedPickerSurfaceStyle.adaptiveBreakpoint].
  final double adaptiveBreakpoint;
  /// See [UnifiedPickerSurfaceStyle.monoTextStyle].
  final TextStyle monoTextStyle;
  /// See [UnifiedPickerSurfaceStyle.todayColor].
  final Color todayColor;

  /// Resolves theme [UnifiedInputThemeData.pickerSurfaceStyle] + [override] over defaults.
  factory UnifiedResolvedPickerSurface.of(BuildContext context, {UnifiedPickerSurfaceStyle? override}) {
    final palette = UnifiedInputThemeResolver.resolvePalette(context);
    final dark = UnifiedInputThemeResolver.inferBrightness(context) == UnifiedInputBrightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final s = (UnifiedInputThemeScope.themeDataOf(context).pickerSurfaceStyle ?? const UnifiedPickerSurfaceStyle())
        .merge(override);
    final ink = palette.fieldTextColor;
    final accent = s.accentColor ?? scheme.primary;
    final itemStyle = TextStyle(color: ink, fontSize: 14, height: 1.25).merge(s.itemTextStyle);
    final muted = TextStyle(color: palette.hintColor, fontSize: 12.5, height: 1.25).merge(s.mutedTextStyle);
    return UnifiedResolvedPickerSurface._(
      backgroundColor: s.backgroundColor ?? palette.sheetBackground,
      borderColor: s.borderColor ?? palette.borderColor.withValues(alpha: dark ? 0.5 : 0.8),
      borderWidth: s.borderWidth ?? 1,
      borderRadius: s.borderRadius ?? 12,
      shadows: s.shadows ??
          [
            BoxShadow(color: Colors.black.withValues(alpha: dark ? 0.4 : 0.12), blurRadius: 24, offset: const Offset(0, 8)),
            BoxShadow(color: Colors.black.withValues(alpha: dark ? 0.25 : 0.05), blurRadius: 4, offset: const Offset(0, 1)),
          ],
      padding: s.padding ?? const EdgeInsets.all(4),
      rowHeight: s.rowHeight ?? 36,
      sheetRowHeight: s.sheetRowHeight ?? 48,
      rowPadding: s.rowPadding ?? const EdgeInsets.symmetric(horizontal: 10),
      rowRadius: s.rowRadius ?? 8,
      rowSpacing: s.rowSpacing ?? 1,
      rowColor: s.rowColor ?? Colors.transparent,
      rowHoverColor: s.rowHoverColor ?? ink.withValues(alpha: dark ? 0.08 : 0.05),
      rowSelectedColor: s.rowSelectedColor ?? accent.withValues(alpha: dark ? 0.22 : 0.10),
      rowSelectedTextColor: s.rowSelectedTextColor ?? (dark ? Color.lerp(accent, Colors.white, 0.35)! : accent),
      rowHighlightColor: s.rowHighlightColor ?? ink.withValues(alpha: dark ? 0.12 : 0.08),
      showRowDividers: s.showRowDividers ?? false,
      dividerColor: s.dividerColor ?? palette.borderColor.withValues(alpha: dark ? 0.35 : 0.6),
      itemTextStyle: itemStyle,
      mutedTextStyle: muted,
      sectionTextStyle: muted
          .copyWith(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.6)
          .merge(s.sectionTextStyle),
      selectedIcon: s.selectedIcon ?? Icons.check_rounded,
      accentColor: accent,
      onAccentColor: s.onAccentColor ?? scheme.onPrimary,
      searchHeight: s.searchHeight ?? 36,
      searchBackgroundColor: s.searchBackgroundColor ?? ink.withValues(alpha: dark ? 0.07 : 0.04),
      searchBorderColor: s.searchBorderColor ?? Colors.transparent,
      searchFocusedBorderColor: s.searchFocusedBorderColor ?? accent,
      searchBorderRadius: s.searchBorderRadius ?? 8,
      searchTextStyle: TextStyle(color: ink, fontSize: 14).merge(s.searchTextStyle),
      searchPlaceholderStyle: TextStyle(color: palette.hintColor, fontSize: 14).merge(s.searchPlaceholderStyle),
      searchIcon: s.searchIcon ?? Icons.search_rounded,
      actionHeight: s.actionHeight ?? 32,
      actionRadius: s.actionRadius ?? 8,
      actionTextStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600).merge(s.actionTextStyle),
      secondaryActionColor: s.secondaryActionColor ?? ink.withValues(alpha: dark ? 0.1 : 0.06),
      secondaryActionTextColor: s.secondaryActionTextColor ?? ink,
      anchoredMaxHeight: s.anchoredMaxHeight ?? 340,
      anchoredGap: s.anchoredGap ?? 4,
      anchoredMinWidth: s.anchoredMinWidth ?? 220,
      anchoredScreenMargin: s.anchoredScreenMargin ?? 8,
      anchoredBarrierColor: s.anchoredBarrierColor ?? Colors.transparent,
      dialogWidth: s.dialogWidth ?? 440,
      dialogBarrierColor: s.dialogBarrierColor ?? Colors.black.withValues(alpha: 0.32),
      adaptiveBreakpoint: s.adaptiveBreakpoint ?? 720,
      monoTextStyle: TextStyle(
        color: ink,
        fontSize: 14,
        fontFeatures: const [FontFeature.tabularFigures()],
      ).merge(s.monoTextStyle),
      todayColor: s.todayColor ?? accent,
    );
  }

  /// Row extent (height + spacing) in the current presentation.
  double rowExtentFor(BuildContext context) =>
      (UnifiedPickerPresentationScope.isCompactOf(context) ? rowHeight : sheetRowHeight) + rowSpacing;
}

/// Resolves the effective [UnifiedPickerPresentation] ([adaptive] → concrete).
UnifiedPickerPresentation resolveUnifiedPickerPresentation(
  BuildContext context, {
  UnifiedPickerPresentation? override,
}) {
  final theme = UnifiedInputThemeScope.themeDataOf(context);
  final p = override ?? theme.pickerPresentation ?? UnifiedPickerPresentation.bottomSheet;
  if (p != UnifiedPickerPresentation.adaptive) return p;
  final breakpoint = theme.pickerSurfaceStyle?.adaptiveBreakpoint ?? 720;
  return MediaQuery.sizeOf(context).width >= breakpoint
      ? UnifiedPickerPresentation.anchored
      : UnifiedPickerPresentation.bottomSheet;
}

/// Tells picker content how it is presented so it can lay out compactly.
class UnifiedPickerPresentationScope extends InheritedWidget {
  /// Creates a presentation scope.
  const UnifiedPickerPresentationScope({
    super.key,
    required this.presentation,
    required this.maxHeight,
    this.width,
    required super.child,
  });

  /// Concrete presentation (never [UnifiedPickerPresentation.adaptive]).
  final UnifiedPickerPresentation presentation;

  /// Height available to the content.
  final double maxHeight;

  /// Surface width when fixed (anchored / dialog).
  final double? width;

  /// Nearest scope, if any.
  static UnifiedPickerPresentationScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<UnifiedPickerPresentationScope>();

  /// Whether content is in an anchored popover or a dialog (not a bottom sheet).
  static bool isCompactOf(BuildContext context) {
    final p = maybeOf(context)?.presentation;
    return p == UnifiedPickerPresentation.anchored || p == UnifiedPickerPresentation.dialog;
  }

  /// Whether content is in an anchored popover.
  static bool isAnchoredOf(BuildContext context) =>
      maybeOf(context)?.presentation == UnifiedPickerPresentation.anchored;

  @override
  bool updateShouldNotify(UnifiedPickerPresentationScope oldWidget) =>
      presentation != oldWidget.presentation || maxHeight != oldWidget.maxHeight || width != oldWidget.width;
}

/// Popover / dialog card: fill, outline, radius and shadow from [UnifiedResolvedPickerSurface].
class UnifiedPickerSurface extends StatelessWidget {
  /// Creates a picker surface.
  const UnifiedPickerSurface({super.key, required this.child, this.surfaceStyle});

  /// Content.
  final Widget child;

  /// Per-picker overrides.
  final UnifiedPickerSurfaceStyle? surfaceStyle;

  @override
  Widget build(BuildContext context) {
    final s = UnifiedResolvedPickerSurface.of(context, override: surfaceStyle);
    final radius = BorderRadius.circular(s.borderRadius);
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: s.shadows),
      child: Material(
        color: s.backgroundColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: s.borderWidth <= 0 ? BorderSide.none : BorderSide(color: s.borderColor, width: s.borderWidth),
        ),
        child: DefaultTextStyle.merge(style: s.itemTextStyle, child: child),
      ),
    );
  }
}

/// Global rect of the widget that owns [context], in [overlay] coordinates.
Rect unifiedAnchorRectOf(BuildContext context, RenderBox overlay) {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.hasSize || !box.attached) {
    final c = overlay.size.center(Offset.zero);
    return Rect.fromCenter(center: c, width: 0, height: 0);
  }
  return box.localToGlobal(Offset.zero, ancestor: overlay) & box.size;
}

/// Opens [builder] in a popover anchored to the widget that owns [context].
///
/// The popover is at least as wide as the anchor ([minWidth] / theme
/// `anchoredMinWidth` for narrow fields), opens below it and flips above when
/// there is more room there. Tap outside or Escape dismisses.
Future<T?> showUnifiedAnchoredPopover<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double? width,
  double? minWidth,
  double? maxHeight,
  UnifiedPickerSurfaceStyle? surfaceStyle,
  bool barrierDismissible = true,
  bool wrapSurface = true,
  Rect? anchorRect,
}) {
  final navigator = Navigator.of(context);
  final overlay = navigator.overlay!.context.findRenderObject()! as RenderBox;
  final anchor = anchorRect ?? unifiedAnchorRectOf(context, overlay);
  final s = UnifiedResolvedPickerSurface.of(context, override: surfaceStyle);
  final w = math.max(width ?? anchor.width, minWidth ?? s.anchoredMinWidth);
  return navigator.push<T>(
    _UnifiedAnchoredRoute<T>(
      anchor: anchor,
      width: w,
      maxHeight: maxHeight ?? s.anchoredMaxHeight,
      gap: s.anchoredGap,
      margin: s.anchoredScreenMargin,
      barrierTint: s.anchoredBarrierColor,
      dismissible: barrierDismissible,
      label: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      themes: InheritedTheme.capture(from: context, to: navigator.context),
      surfaceStyle: surfaceStyle,
      wrapSurface: wrapSurface,
      builder: builder,
    ),
  );
}

class _UnifiedAnchoredRoute<T> extends PopupRoute<T> {
  _UnifiedAnchoredRoute({
    required this.anchor,
    required this.width,
    required this.maxHeight,
    required this.gap,
    required this.margin,
    required this.barrierTint,
    required this.dismissible,
    required this.label,
    required this.themes,
    required this.surfaceStyle,
    required this.wrapSurface,
    required this.builder,
  });

  final Rect anchor;
  final double width;
  final double maxHeight;
  final double gap;
  final double margin;
  final Color barrierTint;
  final bool dismissible;
  final String label;
  final CapturedThemes themes;
  final UnifiedPickerSurfaceStyle? surfaceStyle;
  final bool wrapSurface;
  final WidgetBuilder builder;

  bool _above = false;

  @override
  Color? get barrierColor => barrierTint;

  @override
  bool get barrierDismissible => dismissible;

  @override
  String? get barrierLabel => label;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 140);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 90);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final top = mq.padding.top + margin;
    final bottom = size.height - math.max(mq.padding.bottom, mq.viewInsets.bottom) - margin;
    final spaceBelow = bottom - anchor.bottom - gap;
    final spaceAbove = anchor.top - gap - top;
    final wanted = math.min(maxHeight, 240.0);
    _above = spaceBelow < wanted && spaceAbove > spaceBelow;
    final h = math.max(80.0, math.min(maxHeight, _above ? spaceAbove : spaceBelow));
    final w = math.min(width, size.width - margin * 2);

    Widget content = Builder(builder: builder);
    if (wrapSurface) content = UnifiedPickerSurface(surfaceStyle: surfaceStyle, child: content);
    content = UnifiedPickerPresentationScope(
      presentation: UnifiedPickerPresentation.anchored,
      maxHeight: h,
      width: w,
      child: content,
    );

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: CustomSingleChildLayout(
        delegate: _AnchoredLayoutDelegate(
          anchor: anchor,
          width: w,
          maxHeight: h,
          gap: gap,
          margin: margin,
          above: _above,
        ),
        child: themes.wrap(content),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeIn);
    return FadeTransition(
      opacity: curved,
      child: AnimatedBuilder(
        animation: curved,
        child: child,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, (1 - curved.value) * (_above ? 6 : -6)),
          child: child,
        ),
      ),
    );
  }
}

class _AnchoredLayoutDelegate extends SingleChildLayoutDelegate {
  const _AnchoredLayoutDelegate({
    required this.anchor,
    required this.width,
    required this.maxHeight,
    required this.gap,
    required this.margin,
    required this.above,
  });

  final Rect anchor;
  final double width;
  final double maxHeight;
  final double gap;
  final double margin;
  final bool above;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints(minWidth: width, maxWidth: width, maxHeight: maxHeight);

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final maxX = math.max(margin, size.width - margin - childSize.width);
    final x = anchor.left.clamp(margin, maxX);
    final y = above ? anchor.top - gap - childSize.height : anchor.bottom + gap;
    final maxY = math.max(margin, size.height - margin - childSize.height);
    return Offset(x, y.clamp(margin, maxY));
  }

  @override
  bool shouldRelayout(_AnchoredLayoutDelegate old) =>
      anchor != old.anchor || width != old.width || maxHeight != old.maxHeight || above != old.above;
}

/// Opens [builder] in a centered dialog styled by [UnifiedResolvedPickerSurface].
Future<T?> showUnifiedPickerDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double? width,
  double? maxHeight,
  UnifiedPickerSurfaceStyle? surfaceStyle,
  bool barrierDismissible = true,
}) {
  final s = UnifiedResolvedPickerSurface.of(context, override: surfaceStyle);
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: s.dialogBarrierColor,
    builder: (ctx) {
      final size = MediaQuery.sizeOf(ctx);
      final w = math.min(width ?? s.dialogWidth, size.width - 32);
      final h = math.min(maxHeight ?? size.height * 0.8, size.height - 48);
      return Center(
        child: SizedBox(
          width: w,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: h),
            child: UnifiedPickerPresentationScope(
              presentation: UnifiedPickerPresentation.dialog,
              maxHeight: h,
              width: w,
              child: UnifiedPickerSurface(surfaceStyle: surfaceStyle, child: Builder(builder: builder)),
            ),
          ),
        ),
      );
    },
  );
}

/// Shared layout for list pickers: bottom sheet (legacy look) or a compact
/// surface body (anchored / dialog) that sizes to its rows.
class UnifiedPickerFrame extends StatelessWidget {
  /// Creates a picker frame.
  const UnifiedPickerFrame({
    super.key,
    required this.header,
    required this.list,
    this.search,
    this.top = const [],
    this.listExtent,
    this.footer,
    this.sheetBackgroundColor,
    this.sheetBorderRadius,
    this.textStyle,
    this.showHeaderWhenAnchored = false,
  });

  /// Title row (sheet / dialog; hidden when anchored unless [showHeaderWhenAnchored]).
  final Widget header;

  /// Optional search box.
  final Widget? search;

  /// Widgets between search and list (suggestions, custom header).
  final List<Widget> top;

  /// Scrollable list / grid; given a bounded height.
  final Widget list;

  /// Natural list height in compact mode (rows × extent); null fills [maxHeight].
  final double? listExtent;

  /// Footer actions.
  final Widget? footer;

  /// Bottom-sheet fill.
  final Color? sheetBackgroundColor;

  /// Bottom-sheet radius.
  final BorderRadius? sheetBorderRadius;

  /// Default text style.
  final TextStyle? textStyle;

  /// Keep the header in anchored popovers.
  final bool showHeaderWhenAnchored;

  @override
  Widget build(BuildContext context) {
    final scope = UnifiedPickerPresentationScope.maybeOf(context);
    final compact = UnifiedPickerPresentationScope.isCompactOf(context);
    if (!compact) {
      return SafeArea(
        child: BottomSheet(
          backgroundColor: sheetBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: sheetBorderRadius ?? BorderRadius.circular(12)),
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
          enableDrag: false,
          onClosing: () {},
          builder: (context) => DefaultTextStyle.merge(
            style: textStyle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [header, ?search, ...top, Expanded(child: list), ?footer],
            ),
          ),
        ),
      );
    }
    final s = UnifiedResolvedPickerSurface.of(context);
    final anchored = scope!.presentation == UnifiedPickerPresentation.anchored;
    return DefaultTextStyle.merge(
      style: textStyle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!anchored || showHeaderWhenAnchored) header,
          if (search != null) Padding(padding: EdgeInsets.fromLTRB(6, anchored ? 6 : 0, 6, 2), child: search),
          ...top,
          Flexible(
            child: SizedBox(
              height: (listExtent ?? scope.maxHeight) + s.padding.vertical,
              child: list,
            ),
          ),
          if (footer != null) ...[
            Divider(height: 1, thickness: 1, color: s.dividerColor),
            footer!,
          ],
        ],
      ),
    );
  }
}

/// One picker row: hover / selected / keyboard-highlight states from the surface style.
class UnifiedPickerRow extends StatelessWidget {
  /// Creates a picker row.
  const UnifiedPickerRow({
    super.key,
    required this.child,
    required this.onTap,
    this.selected = false,
    this.highlighted = false,
    this.leading,
    this.trailing,
    this.showSelectedIcon = true,
  });

  /// Label.
  final Widget child;

  /// Tap handler.
  final VoidCallback? onTap;

  /// Selected state (fill + text color).
  final bool selected;

  /// Keyboard highlight.
  final bool highlighted;

  /// Leading slot (checkbox, avatar).
  final Widget? leading;

  /// Trailing slot; defaults to the selected check icon.
  final Widget? trailing;

  /// Show [UnifiedResolvedPickerSurface.selectedIcon] when selected and no [trailing].
  final bool showSelectedIcon;

  @override
  Widget build(BuildContext context) {
    final s = UnifiedResolvedPickerSurface.of(context);
    final compact = UnifiedPickerPresentationScope.isCompactOf(context);
    final height = compact ? s.rowHeight : s.sheetRowHeight;
    final radius = BorderRadius.circular(compact ? s.rowRadius : 0);
    final fill = selected ? s.rowSelectedColor : (highlighted ? s.rowHighlightColor : s.rowColor);
    final textStyle = selected
        ? s.itemTextStyle.copyWith(color: s.rowSelectedTextColor, fontWeight: FontWeight.w600)
        : s.itemTextStyle;
    final icon = trailing ??
        (selected && showSelectedIcon && s.selectedIcon != null
            ? Icon(s.selectedIcon, size: 16, color: s.rowSelectedTextColor)
            : null);
    Widget row = Material(
      color: fill,
      borderRadius: radius,
      child: InkWell(
        canRequestFocus: false,
        borderRadius: radius,
        hoverColor: s.rowHoverColor,
        highlightColor: s.rowHoverColor,
        splashColor: Colors.transparent,
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: compact ? s.rowPadding : s.rowPadding.add(const EdgeInsets.symmetric(horizontal: 6)),
            child: Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 10)],
                Expanded(
                  child: DefaultTextStyle.merge(
                    style: textStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: IconTheme.merge(data: IconThemeData(color: textStyle.color, size: 18), child: child),
                  ),
                ),
                if (icon != null) ...[const SizedBox(width: 8), icon],
              ],
            ),
          ),
        ),
      ),
    );
    if (s.showRowDividers && !compact) {
      row = DecoratedBox(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: s.dividerColor))),
        child: row,
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? s.padding.left : 0, vertical: s.rowSpacing / 2),
      child: row,
    );
  }
}

/// Small action button for picker footers / search rows.
class UnifiedPickerActionButton extends StatelessWidget {
  /// Creates an action button.
  const UnifiedPickerActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = false,
    this.icon,
  });

  /// Label.
  final String label;

  /// Handler; null disables.
  final VoidCallback? onPressed;

  /// Accent fill (else the secondary tint).
  final bool primary;

  /// Optional leading icon.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final s = UnifiedResolvedPickerSurface.of(context);
    final fg = primary ? s.onAccentColor : s.secondaryActionTextColor;
    final bg = primary ? s.accentColor : s.secondaryActionColor;
    final radius = BorderRadius.circular(s.actionRadius);
    return Opacity(
      opacity: onPressed == null ? 0.45 : 1,
      child: Material(
        color: bg,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: Container(
            height: s.actionHeight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: 15, color: fg), const SizedBox(width: 6)],
                Text(label, style: s.actionTextStyle.copyWith(color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens list-picker content as a bottom sheet / anchored popover / dialog.
///
/// Used by [showUnifiedFieldsPickerBottomSheet]; [sheet] runs the legacy
/// bottom-sheet path.
Future<T?> showUnifiedPickerPresented<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required Future<T?> Function() sheet,
  UnifiedPickerPresentation? presentation,
  UnifiedPickerSurfaceStyle? surfaceStyle,
  bool barrierDismissible = true,
  double? anchoredMinWidth,
  double? dialogWidth,
}) {
  switch (resolveUnifiedPickerPresentation(context, override: presentation)) {
    case UnifiedPickerPresentation.anchored:
      return showUnifiedAnchoredPopover<T>(
        context: context,
        surfaceStyle: surfaceStyle,
        barrierDismissible: barrierDismissible,
        minWidth: anchoredMinWidth,
        builder: (c) => UnifiedPickerModalScope(child: builder(c)),
      );
    case UnifiedPickerPresentation.dialog:
      return showUnifiedPickerDialog<T>(
        context: context,
        surfaceStyle: surfaceStyle,
        barrierDismissible: barrierDismissible,
        width: dialogWidth,
        builder: (c) => UnifiedPickerModalScope(child: builder(c)),
      );
    case UnifiedPickerPresentation.bottomSheet:
    case UnifiedPickerPresentation.adaptive:
      return sheet();
  }
}
