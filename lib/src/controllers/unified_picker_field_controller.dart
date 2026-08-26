import 'package:flutter/material.dart';

import '../fields/unified_multi_picker_sheet.dart';
import '../fields/unified_picker_item_builders.dart';
import '../fields/unified_input_theme.dart';
import '../fields/unified_picker_keyboard.dart';
import '../fields/unified_picker_sheet.dart';
import 'base_unified_field_controller.dart';

/// Controller for single-select picker fields ([UnifiedSinglePickerField], async variant).
class UnifiedPickerFieldController<T> extends BaseUnifiedFieldController<T> {
  /// Creates a single-select picker controller.
  UnifiedPickerFieldController({
    super.initialValue,
    super.validator,
    super.focusNode,
    this.valueToString,
    this.searchBuilder,
    this.itemToWidget,
    this.suggestion = const [],
    this.hasSearch = true,
    this.searchAutoFocus = false,
    this.showClearButton = true,
    this.gridItemBuilder,
    this.gridDelegate,
    this.pickerSheetStyle,
    this.pickerSheetModalSettings,
  });

  /// Sheet chrome bundle for [openPicker].
  final UnifiedPickerSheetStyle? pickerSheetStyle;

  /// Modal flags for [openPicker].
  final UnifiedPickerSheetModalSettings? pickerSheetModalSettings;

  /// Renders a value as display text.
  String Function(T value)? valueToString;

  /// Custom search text per item.
  String Function(T value)? searchBuilder;

  /// Custom row in the sheet.
  Widget Function(T value)? itemToWidget;

  /// Custom grid tile builder; when set, the sheet uses a [GridView].
  final UnifiedPickerGridItemBuilder<T>? gridItemBuilder;

  /// Grid layout when [gridItemBuilder] is set. Defaults to [unifiedPickerDefaultGridDelegate].
  final SliverGridDelegate? gridDelegate;

  /// Pinned suggestions above the list.
  final List<T> suggestion;

  /// Whether the sheet shows a search field.
  final bool hasSearch;

  /// Autofocus the search field when the sheet opens.
  final bool searchAutoFocus;

  /// Show a Clear action in the sheet header.
  final bool showClearButton;

  List<T> _boundItems = const [];
  String _boundLabel = '';

  /// Called by the bound field when [items] / label change.
  void bindPicker({required List<T> items, required String label}) {
    _boundItems = items;
    _boundLabel = label;
  }

  /// Display text for [v] or the current [value].
  String displayText([T? v]) {
    final item = v ?? value;
    if (item == null) return '';
    return unifiedPickerItemLabel(item as T, valueToString: valueToString);
  }

  /// Opens the picker sheet. When a field is bound in the widget tree, uses the
  /// same path as tapping the field (no [items] / [label] needed). Otherwise
  /// pass [items] and [label], or call [bindPicker] before opening.
  Future<T?> openPicker(
    BuildContext context, {
    List<T>? items,
    String? label,
  }) async {
    final opener = attachedFieldOpener;
    if (opener != null) {
      await opener(context);
      return value;
    }
    final resolvedItems = items ?? _boundItems;
    final resolvedLabel = label ?? _boundLabel;
    assert(
      resolvedItems.isNotEmpty,
      'UnifiedPickerFieldController.openPicker: mount the field first (same as a tap), '
      'or pass items and label.',
    );
    return _openPickerSheet(
      context,
      items: resolvedItems,
      label: resolvedLabel,
    );
  }

  Future<T?> _openPickerSheet(
    BuildContext context, {
    required List<T> items,
    required String label,
  }) async {
    unifiedUnfocusBeforeModal(context);
    final dynamic result = await showUnifiedFieldsPickerBottomSheet<dynamic>(
      context: context,
      pickerSheetStyle: pickerSheetStyle,
      modalSettings: pickerSheetModalSettings,
      builder: (c) => Padding(
        padding: EdgeInsets.zero,
        child: PickerSheetWidget<T>(
          suggestion: suggestion,
          value: value,
          searchAutoFocus: searchAutoFocus,
          hasClear: showClearButton,
          searchBuilder: searchBuilder,
          valueToString: valueToString,
          items: items,
          label: label,
          itemToWidget: itemToWidget,
          hasSearch: hasSearch,
          gridItemBuilder: gridItemBuilder,
          gridDelegate: gridDelegate,
        ),
      ),
    );

    if (!context.mounted) return null;

    if (result == Null) {
      clear();
      return null;
    }
    if (result != null) {
      value = result as T;
      return value;
    }
    return null;
  }
}

