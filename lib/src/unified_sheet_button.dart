import 'package:flutter/material.dart';

/// Small filled / outlined button used by picker sheets (replaces app-specific [AppButton]).
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

  @override
  Widget build(BuildContext context) {
    final effectiveChild = child ?? Text(label);
    if (reverse) {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: borderSide,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
        onPressed: onPressed,
        child: effectiveChild,
      );
    }
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      onPressed: onPressed,
      child: effectiveChild,
    );
  }
}
