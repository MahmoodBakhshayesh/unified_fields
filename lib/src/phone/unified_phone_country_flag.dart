import 'package:flutter/material.dart';

import 'unified_flag.dart';
import 'unified_input_phone_style.dart';

/// @deprecated Use [UnifiedFlag] instead.
@Deprecated('Use UnifiedFlag')
class UnifiedPhoneCountryFlag extends StatelessWidget {
  /// Creates a flag for [isoCode].
  const UnifiedPhoneCountryFlag({
    super.key,
    required this.isoCode,
    this.width = 24,
    this.height = 18,
    this.borderRadius = const BorderRadius.all(Radius.circular(2)),
    this.style,
  });

  /// ISO 3166-1 alpha-2 code.
  final String isoCode;

  /// Flag width.
  final double width;

  /// Flag height.
  final double height;

  /// Clip radius applied to the SVG.
  final BorderRadius borderRadius;

  /// Optional style overrides.
  final UnifiedInputPhoneStyle? style;

  @override
  Widget build(BuildContext context) {
    return UnifiedFlag(
      code: isoCode,
      width: width,
      height: height,
      borderRadius: borderRadius,
      style: style,
    );
  }
}