/// Controller for multi-select picker fields.
class UnifiedMultiPickerFieldController<T>
    extends BaseUnifiedFieldController<List<T>> {
  /// Creates a multi-select picker controller.
  UnifiedMultiPickerFieldController({
    List<T> initialValue = const [],
    super.validator,
    super.focusNode,
    this.valueToString,
    this.searchBuilder,
    this.itemToWidget,
    this.suggestion = const [],
    this.hasSearch = true,
    this.searchAutoFocus = false,
    this.showClearButton = true,
    this.gridItemBuilder,
    this.gridDelegate,
    this.pickerSheetStyle,
    this.pickerSheetModalSettings,
  }) : super(initialValue: List<T>.from(initialValue));

  /// Sheet chrome bundle for [openPicker].
  final UnifiedPickerSheetStyle? pickerSheetStyle;

  /// Modal flags for [openPicker].
  final UnifiedPickerSheetModalSettings? pickerSheetModalSettings;

  /// Renders a value as display text.
  String Function(T value)? valueToString;

  /// Custom search text per item.
  String Function(T value)? searchBuilder;

  /// Custom row in the sheet.
  Widget Function(T value)? itemToWidget;

  /// Custom grid tile builder; when set, the sheet uses a [GridView].
  final UnifiedPickerMultiGridItemBuilder<T>? gridItemBuilder;

  /// Grid layout when [gridItemBuilder] is set. Defaults to [unifiedPickerDefaultGridDelegate].
  final SliverGridDelegate? gridDelegate;

  /// Pinned suggestions above the list.
  final List<T> suggestion;

  /// Whether the sheet shows a search field.
  final bool hasSearch;

  /// Autofocus the search field when the sheet opens.
  final bool searchAutoFocus;

  /// Show a Clear action in the sheet header.
  final bool showClearButton;

  List<T> _boundItems = const [];
  String _boundLabel = '';

  /// Called by the bound field when [items] / label change.
  void bindPicker({required List<T> items, required String label}) {
    _boundItems = items;
    _boundLabel = label;
  }

  /// Unmodifiable copy of the current selection.
  List<T> get values => List<T>.unmodifiable(value ?? const []);

  @override
  bool get isEmpty => value == null || value!.isEmpty;

  @override
  set value(List<T>? next) {
    super.value = next == null ? null : List<T>.from(next);
  }

  /// Comma-separated display text for the current selection.
  String displayText() {
    final vs = value;
    if (vs == null || vs.isEmpty) return '';
    return vs
        .map((e) => unifiedPickerItemLabel(e, valueToString: valueToString))
        .join(', ');
  }

  /// Opens the multi picker. Uses the attached field opener when present.
  Future<List<T>?> openPicker(
    BuildContext context, {
    List<T>? items,
    String? label,
  }) async {
    final opener = attachedFieldOpener;
    if (opener != null) {
      await opener(context);
      return value == null ? null : List<T>.from(value!);
    }
    final resolvedItems = items ?? _boundItems;
    final resolvedLabel = label ?? _boundLabel;
    assert(
      resolvedItems.isNotEmpty,
      'UnifiedMultiPickerFieldController.openPicker: mount the field first (same as a tap), '
      'or pass items and label.',
    );
    return _openPickerSheet(
      context,
      items: resolvedItems,
      label: resolvedLabel,
    );
  }

  Future<List<T>?> _openPickerSheet(
    BuildContext context, {
    required List<T> items,
    required String label,
  }) async {
    unifiedUnfocusBeforeModal(context);
    final dynamic result = await showUnifiedFieldsPickerBottomSheet<dynamic>(
      context: context,
      pickerSheetStyle: pickerSheetStyle,
      modalSettings: pickerSheetModalSettings,
      builder: (c) => Padding(
        padding: EdgeInsets.zero,
        child: MultiPickerSheetWidget<T>(
          suggestion: suggestion,
          values: List<T>.from(value ?? const []),
          searchAutoFocus: searchAutoFocus,
          hasClear: showClearButton,
          searchBuilder: searchBuilder,
          valueToString: valueToString,
          items: items,
          label: label,
          itemToWidget: itemToWidget,
          hasSearch: hasSearch,
          gridItemBuilder: gridItemBuilder,
          gridDelegate: gridDelegate,
        ),
      ),
    );

    if (!context.mounted) return null;

    if (result == Null) {
      value = <T>[];
      return value;
    }
    if (result != null) {
      final raw = result as List;
      value = raw.cast<T>().toList();
      return value;
    }
    return null;
  }

  @override
  void clear() {
    value = <T>[];
    clearError();
  }
}
