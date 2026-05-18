import 'package:flutter/material.dart';

import 'unified_picker_field_controller.dart';

/// Controller for [UnifiedAsyncPickerField].
class UnifiedAsyncPickerFieldController<T>
    extends UnifiedPickerFieldController<T> {
  /// Creates an async single-select picker controller.
  UnifiedAsyncPickerFieldController({
    super.initialValue,
    super.validator,
    super.focusNode,
    required this.itemProvider,
    super.valueToString,
    super.searchBuilder,
    super.itemToWidget,
    super.gridItemBuilder,
    super.gridDelegate,
    super.suggestion,
    super.hasSearch,
    super.searchAutoFocus,
    super.showClearButton,
  });

  /// Loads choices when the picker opens without an attached field.
  final Future<List<T>> Function() itemProvider;

  String _boundLabel = '';

  /// Sheet title used when opening without an attached field.
  void bindPickerLabel(String label) {
    _boundLabel = label;
  }

  /// Opens the async picker. Uses the attached field when present (same as tap).
  Future<T?> openPickerAsync(BuildContext context, {String? label}) async {
    final opener = attachedFieldOpener;
    if (opener != null) {
      await opener(context);
      return value;
    }
    final loaded = await itemProvider();
    if (!context.mounted) return null;
    return super.openPicker(
      context,
      items: loaded,
      label: label ?? _boundLabel,
    );
  }

  @override
  Future<T?> openPicker(
    BuildContext context, {
    List<T>? items,
    String? label,
  }) => openPickerAsync(context, label: label);
}

/// Controller for [UnifiedAsyncMultiPickerField].
class UnifiedAsyncMultiPickerFieldController<T>
    extends UnifiedMultiPickerFieldController<T> {
  /// Creates an async multi-select picker controller.
  UnifiedAsyncMultiPickerFieldController({
    super.initialValue,
    super.validator,
    super.focusNode,
    required this.itemProvider,
    super.valueToString,
    super.searchBuilder,
    super.itemToWidget,
    super.gridItemBuilder,
    super.gridDelegate,
    super.suggestion,
    super.hasSearch,
    super.searchAutoFocus,
    super.showClearButton,
  });

  /// Loads choices when the picker opens without an attached field.
  final Future<List<T>> Function() itemProvider;

  String _boundLabel = '';

  /// Sheet title used when opening without an attached field.
  void bindPickerLabel(String label) {
    _boundLabel = label;
  }

  /// Opens the async multi picker. Uses the attached field when present (same as tap).
  Future<List<T>?> openPickerAsync(
    BuildContext context, {
    String? label,
  }) async {
    final opener = attachedFieldOpener;
    if (opener != null) {
      await opener(context);
      return value == null ? null : List<T>.from(value!);
    }
    final loaded = await itemProvider();
    if (!context.mounted) return null;
    return super.openPicker(
      context,
      items: loaded,
      label: label ?? _boundLabel,
    );
  }

  @override
  Future<List<T>?> openPicker(
    BuildContext context, {
    List<T>? items,
    String? label,
  }) => openPickerAsync(context, label: label);
}
