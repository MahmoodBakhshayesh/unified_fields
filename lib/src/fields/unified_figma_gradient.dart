import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// A [LinearGradient] positioned with a Figma `gradientTransform`, so a stroke
/// or fill copied from Figma (Dev Mode / Plugin API) renders identically at any
/// box size.
///
/// Figma stores linear gradients as a 2 × 3 affine matrix
/// `[[a, b, c], [d, e, f]]` mapping the node's normalized space (`0..1` on
/// each axis) to gradient space, where the gradient runs along x from 0 to 1:
/// `t = a·u + b·v + c`. Only the first row affects a linear gradient.
///
/// ```dart
/// // "Linear Stroke pink + violet"
/// const stroke = UnifiedFigmaLinearGradient(
///   figmaTransform: [[0.9476, 0.0524, 0], [-0.9476, 0.9476, 0.5]],
///   colors: [Color(0xFF8B5CF6), Color(0xFF050517), Color(0xFFFF5CA8)],
///   stops: [0, 0.5926, 1],
/// );
/// ```
@immutable
class UnifiedFigmaLinearGradient extends LinearGradient {
  /// Creates a gradient from Figma's [figmaTransform] rows and stops.
  const UnifiedFigmaLinearGradient({
    required this.figmaTransform,
    required super.colors,
    super.stops,
    super.tileMode,
  });

  /// Figma `gradientTransform` (`[[a, b, c], [d, e, f]]`).
  final List<List<double>> figmaTransform;

  /// Begin / end of an equivalent [LinearGradient] for [rect].
  (Alignment, Alignment) alignmentsFor(Rect rect) {
    final a = figmaTransform[0][0];
    final b = figmaTransform[0][1];
    final c = figmaTransform[0][2];
    final w = rect.width <= 0 ? 1.0 : rect.width;
    final h = rect.height <= 0 ? 1.0 : rect.height;
    // t = gx·x + gy·y + c in pixels relative to rect.topLeft.
    final gx = a / w;
    final gy = b / h;
    final len2 = gx * gx + gy * gy;
    if (len2 == 0) return (Alignment.centerLeft, Alignment.centerRight);
    final p0 = Offset(-c * gx / len2, -c * gy / len2);
    final p1 = p0 + Offset(gx / len2, gy / len2);
    Alignment toAlign(Offset p) => Alignment(2 * p.dx / w - 1, 2 * p.dy / h - 1);
    return (toAlign(p0), toAlign(p1));
  }

  @override
  ui.Shader createShader(Rect rect, {TextDirection? textDirection}) {
    final (b, e) = alignmentsFor(rect);
    return LinearGradient(begin: b, end: e, colors: colors, stops: stops, tileMode: tileMode)
        .createShader(rect, textDirection: textDirection);
  }

  @override
  UnifiedFigmaLinearGradient scale(double factor) => UnifiedFigmaLinearGradient(
        figmaTransform: figmaTransform,
        colors: colors.map((c) => Color.lerp(null, c, factor)!).toList(),
        stops: stops,
        tileMode: tileMode,
      );

  @override
  UnifiedFigmaLinearGradient withOpacity(double opacity) => UnifiedFigmaLinearGradient(
        figmaTransform: figmaTransform,
        colors: colors.map((c) => c.withValues(alpha: c.a * opacity)).toList(),
        stops: stops,
        tileMode: tileMode,
      );

  @override
  bool operator ==(Object other) =>
      other is UnifiedFigmaLinearGradient &&
      listEquals(other.colors, colors) &&
      listEquals(other.stops, stops) &&
      other.tileMode == tileMode &&
      other.figmaTransform.length == figmaTransform.length &&
      Iterable<int>.generate(figmaTransform.length).every((i) => listEquals(other.figmaTransform[i], figmaTransform[i]));

  @override
  int get hashCode => Object.hash(
        Object.hashAll(colors),
        stops == null ? null : Object.hashAll(stops!),
        tileMode,
        Object.hashAll(figmaTransform.expand((r) => r)),
      );
}
