import 'unified_date_picker_types.dart';
import 'unified_fields_duration_format_style.dart';
import 'unified_fields_typography.dart';

/// How [UnifiedDurationField] formats and edits values when [pickerColumns] is null.
enum UnifiedDurationGranularity {
  /// Hours only (`HH`).
  hours,

  /// `HH:MM`.
  hoursMinutes,

  /// `HH:MM:SS`.
  hoursMinutesSeconds,

  /// Total `MM:SS` (minutes can exceed 59). Prefer [hoursMinutes] for new code.
  minutesSeconds,
}

/// One scroll column in a unified duration wheel picker (largest → smallest, left to right).
enum UnifiedFieldsDurationColumn {
  /// Calendar year (365 days each for total duration).
  year,

  /// Calendar month (30 days each).
  month,

  /// Week (7 days each).
  week,

  /// Day (24 hours each).
  day,

  /// Hour.
  hour,

  /// Minute.
  minute,

  /// Second.
  second,
}

/// Common column presets (largest unit first).
abstract final class UnifiedFieldsDurationColumnPresets {
  /// Year, month, day.
  static const List<UnifiedFieldsDurationColumn> yearsMonthsDays = [
    UnifiedFieldsDurationColumn.year,
    UnifiedFieldsDurationColumn.month,
    UnifiedFieldsDurationColumn.day,
  ];

  /// Year, week, day, hour.
  static const List<UnifiedFieldsDurationColumn> yearsWeeksDaysHours = [
    UnifiedFieldsDurationColumn.year,
    UnifiedFieldsDurationColumn.week,
    UnifiedFieldsDurationColumn.day,
    UnifiedFieldsDurationColumn.hour,
  ];

  /// Hour, minute, second.
  static const List<UnifiedFieldsDurationColumn> hoursMinutesSeconds = [
    UnifiedFieldsDurationColumn.hour,
    UnifiedFieldsDurationColumn.minute,
    UnifiedFieldsDurationColumn.second,
  ];

  /// Minute, second (minutes may exceed 59).
  static const List<UnifiedFieldsDurationColumn> minutesSeconds = [
    UnifiedFieldsDurationColumn.minute,
    UnifiedFieldsDurationColumn.second,
  ];
}

/// Seconds contributed by one unit of [column] when composing a [Duration].
int unifiedDurationColumnUnitSeconds(UnifiedFieldsDurationColumn column) {
  switch (column) {
    case UnifiedFieldsDurationColumn.year:
      return const Duration(days: 365).inSeconds;
    case UnifiedFieldsDurationColumn.month:
      return const Duration(days: 30).inSeconds;
    case UnifiedFieldsDurationColumn.week:
      return const Duration(days: 7).inSeconds;
    case UnifiedFieldsDurationColumn.day:
      return const Duration(days: 1).inSeconds;
    case UnifiedFieldsDurationColumn.hour:
      return const Duration(hours: 1).inSeconds;
    case UnifiedFieldsDurationColumn.minute:
      return const Duration(minutes: 1).inSeconds;
    case UnifiedFieldsDurationColumn.second:
      return 1;
  }
}

/// Maps legacy [UnifiedDurationGranularity] to wheel columns.
List<UnifiedFieldsDurationColumn> unifiedDurationColumnsFromGranularity(
  UnifiedDurationGranularity granularity,
) {
  switch (granularity) {
    case UnifiedDurationGranularity.hours:
      return [UnifiedFieldsDurationColumn.hour];
    case UnifiedDurationGranularity.hoursMinutes:
      return UnifiedFieldsDurationColumnPresets.hoursMinutesSeconds.sublist(
        0,
        2,
      );
    case UnifiedDurationGranularity.hoursMinutesSeconds:
      return UnifiedFieldsDurationColumnPresets.hoursMinutesSeconds;
    case UnifiedDurationGranularity.minutesSeconds:
      return UnifiedFieldsDurationColumnPresets.minutesSeconds;
  }
}

/// Resolves explicit [pickerColumns] or falls back to [granularity].
List<UnifiedFieldsDurationColumn> resolveUnifiedDurationColumns({
  List<UnifiedFieldsDurationColumn>? pickerColumns,
  UnifiedDurationGranularity? granularity,
}) {
  if (pickerColumns != null && pickerColumns.isNotEmpty) {
    return List<UnifiedFieldsDurationColumn>.from(pickerColumns);
  }
  return unifiedDurationColumnsFromGranularity(
    granularity ?? UnifiedDurationGranularity.hoursMinutesSeconds,
  );
}

bool _hasColumnAfter(
  List<UnifiedFieldsDurationColumn> columns,
  UnifiedFieldsDurationColumn column,
  Set<UnifiedFieldsDurationColumn> finer,
) {
  final i = columns.indexOf(column);
  if (i < 0) return false;
  for (var j = i + 1; j < columns.length; j++) {
    if (finer.contains(columns[j])) return true;
  }
  return false;
}

