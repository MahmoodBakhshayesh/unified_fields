import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'fields/unified_input_brightness.dart';
import 'fields/unified_input_palette.dart';
import 'fields/unified_input_theme.dart';
import 'persian_jalali_calendar.dart';
import 'unified_date_picker_types.dart';
import 'unified_date_wheel_style.dart';
import 'unified_fields_strings.dart';
import 'unified_fields_typography.dart';

export 'unified_date_wheel_style.dart';

/// Wheel-based date picker with Gregorian and Shamsi (Jalali) support.
class UnifiedFieldsDateWheelPickerSheet extends StatefulWidget {
  /// Creates a scroll-wheel date picker.
  const UnifiedFieldsDateWheelPickerSheet({
    super.key,
    required this.firstDate,
    required this.lastDate,
    required this.initialDate,
    this.title,
    this.showCalendarKindToggle = true,
    this.initialCalendarKind = UnifiedFieldsCalendarKind.gregorian,
    this.granularity = UnifiedFieldsDatePickerGranularity.day,
    this.wheelStyle,
    this.showWeekdayInWheel = true,
    this.onConfirmedCalendarKind,
  });

  /// Earliest selectable date (inclusive).
  final DateTime firstDate;

  /// Latest selectable date (inclusive).
  final DateTime lastDate;

  /// Initial selection.
  final DateTime initialDate;

  /// Optional title above the wheels.
  final String? title;

  /// When false, hides the Gregorian / Shamsi switch.
  final bool showCalendarKindToggle;

  /// Starting calendar system for the wheels.
  final UnifiedFieldsCalendarKind initialCalendarKind;

  /// Which wheels are shown (day+month+year, month+year, or year only).
  final UnifiedFieldsDatePickerGranularity granularity;

  /// Optional wheel chrome; defaults from theme + [UnifiedInputPalette].
  final UnifiedFieldsDateWheelStyle? wheelStyle;

  /// When true (default), the day wheel shows weekday names beside the day numeral.
  final bool showWeekdayInWheel;

  /// Called with the active calendar kind when the user confirms.
  final ValueChanged<UnifiedFieldsCalendarKind>? onConfirmedCalendarKind;

  @override
  State<UnifiedFieldsDateWheelPickerSheet> createState() => _UnifiedFieldsDateWheelPickerSheetState();
}

/// Day row in the wheel picker (fixed-width layout when [weekday] is set).
@immutable
class UnifiedWheelDayRow {
  /// Creates a day wheel row.
  const UnifiedWheelDayRow({required this.day, this.weekday});

  /// Day of month (1–31).
  final int day;

  /// Weekday label, or null when hidden.
  final String? weekday;
}

class _UnifiedFieldsDateWheelPickerSheetState extends State<UnifiedFieldsDateWheelPickerSheet> {
  String _digitText(String text) =>
      UnifiedFieldsTypography.instance.localizeDigits(text, calendarKind: _kind);

  TextStyle _digitStyle(TextStyle style) =>
      UnifiedFieldsTypography.instance.mergeDigitStyle(style, calendarKind: _kind);

  late DateTime _first;
  late DateTime _last;
  late DateTime _selected;
  late UnifiedFieldsCalendarKind _kind;

  FixedExtentScrollController? _dayCtrl;
  FixedExtentScrollController? _monthCtrl;
  FixedExtentScrollController? _yearCtrl;

  List<int> _years = [];
  List<int> _months = [];
  List<int> _days = [];

  bool get _showDay => widget.granularity == UnifiedFieldsDatePickerGranularity.day;
  bool get _showMonth =>
      widget.granularity == UnifiedFieldsDatePickerGranularity.day ||
      widget.granularity == UnifiedFieldsDatePickerGranularity.month;

  @override
  void initState() {
    super.initState();
    _first = DateUtils.dateOnly(widget.firstDate);
    _last = DateUtils.dateOnly(widget.lastDate);
    _kind = widget.initialCalendarKind;
    _selected = _normalizeAndClamp(widget.initialDate);
    _rebuildColumns(notify: false);
    _attachControllers();
  }

