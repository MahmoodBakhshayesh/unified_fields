import 'unified_date_picker_types.dart';
import 'unified_duration_columns.dart';

/// Package-wide UI strings for sheets, pickers, and platform dialogs.
///
/// Override before building widgets (e.g. in `main()`):
///
/// ```dart
/// UnifiedFieldsStrings.instance = const UnifiedFieldsStrings(
///   cancel: 'لغو',
///   confirm: 'تأیید',
/// );
/// ```
class UnifiedFieldsStrings {
  /// Creates a string bundle with English defaults.
  const UnifiedFieldsStrings({
    this.cancel = 'Cancel',
    this.confirm = 'Confirm',
    this.now = 'Now',
    this.clear = 'Clear',
    this.done = 'Done',
    this.suggestion = 'Suggestion',
    this.pickPrefix = 'Pick',
    this.date = 'Date',
    this.dayLabel = 'Day',
    this.monthLabel = 'Month',
    this.yearLabel = 'Year',
    this.shamsiYearLabel = 'سال',
    this.shamsiMonthLabel = 'ماه',
    this.shamsiDayLabel = 'روز',
    this.jumpToMonthYear = 'Jump to month / year',
    this.pickDateRangeHint = 'Select start and end dates',
    this.calendarGregorian = 'Gregorian',
    this.calendarShamsi = 'Shamsi (Jalali)',
    this.hourLabel = 'Hour',
    this.minuteLabel = 'Minute',
    this.secondLabel = 'Second',
    this.shamsiHourLabel = 'ساعت',
    this.shamsiMinuteLabel = 'دقیقه',
    this.shamsiSecondLabel = 'ثانیه',
    this.weekLabel = 'Week',
    this.shamsiWeekLabel = 'هفته',
    this.defaultDurationTitle = 'Duration',
    this.asyncQueryTypeToFetch = 'Start typing to fetch',
    this.asyncQueryNoResults = 'No results',
  });

  /// Active strings used by unified_fields widgets.
  static UnifiedFieldsStrings instance = const UnifiedFieldsStrings();

  /// Cancel action (sheets, dialogs, tooltips).
  final String cancel;

  /// Confirm / apply action.
  final String confirm;

  /// Quick-pick "now" chip on styled time pickers.
  final String now;

  /// Clear selection in picker sheet headers.
  final String clear;

  /// Done action (e.g. duration sheet).
  final String done;

  /// Badge on pinned suggestion rows.
  final String suggestion;

  /// Prefix for multi-picker sheet titles (`Pick Country` → `pickPrefix` + label).
  final String pickPrefix;

  /// Generic date label when no title is provided.
  final String date;

  /// Day column header on wheel date picker.
  final String dayLabel;

  /// Month column header on wheel date picker.
  final String monthLabel;

  /// Year column header on wheel / jump UI.
  final String yearLabel;

  /// Shamsi wheel column: year (سال).
  final String shamsiYearLabel;

  /// Shamsi wheel column: month (ماه).
  final String shamsiMonthLabel;

  /// Shamsi wheel column: day (روز).
  final String shamsiDayLabel;

  /// Wheel column headers for [kind] (Gregorian vs Shamsi).
  ({String year, String month, String day}) wheelColumnHeaders(
    UnifiedFieldsCalendarKind kind,
  ) {
    if (kind == UnifiedFieldsCalendarKind.jalali) {
      return (
        year: shamsiYearLabel,
        month: shamsiMonthLabel,
        day: shamsiDayLabel,
      );
    }
    return (year: yearLabel, month: monthLabel, day: dayLabel);
  }

  /// Title for month/year jump controls.
  final String jumpToMonthYear;

  /// Hint when picking a range without start/end yet.
  final String pickDateRangeHint;

  /// Gregorian calendar toggle label.
  final String calendarGregorian;

  /// Shamsi (Jalali) calendar toggle label.
  final String calendarShamsi;

  /// Time picker hour wheel label.
  final String hourLabel;

  /// Time picker minute wheel label.
  final String minuteLabel;

  /// Time / duration second wheel label.
  final String secondLabel;

  /// Shamsi hour column (ساعت).
  final String shamsiHourLabel;

  /// Shamsi minute column (دقیقه).
  final String shamsiMinuteLabel;

  /// Shamsi second column (ثانیه).
  final String shamsiSecondLabel;

  /// Week column header.
  final String weekLabel;

  /// Shamsi week column (هفته).
  final String shamsiWeekLabel;

