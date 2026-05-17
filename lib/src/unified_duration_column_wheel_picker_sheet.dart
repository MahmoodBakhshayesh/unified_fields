import 'package:flutter/material.dart';

import 'fields/unified_input_brightness.dart';
import 'fields/unified_input_palette.dart';
import 'fields/unified_input_theme.dart';
import 'unified_date_picker_types.dart';
import 'unified_date_wheel_style.dart';
import 'unified_duration_columns.dart';
import 'unified_fields_strings.dart';
import 'unified_fields_typography.dart';
import 'unified_wheel_scroll_behavior.dart';

/// Styled scroll-wheel duration picker with custom [columns] (e.g. year · week · day · hour).
class UnifiedFieldsDurationColumnWheelPickerSheet extends StatefulWidget {
  /// Creates a multi-column duration wheel sheet.
  const UnifiedFieldsDurationColumnWheelPickerSheet({
    super.key,
    required this.columns,
    required this.initial,
    required this.maxDuration,
    this.title,
    this.confirmLabel,
    this.showCalendarKindToggle = true,
    this.initialCalendarKind = UnifiedFieldsCalendarKind.gregorian,
    this.wheelStyle,
    this.onConfirmedCalendarKind,
  }) : assert(columns.length > 0, 'columns must not be empty');

  /// Column order (largest unit left → smallest right).
  final List<UnifiedFieldsDurationColumn> columns;

  /// Initial total duration.
  final Duration initial;

  /// Maximum total duration (per-column max derived from this).
  final Duration maxDuration;

  /// Optional title.
  final String? title;

  /// Confirm label; defaults to [UnifiedFieldsStrings.done].
  final String? confirmLabel;

  /// Gregorian / Shamsi digit toggle.
  final bool showCalendarKindToggle;

  /// Starting digit / label mode for wheel labels and numerals.
  final UnifiedFieldsCalendarKind initialCalendarKind;

  /// Optional wheel chrome; auto-themed from context when null.
  final UnifiedFieldsDateWheelStyle? wheelStyle;

  /// Called when the user confirms with the active calendar kind.
  final ValueChanged<UnifiedFieldsCalendarKind>? onConfirmedCalendarKind;

  @override
  State<UnifiedFieldsDurationColumnWheelPickerSheet> createState() =>
      _UnifiedFieldsDurationColumnWheelPickerSheetState();
}

