import 'package:flutter/material.dart';

import '../fields/unified_async_query_picker_sheet.dart';
import 'unified_picker_field_controller.dart';

/// Controller for [UnifiedAsyncQueryMultiPicker].
class UnifiedAsyncQueryMultiPickerFieldController<T>
    extends UnifiedMultiPickerFieldController<T> {
  /// Creates an async query multi-picker controller.
  ///
  /// [queryFetcher] is supplied by the bound [UnifiedAsyncQueryMultiPicker] via
  /// [bindAsyncQueryPicker]; do not pass it here.
  UnifiedAsyncQueryMultiPickerFieldController({
    super.initialValue,
    super.validator,
    super.focusNode,
    this.queryThreshold = 3,
    this.queryDebounce = const Duration(milliseconds: 300),
    this.queryPromptMessage,
    super.valueToString,
    super.itemToWidget,
    super.searchAutoFocus = true,
    super.showClearButton = true,
  });

  UnifiedAsyncQueryFetcher<T>? _queryFetcher;
  String _boundLabel = '';

  /// Minimum query length before the bound field's [queryFetcher] runs.
  int queryThreshold;

  /// Debounce between keystrokes and fetch.
  Duration queryDebounce;

  /// Sheet hint when the query is too short.
  String? queryPromptMessage;

  /// Called by [UnifiedAsyncQueryMultiPicker] when label / query settings change.
  void bindAsyncQueryPicker({
    required String label,
    required UnifiedAsyncQueryFetcher<T> queryFetcher,
    required int queryThreshold,
    required Duration queryDebounce,
    String? queryPromptMessage,
  }) {
    _boundLabel = label;
    _queryFetcher = queryFetcher;
    this.queryThreshold = queryThreshold;
    this.queryDebounce = queryDebounce;
    this.queryPromptMessage = queryPromptMessage;
  }

  /// Opens the async query multi-picker sheet (same as tapping the bound field).
  Future<List<T>?> openQueryPicker(BuildContext context, {String? label}) async {
    final opener = attachedFieldOpener;
    if (opener != null) {
      await opener(context);
      return value == null ? null : List<T>.from(value!);
    }
    final fetcher = _queryFetcher;
    assert(
      fetcher != null,
      'UnifiedAsyncQueryMultiPickerFieldController.openQueryPicker: mount the field first '
      '(same as a tap), or call bindAsyncQueryPicker with queryFetcher from the widget.',
    );
    if (!context.mounted || fetcher == null) {
      return value == null ? null : List<T>.from(value!);
    }
    return showUnifiedAsyncQueryMultiPickerSheet<T>(
      context: context,
      label: label ?? _boundLabel,
      queryFetcher: fetcher,
      queryThreshold: queryThreshold,
      queryDebounce: queryDebounce,
      queryPromptMessage: queryPromptMessage,
      values: List<T>.from(value ?? const []),
      valueToString: valueToString,
      itemToWidget: itemToWidget,
      searchAutoFocus: searchAutoFocus,
      showClearButton: showClearButton,
    );
  }

  @override
  Future<List<T>?> openPicker(
    BuildContext context, {
    List<T>? items,
    String? label,
  }) =>
      openQueryPicker(context, label: label);
}
