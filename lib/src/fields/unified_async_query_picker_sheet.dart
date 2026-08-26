import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../unified_colors.dart';
import '../unified_fields_context.dart';
import '../unified_fields_strings.dart';
import '../unified_sheet_button.dart';
import 'unified_input_theme.dart';
import 'unified_picker_item_builders.dart';
import 'unified_picker_keyboard.dart';

/// Loads options for [UnifiedAsyncQueryPicker] / [showUnifiedAsyncQueryPickerSheet].
typedef UnifiedAsyncQueryFetcher<T> = Future<List<T>> Function(String query);

/// Bottom sheet: search below the header, remote results after [queryThreshold] chars.
class AsyncQueryPickerSheetWidget<T> extends StatefulWidget {
  /// Creates an async query picker sheet.
  const AsyncQueryPickerSheetWidget({
    super.key,
    required this.label,
    required this.queryFetcher,
    this.queryThreshold = 3,
    this.queryDebounce = const Duration(milliseconds: 300),
    this.queryPromptMessage,
    this.value,
    this.valueToString,
    this.itemToWidget,
    this.sheetBackgroundColor,
    this.pickerHeaderStyle,
    this.searchAutoFocus = true,
    this.showClearButton = false,
  });

  /// Sheet title.
  final String label;

  /// Called with the current search text when length ≥ [queryThreshold].
  final UnifiedAsyncQueryFetcher<T> queryFetcher;

  /// Minimum query length before [queryFetcher] runs.
  final int queryThreshold;

  /// Debounce after typing before a fetch starts.
  final Duration queryDebounce;

  /// Shown when the query is shorter than [queryThreshold].
  final String? queryPromptMessage;

  /// Highlight this value in the result list when present.
  final T? value;

  /// Display label per item.
  final String Function(T value)? valueToString;

  /// Custom list row builder.
  final Widget Function(T value)? itemToWidget;

  /// Sheet background override.
  final Color? sheetBackgroundColor;

  /// Header chrome override.
  final UnifiedInputPickerHeaderStyle? pickerHeaderStyle;

  /// Autofocus the bottom search field when the sheet opens.
  final bool searchAutoFocus;

  /// Show Clear in the sheet header.
  final bool showClearButton;

  @override
  State<AsyncQueryPickerSheetWidget<T>> createState() =>
      _AsyncQueryPickerSheetWidgetState<T>();
}

