import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'fields/unified_picker_presentation.dart';

/// Small filled / outlined button used by picker sheets (replaces app-specific [AppButton]).
///
/// Built with [Material] + [InkWell] — not [FilledButton] / [OutlinedButton] — so host apps
/// that forbid Material button types in design audits can open picker sheets.
class UnifiedSheetButton extends StatelessWidget {
  /// Creates a sheet action button.
  const UnifiedSheetButton({
    super.key,
    required this.label,
    this.onPressed,
    this.radius = 8,
    this.color,
    this.textColor,
    this.borderSide,
    this.reverse = false,
    this.child,
    this.height = 40,
  });

  /// Visible label (used as the child when [child] is null).
  final String label;

  /// Tap handler; null disables the button.
  final VoidCallback? onPressed;

  /// Corner radius of the button shape.
  final double radius;

  /// Background color for the filled variant.
  final Color? color;

  /// Foreground (text / icon) color.
  final Color? textColor;

  /// Optional border side for the outlined variant.
  final BorderSide? borderSide;

  /// When true, the button is rendered as an outlined (secondary) action.
  final bool reverse;

  /// Optional widget used instead of [label] (for icons / custom content).
  final Widget? child;

  /// Minimum tap target height (raised to [UnifiedPickerSurfaceStyle.minTapTarget]
  /// when the theme sets one).
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = onPressed != null;
    final fg = textColor ?? (reverse ? scheme.onSurface : scheme.onPrimary);
    final bg = reverse
        ? Colors.transparent
        : (color ?? scheme.primary);
    final border = reverse
        ? (borderSide ?? BorderSide(color: color ?? scheme.outline))
        : BorderSide.none;
    final radiusGeom = BorderRadius.circular(radius);
    final minTap = UnifiedResolvedPickerSurface.of(context).minTapTarget;
    final labelStyle = theme.textTheme.labelLarge?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ) ??
        TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 14);
    final effectiveChild = DefaultTextStyle.merge(
      style: labelStyle,
      child: child ?? Text(label),
    );

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(borderRadius: radiusGeom, side: border),
        child: InkWell(
          borderRadius: radiusGeom,
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: math.max(height, minTap), minWidth: minTap),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Center(widthFactor: 1, child: effectiveChild),
            ),
          ),
        ),
      ),
    );
  }
}
