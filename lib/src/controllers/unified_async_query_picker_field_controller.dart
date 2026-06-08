import 'package:flutter/material.dart';

import '../fields/unified_async_query_picker_sheet.dart';
import 'unified_picker_field_controller.dart';

/// Controller for [UnifiedAsyncQueryPicker].
class UnifiedAsyncQueryPickerFieldController<T>
    extends UnifiedPickerFieldController<T> {
  /// Creates an async query picker controller.
  UnifiedAsyncQueryPickerFieldController({
    super.initialValue,
    super.validator,
    super.focusNode,
    required this.queryFetcher,
    this.queryThreshold = 3,
    this.queryDebounce = const Duration(milliseconds: 300),
    this.queryPromptMessage,
    super.valueToString,
    super.itemToWidget,
    super.searchAutoFocus = true,
    super.showClearButton = false,
  });

  /// Remote search function (mutable when the parent widget updates).
  UnifiedAsyncQueryFetcher<T> queryFetcher;

  String _boundLabel = '';

  /// Minimum query length before [queryFetcher] runs.
  int queryThreshold;

  /// Debounce between keystrokes and fetch.
  Duration queryDebounce;

  /// Sheet hint when the query is too short.
  String? queryPromptMessage;

  /// Remembers the field label for [openQueryPicker] when no [label] is passed.
  void bindPickerLabel(String label) => _boundLabel = label;

  /// Opens the query picker sheet (same as tapping the bound field).
  Future<T?> openQueryPicker(BuildContext context, {String? label}) async {
    final opener = attachedFieldOpener;
    if (opener != null) {
      await opener(context);
      return value;
    }
    if (!context.mounted) return value;
    return showUnifiedAsyncQueryPickerSheet<T>(
      context: context,
      label: label ?? _boundLabel,
      queryFetcher: queryFetcher,
      queryThreshold: queryThreshold,
      queryDebounce: queryDebounce,
      queryPromptMessage: queryPromptMessage,
      value: value,
      valueToString: valueToString,
      itemToWidget: itemToWidget,
      searchAutoFocus: searchAutoFocus,
      showClearButton: showClearButton,
    );
  }

  @override
  Future<T?> openPicker(
    BuildContext context, {
    List<T>? items,
    String? label,
  }) =>
      openQueryPicker(context, label: label);
}