  @override
  void dispose() {
    _dayCtrl?.dispose();
    _monthCtrl?.dispose();
    _yearCtrl?.dispose();
    super.dispose();
  }

  DateTime _normalizeAndClamp(DateTime d) {
    var x = DateUtils.dateOnly(d);
    switch (widget.granularity) {
      case UnifiedFieldsDatePickerGranularity.month:
        x = DateTime(x.year, x.month, 1);
        break;
      case UnifiedFieldsDatePickerGranularity.year:
        x = DateTime(x.year, 1, 1);
        break;
      case UnifiedFieldsDatePickerGranularity.day:
        break;
    }
    if (x.isBefore(_first)) return _first;
    if (x.isAfter(_last)) return _last;
    return x;
  }

  DateTime _clamp(DateTime d) {
    final x = DateUtils.dateOnly(d);
    if (x.isBefore(_first)) return _first;
    if (x.isAfter(_last)) return _last;
    return x;
  }

  void _rebuildColumns({required bool notify}) {
    _years = _buildYears();
    if (_kind == UnifiedFieldsCalendarKind.gregorian) {
      final y = _selected.year.clamp(_years.first, _years.last);
      _months = _buildGregorianMonths(y);
      final m = _months.contains(_selected.month) ? _selected.month : _months.last;
      _days = _showDay ? _buildGregorianDays(y, m) : [];
      _selected = _composeGregorian(y, m, _showDay ? _selected.day : 1);
    } else {
      final j = PersianJalaliCalendar.fromGregorian(_selected);
      final y = j.year.clamp(_years.first, _years.last);
      _months = _buildJalaliMonths(y);
      final m = _months.contains(j.month) ? j.month : _months.last;
      _days = _showDay ? _buildJalaliDays(y, m) : [];
      _selected = PersianJalaliCalendar.toGregorianDate(
        y,
        m,
        _showDay ? (PersianJalaliCalendar.fromGregorian(_selected).day) : 1,
      );
    }
    _selected = _normalizeAndClamp(_selected);
    if (notify) setState(() {});
  }

  void _attachControllers() {
    _yearCtrl?.dispose();
    _monthCtrl?.dispose();
    _dayCtrl?.dispose();

    final yIdx = _years.indexOf(_currentYear()).clamp(0, _years.isEmpty ? 0 : _years.length - 1);
    final mIdx = _months.indexOf(_currentMonth()).clamp(0, _months.isEmpty ? 0 : _months.length - 1);
    _yearCtrl = FixedExtentScrollController(initialItem: yIdx);
    _monthCtrl = FixedExtentScrollController(initialItem: mIdx);

    if (_showDay) {
      final d = _currentDay();
      final dIdx = _days.indexOf(d).clamp(0, _days.isEmpty ? 0 : _days.length - 1);
      _dayCtrl = FixedExtentScrollController(initialItem: dIdx);
    } else {
      _dayCtrl = null;
    }
  }

  int _currentYear() {
    if (_kind == UnifiedFieldsCalendarKind.gregorian) return _selected.year;
    return PersianJalaliCalendar.fromGregorian(_selected).year;
  }

  int _currentMonth() {
    if (_kind == UnifiedFieldsCalendarKind.gregorian) return _selected.month;
    return PersianJalaliCalendar.fromGregorian(_selected).month;
  }

  int _currentDay() {
    if (_kind == UnifiedFieldsCalendarKind.gregorian) return _selected.day;
    return PersianJalaliCalendar.fromGregorian(_selected).day;
  }

  List<int> _buildYears() {
    if (_kind == UnifiedFieldsCalendarKind.gregorian) {
      return [for (var y = _first.year; y <= _last.year; y++) y];
    }
    final jFirst = PersianJalaliCalendar.fromGregorian(_first).year;
    final jLast = PersianJalaliCalendar.fromGregorian(_last).year;
    return [for (var y = jFirst; y <= jLast; y++) y];
  }

