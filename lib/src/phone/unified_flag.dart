import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'unified_phone_flag_assets.dart';
import '../fields/unified_input_theme.dart';

/// Displays a country flag SVG from bundled assets.
///
/// [code] is ISO 3166-1 alpha-2 (e.g. `IR`, `IN`) or an asset stem (`c_do`).
///
/// When [width], [height], and [borderRadius] are omitted, values come from
/// [UnifiedInputPhoneStyle] on [UnifiedInputThemeScope] (see [style] for local overrides).
class UnifiedFlag extends StatelessWidget {
  /// Creates a flag for [code].
  const UnifiedFlag({
    super.key,
    required this.code,
    this.width,
    this.height,
    this.size,
    this.borderRadius,
    this.style,
    this.package,
  });

  /// ISO or asset stem (e.g. `IR`, `IN`, `c_do`).
  final String code;

  /// Flag width; overridden by [size].
  final double? width;

  /// Flag height; when null and [size] is set, uses [size] × 0.75.
  final double? height;

  /// Shorthand for width; height defaults to [size] × 0.75 unless [height] is set.
  final double? size;

  /// Clip radius; falls back to theme phone style.
  final BorderRadius? borderRadius;

  /// Merges on top of scoped [UnifiedInputPhoneStyle].
  final UnifiedInputPhoneStyle? style;

  /// Package hosting assets; defaults to [unifiedFieldsPackageName].
  final String? package;

  @override
  Widget build(BuildContext context) {
    final resolved = UnifiedInputThemeResolver.resolvePhoneStyle(
      context,
      overrides: style,
    );
    final w = size ?? width ?? resolved.flagWidth ?? 24;
    final h = height ??
        (size != null
            ? (resolved.flagHeight ?? size! * 0.75)
            : (resolved.flagHeight ?? 18));
    final radius = borderRadius ??
        resolved.flagBorderRadius ??
        const BorderRadius.all(Radius.circular(3));
    final assetPath = unifiedFlagAssetPath(code);
    final pkg = package ?? unifiedFieldsPackageName;

    return ClipRRect(
      borderRadius: radius,
      child: SvgPicture.asset(
        assetPath,
        package: pkg,
        width: w,
        height: h,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => _placeholder(w, h),
        errorBuilder: (_, _, _) => _placeholder(w, h),
      ),
    );
  }

  Widget _placeholder(double w, double h) {
    return SizedBox(
      width: w,
      height: h,
      child: ColoredBox(
        color: Colors.grey.shade400,
        child: Center(
          child: Text(
            code.length >= 2 ? code.substring(0, 2).toUpperCase() : code.toUpperCase(),
            style: TextStyle(
              fontSize: h * 0.45,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
