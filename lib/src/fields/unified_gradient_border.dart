import 'package:material_ui/material_ui.dart';

/// Paints a [gradient] **stroke only** around [child] (not a filled background).
///
/// Uses [CustomPainter] with [PaintingStyle.stroke] so translucent
/// [backgroundColor] values never reveal the gradient as a fill.
class UnifiedGradientBorder extends StatelessWidget {
  /// Creates a gradient stroke wrapper.
  const UnifiedGradientBorder({
    super.key,
    required this.gradient,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.width = 1,
    this.backgroundColor,
    this.clipInner = true,
  });

  /// Stroke gradient (typically left→right or angled pink→violet).
  final Gradient gradient;

  /// Content inside the bordered box.
  final Widget child;

  /// Outer corner radius.
  final BorderRadius borderRadius;

  /// Visible stroke thickness in logical pixels.
  final double width;

  /// Fill behind [child] (defaults to transparent). May be translucent.
  final Color? backgroundColor;

  /// When true, clips [child] to the inset radius.
  final bool clipInner;

  /// Inset [borderRadius] by [inset] so inner fill matches the stroke.
  static BorderRadius insetRadius(BorderRadius radius, double inset) {
    Radius shrink(Radius r) => Radius.circular((r.x - inset).clamp(0, r.x));
    return BorderRadius.only(
      topLeft: shrink(radius.topLeft),
      topRight: shrink(radius.topRight),
      bottomLeft: shrink(radius.bottomLeft),
      bottomRight: shrink(radius.bottomRight),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = width <= 0 ? 0.0 : width;
    if (w == 0) return child;

    final innerRadius = insetRadius(borderRadius, w);
    Widget content = child;
    if (clipInner) {
      content = ClipRRect(borderRadius: innerRadius, child: content);
    }

    // Like Figma (and BoxDecoration borders): fill the full outer shape, then
    // paint the stroke on top so opaque fills / child chrome never hide it.
    return CustomPaint(
      foregroundPainter: _UnifiedGradientBorderPainter(
        gradient: gradient,
        borderRadius: borderRadius,
        strokeWidth: w,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        child: content,
      ),
    );
  }
}

class _UnifiedGradientBorderPainter extends CustomPainter {
  _UnifiedGradientBorderPainter({
    required this.gradient,
    required this.borderRadius,
    required this.strokeWidth,
  });

  final Gradient gradient;
  final BorderRadius borderRadius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (strokeWidth <= 0 || size.isEmpty) return;

    // Center the stroke on the inset path so it stays inside [size].
    final inset = strokeWidth / 2;
    if (size.width <= strokeWidth || size.height <= strokeWidth) return;

    final rrect = borderRadius
        .resolve(TextDirection.ltr)
        .toRRect(Offset.zero & size)
        .deflate(inset);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(Offset.zero & size);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _UnifiedGradientBorderPainter oldDelegate) {
    return oldDelegate.gradient != gradient ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Shared chrome helper: solid [BorderSide] or optional [borderGradient].
///
/// When [borderGradient] is null (or [forceSolid] is true), behavior matches the
/// pre-1.3.0 `Container` + `BoxDecoration(border: …)` path — existing field
/// setups are unchanged. Gradient stroke is opt-in only.
class UnifiedFieldBorderBox extends StatelessWidget {
  /// Creates a bordered field body.
  const UnifiedFieldBorderBox({
    super.key,
    required this.child,
    required this.borderRadius,
    this.borderSide,
    this.borderGradient,
    this.backgroundColor,
    this.height,
    this.minHeight,
    this.alignment,
    this.forceSolid = false,
    this.clipInner = true,
    this.strokeOverChild = false,
  });

  /// Content inside the bordered box.
  final Widget child;

  /// Outer corner radius.
  final BorderRadius borderRadius;

  /// Solid path only: paint the stroke on top of [child] instead of insetting
  /// it, and inset [child] horizontally only. Text sits where it did, but the
  /// child spans the full outer height, so hit areas and accessibility rects
  /// can reach the outer edge (a 44 px field yields 44 px targets, not 44
  /// minus two strokes). Used when adornment tap targets are on
  /// ([UnifiedInputAdornmentStyle.minTapTarget]). The gradient path always
  /// fills the full area.
  final bool strokeOverChild;

  /// Solid stroke when [borderGradient] is null or [forceSolid] is true.
  final BorderSide? borderSide;

  /// Optional gradient stroke (preferred over solid [borderSide] color).
  final Gradient? borderGradient;

  /// Fill behind [child].
  final Color? backgroundColor;

  /// Fixed outer height of the bordered box (solid: `Container.height`;
  /// gradient: total size including stroke).
  final double? height;

  /// Minimum outer height when [height] is null.
  final double? minHeight;

  /// Optional alignment (omit to expand [child] like a plain `Container`).
  final AlignmentGeometry? alignment;

  /// When true, always use solid [borderSide] (e.g. validation error).
  final bool forceSolid;

  /// When true, clips [child] to the (inset) radius.
  final bool clipInner;

  bool get _useGradient =>
      !forceSolid &&
      borderGradient != null &&
      (borderSide?.style != BorderStyle.none);

  double get _strokeWidth {
    final side = borderSide;
    if (side == null || side.style == BorderStyle.none) {
      return _useGradient ? 1.0 : 0.0;
    }
    return side.width;
  }

  @override
  Widget build(BuildContext context) {
    final side = borderSide;

    if (_useGradient) {
      final w = _strokeWidth <= 0 ? 1.0 : _strokeWidth;
      // Stroke is painted inside bounds (centered on inset path), so [height]
      // is the outer size and the child fills the full area.
      Widget content = child;
      if (height != null) {
        content = SizedBox(
          height: height,
          width: double.infinity,
          child: child,
        );
      } else if (minHeight != null) {
        content = ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight!),
          child: child,
        );
      }
      if (alignment != null) {
        content = Align(alignment: alignment!, child: content);
      }
      return UnifiedGradientBorder(
        gradient: borderGradient!,
        borderRadius: borderRadius,
        width: w,
        backgroundColor: backgroundColor,
        clipInner: clipInner,
        child: content,
      );
    }

    final hasStroke = side != null && side.style != BorderStyle.none;
    if (strokeOverChild && hasStroke) {
      final inset = side.width;
      Widget content = clipInner
          ? ClipRRect(borderRadius: borderRadius, child: child)
          : child;
      content = Padding(
        padding: EdgeInsets.symmetric(horizontal: inset),
        child: content,
      );
      return Container(
        height: height,
        constraints: height == null && minHeight != null
            ? BoxConstraints(minHeight: minHeight!)
            : null,
        alignment: alignment,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.fromBorderSide(side),
        ),
        child: content,
      );
    }

    // Solid path: same layout contract as pre-1.3.0 Container + border.
    return Container(
      height: height,
      constraints: height == null && minHeight != null
          ? BoxConstraints(minHeight: minHeight!)
          : null,
      alignment: alignment,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: side == null || side.style == BorderStyle.none
            ? null
            : Border.fromBorderSide(side),
      ),
      child: clipInner
          ? ClipRRect(borderRadius: borderRadius, child: child)
          : child,
    );
  }
}
