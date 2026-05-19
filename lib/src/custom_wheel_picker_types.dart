import 'package:flutter/material.dart';

/// How multi-column wheels are arranged in [CustomWheelPickerSheet].
enum CustomWheelPickerWheelLayout {
  /// Columns side by side; each wheel scrolls vertically (default).
  vertical,

  /// Columns stacked; each wheel scrolls horizontally.
  horizontal,
}

/// One scroll wheel column in [CustomWheelPicker] / [CustomWheelPickerSheet].
///
/// Use [CustomWheelPickerColumn.typed] (static) for type-safe options:
///
/// ```dart
/// CustomWheelPickerColumn.typed<int>(
///   options: [1, 2, 3],
///   label: 'Qty',
///   valueToString: (v) => '$v',
/// )
/// ```
class CustomWheelPickerColumn {
  /// Creates a column with [options] and optional label / display builders.
  const CustomWheelPickerColumn({
    required this.options,
    this.label,
    this.valueToString,
    this.itemBuilder,
    this.flex = 1,
    this.equals,
  });

  /// Type-safe column builder.
  static CustomWheelPickerColumn typed<T>({
    required List<T> options,
    String? label,
    String Function(T value)? valueToString,
    Widget Function(BuildContext context, T value)? itemBuilder,
    int flex = 1,
    bool Function(T a, T b)? equals,
  }) {
    return CustomWheelPickerColumn(
      options: List<Object?>.from(options),
      label: label,
      valueToString: valueToString == null
          ? null
          : (Object? v) => valueToString(v as T),
      itemBuilder: itemBuilder == null
          ? null
          : (BuildContext ctx, Object? v) => itemBuilder(ctx, v as T),
      flex: flex,
      equals: equals == null
          ? null
          : (Object? a, Object? b) => equals(a as T, b as T),
    );
  }

  /// Choices for this wheel (index 0 = top / start of scroll).
  final List<Object?> options;

  /// Header above the wheel.
  final String? label;

  /// Display label for a value (field text + wheel rows).
  final String Function(Object? value)? valueToString;

  /// Custom wheel row; default is centered [Text] from [valueToString].
  final Widget Function(BuildContext context, Object? value)? itemBuilder;

  /// Relative width in vertical layout ([Row] flex). Ignored in horizontal layout.
  final int flex;

  /// Value equality; defaults to `==`.
  final bool Function(Object? a, Object? b)? equals;

  /// Index of [value] in [options], or `0` when missing.
  int indexForValue(Object? value) {
    if (options.isEmpty) return 0;
    final eq = equals ?? (Object? a, Object? b) => a == b;
    for (var i = 0; i < options.length; i++) {
      if (eq(options[i], value)) return i;
    }
    return 0;
  }

  /// Value at wheel index (clamped).
  Object? valueAt(int index) {
    if (options.isEmpty) return null;
    return options[index.clamp(0, options.length - 1)];
  }

  /// Display label for a wheel value ([valueToString] or [Object.toString]).
  String labelFor(Object? value) {
    if (valueToString != null) return valueToString!(value);
    return value?.toString() ?? '';
  }
}

/// Selection keyed by column index: `{0: 1, 1: "test", …}`.
typedef CustomWheelPickerValue = Map<int, Object?>;

/// Alias for [CustomWheelPickerValue].
typedef CustomWheelPickerSelection = CustomWheelPickerValue;

/// Sorted column indices from [columns].
List<int> sortedCustomWheelPickerColumnKeys(Map<int, CustomWheelPickerColumn> columns) {
  final keys = columns.keys.toList()..sort();
  return keys;
}

/// Display text for a [CustomWheelPicker] field.
String formatCustomWheelPickerValue(
  Map<int, CustomWheelPickerColumn> columns,
  CustomWheelPickerValue value, {
  String separator = ' · ',
}) {
  final parts = <String>[];
  for (final key in sortedCustomWheelPickerColumnKeys(columns)) {
    final col = columns[key];
    if (col == null) continue;
    final v = value[key];
    if (v == null) continue;
    final text = col.labelFor(v).trim();
    if (text.isNotEmpty) parts.add(text);
  }
  return parts.join(separator);
}

/// Builds a value map from per-column selected indices.
CustomWheelPickerValue customWheelPickerValueFromIndices(
  Map<int, CustomWheelPickerColumn> columns,
  Map<int, int> indices,
) {
  final out = <int, Object?>{};
  for (final key in sortedCustomWheelPickerColumnKeys(columns)) {
    final col = columns[key]!;
    final ix = indices[key] ?? 0;
    out[key] = col.valueAt(ix);
  }
  return out;
}
