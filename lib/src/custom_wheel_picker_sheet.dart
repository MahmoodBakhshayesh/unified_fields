import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'custom_wheel_picker_types.dart';
import 'fields/unified_input_brightness.dart';
import 'fields/unified_input_palette.dart';
import 'fields/unified_input_theme.dart';
import 'unified_date_wheel_style.dart';
import 'unified_fields_strings.dart';
import 'unified_wheel_scroll_behavior.dart';

/// Multi-column scroll-wheel picker sheet for [CustomWheelPicker].
///
/// Pass [columns] as `{0: columnA, 1: columnB, …}` and optional [value] with the
/// same keys. Returns a [CustomWheelPickerValue] on confirm.
class CustomWheelPickerSheet extends StatefulWidget {
  /// Creates a custom multi-wheel picker sheet.
  CustomWheelPickerSheet({
    super.key,
    required this.columns,
    this.value = const {},
    this.title,
    this.confirmLabel,
    this.wheelLayout = CustomWheelPickerWheelLayout.vertical,
    this.wheelStyle,
    this.pickerSheetStyle,
    this.pickerSheetBackgroundColor,
    this.pickerHeaderStyle,
  }) : assert(columns.isNotEmpty, 'columns must not be empty');

  /// Wheels keyed by column index.
  final Map<int, CustomWheelPickerColumn> columns;

  /// Initial selection per column index.
  final CustomWheelPickerValue value;

  /// Sheet title (falls back to package default).
  final String? title;

  /// Confirm button label.
  final String? confirmLabel;

  /// Vertical columns in a row, or horizontal wheels stacked.
  final CustomWheelPickerWheelLayout wheelLayout;

  /// Wheel chrome; themed from context when null.
  final UnifiedFieldsDateWheelStyle? wheelStyle;

  /// Sheet chrome bundle (background, padding, panel colors).
  final UnifiedPickerSheetStyle? pickerSheetStyle;

  /// Sheet background override.
  final Color? pickerSheetBackgroundColor;

  /// Header chrome override.
  final UnifiedInputPickerHeaderStyle? pickerHeaderStyle;

  @override
  State<CustomWheelPickerSheet> createState() => _CustomWheelPickerSheetState();
}

/// Opens [CustomWheelPickerSheet] and returns the picked value map, or `null`.
Future<CustomWheelPickerValue?> showCustomWheelPicker({
  required BuildContext context,
  required Map<int, CustomWheelPickerColumn> columns,
  CustomWheelPickerValue value = const {},
  String? title,
  String? confirmLabel,
  CustomWheelPickerWheelLayout wheelLayout =
      CustomWheelPickerWheelLayout.vertical,
  UnifiedFieldsDateWheelStyle? wheelStyle,
  UnifiedPickerSheetStyle? pickerSheetStyle,
  Color? pickerSheetBackgroundColor,
  UnifiedInputPickerHeaderStyle? pickerHeaderStyle,
  UnifiedPickerSheetModalSettings? pickerSheetModalSettings,
  bool? barrierDismissible,
}) {
  final base = UnifiedBasePickerSheetStyle.resolve(
    context,
    pickerSheetStyle: pickerSheetStyle,
    pickerSheetBackgroundColor: pickerSheetBackgroundColor,
  );
  final modal = UnifiedPickerSheetModalSettings.resolve(
    context,
    pickerSheetStyle: pickerSheetStyle,
    fieldOverride: pickerSheetModalSettings,
    legacyIsDismissible: barrierDismissible,
  );
  return showModalBottomSheet<CustomWheelPickerValue>(
    context: context,
    isScrollControlled: modal.isScrollControlled!,
    isDismissible: modal.isDismissible!,
    enableDrag: modal.enableDrag!,
    showDragHandle: modal.showDragHandle!,
    // Safe area is applied inside the clipped sheet so the sheet background
    // does not paint square corners below the modal shape.
    useSafeArea: modal.useSafeArea!,
    backgroundColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: base.sheetBorderRadius!),
    clipBehavior: Clip.antiAlias,
    builder: (ctx) {
      final bottomInset = modal.useSafeArea!
          ? 0.0
          : MediaQuery.viewPaddingOf(ctx).bottom;
      final child = CustomWheelPickerSheet(
          columns: columns,
          value: value,
          title: title,
          confirmLabel: confirmLabel,
          wheelLayout: wheelLayout,
          wheelStyle: wheelStyle,
          pickerSheetStyle: pickerSheetStyle,
          pickerSheetBackgroundColor: pickerSheetBackgroundColor,
          pickerHeaderStyle: pickerHeaderStyle,
        );
      if (bottomInset <= 0) return child;
      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: child,
      );
    },
  );
}

