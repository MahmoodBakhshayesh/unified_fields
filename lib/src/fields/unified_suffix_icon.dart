import 'package:flutter/material.dart';

/// Shared suffix sizing for [UnifiedBaseTextField] and picker fields.
///
/// Display-only icons use a fixed [slotSize] box; tappable icons use the same
/// box via a zero-padding [IconButton] so they line up with date/duration defaults.
abstract final class UnifiedSuffixIconChrome {
  /// Width and height of every suffix affordance in the field row.
  static const double slotSize = 32;

  /// Glyph size inside the slot.
  static const double iconSize = 18;

  /// Centers [child] in the standard suffix slot (non-interactive icons).
  static Widget slot(Widget child) {
    return SizedBox(
      width: slotSize,
      height: slotSize,
      child: Center(child: child),
    );
  }

  /// Builds a suffix icon aligned with lock / clear / password affordances.
  static Widget build({
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
    String? tooltip,
    double glyphSize = iconSize,
  }) {
    final iconWidget = Icon(icon, size: glyphSize, color: color);
    if (onPressed == null) {
      return ExcludeFocus(child: slot(iconWidget));
    }
    return ExcludeFocus(
      child: IconButton(
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.zero,
          minimumSize: const Size(slotSize, slotSize),
          fixedSize: const Size(slotSize, slotSize),
          visualDensity: VisualDensity.compact,
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(
          width: slotSize,
          height: slotSize,
        ),
        onPressed: onPressed,
        tooltip: tooltip,
        icon: iconWidget,
      ),
    );
  }

  /// Wraps a custom suffix widget in the standard slot when needed.
  static Widget normalize(Widget suffix) {
    if (suffix is Icon) {
      return slot(suffix);
    }
    if (suffix is IconButton) {
      return _normalizeIconButton(suffix);
    }
    if (suffix is ExcludeFocus) {
      final child = suffix.child;
      if (child is IconButton) {
        return ExcludeFocus(child: _normalizeIconButton(child));
      }
      if (child is Icon) {
        return ExcludeFocus(child: slot(child));
      }
    }
    return slot(suffix);
  }

  static Widget _normalizeIconButton(IconButton button) {
    return build(
      icon: _iconDataFromWidget(button.icon) ?? Icons.arrow_drop_down,
      color: _colorFromWidget(button.icon) ?? const Color(0xFF000000),
      onPressed: button.onPressed,
      tooltip: button.tooltip,
    );
  }

  static IconData? _iconDataFromWidget(Widget icon) {
    if (icon is Icon) return icon.icon;
    return null;
  }

  static Color? _colorFromWidget(Widget icon) {
    if (icon is Icon) return icon.color;
    return null;
  }
}
