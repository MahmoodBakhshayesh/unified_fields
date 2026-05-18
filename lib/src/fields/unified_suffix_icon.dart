import 'package:flutter/material.dart';

/// Shared suffix sizing for [UnifiedBaseTextField] and picker fields.
///
/// Display-only icons use a fixed [slotSize] box; tappable icons use the same
/// box via a zero-padding [IconButton] so they line up with date/duration defaults.
/// Custom [suffixIcon] widgets use [normalize] with optional [width]/[height]
/// from [UnifiedInputDecoration.suffixWidth] / [suffixHeight].
abstract final class UnifiedSuffixIconChrome {
  /// Width and height of every suffix affordance in the field row.
  static const double slotSize = 32;

  /// Glyph size inside the slot.
  static const double iconSize = 18;

  static double _slotWidth(double? width) => width ?? slotSize;

  static double _slotHeight(double? height) => height ?? slotSize;

  /// Centers [child] in the suffix slot (non-interactive icons).
  static Widget slot(
    Widget child, {
    double? width,
    double? height,
  }) {
    return SizedBox(
      width: _slotWidth(width),
      height: _slotHeight(height),
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
    double? slotWidth,
    double? slotHeight,
  }) {
    final w = _slotWidth(slotWidth);
    final h = _slotHeight(slotHeight);
    final iconWidget = Icon(icon, size: glyphSize, color: color);
    if (onPressed == null) {
      return ExcludeFocus(child: slot(iconWidget, width: w, height: h));
    }
    return ExcludeFocus(
      child: IconButton(
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.zero,
          minimumSize: Size(w, h),
          fixedSize: Size(w, h),
          visualDensity: VisualDensity.compact,
        ),
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(width: w, height: h),
        onPressed: onPressed,
        tooltip: tooltip,
        icon: iconWidget,
      ),
    );
  }

  /// Wraps a custom [suffixIcon] in a sized slot; omit [width]/[height] for the default 32×32.
  static Widget normalize(
    Widget suffix, {
    double? width,
    double? height,
  }) {
    if (suffix is Icon) {
      return slot(suffix, width: width, height: height);
    }
    if (suffix is IconButton) {
      return _normalizeIconButton(suffix, slotWidth: width, slotHeight: height);
    }
    if (suffix is ExcludeFocus) {
      final child = suffix.child;
      if (child is IconButton) {
        return ExcludeFocus(
          child: _normalizeIconButton(
            child,
            slotWidth: width,
            slotHeight: height,
          ),
        );
      }
      if (child is Icon) {
        return ExcludeFocus(
          child: slot(child, width: width, height: height),
        );
      }
    }
    return slot(suffix, width: width, height: height);
  }

  static Widget _normalizeIconButton(
    IconButton button, {
    double? slotWidth,
    double? slotHeight,
  }) {
    return build(
      icon: _iconDataFromWidget(button.icon) ?? Icons.arrow_drop_down,
      color: _colorFromWidget(button.icon) ?? const Color(0xFF000000),
      onPressed: button.onPressed,
      tooltip: button.tooltip,
      slotWidth: slotWidth,
      slotHeight: slotHeight,
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
