import 'package:flutter/material.dart';

import '../fields/unified_duration_field.dart';
import '../unified_fields_duration_format_style.dart';
import '../fields/unified_input_brightness.dart';
import '../unified_date_picker_types.dart';
import '../unified_date_wheel_style.dart';
import '../unified_fields_strings.dart';
import 'base_unified_field_controller.dart';

/// Controller for [UnifiedDurationField].
class UnifiedDurationFieldController
    extends BaseUnifiedFieldController<Duration> {
  /// Creates a duration field controller.
  UnifiedDurationFieldController({
    super.initialValue,
    super.validator,
    super.focusNode,
    this.granularity = UnifiedDurationGranularity.hoursMinutesSeconds,
    this.pickerColumns,
    this.pickerStyle = UnifiedFieldsDurationPickerStyle.wheels,
    UnifiedFieldsCalendarKind calendarKind =
        UnifiedFieldsCalendarKind.gregorian,
    this.min,
    this.max,
    this.brightness,
    this.wheelStyle,
    this.showCalendarKindToggle = true,
    this.durationFormatStyle,
  }) : _calendarKind = calendarKind;

  /// Step granularity when [pickerColumns] is null.
  final UnifiedDurationGranularity granularity;

  /// Custom wheel columns (overrides [granularity] when set).
  final List<UnifiedFieldsDurationColumn>? pickerColumns;

  /// Cupertino vs unified styled wheels.
  final UnifiedFieldsDurationPickerStyle pickerStyle;

  /// Minimum allowed duration.
  final Duration? min;

  /// Maximum allowed duration.
  final Duration? max;

  /// Optional brightness override for the sheet palette.
  final UnifiedInputBrightness? brightness;

  /// Optional wheel chrome.
  final UnifiedFieldsDateWheelStyle? wheelStyle;

  /// Whether the picker shows Gregorian / Shamsi digit toggle.
  final bool showCalendarKindToggle;

  /// Colon-separated display style for the field text.
  final UnifiedFieldsDurationFormatStyle? durationFormatStyle;

  UnifiedFieldsCalendarKind _calendarKind;

  /// Active digit / label mode for display and wheels.
  UnifiedFieldsCalendarKind get calendarKind => _calendarKind;

  set calendarKind(UnifiedFieldsCalendarKind kind) {
    if (_calendarKind == kind) return;
    _calendarKind = kind;
    notifyListeners();
  }

  List<UnifiedFieldsDurationColumn> get _columns =>
      resolveUnifiedDurationColumns(
        pickerColumns: pickerColumns,
        granularity: granularity,
      );

  String _boundTitle = UnifiedFieldsStrings.instance.defaultDurationTitle;

  /// Sheet title from the bound field.
  void bindPickerTitle(String title) {
    _boundTitle = title;
  }

  /// Formats [value] for display.
  String format([Duration? d]) => unifiedFormatDuration(
    d ?? value ?? Duration.zero,
    granularity: granularity,
    pickerColumns: _columns,
    calendarKind: calendarKind,
    formatStyle: durationFormatStyle,
  );

  /// Opens the duration picker sheet and updates [value] when confirmed.
  Future<Duration?> openPicker(
    BuildContext context, {
    String? title,
    Duration? initial,
  }) async {
    final opener = attachedFieldOpener;
    if (opener != null) {
      await opener(context);
      return value;
    }

    final result = await showUnifiedFieldsDurationPicker(
      context: context,
      title: title ?? _boundTitle,
      initial: unifiedClampDuration(
        initial ?? value ?? Duration.zero,
        min,
        max,
      ),
      min: min ?? Duration.zero,
      max: max ?? const Duration(hours: 999),
      granularity: granularity,
      pickerColumns: pickerColumns,
      pickerStyle: pickerStyle,
      showCalendarKindToggle: showCalendarKindToggle,
      initialCalendarKind: calendarKind,
      wheelStyle: wheelStyle,
      onConfirmedCalendarKind: (k) => calendarKind = k,
    );

    if (result != null) {
      value = unifiedClampDuration(result, min, max);
    }
    return result;
  }
}
