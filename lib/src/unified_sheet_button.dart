import 'package:flutter/material.dart';

/// Small filled / outlined button used by picker sheets (replaces app-specific [AppButton]).
class UnifiedSheetButton extends StatelessWidget {
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

  final String label;
  final VoidCallback? onPressed;
  final double radius;
  final Color? color;
  final Color? textColor;
  final BorderSide? borderSide;
  final bool reverse;
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
