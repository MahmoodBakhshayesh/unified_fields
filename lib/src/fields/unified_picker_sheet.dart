import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../unified_fields_context.dart';
import '../unified_fields_strings.dart';
import 'unified_input_theme.dart';
import 'unified_picker_item_builders.dart';
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

  /// Custom row builder; defaults to a [Text] of [searchBuilder] or `toString`.
  final Widget Function(T)? itemToWidget;

  /// Custom searchable text per item.
  final String Function(T)? searchBuilder;

  /// When set, items render in a [GridView] via this builder instead of a list.
  final UnifiedPickerGridItemBuilder<T>? gridItemBuilder;

  /// Grid layout when [gridItemBuilder] is set. Defaults to [unifiedPickerDefaultGridDelegate].
  final SliverGridDelegate? gridDelegate;

  /// Creates a single-picker sheet.
  const PickerSheetWidget({
    super.key,
    required this.items,
    this.headerWidget,
    required this.suggestion,
    required this.label,
    required this.hasClear,
    this.itemToWidget,
    required this.value,
    required this.searchAutoFocus,
    this.searchBuilder,
    required this.hasSearch,
    this.gridItemBuilder,
    this.gridDelegate,
  });

  @override
  State<PickerSheetWidget<T>> createState() => _PickerSheetWidgetState<T>();
}

class _PickerSheetWidgetState<T> extends State<PickerSheetWidget<T>> {
  final TextEditingController searchC = TextEditingController();
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _positionsListener =
      ItemPositionsListener.create();
  bool autoPop = false;

  @override
  void initState() {
    super.initState();
    searchC.addListener(() {
      if (searchC.text.isNotEmpty) {
        _scrollToTop();
      }
      setState(() {});
    });
    if (widget.gridItemBuilder == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
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
    searchC.dispose();
    super.dispose();
  }

  List<T> _filteredSorted() {
    final query = searchC.text.toLowerCase();
    // dev.log(widget.items.first.toString());
    // dev.log(widget.searchBuilder!(widget.items.first));
    // dev.log((widget.searchBuilder?.call(widget.items.first) ?? widget.items.first.toString()).toLowerCase().indexOf(query).toString());

    final filtered = widget.items
        .where(
          (a) =>
              query.isEmpty ||
              (widget.searchBuilder?.call(a) ?? a.toString())
                  .toLowerCase()
                  .split(' ')
                  .any((sp) => sp.startsWith(query)),
        )
        .toList();

    // same sort rule you had: by match position
    if (query.isNotEmpty) {
      filtered.sort((a, b) {
        var comp = (widget.searchBuilder?.call(a) ?? a.toString())
            .toLowerCase()
            .indexOf(query)
            .compareTo(
              (widget.searchBuilder?.call(b) ?? b.toString())
                  .toLowerCase()
                  .indexOf(query),
            );
        if (comp == 0) {
          return (widget.searchBuilder?.call(a) ?? a.toString()).compareTo(
            (widget.searchBuilder?.call(b) ?? b.toString()),
          );
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
    final sheetBg = UnifiedInputThemeResolver.resolvePickerSheetBackground(context);
    return SafeArea(
      child: BottomSheet(
        backgroundColor: sheetBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                            child:
                                widget.itemToWidget?.call(s) ??
                                Text(s.toString()),
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
        return InkWell(
          onTap: () => Navigator.of(context).pop(item),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blueAccent.withValues(alpha: 0.3)
                  : const Color(0xffF2F3F6),
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
                  child:
                      widget.itemToWidget?.call(item) ??
                      Text(item.toString()),
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
  Widget Function(T)? itemToWidget,
  UnifiedPickerGridItemBuilder<T>? gridItemBuilder,
  SliverGridDelegate? gridDelegate,
  Widget? headerWidget,
}) async {
  FocusScope.of(context).requestFocus(FocusNode());
  final dynamic result = await showModalBottomSheet<dynamic>(
    context: context,
    isScrollControlled: true,
    builder: (c) => Padding(
      padding: EdgeInsets.zero,
      child: PickerSheetWidget<T>(
        items: items,
        suggestion: suggestion,
        value: value,
        searchAutoFocus: searchAutoFocus,
        hasClear: hasClear,
        searchBuilder: searchBuilder,
        label: label,
        itemToWidget: itemToWidget,
        hasSearch: hasSearch,
        headerWidget: headerWidget,
        gridItemBuilder: gridItemBuilder,
        gridDelegate: gridDelegate,
      ),
    ),
  );
  if (result == Null) return null;
  return result as T?;
}
