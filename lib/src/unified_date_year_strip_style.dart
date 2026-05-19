import 'package:flutter/material.dart';

import 'unified_date_wheel_style.dart';

/// Visual styling for the horizontal year strip in month/year date picker UI.
///
/// Set on [UnifiedInputDatePickerStyle.yearStripStyle]. When omitted, [fadeColor]
/// and [magnification] fall back to [UnifiedInputDatePickerStyle.wheelStyle] where
/// possible, then sheet background.
@immutable
class UnifiedFieldsDateYearStripStyle {
  /// Creates optional year-strip overrides.
  const UnifiedFieldsDateYearStripStyle({
    this.fadeColor,
    this.showFade,
    this.fadeExtent,
    this.magnification,
    this.itemWidth,
    this.spacing,
    this.stripHeight,
  });

  /// Base color for start / end edge gradients.
  final Color? fadeColor;

  /// When null, fade is shown when [magnification] is above 1.0 (default true).
  final bool? showFade;

  /// Fraction of strip width for each end gradient (0–0.5). Default `0.22`.
  final double? fadeExtent;

  /// Scale boost for the year chip nearest the horizontal center (1.0 = flat).
  ///
  /// Defaults to [UnifiedFieldsDateWheelStyle] magnification or `1.12`.
  final double? magnification;

  /// Width of each year chip. Default `76`.
  final double? itemWidth;

  /// Gap between chips. Default `8`.
  final double? spacing;

  /// Total height of the scroll band. Default `48` (grows slightly when magnified).
  final double? stripHeight;

  static const double _kDefaultMagnification = 1.12;
  static const double _kDefaultFadeExtent = 0.22;
  static const double _kDefaultItemWidth = 76;
  static const double _kDefaultSpacing = 8;
  static const double _kDefaultStripHeight = 48;

  /// Fills defaults; merges [overrides] and optional [wheelStyle] fallbacks.
  factory UnifiedFieldsDateYearStripStyle.resolve({
    UnifiedFieldsDateYearStripStyle? overrides,
    UnifiedFieldsDateWheelStyle? wheelStyle,
    Color? sheetBackground,
  }) {
    final fade =
        overrides?.fadeColor ?? wheelStyle?.fadeColor ?? sheetBackground;
    final mag =
        overrides?.magnification ?? wheelStyle?.magnification ?? _kDefaultMagnification;
    final showFade = overrides?.showFade ?? (mag > 1.001);
    return UnifiedFieldsDateYearStripStyle(
      fadeColor: fade,
      showFade: showFade,
      fadeExtent: overrides?.fadeExtent ?? _kDefaultFadeExtent,
      magnification: mag,
      itemWidth: overrides?.itemWidth ?? _kDefaultItemWidth,
      spacing: overrides?.spacing ?? _kDefaultSpacing,
      stripHeight: overrides?.stripHeight ?? _kDefaultStripHeight,
    );
  }

  /// Merges [other] on top of this.
  UnifiedFieldsDateYearStripStyle merge(UnifiedFieldsDateYearStripStyle? other) {
    if (other == null) return this;
    return UnifiedFieldsDateYearStripStyle(
      fadeColor: other.fadeColor ?? fadeColor,
      showFade: other.showFade ?? showFade,
      fadeExtent: other.fadeExtent ?? fadeExtent,
      magnification: other.magnification ?? magnification,
      itemWidth: other.itemWidth ?? itemWidth,
      spacing: other.spacing ?? spacing,
      stripHeight: other.stripHeight ?? stripHeight,
    );
  }

  /// Whether the strip scales the centered year chip ([magnification] > 1).
  bool get useMagnification => (magnification ?? _kDefaultMagnification) > 1.001;

  /// Whether edge fade gradients are shown ([showFade] or [useMagnification]).
  bool get effectiveShowFade => showFade ?? useMagnification;
}
