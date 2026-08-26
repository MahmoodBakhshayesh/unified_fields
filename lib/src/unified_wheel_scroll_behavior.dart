import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Maps a possibly unbounded wheel index onto `[0, itemCount)`.
///
/// Dart's remainder is signed (`-1 % 60 == -1`), so this always returns a
/// non-negative value. Used so clock-style wheels can loop in both directions.
int unifiedFieldsLoopingWheelIndex(int index, int itemCount) {
  if (itemCount <= 0) return 0;
  return (index % itemCount + itemCount) % itemCount;
}

/// Whether a wheel with [itemCount] values should wrap like a clock.
///
/// Small cyclic ranges (hours, minutes, seconds, months) loop; huge ranges
/// such as years 0–999 do not.
bool unifiedFieldsLoopingWheelEnabled(int itemCount) =>
    itemCount > 1 && itemCount <= 60;

/// Mouse / trackpad drag + wheel scrolling on desktop for [ListWheelScrollView] pickers.
class UnifiedFieldsWheelScrollBehavior extends MaterialScrollBehavior {
  /// Creates scroll behavior for unified wheel pickers.
  const UnifiedFieldsWheelScrollBehavior();

  /// Scroll behavior for unified wheel pickers in [context].
  static ScrollBehavior of(BuildContext context) =>
      const UnifiedFieldsWheelScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}
