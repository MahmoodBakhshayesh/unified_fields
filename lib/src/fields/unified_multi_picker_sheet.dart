import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../unified_fields_context.dart';
import '../unified_colors.dart';
import '../unified_fields_strings.dart';
import '../unified_sheet_button.dart';
import 'unified_input_theme.dart';
import 'unified_picker_item_builders.dart';

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

  /// Custom row builder; defaults to a [Text] of [searchBuilder] or `toString`.
  final Widget Function(T)? itemToWidget;

  /// Custom searchable text per item.
  final String Function(T)? searchBuilder;

  /// When set, items render in a [GridView] via this builder instead of a list.
  final UnifiedPickerMultiGridItemBuilder<T>? gridItemBuilder;

  /// Grid layout when [gridItemBuilder] is set. Defaults to [unifiedPickerDefaultGridDelegate].
  final SliverGridDelegate? gridDelegate;

  /// Creates a multi-picker sheet.
  const MultiPickerSheetWidget({
    super.key,
    required this.items,
    this.headerWidget,
    required this.suggestion,
    required this.label,
    required this.hasClear,
    this.itemToWidget,
    required this.values,
    required this.searchAutoFocus,
    this.searchBuilder,
    required this.hasSearch,
    this.gridItemBuilder,
    this.gridDelegate,
  });

  @override
  State<MultiPickerSheetWidget<T>> createState() =>
      _MultiPickerSheetWidgetState<T>();
}

class _MultiPickerSheetWidgetState<T> extends State<MultiPickerSheetWidget<T>> {
  final TextEditingController searchC = TextEditingController();
  bool autoPop = false;
  List<T> selected = [];

  @override
  void initState() {
    selected = [...widget.values];
    super.initState();
    searchC.addListener(() => setState(() {}));
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
    searchC.dispose();
    super.dispose();
  }

  List<T> _filteredSorted() {
    final query = searchC.text.toLowerCase();

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
    return filtered.where((a) => !widget.suggestion.contains(a)).toList();
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
    // if (widget.suggestion.isNotEmpty &&
    //     items.isEmpty &&
    //     widget.suggestion.where((a) => searchC.text.toLowerCase().isEmpty || (widget.searchBuilder?.call(a) ?? a.toString()).toLowerCase().split(' ').any((sp) => sp.startsWith(searchC.text.toLowerCase()))).toList().length == 1 &&
    //     !autoPop) {
    //   autoPop = true;
    //   Future.delayed(Duration(milliseconds: 300), () {
    //     Navigator.of(context).pop(widget.suggestion.first);
    //   });
    // }
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
                title: UnifiedFieldsStrings.instance.multiPickerTitle(
                  widget.label,
                ),
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
                        color: UnifiedColors.mainGreen.withValues(alpha: 0.18),
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
                        onPressed: () {
                          Navigator.pop(context, selected);
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
          return gridBuilder(
            context,
            index,
            item,
            isSelected,
            () {
              setState(() {
                if (isSelected) {
                  selected.remove(item);
                } else {
                  selected.add(item);
                }
              });
            },
          );
        },
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (c, i) {
        final item = items[i];
        final isSelected = selected.contains(item);
        return InkWell(
          onTap: () {
            if (isSelected) {
              selected.remove(item);
            } else {
              selected.add(item);
            }
            setState(() {});
          },
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
                UnifiedMultiPickerCheckbox(value: isSelected),
                const SizedBox(width: 8),
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
  Widget Function(T)? itemToWidget,
  UnifiedPickerMultiGridItemBuilder<T>? gridItemBuilder,
  SliverGridDelegate? gridDelegate,
  Widget? headerWidget,
}) async {
  FocusScope.of(context).requestFocus(FocusNode());
  final dynamic result = await showModalBottomSheet<dynamic>(
    context: context,
    isScrollControlled: true,
    builder: (c) => Padding(
      padding: EdgeInsets.zero,
      child: MultiPickerSheetWidget<T>(
        items: items,
        suggestion: suggestion,
        values: values,
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
  if (result == Null) return <T>[];
  if (result is List<T>) return result;
  if (result is List) return result.cast<T>().toList();
  return null;
}
