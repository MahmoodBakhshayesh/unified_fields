import 'package:flutter/material.dart';

import 'fields/unified_input_brightness.dart';
import 'fields/unified_input_palette.dart';
import 'fields/unified_input_theme.dart';
import 'unified_date_picker_types.dart';
import 'unified_date_wheel_style.dart';
import 'unified_fields_strings.dart';
import 'unified_fields_typography.dart';
import 'unified_wheel_scroll_behavior.dart';

/// Result of an H:M:S wheel picker.
typedef UnifiedFieldsHmsPick = ({int hours, int minutes, int seconds});

/// Styled scroll-wheel picker for hour / minute / second columns.
class UnifiedFieldsHmsWheelPickerSheet extends StatefulWidget {
  /// Creates an H:M:S wheel sheet.
  const UnifiedFieldsHmsWheelPickerSheet({
    super.key,
    required this.initialHours,
    required this.initialMinutes,
    required this.initialSeconds,
    required this.maxHours,
    this.maxMinutes = 59,
    this.maxSeconds = 59,
    this.showHours = true,
    this.showMinutes = true,
    this.showSeconds = true,
    this.title,
    this.confirmLabel,
    this.showCalendarKindToggle = true,
    this.initialCalendarKind = UnifiedFieldsCalendarKind.gregorian,
    this.wheelStyle,
    this.onConfirmedCalendarKind,
  });

  /// Initial hour index (0…[maxHours]).
  final int initialHours;

  /// Initial minute index.
  final int initialMinutes;

  /// Initial second index.
  final int initialSeconds;

  /// Maximum hour value (inclusive).
  final int maxHours;

  /// Maximum minute value (inclusive).
  final int maxMinutes;

  /// Maximum second value (inclusive).
  final int maxSeconds;

  /// When false, hides the hour column.
  final bool showHours;

  /// When false, hides the minute column.
  final bool showMinutes;

  /// When false, hides the second column.
  final bool showSeconds;

  /// Optional title.
  final String? title;

  /// Confirm button label; defaults to [UnifiedFieldsStrings.confirm].
  final String? confirmLabel;

  /// When true, shows Gregorian / Shamsi toggle (Persian digits in Shamsi).
  final bool showCalendarKindToggle;

  /// Starting digit / label mode.
  final UnifiedFieldsCalendarKind initialCalendarKind;

  /// Optional wheel chrome.
  final UnifiedFieldsDateWheelStyle? wheelStyle;

  /// Called with active calendar kind on confirm.
  final ValueChanged<UnifiedFieldsCalendarKind>? onConfirmedCalendarKind;

  @override
  State<UnifiedFieldsHmsWheelPickerSheet> createState() => _UnifiedFieldsHmsWheelPickerSheetState();
}

class _UnifiedFieldsHmsWheelPickerSheetState extends State<UnifiedFieldsHmsWheelPickerSheet> {
  late int _h;
  late int _m;
  late int _s;
  late UnifiedFieldsCalendarKind _kind;

  FixedExtentScrollController? _hCtrl;
  FixedExtentScrollController? _mCtrl;
  FixedExtentScrollController? _sCtrl;

  String _digitText(String text) =>
      UnifiedFieldsTypography.instance.localizeDigits(text, calendarKind: _kind);

  TextStyle _digitStyle(TextStyle style) =>
      UnifiedFieldsTypography.instance.mergeDigitStyle(style, calendarKind: _kind);

  @override
  void initState() {
    super.initState();
    _kind = widget.initialCalendarKind;
    _h = widget.initialHours.clamp(0, widget.maxHours);
    _m = widget.initialMinutes.clamp(0, widget.maxMinutes);
    _s = widget.initialSeconds.clamp(0, widget.maxSeconds);
    if (widget.showHours) {
      _hCtrl = FixedExtentScrollController(initialItem: _h);
    }
    if (widget.showMinutes) {
      _mCtrl = FixedExtentScrollController(initialItem: _m);
    }
    if (widget.showSeconds) {
      _sCtrl = FixedExtentScrollController(initialItem: _s);
    }
  }

  @override
  void dispose() {
    _hCtrl?.dispose();
    _mCtrl?.dispose();
    _sCtrl?.dispose();
    super.dispose();
  }

  void _onKindChanged(UnifiedFieldsCalendarKind k) {
    if (_kind == k) return;
    setState(() => _kind = k);
  }

  UnifiedFieldsHmsPick _compose() => (hours: _h, minutes: _m, seconds: _s);

