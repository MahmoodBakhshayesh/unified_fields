import 'package:flutter/material.dart';

import 'unified_field_label_mode.dart';
import 'unified_input_decoration.dart';

/// Default layout and behavior for [UnifiedBaseTextField] via [UnifiedInputThemeData.fieldDefaults].
///
/// Each value is optional; field-level parameters and [UnifiedInputDecoration] still win.
@immutable
class UnifiedInputFieldDefaults {
  /// Creates subtree defaults for unified text fields.
  const UnifiedInputFieldDefaults({
    this.labelMode,
    this.labelInRow,
    this.rowLabelRatio,
    this.height,
    this.borderRadius,
    this.borderSide,
    this.backgroundColor,
    this.headerBackgroundColor,
    this.showError,
    this.showClearButton,
    this.resetTextWhenLocked,
    this.autovalidateMode,
    this.contentPadding,
    this.mustResolveTextDirectionByInput,
  });

  /// Default label placement for fields that do not set [UnifiedBaseTextField.labelMode].
  final UnifiedFieldLabelMode? labelMode;

  /// Legacy row label flag; ignored when [labelMode] is set on these defaults.
  final bool? labelInRow;

  /// Flex ratio for label vs body in [UnifiedFieldLabelMode.labelInRow].
  final List<int>? rowLabelRatio;

  /// Minimum inner row height.
  final double? height;

  /// Field box corner radius.
  final BorderRadius? borderRadius;

  /// Field box border.
  final BorderSide? borderSide;

  /// Editing-area background.
  final Color? backgroundColor;

  /// Label column background when the label is in a row.
  final Color? headerBackgroundColor;

  /// Whether to show the inline error strip.
  final bool? showError;

  /// Whether to show a clear (×) suffix when the field has text.
  final bool? showClearButton;

  /// Reset text to [UnifiedBaseTextField.initialValue] when [UnifiedBaseTextField.locked] becomes true.
  final bool? resetTextWhenLocked;

  /// When [UnifiedBaseTextField.validator] runs for UI feedback (`null` = always).
  final AutovalidateMode? autovalidateMode;

  /// Inner padding of the editing area.
  final EdgeInsetsGeometry? contentPadding;

  /// Infer [TextDirection] from the first typed character (RTL scripts).
  final bool? mustResolveTextDirectionByInput;

  /// Maps layout fields into [UnifiedInputDecoration] for palette merge.
  UnifiedInputDecoration toDecoration() {
    var merged = UnifiedInputDecoration(
      labelMode: labelMode,
      rowLabelRatio: rowLabelRatio ?? const [],
      height: height,
      borderRadius: borderRadius,
      borderSide: borderSide,
      backgroundColor: backgroundColor,
      headerBackgroundColor: headerBackgroundColor,
      showError: showError ?? true,
      contentPadding: contentPadding,
    );
    if (labelInRow != null) {
      merged = merged.merge(UnifiedInputDecoration(labelInRow: labelInRow!));
    }
    return merged;
  }

  /// Merges [other] on top of this; non-null fields from [other] win.
  UnifiedInputFieldDefaults merge(UnifiedInputFieldDefaults? other) {
    if (other == null) return this;
    return UnifiedInputFieldDefaults(
      labelMode: other.labelMode ?? labelMode,
      labelInRow: other.labelInRow ?? labelInRow,
      rowLabelRatio: other.rowLabelRatio ?? rowLabelRatio,
      height: other.height ?? height,
      borderRadius: other.borderRadius ?? borderRadius,
      borderSide: other.borderSide ?? borderSide,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      headerBackgroundColor:
          other.headerBackgroundColor ?? headerBackgroundColor,
      showError: other.showError ?? showError,
      showClearButton: other.showClearButton ?? showClearButton,
      resetTextWhenLocked: other.resetTextWhenLocked ?? resetTextWhenLocked,
      autovalidateMode: other.autovalidateMode ?? autovalidateMode,
      contentPadding: other.contentPadding ?? contentPadding,
      mustResolveTextDirectionByInput: other.mustResolveTextDirectionByInput ??
          mustResolveTextDirectionByInput,
    );
  }
}
