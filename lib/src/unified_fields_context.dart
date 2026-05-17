import 'package:flutter/material.dart';

/// [BuildContext] helpers for unified field layout (prefixed to avoid clashing with app extensions).
extension UnifiedFieldsContextX on BuildContext {
  /// `MediaQuery.sizeOf(this).width`
  double get unifiedFieldsScreenWidth => MediaQuery.sizeOf(this).width;

  /// `MediaQuery.sizeOf(this).height`
  double get unifiedFieldsScreenHeight => MediaQuery.sizeOf(this).height;

  /// Wide layout: dialog instead of bottom sheet (width ≥ 900).
  bool get unifiedFieldsUseDialogLayout => unifiedFieldsScreenWidth >= 900;

  /// [Theme.of(this).colorScheme.primary]
  Color get unifiedFieldsPrimaryColor => Theme.of(this).colorScheme.primary;

  /// Deprecated: use [unifiedFieldsScreenWidth].
  @Deprecated('Use unifiedFieldsScreenWidth')
  double get width => unifiedFieldsScreenWidth;

  /// Deprecated: use [unifiedFieldsScreenHeight].
  @Deprecated('Use unifiedFieldsScreenHeight')
  double get height => unifiedFieldsScreenHeight;

  /// Deprecated: use [unifiedFieldsUseDialogLayout].
  @Deprecated('Use unifiedFieldsUseDialogLayout')
  bool get isDesktop => unifiedFieldsUseDialogLayout;

  /// Deprecated: use [unifiedFieldsPrimaryColor].
  @Deprecated('Use unifiedFieldsPrimaryColor')
  Color get mainColor => unifiedFieldsPrimaryColor;
}
