import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../unified_fields_strings.dart';
import '../unified_sheet_button.dart';
import 'unified_input_theme.dart';
import 'unified_picker_item_builders.dart';
import 'unified_picker_keyboard.dart';
import 'unified_picker_list_chrome.dart';
import 'unified_picker_presentation.dart';

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
    this.searchInputFormatters,
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

  /// Optional search formatters; falls back to theme when null.
  ///
  /// When both are null, **no** formatters are applied.
  final List<TextInputFormatter>? searchInputFormatters;

  @override
  State<AsyncQueryPickerSheetWidget<T>> createState() =>
      _AsyncQueryPickerSheetWidgetState<T>();
}

class _AsyncQueryPickerSheetWidgetState<T>
    extends State<AsyncQueryPickerSheetWidget<T>> {
  final TextEditingController _searchC = TextEditingController(text: UnifiedPickerTypeAhead.take() ?? '');
  Timer? _debounce;
  int _fetchGeneration = 0;
  List<T> _items = const [];
  bool _loading = false;
  String? _errorText;

  List<TextInputFormatter> _resolvedSearchFormatters(BuildContext context) =>
      widget.searchInputFormatters ??
      UnifiedInputThemeScope.themeDataOf(context).pickerSearchInputFormatters ??
      const [];

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

  Widget _buildBody(UnifiedPickerListChrome listChrome) {
    final query = _searchC.text;
    if (query.length < widget.queryThreshold) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            widget.queryPromptMessage ??
                UnifiedFieldsStrings.instance.asyncQueryTypeToFetch,
            textAlign: TextAlign.center,
            style: listChrome.mutedTextStyle,
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
          style: listChrome.mutedTextStyle,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final isSelected = widget.value == item;
        return UnifiedPickerRow(
          selected: isSelected,
          onTap: () => Navigator.of(context).pop(item),
          child: unifiedPickerResolveListItem(
            item,
            itemToWidget: widget.itemToWidget,
            valueToString: widget.valueToString,
            textStyle: listChrome.itemTextStyle,
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
    final listChrome = UnifiedPickerListChrome.of(context);
    final surface = UnifiedResolvedPickerSurface.of(context);
    final anchored = UnifiedPickerPresentationScope.isAnchoredOf(context);
    return UnifiedPickerModalScope(
      child: UnifiedPickerFrame(
        sheetBackgroundColor: baseSheet.sheetBackgroundColor,
        sheetBorderRadius: baseSheet.sheetBorderRadius,
        textStyle: listChrome.itemTextStyle,
        listExtent: _items.isEmpty
            ? surface.rowHeight * 3
            : _items.length * surface.rowExtentFor(context) + 8,
        header: UnifiedPickerSheetHeader(
          title: widget.label,
          showClear: widget.showClearButton,
          pickerHeaderStyle: widget.pickerHeaderStyle,
        ),
        search: listChrome.buildSearchField(
          controller: _searchC,
          autofocus: widget.searchAutoFocus || anchored,
          inputFormatters: _resolvedSearchFormatters(context),
          trailing: anchored && widget.showClearButton
              ? UnifiedPickerActionButton(
                  label: UnifiedFieldsStrings.instance.clear,
                  onPressed: () => Navigator.of(context).pop(Null),
                )
              : null,
        ),
        list: _buildBody(listChrome),
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
    this.searchInputFormatters,
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

  /// Optional search formatters; falls back to theme when null.
  ///
  /// When both are null, **no** formatters are applied.
  final List<TextInputFormatter>? searchInputFormatters;

  @override
  State<AsyncQueryMultiPickerSheetWidget<T>> createState() =>
      _AsyncQueryMultiPickerSheetWidgetState<T>();
}

class _AsyncQueryMultiPickerSheetWidgetState<T>
    extends State<AsyncQueryMultiPickerSheetWidget<T>> {
  final TextEditingController _searchC = TextEditingController(text: UnifiedPickerTypeAhead.take() ?? '');
  Timer? _debounce;
  int _fetchGeneration = 0;
  List<T> _items = const [];
  bool _loading = false;
  String? _errorText;
  late List<T> _selected;

  List<TextInputFormatter> _resolvedSearchFormatters(BuildContext context) =>
      widget.searchInputFormatters ??
      UnifiedInputThemeScope.themeDataOf(context).pickerSearchInputFormatters ??
      const [];

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

  Widget _buildBody(UnifiedPickerListChrome listChrome) {
    final query = _searchC.text;
    if (query.length < widget.queryThreshold) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            widget.queryPromptMessage ??
                UnifiedFieldsStrings.instance.asyncQueryTypeToFetch,
            textAlign: TextAlign.center,
            style: listChrome.mutedTextStyle,
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
          style: listChrome.mutedTextStyle,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final isSelected = _selected.contains(item);
        return UnifiedPickerRow(
          selected: isSelected,
          showSelectedIcon: false,
          onTap: () => _toggle(item),
          leading: UnifiedMultiPickerCheckbox(value: isSelected),
          child: unifiedPickerResolveListItem(
            item,
            itemToWidget: widget.itemToWidget,
            valueToString: widget.valueToString,
            textStyle: listChrome.itemTextStyle,
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
    final listChrome = UnifiedPickerListChrome.of(context);
    final surface = UnifiedResolvedPickerSurface.of(context);
    final compact = UnifiedPickerPresentationScope.isCompactOf(context);
    final footer = compact
        ? Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
            child: Row(
              children: [
                Expanded(child: Text('${_selected.length} selected', maxLines: 1, overflow: TextOverflow.fade, softWrap: false, style: surface.mutedTextStyle)),
                UnifiedPickerActionButton(
                  label: UnifiedFieldsStrings.instance.cancel,
                  onPressed: () => Navigator.pop(context, widget.values),
                ),
                const SizedBox(width: 6),
                UnifiedPickerActionButton(
                  primary: true,
                  label: UnifiedFieldsStrings.instance.done,
                  onPressed: () => Navigator.pop(context, _selected),
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              spacing: 12,
              children: [
                Expanded(
                  child: UnifiedSheetButton(
                    label: UnifiedFieldsStrings.instance.cancel,
                    radius: 12,
                    color: listChrome.palette.borderColor,
                    reverse: true,
                    textColor: listChrome.palette.fieldTextColor,
                    borderSide: BorderSide(color: listChrome.palette.borderColor),
                    onPressed: () => Navigator.pop(context, widget.values),
                  ),
                ),
                Expanded(
                  child: UnifiedSheetButton(
                    label: UnifiedFieldsStrings.instance.confirm,
                    radius: 12,
                    onPressed: () => Navigator.pop(context, _selected),
                  ),
                ),
              ],
            ),
          );
    return UnifiedPickerModalScope(
      onConfirm: () => Navigator.pop(context, _selected),
      child: UnifiedPickerFrame(
        sheetBackgroundColor: baseSheet.sheetBackgroundColor,
        sheetBorderRadius: baseSheet.sheetBorderRadius,
        textStyle: listChrome.itemTextStyle,
        listExtent: _items.isEmpty
            ? surface.rowHeight * 3
            : _items.length * surface.rowExtentFor(context) + 8,
        header: UnifiedPickerSheetHeader(
          title: UnifiedFieldsStrings.instance.multiPickerTitle(widget.label),
          showClear: widget.showClearButton,
          onClear: () => setState(() => _selected = []),
        ),
        search: listChrome.buildSearchField(
          controller: _searchC,
          autofocus: widget.searchAutoFocus || UnifiedPickerPresentationScope.isAnchoredOf(context),
          inputFormatters: _resolvedSearchFormatters(context),
          trailing: compact && widget.showClearButton && _selected.isNotEmpty
              ? UnifiedPickerActionButton(
                  label: UnifiedFieldsStrings.instance.clear,
                  onPressed: () => setState(() => _selected = []),
                )
              : null,
        ),
        list: _buildBody(listChrome),
        footer: footer,
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
