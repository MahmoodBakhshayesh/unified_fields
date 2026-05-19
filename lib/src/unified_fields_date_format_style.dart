import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'persian_jalali_calendar.dart';
import 'unified_date_picker_types.dart';
import 'unified_fields_typography.dart';

/// Display patterns for [UnifiedDateField] / [UnifiedDateRangeField] (Gregorian and Shamsi).
///
/// Set on [UnifiedInputThemeData.dateFormatStyle] for a subtree, or override per field
/// via `dateFormatStyle`. A legacy [DateFormat] on `valueFormat` still wins when set.
@immutable
class UnifiedFieldsDateFormatStyle {
  /// Creates date display patterns for both calendar kinds.
  const UnifiedFieldsDateFormatStyle({
    this.gregorianDayPattern = 'dd,MMM yyyy',
    this.gregorianMonthPattern = 'MMM yyyy',
    this.gregorianYearPattern = 'yyyy',
    this.rangeSeparator = ' – ',
  });

  /// Built-in patterns (Gregorian `dd,MMM yyyy`; Shamsi via [PersianJalaliCalendar]).
  static const standard = UnifiedFieldsDateFormatStyle();

  /// ISO-style Gregorian day: `yyyy-MM-dd`.
  static const isoGregorianDay = UnifiedFieldsDateFormatStyle(
    gregorianDayPattern: 'yyyy-MM-dd',
    gregorianMonthPattern: 'yyyy-MM',
  );

  /// [DateFormat] pattern for a full Gregorian day.
  final String gregorianDayPattern;

  /// [DateFormat] pattern for month granularity.
  final String gregorianMonthPattern;

  /// [DateFormat] pattern for year granularity.
  final String gregorianYearPattern;

  /// Separator between start and end in a date range.
  final String rangeSeparator;

  String _gregorianPattern(UnifiedFieldsDatePickerGranularity granularity) {
    switch (granularity) {
      case UnifiedFieldsDatePickerGranularity.year:
        return gregorianYearPattern;
      case UnifiedFieldsDatePickerGranularity.month:
        return gregorianMonthPattern;
      case UnifiedFieldsDatePickerGranularity.day:
        return gregorianDayPattern;
    }
  }

  /// Formats a single [dateTime] for the given [calendarKind] and [granularity].
  String format(
    DateTime dateTime, {
    required UnifiedFieldsCalendarKind calendarKind,
    UnifiedFieldsDatePickerGranularity granularity =
        UnifiedFieldsDatePickerGranularity.day,
  }) {
    final String raw;
    if (calendarKind == UnifiedFieldsCalendarKind.jalali) {
      raw = PersianJalaliCalendar.formatFieldText(
        dateTime,
        granularity: granularity,
      );
    } else {
      raw = DateFormat(_gregorianPattern(granularity)).format(dateTime);
    }
    return UnifiedFieldsTypography.instance.localizeDigits(
      raw,
      calendarKind: calendarKind,
    );
  }

  /// Formats [range] using [format] for each bound and [rangeSeparator].
  String formatRange(
    DateTimeRange? range, {
    required UnifiedFieldsCalendarKind calendarKind,
    UnifiedFieldsDatePickerGranularity granularity =
        UnifiedFieldsDatePickerGranularity.day,
  }) {
    if (range == null) return '';
    final start = format(
      range.start,
      calendarKind: calendarKind,
      granularity: granularity,
    );
    final end = format(
      range.end,
      calendarKind: calendarKind,
      granularity: granularity,
    );
    return '$start$rangeSeparator$end';
  }
}

/// Field → theme → [UnifiedFieldsDateFormatStyle.standard].
UnifiedFieldsDateFormatStyle resolveUnifiedDateFormatStyle({
  UnifiedFieldsDateFormatStyle? field,
  UnifiedFieldsDateFormatStyle? theme,
}) =>
    field ?? theme ?? UnifiedFieldsDateFormatStyle.standard;
