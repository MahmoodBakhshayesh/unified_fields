import 'package:flutter/material.dart';

/// Builds a single-select picker cell in a [GridView] sheet.
///
/// [index] is the index in the filtered item list. Call [onSelect] to choose
/// the item and close the sheet.
typedef UnifiedPickerGridItemBuilder<T> = Widget Function(
  BuildContext context,
  int index,
  T item,
  VoidCallback onSelect,
);

/// Builds a multi-select picker cell in a [GridView] sheet.
///
/// [index] is the index in the filtered item list. Call [onSelect] to toggle
/// selection (the sheet stays open until the user confirms).
typedef UnifiedPickerMultiGridItemBuilder<T> = Widget Function(
  BuildContext context,
  int index,
  T item,
  bool isSelected,
  VoidCallback onSelect,
);

/// Default [SliverGridDelegate] for picker grid sheets when [gridDelegate] is omitted.
///
/// Uses [SliverGridDelegateWithFixedCrossAxisCount]. For [SliverGridDelegateWithMaxCrossAxisExtent],
/// [SliverGridDelegateWithFixedCrossAxisCount], or custom delegates, pass [gridDelegate] on the field or sheet.
SliverGridDelegate unifiedPickerDefaultGridDelegate({
  int crossAxisCount = 2,
  double childAspectRatio = 1,
  double crossAxisSpacing = 8,
  double mainAxisSpacing = 8,
}) =>
    SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
    );

/// Resolves the grid delegate used when [gridItemBuilder] is set.
SliverGridDelegate unifiedPickerResolveGridDelegate(SliverGridDelegate? gridDelegate) =>
    gridDelegate ?? unifiedPickerDefaultGridDelegate();

/// Display label for a picker item (field text + default list rows).
String unifiedPickerItemLabel<T>(
  T value, {
  String Function(T value)? valueToString,
}) =>
    valueToString?.call(value) ?? value.toString();

/// Default list-row widget when [itemToWidget] is omitted on picker fields/sheets.
Widget unifiedPickerDefaultItemWidget<T>(
  T value, {
  String Function(T)? valueToString,
  TextStyle? style,
  TextAlign textAlign = TextAlign.start,
  int? maxLines,
  TextOverflow? overflow,
}) =>
    Text(
      unifiedPickerItemLabel(value, valueToString: valueToString),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );

/// [itemToWidget] when provided, otherwise [unifiedPickerDefaultItemWidget].
Widget unifiedPickerResolveListItem<T>(
  T value, {
  Widget Function(T value)? itemToWidget,
  String Function(T value)? valueToString,
  TextStyle? textStyle,
  TextAlign textAlign = TextAlign.start,
}) =>
    itemToWidget?.call(value) ??
    unifiedPickerDefaultItemWidget(
      value,
      valueToString: valueToString,
      style: textStyle,
      textAlign: textAlign,
    );
