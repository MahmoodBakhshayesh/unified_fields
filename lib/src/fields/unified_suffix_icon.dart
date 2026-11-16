import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';

import 'unified_input_theme.dart';

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
  static Widget slot(Widget child, {double? width, double? height}) {
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
    double? minTapTarget,
  }) {
    final w = _slotWidth(slotWidth);
    final h = _slotHeight(slotHeight);
    final iconWidget = Icon(icon, size: glyphSize, color: color);
    if (onPressed == null) {
      return ExcludeFocus(
        child: slot(iconWidget, width: w, height: h),
      );
    }
    return ExcludeFocus(
      child: UnifiedAdornmentTapTarget(
        minTapTarget: minTapTarget,
        onTap: onPressed,
        tooltip: tooltip,
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
    adornment = _applyIconStyle(
      adornment,
      iconColor: iconColor,
      iconSize: iconSize,
    );

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
        return ExcludeFocus(
          child: slot(child, width: width, height: height),
        );
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
          child: _applyIconStyle(
            child,
            iconColor: iconColor,
            iconSize: iconSize,
          ),
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
      color:
          _colorFromWidget(button.icon) ?? iconColor ?? const Color(0xFF000000),
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

/// Raises the hit-test and accessibility area of an interactive field
/// adornment to [minTapTarget] without changing the visual [child].
///
/// The slot is `max(child width, minTapTarget)` wide and
/// `max(child height, minTapTarget)` tall, clamped to the incoming
/// constraints, so it never makes the field taller. [child] stays centred and
/// keeps its own size; a tap anywhere in the slot reaches it. The slot is one
/// button node for assistive technologies ([tooltip] / [semanticLabel],
/// [onTap]); [child]'s own semantics are excluded.
///
/// When [minTapTarget] is null it is read from the theme
/// ([UnifiedInputThemeResolver.adornmentMinTapTarget]). With no floor, or a
/// child already as large, [child] is returned unchanged.
class UnifiedAdornmentTapTarget extends StatelessWidget {
  /// Wraps an interactive adornment.
  const UnifiedAdornmentTapTarget({
    super.key,
    required this.child,
    this.onTap,
    this.tooltip,
    this.semanticLabel,
    this.minTapTarget,
  });

  /// The visual adornment (handles its own gestures).
  final Widget child;

  /// Semantic tap action (normally the same callback as [child]'s).
  final VoidCallback? onTap;

  /// Accessibility tooltip (e.g. "Show password").
  final String? tooltip;

  /// Accessibility label.
  final String? semanticLabel;

  /// Floor in logical pixels; null reads the theme, 0 disables.
  final double? minTapTarget;

  @override
  Widget build(BuildContext context) {
    final min =
        minTapTarget ??
        UnifiedInputThemeResolver.adornmentMinTapTarget(context);
    if (!(min > 0)) return child;
    return Semantics(
      container: true,
      button: true,
      enabled: onTap != null,
      tooltip: tooltip,
      label: semanticLabel,
      onTap: onTap,
      child: _TapTargetBox(
        minExtent: min,
        child: ExcludeSemantics(child: child),
      ),
    );
  }
}

class _TapTargetBox extends SingleChildRenderObjectWidget {
  const _TapTargetBox({required this.minExtent, super.child});

  final double minExtent;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderTapTargetBox(minExtent);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderTapTargetBox renderObject,
  ) {
    renderObject.minExtent = minExtent;
  }
}

class _RenderTapTargetBox extends RenderShiftedBox {
  _RenderTapTargetBox(this._minExtent) : super(null);

  double _minExtent;
  double get minExtent => _minExtent;
  set minExtent(double v) {
    if (v == _minExtent) return;
    _minExtent = v;
    markNeedsLayout();
  }

  Size _sizeFor(BoxConstraints constraints, Size childSize) {
    final w = math.max(childSize.width, _minExtent);
    // Unbounded height (no field around): keep the child height, never grow.
    final h = constraints.hasBoundedHeight
        ? math.max(childSize.height, _minExtent)
        : childSize.height;
    return constraints.constrain(Size(w, h));
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      math.max(child?.getMinIntrinsicWidth(height) ?? 0, _minExtent);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      math.max(child?.getMaxIntrinsicWidth(height) ?? 0, _minExtent);

  // Heights report the child's own: a parent sizing by intrinsics (e.g. a
  // Material decorator) must not grow the field for the hit area.
  @override
  double computeMinIntrinsicHeight(double width) =>
      child?.getMinIntrinsicHeight(width) ?? 0;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      child?.getMaxIntrinsicHeight(width) ?? 0;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final c = child;
    if (c == null) return constraints.constrain(Size.square(_minExtent));
    return _sizeFor(constraints, c.getDryLayout(constraints.loosen()));
  }

  @override
  void performLayout() {
    final c = child;
    if (c == null) {
      size = constraints.constrain(Size.square(_minExtent));
      return;
    }
    c.layout(constraints.loosen(), parentUsesSize: true);
    size = _sizeFor(constraints, c.size);
    (c.parentData! as BoxParentData).offset = Alignment.center.alongOffset(
      size - c.size as Offset,
    );
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final c = child;
    if (c == null) return false;
    final offset = (c.parentData! as BoxParentData).offset;
    // Any point of the slot hits the chip at the nearest point inside it.
    final local = position - offset;
    final clamped = Offset(
      local.dx.clamp(0.0, math.max(0.0, c.size.width - 0.01)),
      local.dy.clamp(0.0, math.max(0.0, c.size.height - 0.01)),
    );
    return result.addWithPaintOffset(
      offset: offset + (local - clamped),
      position: position,
      hitTest: (result, transformed) =>
          c.hitTest(result, position: transformed),
    );
  }
}
