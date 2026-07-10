import 'package:flutter/material.dart';

/// Shared suffix sizing for [UnifiedBaseTextField] and picker fields.
///
/// [Icon]s and [IconButton]s use a fixed [slotSize] box so they line up with
/// lock / clear / password affordances. Other widgets use their intrinsic size
/// unless [UnifiedInputDecoration.suffixWidth] / [suffixHeight] are set.
abstract final class UnifiedSuffixIconChrome {
  /// Width and height of standard icon suffix affordances.
  static const double slotSize = 32;

  /// Glyph size inside the icon slot.
  static const double iconSize = 18;

  static double _slotWidth(double? width) => width ?? slotSize;

  static double _slotHeight(double? height) => height ?? slotSize;

  static bool _hasExplicitSize(double? width, double? height) =>
      width != null || height != null;

  /// Centers [child] in a fixed slot (used for icons and explicit overrides).
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

  /// Lays out a field adornment ([prefixIcon], [suffixIcon], etc.).
  ///
  /// With [width] / [height] (from decoration), uses a fixed slot. [Icon] and
  /// [IconButton] use the default 32×32 slot. Everything else keeps intrinsic
  /// width and height.
  ///
  /// When [iconColor] is set, [Icon] widgets without an explicit color are tinted.
  /// [iconSize] overrides the glyph size for bare [Icon] adornments.
  static Widget normalize(
    Widget adornment, {
    double? width,
    double? height,
    Color? iconColor,
    double? iconSize,
  }) {
    adornment = _applyIconStyle(adornment, iconColor: iconColor, iconSize: iconSize);

    if (_hasExplicitSize(width, height)) {
      return _slotAdornment(
        adornment,
        width: width,
        height: height,
        iconColor: iconColor,
        iconSize: iconSize,
      );
    }

    if (adornment is Icon) {
      return slot(adornment, width: width, height: height);
    }
    if (adornment is IconButton) {
      return _normalizeIconButton(
        adornment,
        iconColor: iconColor,
        iconSize: iconSize,
      );
    }
    if (adornment is ExcludeFocus) {
      final child = adornment.child;
      if (child is IconButton) {
        return ExcludeFocus(
          child: _normalizeIconButton(
            child,
            iconColor: iconColor,
            iconSize: iconSize,
          ),
        );
      }
      if (child is Icon) {
        return ExcludeFocus(child: slot(child, width: width, height: height));
      }
    }

    return adornment;
  }

  static Widget _applyIconStyle(
    Widget adornment, {
    Color? iconColor,
    double? iconSize,
  }) {
    if (adornment is Icon) {
      return Icon(
        adornment.icon,
        size: iconSize ?? adornment.size,
        color: adornment.color ?? iconColor,
        semanticLabel: adornment.semanticLabel,
        textDirection: adornment.textDirection,
        shadows: adornment.shadows,
      );
    }
    if (adornment is ExcludeFocus) {
      final child = adornment.child;
      if (child is Icon || child is IconButton) {
        return ExcludeFocus(
          child: _applyIconStyle(child, iconColor: iconColor, iconSize: iconSize),
        );
      }
    }
    return adornment;
  }

  static Widget _slotAdornment(
    Widget suffix, {
    double? width,
    double? height,
    Color? iconColor,
    double? iconSize,
  }) {
    suffix = _applyIconStyle(suffix, iconColor: iconColor, iconSize: iconSize);
    if (suffix is Icon) {
      return slot(suffix, width: width, height: height);
    }
    if (suffix is IconButton) {
      return _normalizeIconButton(
        suffix,
        slotWidth: width,
        slotHeight: height,
        iconColor: iconColor,
        iconSize: iconSize,
      );
    }
    if (suffix is ExcludeFocus) {
      final child = suffix.child;
      if (child is IconButton) {
        return ExcludeFocus(
          child: _normalizeIconButton(
            child,
            slotWidth: width,
            slotHeight: height,
            iconColor: iconColor,
            iconSize: iconSize,
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
    Color? iconColor,
    double? iconSize,
  }) {
    return build(
      icon: _iconDataFromWidget(button.icon) ?? Icons.arrow_drop_down,
      color: _colorFromWidget(button.icon) ?? iconColor ?? const Color(0xFF000000),
      onPressed: button.onPressed,
      tooltip: button.tooltip,
      slotWidth: slotWidth,
      slotHeight: slotHeight,
      glyphSize: iconSize ?? UnifiedSuffixIconChrome.iconSize,
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
