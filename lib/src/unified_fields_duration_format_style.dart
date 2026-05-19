import 'package:flutter/foundation.dart';

import 'unified_date_picker_types.dart';
import 'unified_duration_columns.dart';
import 'unified_fields_typography.dart';

/// Display style for [UnifiedDurationField] colon-separated parts.
///
/// Set on [UnifiedInputThemeData.durationFormatStyle] or override per field.
/// Digit localization (Gregorian vs Shamsi) still follows [UnifiedFieldsCalendarKind].
@immutable
class UnifiedFieldsDurationFormatStyle {
  /// Creates duration display formatting options.
  const UnifiedFieldsDurationFormatStyle({
    this.partSeparator = ':',
    this.yearMinWidth = 1,
    this.partMinWidth = 2,
  });

  /// Colon-separated parts with zero-padded units (default field display).
  static const standard = UnifiedFieldsDurationFormatStyle();

  /// Separator between column parts (default `:`).
  final String partSeparator;

  /// Minimum width for the year column when present.
  final int yearMinWidth;

  /// Minimum width for non-year columns.
  final int partMinWidth;

  /// Formats [duration] using [columns] and optional [calendarKind] for digits.
  String format(
    Duration duration,
    List<UnifiedFieldsDurationColumn> columns, {
    UnifiedFieldsCalendarKind? calendarKind,
  }) {
    final parts = decomposeUnifiedDuration(duration, columns);
    final buffer = <String>[];
    for (var i = 0; i < columns.length; i++) {
      final col = columns[i];
      final v = parts[i];
      final minWidth =
          col == UnifiedFieldsDurationColumn.year ? yearMinWidth : partMinWidth;
      buffer.add(v.toString().padLeft(minWidth, '0'));
    }
    final joined = buffer.join(partSeparator);
    return UnifiedFieldsTypography.instance.localizeDigits(
      joined,
      calendarKind: calendarKind,
    );
  }
}

/// Field → theme → [UnifiedFieldsDurationFormatStyle.standard].
UnifiedFieldsDurationFormatStyle resolveUnifiedDurationFormatStyle({
  UnifiedFieldsDurationFormatStyle? field,
  UnifiedFieldsDurationFormatStyle? theme,
}) =>
    field ?? theme ?? UnifiedFieldsDurationFormatStyle.standard;
