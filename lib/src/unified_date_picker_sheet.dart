import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'fields/unified_input_palette.dart';
import 'fields/unified_input_theme.dart';
import 'persian_jalali_calendar.dart';
import 'unified_fields_context.dart';
import 'unified_date_picker_types.dart';
import 'unified_date_wheel_picker_sheet.dart';
import 'unified_fields_strings.dart';
import 'unified_fields_typography.dart';
import 'unified_fields_styled_picker_bridge.dart';
import 'unified_fields_styled_calendar_picker.dart';
import 'unified_fields_picker_theme.dart';
import 'unified_date_year_strip_style.dart';

export 'unified_date_picker_types.dart';
export 'unified_input_date_picker_style.dart';
export 'unified_date_year_strip_style.dart';
export 'unified_date_wheel_picker_sheet.dart'
    show UnifiedFieldsDateWheelPickerSheet, UnifiedFieldsDateWheelStyle;

int _clampPageIndex(int page, int pageCount) {
  if (pageCount <= 0) return 0;
  if (page < 0) return 0;
  if (page >= pageCount) return pageCount - 1;
  return page;
}

const int _kCalendarStaticRows = 6;

/// Opens unified_fields calendar UI (bottom sheet on phone/tablet, centered dialog on desktop).
Future<DateTime?> showUnifiedFieldsDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String? title,
  bool? barrierDismissible,
  UnifiedPickerSheetStyle? pickerSheetStyle,
  UnifiedPickerSheetModalSettings? pickerSheetModalSettings,
  bool showCalendarKindToggle = true,
  UnifiedFieldsDatePickerGranularity granularity =
      UnifiedFieldsDatePickerGranularity.day,
  UnifiedFieldsDatePickerStyle pickerStyle =
      UnifiedFieldsDatePickerStyle.calendar,
  UnifiedFieldsCalendarKind initialCalendarKind =
      UnifiedFieldsCalendarKind.gregorian,
  UnifiedFieldsDateWheelStyle? wheelStyle,
  UnifiedInputDatePickerStyle? datePickerStyle,
  bool showWeekdayInWheel = true,
  ValueChanged<UnifiedFieldsCalendarKind>? onConfirmedCalendarKind,
  UnifiedFieldsCalendarDayInfoBuilder? dayInfoBuilder,
  UnifiedFieldsPickerTheme? pickerTheme,
}) {
  final first = DateUtils.dateOnly(firstDate);
  final last = DateUtils.dateOnly(lastDate);
  assert(!first.isAfter(last), 'firstDate must be on or before lastDate');

  if (pickerStyle.isStyledPicker) {
    return showUnifiedFieldsStyledDatePicker(
      context: context,
      style: pickerStyle,
      initialDate: initialDate,
      minDate: first,
      maxDate: last,
      dayInfoBuilder: dayInfoBuilder,
      title: title,
      pickerTheme: UnifiedFieldsPickerTheme.resolve(
        context,
        overrides: pickerTheme,
        datePickerStyle: datePickerStyle,
      ),
    );
  }

  final resolvedStyle = UnifiedInputThemeResolver.resolveDatePickerStyle(
    context,
    overrides: datePickerStyle,
  );
  final effectiveWheelStyle =
      resolvedStyle.wheelStyle?.merge(wheelStyle) ?? wheelStyle;

  final Widget sheet;
  if (pickerStyle == UnifiedFieldsDatePickerStyle.wheels) {
    sheet = UnifiedFieldsDateWheelPickerSheet(
      initialDate: initialDate,
      firstDate: first,
      lastDate: last,
      title: title,
      showCalendarKindToggle: showCalendarKindToggle,
      initialCalendarKind: initialCalendarKind,
      granularity: granularity,
      wheelStyle: effectiveWheelStyle,
      datePickerStyle: resolvedStyle,
      showWeekdayInWheel: showWeekdayInWheel,
      onConfirmedCalendarKind: onConfirmedCalendarKind,
    );
  } else {
    sheet = UnifiedFieldsDatePickerSheet(
      pickRange: false,
      initialDate: initialDate,
      firstDate: first,
      lastDate: last,
      title: title,
      showCalendarKindToggle: showCalendarKindToggle,
      granularity: granularity,
      initialCalendarKind: initialCalendarKind,
      datePickerStyle: resolvedStyle,
      onConfirmedCalendarKind: onConfirmedCalendarKind,
    );
  }

  final isWheels = pickerStyle == UnifiedFieldsDatePickerStyle.wheels;
  final modal = UnifiedPickerSheetModalSettings.resolve(
    context,
    pickerSheetStyle: pickerSheetStyle,
    fieldOverride: pickerSheetModalSettings,
    legacyIsDismissible: barrierDismissible,
  );
  final dismissible = modal.isDismissible!;
  return _presentPicker<DateTime>(
    context: context,
    modal: modal,
    enableDrag: !isWheels && dismissible,
    showDragHandle: !isWheels && dismissible,
    scrollable: !isWheels,
    dialogBorderRadius: resolvedStyle.dialogBorderRadius,
    child: sheet,
  );
}

/// Same chrome as [showUnifiedFieldsDatePicker], but returns an inclusive [DateTimeRange].
Future<DateTimeRange?> showUnifiedFieldsDatePickerRange({
  required BuildContext context,
  DateTimeRange? initialRange,
  required DateTime firstDate,
  required DateTime lastDate,
  String? title,
  bool? barrierDismissible,
  UnifiedPickerSheetStyle? pickerSheetStyle,
  UnifiedPickerSheetModalSettings? pickerSheetModalSettings,
  bool showCalendarKindToggle = true,
  UnifiedFieldsCalendarKind initialCalendarKind =
      UnifiedFieldsCalendarKind.gregorian,
  UnifiedFieldsDatePickerStyle pickerStyle =
      UnifiedFieldsDatePickerStyle.verticalMonths,
  UnifiedInputDatePickerStyle? datePickerStyle,
  UnifiedFieldsCalendarDayInfoBuilder? dayInfoBuilder,
  UnifiedFieldsPickerTheme? pickerTheme,
  ValueChanged<UnifiedFieldsCalendarKind>? onConfirmedCalendarKind,
}) {
  final first = DateUtils.dateOnly(firstDate);
  final last = DateUtils.dateOnly(lastDate);
  assert(!first.isAfter(last), 'firstDate must be on or before lastDate');

  if (pickerStyle.isStyledPicker) {
    return showUnifiedFieldsStyledDatePickerRange(
      context: context,
      style: pickerStyle,
      initialRange: initialRange,
      minDate: first,
      maxDate: last,
      dayInfoBuilder: dayInfoBuilder,
      title: title,
      pickerTheme: UnifiedFieldsPickerTheme.resolve(
        context,
        overrides: pickerTheme,
        datePickerStyle: datePickerStyle,
      ),
    );
  }

  final resolvedStyle = UnifiedInputThemeResolver.resolveDatePickerStyle(
    context,
    overrides: datePickerStyle,
  );

  final sheet = UnifiedFieldsDatePickerSheet(
    pickRange: true,
    initialDate: initialRange?.start ?? DateTime.now(),
    initialRange: initialRange,
    firstDate: first,
    lastDate: last,
    title: title,
    showCalendarKindToggle: showCalendarKindToggle,
    initialCalendarKind: initialCalendarKind,
    datePickerStyle: resolvedStyle,
    onConfirmedCalendarKind: onConfirmedCalendarKind,
  );

  final modal = UnifiedPickerSheetModalSettings.resolve(
    context,
    pickerSheetStyle: pickerSheetStyle,
    fieldOverride: pickerSheetModalSettings,
    legacyIsDismissible: barrierDismissible,
  );
  return _presentPicker<DateTimeRange>(
    context: context,
    modal: modal,
    dialogBorderRadius: resolvedStyle.dialogBorderRadius,
    child: sheet,
  );
}

