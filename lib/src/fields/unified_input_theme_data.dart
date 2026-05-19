import 'package:flutter/material.dart';

import 'unified_input_brightness.dart';
import 'unified_input_decoration.dart';
import 'unified_input_field_defaults.dart';
import 'unified_input_palette.dart';
import '../phone/unified_input_phone_style.dart';
import '../unified_fields_date_format_style.dart';
import '../unified_fields_duration_format_style.dart';
import '../unified_input_date_picker_style.dart';
import 'unified_base_picker_sheet_style.dart';
import 'unified_picker_sheet_modal_settings.dart';
import 'unified_picker_sheet_style.dart';

/// Default suffix icons for unified field types when the field does not set its own.
@immutable
class UnifiedInputDefaultSuffixIcons {
  /// Creates optional per-field-type suffix icons ([IconData] rendered with field chrome).
  const UnifiedInputDefaultSuffixIcons({
    this.date,
    this.time,
    this.duration,
    this.phone,
    this.picker,
    this.multiPicker,
  });

  /// Shown on [UnifiedDateField] when no custom suffix is set.
  final IconData? date;

  /// Shown on [UnifiedTimeOfDayField] when no custom suffix is set.
  final IconData? time;

  /// Shown on [UnifiedDurationField] when no custom suffix is set.
  final IconData? duration;

  /// Shown on [UnifiedPhoneField] when no custom suffix is set.
  final IconData? phone;

  /// Shown on single-select picker fields when no custom suffix is set.
  final IconData? picker;

  /// Shown on multi-select picker fields when no custom suffix is set.
  final IconData? multiPicker;
}

/// Optional theme overrides for a [UnifiedInputThemeScope] subtree.
@immutable
class UnifiedInputThemeData {
  /// All fields are optional; omitted values fall back to palette / [Theme].
  const UnifiedInputThemeData({
    this.brightnessOverride,
    this.paletteOverride,
    this.disabledLabelColor,
    this.disabledLabelOpacity,
    this.disabledFieldColor,
    this.disabledFieldOpacity,
    this.disabledFieldBackgroundOpacity,
    this.lockedLabelColor,
    this.lockedLabelOpacity,
    this.lockedFieldColor,
    this.lockedFieldOpacity,
    this.lockedFieldBackgroundOpacity,
    this.placeholderColor,
    this.placeholderOpacity,
    this.placeholderOpacityWhenDisabled,
    this.requiredIcon,
    this.requiredIconColor,
    this.requiredIconSize,
    this.validationColor,
    this.clearButtonColor,
    this.suffixIconColor,
    this.suffixIconOpacity,
    this.loadingIndicatorColor,
    this.pickerSheetBackgroundColor,
    this.basePickerSheetStyle,
    this.pickerSheetModalSettings,
    this.pickerHeaderStyle,
    this.multiPickerCheckboxStyle,
    this.defaultSuffixIcons,
    this.phoneStyle,
    this.datePickerStyle,
    this.dateFormatStyle,
    this.durationFormatStyle,
    this.fieldDecorationSet,
    this.fieldDefaults,
  });

  /// When non-null, replaces inferred brightness from [Theme.of(context)].
  final UnifiedInputBrightness? brightnessOverride;

  /// Full palette override (skips built-in light/dark palettes).
  final UnifiedInputPalette? paletteOverride;

  /// Label color when the field is disabled; defaults to palette label color.
  final Color? disabledLabelColor;

  /// Label opacity when disabled (0–1); defaults to `0.45`.
  final double? disabledLabelOpacity;

  /// Input text color when disabled; defaults to [UnifiedInputPalette.fieldTextColor].
  final Color? disabledFieldColor;

  /// Input text opacity when disabled (0–1); defaults to `0.45`.
  final double? disabledFieldOpacity;

  /// Body background opacity when disabled (0–1); defaults to `0.55`.
  final double? disabledFieldBackgroundOpacity;

  /// Label color when [UnifiedBaseTextField.locked]; defaults to palette label color.
  final Color? lockedLabelColor;

  /// Label opacity when locked (0–1); defaults to `0.55`.
  final double? lockedLabelOpacity;

  /// Input text color when locked; defaults to [UnifiedInputPalette.fieldTextColor].
  final Color? lockedFieldColor;

  /// Input text opacity when locked (0–1); defaults to `0.55`.
  final double? lockedFieldOpacity;

  /// Body background opacity when locked (0–1); defaults to `0.65`.
  final double? lockedFieldBackgroundOpacity;

  /// Placeholder / hint color; defaults to [UnifiedInputPalette.hintColor].
  final Color? placeholderColor;

  /// Placeholder opacity when the field is enabled (0–1); defaults to `0.72`.
  final double? placeholderOpacity;

  /// Placeholder opacity when disabled (0–1); defaults to `0.45`.
  final double? placeholderOpacityWhenDisabled;

  /// Required-field asterisk icon; defaults to [Icons.star_rate_rounded].
  final IconData? requiredIcon;

  /// Required-field icon color; defaults to `Colors.red` (label-in-row) or palette label (column label).
  final Color? requiredIconColor;

  /// Required-field icon size; defaults to `8`.
  final double? requiredIconSize;

  /// Default validation / inline error color when the field does not set one.
  final Color? validationColor;

  /// Clear (“x”) suffix button color.
  final Color? clearButtonColor;

  /// Color for state suffix icons (lock, disabled, password toggle).
  final Color? suffixIconColor;

  /// Opacity for state suffix icons (0–1); defaults to `0.7`.
  final double? suffixIconOpacity;

  /// Loading spinner on fields; defaults to [ThemeData.colorScheme.primary].
  final Color? loadingIndicatorColor;

