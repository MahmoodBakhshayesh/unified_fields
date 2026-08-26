import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../unified_fields_context.dart';
import '../unified_fields_strings.dart';
import 'unified_input_theme.dart';
import 'unified_picker_item_builders.dart';
import 'unified_picker_keyboard.dart';
import '../scrollable_list/item_positions_listener.dart';
import '../scrollable_list/scrollable_positioned_list.dart';

/// Bottom-sheet content used by [UnifiedSinglePickerField] for single-selection.
class PickerSheetWidget<T> extends StatefulWidget {
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

  /// Currently selected value (highlights the row on open).
  final T? value;

  /// Optional widget rendered above the list, below the title.
  final Widget? headerWidget;

  /// Custom row builder; defaults to [unifiedPickerDefaultItemWidget] using [valueToString].
  final Widget Function(T)? itemToWidget;

  /// Display/search label per item; defaults to [Object.toString].
  final String Function(T)? valueToString;

  /// Custom searchable text per item (defaults to [valueToString] / [unifiedPickerItemLabel]).
  final String Function(T)? searchBuilder;

  /// When set, items render in a [GridView] via this builder instead of a list.
  final UnifiedPickerGridItemBuilder<T>? gridItemBuilder;

  /// Grid layout when [gridItemBuilder] is set. Defaults to [unifiedPickerDefaultGridDelegate].
  final SliverGridDelegate? gridDelegate;

  /// Sheet background; overrides [UnifiedInputThemeData.pickerSheetBackgroundColor].
  final Color? sheetBackgroundColor;

  /// Header chrome; merged with theme [UnifiedInputThemeData.pickerHeaderStyle].
  final UnifiedInputPickerHeaderStyle? pickerHeaderStyle;

  /// Creates a single-picker sheet.
  const PickerSheetWidget({
    super.key,
    required this.items,
    this.headerWidget,
    required this.suggestion,
    required this.label,
    required this.hasClear,
    this.itemToWidget,
    this.valueToString,
    required this.value,
    required this.searchAutoFocus,
    this.searchBuilder,
    required this.hasSearch,
    this.gridItemBuilder,
    this.gridDelegate,
    this.sheetBackgroundColor,
    this.pickerHeaderStyle,
  });

  @override
  State<PickerSheetWidget<T>> createState() => _PickerSheetWidgetState<T>();
}

class _PickerSheetWidgetState<T> extends State<PickerSheetWidget<T>> {
  final TextEditingController searchC = TextEditingController();
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _positionsListener =
      ItemPositionsListener.create();
  final FocusNode _sheetFocusNode = FocusNode(debugLabel: 'PickerSheetWidget');
  final FocusNode _searchFocusNode = FocusNode(
    debugLabel: 'PickerSheetWidgetSearch',
  );
  bool autoPop = false;

  /// Keyboard-highlighted row in the filtered list; `-1` when none.
  int _highlight = -1;
  List<T> _visibleItems = const [];

  /// Grid tiles are app-built, so highlight chrome / scroll-to-row only apply
  /// to the list layout.
  bool get _keyboardNavEnabled => widget.gridItemBuilder == null;

  @override
  void initState() {
    super.initState();
    searchC.addListener(() {
      if (searchC.text.isNotEmpty) {
        _scrollToTop();
      }
      // Enter picks the best match while a query is active.
      _highlight = searchC.text.isEmpty ? -1 : 0;
      setState(() {});
    });
    if (widget.gridItemBuilder == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusOnOpen());
  }

  /// Takes keyboard focus so arrows / Enter work right after the sheet opens.
  /// The search field is only focused when [PickerSheetWidget.searchAutoFocus]
  /// asks for it, so phones do not get an unexpected soft keyboard.
  void _focusOnOpen() {
    if (!mounted) return;
    if (widget.hasSearch && widget.searchAutoFocus) {
      _searchFocusNode.requestFocus();
      return;
    }
    _sheetFocusNode.requestFocus();
  }

