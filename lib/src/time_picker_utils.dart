import 'package:flutter/material.dart';

/// Wraps [showTimePicker] without app-specific l10n (uses [MaterialLocalizations] + English fallbacks).
class TimePickerUtils {
  static Future<TimeOfDay?> show(
    BuildContext context, {
    String? title,
    TimeOfDay? initialTime,
    TimePickerEntryMode timePickerEntryMode = TimePickerEntryMode.dial,
  }) {
    final mat = MaterialLocalizations.of(context);
    return showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      helpText: title,
      confirmText: mat.okButtonLabel,
      cancelText: mat.cancelButtonLabel,
      initialEntryMode: timePickerEntryMode,
      hourLabelText: 'Hour',
      minuteLabelText: 'Minute',
    );
  }
}
