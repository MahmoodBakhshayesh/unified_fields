import 'package:flutter/widgets.dart';

import 'unified_input_brightness.dart';
import 'unified_input_decoration.dart';

/// Resolved palette decoration plus optional per-state [composedSet] for a field build.
class UnifiedFieldDecorationContext {
  /// Creates chrome resolved for one build pass (static / enabled appearance).
  const UnifiedFieldDecorationContext({
    required this.resolved,
    required this.composedSet,
  });

  /// Palette-default merge of the field's [UnifiedInputDecoration] (enabled / base look).
  final UnifiedInputDecoration resolved;

  /// Theme + field + [UnifiedInputDecorationSet] merged for [UnifiedBaseTextField].
  final UnifiedInputDecorationSet composedSet;

  /// Non-null when [composedSet] should drive per-state chrome on the base field.
  UnifiedInputDecorationSet? get activeSet =>
      composedSet.isConfigured ? composedSet : null;
}

/// Resolves static decoration and composes per-state layers for a unified field.
UnifiedFieldDecorationContext resolveUnifiedFieldDecorationContext(
  BuildContext context, {
  UnifiedInputDecoration? decoration,
  UnifiedInputDecorationSet? decorationSet,
  UnifiedInputBrightness? brightness,
}) {
  final composed = composeFieldDecorationSet(
    context,
    decoration: decoration,
    decorationSet: decorationSet,
  );
  final resolved = resolveUnifiedDecoration(
    context,
    overrides: decoration,
    brightness: brightness,
  );
  return UnifiedFieldDecorationContext(
    resolved: resolved,
    composedSet: composed,
  );
}
