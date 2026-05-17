import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

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
