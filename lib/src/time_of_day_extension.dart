import 'package:flutter/material.dart';

import 'int_extension.dart';

/// Conversions on [TimeOfDay] used by the duration / time fields.
extension TimeOfDayExt on TimeOfDay {
  /// Returns the duration from midnight to this time.
  Duration get toDuration => Duration(hours: hour, minutes: minute);
}

/// JSON-style serialization helper for [TimeOfDay].
extension TimeOfDayParsingExtension on TimeOfDay {
  /// `HH:mm` string used as a stable serialization format.
  String? get toJson {
    return '${hour.withTwoNumberFormat}:${minute.withTwoNumberFormat}';
  }
}

/// Lightweight parser for `HH:mm` strings into [TimeOfDay].
class TimeOfDayParser {
  /// Returns a [TimeOfDay] parsed from [stringValue] (`HH:mm`), or null when malformed.
  static TimeOfDay? tryParse(String? stringValue) {
    if (stringValue == null ||
        stringValue.isEmpty ||
        stringValue.contains(':') == false) {
      return null;
    }

    final split = stringValue.split(':');

    if (split.length < 2) return null;

    try {
      return TimeOfDay(hour: int.parse(split[0]), minute: int.parse(split[1]));
    } catch (e) {
      return null;
    }
  }
}