  /// Column header for [column] on duration wheels.
  String durationColumnHeader(
    UnifiedFieldsDurationColumn column,
    UnifiedFieldsCalendarKind kind,
  ) {
    if (kind == UnifiedFieldsCalendarKind.jalali) {
      return switch (column) {
        UnifiedFieldsDurationColumn.year => shamsiYearLabel,
        UnifiedFieldsDurationColumn.month => shamsiMonthLabel,
        UnifiedFieldsDurationColumn.week => shamsiWeekLabel,
        UnifiedFieldsDurationColumn.day => shamsiDayLabel,
        UnifiedFieldsDurationColumn.hour => shamsiHourLabel,
        UnifiedFieldsDurationColumn.minute => shamsiMinuteLabel,
        UnifiedFieldsDurationColumn.second => shamsiSecondLabel,
      };
    }
    return switch (column) {
      UnifiedFieldsDurationColumn.year => yearLabel,
      UnifiedFieldsDurationColumn.month => monthLabel,
      UnifiedFieldsDurationColumn.week => weekLabel,
      UnifiedFieldsDurationColumn.day => dayLabel,
      UnifiedFieldsDurationColumn.hour => hourLabel,
      UnifiedFieldsDurationColumn.minute => minuteLabel,
      UnifiedFieldsDurationColumn.second => secondLabel,
    };
  }

  /// H:M:S wheel headers for [kind].
  ({String hour, String minute, String second}) hmsWheelColumnHeaders(
    UnifiedFieldsCalendarKind kind,
  ) {
    if (kind == UnifiedFieldsCalendarKind.jalali) {
      return (
        hour: shamsiHourLabel,
        minute: shamsiMinuteLabel,
        second: shamsiSecondLabel,
      );
    }
    return (hour: hourLabel, minute: minuteLabel, second: secondLabel);
  }

  /// Fallback duration picker title when none is passed.
  final String defaultDurationTitle;

  /// [AsyncQueryPickerSheetWidget] hint when the query is shorter than the threshold.
  final String asyncQueryTypeToFetch;

  /// Shown when a query fetch returns an empty list.
  final String asyncQueryNoResults;

  /// Multi-picker sheet header: `"$pickPrefix $label"` trimmed.
  String multiPickerTitle(String label) {
    final t = '$pickPrefix $label'.trim();
    return t.isEmpty ? pickPrefix : t;
  }
}

/// @deprecated Use [UnifiedFieldsStrings.instance].
@Deprecated('Use UnifiedFieldsStrings.instance')
abstract final class UnifiedDatePickerStrings {
  /// @deprecated Use [UnifiedFieldsStrings.instance.cancel].
  @Deprecated('Use UnifiedFieldsStrings.instance.cancel')
  static String get cancel => UnifiedFieldsStrings.instance.cancel;

  /// @deprecated Use [UnifiedFieldsStrings.instance.confirm].
  @Deprecated('Use UnifiedFieldsStrings.instance.confirm')
  static String get confirm => UnifiedFieldsStrings.instance.confirm;

  /// @deprecated Use [UnifiedFieldsStrings.instance.date].
  @Deprecated('Use UnifiedFieldsStrings.instance.date')
  static String get date => UnifiedFieldsStrings.instance.date;

  /// @deprecated Use [UnifiedFieldsStrings.instance.yearLabel].
  @Deprecated('Use UnifiedFieldsStrings.instance.yearLabel')
  static String get yearLabel => UnifiedFieldsStrings.instance.yearLabel;

  /// @deprecated Use [UnifiedFieldsStrings.instance.jumpToMonthYear].
  @Deprecated('Use UnifiedFieldsStrings.instance.jumpToMonthYear')
  static String get jumpToMonthYear =>
      UnifiedFieldsStrings.instance.jumpToMonthYear;

  /// @deprecated Use [UnifiedFieldsStrings.instance.pickDateRangeHint].
  @Deprecated('Use UnifiedFieldsStrings.instance.pickDateRangeHint')
  static String get pickDateRangeHint =>
      UnifiedFieldsStrings.instance.pickDateRangeHint;

  /// @deprecated Use [UnifiedFieldsStrings.instance.calendarGregorian].
  @Deprecated('Use UnifiedFieldsStrings.instance.calendarGregorian')
  static String get calendarGregorian =>
      UnifiedFieldsStrings.instance.calendarGregorian;

  /// @deprecated Use [UnifiedFieldsStrings.instance.calendarShamsi].
  @Deprecated('Use UnifiedFieldsStrings.instance.calendarShamsi')
  static String get calendarShamsi =>
      UnifiedFieldsStrings.instance.calendarShamsi;
}
