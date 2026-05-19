import 'package:flutter/material.dart';

import '../unified_date_picker_sheet.dart';
import '../fields/unified_date_field.dart' show formatUnifiedDateFieldText;
import 'base_unified_field_controller.dart';

/// Controller for [UnifiedDateField] — value, formatting, calendar kind, picker.
class UnifiedDateFieldController extends BaseUnifiedFieldController<DateTime> {
  /// Creates a date field controller.
  UnifiedDateFieldController({
    DateTime? initialValue,
    super.validator,
    super.focusNode,
    this.valueFormat,
    this.pickerGranularity = UnifiedFieldsDatePickerGranularity.day,
    UnifiedFieldsCalendarKind calendarKind =
        UnifiedFieldsCalendarKind.gregorian,
    this.min,
    this.max,
    this.showCalendarKindToggle = true,
    this.mode = DatePickerEntryMode.calendar,
    this.pickerStyle = UnifiedFieldsDatePickerStyle.calendar,
    this.wheelStyle,
    this.datePickerStyle,
    this.showWeekdayInWheel = true,
  }) : _calendarKind = calendarKind,
       super(initialValue: initialValue);

  /// Format passed to [formatUnifiedDateFieldText].
  final Object? valueFormat;

  /// Picker granularity (day / month / year).
  final UnifiedFieldsDatePickerGranularity pickerGranularity;

  /// Earliest selectable date.
  final DateTime? min;

  /// Latest selectable date.
  final DateTime? max;

  /// Whether the picker sheet shows Gregorian / Shamsi toggle.
  final bool showCalendarKindToggle;

  /// Forwarded to the platform date picker.
  final DatePickerEntryMode mode;

  /// Calendar grid vs scroll-wheel picker UI.
  final UnifiedFieldsDatePickerStyle pickerStyle;

  /// Optional wheel chrome when [pickerStyle] is [UnifiedFieldsDatePickerStyle.wheels].
  final UnifiedFieldsDateWheelStyle? wheelStyle;

  /// Picker sheet chrome (calendar + header); merged with theme [datePickerStyle].
  final UnifiedInputDatePickerStyle? datePickerStyle;

  /// Show weekday names in the day wheel column.
  final bool showWeekdayInWheel;

  UnifiedFieldsCalendarKind _calendarKind;

  /// Active calendar kind for the picker UI.
  UnifiedFieldsCalendarKind get calendarKind => _calendarKind;

  String _boundTitle = '';

  /// Switches preferred calendar display (picker UI).
  set calendarKind(UnifiedFieldsCalendarKind kind) {
    if (_calendarKind == kind) return;
    _calendarKind = kind;
    notifyListeners();
  }

  /// Formats [value] (or [date]) for display in the field.
  String format([DateTime? date]) {
    return formatUnifiedDateFieldText(
      date ?? value,
      valueFormat,
      granularity: pickerGranularity,
      calendarKind: calendarKind,
    );
  }

  /// Sheet title from the bound field ([bindPickerTitle]).
  void bindPickerTitle(String title) {
    _boundTitle = title;
  }

  /// Opens the unified date picker and updates [value] when confirmed.
  Future<DateTime?> openPicker(
    BuildContext context, {
    String? title,
    DateTime? initialDate,
  }) async {
    final opener = attachedFieldOpener;
    if (opener != null) {
      await opener(context);
      return value;
    }
    final picked = await showUnifiedFieldsDatePicker(
      context: context,
      initialDate: initialDate ?? value ?? DateTime.now(),
      firstDate: min ?? DateTime(1900),
      lastDate: max ?? DateTime(3000),
      title: title ?? _boundTitle,
      showCalendarKindToggle: showCalendarKindToggle,
      granularity: pickerGranularity,
      pickerStyle: pickerStyle,
      initialCalendarKind: calendarKind,
      wheelStyle: wheelStyle,
      datePickerStyle: datePickerStyle,
      showWeekdayInWheel: showWeekdayInWheel,
      onConfirmedCalendarKind: (kind) => calendarKind = kind,
    );
    if (picked != null) {
      value = picked;
    }
    return picked;
  }
}
