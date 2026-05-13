import 'package:flutter/material.dart';

import '../unified_colors.dart';

/// Resolved colors for one unified-input brightness.
///
/// Override individual slots via [UnifiedInputDecoration] on each field.
@immutable
class UnifiedInputPalette {
  /// Background color of the editing area.
  final Color bodyBackground;

  /// Background of the left label area for `labelInRow` layouts.
  final Color headerBackground;

  /// Color of the field label.
  final Color labelColor;

  /// Color of placeholder / hint text.
  final Color hintColor;

  /// Color of the user-entered field text.
  final Color fieldTextColor;

  /// Default border color.
  final Color borderColor;

  /// Default border side used for the field box.
  final BorderSide defaultBorderSide;

  /// Default border radius of the field box.
  final BorderRadius borderRadius;

  /// Color used for error chrome.
  final Color validationColor;

  /// Background color of bottom sheets opened by the fields.
  final Color sheetBackground;

  /// Background color of the sheet header (title bar).
  final Color sheetHeaderBackground;

  /// Creates a palette with all slots required.
  const UnifiedInputPalette({
    required this.bodyBackground,
    required this.headerBackground,
    required this.labelColor,
    required this.hintColor,
    required this.fieldTextColor,
    required this.borderColor,
    required this.defaultBorderSide,
    required this.borderRadius,
    required this.validationColor,
    required this.sheetBackground,
    required this.sheetHeaderBackground,
  });

  /// Matches unified_fields “card” fields (grey body, dark label).
  static UnifiedInputPalette light() {
    return UnifiedInputPalette(
      bodyBackground: Colors.black26,
      headerBackground: Colors.black26,
      labelColor: UnifiedColors.textColorDark,
      hintColor: UnifiedColors.hintColor,
      fieldTextColor: UnifiedColors.textColorDark,
      borderColor: const Color(0xff58514C),
      defaultBorderSide: const BorderSide(color: Color(0xff58514C), width: 0.5),
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      validationColor: Colors.red,
      sheetBackground: const Color(0xffEAECF2),
      sheetHeaderBackground: Colors.white,
    );
  }

  /// Default dark palette used by [UnifiedInputBrightness.dark].
  static UnifiedInputPalette dark() {
    return UnifiedInputPalette(
      bodyBackground: const Color(0xFF2C2C2E),
      headerBackground: const Color(0xFF2C2C2E),
      labelColor: const Color(0xFFEAEAEA),
      hintColor: const Color(0xFF8E8E93),
      fieldTextColor: const Color(0xFFF2F2F7),
      borderColor: const Color(0xFF48484A),
      defaultBorderSide: const BorderSide(color: Color(0xFF48484A), width: 0.5),
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      validationColor: const Color(0xFFFF6B6B),
      sheetBackground: const Color(0xFF1C1C1E),
      sheetHeaderBackground: const Color(0xFF2C2C2E),
    );
  }
}
