import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../unified_fields_context.dart';
import '../unified_colors.dart';
import '../unified_fields_strings.dart';
import '../unified_sheet_button.dart';
import 'unified_input_theme.dart';
import 'unified_picker_item_builders.dart';
import 'unified_picker_keyboard.dart';

/// Bottom-sheet content used by [UnifiedMultiPickerField] for multi-selection.
class MultiPickerSheetWidget<T> extends StatefulWidget {
  /// Choices shown in the sheet.
  final List<T> items;

  /// Suggestion list pinned above the searchable list.
  final List<T> suggestion;

  /// Sheet title.
  final String label;

  /// Whether the sheet shows a search field.
  final bool hasSearch;

  /// Whether the sheet shows the Clear action in the header.
  final bool hasClear;

  /// Autofocus the search field on open.
  final bool searchAutoFocus;

  /// Current selection used to seed the sheet.
  final List<T> values;

  /// Optional widget rendered above the list, below the title.
  final Widget? headerWidget;

  /// Custom row builder; defaults to [unifiedPickerDefaultItemWidget] using [valueToString].
  final Widget Function(T)? itemToWidget;

  /// Display/search label per item; defaults to [Object.toString].
  final String Function(T)? valueToString;

  /// Custom searchable text per item (defaults to [valueToString]).
  final String Function(T)? searchBuilder;

  /// When set, items render in a [GridView] via this builder instead of a list.
  final UnifiedPickerMultiGridItemBuilder<T>? gridItemBuilder;

  /// Grid layout when [gridItemBuilder] is set. Defaults to [unifiedPickerDefaultGridDelegate].
  final SliverGridDelegate? gridDelegate;

  /// Sheet background; overrides [UnifiedInputThemeData.pickerSheetBackgroundColor].
  final Color? sheetBackgroundColor;

  /// Header chrome; merged with theme [UnifiedInputThemeData.pickerHeaderStyle].
  final UnifiedInputPickerHeaderStyle? pickerHeaderStyle;

  /// Creates a multi-picker sheet.
  const MultiPickerSheetWidget({
    super.key,
    required this.items,
    this.headerWidget,
    required this.suggestion,
    required this.label,
    required this.hasClear,
    this.itemToWidget,
    this.valueToString,
    required this.values,
    required this.searchAutoFocus,
    this.searchBuilder,
    required this.hasSearch,
    this.gridItemBuilder,
    this.gridDelegate,
    this.sheetBackgroundColor,
    this.pickerHeaderStyle,
  });

  @override
  State<MultiPickerSheetWidget<T>> createState() =>
      _MultiPickerSheetWidgetState<T>();
}

class _MultiPickerSheetWidgetState<T> extends State<MultiPickerSheetWidget<T>> {
  final TextEditingController searchC = TextEditingController();
  final FocusNode _sheetFocusNode = FocusNode(
    debugLabel: 'MultiPickerSheetWidget',
  );
  final FocusNode _searchFocusNode = FocusNode(
    debugLabel: 'MultiPickerSheetWidgetSearch',
  );
  bool autoPop = false;
  List<T> selected = [];
  int _highlight = -1;
  List<T> _visibleItems = const [];

  bool get _keyboardNavEnabled => widget.gridItemBuilder == null;

