import 'package:flutter/material.dart';

/// Minimal [BuildContext] helpers for unified field widgets (no app routing / l10n).
extension UnifiedFieldsContextX on BuildContext {
  double get width => MediaQuery.sizeOf(this).width;

  double get height => MediaQuery.sizeOf(this).height;

  /// Wide layout: use dialog instead of bottom sheet (desktop-style branch).
  bool get isDesktop => width >= 900;

  Color get mainColor => Theme.of(this).colorScheme.primary;
}
