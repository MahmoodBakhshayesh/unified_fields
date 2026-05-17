import 'package:flutter/material.dart';

import '../fields/unified_duration_field.dart';
import '../fields/unified_input_brightness.dart';
import '../fields/unified_input_theme.dart';
import 'base_unified_field_controller.dart';

/// Controller for [UnifiedDurationField].
class UnifiedDurationFieldController extends BaseUnifiedFieldController<Duration> {
  /// Creates a duration field controller.
  UnifiedDurationFieldController({
    super.initialValue,
    super.validator,
    super.focusNode,
    this.granularity = UnifiedDurationGranularity.hoursMinutesSeconds,
    this.min,
    this.max,
    this.brightness,
  });

  /// Step granularity shown in the picker sheet.
  final UnifiedDurationGranularity granularity;

  /// Minimum allowed duration.
  final Duration? min;

  /// Maximum allowed duration.
  final Duration? max;

  /// Optional brightness override for the sheet palette.
  final UnifiedInputBrightness? brightness;

  String _boundTitle = 'Duration';

  /// Sheet title from the bound field.
  void bindPickerTitle(String title) {
    _boundTitle = title;
  }

  /// Formats [value] for display.
  String format([Duration? d]) => unifiedFormatDuration(d ?? value ?? Duration.zero, granularity);

  /// Opens the duration picker sheet and updates [value] when confirmed.
  Future<Duration?> openPicker(
    BuildContext context, {
    String? title,
    Duration? initial,
  }) async {
    final opener = attachedFieldOpener;
    if (opener != null) {
      await opener(context);
      return value;
    }
    final palette = brightness != null
        ? UnifiedInputThemeResolver.paletteFor(brightness!)
        : UnifiedInputThemeResolver.resolvePalette(context);

    final result = await showModalBottomSheet<Duration?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.sheetBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => UnifiedDurationPickerSheet(
        title: title ?? _boundTitle,
        palette: palette,
        initial: unifiedClampDuration(initial ?? value ?? Duration.zero, min, max),
        min: min ?? Duration.zero,
        max: max ?? const Duration(hours: 999),
        granularity: granularity,
      ),
    );

    if (result != null) {
      value = unifiedClampDuration(result, min, max);
    }
    return result;
  }
}
