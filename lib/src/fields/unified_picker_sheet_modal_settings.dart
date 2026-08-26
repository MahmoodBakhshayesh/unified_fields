import 'package:flutter/material.dart';

import 'unified_input_theme.dart';
import 'unified_picker_keyboard.dart';

/// Modal presentation flags for picker bottom sheets ([showModalBottomSheet]).
///
/// Set on [UnifiedInputThemeData.pickerSheetModalSettings], per field via
/// [UnifiedPickerSheetStyle.modalSettings], or [pickerSheetModalSettings] on
/// picker fields. Field-level values win over the bundle, then theme, then
/// [defaults].
@immutable
class UnifiedPickerSheetModalSettings {
  /// Creates optional modal bottom-sheet overrides.
  const UnifiedPickerSheetModalSettings({
    this.isScrollControlled,
    this.isDismissible,
    this.enableDrag,
    this.useSafeArea,
    this.showDragHandle,
  });

  /// Passed to [showModalBottomSheet.isScrollControlled].
  final bool? isScrollControlled;

  /// Passed to [showModalBottomSheet.isDismissible] (tap outside / back).
  final bool? isDismissible;

  /// Passed to [showModalBottomSheet.enableDrag].
  final bool? enableDrag;

  /// Passed to [showModalBottomSheet.useSafeArea].
  final bool? useSafeArea;

  /// Passed to [showModalBottomSheet.showDragHandle].
  final bool? showDragHandle;

  /// Package defaults for list / wheel picker sheets.
  static const UnifiedPickerSheetModalSettings defaults =
      UnifiedPickerSheetModalSettings(
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        useSafeArea: true,
        showDragHandle: false,
      );

  /// Merges [other] on top of this (non-null fields from [other] win).
  UnifiedPickerSheetModalSettings merge(
    UnifiedPickerSheetModalSettings? other,
  ) {
    if (other == null) return this;
    return UnifiedPickerSheetModalSettings(
      isScrollControlled: other.isScrollControlled ?? isScrollControlled,
      isDismissible: other.isDismissible ?? isDismissible,
      enableDrag: other.enableDrag ?? enableDrag,
      useSafeArea: other.useSafeArea ?? useSafeArea,
      showDragHandle: other.showDragHandle ?? showDragHandle,
    );
  }

  /// Theme → [pickerSheetStyle.modalSettings] → [fieldOverride] → [legacyIsDismissible].
  static UnifiedPickerSheetModalSettings resolve(
    BuildContext context, {
    UnifiedPickerSheetModalSettings? fieldOverride,
    UnifiedPickerSheetStyle? pickerSheetStyle,
    bool? legacyIsDismissible,
  }) {
    final theme = UnifiedInputThemeScope.themeDataOf(
      context,
    ).pickerSheetModalSettings;
    final merged = defaults
        .merge(theme)
        .merge(pickerSheetStyle?.modalSettings)
        .merge(fieldOverride);

    final dismissible = legacyIsDismissible ?? merged.isDismissible ?? true;
    final drag = merged.enableDrag ?? dismissible;

    return UnifiedPickerSheetModalSettings(
      isScrollControlled: merged.isScrollControlled ?? true,
      isDismissible: dismissible,
      enableDrag: drag,
      useSafeArea: merged.useSafeArea ?? true,
      showDragHandle: merged.showDragHandle ?? false,
    );
  }
}

/// Opens a picker bottom sheet using resolved modal flags (and optional shape).
Future<T?> showUnifiedFieldsPickerBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  UnifiedPickerSheetStyle? pickerSheetStyle,
  UnifiedPickerSheetModalSettings? modalSettings,
  bool? legacyIsDismissible,
  ShapeBorder? shape,
  Color? backgroundColor,
  Clip? clipBehavior,
}) {
  final modal = UnifiedPickerSheetModalSettings.resolve(
    context,
    pickerSheetStyle: pickerSheetStyle,
    fieldOverride: modalSettings,
    legacyIsDismissible: legacyIsDismissible,
  );

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: modal.isScrollControlled!,
    isDismissible: modal.isDismissible!,
    enableDrag: modal.enableDrag!,
    useSafeArea: modal.useSafeArea!,
    showDragHandle: modal.showDragHandle!,
    shape: shape,
    backgroundColor: backgroundColor,
    clipBehavior: clipBehavior ?? Clip.antiAlias,
    builder: (ctx) => UnifiedPickerModalScope(child: builder(ctx)),
  );
}
