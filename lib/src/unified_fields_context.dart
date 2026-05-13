import 'package:flutter/material.dart';

/// Minimal [BuildContext] helpers for unified field widgets (no app routing / l10n).
extension UnifiedFieldsContextX on BuildContext {
  /// Convenience for `MediaQuery.sizeOf(context).width`.
  double get width => MediaQuery.sizeOf(this).width;

  /// Convenience for `MediaQuery.sizeOf(context).height`.
  double get height => MediaQuery.sizeOf(this).height;

  /// Wide layout: use dialog instead of bottom sheet (desktop-style branch).
  bool get isDesktop => width >= 900;

  /// Shortcut to the ambient primary color from [Theme.of].
  Color get mainColor => Theme.of(this).colorScheme.primary;
}