  @override
  void didUpdateWidget(covariant PickerSheetWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gridItemBuilder != null) return;
    if (oldWidget.value != widget.value || oldWidget.items != widget.items) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  @override
  void dispose() {
    _sheetFocusNode.dispose();
    _searchFocusNode.dispose();
    searchC.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!_keyboardNavEnabled) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final traverse = unifiedPickerTraversalDelta(event);
    if (traverse != null) {
      if (_searchFocusNode.hasFocus) {
        _sheetFocusNode.requestFocus();
      }
      _moveHighlight(traverse);
      return KeyEventResult.handled;
    }
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      if (_highlight < 0 || _highlight >= _visibleItems.length) {
        // No highlight: leave Enter to the search field / focused row.
        return KeyEventResult.ignored;
      }
      Navigator.of(context).pop(_visibleItems[_highlight]);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      Navigator.of(context).maybePop();
      return KeyEventResult.handled;
    }
    return _typeToSearch(event);
  }

  /// Typing while the sheet (not the search field) holds focus starts a query,
  /// so desktop users do not have to click the search box first.
  KeyEventResult _typeToSearch(KeyEvent event) {
    if (!widget.hasSearch || !_sheetFocusNode.hasPrimaryFocus) {
      return KeyEventResult.ignored;
    }
    final character = event.character;
    if (character == null ||
        character.length != 1 ||
        character.trim().isEmpty ||
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed ||
        HardwareKeyboard.instance.isAltPressed) {
      return KeyEventResult.ignored;
    }
    _searchFocusNode.requestFocus();
    final next = '${searchC.text}$character';
    searchC.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
    return KeyEventResult.handled;
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
    _scrollToHighlight(next);
  }

  void _scrollToHighlight(int index) {
    if (!_itemScrollController.isAttached) return;
    if (_isIndexFullyVisible(index)) return;
    _itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      alignment: 0.3,
    );
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
    // dev.log(filtered.first.toString());
    // dev.log(widget.searchBuilder!(filtered.first));
    // dev.log((widget.searchBuilder?.call(filtered.first) ?? filtered.first.toString()).toLowerCase().indexOf(query).toString());
    return filtered;
  }

  void _scrollToSelected() {
    if (!mounted || widget.value == null) return;

    final items = _filteredSorted(); // <- your filtered list
    final idx = items.indexOf(widget.value as T);
    if (idx < 0) return;

    // Defer until laid out so positions are available
    if (!_itemScrollController.isAttached ||
        _positionsListener.itemPositions.value.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
      return;
    }

    // If everything fits, don't scroll
    if (_listFitsInViewport(items.length)) {
      return;
    }

    // If already fully visible, don't scroll
    if (_isIndexFullyVisible(idx)) {
      return;
    }

    _itemScrollController.scrollTo(
      index: idx,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.1,
    );
  }

  void _scrollToTop() {
    if (!mounted || widget.value == null) return;

    final items = _filteredSorted(); // <- your filtered list
    final idx = 0;
    // Defer until laid out so positions are available
    if (!_itemScrollController.isAttached ||
        _positionsListener.itemPositions.value.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
      return;
    }

    // If everything fits, don't scroll
    if (_listFitsInViewport(items.length)) {
      return;
    }

    // If already fully visible, don't scroll
    if (_isIndexFullyVisible(idx)) {
      return;
    }

    _itemScrollController.scrollTo(
      index: idx,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.1,
    );
  }

  bool _listFitsInViewport(int itemCount) {
    final positions = _positionsListener.itemPositions.value;
    if (positions.isEmpty) return false; // not laid out yet

    // Is the first item fully visible?
    final first = positions.where((p) => p.index == 0).toList();
    // Is the last item fully visible?
    final last = positions.where((p) => p.index == itemCount - 1).toList();

    if (first.isNotEmpty && last.isNotEmpty) {
      final firstFullyVisible = first.any(
        (p) => p.itemLeadingEdge >= 0 && p.itemTrailingEdge <= 1,
      );
      final lastFullyVisible = last.any(
        (p) => p.itemLeadingEdge >= 0 && p.itemTrailingEdge <= 1,
      );
      return firstFullyVisible && lastFullyVisible;
    }
    return false;
  }

  bool _isIndexFullyVisible(int index) {
    final positions = _positionsListener.itemPositions.value;
    if (positions.isEmpty) return false;
    return positions.any(
      (p) =>
          p.index == index && p.itemLeadingEdge >= 0 && p.itemTrailingEdge <= 1,
    );
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
    if (widget.suggestion.isNotEmpty &&
        items.isEmpty &&
        widget.suggestion
                .where(
                  (a) =>
                      searchC.text.toLowerCase().isEmpty ||
                      (widget.searchBuilder?.call(a) ?? a.toString())
                          .toLowerCase()
                          .split(' ')
                          .any(
                            (sp) => sp.startsWith(searchC.text.toLowerCase()),
                          ),
                )
                .toList()
                .length ==
            1 &&
        !autoPop) {
      autoPop = true;
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!context.mounted) return;
        Navigator.of(context).pop(widget.suggestion.first);
      });
    }
    final baseSheet = UnifiedBasePickerSheetStyle.resolve(
      context,
      pickerSheetBackgroundColor: widget.sheetBackgroundColor,
    );
    final sheet = SafeArea(
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
                title: widget.label,
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
                  onSubmitted: (a) {
                    if (a.isEmpty && widget.suggestion.isNotEmpty) {
                      Navigator.of(context).pop(widget.suggestion.first);
                    }
                  },
                  prefix: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.search),
                  ),
                ),

              // List
              Column(
                children: widget.suggestion.map((s) {
                  return InkWell(
                    canRequestFocus: false,
                    onTap: () => Navigator.of(context).pop(s),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(8),
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
            ],
          );
        },
      ),
    );
    return UnifiedPickerModalScope(
      child: Focus(
        focusNode: _sheetFocusNode,
        skipTraversal: true,
        onKeyEvent: _handleKeyEvent,
        child: sheet,
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
          return gridBuilder(
            context,
            index,
            item,
            () => Navigator.of(context).pop(item),
          );
        },
      );
    }

    return ScrollablePositionedList.builder(
      padding: const EdgeInsets.only(bottom: 400),
      itemScrollController: _itemScrollController,
      itemPositionsListener: _positionsListener,
      itemCount: items.length,
      itemBuilder: (c, i) {
        final item = items[i];
        final isSelected = widget.value == item;
        final isHighlighted = i == _highlight;
        return InkWell(
          canRequestFocus: false,
          onTap: () => Navigator.of(context).pop(item),
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

/// Shows a single-select picker bottom sheet and returns the chosen value (or `null`).
Future<T?> showUnifiedSinglePickerSheet<T>({
  required BuildContext context,
  required List<T> items,
  required String label,
  T? value,
  List<T> suggestion = const [],
  bool hasSearch = true,
  bool hasClear = true,
  bool searchAutoFocus = false,
  String Function(T)? searchBuilder,
  String Function(T)? valueToString,
  Widget Function(T)? itemToWidget,
  UnifiedPickerGridItemBuilder<T>? gridItemBuilder,
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
      child: PickerSheetWidget<T>(
        items: items,
        suggestion: suggestion,
        value: value,
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
  if (result == Null) return null;
  return result as T?;
}
