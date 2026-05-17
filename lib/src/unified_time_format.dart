import 'package:flutter/material.dart';

import 'unified_date_picker_types.dart';
import 'unified_fields_typography.dart';
import 'unified_time_picker_types.dart';

/// Picked time from a unified wheel / format helper (supports seconds).
@immutable
class UnifiedFieldsPickedTime {
  /// Creates a picked time.
  const UnifiedFieldsPickedTime({
    required this.hour,
    required this.minute,
    this.second = 0,
  });

  /// Hour (0–23).
  final int hour;

  /// Minute (0–59).
  final int minute;

  /// Second (0–59).
  final int second;

  /// Converts to [TimeOfDay] (seconds are not represented on [TimeOfDay]).
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));

  /// From [TimeOfDay] with optional [second].
  factory UnifiedFieldsPickedTime.fromTimeOfDay(TimeOfDay t, {int second = 0}) =>
      UnifiedFieldsPickedTime(hour: t.hour, minute: t.minute, second: second);
}

/// Formats [time] for display in unified time fields.
String formatUnifiedTimeOfDayText(
  TimeOfDay? time, {
  UnifiedFieldsTimeGranularity granularity = UnifiedFieldsTimeGranularity.hoursMinutes,
  int second = 0,
  UnifiedFieldsCalendarKind? calendarKind,
}) {
  if (time == null) return '';
  final raw = _formatRaw(time.hour, time.minute, second, granularity);
  return UnifiedFieldsTypography.instance.localizeDigits(raw, calendarKind: calendarKind);
}

/// Formats [picked] for display.
String formatUnifiedPickedTimeText(
  UnifiedFieldsPickedTime? picked, {
  UnifiedFieldsTimeGranularity granularity = UnifiedFieldsTimeGranularity.hoursMinutes,
  UnifiedFieldsCalendarKind? calendarKind,
}) {
  if (picked == null) return '';
  final raw = _formatRaw(picked.hour, picked.minute, picked.second, granularity);
  return UnifiedFieldsTypography.instance.localizeDigits(raw, calendarKind: calendarKind);
}

String _formatRaw(int hour, int minute, int second, UnifiedFieldsTimeGranularity granularity) {
  String two(int n) => n.clamp(0, 99).toString().padLeft(2, '0');
  switch (granularity) {
    case UnifiedFieldsTimeGranularity.hours:
      return two(hour);
    case UnifiedFieldsTimeGranularity.hoursMinutes:
      return '${two(hour)}:${two(minute)}';
    case UnifiedFieldsTimeGranularity.hoursMinutesSeconds:
      return '${two(hour)}:${two(minute)}:${two(second)}';
  }
}

/// Parses display text into [UnifiedFieldsPickedTime].
UnifiedFieldsPickedTime? tryParseUnifiedTimeText(
  String? raw,
  UnifiedFieldsTimeGranularity granularity,
) {
  if (raw == null) return null;
  final s = UnifiedFieldsTypography.fromPersianDigits(raw.trim());
  if (s.isEmpty) return null;
  final parts = s.split(':');
  try {
    switch (granularity) {
      case UnifiedFieldsTimeGranularity.hours:
        if (parts.length != 1) return null;
        return UnifiedFieldsPickedTime(hour: int.parse(parts[0]), minute: 0);
      case UnifiedFieldsTimeGranularity.hoursMinutes:
        if (parts.length != 2) return null;
        return UnifiedFieldsPickedTime(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      case UnifiedFieldsTimeGranularity.hoursMinutesSeconds:
        if (parts.length != 3) return null;
        return UnifiedFieldsPickedTime(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
          second: int.parse(parts[2]),
        );
    }
  } catch (_) {
    return null;
  }
}

/// Legacy [TimeOfDayParser] bridge.
TimeOfDay? tryParseTimeOfDayText(String? raw, UnifiedFieldsTimeGranularity granularity) =>
    tryParseUnifiedTimeText(raw, granularity)?.toTimeOfDay();
