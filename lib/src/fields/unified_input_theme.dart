import 'package:flutter/material.dart';

import 'unified_input_brightness.dart';
import 'unified_input_palette.dart';
import 'unified_input_theme_data.dart';

export 'unified_input_theme_data.dart';

/// Optional inherited scope for brightness, palette, disabled/placeholder chrome, picker sheets, and default suffix icons.
class UnifiedInputThemeScope extends InheritedWidget {
  /// Creates a scope; only [child] is required. Pass [data] and/or legacy overrides.
  const UnifiedInputThemeScope({
    super.key,
    this.data,
    this.brightnessOverride,
    this.paletteOverride,
    required super.child,
  });

  /// Theme overrides for this subtree.
  final UnifiedInputThemeData? data;

  /// Legacy: prefer [UnifiedInputThemeData.brightnessOverride] on [data].
  final UnifiedInputBrightness? brightnessOverride;

  /// Legacy: prefer [UnifiedInputThemeData.paletteOverride] on [data].
  final UnifiedInputPalette? paletteOverride;

  /// Effective merged theme (legacy constructor args + [data]).
  UnifiedInputThemeData get effectiveData {
    final base = data ?? const UnifiedInputThemeData();
    if (brightnessOverride == null && paletteOverride == null) return base;
    return base.merge(
      UnifiedInputThemeData(
        brightnessOverride: brightnessOverride,
        paletteOverride: paletteOverride,
      ),
    );
  }

  /// Returns the closest scope in the widget tree, if any.
  static UnifiedInputThemeScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UnifiedInputThemeScope>();
  }

  /// Resolved theme data from the closest scope, or defaults.
  static UnifiedInputThemeData themeDataOf(BuildContext context) {
    return maybeOf(context)?.effectiveData ?? const UnifiedInputThemeData();
  }

  @override
  bool updateShouldNotify(covariant UnifiedInputThemeScope oldWidget) {
    return data != oldWidget.data ||
        brightnessOverride != oldWidget.brightnessOverride ||
        paletteOverride != oldWidget.paletteOverride;
  }
}

/// Resolve palette + brightness used by unified fields.
class UnifiedInputThemeResolver {
  UnifiedInputThemeResolver._();

  /// Picks brightness from scope or [Theme.of].
  static UnifiedInputBrightness inferBrightness(BuildContext context) {
    final theme = UnifiedInputThemeScope.themeDataOf(context);
    if (theme.brightnessOverride != null) return theme.brightnessOverride!;
    return Theme.of(context).brightness == Brightness.dark
        ? UnifiedInputBrightness.dark
        : UnifiedInputBrightness.light;
  }

  /// Resolves the active palette for [context].
  static UnifiedInputPalette resolvePalette(BuildContext context) {
    final theme = UnifiedInputThemeScope.themeDataOf(context);
    if (theme.paletteOverride != null) return theme.paletteOverride!;
    return paletteFor(inferBrightness(context));
  }

  /// Returns the default palette for the given brightness.
  static UnifiedInputPalette paletteFor(UnifiedInputBrightness b) {
    switch (b) {
      case UnifiedInputBrightness.light:
        return UnifiedInputPalette.light();
      case UnifiedInputBrightness.dark:
        return UnifiedInputPalette.dark();
    }
  }

  /// Picker / wheel sheet surface color.
  static Color resolvePickerSheetBackground(
    BuildContext context, {
    UnifiedInputPalette? palette,
  }) {
    final theme = UnifiedInputThemeScope.themeDataOf(context);
    if (theme.pickerSheetBackgroundColor != null) {
      return theme.pickerSheetBackgroundColor!;
    }
    final p = palette ?? resolvePalette(context);
    return Theme.of(context).bottomSheetTheme.backgroundColor ??
        p.sheetBackground;
  }

  /// Default [IconData] for a field suffix when the widget does not supply one.
  static IconData defaultSuffixIconData(
    BuildContext context,
    UnifiedInputFieldSuffixKind kind,
  ) {
    final icons = UnifiedInputThemeScope.themeDataOf(
      context,
    ).defaultSuffixIcons;
    switch (kind) {
      case UnifiedInputFieldSuffixKind.date:
        return icons?.date ?? Icons.calendar_today_outlined;
      case UnifiedInputFieldSuffixKind.time:
        return icons?.time ?? Icons.schedule_outlined;
      case UnifiedInputFieldSuffixKind.duration:
        return icons?.duration ?? Icons.timer_outlined;
      case UnifiedInputFieldSuffixKind.picker:
        return icons?.picker ?? Icons.arrow_drop_down;
      case UnifiedInputFieldSuffixKind.multiPicker:
        return icons?.multiPicker ?? Icons.arrow_drop_down;
    }
  }

