import 'package:flutter/material.dart';

import 'unified_field_label_mode.dart';
import 'unified_input_brightness.dart';
import 'unified_input_field_defaults.dart';
import 'unified_input_palette.dart';
import '../phone/unified_input_phone_style.dart';
import 'unified_input_theme_data.dart';
import 'unified_picker_sheet_style.dart';
import 'unified_suffix_icon.dart';
import '../unified_date_picker_types.dart';
import '../unified_fields_typography.dart';

export 'unified_input_field_defaults.dart';
export 'unified_input_label_mode_style.dart';
export 'unified_input_theme_data.dart';
export 'unified_picker_sheet_chrome.dart';
export 'unified_picker_sheet_style.dart';
export 'unified_suffix_icon.dart';
export '../phone/unified_input_phone_style.dart';

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
    Color? pickerSheetBackgroundColor,
  }) {
    if (pickerSheetBackgroundColor != null) {
      return pickerSheetBackgroundColor;
    }
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
      case UnifiedInputFieldSuffixKind.phone:
        return icons?.phone ?? Icons.phone_outlined;
      case UnifiedInputFieldSuffixKind.picker:
        return icons?.picker ?? Icons.arrow_drop_down;
      case UnifiedInputFieldSuffixKind.multiPicker:
        return icons?.multiPicker ?? Icons.arrow_drop_down;
    }
  }

  /// Resolved [UnifiedInputPhoneStyle] for [UnifiedPhoneField] / [UnifiedFlag].
  static UnifiedInputPhoneStyle resolvePhoneStyle(
    BuildContext context, {
    UnifiedInputPhoneStyle? overrides,
    UnifiedInputPalette? palette,
  }) {
    final theme = _theme(context).phoneStyle ?? const UnifiedInputPhoneStyle();
    final p = palette ?? resolvePalette(context);
    return theme.merge(overrides).applyDefaults(p);
  }

  /// Builds a default suffix icon in the standard 32×32 slot.
  static Widget defaultSuffixIcon(
    BuildContext context,
    UnifiedInputFieldSuffixKind kind,
    UnifiedInputPalette palette, {
    VoidCallback? onPressed,
  }) {
    return UnifiedSuffixIconChrome.build(
      icon: defaultSuffixIconData(context, kind),
      color: suffixIconColor(context, palette),
      onPressed: onPressed,
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

  /// Theme placeholder color/opacity only (no typography).
  static TextStyle placeholderStyle(
    BuildContext context,
    UnifiedInputPalette palette, {
    required bool disabled,
    double? fontSize,
  }) {
    return TextStyle(
      color: _placeholderColor(context, palette, disabled: disabled),
      fontSize: fontSize ?? 16,
      fontWeight: FontWeight.w400,
    );
  }

  /// Placeholder [TextStyle]: copies typography from [fieldStyle], applies theme hint
  /// color/opacity, then merges [placeholderOverride] on top.
  static TextStyle resolvePlaceholderStyle(
    BuildContext context,
    UnifiedInputPalette palette, {
    required bool disabled,
    TextStyle? fieldStyle,
    TextStyle? placeholderOverride,
  }) {
    final field = fieldStyle ?? const TextStyle();
    final hintChrome = TextStyle(
      color: _placeholderColor(context, palette, disabled: disabled),
      fontSize: field.fontSize ?? 16,
      fontWeight: field.fontWeight ?? FontWeight.w400,
    );
    var resolved = field.merge(hintChrome);
    if (placeholderOverride != null) {
      resolved = resolved.merge(placeholderOverride);
    }
    return resolved;
  }

  static Color _placeholderColor(
    BuildContext context,
    UnifiedInputPalette palette, {
    required bool disabled,
  }) {
    final theme = _theme(context);
    final color = theme.placeholderColor ?? palette.hintColor;
    final opacity = disabled
        ? (theme.placeholderOpacityWhenDisabled ??
              theme.placeholderOpacity ??
              0.45)
        : (theme.placeholderOpacity ?? 0.72);
    return _withOpacity(color, opacity);
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

  /// Picker sheet header style from [UnifiedInputThemeScope], merged with [override].
  static UnifiedInputPickerHeaderStyle pickerHeaderStyle(
    BuildContext context, {
    UnifiedInputPickerHeaderStyle? override,
  }) {
    final base =
        _theme(context).pickerHeaderStyle ?? const UnifiedInputPickerHeaderStyle();
    return base.merge(override);
  }

  static UnifiedInputPickerHeaderStyle _headerStyle(
    BuildContext context, {
    UnifiedInputPickerHeaderStyle? override,
  }) =>
      pickerHeaderStyle(context, override: override);

  static UnifiedInputMultiPickerCheckboxStyle _checkboxStyle(
    BuildContext context,
  ) =>
      _theme(context).multiPickerCheckboxStyle ??
      const UnifiedInputMultiPickerCheckboxStyle();

  /// Padding for picker sheet headers.
  static EdgeInsetsGeometry pickerHeaderPadding(BuildContext context) =>
      _headerStyle(context).padding ??
      const EdgeInsetsDirectional.fromSTEB(16, 12, 8, 12);

  /// Picker sheet header background.
  static Color pickerHeaderBackgroundColor(
    BuildContext context,
    UnifiedInputPalette palette,
  ) =>
      _headerStyle(context).backgroundColor ?? palette.sheetHeaderBackground;

  /// Picker sheet header title style.
  static TextStyle pickerHeaderTitleStyle(
    BuildContext context,
    UnifiedInputPalette palette,
  ) =>
      _headerStyle(context).titleStyle ??
      TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: palette.labelColor,
      );

  /// Clear button color in picker headers.
  static Color pickerHeaderClearButtonColor(BuildContext context) =>
      _headerStyle(context).clearButtonColor ??
      Theme.of(context).colorScheme.primary;

  /// Help text style in picker headers.
  static TextStyle pickerHeaderHelpTextStyle(
    BuildContext context,
    UnifiedInputPalette palette,
  ) =>
      _headerStyle(context).helpTextStyle ??
      TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: palette.labelColor.withValues(alpha: 0.75),
      );

  /// Multi-picker checkbox style from the active theme scope.
  static UnifiedInputMultiPickerCheckboxStyle multiPickerCheckboxStyle(
    BuildContext context,
  ) =>
      _checkboxStyle(context);

  static UnifiedInputFieldDefaults? _fieldDefaults(BuildContext context) =>
      _theme(context).fieldDefaults;

  /// Effective [UnifiedFieldLabelMode] when the field does not set [labelMode].
  static UnifiedFieldLabelMode? fieldLabelMode(BuildContext context) =>
      _fieldDefaults(context)?.labelMode;

  /// Effective show-clear suffix when the field leaves [UnifiedBaseTextField.showClearButton] null.
  static bool fieldShowClearButton(BuildContext context, {bool? field}) =>
      field ?? _fieldDefaults(context)?.showClearButton ?? false;

  /// Effective inline error strip when [UnifiedBaseTextField.showError] is null.
  static bool fieldShowError(BuildContext context, {bool? field}) =>
      field ?? _fieldDefaults(context)?.showError ?? true;

  /// Effective reset-on-lock when [UnifiedBaseTextField.resetTextWhenLocked] is null.
  static bool fieldResetTextWhenLocked(BuildContext context, {bool? field}) =>
      field ?? _fieldDefaults(context)?.resetTextWhenLocked ?? true;

  /// Effective autovalidate when [UnifiedBaseTextField.autovalidateMode] is null.
  static AutovalidateMode fieldAutovalidateMode(
    BuildContext context, {
    AutovalidateMode? field,
  }) =>
      field ?? _fieldDefaults(context)?.autovalidateMode ?? AutovalidateMode.always;

  /// Effective bidirectional typing when the field leaves the flag null.
  static bool fieldMustResolveTextDirectionByInput(
    BuildContext context, {
    bool? field,
  }) =>
      field ??
      _fieldDefaults(context)?.mustResolveTextDirectionByInput ??
      false;

  /// Effective select-all-on-focus when [UnifiedBaseTextField.selectTextOnFocus] is null.
  static bool fieldSelectTextOnFocus(BuildContext context, {bool? field}) =>
      field ?? _fieldDefaults(context)?.selectTextOnFocus ?? false;

  /// Resolves the field value [TextStyle]: decoration → widget → theme
  /// ([UnifiedInputFieldDefaults.textStyle] or [textStylePersian] when Persian digits apply).
  static TextStyle? fieldTextStyle(
    BuildContext context, {
    UnifiedFieldsCalendarKind? calendarKind,
    bool? usePersianDigits,
    TextStyle? decorationStyle,
    TextStyle? widgetStyle,
  }) {
    final fd = _fieldDefaults(context);
    final typography = UnifiedFieldsTypography.instance;
    final persian = usePersianDigits ??
        typography.shouldUsePersianDigits(calendarKind: calendarKind);
    final TextStyle? themeStyle;
    if (persian) {
      final base = fd?.textStyle;
      final override = fd?.textStylePersian;
      if (base != null && override != null) {
        themeStyle = base.merge(override);
      } else {
        themeStyle = override ?? base;
      }
    } else {
      themeStyle = fd?.textStyle;
    }
    return decorationStyle ?? widgetStyle ?? themeStyle;
  }
}

