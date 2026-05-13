import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Resolved colors for one unified-input brightness.
///
/// Override individual slots via [UnifiedInputDecoration] on each field.
@immutable
class UnifiedInputPalette {
  final Color bodyBackground;
  final Color headerBackground;
  final Color labelColor;
  final Color hintColor;
  final Color fieldTextColor;
  final Color borderColor;
  final BorderSide defaultBorderSide;
  final BorderRadius borderRadius;
  final Color validationColor;
  final Color sheetBackground;
  final Color sheetHeaderBackground;

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
      labelColor: AppColors.textColorDark,
      hintColor: AppColors.hintColor,
      fieldTextColor: AppColors.textColorDark,
      borderColor: const Color(0xff58514C),
      defaultBorderSide: const BorderSide(color: Color(0xff58514C), width: 0.5),
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      validationColor: Colors.red,
      sheetBackground: const Color(0xffEAECF2),
      sheetHeaderBackground: Colors.white,
    );
  }

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
