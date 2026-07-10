import 'package:flutter/material.dart';

import '../unified_date_picker_sheet.dart';
import '../unified_date_picker_types.dart';
import '../unified_fields_date_format_style.dart';
import '../unified_fields_picker_theme.dart';
import '../unified_fields_styled_calendar_picker.dart';
import '../unified_input_date_picker_style.dart';
import '../fields/unified_date_field.dart' show formatUnifiedDateRangeFieldText;
import 'base_unified_field_controller.dart';

/// Controller for [UnifiedDateRangeField].
class UnifiedDateRangeFieldController
    extends BaseUnifiedFieldController<DateTimeRange> {
  /// Creates a date-range field controller.
  UnifiedDateRangeFieldController({
    DateTimeRange? initialValue,
    super.validator,
    super.focusNode,
    this.min,
    this.max,
    this.showCalendarKindToggle = true,
    this.dateFormatStyle,
    this.pickerStyle = UnifiedFieldsDatePickerStyle.verticalMonths,
    this.datePickerStyle,
    this.dayInfoBuilder,
    this.pickerTheme,
    this.calendarKind = UnifiedFieldsCalendarKind.gregorian,
  }) : super(initialValue: initialValue);

  /// Earliest allowed date.
  final DateTime? min;

  /// Latest allowed date.
  final DateTime? max;

  /// Whether the picker sheet shows Gregorian / Shamsi toggle.
  final bool showCalendarKindToggle;

  /// Gregorian / Shamsi display patterns for the field text.
  final UnifiedFieldsDateFormatStyle? dateFormatStyle;

  /// Styled range picker layout.
  final UnifiedFieldsDatePickerStyle pickerStyle;

  /// Picker sheet chrome.
  final UnifiedInputDatePickerStyle? datePickerStyle;

  /// Per-day decorations for styled range pickers.
  final UnifiedFieldsCalendarDayInfoBuilder? dayInfoBuilder;

  /// Extra styling for styled range pickers.
  final UnifiedFieldsPickerTheme? pickerTheme;

  /// Calendar kind for formatting and digit localization.
  final UnifiedFieldsCalendarKind calendarKind;

  String _boundTitle = '';

  /// Sheet title from the bound field ([bindPickerTitle]).
  void bindPickerTitle(String title) {
    _boundTitle = title;
  }

  /// Formats [value] (or [range]) for display.
  String format([DateTimeRange? range]) => formatUnifiedDateRangeFieldText(
        range ?? value,
        calendarKind: calendarKind,
        formatStyle: dateFormatStyle,
      );

  /// Opens the unified date-range picker and updates [value] when confirmed.
  Future<DateTimeRange?> openPicker(
    BuildContext context, {
    String? title,
    DateTimeRange? initialRange,
  }) async {
    final opener = attachedFieldOpener;
    if (opener != null) {
      await opener(context);
      return value;
    }
    final picked = await showUnifiedFieldsDatePickerRange(
      context: context,
      initialRange: initialRange ?? value,
      firstDate: min ?? DateTime(1900),
      lastDate: max ?? DateTime(3000),
      title: title ?? _boundTitle,
      showCalendarKindToggle: showCalendarKindToggle,
      pickerStyle: pickerStyle,
      datePickerStyle: datePickerStyle,
      dayInfoBuilder: dayInfoBuilder,
      pickerTheme: pickerTheme,
    );
    if (picked != null) {
      value = picked;
    }
    return picked;
  }
}
