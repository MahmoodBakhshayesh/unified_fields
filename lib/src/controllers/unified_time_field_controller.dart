import 'package:flutter/material.dart';

import '../time_picker_utils.dart';
import 'base_unified_field_controller.dart';

/// Controller for [UnifiedTimeOfDayField].
class UnifiedTimeOfDayFieldController extends BaseUnifiedFieldController<TimeOfDay> {
  /// Creates a time-of-day controller.
  UnifiedTimeOfDayFieldController({
    super.initialValue,
    super.validator,
    super.focusNode,
    this.timePickerEntryMode = TimePickerEntryMode.dial,
  });

  /// Entry mode for the platform time picker.
  final TimePickerEntryMode timePickerEntryMode;

  String _boundTitle = '';

  /// Sheet title from the bound field.
  void bindPickerTitle(String title) {
    _boundTitle = title;
  }

  /// Opens the time picker and updates [value] when confirmed.
  Future<TimeOfDay?> openPicker(
    BuildContext context, {
    String? title,
    TimeOfDay? initialTime,
  }) async {
    final opener = attachedFieldOpener;
    if (opener != null) {
      await opener(context);
      return value;
    }
    final picked = await TimePickerUtils.show(
      context,
      title: title ?? _boundTitle,
      initialTime: initialTime ?? value ?? TimeOfDay.now(),
      timePickerEntryMode: timePickerEntryMode,
    );
    if (picked != null) {
      value = picked;
    }
    return picked;
  }
}