  List<int> _buildGregorianMonths(int year) {
    final out = <int>[];
    for (var m = 1; m <= 12; m++) {
      final start = DateTime(year, m, 1);
      final end = DateTime(year, m + 1, 0);
      if (!end.isBefore(_first) && !start.isAfter(_last)) out.add(m);
    }
    return out;
  }

  List<int> _buildJalaliMonths(int jYear) {
    final out = <int>[];
    for (var m = 1; m <= 12; m++) {
      final start = PersianJalaliCalendar.toGregorianDate(jYear, m, 1);
      final ml = PersianJalaliCalendar.monthLength(jYear, m);
      final end = PersianJalaliCalendar.toGregorianDate(jYear, m, ml);
      if (!end.isBefore(_first) && !start.isAfter(_last)) out.add(m);
    }
    return out;
  }

  List<int> _buildGregorianDays(int year, int month) {
    final out = <int>[];
    final len = DateTime(year, month + 1, 0).day;
    for (var d = 1; d <= len; d++) {
      final dt = DateTime(year, month, d);
      if (!dt.isBefore(_first) && !dt.isAfter(_last)) out.add(d);
    }
    return out;
  }

  List<int> _buildJalaliDays(int jYear, int jMonth) {
    final out = <int>[];
    final len = PersianJalaliCalendar.monthLength(jYear, jMonth);
    for (var d = 1; d <= len; d++) {
      final dt = PersianJalaliCalendar.toGregorianDate(jYear, jMonth, d);
      if (!dt.isBefore(_first) && !dt.isAfter(_last)) out.add(d);
    }
    return out;
  }

  DateTime _composeGregorian(int y, int m, int d) {
    final len = DateTime(y, m + 1, 0).day;
    final day = d.clamp(1, len);
    return _clamp(DateTime(y, m, day));
  }

  void _onYear(int index) {
    if (index < 0 || index >= _years.length) return;
    final y = _years[index];
    if (_kind == UnifiedFieldsCalendarKind.gregorian) {
      _selected = _composeGregorian(y, _currentMonth(), _showDay ? _currentDay() : 1);
    } else {
      _selected = PersianJalaliCalendar.toGregorianDate(
        y,
        _currentMonth(),
        _showDay ? _currentDay() : 1,
      );
    }
    _rebuildColumns(notify: false);
    _attachControllers();
    setState(() {});
  }

  void _onMonth(int index) {
    if (index < 0 || index >= _months.length) return;
    final m = _months[index];
    if (_kind == UnifiedFieldsCalendarKind.gregorian) {
      _selected = _composeGregorian(_currentYear(), m, _showDay ? _currentDay() : 1);
    } else {
      _selected = PersianJalaliCalendar.toGregorianDate(
        _currentYear(),
        m,
        _showDay ? _currentDay() : 1,
      );
    }
    _rebuildColumns(notify: false);
    _attachControllers();
    setState(() {});
  }

  void _onDay(int index) {
    if (!_showDay || index < 0 || index >= _days.length) return;
    final d = _days[index];
    if (_kind == UnifiedFieldsCalendarKind.gregorian) {
      _selected = _composeGregorian(_currentYear(), _currentMonth(), d);
    } else {
      _selected = PersianJalaliCalendar.toGregorianDate(_currentYear(), _currentMonth(), d);
    }
    _selected = _clamp(_selected);
    setState(() {});
  }

  void _onKindChanged(UnifiedFieldsCalendarKind k) {
    if (_kind == k) return;
    setState(() {
      _kind = k;
      _rebuildColumns(notify: false);
      _attachControllers();
    });
  }

  UnifiedWheelDayRow _dayRow(int day) {
    if (_kind == UnifiedFieldsCalendarKind.gregorian) {
      final dt = DateTime(_currentYear(), _currentMonth(), day);
      final weekday = widget.showWeekdayInWheel ? DateFormat('EEEE').format(dt) : null;
      return UnifiedWheelDayRow(day: dt.day, weekday: weekday);
    }
    final weekday = widget.showWeekdayInWheel
        ? PersianJalaliCalendar.persianWeekdayName(_currentYear(), _currentMonth(), day)
        : null;
    return UnifiedWheelDayRow(day: day, weekday: weekday);
  }