  /// Background for date/time/duration picker sheets and wheel chrome.
  ///
  /// When null, uses [ThemeData.bottomSheetTheme.backgroundColor] then
  /// [UnifiedInputPalette.sheetBackground].
  final Color? pickerSheetBackgroundColor;

  /// Package-default suffix icons per field type.
  final UnifiedInputDefaultSuffixIcons? defaultSuffixIcons;

  /// Shared picker sheet padding, radius, and panel colors (list + wheel pickers).
  final UnifiedBasePickerSheetStyle? basePickerSheetStyle;

  /// Default [showModalBottomSheet] flags for picker fields.
  final UnifiedPickerSheetModalSettings? pickerSheetModalSettings;

  /// Picker sheet title bar padding, colors, and title style.
  final UnifiedInputPickerHeaderStyle? pickerHeaderStyle;

  /// Multi-picker row checkbox colors and corner radius.
  final UnifiedInputMultiPickerCheckboxStyle? multiPickerCheckboxStyle;

  /// Dial-code box, flag size, and invalid dial-code display for [UnifiedPhoneField].
  final UnifiedInputPhoneStyle? phoneStyle;

  /// Calendar / wheel date picker chrome for [UnifiedDateField] and [showUnifiedFieldsDatePicker].
  final UnifiedInputDatePickerStyle? datePickerStyle;

  /// Default Gregorian / Shamsi display patterns for date and date-range fields.
  final UnifiedFieldsDateFormatStyle? dateFormatStyle;

  /// Default colon-separated display for [UnifiedDurationField].
  final UnifiedFieldsDurationFormatStyle? durationFormatStyle;

  /// Default per-state field decorations for the whole subtree (merged under each field).
  final UnifiedInputDecorationSet? fieldDecorationSet;

  /// Default [UnifiedBaseTextField] layout and behavior (`labelMode`, `height`, borders, …).
  final UnifiedInputFieldDefaults? fieldDefaults;

  /// Returns a copy with the given fields replaced.
  UnifiedInputThemeData merge(UnifiedInputThemeData? other) {
    if (other == null) return this;
    return UnifiedInputThemeData(
      brightnessOverride: other.brightnessOverride ?? brightnessOverride,
      paletteOverride: other.paletteOverride ?? paletteOverride,
      disabledLabelColor: other.disabledLabelColor ?? disabledLabelColor,
      disabledLabelOpacity: other.disabledLabelOpacity ?? disabledLabelOpacity,
      disabledFieldColor: other.disabledFieldColor ?? disabledFieldColor,
      disabledFieldOpacity: other.disabledFieldOpacity ?? disabledFieldOpacity,
      disabledFieldBackgroundOpacity:
          other.disabledFieldBackgroundOpacity ?? disabledFieldBackgroundOpacity,
      lockedLabelColor: other.lockedLabelColor ?? lockedLabelColor,
      lockedLabelOpacity: other.lockedLabelOpacity ?? lockedLabelOpacity,
      lockedFieldColor: other.lockedFieldColor ?? lockedFieldColor,
      lockedFieldOpacity: other.lockedFieldOpacity ?? lockedFieldOpacity,
      lockedFieldBackgroundOpacity:
          other.lockedFieldBackgroundOpacity ?? lockedFieldBackgroundOpacity,
      placeholderColor: other.placeholderColor ?? placeholderColor,
      placeholderOpacity: other.placeholderOpacity ?? placeholderOpacity,
      placeholderOpacityWhenDisabled:
          other.placeholderOpacityWhenDisabled ?? placeholderOpacityWhenDisabled,
      requiredIcon: other.requiredIcon ?? requiredIcon,
      requiredIconColor: other.requiredIconColor ?? requiredIconColor,
      requiredIconSize: other.requiredIconSize ?? requiredIconSize,
      validationColor: other.validationColor ?? validationColor,
      clearButtonColor: other.clearButtonColor ?? clearButtonColor,
      suffixIconColor: other.suffixIconColor ?? suffixIconColor,
      suffixIconOpacity: other.suffixIconOpacity ?? suffixIconOpacity,
      loadingIndicatorColor: other.loadingIndicatorColor ?? loadingIndicatorColor,
      pickerSheetBackgroundColor:
          other.pickerSheetBackgroundColor ?? pickerSheetBackgroundColor,
      basePickerSheetStyle: basePickerSheetStyle?.merge(other.basePickerSheetStyle) ??
          other.basePickerSheetStyle,
      pickerSheetModalSettings:
          pickerSheetModalSettings?.merge(other.pickerSheetModalSettings) ??
              other.pickerSheetModalSettings,
      pickerHeaderStyle: other.pickerHeaderStyle ?? pickerHeaderStyle,
      multiPickerCheckboxStyle:
          other.multiPickerCheckboxStyle ?? multiPickerCheckboxStyle,
      defaultSuffixIcons: other.defaultSuffixIcons ?? defaultSuffixIcons,
      phoneStyle: other.phoneStyle ?? phoneStyle,
      datePickerStyle: other.datePickerStyle?.merge(datePickerStyle) ??
          datePickerStyle ??
          other.datePickerStyle,
      dateFormatStyle: other.dateFormatStyle ?? dateFormatStyle,
      durationFormatStyle: other.durationFormatStyle ?? durationFormatStyle,
      fieldDecorationSet: other.fieldDecorationSet ?? fieldDecorationSet,
      fieldDefaults: other.fieldDefaults ?? fieldDefaults,
    );
  }
}

/// Which built-in field suffix icon to resolve from [UnifiedInputThemeData].
enum UnifiedInputFieldSuffixKind {
  /// Date field picker affordance.
  date,

  /// Time-of-day field.
  time,

  /// Duration field.
  duration,

  /// Single-select picker.
  picker,

  /// Multi-select picker.
  multiPicker,

  /// Phone field.
  phone,
}