  @override
  void initState() {
    selected = [...widget.values];
    super.initState();
    searchC.addListener(() {
      _highlight = searchC.text.isEmpty ? -1 : 0;
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.hasSearch && widget.searchAutoFocus) {
        _searchFocusNode.requestFocus();
        return;
      }
      _sheetFocusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(covariant MultiPickerSheetWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values) {
      selected = [...widget.values];
    }
  }

  @override
  void dispose() {
    _sheetFocusNode.dispose();
    _searchFocusNode.dispose();
    searchC.dispose();
    super.dispose();
  }

  void _toggle(T item) {
    if (selected.contains(item)) {
      selected.remove(item);
    } else {
      selected.add(item);
    }
    setState(() {});
  }

  void _confirm() => Navigator.of(context).pop(selected);

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!_keyboardNavEnabled) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final traverse = unifiedPickerTraversalDelta(event);
    if (traverse != null) {
      if (_searchFocusNode.hasFocus) {
        _sheetFocusNode.requestFocus();
      }
      _moveHighlight(traverse);
      return KeyEventResult.handled;
    }
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.space) {
      if (_highlight >= 0 && _highlight < _visibleItems.length) {
        _toggle(_visibleItems[_highlight]);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    return KeyEventResult.ignored;
  }

  void _moveHighlight(int delta) {
    final items = _visibleItems;
    if (items.isEmpty) return;
    final raw = _highlight < 0
        ? (delta > 0 ? 0 : items.length - 1)
        : _highlight + delta;
    final next = unifiedPickerWrapIndex(raw, items.length);
    if (next == _highlight) return;
    setState(() => _highlight = next);
  }

  String _searchLabel(T item) =>
      widget.searchBuilder?.call(item) ??
      unifiedPickerItemLabel(item, valueToString: widget.valueToString);

  List<T> _filteredSorted() {
    final query = searchC.text.toLowerCase();

    final filtered = widget.items
        .where(
          (a) =>
              query.isEmpty ||
              _searchLabel(
                a,
              ).toLowerCase().split(' ').any((sp) => sp.startsWith(query)),
        )
        .toList();

    if (query.isNotEmpty) {
      filtered.sort((a, b) {
        var comp = _searchLabel(a)
            .toLowerCase()
            .indexOf(query)
            .compareTo(_searchLabel(b).toLowerCase().indexOf(query));
        if (comp == 0) {
          return _searchLabel(a).compareTo(_searchLabel(b));
        }
        return comp;
      });
    }
    return filtered.where((a) => !widget.suggestion.contains(a)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredSorted();
    _visibleItems = items;
    if (_highlight >= items.length) _highlight = items.length - 1;
    // if (items.length == 1 && !autoPop) {
    //   autoPop = true;
    //   Future.delayed(Duration(milliseconds: 300), () {
    //     Navigator.of(context).pop(items.first);
    //   });
    // }
    // if (widget.suggestion.isNotEmpty &&
    //     items.isEmpty &&
    //     widget.suggestion.where((a) => searchC.text.toLowerCase().isEmpty || (widget.searchBuilder?.call(a) ?? a.toString()).toLowerCase().split(' ').any((sp) => sp.startsWith(searchC.text.toLowerCase()))).toList().length == 1 &&
    //     !autoPop) {
    //   autoPop = true;
    //   Future.delayed(Duration(milliseconds: 300), () {
    //     Navigator.of(context).pop(widget.suggestion.first);
    //   });
    // }
    final baseSheet = UnifiedBasePickerSheetStyle.resolve(
      context,
      pickerSheetBackgroundColor: widget.sheetBackgroundColor,
    );
    return UnifiedPickerModalScope(
      onConfirm: _confirm,
      child: Focus(
        focusNode: _sheetFocusNode,
        skipTraversal: true,
        onKeyEvent: _handleKeyEvent,
        child: SafeArea(
          child: BottomSheet(
            backgroundColor: baseSheet.sheetBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: baseSheet.sheetBorderRadius!,
            ),
            constraints: BoxConstraints(
              maxHeight: context.unifiedFieldsScreenHeight * 0.9,
            ),
            // The outer showModalBottomSheet already owns drag-to-dismiss and the
            // animation controller. Disabling drag here avoids the
            // `BottomSheet.animationController cannot be null` assertion.
            enableDrag: false,
            onClosing: () {},
            builder: (BuildContext context) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UnifiedPickerSheetHeader(
                    title: UnifiedFieldsStrings.instance.multiPickerTitle(
                      widget.label,
                    ),
                    showClear: widget.hasClear,
                    pickerHeaderStyle: widget.pickerHeaderStyle,
                  ),
                  if (widget.headerWidget != null) widget.headerWidget!,
                  // Search
                  if (widget.hasSearch)
                    CupertinoTextField(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      controller: searchC,
                      focusNode: _searchFocusNode,
                      autofocus: widget.searchAutoFocus,
                      prefix: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.search),
                      ),
                    ),

                  // List
                  Column(
                    children: widget.suggestion.map((s) {
                      return InkWell(
                        onTap: () => Navigator.of(context).pop(s),
                        child: Container(
                          decoration: BoxDecoration(
                            color: UnifiedColors.mainGreen.withValues(
                              alpha: 0.18,
                            ),
                            border: const Border(
                              bottom: BorderSide(color: Colors.white),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: unifiedPickerResolveListItem(
                                  s,
                                  itemToWidget: widget.itemToWidget,
                                  valueToString: widget.valueToString,
                                ),
                              ),
                              Text(
                                UnifiedFieldsStrings.instance.suggestion,
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  Expanded(child: _buildItemBody(context, items)),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
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
                            borderSide: BorderSide(color: Colors.grey),
                            onPressed: () {
                              Navigator.pop(context, widget.values);
                            },
                          ),
                        ),
                        Expanded(
                          child: UnifiedSheetButton(
                            label: UnifiedFieldsStrings.instance.confirm,
                            radius: 12,
                            onPressed: _confirm,
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
      ),
    );
  }

  Widget _buildItemBody(BuildContext context, List<T> items) {
    final gridBuilder = widget.gridItemBuilder;
    if (gridBuilder != null) {
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: unifiedPickerResolveGridDelegate(widget.gridDelegate),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = selected.contains(item);
          return gridBuilder(context, index, item, isSelected, () {
            setState(() {
              if (isSelected) {
                selected.remove(item);
              } else {
                selected.add(item);
              }
            });
          });
        },
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (c, i) {
        final item = items[i];
        final isSelected = selected.contains(item);
        final isHighlighted = i == _highlight;
        return InkWell(
          canRequestFocus: false,
          onTap: () => _toggle(item),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blueAccent.withValues(alpha: 0.3)
                  : (isHighlighted
                        ? Colors.blueAccent.withValues(alpha: 0.12)
                        : const Color(0xffF2F3F6)),
              border: Border(
                bottom: const BorderSide(color: Colors.white),
                left: isHighlighted
                    ? const BorderSide(color: Colors.blueAccent, width: 3)
                    : BorderSide.none,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
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
}

/// Shows a multi-select picker bottom sheet and returns the chosen values.
Future<List<T>?> showUnifiedMultiPickerSheet<T>({
  required BuildContext context,
  required List<T> items,
  required String label,
  List<T> values = const [],
  List<T> suggestion = const [],
  bool hasSearch = true,
  bool hasClear = true,
  bool searchAutoFocus = false,
  String Function(T)? searchBuilder,
  String Function(T)? valueToString,
  Widget Function(T)? itemToWidget,
  UnifiedPickerMultiGridItemBuilder<T>? gridItemBuilder,
  SliverGridDelegate? gridDelegate,
  Widget? headerWidget,
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
    builder: (c) => Padding(
      padding: EdgeInsets.zero,
      child: MultiPickerSheetWidget<T>(
        items: items,
        suggestion: suggestion,
        values: values,
        searchAutoFocus: searchAutoFocus,
        hasClear: hasClear,
        searchBuilder: searchBuilder,
        valueToString: valueToString,
        label: label,
        itemToWidget: itemToWidget,
        hasSearch: hasSearch,
        headerWidget: headerWidget,
        gridItemBuilder: gridItemBuilder,
        gridDelegate: gridDelegate,
        sheetBackgroundColor: bg,
        pickerHeaderStyle: header,
      ),
    ),
  );
  if (result == Null) return <T>[];
  if (result is List<T>) return result;
  if (result is List) return result.cast<T>().toList();
  return null;
}
