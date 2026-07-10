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
  /// Legacy month grid with Jalali/Gregorian toggle (default).
  calendar,

  /// Legacy Cupertino-style scroll wheels with Jalali support.
  wheels,

  /// Paged month grid with animated slide transitions, swipe + chevrons.
  monthGrid,

  /// Horizontal filmstrip of day cards (pricing / events per day).
  dateStrip,

  /// Continuous vertically-scrolling months (booking style).
  verticalMonths,

  /// Drill-down chips: year → month → day with breadcrumb.
  cascadeChips,

  /// Big animated day readout over a swipeable one-week strip.
  heroCalendar,
}

/// Whether [style] uses the creative [UnifiedFieldsStyledCalendarPicker].
extension UnifiedFieldsDatePickerStyleX on UnifiedFieldsDatePickerStyle {
  bool get isStyledPicker => switch (this) {
        UnifiedFieldsDatePickerStyle.monthGrid ||
        UnifiedFieldsDatePickerStyle.dateStrip ||
        UnifiedFieldsDatePickerStyle.verticalMonths ||
        UnifiedFieldsDatePickerStyle.cascadeChips ||
        UnifiedFieldsDatePickerStyle.heroCalendar =>
          true,
        _ => false,
      };
}