class _CustomWheelPickerSheetState extends State<CustomWheelPickerSheet> {
  late final List<int> _keys;
  late final Map<int, int> _indices;
  late final List<FixedExtentScrollController> _verticalControllers;
  late final List<ScrollController> _horizontalControllers;

  static const double _kHeaderHeight = 36;
  static const double _kHorizontalItemWidth = 80;
  static const double _kHorizontalSpacing = 8;
  static const double _kHorizontalRowHeight = 52;

  @override
  void initState() {
    super.initState();
    _keys = sortedCustomWheelPickerColumnKeys(widget.columns);
    _indices = {
      for (final k in _keys)
        k: widget.columns[k]!.indexForValue(widget.value[k]),
    };
    _verticalControllers = List.generate(
      _keys.length,
      (i) {
        final key = _keys[i];
        return FixedExtentScrollController(initialItem: _indices[key]!);
      },
    );
    _horizontalControllers = List.generate(
      _keys.length,
      (i) => ScrollController(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var i = 0; i < _keys.length; i++) {
        _scrollHorizontalToIndex(i, _indices[_keys[i]]!, animate: false);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _verticalControllers) {
      c.dispose();
    }
    for (final c in _horizontalControllers) {
      c.dispose();
    }
    super.dispose();
  }

  CustomWheelPickerValue get _currentValue =>
      customWheelPickerValueFromIndices(widget.columns, _indices);

  void _setIndex(int columnKey, int index) {
    setState(() => _indices[columnKey] = index);
  }

  double _horizontalStride() => _kHorizontalItemWidth + _kHorizontalSpacing;

  void _scrollHorizontalToIndex(int columnIndex, int itemIndex,
      {bool animate = true}) {
    final controller = _horizontalControllers[columnIndex];
    if (!controller.hasClients) return;
    final target = itemIndex * _horizontalStride();
    final clamped = target.clamp(0.0, controller.position.maxScrollExtent);
    if (animate) {
      controller.animateTo(
        clamped,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    } else {
      controller.jumpTo(clamped);
    }
  }

  void _snapHorizontalColumn(int columnIndex) {
    final controller = _horizontalControllers[columnIndex];
    if (!controller.hasClients) return;
    final key = _keys[columnIndex];
    final count = widget.columns[key]!.options.length;
    if (count <= 0) return;
    final index =
        (controller.offset / _horizontalStride()).round().clamp(0, count - 1);
    _scrollHorizontalToIndex(columnIndex, index);
    _setIndex(key, index);
  }

  void _onHorizontalPointerSignal(int columnIndex, PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final controller = _horizontalControllers[columnIndex];
    if (!controller.hasClients) return;
    final delta =
        event.scrollDelta.dx != 0 ? event.scrollDelta.dx : event.scrollDelta.dy;
    if (delta == 0) return;
    controller.jumpTo(
      (controller.offset + delta)
          .clamp(0.0, controller.position.maxScrollExtent),
    );
  }

  void _onVerticalPointerSignal(
    int controllerIndex,
    int columnKey,
    int count,
    PointerSignalEvent event,
  ) {
    if (event is! PointerScrollEvent) return;
    final controller = _verticalControllers[controllerIndex];
    if (!controller.hasClients || count <= 0) return;
    final delta = event.scrollDelta.dy;
    if (delta == 0) return;
    final step = delta > 0 ? 1 : -1;
    final next = (controller.selectedItem + step).clamp(0, count - 1);
    if (next == controller.selectedItem) return;
    controller.animateToItem(
      next,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
    );
    _setIndex(columnKey, next);
  }

  BoxDecoration _panelDecoration(
    UnifiedFieldsDateWheelStyle style,
    UnifiedBasePickerSheetStyle base,
  ) {
    return BoxDecoration(
      color: style.wheelBackground,
      borderRadius: BorderRadius.circular(style.cornerRadius!),
      border: Border.all(
        color: base.panelBorderColor ?? style.columnDivider!,
        width: base.panelBorderWidth ?? 1,
      ),
    );
  }

  UnifiedInputPalette _palette(Brightness b) =>
      UnifiedInputThemeResolver.paletteFor(
        b == Brightness.dark
            ? UnifiedInputBrightness.dark
            : UnifiedInputBrightness.light,
      );

  Widget _columnHeader(String label, UnifiedFieldsDateWheelStyle style) {
    return SizedBox(
      height: _kHeaderHeight,
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 0.2,
            color: style.headerTextColor!,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _wheelLabel({
    required Object? value,
    required CustomWheelPickerColumn column,
    required UnifiedFieldsDateWheelStyle style,
    required double itemExtent,
  }) {
    if (column.itemBuilder != null) {
      return SizedBox(
        height: itemExtent,
        width: double.infinity,
        child: Center(child: column.itemBuilder!(context, value)),
      );
    }
    return SizedBox(
      height: itemExtent,
      width: double.infinity,
      child: Center(
        child: Text(
          column.labelFor(value),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 17,
            height: 1.0,
            color: style.itemTextColor!,
          ),
        ),
      ),
    );
  }

  Widget _verticalWheel({
    required int columnKey,
    required int controllerIndex,
    required CustomWheelPickerColumn column,
    required UnifiedFieldsDateWheelStyle style,
  }) {
    final count = column.options.length;
    if (count <= 0) return const SizedBox.shrink();
    return Listener(
      onPointerSignal: (e) =>
          _onVerticalPointerSignal(controllerIndex, columnKey, count, e),
      child: ScrollConfiguration(
        behavior: UnifiedFieldsWheelScrollBehavior.of(context),
        child: ListWheelScrollView.useDelegate(
          controller: _verticalControllers[controllerIndex],
          itemExtent: style.itemExtent!,
          diameterRatio: style.diameterRatio!,
          magnification: style.magnification!,
          squeeze: style.squeeze!,
          useMagnifier: true,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: (index) => _setIndex(columnKey, index),
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: count,
            builder: (context, index) {
              if (index < 0 || index >= count) return null;
              return _wheelLabel(
                value: column.options[index],
                column: column,
                style: style,
                itemExtent: style.itemExtent!,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _horizontalChip({
    required int index,
    required int columnKey,
    required int controllerIndex,
    required CustomWheelPickerColumn column,
    required UnifiedFieldsDateWheelStyle style,
    required bool scrollable,
  }) {
    final selected = _indices[columnKey] == index;
    final chipHeight = _kHorizontalRowHeight - 8;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(style.selectionRadius!),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (scrollable) {
            _scrollHorizontalToIndex(controllerIndex, index);
          }
          _setIndex(columnKey, index);
        },
        child: Ink(
          width: _kHorizontalItemWidth,
          height: chipHeight,
          decoration: BoxDecoration(
            color: selected
                ? style.selectionFill
                : style.wheelBackground?.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(style.selectionRadius!),
            border: Border.all(
              color: selected
                  ? style.selectionBorder!
                  : style.columnDivider!,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: _wheelLabel(
            value: column.options[index],
            column: column,
            style: style,
            itemExtent: chipHeight,
          ),
        ),
      ),
    );
  }

  Widget _horizontalWheelRow({
    required int columnKey,
    required int controllerIndex,
    required CustomWheelPickerColumn column,
    required UnifiedFieldsDateWheelStyle style,
  }) {
    final count = column.options.length;
    if (count <= 0) return const SizedBox.shrink();
    final controller = _horizontalControllers[controllerIndex];
    final contentWidth = count * _kHorizontalItemWidth +
        (count > 1 ? (count - 1) * _kHorizontalSpacing : 0);

    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalPadding = 24.0;
        final fits = contentWidth <= constraints.maxWidth - horizontalPadding;

        if (fits) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < count; i++) ...[
                    if (i > 0) const SizedBox(width: _kHorizontalSpacing),
                    _horizontalChip(
                      index: i,
                      columnKey: columnKey,
                      controllerIndex: controllerIndex,
                      column: column,
                      style: style,
                      scrollable: false,
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return Listener(
          onPointerSignal: (e) =>
              _onHorizontalPointerSignal(controllerIndex, e),
          child: NotificationListener<ScrollEndNotification>(
            onNotification: (_) {
              _snapHorizontalColumn(controllerIndex);
              return false;
            },
            child: ScrollConfiguration(
              behavior: UnifiedFieldsWheelScrollBehavior.of(context),
              child: ListView.separated(
                controller: controller,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: count,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: _kHorizontalSpacing),
                itemBuilder: (context, index) => _horizontalChip(
                  index: index,
                  columnKey: columnKey,
                  controllerIndex: controllerIndex,
                  column: column,
                  style: style,
                  scrollable: true,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _wheelFade({
    required UnifiedFieldsDateWheelStyle style,
    required bool top,
    required bool vertical,
  }) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: vertical
                ? (top ? Alignment.topCenter : Alignment.bottomCenter)
                : (top ? Alignment.centerLeft : Alignment.centerRight),
            end: vertical
                ? (top ? Alignment.bottomCenter : Alignment.topCenter)
                : (top ? Alignment.centerRight : Alignment.centerLeft),
            colors: [style.fadeColor!, style.fadeColor!.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }

  Widget _selectionOverlay(UnifiedFieldsDateWheelStyle style) {
    final bandHeight = style.itemExtent!;
    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: Align(
            alignment: Alignment.center,
            child: Container(
              height: bandHeight,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: style.selectionFill!,
                borderRadius: BorderRadius.circular(style.selectionRadius!),
              ),
            ),
          ),
        ),
        IgnorePointer(
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: bandHeight,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(height: 1.5, color: style.selectionBorder!),
                  Container(height: 1.5, color: style.selectionBorder!),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _verticalPanel(
    UnifiedFieldsDateWheelStyle style,
    UnifiedBasePickerSheetStyle base,
  ) {
    final wheelsHeight = style.wheelHeight! - _kHeaderHeight;

    return Padding(
      padding: base.contentPadding!,
      child: Padding(
        padding: base.panelPadding!,
        child: DecoratedBox(
          decoration: _panelDecoration(style, base),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(style.cornerRadius!),
            child: SizedBox(
              height: style.wheelHeight!,
              child: Column(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: style.headerDivider!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        for (var i = 0; i < _keys.length; i++) ...[
                          Expanded(
                            flex: widget.columns[_keys[i]]!.flex,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: i < _keys.length - 1
                                    ? BorderDirectional(
                                        end: BorderSide(
                                          color: style.columnDivider!,
                                          width: 1,
                                        ),
                                      )
                                    : null,
                              ),
                              child: _columnHeader(
                                widget.columns[_keys[i]]!.label ?? '',
                                style,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(
                    height: wheelsHeight,
                    child: Stack(
                      children: [
                        Row(
                          children: [
                            for (var i = 0; i < _keys.length; i++) ...[
                              Expanded(
                                flex: widget.columns[_keys[i]]!.flex,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    border: i < _keys.length - 1
                                        ? BorderDirectional(
                                            end: BorderSide(
                                              color: style.columnDivider!,
                                              width: 1,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: _verticalWheel(
                                    columnKey: _keys[i],
                                    controllerIndex: i,
                                    column: widget.columns[_keys[i]]!,
                                    style: style,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        _selectionOverlay(style),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: wheelsHeight * 0.34,
                        child: _wheelFade(
                          style: style,
                          top: true,
                          vertical: true,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: wheelsHeight * 0.34,
                        child: _wheelFade(
                          style: style,
                          top: false,
                          vertical: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _horizontalPanel(
    UnifiedFieldsDateWheelStyle style,
    UnifiedBasePickerSheetStyle base,
  ) {
    final rowCount = _keys.length;
    final panelHeight =
        _kHeaderHeight * rowCount + _kHorizontalRowHeight * rowCount + 16;

    return Padding(
      padding: base.contentPadding!,
      child: Padding(
        padding: base.panelPadding!,
        child: DecoratedBox(
          decoration: _panelDecoration(style, base),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(style.cornerRadius!),
            child: SizedBox(
              height: panelHeight.clamp(style.wheelHeight! * 0.5, 420),
              child: Column(
                children: [
                  for (var i = 0; i < _keys.length; i++) ...[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: style.headerDivider!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: _columnHeader(
                        widget.columns[_keys[i]]!.label ?? '',
                        style,
                      ),
                    ),
                    SizedBox(
                      height: _kHorizontalRowHeight,
                      child: _horizontalWheelRow(
                        columnKey: _keys[i],
                        controllerIndex: i,
                        column: widget.columns[_keys[i]]!,
                        style: style,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  UnifiedFieldsDateWheelStyle? _wheelStyleWithBase(
    UnifiedFieldsDateWheelStyle? wheelStyle,
    UnifiedBasePickerSheetStyle base,
  ) {
    final panelRadius = base.panelBorderRadius?.topLeft.x;
    if (wheelStyle == null &&
        base.panelBackgroundColor == null &&
        panelRadius == null &&
        base.panelBorderColor == null) {
      return null;
    }
    return UnifiedFieldsDateWheelStyle(
      wheelBackground: base.panelBackgroundColor,
      cornerRadius: panelRadius,
      columnDivider: base.panelBorderColor,
    ).merge(wheelStyle);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = _palette(theme.brightness);
    final strings = UnifiedFieldsStrings.instance;
    final baseSheet = UnifiedBasePickerSheetStyle.resolve(
      context,
      palette: palette,
      pickerSheetStyle: widget.pickerSheetStyle,
      pickerSheetBackgroundColor: widget.pickerSheetBackgroundColor,
    );
    final wheelStyle = UnifiedFieldsDateWheelStyle.forPicker(
      palette,
      theme,
      overrides: _wheelStyleWithBase(widget.wheelStyle, baseSheet),
      context: context,
    );
    final titleText = (widget.title ?? '').trim();

    return ClipRRect(
      borderRadius: baseSheet.sheetBorderRadius!,
      child: Material(
        color: baseSheet.sheetBackgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UnifiedPickerSheetHeader(
              title: titleText.isEmpty ? 'Choose' : titleText,
              pickerHeaderStyle: widget.pickerHeaderStyle,
              sheetBorderRadius: baseSheet.sheetBorderRadius,
            ),
          if (widget.wheelLayout == CustomWheelPickerWheelLayout.vertical)
            _verticalPanel(wheelStyle, baseSheet)
          else
            _horizontalPanel(wheelStyle, baseSheet),
          Padding(
            padding: baseSheet.footerPadding!,
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(strings.cancel),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(_currentValue),
                  child: Text(widget.confirmLabel ?? strings.confirm),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}