Future<T?> _presentPicker<T>({
  required BuildContext context,
  required UnifiedPickerSheetModalSettings modal,
  required Widget child,
  bool? enableDrag,
  bool? showDragHandle,
  bool scrollable = true,
  double? dialogBorderRadius,
}) {
  final dismissible = modal.isDismissible!;
  final drag = enableDrag ?? dismissible;
  final handle = showDragHandle ?? dismissible;
  if (!context.mounted) return Future.value(null);

  if (context.unifiedFieldsUseDialogLayout) {
    return showDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      builder: (ctx) {
        final maxH = MediaQuery.sizeOf(ctx).height * 0.92;
        final body = scrollable ? SingleChildScrollView(child: child) : child;
        return Dialog(
          clipBehavior: Clip.antiAlias,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dialogBorderRadius ?? 20),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 420, maxHeight: maxH),
            child: body,
          ),
        );
      },
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: modal.isScrollControlled!,
    isDismissible: dismissible,
    enableDrag: drag,
    useSafeArea: modal.useSafeArea!,
    showDragHandle: handle,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) {
      return Container(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: child,
      );
    },
  );
}

/// Inline calendar between [firstDate] and [lastDate]; single date or range via [pickRange].
class UnifiedFieldsDatePickerSheet extends StatefulWidget {
  /// Creates an inline calendar picker.
  const UnifiedFieldsDatePickerSheet({
    super.key,
    required this.firstDate,
    required this.lastDate,
    required this.initialDate,
    this.initialRange,
    this.pickRange = false,
    this.title,
    this.showCalendarKindToggle = true,
    this.granularity = UnifiedFieldsDatePickerGranularity.day,
    this.initialCalendarKind = UnifiedFieldsCalendarKind.gregorian,
    this.datePickerStyle,
    this.onConfirmedCalendarKind,
  });

  /// Earliest selectable date (inclusive).
  final DateTime firstDate;

  /// Latest selectable date (inclusive).
  final DateTime lastDate;

  /// Date to seed single-date pick.
  final DateTime initialDate;

  /// Range to seed range-pick (when [pickRange] is true).
  final DateTimeRange? initialRange;

  /// When true, picks a [DateTimeRange]; otherwise a single date.
  final bool pickRange;

  /// Optional title rendered above the calendar.
  final String? title;

  /// When false, hides the Gregorian / Shamsi switch.
  final bool showCalendarKindToggle;

  /// For single-date pick only; range pick always uses [day] UI.
  final UnifiedFieldsDatePickerGranularity granularity;

  /// Calendar system shown when the sheet opens.
  final UnifiedFieldsCalendarKind initialCalendarKind;

  /// Pre-resolved picker chrome (from theme + field overrides).
  final UnifiedInputDatePickerStyle? datePickerStyle;

  /// Called with the active calendar kind when the user confirms.
  final ValueChanged<UnifiedFieldsCalendarKind>? onConfirmedCalendarKind;

  @override
  State<UnifiedFieldsDatePickerSheet> createState() =>
      _UnifiedFieldsDatePickerSheetState();
}

