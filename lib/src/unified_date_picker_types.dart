/// Calendar systems supported by unified date pickers.
enum UnifiedFieldsCalendarKind {
  /// Gregorian calendar (default).
  gregorian,

  /// Shamsi (Jalali) calendar.
  jalali,
}

/// How precise date selection is in unified date pickers.
enum UnifiedFieldsDatePickerGranularity {
  /// Full day (year + month + day wheels or calendar grid).
  day,

  /// Month + year only.
  month,

  /// Year only.
  year,
}

/// Visual style for single-date [showUnifiedFieldsDatePicker].
enum UnifiedFieldsDatePickerStyle {
  /// Month grid / list UI (default).
  calendar,

  /// Cupertino-style scroll wheels (columns depend on [UnifiedFieldsDatePickerGranularity]).
  wheels,
}
