/// How precise time selection is in unified time pickers.
enum UnifiedFieldsTimeGranularity {
  /// Hour wheel only (0–23).
  hours,

  /// Hour + minute wheels.
  hoursMinutes,

  /// Hour + minute + second wheels.
  hoursMinutesSeconds,
}

/// Visual style for unified time pickers.
enum UnifiedFieldsTimePickerStyle {
  /// Platform [showTimePicker] dial / input.
  dial,

  /// Unified scroll wheels (matches date wheel chrome).
  wheels,
}

/// Visual style for unified duration pickers.
enum UnifiedFieldsDurationPickerStyle {
  /// Legacy Cupertino-style wheels in [UnifiedDurationPickerSheet].
  cupertino,

  /// Unified scroll wheels (matches date wheel chrome).
  wheels,
}
