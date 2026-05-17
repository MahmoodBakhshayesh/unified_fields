import 'package:flutter/material.dart';

import '../time_picker_utils.dart';
import '../unified_date_picker_types.dart';
import '../unified_date_wheel_style.dart';
import '../unified_time_format.dart';
import '../unified_time_picker_types.dart';
import 'base_unified_field_controller.dart';

/// Controller for [UnifiedTimeOfDayField].
class UnifiedTimeOfDayFieldController
    extends BaseUnifiedFieldController<TimeOfDay> {
  /// Creates a time-of-day controller.
  UnifiedTimeOfDayFieldController({
    super.initialValue,
    super.validator,
    super.focusNode,
    this.timePickerEntryMode = TimePickerEntryMode.dial,
    this.pickerStyle = UnifiedFieldsTimePickerStyle.dial,
    this.granularity = UnifiedFieldsTimeGranularity.hoursMinutes,
    UnifiedFieldsCalendarKind calendarKind =
        UnifiedFieldsCalendarKind.gregorian,
    this.showCalendarKindToggle = true,
    this.wheelStyle,
    int initialSecond = 0,
  }) : _calendarKind = calendarKind,
       _second = initialSecond;

  /// Entry mode for the platform dial picker.
  final TimePickerEntryMode timePickerEntryMode;

  /// Dial vs unified wheels.
  final UnifiedFieldsTimePickerStyle pickerStyle;

  /// Wheel column set (H, H:M, H:M:S).
  final UnifiedFieldsTimeGranularity granularity;

  /// When false, hides Gregorian / Shamsi toggle on wheel picker.
  final bool showCalendarKindToggle;

  /// Optional wheel chrome.
  final UnifiedFieldsDateWheelStyle? wheelStyle;

  /// Seconds when [granularity] is [UnifiedFieldsTimeGranularity.hoursMinutesSeconds].
  int _second;

  UnifiedFieldsCalendarKind _calendarKind;

  /// Active digit / label mode.
  UnifiedFieldsCalendarKind get calendarKind => _calendarKind;

  set calendarKind(UnifiedFieldsCalendarKind kind) {
    if (_calendarKind == kind) return;
    _calendarKind = kind;
    notifyListeners();
  }

  /// Seconds component for H:M:S display.
  int get second => _second;

  set second(int s) {
    final v = s.clamp(0, 59);
    if (_second == v) return;
    _second = v;
    notifyListeners();
  }

  String _boundTitle = '';

  /// Sheet title from the bound field.
  void bindPickerTitle(String title) {
    _boundTitle = title;
  }

  /// Formats [value] for display.
  String format([TimeOfDay? time]) => formatUnifiedTimeOfDayText(
    time ?? value,
    granularity: granularity,
    second: _second,
    calendarKind: calendarKind,
  );

  /// Opens the time picker and updates [value] when confirmed.
  Future<TimeOfDay?> openPicker(
    BuildContext context, {
    String? title,
    TimeOfDay? initialTime,
  }) async {
    final opener = attachedFieldOpener;
    if (opener != null) {
      await opener(context);
      return value;
    }
    final picked = await TimePickerUtils.show(
      context,
      title: title ?? _boundTitle,
      initialTime: initialTime ?? value ?? TimeOfDay.now(),
      initialSecond: _second,
      timePickerEntryMode: timePickerEntryMode,
      pickerStyle: pickerStyle,
      granularity: granularity,
      showCalendarKindToggle: showCalendarKindToggle,
      initialCalendarKind: calendarKind,
      wheelStyle: wheelStyle,
      onConfirmedCalendarKind: (k) => calendarKind = k,
    );
    if (picked != null) {
      value = picked.toTimeOfDay();
      _second = picked.second;
    }
    return picked?.toTimeOfDay();
  }
}