class _UnifiedFieldsDurationColumnWheelPickerSheetState
    extends State<UnifiedFieldsDurationColumnWheelPickerSheet> {
  late List<int> _values;
  late UnifiedFieldsCalendarKind _kind;
  late List<FixedExtentScrollController> _controllers;

  String _digitText(String text) => UnifiedFieldsTypography.instance
      .localizeDigits(text, calendarKind: _kind);

  TextStyle _digitStyle(TextStyle style) => UnifiedFieldsTypography.instance
      .mergeDigitStyle(style, calendarKind: _kind);

  @override
  void initState() {
    super.initState();
    _kind = widget.initialCalendarKind;
    _values = decomposeUnifiedDuration(widget.initial, widget.columns);
    _controllers = List.generate(widget.columns.length, (i) {
      final max = unifiedDurationColumnMaxIndex(
        widget.columns[i],
        widget.columns,
        widget.maxDuration,
      );
      final initial = _values[i].clamp(0, max);
      _values[i] = initial;
      return FixedExtentScrollController(initialItem: initial);
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onKindChanged(UnifiedFieldsCalendarKind k) {
    if (_kind == k) return;
    setState(() => _kind = k);
  }

  UnifiedInputPalette _palette(Brightness b) =>
      UnifiedInputThemeResolver.paletteFor(
        b == Brightness.dark
            ? UnifiedInputBrightness.dark
            : UnifiedInputBrightness.light,
      );

  static const double _kHeaderHeight = 36;

  Widget _columnHeader(String label, UnifiedFieldsDateWheelStyle style) {
    return SizedBox(
      height: _kHeaderHeight,
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _digitStyle(
            TextStyle(
              fontSize: 12,
              letterSpacing: 0.2,
              color: style.headerTextColor!,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _wheelListChild({
    required String label,
    required double itemExtent,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      height: itemExtent,
      child: Center(
        child: Text(
          _digitText(label),
          textAlign: TextAlign.center,
          style: _digitStyle(
            TextStyle(fontSize: 17, height: 1.0, color: color),
          ),
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _wheel({
    required BuildContext context,
    required FixedExtentScrollController controller,
    required int count,
    required ValueChanged<int> onSelected,
    required UnifiedFieldsDateWheelStyle style,
  }) {
    if (count <= 0) return const SizedBox.shrink();
    return ScrollConfiguration(
      behavior: UnifiedFieldsWheelScrollBehavior.of(context),
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: style.itemExtent!,
        diameterRatio: style.diameterRatio!,
        magnification: style.magnification!,
        squeeze: style.squeeze!,
        useMagnifier: true,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onSelected,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: count,
          builder: (context, index) {
            if (index < 0 || index >= count) return null;
            return _wheelListChild(
              label: '$index',
              itemExtent: style.itemExtent!,
              color: style.itemTextColor!,
            );
          },
        ),
      ),
    );
  }

  Widget _wheelFade({
    required UnifiedFieldsDateWheelStyle style,
    required bool top,
  }) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: top ? Alignment.topCenter : Alignment.bottomCenter,
            end: top ? Alignment.bottomCenter : Alignment.topCenter,
            colors: [style.fadeColor!, style.fadeColor!.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }

  Widget _styledWheelPanel({
    required BuildContext context,
    required UnifiedFieldsDateWheelStyle style,
    required UnifiedFieldsStrings strings,
  }) {
    final bandHeight = style.itemExtent!;
    final wheelsHeight = style.wheelHeight! - _kHeaderHeight;
    final colCount = widget.columns.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: style.wheelBackground!,
          borderRadius: BorderRadius.circular(style.cornerRadius!),
          border: Border.all(color: style.columnDivider!, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(style.cornerRadius!),
          child: SizedBox(
            height: style.wheelHeight!,
            child: Column(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: style.headerDivider!, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      for (var i = 0; i < colCount; i++)
                        Expanded(
                          flex: 2,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: i < colCount - 1
                                  ? BorderDirectional(
                                      end: BorderSide(
                                        color: style.columnDivider!,
                                        width: 1,
                                      ),
                                    )
                                  : null,
                            ),
                            child: _columnHeader(
                              strings.durationColumnHeader(
                                widget.columns[i],
                                _kind,
                              ),
                              style,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: wheelsHeight,
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          for (var i = 0; i < colCount; i++)
                            Expanded(
                              flex: 2,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  border: i < colCount - 1
                                      ? BorderDirectional(
                                          end: BorderSide(
                                            color: style.columnDivider!,
                                            width: 1,
                                          ),
                                        )
                                      : null,
                                ),
                                child: _wheel(
                                  context: context,
                                  controller: _controllers[i],
                                  count:
                                      unifiedDurationColumnMaxIndex(
                                        widget.columns[i],
                                        widget.columns,
                                        widget.maxDuration,
                                      ) +
                                      1,
                                  onSelected: (index) =>
                                      setState(() => _values[i] = index),
                                  style: style,
                                ),
                              ),
                            ),
                        ],
                      ),
                      IgnorePointer(
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: bandHeight,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: style.selectionFill!,
                              borderRadius: BorderRadius.circular(
                                style.selectionRadius!,
                              ),
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
                                Container(
                                  height: 1.5,
                                  color: style.selectionBorder!,
                                ),
                                Container(
                                  height: 1.5,
                                  color: style.selectionBorder!,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: wheelsHeight * 0.34,
                        child: _wheelFade(style: style, top: true),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: wheelsHeight * 0.34,
                        child: _wheelFade(style: style, top: false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = _palette(theme.brightness);
    final strings = UnifiedFieldsStrings.instance;
    final wheelStyle = UnifiedFieldsDateWheelStyle.forPicker(
      palette,
      theme,
      overrides: widget.wheelStyle,
      context: context,
    );
    final titleText = (widget.title ?? '').trim();

    return Material(
      color: UnifiedInputThemeResolver.resolvePickerSheetBackground(
        context,
        palette: palette,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 4, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    titleText.isEmpty
                        ? strings.defaultDurationTitle
                        : titleText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: palette.fieldTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: strings.cancel,
                  icon: Icon(
                    Icons.close_rounded,
                    color: palette.fieldTextColor.withValues(alpha: 0.85),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          if (widget.showCalendarKindToggle)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SegmentedButton<UnifiedFieldsCalendarKind>(
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return theme.colorScheme.onPrimary;
                    }
                    return palette.fieldTextColor;
                  }),
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return theme.colorScheme.primary;
                    }
                    return palette.sheetHeaderBackground;
                  }),
                ),
                segments: [
                  ButtonSegment<UnifiedFieldsCalendarKind>(
                    value: UnifiedFieldsCalendarKind.gregorian,
                    label: Text(strings.calendarGregorian),
                  ),
                  ButtonSegment<UnifiedFieldsCalendarKind>(
                    value: UnifiedFieldsCalendarKind.jalali,
                    label: Text(strings.calendarShamsi),
                  ),
                ],
                selected: {_kind},
                onSelectionChanged: (s) => _onKindChanged(s.first),
              ),
            ),
          _styledWheelPanel(
            context: context,
            style: wheelStyle,
            strings: strings,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(strings.cancel),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    widget.onConfirmedCalendarKind?.call(_kind);
                    Navigator.of(
                      context,
                    ).pop(composeUnifiedDuration(widget.columns, _values));
                  },
                  child: Text(widget.confirmLabel ?? strings.done),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