/// Maximum index (inclusive) for [column] given [maxDuration] and full [columns] set.
///
/// Calendar-style columns use fixed ranges on the wheel (year 0…999, month 0…11,
/// week 0…4) so pickers are not squeezed to `0` when [maxDuration] is smaller than
/// one year. The composed total is still clamped to [maxDuration] on confirm.
int unifiedDurationColumnMaxIndex(
  UnifiedFieldsDurationColumn column,
  List<UnifiedFieldsDurationColumn> columns,
  Duration maxDuration,
) {
  final totalSecs = maxDuration.inSeconds;
  final unit = unifiedDurationColumnUnitSeconds(column);

  switch (column) {
    case UnifiedFieldsDurationColumn.year:
      return 999;
    case UnifiedFieldsDurationColumn.month:
      if (_hasColumnAfter(columns, column, {
            UnifiedFieldsDurationColumn.week,
            UnifiedFieldsDurationColumn.day,
            UnifiedFieldsDurationColumn.hour,
            UnifiedFieldsDurationColumn.minute,
            UnifiedFieldsDurationColumn.second,
          }) ||
          columns.contains(UnifiedFieldsDurationColumn.year)) {
        return 11;
      }
      return (totalSecs ~/ unit).clamp(0, 99);
    case UnifiedFieldsDurationColumn.week:
      if (_hasColumnAfter(columns, column, {
            UnifiedFieldsDurationColumn.day,
            UnifiedFieldsDurationColumn.hour,
            UnifiedFieldsDurationColumn.minute,
            UnifiedFieldsDurationColumn.second,
          }) ||
          columns.contains(UnifiedFieldsDurationColumn.month) ||
          columns.contains(UnifiedFieldsDurationColumn.year)) {
        return 4;
      }
      return (totalSecs ~/ unit).clamp(0, 999);
    case UnifiedFieldsDurationColumn.day:
      if (_hasColumnAfter(columns, column, {
        UnifiedFieldsDurationColumn.hour,
      })) {
        return 30.clamp(0, (totalSecs ~/ unit).clamp(0, 999));
      }
      return (totalSecs ~/ unit).clamp(0, 999);
    case UnifiedFieldsDurationColumn.hour:
      if (_hasColumnAfter(columns, column, {
        UnifiedFieldsDurationColumn.minute,
        UnifiedFieldsDurationColumn.second,
      })) {
        return 23;
      }
      return (totalSecs ~/ unit).clamp(0, 999);
    case UnifiedFieldsDurationColumn.minute:
      if (_hasColumnAfter(columns, column, {
        UnifiedFieldsDurationColumn.second,
      })) {
        return 59;
      }
      return (totalSecs ~/ unit).clamp(0, 99999);
    case UnifiedFieldsDurationColumn.second:
      return 59;
  }
}

/// Splits [duration] into one value per [columns] entry (largest unit first).
List<int> decomposeUnifiedDuration(
  Duration duration,
  List<UnifiedFieldsDurationColumn> columns,
) {
  var remaining = duration.inSeconds;
  return [
    for (final col in columns)
      () {
        final unit = unifiedDurationColumnUnitSeconds(col);
        final v = remaining ~/ unit;
        remaining %= unit;
        return v;
      }(),
  ];
}

/// Builds a [Duration] from parallel [values] and [columns].
Duration composeUnifiedDuration(
  List<UnifiedFieldsDurationColumn> columns,
  List<int> values,
) {
  assert(columns.length == values.length);
  var secs = 0;
  for (var i = 0; i < columns.length; i++) {
    secs += values[i] * unifiedDurationColumnUnitSeconds(columns[i]);
  }
  return Duration(seconds: secs);
}

/// Formats [duration] as colon-separated parts matching [columns].
String formatUnifiedDurationColumns(
  Duration duration,
  List<UnifiedFieldsDurationColumn> columns, {
  UnifiedFieldsCalendarKind? calendarKind,
  UnifiedFieldsDurationFormatStyle? formatStyle,
}) {
  return (formatStyle ?? UnifiedFieldsDurationFormatStyle.standard).format(
    duration,
    columns,
    calendarKind: calendarKind,
  );
}

/// Parses colon-separated text built by [formatUnifiedDurationColumns].
Duration? tryParseUnifiedDurationColumns(
  String raw,
  List<UnifiedFieldsDurationColumn> columns,
) {
  final text = UnifiedFieldsTypography.fromPersianDigits(raw.trim());
  if (text.isEmpty) return null;
  final parts = text.split(':');
  if (parts.length != columns.length) return null;
  try {
    final values = [for (final p in parts) int.parse(p)];
    return composeUnifiedDuration(columns, values);
  } catch (_) {
    return null;
  }
}
