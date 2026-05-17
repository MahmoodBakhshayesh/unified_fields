import 'package:flutter/material.dart';

import 'unified_date_picker_types.dart';
import 'unified_date_wheel_style.dart';
import 'unified_fields_context.dart';
import 'unified_fields_strings.dart';
import 'unified_hms_wheel_picker_sheet.dart';
import 'unified_time_format.dart';
import 'unified_time_picker_types.dart';

/// Wraps platform and unified wheel time pickers.
class TimePickerUtils {
  TimePickerUtils._();

  /// Opens a time picker ([pickerStyle] dial vs wheels) and returns the selection.
  static Future<UnifiedFieldsPickedTime?> show(
    BuildContext context, {
    String? title,
    TimeOfDay? initialTime,
    int initialSecond = 0,
    TimePickerEntryMode timePickerEntryMode = TimePickerEntryMode.dial,
    UnifiedFieldsTimePickerStyle pickerStyle = UnifiedFieldsTimePickerStyle.dial,
    UnifiedFieldsTimeGranularity granularity = UnifiedFieldsTimeGranularity.hoursMinutes,
    bool showCalendarKindToggle = true,
    UnifiedFieldsCalendarKind initialCalendarKind = UnifiedFieldsCalendarKind.gregorian,
    UnifiedFieldsDateWheelStyle? wheelStyle,
    ValueChanged<UnifiedFieldsCalendarKind>? onConfirmedCalendarKind,
  }) async {
    if (pickerStyle == UnifiedFieldsTimePickerStyle.wheels) {
      return showUnifiedFieldsTimePicker(
        context: context,
        title: title,
        initialTime: initialTime ?? TimeOfDay.now(),
        initialSecond: initialSecond,
        granularity: granularity,
        showCalendarKindToggle: showCalendarKindToggle,
        initialCalendarKind: initialCalendarKind,
        wheelStyle: wheelStyle,
        onConfirmedCalendarKind: onConfirmedCalendarKind,
      );
    }
    final mat = MaterialLocalizations.of(context);
    final initial = initialTime ?? TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: title,
      confirmText: mat.okButtonLabel,
      cancelText: mat.cancelButtonLabel,
      initialEntryMode: timePickerEntryMode,
      hourLabelText: UnifiedFieldsStrings.instance.hourLabel,
      minuteLabelText: UnifiedFieldsStrings.instance.minuteLabel,
    );
    if (picked == null) return null;
    return UnifiedFieldsPickedTime.fromTimeOfDay(picked, second: initialSecond);
  }
}

/// Opens unified scroll-wheel time picker (H / H:M / H:M:S).
Future<UnifiedFieldsPickedTime?> showUnifiedFieldsTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  int initialSecond = 0,
  String? title,
  UnifiedFieldsTimeGranularity granularity = UnifiedFieldsTimeGranularity.hoursMinutes,
  bool showCalendarKindToggle = true,
  UnifiedFieldsCalendarKind initialCalendarKind = UnifiedFieldsCalendarKind.gregorian,
  UnifiedFieldsDateWheelStyle? wheelStyle,
  ValueChanged<UnifiedFieldsCalendarKind>? onConfirmedCalendarKind,
  bool barrierDismissible = true,
}) {
  final showMinutes = granularity != UnifiedFieldsTimeGranularity.hours;
  final showSeconds = granularity == UnifiedFieldsTimeGranularity.hoursMinutesSeconds;

  final sheet = UnifiedFieldsHmsWheelPickerSheet(
    title: title,
    initialHours: initialTime.hour.clamp(0, 23),
    initialMinutes: initialTime.minute.clamp(0, 59),
    initialSeconds: initialSecond.clamp(0, 59),
    maxHours: 23,
    maxMinutes: 59,
    maxSeconds: 59,
    showHours: true,
    showMinutes: showMinutes,
    showSeconds: showSeconds,
    showCalendarKindToggle: showCalendarKindToggle,
    initialCalendarKind: initialCalendarKind,
    wheelStyle: wheelStyle,
    onConfirmedCalendarKind: onConfirmedCalendarKind,
  );

  Future<UnifiedFieldsHmsPick?> present() {
    if (context.isDesktop) {
      return showDialog<UnifiedFieldsHmsPick>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (ctx) => Dialog(
          clipBehavior: Clip.antiAlias,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 420, maxHeight: MediaQuery.sizeOf(ctx).height * 0.92),
            child: sheet,
          ),
        ),
      );
    }
    return showModalBottomSheet<UnifiedFieldsHmsPick>(
      context: context,
      isScrollControlled: true,
      isDismissible: barrierDismissible,
      enableDrag: false,
      useSafeArea: true,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: sheet,
      ),
    );
  }

  return present().then((pick) {
    if (pick == null) return null;
    return UnifiedFieldsPickedTime(hour: pick.hours, minute: pick.minutes, second: pick.seconds);
  });
}
