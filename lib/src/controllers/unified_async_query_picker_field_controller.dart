import 'package:material_ui/material_ui.dart';

import '../fields/unified_async_query_picker_sheet.dart';
import 'unified_picker_field_controller.dart';

/// Controller for [UnifiedAsyncQueryPicker].
class UnifiedAsyncQueryPickerFieldController<T>
    extends UnifiedPickerFieldController<T> {
  /// Creates an async query picker controller.
  ///
  /// [queryFetcher] is supplied by the bound [UnifiedAsyncQueryPicker] via
  /// [bindAsyncQueryPicker]; do not pass it here.
  UnifiedAsyncQueryPickerFieldController({
    super.initialValue,
    super.validator,
    super.focusNode,
    this.queryThreshold = 3,
    this.queryDebounce = const Duration(milliseconds: 300),
    this.queryPromptMessage,
    super.valueToString,
    super.itemToWidget,
    super.searchAutoFocus = true,
    super.showClearButton = false,
  });

  UnifiedAsyncQueryFetcher<T>? _queryFetcher;
  String _boundLabel = '';

  /// Minimum query length before the bound field's [queryFetcher] runs.
  int queryThreshold;

  /// Debounce between keystrokes and fetch.
  Duration queryDebounce;

  /// Sheet hint when the query is too short.
  String? queryPromptMessage;

  /// Called by [UnifiedAsyncQueryPicker] when label / query settings change.
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

  /// Opens the query picker sheet (same as tapping the bound field).
  Future<T?> openQueryPicker(BuildContext context, {String? label}) async {
    final opener = attachedFieldOpener;
    if (opener != null) {
      await opener(context);
      return value;
    }
    final fetcher = _queryFetcher;
    assert(
      fetcher != null,
      'UnifiedAsyncQueryPickerFieldController.openQueryPicker: mount the field first '
      '(same as a tap), or call bindAsyncQueryPicker with queryFetcher from the widget.',
    );
    if (!context.mounted || fetcher == null) return value;
    return showUnifiedAsyncQueryPickerSheet<T>(
      context: context,
      label: label ?? _boundLabel,
      queryFetcher: fetcher,
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
