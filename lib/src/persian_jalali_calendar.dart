import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import 'unified_date_picker_types.dart';

/// Jalali / Persian solar (Shamsi) calendar helpers for date-picker grids.
abstract final class PersianJalaliCalendar {
  /// Number of days in the given Jalali year/month.
  static int monthLength(int jalaliYear, int jalaliMonth) =>
      Jalali(jalaliYear, jalaliMonth, 1).monthLength;

  /// Local midnights from Jalali day.
  static DateTime toGregorianDate(
    int jalaliYear,
    int jalaliMonth,
    int jalaliDay,
  ) {
    return DateUtils.dateOnly(
      Jalali(jalaliYear, jalaliMonth, jalaliDay).toDateTime(),
    );
  }

  /// Converts a [DateTime] (Gregorian) into a [Jalali] date.
  static Jalali fromGregorian(DateTime g) => Jalali.fromDateTime(g);

  /// Every Jalali month that intersects `[first, last]` (local midnights).
  static List<(int jy, int jm)> enumerateMonthsBetween(
    DateTime first,
    DateTime last,
  ) {
    final a = DateUtils.dateOnly(first);
    final b = DateUtils.dateOnly(last);
    if (a.isAfter(b)) return [];

    final start = Jalali.fromDateTime(a);
    final end = Jalali.fromDateTime(b);
    final out = <(int, int)>[];

    var jy = start.year;
    var jm = start.month;
    while (jy < end.year || (jy == end.year && jm <= end.month)) {
      out.add((jy, jm));
      jm++;
      if (jm > 12) {
        jm = 1;
        jy++;
      }
    }
    return out;
  }

  /// Persian month names (matches [JalaliFormatter.mN]); [month] is 1…12.
  static String persianMonthName(int month) {
    return JalaliFormatter(Jalali(1400, month, 1)).mN;
  }

  /// Persian weekday name (شنبه … جمعه) for a Jalali date.
  static String persianWeekdayName(
    int jalaliYear,
    int jalaliMonth,
    int jalaliDay,
  ) {
    return JalaliFormatter(Jalali(jalaliYear, jalaliMonth, jalaliDay)).wN;
  }

  /// Day column label for wheel picker: `"$day $weekday"` in Farsi.
  static String jalaliDayWheelLabel(
    int jalaliYear,
    int jalaliMonth,
    int jalaliDay,
  ) {
    return '$jalaliDay ${persianWeekdayName(jalaliYear, jalaliMonth, jalaliDay)}';
  }

  /// Formats a Gregorian [dateTime] for display in Shamsi mode (mirrors default Gregorian patterns).
  static String formatFieldText(
    DateTime dateTime, {
    UnifiedFieldsDatePickerGranularity granularity =
        UnifiedFieldsDatePickerGranularity.day,
  }) {
    final j = fromGregorian(DateUtils.dateOnly(dateTime));
    switch (granularity) {
      case UnifiedFieldsDatePickerGranularity.year:
        return '${j.year}';
      case UnifiedFieldsDatePickerGranularity.month:
        return '${persianMonthName(j.month)} ${j.year}';
      case UnifiedFieldsDatePickerGranularity.day:
        return '${j.day},${persianMonthName(j.month)} ${j.year}';
    }
  }
}
