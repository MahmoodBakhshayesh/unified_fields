import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

/// Jalali / Persian solar (Shamsi) calendar helpers for date-picker grids.
abstract final class PersianJalaliCalendar {
  /// Number of days in the given Jalali year/month.
  static int monthLength(int jalaliYear, int jalaliMonth) =>
      Jalali(jalaliYear, jalaliMonth, 1).monthLength;

  /// Local midnights from Jalali day.
  static DateTime toGregorianDate(int jalaliYear, int jalaliMonth, int jalaliDay) {
    return DateUtils.dateOnly(Jalali(jalaliYear, jalaliMonth, jalaliDay).toDateTime());
  }

  /// Converts a [DateTime] (Gregorian) into a [Jalali] date.
  static Jalali fromGregorian(DateTime g) => Jalali.fromDateTime(g);

  /// Every Jalali month that intersects `[first, last]` (local midnights).
  static List<(int jy, int jm)> enumerateMonthsBetween(DateTime first, DateTime last) {
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

  /// English month names (matches [JalaliFormatter.mNFn]); [month] is 1…12.
  static String englishMonthName(int month) {
    return JalaliFormatter(Jalali(1400, month, 1)).mNFn;
  }
}