class _UnifiedFieldsDatePickerSheetState
    extends State<UnifiedFieldsDatePickerSheet> {
  String _digitText(String text) => UnifiedFieldsTypography.instance
      .localizeDigits(text, calendarKind: _kind);

  TextStyle _digitStyle(TextStyle style, UnifiedInputDatePickerStyle pickerStyle) =>
      UnifiedFieldsTypography.instance.mergeDigitStyle(
        pickerStyle.calendarTextStyle(style, _kind),
        calendarKind: _kind,
      );

  late DateTime _firstMonth;
  late int _monthCount;
  late List<(int jy, int jm)> _jalaliMonths;
  late PageController _pageController;
  late DateTime _selected;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  late UnifiedFieldsCalendarKind _kind;

  /// Gregorian year shown in month-granularity UI.
  late int _gYearForMonthPicker;

  /// Jalali year shown in month-granularity UI.
  late int _jYearForMonthPicker;

  /// Fixed row height for the year-granularity list (matches default [ListTile] minHeight).
  static const double _kYearListItemExtent = 48;

  ScrollController? _yearScrollController;
  bool _pendingYearAutoScroll = true;

  DateTime get _pageAnchor =>
      widget.pickRange ? (_rangeStart ?? _selected) : _selected;

  bool get _useDayCalendar =>
      widget.pickRange ||
      widget.granularity == UnifiedFieldsDatePickerGranularity.day;

  @override
  void initState() {
    super.initState();
    _kind = widget.initialCalendarKind;
    _firstMonth = DateTime(widget.firstDate.year, widget.firstDate.month);
    final lastMonth = DateTime(widget.lastDate.year, widget.lastDate.month);
    _monthCount = _monthsBetween(_firstMonth, lastMonth) + 1;
    _jalaliMonths = PersianJalaliCalendar.enumerateMonthsBetween(
      widget.firstDate,
      widget.lastDate,
    );

    if (widget.pickRange) {
      final ir = widget.initialRange;
      if (ir != null) {
        _rangeStart = DateUtils.dateOnly(
          _clampDate(ir.start, widget.firstDate, widget.lastDate),
        );
        _rangeEnd = DateUtils.dateOnly(
          _clampDate(ir.end, widget.firstDate, widget.lastDate),
        );
      } else {
        final d = DateUtils.dateOnly(
          _clampDate(widget.initialDate, widget.firstDate, widget.lastDate),
        );
        _rangeStart = _rangeEnd = d;
      }
      _selected = _rangeStart!;
    } else {
      _selected = DateUtils.dateOnly(
        _clampDate(widget.initialDate, widget.firstDate, widget.lastDate),
      );
      _applyGranularityNormalizationToSelected();
    }

    _gYearForMonthPicker = _selected.year.clamp(
      widget.firstDate.year,
      widget.lastDate.year,
    );
    final jMinY = PersianJalaliCalendar.fromGregorian(widget.firstDate).year;
    final jMaxY = PersianJalaliCalendar.fromGregorian(widget.lastDate).year;
    _jYearForMonthPicker = PersianJalaliCalendar.fromGregorian(
      _selected,
    ).year.clamp(jMinY, jMaxY);

    final initialPage = _computeInitialPage(kind: _kind, anchor: _pageAnchor);
    _pageController = PageController(initialPage: initialPage);
  }

  void _applyGranularityNormalizationToSelected() {
    if (widget.pickRange) return;
    switch (widget.granularity) {
      case UnifiedFieldsDatePickerGranularity.month:
        _selected = DateTime(_selected.year, _selected.month, 1);
        break;
      case UnifiedFieldsDatePickerGranularity.year:
        _selected = DateTime(_selected.year, 1, 1);
        break;
      case UnifiedFieldsDatePickerGranularity.day:
        break;
    }
    _selected = DateUtils.dateOnly(
      _clampDate(_selected, widget.firstDate, widget.lastDate),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _yearScrollController?.dispose();
    super.dispose();
  }

  /// Index of the selected year in the year-granularity list for the active calendar.
  int _selectedYearIndex() {
    if (_kind == UnifiedFieldsCalendarKind.gregorian) {
      return (_selected.year - widget.firstDate.year).clamp(
        0,
        widget.lastDate.year - widget.firstDate.year,
      );
    }
    final years = <int>{for (final e in _jalaliMonths) e.$1}.toList()..sort();
    if (years.isEmpty) return 0;
    final jSel = PersianJalaliCalendar.fromGregorian(_selected).year;
    final idx = years.indexOf(jSel);
    return idx < 0 ? 0 : idx;
  }

  /// Centers the selected year in the year-granularity list when it first appears.
  void _scrollYearListToSelected() {
    final ctrl = _yearScrollController;
    if (ctrl == null || !ctrl.hasClients) return;
    final viewport = ctrl.position.viewportDimension;
    final max = ctrl.position.maxScrollExtent;
    final centerOffset =
        (_selectedYearIndex() * _kYearListItemExtent) -
        (viewport / 2) +
        (_kYearListItemExtent / 2);
    final clamped = centerOffset.clamp(0.0, max);
    ctrl.jumpTo(clamped);
  }

  int _computeInitialPage({
    required UnifiedFieldsCalendarKind kind,
    required DateTime anchor,
  }) {
    if (kind == UnifiedFieldsCalendarKind.gregorian) {
      final initialMonth = DateTime(anchor.year, anchor.month);
      return _clampPageIndex(
        _monthsBetween(_firstMonth, initialMonth),
        _monthCount,
      );
    }
    if (_jalaliMonths.isEmpty) return 0;
    final j = PersianJalaliCalendar.fromGregorian(anchor);
    final idx = _jalaliMonths.indexWhere(
      (e) => e.$1 == j.year && e.$2 == j.month,
    );
    return idx < 0 ? 0 : idx;
  }

  int _pageCountForKind(UnifiedFieldsCalendarKind kind) =>
      kind == UnifiedFieldsCalendarKind.gregorian
      ? _monthCount
      : (_jalaliMonths.isEmpty ? 1 : _jalaliMonths.length);

  int _safeCurrentPage(int pageCount) {
    final safe = pageCount < 1 ? 1 : pageCount;
    if (!_pageController.hasClients) {
      return _clampPageIndex(_pageController.initialPage, safe);
    }
    return _clampPageIndex(_pageController.page!.round(), safe);
  }

  void _onKindChanged(UnifiedFieldsCalendarKind k) {
    if (_kind == k || !widget.showCalendarKindToggle) return;
    final anchor = _pageAnchor;
    _pageController.dispose();
    _kind = k;
    final count = _pageCountForKind(k);
    final page = _clampPageIndex(
      _computeInitialPage(kind: k, anchor: anchor),
      count,
    );
    _pageController = PageController(initialPage: page);
    setState(() {});
    if (!_useDayCalendar) {
      _gYearForMonthPicker = _selected.year.clamp(
        widget.firstDate.year,
        widget.lastDate.year,
      );
      final jMinY = PersianJalaliCalendar.fromGregorian(widget.firstDate).year;
      final jMaxY = PersianJalaliCalendar.fromGregorian(widget.lastDate).year;
      _jYearForMonthPicker = PersianJalaliCalendar.fromGregorian(
        _selected,
      ).year.clamp(jMinY, jMaxY);
    }
    if (widget.granularity == UnifiedFieldsDatePickerGranularity.year) {
      _pendingYearAutoScroll = true;
    }
  }

  void _handleDayTap(DateTime d) {
    final day = DateUtils.dateOnly(d);
    if (!widget.pickRange) {
      setState(() => _selected = day);
      return;
    }
    setState(() {
      final rs = _rangeStart;
      final re = _rangeEnd;
      if (rs == null) {
        _rangeStart = _rangeEnd = day;
        return;
      }
      if (re == null || DateUtils.isSameDay(rs, re)) {
        if (day.isBefore(rs)) {
          _rangeEnd = rs;
          _rangeStart = day;
        } else {
          _rangeEnd = day;
        }
        return;
      }
      _rangeStart = _rangeEnd = day;
    });
  }

  void _confirm() {
    if (!mounted) return;
    widget.onConfirmedCalendarKind?.call(_kind);
    if (widget.pickRange) {
      final rs = _rangeStart;
      final re = _rangeEnd;
      if (rs == null || re == null) return;
      final start = rs.isBefore(re) ? rs : re;
      final end = rs.isBefore(re) ? re : rs;
      Navigator.of(
        context,
      ).pop<DateTimeRange>(DateTimeRange(start: start, end: end));
      return;
    }
    var out = DateUtils.dateOnly(_selected);
    switch (widget.granularity) {
      case UnifiedFieldsDatePickerGranularity.year:
        out = DateUtils.dateOnly(DateTime(out.year, 1, 1));
        break;
      case UnifiedFieldsDatePickerGranularity.month:
        out = DateUtils.dateOnly(DateTime(out.year, out.month, 1));
        break;
      case UnifiedFieldsDatePickerGranularity.day:
        break;
    }
    out = DateUtils.dateOnly(
      _clampDate(out, widget.firstDate, widget.lastDate),
    );
    Navigator.of(context).pop<DateTime>(out);
  }

  UnifiedInputPalette _palette(Brightness b) => b == Brightness.dark
      ? UnifiedInputPalette.dark()
      : UnifiedInputPalette.light();

  Future<void> _openMonthYearJump() async {
    final palette = _palette(Theme.of(context).brightness);
    final style = _pickerStyle(context, palette);
    final pageCount = _pageCountForKind(_kind);
    final page = _safeCurrentPage(pageCount);

    if (_kind == UnifiedFieldsCalendarKind.gregorian) {
      final cur = DateTime(_firstMonth.year, _firstMonth.month + page);
      final picked = await showModalBottomSheet<(int, int)?>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (ctx) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(ctx).bottom,
            ),
            child: _GregorianMonthYearJumpPanel(
              style: style,
              palette: palette,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              initialYear: cur.year,
              initialMonth: cur.month,
              title: UnifiedFieldsStrings.instance.jumpToMonthYear,
              yearLabel: UnifiedFieldsStrings.instance.yearLabel,
            ),
          );
        },
      );
      if (picked != null && mounted) {
        final target = _monthsBetween(
          _firstMonth,
          DateTime(picked.$1, picked.$2),
        );
        _pageController.jumpToPage(_clampPageIndex(target, _monthCount));
        setState(() {});
      }
      return;
    }

    if (_jalaliMonths.isEmpty) return;
    final ix = _clampPageIndex(page, _jalaliMonths.length);
    final cur = _jalaliMonths[ix];
    final picked = await showModalBottomSheet<(int, int)?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
          child: _JalaliMonthYearJumpPanel(
            style: style,
            palette: palette,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            initialYear: cur.$1,
            initialMonth: cur.$2,
            title: UnifiedFieldsStrings.instance.jumpToMonthYear,
            yearLabel: UnifiedFieldsStrings.instance.yearLabel,
          ),
        );
      },
    );
    if (picked != null && mounted) {
      final idx = _jalaliMonths.indexWhere(
        (e) => e.$1 == picked.$1 && e.$2 == picked.$2,
      );
      if (idx >= 0) {
        _pageController.jumpToPage(idx);
        setState(() {});
      }
    }
  }

  UnifiedInputDatePickerStyle _pickerStyle(
    BuildContext context,
    UnifiedInputPalette palette,
  ) =>
      widget.datePickerStyle ??
      UnifiedInputThemeResolver.resolveDatePickerStyle(
        context,
        palette: palette,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = _palette(theme.brightness);
    final style = _pickerStyle(context, palette);
    final loc = MaterialLocalizations.of(context);
    final titleText = (widget.title ?? '').trim();
    final pageCount = _pageCountForKind(_kind);
    final cellHeight = style.cellHeight!;
    final gridHeight = _kCalendarStaticRows * cellHeight;

    return Material(
      color: style.sheetBackgroundColor,
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
                        ? UnifiedFieldsStrings.instance.date
                        : titleText,
                    style: _digitStyle(style.titleStyle!, style),
                  ),
                ),
                IconButton(
                  tooltip: UnifiedFieldsStrings.instance.cancel,
                  icon: Icon(
                    Icons.close_rounded,
                    color: style.closeIconColor,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          if (widget.pickRange)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text(
                UnifiedFieldsStrings.instance.pickDateRangeHint,
                style: _digitStyle(style.rangeHintStyle!, style),
              ),
            ),
          if (widget.showCalendarKindToggle && _jalaliMonths.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SegmentedButton<UnifiedFieldsCalendarKind>(
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return style.calendarToggleSelectedForeground;
                    }
                    return style.calendarToggleForeground;
                  }),
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return style.calendarToggleSelectedBackground;
                    }
                    return style.calendarToggleBackground;
                  }),
                ),
                segments: [
                  ButtonSegment<UnifiedFieldsCalendarKind>(
                    value: UnifiedFieldsCalendarKind.gregorian,
                    label: Text(
                      UnifiedFieldsStrings.instance.calendarGregorian,
                    ),
                  ),
                  ButtonSegment<UnifiedFieldsCalendarKind>(
                    value: UnifiedFieldsCalendarKind.jalali,
                    label: Text(UnifiedFieldsStrings.instance.calendarShamsi),
                  ),
                ],
                selected: {_kind},
                onSelectionChanged: (s) => _onKindChanged(s.first),
              ),
            ),
          if (_useDayCalendar) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedBuilder(
                animation: _pageController,
                builder: (context, _) {
                  return _PickerTitleBar(
                    kind: _kind,
                    style: style,
                    pageController: _pageController,
                    pageCount: pageCount,
                    firstGregorianMonth: _firstMonth,
                    jalaliMonths: _jalaliMonths,
                    onTitleTap: _openMonthYearJump,
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _WeekdayHeader(loc: loc, style: style, calendarKind: _kind),
            ),
            SizedBox(
              height: gridHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: pageCount,
                onPageChanged: (_) => setState(() {}),
                itemBuilder: (context, pageIndex) {
                  if (_kind == UnifiedFieldsCalendarKind.gregorian) {
                    final month = DateTime(
                      _firstMonth.year,
                      _firstMonth.month + pageIndex,
                    );
                    return _GregorianMonthGrid(
                      style: style,
                      month: month,
                      firstDate: widget.firstDate,
                      lastDate: widget.lastDate,
                      selected: _selected,
                      rangeMode: widget.pickRange,
                      rangeStart: _rangeStart,
                      rangeEnd: _rangeEnd,
                      loc: loc,
                      staticRows: _kCalendarStaticRows,
                      onDayTap: _handleDayTap,
                    );
                  }
                  if (_jalaliMonths.isEmpty) return const SizedBox.shrink();
                  final jmPair =
                      _jalaliMonths[pageIndex.clamp(
                        0,
                        _jalaliMonths.length - 1,
                      )];
                  return _JalaliMonthGrid(
                    style: style,
                    jalaliYear: jmPair.$1,
                    jalaliMonth: jmPair.$2,
                    firstDate: widget.firstDate,
                    lastDate: widget.lastDate,
                    selected: _selected,
                    rangeMode: widget.pickRange,
                    rangeStart: _rangeStart,
                    rangeEnd: _rangeEnd,
                    loc: loc,
                    staticRows: _kCalendarStaticRows,
                    onDayTap: _handleDayTap,
                  );
                },
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
              child: SizedBox(
                height: gridHeight,
                child: _buildGranularityBody(theme, palette, loc, style),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: style.cancelButtonTextStyle != null
                      ? TextButton.styleFrom(
                          textStyle: style.cancelButtonTextStyle,
                        )
                      : null,
                  child: Text(UnifiedFieldsStrings.instance.cancel),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _confirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: style.confirmButtonBackground,
                    foregroundColor: style.confirmButtonForeground,
                    textStyle: style.confirmButtonTextStyle,
                  ),
                  child: Text(UnifiedFieldsStrings.instance.confirm),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGranularityBody(
    ThemeData theme,
    UnifiedInputPalette palette,
    MaterialLocalizations loc,
    UnifiedInputDatePickerStyle style,
  ) {
    switch (widget.granularity) {
      case UnifiedFieldsDatePickerGranularity.year:
        return _buildYearGranularity(style);
      case UnifiedFieldsDatePickerGranularity.month:
        return _buildMonthGranularity(theme, palette, loc, style);
      case UnifiedFieldsDatePickerGranularity.day:
        return const SizedBox.shrink();
    }
  }

  bool _gregorianYearEnabled(int y) {
    final a = DateTime(y, 1, 1);
    final b = DateTime(y, 12, 31);
    return !a.isAfter(widget.lastDate) && !b.isBefore(widget.firstDate);
  }

  bool _jalaliYearEnabled(int jy) {
    final a = PersianJalaliCalendar.toGregorianDate(jy, 1, 1);
    final ml = PersianJalaliCalendar.monthLength(jy, 12);
    final b = PersianJalaliCalendar.toGregorianDate(jy, 12, ml);
    return !a.isAfter(widget.lastDate) && !b.isBefore(widget.firstDate);
  }

  bool _gregorianMonthCellEnabled(int y, int m) {
    final start = DateTime(y, m, 1);
    if (start.isAfter(widget.lastDate)) return false;
    final end = DateTime(y, m + 1, 0);
    if (end.isBefore(widget.firstDate)) return false;
    return true;
  }

  bool _jalaliMonthCellEnabled(int jy, int jm) {
    final start = PersianJalaliCalendar.toGregorianDate(jy, jm, 1);
    final ml = PersianJalaliCalendar.monthLength(jy, jm);
    final end = PersianJalaliCalendar.toGregorianDate(jy, jm, ml);
    return !start.isAfter(widget.lastDate) && !end.isBefore(widget.firstDate);
  }

  /// Updates [_selected] from the tapped year (Gregorian [DateTime] anchor at
  /// Jan 1st) and immediately confirms/pops with the granularity-normalized result.
  void _pickYearAndConfirm(DateTime anchor) {
    setState(() {
      _selected = DateUtils.dateOnly(
        _clampDate(anchor, widget.firstDate, widget.lastDate),
      );
    });
    _confirm();
  }

  Widget _buildYearGranularity(UnifiedInputDatePickerStyle style) {
    _yearScrollController ??= ScrollController();
    if (_pendingYearAutoScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _scrollYearListToSelected();
        _pendingYearAutoScroll = false;
      });
    }

    final selectedBg = style.yearListSelectedBackground!;
    final selectedColor = style.yearListSelectedTextColor!;
    final textColor = style.yearListTextColor!;
    final checkColor = style.yearListCheckmarkColor!;

    if (_kind == UnifiedFieldsCalendarKind.gregorian) {
      final years = <int>[
        for (var y = widget.firstDate.year; y <= widget.lastDate.year; y++) y,
      ];
      return ListView.builder(
        controller: _yearScrollController,
        itemExtent: _kYearListItemExtent,
        itemCount: years.length,
        itemBuilder: (context, i) {
          final y = years[i];
          final enabled = _gregorianYearEnabled(y);
          final sel = _selected.year == y;
          return ListTile(
            enabled: enabled,
            selected: sel,
            selectedTileColor: selectedBg,
            selectedColor: selectedColor,
            trailing:
                sel ? Icon(Icons.check_rounded, color: checkColor) : null,
            title: Text(
              _digitText('$y'),
              style: _digitStyle(
                TextStyle(
                  color: sel ? selectedColor : textColor,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                ),
                style,
              ),
            ),
            onTap: enabled
                ? () => _pickYearAndConfirm(DateTime(y, 1, 1))
                : null,
          );
        },
      );
    }
    final years = <int>{for (final e in _jalaliMonths) e.$1}.toList()..sort();
    if (years.isEmpty) {
      return Center(
        child: Text(
          '-',
          style: _digitStyle(style.rangeHintStyle!, style),
        ),
      );
    }
    return ListView.builder(
      controller: _yearScrollController,
      itemExtent: _kYearListItemExtent,
      itemCount: years.length,
      itemBuilder: (context, i) {
        final jy = years[i];
        final enabled = _jalaliYearEnabled(jy);
        final jSel = PersianJalaliCalendar.fromGregorian(_selected);
        final sel = jSel.year == jy;
        return ListTile(
          enabled: enabled,
          selected: sel,
          selectedTileColor: selectedBg,
          selectedColor: selectedColor,
          trailing:
              sel ? Icon(Icons.check_rounded, color: checkColor) : null,
          title: Text(
            _digitText('$jy'),
            style: _digitStyle(
              TextStyle(
                color: sel ? selectedColor : textColor,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
              ),
              style,
            ),
          ),
          onTap: enabled
              ? () => _pickYearAndConfirm(
                  PersianJalaliCalendar.toGregorianDate(jy, 1, 1),
                )
              : null,
        );
      },
    );
  }

  Widget _buildMonthGranularity(
    ThemeData theme,
    UnifiedInputPalette palette,
    MaterialLocalizations loc,
    UnifiedInputDatePickerStyle style,
  ) {
    if (_kind == UnifiedFieldsCalendarKind.gregorian) {
      final years = <int>[
        for (var y = widget.firstDate.year; y <= widget.lastDate.year; y++) y,
      ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HorizontalYearStrip(
            years: years,
            selectedYear: _gYearForMonthPicker.clamp(years.first, years.last),
            onYearSelected: (y) => setState(() => _gYearForMonthPicker = y),
            style: style,
            calendarKind: UnifiedFieldsCalendarKind.gregorian,
            yearLabel: UnifiedFieldsStrings.instance.yearLabel,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: LayoutBuilder(
                builder: (context, c) {
                  const cols = 4;
                  const rows = 3;
                  final cellW = c.maxWidth / cols;
                  final cellH = c.maxHeight / rows;
                  final aspect = cellH <= 0 ? 1.0 : (cellW / cellH);
                  return GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: cols,
                    padding: EdgeInsets.zero,
                    childAspectRatio: aspect,
                    children: List.generate(12, (idx) {
                      final m = idx + 1;
                      final ok = _gregorianMonthCellEnabled(
                        _gYearForMonthPicker,
                        m,
                      );
                      final d = DateTime(_gYearForMonthPicker, m, 1);
                      final sel =
                          _selected.year == _gYearForMonthPicker &&
                          _selected.month == m;
                      return Padding(
                        padding: const EdgeInsets.all(4),
                        child: InkWell(
                          onTap: ok
                              ? () => setState(() {
                                  _selected = DateUtils.dateOnly(
                                    _clampDate(
                                      d,
                                      widget.firstDate,
                                      widget.lastDate,
                                    ),
                                  );
                                })
                              : null,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: sel
                                  ? theme.colorScheme.primary.withValues(
                                      alpha: 0.35,
                                    )
                                  : palette.sheetHeaderBackground,
                            ),
                            child: Text(
                              DateFormat.MMM().format(DateTime(2000, m)),
                              style: TextStyle(
                                color: ok
                                    ? palette.fieldTextColor
                                    : palette.hintColor,
                                fontWeight: sel
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
        ],
      );
    }
    final years = <int>{for (final e in _jalaliMonths) e.$1}.toList()..sort();
    if (years.isEmpty) {
      return Center(
        child: Text('-', style: TextStyle(color: palette.hintColor)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HorizontalYearStrip(
          years: years,
          selectedYear: _jYearForMonthPicker.clamp(years.first, years.last),
          onYearSelected: (jy) => setState(() => _jYearForMonthPicker = jy),
          style: style,
          calendarKind: UnifiedFieldsCalendarKind.jalali,
          yearLabel: UnifiedFieldsStrings.instance.yearLabel,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: LayoutBuilder(
              builder: (context, c) {
                const cols = 4;
                const rows = 3;
                final cellW = c.maxWidth / cols;
                final cellH = c.maxHeight / rows;
                final aspect = cellH <= 0 ? 1.0 : (cellW / cellH);
                return GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: cols,
                  padding: EdgeInsets.zero,
                  childAspectRatio: aspect,
                  children: List.generate(12, (idx) {
                    final jm = idx + 1;
                    final ok = _jalaliMonthCellEnabled(
                      _jYearForMonthPicker,
                      jm,
                    );
                    final d = PersianJalaliCalendar.toGregorianDate(
                      _jYearForMonthPicker,
                      jm,
                      1,
                    );
                    final jSel = PersianJalaliCalendar.fromGregorian(_selected);
                    final sel =
                        jSel.year == _jYearForMonthPicker && jSel.month == jm;
                    final label = PersianJalaliCalendar.persianMonthName(jm);
                    return Padding(
                      padding: const EdgeInsets.all(4),
                      child: InkWell(
                        onTap: ok
                            ? () => setState(() {
                                _selected = DateUtils.dateOnly(
                                  _clampDate(
                                    d,
                                    widget.firstDate,
                                    widget.lastDate,
                                  ),
                                );
                              })
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: sel
                                ? theme.colorScheme.primary.withValues(
                                    alpha: 0.35,
                                  )
                                : palette.sheetHeaderBackground,
                          ),
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: UnifiedFieldsTypography.instance
                                .mergeDigitStyle(
                              style.calendarTextStyle(
                                TextStyle(
                                  fontSize: 12,
                                  color: ok
                                      ? palette.fieldTextColor
                                      : palette.hintColor,
                                  fontWeight: sel
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                                UnifiedFieldsCalendarKind.jalali,
                              ),
                              calendarKind: UnifiedFieldsCalendarKind.jalali,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _PickerTitleBar extends StatelessWidget {
  const _PickerTitleBar({
    required this.kind,
    required this.style,
    required this.pageController,
    required this.pageCount,
    required this.firstGregorianMonth,
    required this.jalaliMonths,
    required this.onTitleTap,
  });

  final UnifiedFieldsCalendarKind kind;
  final UnifiedInputDatePickerStyle style;
  final PageController pageController;
  final int pageCount;
  final DateTime firstGregorianMonth;
  final List<(int jy, int jm)> jalaliMonths;
  final VoidCallback onTitleTap;

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final safePageCount = pageCount < 1 ? 1 : pageCount;
    final page = _clampPageIndex(
      pageController.hasClients
          ? pageController.page!.round()
          : pageController.initialPage,
      safePageCount,
    );

    late final String label;
    if (kind == UnifiedFieldsCalendarKind.gregorian) {
      final month = DateTime(
        firstGregorianMonth.year,
        firstGregorianMonth.month + page,
      );
      label = loc.formatMonthYear(DateTime(month.year, month.month));
    } else {
      if (jalaliMonths.isEmpty) {
        label = '';
      } else {
        final ix = _clampPageIndex(page, jalaliMonths.length);
        final jy = jalaliMonths[ix].$1;
        final jm = jalaliMonths[ix].$2;
        final name = PersianJalaliCalendar.persianMonthName(jm);
        label = '$name $jy';
      }
    }
    final typography = UnifiedFieldsTypography.instance;
    final displayLabel = typography.localizeDigits(label, calendarKind: kind);
    final titleStyle = typography.mergeDigitStyle(
      style.calendarTextStyle(style.monthTitleStyle!, kind),
      calendarKind: kind,
    );
    final navColor = style.monthNavIconColor!;

    void go(int delta) {
      final target = _clampPageIndex(page + delta, safePageCount);
      if (target == page) return;
      pageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }

    return Row(
      children: [
        IconButton(
          onPressed: page > 0 ? () => go(-1) : null,
          icon: Icon(Icons.chevron_left_rounded, color: navColor),
        ),
        Expanded(
          child: InkWell(
            onTap: onTitleTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      displayLabel,
                      style: titleStyle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: navColor.withValues(alpha: 0.9),
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: page < safePageCount - 1 ? () => go(1) : null,
          icon: Icon(Icons.chevron_right_rounded, color: navColor),
        ),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({
    required this.loc,
    required this.style,
    required this.calendarKind,
  });

  final MaterialLocalizations loc;
  final UnifiedInputDatePickerStyle style;
  final UnifiedFieldsCalendarKind calendarKind;

  @override
  Widget build(BuildContext context) {
    final labels = loc.narrowWeekdays;
    final weekdayStyle = style.calendarTextStyle(
      style.weekdayTextStyle!,
      calendarKind,
    );
    return Row(
      children: [
        for (final s in labels)
          Expanded(
            child: Center(
              child: Text(s, style: weekdayStyle),
            ),
          ),
      ],
    );
  }
}

int _weekdayGridOffset(DateTime date, MaterialLocalizations loc) {
  final weekdayFromMonday = date.weekday - 1;
  final firstDayOfWeekFromSunday = loc.firstDayOfWeekIndex;
  final firstDayOfWeekFromMonday = (firstDayOfWeekFromSunday - 1) & 7;
  final delta = weekdayFromMonday - firstDayOfWeekFromMonday;
  return ((delta % 7) + 7) % 7;
}

class _GregorianMonthGrid extends StatelessWidget {
  const _GregorianMonthGrid({
    required this.style,
    required this.month,
    required this.firstDate,
    required this.lastDate,
    required this.selected,
    required this.rangeMode,
    required this.rangeStart,
    required this.rangeEnd,
    required this.loc,
    required this.staticRows,
    required this.onDayTap,
  });

  final UnifiedInputDatePickerStyle style;
  final DateTime month;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime selected;
  final bool rangeMode;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final MaterialLocalizations loc;
  final int staticRows;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    final year = month.year;
    final monthIndex = month.month;
    final daysInMonth = DateUtils.getDaysInMonth(year, monthIndex);
    final leadingBlanks = DateUtils.firstDayOffset(year, monthIndex, loc);

    return _DayGrid(
      style: style,
      rowHeight: style.cellHeight!,
      staticRows: staticRows,
      leadingBlanks: leadingBlanks,
      daysInMonth: daysInMonth,
      firstDate: firstDate,
      lastDate: lastDate,
      selected: selected,
      rangeMode: rangeMode,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
      dayLabel: (day) => '$day',
      calendarKindForDigits: UnifiedFieldsCalendarKind.gregorian,
      gregorianForDay: (day) => DateTime(year, monthIndex, day),
      onDayTap: onDayTap,
    );
  }
}

class _JalaliMonthGrid extends StatelessWidget {
  const _JalaliMonthGrid({
    required this.style,
    required this.jalaliYear,
    required this.jalaliMonth,
    required this.firstDate,
    required this.lastDate,
    required this.selected,
    required this.rangeMode,
    required this.rangeStart,
    required this.rangeEnd,
    required this.loc,
    required this.staticRows,
    required this.onDayTap,
  });

  final UnifiedInputDatePickerStyle style;
  final int jalaliYear;
  final int jalaliMonth;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime selected;
  final bool rangeMode;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final MaterialLocalizations loc;
  final int staticRows;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    final start = PersianJalaliCalendar.toGregorianDate(
      jalaliYear,
      jalaliMonth,
      1,
    );
    final leadingBlanks = _weekdayGridOffset(start, loc);
    final daysInMonth = PersianJalaliCalendar.monthLength(
      jalaliYear,
      jalaliMonth,
    );

    return _DayGrid(
      style: style,
      rowHeight: style.cellHeight!,
      staticRows: staticRows,
      leadingBlanks: leadingBlanks,
      daysInMonth: daysInMonth,
      firstDate: firstDate,
      lastDate: lastDate,
      selected: selected,
      rangeMode: rangeMode,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
      dayLabel: (day) => '$day',
      calendarKindForDigits: UnifiedFieldsCalendarKind.jalali,
      gregorianForDay: (day) =>
          PersianJalaliCalendar.toGregorianDate(jalaliYear, jalaliMonth, day),
      onDayTap: onDayTap,
    );
  }
}

class _DayGrid extends StatelessWidget {
  const _DayGrid({
    required this.style,
    required this.rowHeight,
    required this.staticRows,
    required this.leadingBlanks,
    required this.daysInMonth,
    required this.firstDate,
    required this.lastDate,
    required this.selected,
    required this.rangeMode,
    required this.rangeStart,
    required this.rangeEnd,
    required this.dayLabel,
    this.calendarKindForDigits,
    required this.gregorianForDay,
    required this.onDayTap,
  });

  final UnifiedInputDatePickerStyle style;
  final double rowHeight;
  final int staticRows;
  final int leadingBlanks;
  final int daysInMonth;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime selected;
  final bool rangeMode;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final String Function(int day) dayLabel;
  final UnifiedFieldsCalendarKind? calendarKindForDigits;
  final DateTime Function(int day) gregorianForDay;
  final ValueChanged<DateTime> onDayTap;

  bool _inInclusiveRange(DateTime d, DateTime a, DateTime b) {
    final s = a.isBefore(b) ? a : b;
    final e = a.isBefore(b) ? b : a;
    return !d.isBefore(s) && !d.isAfter(e);
  }

  @override
  Widget build(BuildContext context) {
    final rowCount = staticRows;
    final circleSize = style.dayCircleSize!;

    int dayAtIndex(int i) => i - leadingBlanks + 1;

    return Column(
      children: [
        for (var row = 0; row < rowCount; row++)
          SizedBox(
            height: rowHeight,
            child: Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: Builder(
                      builder: (_) {
                        final i = row * 7 + col;
                        if (i < leadingBlanks ||
                            i >= leadingBlanks + daysInMonth) {
                          return const SizedBox.expand();
                        }
                        final day = dayAtIndex(i);
                        final date = DateUtils.dateOnly(gregorianForDay(day));
                        final isDisabled =
                            date.isBefore(firstDate) || date.isAfter(lastDate);

                        final rs = rangeStart;
                        final re = rangeEnd;

                        final bool isEndpoint;
                        final bool isMiddle;
                        if (!rangeMode) {
                          isEndpoint = DateUtils.isSameDay(date, selected);
                          isMiddle = false;
                        } else if (rs != null && re != null) {
                          isEndpoint =
                              DateUtils.isSameDay(date, rs) ||
                              DateUtils.isSameDay(date, re);
                          final inSpan = _inInclusiveRange(date, rs, re);
                          isMiddle = inSpan && !isEndpoint;
                        } else {
                          isEndpoint = false;
                          isMiddle = false;
                        }

                        final isToday = DateUtils.isSameDay(
                          date,
                          DateUtils.dateOnly(DateTime.now()),
                        );

                        final typography = UnifiedFieldsTypography.instance;
                        final kind = calendarKindForDigits ??
                            UnifiedFieldsCalendarKind.gregorian;
                        final labelStyle = typography.mergeDigitStyle(
                          style.calendarTextStyle(
                            TextStyle(
                              fontSize: style.dayFontSize,
                              height: 1,
                              fontWeight: isEndpoint
                                  ? style.dayFontWeightSelected
                                  : style.dayFontWeight,
                              color: isDisabled
                                  ? style.dayDisabledTextColor
                                  : isEndpoint
                                  ? style.daySelectedTextColor
                                  : isToday && !isEndpoint
                                  ? style.dayTodayTextColor
                                  : style.dayTextColor,
                            ),
                            kind,
                          ),
                          calendarKind: calendarKindForDigits,
                        );
                        final displayDay = typography.localizeDigits(
                          dayLabel(day),
                          calendarKind: calendarKindForDigits,
                        );

                        final showCircle =
                            isEndpoint || (isToday && !isEndpoint);

                        return Padding(
                          padding: const EdgeInsets.all(2),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isDisabled ? null : () => onDayTap(date),
                              customBorder: const CircleBorder(),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: isMiddle
                                      ? style.dayRangeMiddleBackgroundColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: showCircle
                                      ? SizedBox(
                                          width: circleSize,
                                          height: circleSize,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isEndpoint
                                                  ? style.daySelectedBackgroundColor
                                                  : Colors.transparent,
                                              border: isToday && !isEndpoint
                                                  ? Border.all(
                                                      color: style.dayTodayBorderColor!,
                                                      width: 2,
                                                    )
                                                  : null,
                                            ),
                                            child: Center(
                                              child: Text(
                                                displayDay,
                                                textAlign: TextAlign.center,
                                                style: labelStyle,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Text(
                                          displayDay,
                                          textAlign: TextAlign.center,
                                          style: labelStyle,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Mouse / trackpad drag + wheel on desktop for horizontal year strip.
class _DatePickerHorizontalScrollBehavior extends MaterialScrollBehavior {
  const _DatePickerHorizontalScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}

/// Horizontally scrollable year chips for month-granularity and jump panels.
class _HorizontalYearStrip extends StatefulWidget {
  const _HorizontalYearStrip({
    required this.years,
    required this.selectedYear,
    required this.onYearSelected,
    required this.style,
    required this.calendarKind,
    this.yearLabel,
  });

  final List<int> years;
  final int selectedYear;
  final ValueChanged<int> onYearSelected;
  final UnifiedInputDatePickerStyle style;
  final UnifiedFieldsCalendarKind calendarKind;
  final String? yearLabel;

  @override
  State<_HorizontalYearStrip> createState() => _HorizontalYearStripState();
}

class _HorizontalYearStripState extends State<_HorizontalYearStrip> {
  late final ScrollController _scrollController;
  late UnifiedFieldsDateYearStripStyle _stripStyle;
  var _listenMagnification = false;

  double get _itemWidth => _stripStyle.itemWidth!;
  double get _spacing => _stripStyle.spacing!;
  double get _itemStride => _itemWidth + _spacing;
  double get _horizontalPadding => 12;

  @override
  void initState() {
    super.initState();
    _stripStyle = widget.style.resolvedYearStripStyle();
    _scrollController = ScrollController();
    if (_stripStyle.useMagnification) {
      _scrollController.addListener(_onScroll);
      _listenMagnification = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(covariant _HorizontalYearStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    _stripStyle = widget.style.resolvedYearStripStyle();
    if (oldWidget.selectedYear != widget.selectedYear) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  void _onScroll() {
    if (mounted) setState(() {});
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    final delta = event.scrollDelta.dx != 0
        ? event.scrollDelta.dx
        : event.scrollDelta.dy;
    if (delta == 0) return;
    _scrollController.jumpTo(
      (position.pixels + delta).clamp(0.0, position.maxScrollExtent),
    );
  }

  void _scrollToSelected({bool animate = true}) {
    if (!_scrollController.hasClients || widget.years.isEmpty) return;
    final index = widget.years.indexOf(widget.selectedYear);
    if (index < 0) return;
    final viewport = _scrollController.position.viewportDimension;
    final itemCenter =
        _horizontalPadding + index * _itemStride + _itemWidth / 2;
    final target = itemCenter - viewport / 2;
    final clamped = target.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    if (animate) {
      _scrollController.animateTo(
        clamped,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(clamped);
    }
  }

  double _scaleForIndex(int index) {
    final mag = _stripStyle.magnification!;
    if (!_stripStyle.useMagnification) return 1;
    if (!_scrollController.hasClients) {
      return widget.years[index] == widget.selectedYear ? mag : 1;
    }
    final itemCenter =
        _horizontalPadding + index * _itemStride + _itemWidth / 2;
    final viewportCenter =
        _scrollController.offset + _scrollController.position.viewportDimension / 2;
    final distance = (itemCenter - viewportCenter).abs();
    final halfViewport = _scrollController.position.viewportDimension / 2;
    if (halfViewport <= 0) return 1;
    final t = (1 - (distance / halfViewport)).clamp(0.0, 1.0);
    return 1 + (mag - 1) * t;
  }

  @override
  void dispose() {
    if (_listenMagnification) {
      _scrollController.removeListener(_onScroll);
    }
    _scrollController.dispose();
    super.dispose();
  }

  Widget _edgeFade({required bool start}) {
    final color = _stripStyle.fadeColor;
    if (color == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: start ? Alignment.centerLeft : Alignment.centerRight,
            end: start ? Alignment.centerRight : Alignment.centerLeft,
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.years.isEmpty) return const SizedBox.shrink();

    _stripStyle = widget.style.resolvedYearStripStyle();
    final typography = UnifiedFieldsTypography.instance;
    final captionStyle = typography.mergeDigitStyle(
      widget.style.calendarTextStyle(
        TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: widget.style.monthNavIconColor,
        ),
        widget.calendarKind,
      ),
      calendarKind: widget.calendarKind,
    );

    final stripHeight = _stripStyle.stripHeight!;
    final magnifiedHeight = _stripStyle.useMagnification
        ? stripHeight * _stripStyle.magnification!
        : stripHeight;
    final fadeExtent = (_stripStyle.fadeExtent ?? 0.22).clamp(0.0, 0.45);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.yearLabel != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Text(widget.yearLabel!, style: captionStyle),
          ),
        SizedBox(
          height: magnifiedHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final fadeWidth = constraints.maxWidth * fadeExtent;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Listener(
                      onPointerSignal: _onPointerSignal,
                      child: ScrollConfiguration(
                        behavior: const _DatePickerHorizontalScrollBehavior(),
                        child: ListView.separated(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(
                            horizontal: _horizontalPadding,
                            vertical: _stripStyle.useMagnification
                                ? (magnifiedHeight - stripHeight) / 2
                                : 0,
                          ),
                          itemCount: widget.years.length,
                          separatorBuilder: (_, _) =>
                              SizedBox(width: _spacing),
                          itemBuilder: (context, index) {
                            final year = widget.years[index];
                            final selected = year == widget.selectedYear;
                            final label = typography.localizeDigits(
                              '$year',
                              calendarKind: widget.calendarKind,
                            );
                            final scale = _scaleForIndex(index);
                            return Transform.scale(
                              scale: scale,
                              alignment: Alignment.center,
                              child: _YearStripChip(
                                label: label,
                                selected: selected,
                                style: widget.style,
                                calendarKind: widget.calendarKind,
                                itemWidth: _itemWidth,
                                onTap: () => widget.onYearSelected(year),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  if (_stripStyle.effectiveShowFade && fadeWidth > 0) ...[
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: fadeWidth,
                      child: _edgeFade(start: true),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: fadeWidth,
                      child: _edgeFade(start: false),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _YearStripChip extends StatelessWidget {
  const _YearStripChip({
    required this.label,
    required this.selected,
    required this.style,
    required this.calendarKind,
    required this.itemWidth,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final UnifiedInputDatePickerStyle style;
  final UnifiedFieldsCalendarKind calendarKind;
  final double itemWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fill = selected
        ? style.monthJumpSelectedBackground
        : style.monthJumpBackground;
    final borderColor = selected
        ? style.monthJumpSelectedBorderColor
        : style.monthJumpBorderColor;
    final textColor = selected
        ? style.monthJumpSelectedTextColor
        : style.monthJumpTextColor;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          width: itemWidth,
          height: itemWidth * 0.58,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor!, width: 1),
          ),
          child: Center(
            child: Text(
              label,
              style: UnifiedFieldsTypography.instance.mergeDigitStyle(
                style.calendarTextStyle(
                  TextStyle(
                    fontSize: style.monthJumpFontSize,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: textColor,
                  ),
                  calendarKind,
                ),
                calendarKind: calendarKind,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GregorianMonthYearJumpPanel extends StatefulWidget {
  const _GregorianMonthYearJumpPanel({
    required this.style,
    required this.palette,
    required this.firstDate,
    required this.lastDate,
    required this.initialYear,
    required this.initialMonth,
    required this.title,
    required this.yearLabel,
  });

  final UnifiedInputDatePickerStyle style;
  final UnifiedInputPalette palette;
  final DateTime firstDate;
  final DateTime lastDate;
  final int initialYear;
  final int initialMonth;
  final String title;
  final String yearLabel;

  @override
  State<_GregorianMonthYearJumpPanel> createState() =>
      _GregorianMonthYearJumpPanelState();
}

class _GregorianMonthYearJumpPanelState
    extends State<_GregorianMonthYearJumpPanel> {
  late int _year;
  late int _month;

  static const List<String> _monthAbbrevs = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear.clamp(
      widget.firstDate.year,
      widget.lastDate.year,
    );
    _month = widget.initialMonth.clamp(1, 12);
    if (!monthAllowed(_year, _month)) {
      _month = firstAllowedMonth(_year) ?? _month;
    }
  }

  List<int> get _years => [
        for (
          var y = widget.firstDate.year;
          y <= widget.lastDate.year;
          y++
        )
          y,
      ];

  bool monthAllowed(int y, int m) {
    final dim = DateUtils.getDaysInMonth(y, m);
    final monthStart = DateTime(y, m, 1);
    final monthEnd = DateTime(y, m, dim);
    return !monthEnd.isBefore(widget.firstDate) &&
        !monthStart.isAfter(widget.lastDate);
  }

  int? firstAllowedMonth(int y) {
    for (var m = 1; m <= 12; m++) {
      if (monthAllowed(y, m)) return m;
    }
    return null;
  }

  void _onYearSelected(int y) {
    setState(() {
      _year = y;
      if (!monthAllowed(_year, _month)) {
        _month = firstAllowedMonth(_year) ?? _month;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.style.sheetBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(widget.title, style: widget.style.titleStyle),
          ),
          _HorizontalYearStrip(
            years: _years,
            selectedYear: _year,
            onYearSelected: _onYearSelected,
            style: widget.style,
            calendarKind: UnifiedFieldsCalendarKind.gregorian,
            yearLabel: widget.yearLabel,
          ),
          _MonthJumpGrid(
            style: widget.style,
            calendarKind: UnifiedFieldsCalendarKind.gregorian,
            labels: _monthAbbrevs,
            selectedMonth: _month,
            monthEnabled: (m) => monthAllowed(_year, m),
            onMonthSelected: (m) => setState(() => _month = m),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: FilledButton(
              onPressed: monthAllowed(_year, _month)
                  ? () => Navigator.of(context).pop((_year, _month))
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: widget.style.confirmButtonBackground,
                foregroundColor: widget.style.confirmButtonForeground,
              ),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _JalaliMonthYearJumpPanel extends StatefulWidget {
  const _JalaliMonthYearJumpPanel({
    required this.style,
    required this.palette,
    required this.firstDate,
    required this.lastDate,
    required this.initialYear,
    required this.initialMonth,
    required this.title,
    required this.yearLabel,
  });

  final UnifiedInputDatePickerStyle style;
  final UnifiedInputPalette palette;
  final DateTime firstDate;
  final DateTime lastDate;
  final int initialYear;
  final int initialMonth;
  final String title;
  final String yearLabel;

  @override
  State<_JalaliMonthYearJumpPanel> createState() =>
      _JalaliMonthYearJumpPanelState();
}

class _JalaliMonthYearJumpPanelState extends State<_JalaliMonthYearJumpPanel> {
  late int _year;
  late int _month;

  static bool jalaliMonthSelectable(
    int jy,
    int jm,
    DateTime first,
    DateTime last,
  ) {
    final f = DateUtils.dateOnly(first);
    final l = DateUtils.dateOnly(last);
    final dim = PersianJalaliCalendar.monthLength(jy, jm);
    final ds = PersianJalaliCalendar.toGregorianDate(jy, jm, 1);
    final de = PersianJalaliCalendar.toGregorianDate(jy, jm, dim);
    return !de.isBefore(f) && !ds.isAfter(l);
  }

  int get _minY => PersianJalaliCalendar.fromGregorian(widget.firstDate).year;

  int get _maxY => PersianJalaliCalendar.fromGregorian(widget.lastDate).year;

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear.clamp(_minY, _maxY);
    _month = widget.initialMonth.clamp(1, 12);
    if (!jalaliMonthSelectable(
      _year,
      _month,
      widget.firstDate,
      widget.lastDate,
    )) {
      _month = firstAllowed() ?? 1;
    }
  }

  List<int> get _years => [
        for (var y = _minY; y <= _maxY; y++) y,
      ];

  int? firstAllowed() {
    for (var m = 1; m <= 12; m++) {
      if (jalaliMonthSelectable(_year, m, widget.firstDate, widget.lastDate)) {
        return m;
      }
    }
    return null;
  }

  void _onYearSelected(int y) {
    setState(() {
      _year = y;
      if (!jalaliMonthSelectable(
        _year,
        _month,
        widget.firstDate,
        widget.lastDate,
      )) {
        _month = firstAllowed() ?? _month;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.style.sheetBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              widget.title,
              style: widget.style.calendarTextStyle(
                widget.style.titleStyle!,
                UnifiedFieldsCalendarKind.jalali,
              ),
            ),
          ),
          _HorizontalYearStrip(
            years: _years,
            selectedYear: _year,
            onYearSelected: _onYearSelected,
            style: widget.style,
            calendarKind: UnifiedFieldsCalendarKind.jalali,
            yearLabel: widget.yearLabel,
          ),
          _MonthJumpGrid(
            style: widget.style,
            calendarKind: UnifiedFieldsCalendarKind.jalali,
            labels: [
              for (var mm = 1; mm <= 12; mm++)
                PersianJalaliCalendar.persianMonthName(mm),
            ],
            selectedMonth: _month,
            monthEnabled: (m) => jalaliMonthSelectable(
              _year,
              m,
              widget.firstDate,
              widget.lastDate,
            ),
            onMonthSelected: (m) => setState(() => _month = m),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: FilledButton(
              onPressed:
                  jalaliMonthSelectable(
                    _year,
                    _month,
                    widget.firstDate,
                    widget.lastDate,
                  )
                  ? () => Navigator.of(context).pop((_year, _month))
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: widget.style.confirmButtonBackground,
                foregroundColor: widget.style.confirmButtonForeground,
              ),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fixed 3×4 grid of equal-width month cells (no chip checkmark → no layout jump on selection).
class _MonthJumpGrid extends StatelessWidget {
  const _MonthJumpGrid({
    required this.style,
    required this.calendarKind,
    required this.labels,
    required this.selectedMonth,
    required this.monthEnabled,
    required this.onMonthSelected,
  }) : assert(labels.length == 12);

  final UnifiedInputDatePickerStyle style;
  final UnifiedFieldsCalendarKind calendarKind;
  final List<String> labels;
  final int selectedMonth;
  final bool Function(int month) monthEnabled;
  final ValueChanged<int> onMonthSelected;

  static const int _cols = 3;
  static const double _spacing = 8;
  static const double _cellHeight = 42;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          final cellW = (maxW - _spacing * (_cols - 1)) / _cols;
          return Wrap(
            spacing: _spacing,
            runSpacing: _spacing,
            children: [
              for (var m = 1; m <= 12; m++)
                SizedBox(
                  width: cellW,
                  height: _cellHeight,
                  child: _MonthJumpCell(
                    label: labels[m - 1],
                    selected: selectedMonth == m,
                    enabled: monthEnabled(m),
                    style: style,
                    calendarKind: calendarKind,
                    onTap: monthEnabled(m) ? () => onMonthSelected(m) : null,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MonthJumpCell extends StatelessWidget {
  const _MonthJumpCell({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.style,
    required this.calendarKind,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final UnifiedInputDatePickerStyle style;
  final UnifiedFieldsCalendarKind calendarKind;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fill = selected
        ? style.monthJumpSelectedBackground
        : style.monthJumpBackground;
    final borderColor = selected
        ? style.monthJumpSelectedBorderColor
        : style.monthJumpBorderColor;
    final textColor = !enabled
        ? style.dayDisabledTextColor
        : selected
        ? style.monthJumpSelectedTextColor
        : style.monthJumpTextColor;

    Widget child = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor!, width: 1),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: UnifiedFieldsTypography.instance.mergeDigitStyle(
                  style.calendarTextStyle(
                    TextStyle(
                      fontSize: style.monthJumpFontSize,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: textColor,
                    ),
                    calendarKind,
                  ),
                  calendarKind: calendarKind,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (!enabled) {
      child = Opacity(opacity: style.monthJumpDisabledOpacity!, child: child);
    }

    return child;
  }
}

int _monthsBetween(DateTime startMonth, DateTime endMonth) {
  return (endMonth.year - startMonth.year) * 12 +
      (endMonth.month - startMonth.month);
}

DateTime _clampDate(DateTime date, DateTime min, DateTime max) {
  if (date.isBefore(min)) return min;
  if (date.isAfter(max)) return max;
  return date;
}