  UnifiedInputPalette _palette(Brightness b) =>
      UnifiedInputThemeResolver.paletteFor(
        b == Brightness.dark ? UnifiedInputBrightness.dark : UnifiedInputBrightness.light,
      );

  static const double _kHeaderHeight = 36;

  Widget _columnHeader(String label, UnifiedFieldsDateWheelStyle style) {
    return SizedBox(
      height: _kHeaderHeight,
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
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
          style: _digitStyle(TextStyle(fontSize: 17, height: 1.0, color: color)),
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

  Widget _wheelCell({
    required int flex,
    required UnifiedFieldsDateWheelStyle style,
    required bool showTrailingDivider,
    required Widget? wheel,
  }) {
    if (flex <= 0 || wheel == null) return const SizedBox.shrink();
    return Expanded(
      flex: flex,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: showTrailingDivider
              ? BorderDirectional(end: BorderSide(color: style.columnDivider!, width: 1))
              : null,
        ),
        child: wheel,
      ),
    );
  }

  Widget _wheelFade({required UnifiedFieldsDateWheelStyle style, required bool top}) {
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
    final hFlex = widget.showHours ? 2 : 0;
    final mFlex = widget.showMinutes ? 2 : 0;
    final sFlex = widget.showSeconds ? 2 : 0;
    final bandHeight = style.itemExtent!;
    final wheelsHeight = style.wheelHeight! - _kHeaderHeight;
    final headers = strings.hmsWheelColumnHeaders(_kind);

    final hourWheel = widget.showHours && _hCtrl != null
        ? _wheel(
            context: context,
            controller: _hCtrl!,
            count: widget.maxHours + 1,
            onSelected: (i) => setState(() => _h = i),
            style: style,
          )
        : null;
    final minuteWheel = widget.showMinutes && _mCtrl != null
        ? _wheel(
            context: context,
            controller: _mCtrl!,
            count: widget.maxMinutes + 1,
            onSelected: (i) => setState(() => _m = i),
            style: style,
          )
        : null;
    final secondWheel = widget.showSeconds && _sCtrl != null
        ? _wheel(
            context: context,
            controller: _sCtrl!,
            count: widget.maxSeconds + 1,
            onSelected: (i) => setState(() => _s = i),
            style: style,
          )
        : null;

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
                    border: Border(bottom: BorderSide(color: style.headerDivider!, width: 1)),
                  ),
                  child: Row(
                    children: [
                      _headerCell(label: headers.hour, flex: hFlex, style: style, divider: mFlex > 0 || sFlex > 0),
                      _headerCell(label: headers.minute, flex: mFlex, style: style, divider: sFlex > 0),
                      _headerCell(label: headers.second, flex: sFlex, style: style, divider: false),
                    ],
                  ),
                ),
                SizedBox(
                  height: wheelsHeight,
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          _wheelCell(flex: hFlex, style: style, showTrailingDivider: mFlex > 0 || sFlex > 0, wheel: hourWheel),
                          _wheelCell(flex: mFlex, style: style, showTrailingDivider: sFlex > 0, wheel: minuteWheel),
                          _wheelCell(flex: sFlex, style: style, showTrailingDivider: false, wheel: secondWheel),
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

  Widget _headerCell({
    required String label,
    required int flex,
    required UnifiedFieldsDateWheelStyle style,
    required bool divider,
  }) {
    if (flex <= 0) return const SizedBox.shrink();
    return Expanded(
      flex: flex,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: divider
              ? BorderDirectional(end: BorderSide(color: style.columnDivider!, width: 1))
              : null,
        ),
        child: _columnHeader(label, style),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = _palette(theme.brightness);
    final strings = UnifiedFieldsStrings.instance;
    final wheelStyle = UnifiedFieldsDateWheelStyle.forPicker(palette, theme, widget.wheelStyle);
    final titleText = (widget.title ?? '').trim();

    return Material(
      color: theme.bottomSheetTheme.backgroundColor,
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
                    titleText.isEmpty ? strings.defaultDurationTitle : titleText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: palette.fieldTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: strings.cancel,
                  icon: Icon(Icons.close_rounded, color: palette.fieldTextColor.withValues(alpha: 0.85)),
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
          _styledWheelPanel(context: context, style: wheelStyle, strings: strings),
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
                    Navigator.of(context).pop(_compose());
                  },
                  child: Text(widget.confirmLabel ?? strings.confirm),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