  String _monthLabel(int month) {
    if (_kind == UnifiedFieldsCalendarKind.gregorian) {
      return DateFormat.MMMM().format(DateTime(2000, month, 1));
    }
    return PersianJalaliCalendar.persianMonthName(month);
  }

  UnifiedInputPalette _palette(Brightness b) =>
      UnifiedInputThemeResolver.paletteFor(
        b == Brightness.dark ? UnifiedInputBrightness.dark : UnifiedInputBrightness.light,
      );

  static const double _kHeaderHeight = 36;

  int _flexForYear() {
    if (!_showMonth && !_showDay) return 1;
    return 2;
  }

  int _flexForMonth() => widget.granularity == UnifiedFieldsDatePickerGranularity.year ? 0 : 3;

  int _flexForDay() => _showDay ? 4 : 0;

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
          style: _digitStyle(
            TextStyle(
              fontSize: 17,
              height: 1.0,
              color: color,
            ),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _wheelDayListChild({
    required UnifiedWheelDayRow row,
    required double itemExtent,
    required Color color,
    required double dayNumberWidth,
    required double weekdayWidth,
  }) {
    final textStyle = _digitStyle(TextStyle(fontSize: 17, height: 1.0, color: color));
    if (row.weekday == null) {
      return SizedBox(
        width: double.infinity,
        height: itemExtent,
        child: Center(child: Text(_digitText('${row.day}'), style: textStyle)),
      );
    }
    return SizedBox(
      width: double.infinity,
      height: itemExtent,
      child: Center(
        child: SizedBox(
          width: dayNumberWidth + 6 + weekdayWidth,
          child: Row(
            children: [
              SizedBox(
                width: dayNumberWidth,
                child: Text(
                  _digitText('${row.day}'),
                  textAlign: TextAlign.end,
                  style: textStyle.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: weekdayWidth,
                child: Text(
                  row.weekday!,
                  textAlign: TextAlign.start,
                  style: textStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
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
    String Function(int index)? labelOf,
    UnifiedWheelDayRow Function(int index)? dayRowOf,
  }) {
    if (count <= 0) return const SizedBox.shrink();
    return ScrollConfiguration(
      behavior: _UnifiedDateWheelScrollBehavior.of(context),
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
            if (dayRowOf != null) {
              return _wheelDayListChild(
                row: dayRowOf(index),
                itemExtent: style.itemExtent!,
                color: style.itemTextColor!,
                dayNumberWidth: style.wheelDayNumberWidth!,
                weekdayWidth: style.wheelWeekdayWidth!,
              );
            }
            return _wheelListChild(
              label: labelOf!(index),
              itemExtent: style.itemExtent!,
              color: style.itemTextColor!,
            );
          },
        ),
      ),
    );
  }

  Widget? _wheelOnly({
    required BuildContext context,
    required FixedExtentScrollController? controller,
    required int count,
    required ValueChanged<int> onSelected,
    required UnifiedFieldsDateWheelStyle style,
    String Function(int index)? labelOf,
    UnifiedWheelDayRow Function(int index)? dayRowOf,
  }) {
    if (controller == null || count == 0) return null;
    return _wheel(
      context: context,
      controller: controller,
      count: count,
      labelOf: labelOf,
      dayRowOf: dayRowOf,
      onSelected: onSelected,
      style: style,
    );
  }

  Widget _headerCell({
    required String label,
    required int flex,
    required UnifiedFieldsDateWheelStyle style,
    required bool showTrailingDivider,
    Color? columnBackground,
  }) {
    if (flex <= 0) return const SizedBox.shrink();
    return Expanded(
      flex: flex,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: columnBackground,
          border: showTrailingDivider
              ? BorderDirectional(end: BorderSide(color: style.columnDivider!, width: 1))
              : null,
        ),
        child: _columnHeader(label, style),
      ),
    );
  }

  Widget _wheelCell({
    required int flex,
    required UnifiedFieldsDateWheelStyle style,
    required bool showTrailingDivider,
    Color? columnBackground,
    required Widget? wheel,
  }) {
    if (flex <= 0 || wheel == null) return const SizedBox.shrink();
    return Expanded(
      flex: flex,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: columnBackground,
          border: showTrailingDivider
              ? BorderDirectional(end: BorderSide(color: style.columnDivider!, width: 1))
              : null,
        ),
        child: wheel,
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
            colors: [
              style.fadeColor!,
              style.fadeColor!.withValues(alpha: 0),
            ],
            stops: const [0.0, 1.0],
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
    final yearFlex = _flexForYear();
    final monthFlex = _flexForMonth();
    final dayFlex = _flexForDay();
    final bandHeight = style.itemExtent!;
    final wheelsHeight = style.wheelHeight! - _kHeaderHeight;

    final yearWheel = _wheelOnly(
      context: context,
      controller: _yearCtrl,
      count: _years.length,
      labelOf: (i) => '${_years[i]}',
      onSelected: _onYear,
      style: style,
    );
    final monthWheel = _showMonth
        ? _wheelOnly(
            context: context,
            controller: _monthCtrl,
            count: _months.length,
            labelOf: (i) => _monthLabel(_months[i]),
            onSelected: _onMonth,
            style: style,
          )
        : null;
    final dayWheel = _showDay
        ? _wheelOnly(
            context: context,
            controller: _dayCtrl,
            count: _days.length,
            dayRowOf: (i) => _dayRow(_days[i]),
            onSelected: _onDay,
            style: style,
          )
        : null;

    final yearDivider = monthFlex > 0 || dayFlex > 0;
    final monthDivider = dayFlex > 0;
    final dayColumnBg = style.dayColumnBackground;
    final columnHeaders = strings.wheelColumnHeaders(_kind);

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
                      _headerCell(
                        label: columnHeaders.year,
                        flex: yearFlex,
                        style: style,
                        showTrailingDivider: yearDivider,
                      ),
                      _headerCell(
                        label: columnHeaders.month,
                        flex: monthFlex,
                        style: style,
                        showTrailingDivider: monthDivider,
                      ),
                      _headerCell(
                        label: columnHeaders.day,
                        flex: dayFlex,
                        style: style,
                        showTrailingDivider: false,
                        columnBackground: dayColumnBg,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: wheelsHeight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _wheelCell(
                            flex: yearFlex,
                            style: style,
                            showTrailingDivider: yearDivider,
                            wheel: yearWheel,
                          ),
                          _wheelCell(
                            flex: monthFlex,
                            style: style,
                            showTrailingDivider: monthDivider,
                            wheel: monthWheel,
                          ),
                          _wheelCell(
                            flex: dayFlex,
                            style: style,
                            showTrailingDivider: false,
                            columnBackground: dayColumnBg,
                            wheel: dayWheel,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = _palette(theme.brightness);
    final strings = UnifiedFieldsStrings.instance;
    final wheelStyle = UnifiedFieldsDateWheelStyle.forPicker(palette, theme, widget.wheelStyle);
    final titleText = (widget.title ?? '').trim();
    final hasJalali = PersianJalaliCalendar.enumerateMonthsBetween(_first, _last).isNotEmpty;

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
                    titleText.isEmpty ? strings.date : titleText,
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
          if (widget.showCalendarKindToggle && hasJalali)
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
                    Navigator.of(context).pop(_selected);
                  },
                  child: Text(strings.confirm),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mouse / trackpad drag + wheel scrolling on desktop (CupertinoPicker omits mouse by default).
class _UnifiedDateWheelScrollBehavior extends MaterialScrollBehavior {
  const _UnifiedDateWheelScrollBehavior();

  static ScrollBehavior of(BuildContext context) => const _UnifiedDateWheelScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}