class _AsyncQueryPickerSheetWidgetState<T>
    extends State<AsyncQueryPickerSheetWidget<T>> {
  final TextEditingController _searchC = TextEditingController();
  Timer? _debounce;
  int _fetchGeneration = 0;
  List<T> _items = const [];
  bool _loading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _searchC.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchC.removeListener(_onSearchChanged);
    _searchC.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    final query = _searchC.text;
    if (query.length < widget.queryThreshold) {
      _fetchGeneration++;
      setState(() {
        _loading = false;
        _items = const [];
        _errorText = null;
      });
      return;
    }
    _debounce = Timer(widget.queryDebounce, () => _runFetch(query));
  }

  Future<void> _runFetch(String query) async {
    final generation = ++_fetchGeneration;
    setState(() {
      _loading = true;
      _errorText = null;
    });
    try {
      final results = await widget.queryFetcher(query);
      if (!mounted || generation != _fetchGeneration) return;
      setState(() {
        _items = results;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || generation != _fetchGeneration) return;
      setState(() {
        _items = const [];
        _loading = false;
        _errorText = e.toString();
      });
    }
  }

  Widget _buildBody() {
    final query = _searchC.text;
    if (query.length < widget.queryThreshold) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            widget.queryPromptMessage ??
                UnifiedFieldsStrings.instance.asyncQueryTypeToFetch,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 15),
          ),
        ),
      );
    }
    if (_loading) {
      return const Center(child: CupertinoActivityIndicator());
    }
    if (_errorText != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _errorText!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent, fontSize: 14),
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Text(
          UnifiedFieldsStrings.instance.asyncQueryNoResults,
          style: const TextStyle(color: Colors.black54, fontSize: 15),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final isSelected = widget.value == item;
        return InkWell(
          onTap: () => Navigator.of(context).pop(item),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blueAccent.withValues(alpha: 0.3)
                  : const Color(0xffF2F3F6),
              border: const Border(bottom: BorderSide(color: Colors.white)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: unifiedPickerResolveListItem(
              item,
              itemToWidget: widget.itemToWidget,
              valueToString: widget.valueToString,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseSheet = UnifiedBasePickerSheetStyle.resolve(
      context,
      pickerSheetBackgroundColor: widget.sheetBackgroundColor,
    );
    return UnifiedPickerModalScope(
      child: SafeArea(
        child: BottomSheet(
          backgroundColor: baseSheet.sheetBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: baseSheet.sheetBorderRadius!,
          ),
          constraints: BoxConstraints(
            maxHeight: context.unifiedFieldsScreenHeight * 0.9,
          ),
          enableDrag: false,
          onClosing: () {},
          builder: (context) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UnifiedPickerSheetHeader(
                  title: widget.label,
                  showClear: widget.showClearButton,
                  pickerHeaderStyle: widget.pickerHeaderStyle,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: CupertinoTextField(
                    controller: _searchC,
                    autofocus: widget.searchAutoFocus,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    prefix: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(child: _buildBody()),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Opens [AsyncQueryPickerSheetWidget] and returns the selected value, or `null`.
Future<T?> showUnifiedAsyncQueryPickerSheet<T>({
  required BuildContext context,
  required String label,
  required UnifiedAsyncQueryFetcher<T> queryFetcher,
  T? value,
  int queryThreshold = 3,
  Duration queryDebounce = const Duration(milliseconds: 300),
  String? queryPromptMessage,
  String Function(T)? valueToString,
  Widget Function(T)? itemToWidget,
  bool searchAutoFocus = true,
  bool showClearButton = false,
  Color? sheetBackgroundColor,
  UnifiedInputPickerHeaderStyle? pickerHeaderStyle,
  UnifiedPickerSheetStyle? pickerSheetStyle,
  UnifiedPickerSheetModalSettings? pickerSheetModalSettings,
}) async {
  unifiedUnfocusBeforeModal(context);
  final bg =
      sheetBackgroundColor ?? pickerSheetStyle?.pickerSheetBackgroundColor;
  final header = pickerHeaderStyle ?? pickerSheetStyle?.pickerHeaderStyle;
  return showUnifiedFieldsPickerBottomSheet<T>(
    context: context,
    pickerSheetStyle: pickerSheetStyle,
    modalSettings: pickerSheetModalSettings ?? pickerSheetStyle?.modalSettings,
    backgroundColor: bg,
    builder: (c) => AsyncQueryPickerSheetWidget<T>(
      label: label,
      queryFetcher: queryFetcher,
      queryThreshold: queryThreshold,
      queryDebounce: queryDebounce,
      queryPromptMessage: queryPromptMessage,
      value: value,
      valueToString: valueToString,
      itemToWidget: itemToWidget,
      searchAutoFocus: searchAutoFocus,
      showClearButton: showClearButton,
      sheetBackgroundColor: bg,
      pickerHeaderStyle: header,
    ),
  );
}

/// Bottom sheet: search below the header, remote multi-select with a temp selection list.
class AsyncQueryMultiPickerSheetWidget<T> extends StatefulWidget {
  /// Creates an async query multi-picker sheet.
  const AsyncQueryMultiPickerSheetWidget({
    super.key,
    required this.label,
    required this.queryFetcher,
    this.queryThreshold = 3,
    this.queryDebounce = const Duration(milliseconds: 300),
    this.queryPromptMessage,
    this.values = const [],
    this.valueToString,
    this.itemToWidget,
    this.sheetBackgroundColor,
    this.pickerHeaderStyle,
    this.searchAutoFocus = true,
    this.showClearButton = true,
  });

  /// Sheet title.
  final String label;

  /// Called with the current search text when length ≥ [queryThreshold].
  final UnifiedAsyncQueryFetcher<T> queryFetcher;

  /// Minimum query length before [queryFetcher] runs.
  final int queryThreshold;

  /// Debounce after typing before a fetch starts.
  final Duration queryDebounce;

  /// Shown when the query is shorter than [queryThreshold].
  final String? queryPromptMessage;

  /// Seeds the in-sheet temp selection.
  final List<T> values;

  /// Display label per item.
  final String Function(T value)? valueToString;

  /// Custom list row builder.
  final Widget Function(T value)? itemToWidget;

  /// Sheet background override.
  final Color? sheetBackgroundColor;

  /// Header chrome override.
  final UnifiedInputPickerHeaderStyle? pickerHeaderStyle;

  /// Autofocus the bottom search field when the sheet opens.
  final bool searchAutoFocus;

  /// Show Clear in the sheet header (clears temp selection).
  final bool showClearButton;

  @override
  State<AsyncQueryMultiPickerSheetWidget<T>> createState() =>
      _AsyncQueryMultiPickerSheetWidgetState<T>();
}

class _AsyncQueryMultiPickerSheetWidgetState<T>
    extends State<AsyncQueryMultiPickerSheetWidget<T>> {
  final TextEditingController _searchC = TextEditingController();
  Timer? _debounce;
  int _fetchGeneration = 0;
  List<T> _items = const [];
  bool _loading = false;
  String? _errorText;
  late List<T> _selected;

  @override
  void initState() {
    super.initState();
    _selected = [...widget.values];
    _searchC.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchC.removeListener(_onSearchChanged);
    _searchC.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    final query = _searchC.text;
    if (query.length < widget.queryThreshold) {
      _fetchGeneration++;
      setState(() {
        _loading = false;
        _items = const [];
        _errorText = null;
      });
      return;
    }
    _debounce = Timer(widget.queryDebounce, () => _runFetch(query));
  }

  Future<void> _runFetch(String query) async {
    final generation = ++_fetchGeneration;
    setState(() {
      _loading = true;
      _errorText = null;
    });
    try {
      final results = await widget.queryFetcher(query);
      if (!mounted || generation != _fetchGeneration) return;
      setState(() {
        _items = results;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || generation != _fetchGeneration) return;
      setState(() {
        _items = const [];
        _loading = false;
        _errorText = e.toString();
      });
    }
  }

  void _toggle(T item) {
    setState(() {
      if (_selected.contains(item)) {
        _selected.remove(item);
      } else {
        _selected.add(item);
      }
    });
  }

  Widget _buildBody() {
    final query = _searchC.text;
    if (query.length < widget.queryThreshold) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            widget.queryPromptMessage ??
                UnifiedFieldsStrings.instance.asyncQueryTypeToFetch,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 15),
          ),
        ),
      );
    }
    if (_loading) {
      return const Center(child: CupertinoActivityIndicator());
    }
    if (_errorText != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _errorText!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent, fontSize: 14),
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Text(
          UnifiedFieldsStrings.instance.asyncQueryNoResults,
          style: const TextStyle(color: Colors.black54, fontSize: 15),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final isSelected = _selected.contains(item);
        return InkWell(
          onTap: () => _toggle(item),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blueAccent.withValues(alpha: 0.3)
                  : const Color(0xffF2F3F6),
              border: const Border(bottom: BorderSide(color: Colors.white)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                UnifiedMultiPickerCheckbox(value: isSelected),
                const SizedBox(width: 8),
                Expanded(
                  child: unifiedPickerResolveListItem(
                    item,
                    itemToWidget: widget.itemToWidget,
                    valueToString: widget.valueToString,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseSheet = UnifiedBasePickerSheetStyle.resolve(
      context,
      pickerSheetBackgroundColor: widget.sheetBackgroundColor,
    );
    return UnifiedPickerModalScope(
      onConfirm: () => Navigator.pop(context, _selected),
      child: SafeArea(
        child: BottomSheet(
          backgroundColor: baseSheet.sheetBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: baseSheet.sheetBorderRadius!,
          ),
          constraints: BoxConstraints(
            maxHeight: context.unifiedFieldsScreenHeight * 0.9,
          ),
          enableDrag: false,
          onClosing: () {},
          builder: (context) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UnifiedPickerSheetHeader(
                  title: UnifiedFieldsStrings.instance.multiPickerTitle(
                    widget.label,
                  ),
                  showClear: widget.showClearButton,
                  onClear: () => setState(() => _selected = []),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: CupertinoTextField(
                    controller: _searchC,
                    autofocus: widget.searchAutoFocus,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    prefix: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(child: _buildBody()),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: UnifiedSheetButton(
                          label: UnifiedFieldsStrings.instance.cancel,
                          radius: 12,
                          color: UnifiedColors.headlineColor,
                          reverse: true,
                          textColor: Colors.black,
                          borderSide: const BorderSide(color: Colors.grey),
                          onPressed: () {
                            Navigator.pop(context, widget.values);
                          },
                        ),
                      ),
                      Expanded(
                        child: UnifiedSheetButton(
                          label: UnifiedFieldsStrings.instance.confirm,
                          radius: 12,
                          onPressed: () {
                            Navigator.pop(context, _selected);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Opens [AsyncQueryMultiPickerSheetWidget] and returns the confirmed selection.
Future<List<T>?> showUnifiedAsyncQueryMultiPickerSheet<T>({
  required BuildContext context,
  required String label,
  required UnifiedAsyncQueryFetcher<T> queryFetcher,
  List<T> values = const [],
  int queryThreshold = 3,
  Duration queryDebounce = const Duration(milliseconds: 300),
  String? queryPromptMessage,
  String Function(T)? valueToString,
  Widget Function(T)? itemToWidget,
  bool searchAutoFocus = true,
  bool showClearButton = true,
  Color? sheetBackgroundColor,
  UnifiedInputPickerHeaderStyle? pickerHeaderStyle,
  UnifiedPickerSheetStyle? pickerSheetStyle,
  UnifiedPickerSheetModalSettings? pickerSheetModalSettings,
}) async {
  unifiedUnfocusBeforeModal(context);
  final bg =
      sheetBackgroundColor ?? pickerSheetStyle?.pickerSheetBackgroundColor;
  final header = pickerHeaderStyle ?? pickerSheetStyle?.pickerHeaderStyle;
  final dynamic result = await showUnifiedFieldsPickerBottomSheet<dynamic>(
    context: context,
    pickerSheetStyle: pickerSheetStyle,
    modalSettings: pickerSheetModalSettings ?? pickerSheetStyle?.modalSettings,
    backgroundColor: bg,
    builder: (c) => AsyncQueryMultiPickerSheetWidget<T>(
      label: label,
      queryFetcher: queryFetcher,
      queryThreshold: queryThreshold,
      queryDebounce: queryDebounce,
      queryPromptMessage: queryPromptMessage,
      values: values,
      valueToString: valueToString,
      itemToWidget: itemToWidget,
      searchAutoFocus: searchAutoFocus,
      showClearButton: showClearButton,
      sheetBackgroundColor: bg,
      pickerHeaderStyle: header,
    ),
  );
  if (result == Null) return <T>[];
  if (result is List<T>) return result;
  if (result is List) return result.cast<T>().toList();
  return null;
}
