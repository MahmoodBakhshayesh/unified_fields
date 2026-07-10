import 'package:flutter/material.dart';

import 'unified_date_picker_types.dart';
import 'unified_fields_picker_theme.dart';
import 'unified_fields_styled_calendar_picker.dart';
import 'unified_time_picker_types.dart';
import 'unified_fields_styled_time_picker.dart';

/// Maps [UnifiedFieldsDatePickerStyle] to [UnifiedFieldsStyledCalendarStyle].
UnifiedFieldsStyledCalendarStyle styledCalendarStyleFrom(
  UnifiedFieldsDatePickerStyle style,
) {
  return switch (style) {
    UnifiedFieldsDatePickerStyle.monthGrid =>
      UnifiedFieldsStyledCalendarStyle.monthGrid,
    UnifiedFieldsDatePickerStyle.dateStrip =>
      UnifiedFieldsStyledCalendarStyle.dateStrip,
    UnifiedFieldsDatePickerStyle.verticalMonths =>
      UnifiedFieldsStyledCalendarStyle.verticalMonths,
    UnifiedFieldsDatePickerStyle.cascadeChips =>
      UnifiedFieldsStyledCalendarStyle.cascadeChips,
    UnifiedFieldsDatePickerStyle.heroCalendar =>
      UnifiedFieldsStyledCalendarStyle.heroCalendar,
    _ => UnifiedFieldsStyledCalendarStyle.monthGrid,
  };
}

/// Maps [UnifiedFieldsTimePickerStyle] to [UnifiedFieldsStyledTimePickerStyle].
UnifiedFieldsStyledTimePickerStyle styledTimeStyleFrom(
  UnifiedFieldsTimePickerStyle style,
) {
  return switch (style) {
    UnifiedFieldsTimePickerStyle.rulerTape =>
      UnifiedFieldsStyledTimePickerStyle.rulerTape,
    UnifiedFieldsTimePickerStyle.arcSlider =>
      UnifiedFieldsStyledTimePickerStyle.arcSlider,
    UnifiedFieldsTimePickerStyle.digitPad =>
      UnifiedFieldsStyledTimePickerStyle.digitPad,
    UnifiedFieldsTimePickerStyle.timelineRail =>
      UnifiedFieldsStyledTimePickerStyle.timelineRail,
    UnifiedFieldsTimePickerStyle.clockDial =>
      UnifiedFieldsStyledTimePickerStyle.clockDial,
    _ => UnifiedFieldsStyledTimePickerStyle.rulerTape,
  };
}

/// Single-date styled picker used by [showUnifiedFieldsDatePicker].
Future<DateTime?> showUnifiedFieldsStyledDatePicker({
  required BuildContext context,
  required UnifiedFieldsDatePickerStyle style,
  DateTime? initialDate,
  DateTime? minDate,
  DateTime? maxDate,
  UnifiedFieldsCalendarDayInfoBuilder? dayInfoBuilder,
  String? title,
  bool useRootNavigator = false,
  double breakpoint = 800,
  UnifiedFieldsPickerTheme? pickerTheme,
}) async {
  final selection = await showUnifiedFieldsStyledCalendarPicker(
    context: context,
    style: styledCalendarStyleFrom(style),
    mode: UnifiedFieldsStyledCalendarMode.single,
    initialDate: initialDate,
    minDate: minDate,
    maxDate: maxDate,
    dayInfoBuilder: dayInfoBuilder,
    title: title,
    useRootNavigator: useRootNavigator,
    breakpoint: breakpoint,
    theme: pickerTheme ?? const UnifiedFieldsPickerTheme(),
  );
  return selection?.date;
}

/// Range styled picker used by [showUnifiedFieldsDatePickerRange].
Future<DateTimeRange?> showUnifiedFieldsStyledDatePickerRange({
  required BuildContext context,
  required UnifiedFieldsDatePickerStyle style,
  DateTimeRange? initialRange,
  DateTime? minDate,
  DateTime? maxDate,
  UnifiedFieldsCalendarDayInfoBuilder? dayInfoBuilder,
  String? title,
  bool useRootNavigator = false,
  UnifiedFieldsPickerTheme? pickerTheme,
}) async {
  return showUnifiedFieldsStyledDateRangePicker(
    context: context,
    style: styledCalendarStyleFrom(style),
    initialRange: initialRange,
    minDate: minDate,
    maxDate: maxDate,
    dayInfoBuilder: dayInfoBuilder,
    title: title,
    useRootNavigator: useRootNavigator,
    theme: pickerTheme ?? const UnifiedFieldsPickerTheme(),
  );
}