  /// Builds a default suffix [Icon] using [palette.fieldTextColor].
  static Widget defaultSuffixIcon(
    BuildContext context,
    UnifiedInputFieldSuffixKind kind,
    UnifiedInputPalette palette,
  ) {
    return Icon(
      defaultSuffixIconData(context, kind),
      color: suffixIconColor(context, palette),
    );
  }

  static UnifiedInputThemeData _theme(BuildContext context) =>
      UnifiedInputThemeScope.themeDataOf(context);

  static Color _withOpacity(Color color, double opacity) =>
      color.withValues(alpha: opacity.clamp(0.0, 1.0));

  /// Label color for disabled fields.
  static Color disabledLabelColor(
    BuildContext context,
    UnifiedInputPalette palette, {
    Color? base,
  }) {
    final theme = _theme(context);
    final color = theme.disabledLabelColor ?? base ?? palette.labelColor;
    return _withOpacity(color, theme.disabledLabelOpacity ?? 0.45);
  }

  /// Label color for locked fields.
  static Color lockedLabelColor(
    BuildContext context,
    UnifiedInputPalette palette, {
    Color? base,
  }) {
    final theme = _theme(context);
    final color = theme.lockedLabelColor ?? base ?? palette.labelColor;
    return _withOpacity(color, theme.lockedLabelOpacity ?? 0.55);
  }

  /// Input text color for disabled fields.
  static Color disabledFieldColor(
    BuildContext context,
    UnifiedInputPalette palette, {
    Color? base,
  }) {
    final theme = _theme(context);
    final color = theme.disabledFieldColor ?? base ?? palette.fieldTextColor;
    return _withOpacity(color, theme.disabledFieldOpacity ?? 0.45);
  }

  /// Input text color for locked fields.
  static Color lockedFieldColor(
    BuildContext context,
    UnifiedInputPalette palette, {
    Color? base,
  }) {
    final theme = _theme(context);
    final color = theme.lockedFieldColor ?? base ?? palette.fieldTextColor;
    return _withOpacity(color, theme.lockedFieldOpacity ?? 0.55);
  }

  /// Body background opacity when disabled.
  static double disabledFieldBackgroundOpacity(BuildContext context) =>
      _theme(context).disabledFieldBackgroundOpacity ?? 0.55;

  /// Body background opacity when locked.
  static double lockedFieldBackgroundOpacity(BuildContext context) =>
      _theme(context).lockedFieldBackgroundOpacity ?? 0.65;

  /// Placeholder [TextStyle] for enabled / disabled states.
  static TextStyle placeholderStyle(
    BuildContext context,
    UnifiedInputPalette palette, {
    required bool disabled,
    double? fontSize,
  }) {
    final theme = _theme(context);
    final color = theme.placeholderColor ?? palette.hintColor;
    final opacity = disabled
        ? (theme.placeholderOpacityWhenDisabled ?? theme.placeholderOpacity ?? 0.45)
        : (theme.placeholderOpacity ?? 1.0);
    return TextStyle(
      color: _withOpacity(color, opacity),
      fontSize: fontSize,
    );
  }

  /// Required-field marker icon.
  static Widget requiredIcon(
    BuildContext context,
    UnifiedInputPalette palette, {
    Color? fallbackColor,
  }) {
    final theme = _theme(context);
    return Icon(
      theme.requiredIcon ?? Icons.star_rate_rounded,
      color: theme.requiredIconColor ?? fallbackColor ?? Colors.red,
      size: theme.requiredIconSize ?? 8,
    );
  }

  /// Default validation color when the field does not override it.
  static Color validationColor(
    BuildContext context,
    UnifiedInputPalette palette,
  ) =>
      _theme(context).validationColor ?? palette.validationColor;

  /// Clear-button icon color.
  static Color clearButtonColor(
    BuildContext context,
    UnifiedInputPalette palette,
  ) =>
      _theme(context).clearButtonColor ?? palette.fieldTextColor;

  /// State suffix icon color (lock, disabled, visibility).
  static Color suffixIconColor(
    BuildContext context,
    UnifiedInputPalette palette,
  ) {
    final theme = _theme(context);
    final color = theme.suffixIconColor ?? palette.fieldTextColor;
    return _withOpacity(color, theme.suffixIconOpacity ?? 0.7);
  }

  /// Loading spinner color on fields.
  static Color loadingIndicatorColor(BuildContext context) =>
      _theme(context).loadingIndicatorColor ??
      Theme.of(context).colorScheme.primary;
}

