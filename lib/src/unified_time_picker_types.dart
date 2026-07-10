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

  /// Horizontal measuring-tape strips for hours and minutes.
  rulerTape,

  /// Semicircular hour arc + minute slider + ±1 steppers.
  arcSlider,

  /// Tappable 0–23 hour chips + minute slider.
  digitPad,

  /// Vertical day/night rail with draggable handle + minute chips.
  timelineRail,

  /// Analog dual-ring 24h clock face.
  clockDial,
}

/// Whether [style] uses [UnifiedFieldsStyledTimePicker].
extension UnifiedFieldsTimePickerStyleX on UnifiedFieldsTimePickerStyle {
  bool get isStyledPicker => switch (this) {
        UnifiedFieldsTimePickerStyle.rulerTape ||
        UnifiedFieldsTimePickerStyle.arcSlider ||
        UnifiedFieldsTimePickerStyle.digitPad ||
        UnifiedFieldsTimePickerStyle.timelineRail ||
        UnifiedFieldsTimePickerStyle.clockDial =>
          true,
        _ => false,
      };
}

/// Visual style for unified duration pickers.
enum UnifiedFieldsDurationPickerStyle {
  /// Legacy Cupertino-style wheels in [UnifiedDurationPickerSheet].
  cupertino,

  /// Unified scroll wheels (matches date wheel chrome).
  wheels,
}
