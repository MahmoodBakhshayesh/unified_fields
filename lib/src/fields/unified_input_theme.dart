import 'package:flutter/material.dart';

import 'unified_input_brightness.dart';
import 'unified_input_palette.dart';

/// Optional inherited scope to force brightness / palette for a subtree.
class UnifiedInputThemeScope extends InheritedWidget {
  /// Creates a scope; at least one of [brightnessOverride] or [paletteOverride] is usually set.
  const UnifiedInputThemeScope({
    super.key,
    this.brightnessOverride,
    this.paletteOverride,
    required super.child,
  });

  /// When non-null, replaces inferred brightness from [Theme.of(context)].
  final UnifiedInputBrightness? brightnessOverride;

  /// Full palette override (skips [UnifiedInputPalette.light]/dark).
  final UnifiedInputPalette? paletteOverride;

  /// Returns the closest [UnifiedInputThemeScope] in the widget tree, if any.
  static UnifiedInputThemeScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UnifiedInputThemeScope>();
  }

  @override
  bool updateShouldNotify(covariant UnifiedInputThemeScope oldWidget) {
    return brightnessOverride != oldWidget.brightnessOverride || paletteOverride != oldWidget.paletteOverride;
  }
}

/// Resolve palette + brightness used by unified fields.
class UnifiedInputThemeResolver {
  UnifiedInputThemeResolver._();

  /// Picks brightness from a [UnifiedInputThemeScope] override or [Theme.of].
  static UnifiedInputBrightness inferBrightness(BuildContext context) {
    final scope = UnifiedInputThemeScope.maybeOf(context);
    if (scope?.brightnessOverride != null) return scope!.brightnessOverride!;
    return Theme.of(context).brightness == Brightness.dark ? UnifiedInputBrightness.dark : UnifiedInputBrightness.light;
  }

  /// Resolves the active palette for [context].
  static UnifiedInputPalette resolvePalette(BuildContext context) {
    final scope = UnifiedInputThemeScope.maybeOf(context);
    if (scope?.paletteOverride != null) return scope!.paletteOverride!;
    return paletteFor(inferBrightness(context));
  }

  /// Returns the default palette for the given brightness.
  static UnifiedInputPalette paletteFor(UnifiedInputBrightness b) {
    switch (b) {
      case UnifiedInputBrightness.light:
        return UnifiedInputPalette.light();
      case UnifiedInputBrightness.dark:
        return UnifiedInputPalette.dark();
    }
  }
}
